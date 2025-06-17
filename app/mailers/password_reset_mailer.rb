class PasswordResetMailer < ApplicationMailer
  def reset_password(user, token, subdomain)
    @user = user
    @token = token

    host = ENV.fetch("DEFAULT_MAILER_HOST") { "#{subdomain}.lvh.me" } # or change to your frontend host
    protocol = Rails.env.production? ? "https" : "http"

    @reset_url = "#{protocol}://#{host}:3001/reset-password/#{@token}"

    mail(
      to: @user.email,
      subject: I18n.t("mailers.password_reset.subject", default: "Reset your password")
    )
  end

  def confirmation(user)
    @user = user

    mail(
      to: @user.email,
      subject: I18n.t("mailers.password_reset.confirmation_subject", default: "Your password was successfully changed")
    )
  end
end
