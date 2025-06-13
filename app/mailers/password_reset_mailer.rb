class PasswordResetMailer < ApplicationMailer
    def reset_password(user, token, subdomain)
      @user = user
      @token = token
  
      host = ENV.fetch("DEFAULT_MAILER_HOST") { "#{subdomain}.example.com" }
      protocol = Rails.env.production? ? "https" : "http"
  
      @reset_url = Rails.application.routes.url_helpers.reset_password_url(
        token,
        host: host,
        protocol: protocol
      )
  
      mail(
        to: @user.email,
        subject: I18n.t("mailers.password_reset.subject")
      )
    end
end
