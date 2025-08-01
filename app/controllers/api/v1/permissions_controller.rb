# app/controllers/api/v1/permissions_controller.rb
module Api
  module V1
    class PermissionsController < Api::V1::ApplicationController
      before_action :authenticate_user!

      def show
        render_success(permission_hash(current_user), "Permissions retrieved successfully")
      end

      private

      def permission_hash(user)
        {
          role: user.role,
          can_create_ticket: user.can_create_ticket?,
          can_view_all_tickets: user.can_view_all_tickets?,
          can_view_assigned_tickets: user.can_view_assigned_tickets?,
          can_access_knowledge_base: user.can_access_knowledge_base?,
          can_access_incidents_overview: user.can_access_incidents_overview?,
          can_access_problems_overview: user.can_access_problems_overview?,
          can_view_problems_only: user.can_view_problems_only?,
          can_access_settings: user.can_access_settings?,
          can_access_admin_settings: user.can_access_admin_settings?,
          can_view_own_profile: user.can_view_own_profile?,
          can_edit_own_profile: user.can_edit_own_profile?,
          can_view_user_profiles: user.can_view_user_profiles?,
          can_access_admin_dashboard: user.can_access_admin_dashboard?,
          can_access_main_dashboard: user.can_access_main_dashboard?,
          can_create_problem: user.can_create_problem?,
          can_reassign_tickets: user.can_reassign_tickets?,
          can_change_urgency: user.can_change_urgency?,
          can_manage_incidents: user.can_manage_incidents?,
          can_manage_problems: user.can_manage_problems?,
          can_manage_changes: user.can_manage_changes?,
          can_access_call_center: user.can_access_call_center?,
          can_escalate_tickets: user.can_escalate_tickets?,
          can_manage_users: user.can_manage_users?,
          can_create_teams: user.can_create_teams?,
          can_manage_organization: user.can_manage_organization?,
          can_view_reports: {
            team: user.can_view_reports?(:team),
            department: user.can_view_reports?(:department),
            organization: user.can_view_reports?(:organization)
          }
        }
      end
    end
  end
end