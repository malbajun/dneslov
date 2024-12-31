class Api::V1::UsersController < Api::CommonController
   after_action :send_validation_email, only: :create

   def send_validation_email
      if @object.email.no
         logger.info("New User Info: #{@object.email.no}: #{@object.email.validate_url}")

         UserMailer.email_validation(@object).deliver_later
      end
   end
end
