class UserMailer < ApplicationMailer
   def welcome_email user
      @user = user

      mail(to: @user.email.no, subject: 'Welcome to My Awesome Site')
   end

   def email_validation user
      @user = user

      Rails.logger.info("#{user.email.no}: #{user.email.validate_url}")

      mail(to: "#{user.email.no}", subject: "Email validation")
   end
end
