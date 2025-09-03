# frozen_string_literal: true
module Api
  module V1
    class TicketsController < Api::V1::ApiController
      before_action :set_ticket, only: %i[show update destroy assign_to_user escalate_to_problem resolve download_attachment]
      before_action :set_creator, only: [:create]
      before_action :validate_params, only: [:index]

      VALID_STATUSES = %w[open assigned escalated closed suspended resolved pending].freeze
      VALID_TICKET_TYPES = %w[Incident Request Problem].freeze
      VALID_CATEGORIES = %w[Query Complaint Compliment Other].freeze

      # -------------------------------
      # INDEX
      # -------------------------------
      def index
        @tickets = apply_filters(@organization.tickets)
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 10).to_i
        per_page = [per_page, 100].min

        if page < 1 || per_page < 1
          render json: { error: "Invalid pagination parameters" }, status: :unprocessable_entity
          return
        end

        @tickets = @tickets.paginate(page: page, per_page: per_page)

        render json: {
          tickets: @tickets.map { |ticket| ticket_attributes(ticket) },
          pagination: {
            current_page: @tickets.current_page,
            total_pages: @tickets.total_pages,
            total_entries: @tickets.total_entries
          }
        }, status: :ok
      end

      # -------------------------------
      # SHOW
      # -------------------------------
      def show
        unless @ticket.organization_id == @organization.id
          return render json: { error: "Ticket does not belong to this organization" }, status: :forbidden
        end

        unless current_user.domain_admin? || current_user.system_admin? || @ticket.team_id == current_user.team_id
          return render json: { error: "You are not authorized to view this ticket" }, status: :forbidden
        end

        render json: ticket_attributes(@ticket)
      end

      # -------------------------------
      # CREATE
      # -------------------------------
      def create
        unless current_user.can_create_tickets?(ticket_params[:ticket_type])
          return render_forbidden("Unauthorized to create #{ticket_params[:ticket_type]} ticket")
        end

        ticket_params_adjusted = ticket_params_with_enums
        @ticket = @organization.tickets.new(ticket_params_adjusted)
        @ticket.creator = current_user
        @ticket.requester = current_user
        @ticket.reported_at ||= Time.zone.now
        @ticket.status = 'open'

        if ticket_params_adjusted[:priority].present?
          priority_value = ticket_params_adjusted[:priority].to_i
          @ticket.priority = Ticket.priorities.key([0, [3, priority_value].min].max)
        end

        begin
          process_team_and_assignee(ticket_params_adjusted)
        rescue ActiveRecord::RecordNotFound => e
          return render json: { error: e.message }, status: :not_found
        end

        unless VALID_CATEGORIES.include?(ticket_params_adjusted[:category])
          return render json: { error: "Invalid category. Allowed values are: #{VALID_CATEGORIES.join(', ')}" },
                        status: :unprocessable_entity
        end

        if @ticket.save
          if params[:ticket][:attachment].present?
            document = Document.create!(tenant: @organization)
            document.pdf_file.attach(params[:ticket][:attachment])
            @ticket.update(document: document)
          end

          if params[:ticket][:files].present?
            @ticket.files.attach(params[:ticket][:files])
          end

          begin
            SlaCalculator.new(@ticket).calculate
          rescue => e
            Rails.logger.warn "SLA calculation failed for Ticket ##{@ticket.id}: #{e.message}"
          end

          create_initial_comment
          create_notifications

          # Send emails for team and assignee
          if @ticket.team
            @ticket.team.users.each do |user|
              TicketMailer.ticket_assigned_to_team(@ticket, user).deliver_later if user.email
            end
          end
          if @ticket.assignee
            TicketMailer.ticket_assigned_to_user(@ticket, @ticket.assignee).deliver_later if @ticket.assignee.email
          end

          render json: ticket_attributes(@ticket), status: :created
        else
          render json: { errors: @ticket.errors.full_messages, details: @ticket.errors.details },
                status: :unprocessable_entity
        end
      end

      # -------------------------------
      # UPDATE
      # -------------------------------
      def update
        unless current_user.can_resolve_tickets?(@ticket.ticket_type) || current_user.can_reassign_tickets? || current_user.can_change_urgency?
          return render_forbidden("Unauthorized to update this ticket")
        end

        ticket_params_adjusted = ticket_params_with_enums
        original_team_id = @ticket.team_id
        original_assignee_id = @ticket.assignee_id

        if ticket_params_adjusted[:priority].present?
          unless current_user.can_change_urgency?
            return render_forbidden("Unauthorized to change ticket urgency")
          end
          priority_value = ticket_params_adjusted[:priority].to_i
          ticket_params_adjusted[:priority] = Ticket.priorities.key([0, [3, priority_value].min].max)
        end

        begin
          process_team_and_assignee_for_update(ticket_params_adjusted)
        rescue ActiveRecord::RecordNotFound => e
          return render json: { error: e.message }, status: :not_found
        end

        if ticket_params_adjusted[:category].present? && !VALID_CATEGORIES.include?(ticket_params_adjusted[:category])
          return render json: { error: "Invalid category. Allowed values are: #{VALID_CATEGORIES.join(', ')}" }, status: :unprocessable_entity
        end

        # Handle attachments
        if params[:ticket][:attachment].present?
          document = @ticket.document || Document.create!(tenant: @organization)
          document.pdf_file.attach(params[:ticket][:attachment])
          @ticket.update(document: document)
        end

        if params[:ticket][:files].present?
          @ticket.files.attach(params[:ticket][:files])
        end

        if params[:ticket].present?
          resolution_fields = params.require(:ticket).permit(
            :status, :resolved_at, :resolution_note, :reason, :resolution_method,
            :cause_code, :resolution_details, :end_customer, :support_center, :total_kilometer
          ).to_h.symbolize_keys
          ticket_params_adjusted.merge!(resolution_fields) if resolution_fields.present?
        end

        if @ticket.update(ticket_params_adjusted)
          if ticket_params_adjusted[:status] == 'resolved' && !@ticket.resolved_at_was
            unless current_user.can_resolve_tickets?(@ticket.ticket_type)
              return render_forbidden("Unauthorized to resolve #{@ticket.ticket_type} ticket")
            end
            @ticket.update!(resolved_at: Time.current)
            create_resolution_comment(ticket_params_adjusted[:resolution_note] || "Resolved by #{current_user.name}")
            create_resolution_notification
          end

          # Send emails if team or assignee changed
          if @ticket.team_id != original_team_id && @ticket.team
            @ticket.team.users.each do |user|
              TicketMailer.ticket_assigned_to_team(@ticket, user).deliver_later if user.email
            end
          end
          if @ticket.assignee_id != original_assignee_id && @ticket.assignee
            TicketMailer.ticket_assigned_to_user(@ticket, @ticket.assignee).deliver_later if @ticket.assignee.email
          end

          render json: ticket_attributes(@ticket)
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # -------------------------------
      # DESTROY
      # -------------------------------
      def destroy
        unless current_user.is_admin? || current_user.domain_admin? || current_user.system_admin?
          return render_forbidden("Only admins can delete tickets")
        end
        @ticket.destroy!
        head :no_content
      end

      # -------------------------------
      # ASSIGN TO USER
      # -------------------------------
      def assign_to_user
        unless current_user.can_reassign_tickets? || (current_user.team_leader? && current_user.team == @ticket.team)
          return render json: { error: 'You are not authorized to assign this ticket' }, status: :forbidden
        end

        assignee = @ticket.team.users.find_by(id: params[:user_id])
        unless assignee
          return render json: { error: 'User not found in the team' }, status: :unprocessable_entity
        end

        if @ticket.update(assignee: assignee, status: 'assigned')
          TicketMailer.ticket_assigned_to_user(@ticket, assignee).deliver_later if assignee.email
          create_assignment_notification(assignee)
          render json: ticket_attributes(@ticket).merge(
            notification: {
              id: @ticket.notifications.last.id,
              message: @ticket.notifications.last.message
            }
          ), status: :ok
        else
          render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # -------------------------------
      # ESCALATE TO PROBLEM
      # -------------------------------
      def escalate_to_problem
        unless current_user.team_leader? || current_user.super_user? || current_user.department_manager? || current_user.general_manager? || current_user.domain_admin? || current_user.system_admin?
          return render json: { error: 'Only team leads or higher can escalate tickets to problems' }, status: :forbidden
        end

        @problem = Problem.new(
          description: @ticket.description,
          organization: @ticket.organization,
          team: @ticket.team,
          creator: current_user,
          ticket: @ticket
        )

        if @problem.save
          @ticket.update!(status: 'escalated')
          create_escalation_notification if @ticket.assignee
          render json: { message: 'Ticket escalated to problem', problem: @problem.as_json }, status: :created
        else
          render json: { errors: @problem.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # -------------------------------
      # RESOLVE
      # -------------------------------
      def resolve
        unless current_user.can_resolve_tickets?(@ticket.ticket_type)
          return render json: { error: "You are not authorized to resolve this #{@ticket.ticket_type} ticket" }, status: :forbidden
        end

        if @ticket.resolved? || @ticket.closed?
          return render json: { error: 'Ticket is already resolved or closed' }, status: :unprocessable_entity
        end

        resolution_params_adjusted = resolve_params
        resolution_params_adjusted[:status] = 'resolved'
        resolution_params_adjusted[:resolved_at] = Time.current

        begin
          ActiveRecord::Base.transaction do
            @ticket.update!(resolution_params_adjusted)
            create_resolution_comment(resolution_params_adjusted[:resolution_note] || "Resolved by #{current_user.name}")
            create_resolution_notification
          end
          render json: ticket_attributes(@ticket), status: :ok
        rescue ActiveRecord::RecordInvalid => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      # -------------------------------
      # DOWNLOAD ATTACHMENT
      # -------------------------------
      def download_attachment
        attachment = if @ticket.document&.pdf_file&.attached?
                       @ticket.document.pdf_file
                     elsif @ticket.attachment&.attached?
                       @ticket.attachment
                     else
                       @ticket.files.find { |file| file.id.to_s == params[:attachment_id] }
                     end
        if attachment
          redirect_to rails_blob_url(attachment, disposition: "attachment")
        else
          render json: { error: "Attachment not found" }, status: :not_found
        end
      end

      # -------------------------------
      # PRIVATE METHODS
      # -------------------------------

      private

      def create_notifications
        notification = Notification.create!(
          user: @ticket.requester,
          organization: @ticket.organization,
          message: "New ticket created: #{@ticket.title} (#{@ticket.ticket_number})",
          notifiable: @ticket,
          read: false
        )
        NotificationMailer.notify_user(notification).deliver_later
      end

      def ticket_attributes(ticket)
        {
          id: ticket.id,
          ticket_number: ticket.ticket_number,
          title: ticket.title,
          description: ticket.description,
          ticket_type: ticket.ticket_type,
          status: ticket.status,
          urgency: ticket.urgency,
          priority: ticket.priority_before_type_cast,
          impact: ticket.impact,
          team: ticket.team ? { id: ticket.team.id, name: ticket.team.name } : nil,
          assignee_id: ticket.assignee_id,
          requester_id: ticket.requester_id,
          creator_id: ticket.creator_id,
          reported_at: ticket.reported_at&.in_time_zone('Africa/Johannesburg')&.strftime('%Y-%m-%dT%H:%M'),
          caller_name: ticket.caller_name,
          caller_surname: ticket.caller_surname,
          caller_email: ticket.caller_email,
          caller_phone: ticket.caller_phone,
          customer: ticket.customer,
          source: ticket.source,
          category: ticket.category,
          response_due_at: ticket.response_due_at&.in_time_zone('Africa/Johannesburg')&.iso8601,
          resolution_due_at: ticket.resolution_due_at&.in_time_zone('Africa/Johannesburg')&.iso8601,
          escalation_level: ticket.escalation_level,
          sla_breached: ticket.sla_breached,
          calculated_priority: ticket.calculated_priority,
          resolved_at: ticket.resolved_at&.in_time_zone('Africa/Johannesburg')&.iso8601,
          resolution_note: ticket.resolution_note,
          reason: ticket.reason,
          resolution_method: ticket.resolution_method,
          cause_code: ticket.cause_code,
          resolution_details: ticket.resolution_details,
          end_customer: ticket.end_customer,
          support_center: ticket.support_center,
          total_kilometer: ticket.total_kilometer,
          assignee: ticket.assignee ? { id: ticket.assignee.id, name: ticket.assignee.name } : nil,
          creator: ticket.creator ? { id: ticket.creator.id, name: ticket.creator.name } : nil,
          requester: ticket.requester ? { id: ticket.requester.id, name: ticket.requester.name } : nil,
          created_at: ticket.created_at&.in_time_zone('Africa/Johannesburg')&.iso8601,
          updated_at: ticket.updated_at&.in_time_zone('Africa/Johannesburg')&.iso8601,
          attachments: (
            attachments = []
            if ticket.document&.pdf_file&.attached?
              attachments << {
                id: ticket.document.pdf_file.id,
                filename: ticket.document.pdf_file.filename.to_s,
                url: rails_blob_url(ticket.document.pdf_file),
                size: ticket.document.pdf_file.byte_size
              }
            end
            if ticket.attachment&.attached?
              attachments << {
                id: ticket.attachment.id,
                filename: ticket.attachment.filename.to_s,
                url: rails_blob_url(ticket.attachment),
                size: ticket.attachment.byte_size
              }
            end
            if ticket.files&.attached?
              ticket.files.each do |file|
                attachments << {
                  id: file.id,
                  filename: file.filename.to_s,
                  url: rails_blob_url(file),
                  size: file.byte_size
                }
              end
            end
            attachments
          ),
          notifications: ticket.notifications.map do |notification|
            {
              id: notification.id,
              message: notification.message,
              read: notification.read,
              created_at: notification.created_at.in_time_zone('Africa/Johannesburg').iso8601
            }
          end
        }
      end

      def ticket_params
        params.require(:ticket).permit(
          :title, :description, :ticket_type, :urgency, :priority, :impact,
          :team_id, :caller_name, :caller_surname, :caller_email, :caller_phone,
          :customer, :source, :category, :assignee_id, :ticket_number, :reported_at,
          :creator_id, :requester_id, :status, :resolved_at, :resolution_note,
          :reason, :resolution_method, :cause_code, :resolution_details,
          :end_customer, :support_center, :total_kilometer,
          :attachment, files: []
        )
      end

      def resolve_params
        params.require(:ticket).permit(
          :resolution_note, :reason, :resolution_method, :cause_code,
          :resolution_details, :end_customer, :support_center, :total_kilometer
        )
      end

      def set_creator
        @creator = current_user
        render json: { error: 'User not authenticated' }, status: :unauthorized unless @creator
      end

      def set_organization_from_subdomain
        subdomain = request.headers['X-Organization-Subdomain'] || params[:organization_subdomain] || request.subdomains.first
        Rails.logger.info "Looking up organization with subdomain: #{subdomain}"
        @organization = Organization.find_by(subdomain: subdomain)
        unless @organization
          Rails.logger.error "Organization not found for subdomain: #{subdomain}"
          render json: { error: "Organization not found for subdomain: #{subdomain}" }, status: :not_found
        end
      end

      def validate_params
        return unless validate_status && validate_ticket_type
        true
      end

      def validate_status
        return true unless params[:status].present?
        return true if VALID_STATUSES.include?(params[:status])
        render json: { error: "Invalid status. Allowed values are: #{VALID_STATUSES.join(', ')}" }, status: :unprocessable_entity
        false
      end

      def validate_ticket_type
        return true unless params[:ticket_type].present?
        return true if VALID_TICKET_TYPES.include?(params[:ticket_type])
        render json: { error: "Invalid ticket type. Allowed values are: #{VALID_TICKET_TYPES.join(', ')}" }, status: :unprocessable_entity
        false
      end

      def apply_filters(scope)
        Rails.logger.info "Fetching tickets for organization: #{params[:organization_subdomain] || request.headers['X-Organization-Subdomain'] || request.subdomains.first}"
        Rails.logger.info "Current user: #{current_user&.id} - #{current_user&.email}"
        Rails.logger.info "User roles: admin=#{current_user.admin?}, general_manager=#{current_user.general_manager?}, domain_admin=#{current_user.domain_admin?}, system_admin=#{current_user.system_admin?}"

        unless current_user.domain_admin? || current_user.system_admin?
          if current_user.team_id.present?
            scope = scope.where(team_id: current_user.team_id)
          else
            scope = scope.none
          end
        end

        scope = scope.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
        scope = scope.where(assignee_id: params[:user_id]) if params[:user_id].present?
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(ticket_type: params[:ticket_type]) if params[:ticket_type].present?
        scope = scope.where(team_id: params[:team_id]) if params[:team_id].present?
        scope = scope.where(department_id: params[:department_id]) if params[:department_id].present?

        if params[:reported_from].present? && params[:reported_to].present?
          from = Time.zone.parse(params[:reported_from]) rescue nil
          to = Time.zone.parse(params[:reported_to]) rescue nil
          scope = scope.where(reported_at: from.beginning_of_day..to.end_of_day) if from && to
        elsif params[:reported_from].present?
          from = Time.zone.parse(params[:reported_from]) rescue nil
          scope = scope.where("reported_at >= ?", from.beginning_of_day) if from
        elsif params[:reported_to].present?
          to = Time.zone.parse(params[:reported_to]) rescue nil
          scope = scope.where("reported_at <= ?", to.end_of_day) if to
        end

        if params[:created_from].present? && params[:created_to].present?
          from = Time.zone.parse(params[:created_from]) rescue nil
          to = Time.zone.parse(params[:created_to]) rescue nil
          scope = scope.where(created_at: from.beginning_of_day..to.end_of_day) if from && to
        elsif params[:created_from].present?
          from = Time.zone.parse(params[:created_from]) rescue nil
          scope = scope.where("created_at >= ?", from.beginning_of_day) if from
        elsif params[:created_to].present?
          to = Time.zone.parse(params[:created_to]) rescue nil
          scope = scope.where("created_at <= ?", to.end_of_day) if to
        end

        if params[:resolved_from].present? && params[:resolved_to].present?
          from = Time.zone.parse(params[:resolved_from]) rescue nil
          to = Time.zone.parse(params[:resolved_to]) rescue nil
          scope = scope.where(resolved_at: from.beginning_of_day..to.end_of_day) if from && to
        elsif params[:resolved_from].present?
          from = Time.zone.parse(params[:resolved_from]) rescue nil
          scope = scope.where("resolved_at >= ?", from.beginning_of_day) if from
        elsif params[:resolved_to].present?
          to = Time.zone.parse(params[:resolved_to]) rescue nil
          scope = scope.where("resolved_at <= ?", to.end_of_day) if to
        end

        if params[:updated_from].present? && params[:updated_to].present?
          from = Time.zone.parse(params[:updated_from]) rescue nil
          to = Time.zone.parse(params[:updated_to]) rescue nil
          scope = scope.where(updated_at: from.beginning_of_day..to.end_of_day) if from && to
        elsif params[:updated_from].present?
          from = Time.zone.parse(params[:updated_from]) rescue nil
          scope = scope.where("updated_at >= ?", from.beginning_of_day) if from
        elsif params[:updated_to].present?
          to = Time.zone.parse(params[:updated_to]) rescue nil
          scope = scope.where("updated_at <= ?", to.end_of_day) if to
        end

        Rails.logger.info "Filtered ticket count: #{scope.count}"
        scope
      end

      def debug_ticket_counts
        {
          organization: {
            id: @organization.id,
            name: @organization.name,
            subdomain: @organization.subdomain
          },
          current_user: {
            id: current_user.id,
            email: current_user.email,
            team_id: current_user.team_id,
            department_id: current_user.department_id,
            roles: {
              admin: current_user.admin?,
              general_manager: current_user.general_manager?,
              domain_admin: current_user.domain_admin?,
              system_admin: current_user.system_admin?,
              team_leader: current_user.team_leader?
            }
          },
          ticket_counts: {
            total_in_organization: @organization.tickets.count,
            visible_to_user: apply_filters(@organization.tickets).count,
            open_visible_to_user: apply_filters(@organization.tickets).where(status: 'open').count,
            assigned_to_user: @organization.tickets.where(assignee_id: current_user.id).count,
            in_user_team: current_user.team_id ? @organization.tickets.where(team_id: current_user.team_id).count : 0,
            in_user_department: current_user.department_id ? @organization.tickets.where(department_id: current_user.department_id).count : 0
          },
          sample_visible_tickets: apply_filters(@organization.tickets).limit(5).pluck(:id, :status, :assignee_id, :team_id, :department_id)
        }
      end

      def stats
        group_by = params[:group_by] || 'daily'
        date_field = params[:date_field] || 'created_at'

        unless %w[daily monthly].include?(group_by)
          return render json: { error: "Invalid group_by parameter. Use 'daily' or 'monthly'" }, status: :bad_request
        end

        unless %w[created_at resolved_at updated_at].include?(date_field)
          return render json: { error: "Invalid date_field parameter. Use 'created_at', 'resolved_at', or 'updated_at'" }, status: :bad_request
        end

        scope = @organization.tickets

        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(ticket_type: params[:ticket_type]) if params[:ticket_type].present?

        if params[:start_date].present? && params[:end_date].present?
          start_date = Date.parse(params[:start_date]) rescue nil
          end_date = Date.parse(params[:end_date]) rescue nil
          if start_date && end_date
            scope = scope.where("#{date_field} BETWEEN ? AND ?", start_date.beginning_of_day, end_date.end_of_day)
          end
        end

        case group_by
        when 'daily'
          data = scope
                   .group("DATE(#{date_field})")
                   .order("DATE(#{date_field})")
                   .count
        when 'monthly'
          data = scope
                   .group("DATE_TRUNC('month', #{date_field})")
                   .order("DATE_TRUNC('month', #{date_field})")
                   .count
        end

        formatted = data.map do |date, count|
          { date: date.to_date.to_s, count: count }
        end

        render json: {
          grouped_by: group_by,
          field: date_field,
          organization: @organization.subdomain,
          data: formatted
        }, status: :ok
      end

      def set_ticket
        @ticket = @organization.tickets.find_by(id: params[:id]) ||
                  @organization.tickets.find_by(ticket_number: params[:id])
        raise ActiveRecord::RecordNotFound unless @ticket
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Ticket not found' }, status: :not_found
      end

      def ticket_params_with_enums
        permitted_params = ticket_params.dup

        if permitted_params[:urgency].present?
          urgency_value = permitted_params[:urgency].downcase
          permitted_params[:urgency] = Ticket.urgencies[urgency_value]
          unless permitted_params[:urgency]
            raise ArgumentError, "Invalid urgency: #{urgency_value}. Allowed values are: #{Ticket.urgencies.keys.join(', ')}"
          end
        end

        if permitted_params[:impact].present?
          impact_value = permitted_params[:impact].downcase
          permitted_params[:impact] = Ticket.impacts[impact_value]
          unless permitted_params[:impact]
            raise ArgumentError, "Invalid impact: #{impact_value}. Allowed values are: #{Ticket.impacts.keys.join(', ')}"
          end
        end

        permitted_params
      end

      def export
        tickets = apply_filters(@organization.tickets).limit(10_000)

        respond_to do |format|
          format.csv do
            headers["Content-Disposition"] = "attachment; filename=tickets-#{Date.today}.csv"
            headers["Content-Type"] = "text/csv"
            render plain: tickets_to_csv(tickets)
          end

          format.xlsx do
            render xlsx: "export", filename: "tickets-#{Date.today}.xlsx", locals: { tickets: tickets }
          end
        end
      end

      def process_team_and_assignee(params)
        if params[:team_id].present?
          team = @organization.teams.find_by(id: params[:team_id])
          unless team
            raise ActiveRecord::RecordNotFound, 'Team not found in this organization'
          end
          @ticket.team = team

          if params[:assignee_id].present?
            unless current_user.can_reassign_tickets? || (current_user.team_leader? && current_user.team == team)
              raise ArgumentError, 'Unauthorized to assign this ticket'
            end
            assignee = @organization.users.find_by(id: params[:assignee_id])
            unless assignee
              raise ActiveRecord::RecordNotFound, "User #{params[:assignee_id]} not found in organization"
            end

            unless team.users.exists?(id: assignee.id)
              raise ActiveRecord::RecordNotFound, "User #{params[:assignee_id]} not found in team #{team.id}"
            end

            @ticket.assignee = assignee
            @ticket.status = 'assigned'
          elsif @ticket.assignee.nil? # Auto-assign if no assignee provided
            assignee = find_least_busy_user(team)
            if assignee
              @ticket.assignee = assignee
              @ticket.status = 'assigned'
            end
          end
        end
      end

      def process_team_and_assignee_for_update(params)
        team_changed = false
        new_team = nil

        if params[:team_id].present?
          new_team = @organization.teams.find_by(id: params[:team_id])
          unless new_team
            raise ActiveRecord::RecordNotFound, 'Team not found in this organization'
          end
          team_changed = @ticket.team_id != new_team.id

          if team_changed && @ticket.assignee.present? && !new_team.users.include?(@ticket.assignee)
            @ticket.assignee = nil
          end

          @ticket.team = new_team
        end

        if params[:assignee_id].present?
          team = new_team || @ticket.team
          unless team
            raise ArgumentError, 'Cannot assign user without a team'
          end
          unless current_user.can_reassign_tickets? || (current_user.team_leader? && current_user.team == team)
            raise ArgumentError, 'Unauthorized to assign this ticket'
          end
          assignee = @organization.users.find_by(id: params[:assignee_id])
          unless assignee
            raise ActiveRecord::RecordNotFound, "User #{params[:assignee_id]} not found in organization"
          end

          unless team.users.exists?(id: assignee.id)
            raise ActiveRecord::RecordNotFound, "User #{params[:assignee_id]} not found in team #{team.id}"
          end

          @ticket.assignee = assignee
          @ticket.status = 'assigned'
        elsif params[:team_id].present? && @ticket.assignee.nil? # Auto-assign if team specified and no assignee
          assignee = find_least_busy_user(@ticket.team)
          if assignee
            @ticket.assignee = assignee
            @ticket.status = 'assigned'
          end
        end
      end

      def find_least_busy_user(team)
        active_statuses = %w[open assigned escalated pending suspended].map { |s| Ticket.statuses[s] }
        team.users
          .left_joins(:assigned_tickets)
          .group('users.id')
          .having("COALESCE(SUM(CASE WHEN tickets.status IN (?) THEN 1 ELSE 0 END), 0) = 0", active_statuses)
          .order('users.id ASC')
          .first
      end

      def create_initial_comment
        @ticket.comments.create!(
          content: "Ticket created by #{@creator.name}",
          user: @creator
        )
      end

      def create_assignment_notification(assignee)
        Notification.create!(
          user: assignee,
          organization: @ticket.organization,
          message: "You have been assigned a new ticket: #{@ticket.title} (#{@ticket.ticket_number})",
          read: false,
          notifiable: @ticket
        )
      end

      def create_escalation_notification
        Notification.create!(
          user: @ticket.assignee,
          organization: @ticket.organization,
          message: "Ticket #{@ticket.ticket_number} has been escalated to a problem",
          read: false,
          notifiable: @problem
        )
      end

      def create_resolution_comment(resolution_note)
        @ticket.comments.create!(
          content: "Ticket resolved: #{resolution_note}",
          user: current_user
        )
      end

      def create_resolution_notification
        if @ticket.assignee && @ticket.assignee != current_user && @ticket.assignee != @ticket.requester
          notification = Notification.create!(
            user: @ticket.assignee,
            organization: @ticket.organization,
            message: "Ticket resolved by #{current_user.name}: #{@ticket.title} (#{@ticket.ticket_number})",
            read: false,
            notifiable: @ticket
          )
          NotificationMailer.notify_user(notification).deliver_later
        end
      end
    end
  end
end