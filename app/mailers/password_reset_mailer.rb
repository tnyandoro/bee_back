class PasswordResetMailer < ApplicationMailer
    def reset_password(user, token, subdomain)
        @user = user
        @token = token
        @reset_url = "http://#{subdomain}.lvh.me:3001/reset-password/#{token}"
        mail(to: @user.email, subject: "Reset Your Password")
    end
end