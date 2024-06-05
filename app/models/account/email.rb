class Account::Email < Account
   include Rails.application.routes.url_helpers

   validates :no, format: { with: URI::MailTo::EMAIL_REGEXP }

   def validate_url
      url_for(controller: "sessions", action: "update", token: CGI.escape(validate_token.code))
   end
end
