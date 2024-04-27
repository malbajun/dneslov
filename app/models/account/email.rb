class Account::Email < Account
   validates :no, format: { with: URI::MailTo::EMAIL_REGEXP }

   def validate_url
      File.join *[ImageUploader.asset_host.to_s, 'token', 'validate', CGI.escape(validate_token.code)]
   end
end
