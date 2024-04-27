class AuthController < ApplicationController
   class InvalidTokenError < StandardError; end
   class UloginError < StandardError; end

   before_action :validate_csrf, only: %i(ulogin)
   before_action :fetch_info, only: %i(ulogin)

   rescue_from Exception, with: :exception
   rescue_from UloginError, with: :ulogin_error
   rescue_from InvalidTokenError, with: :invalid_token_error

   skip_before_action :verify_authenticity_token

   def ulogin
      service = UloginSignupOrLoginService.new(@info)
      service.do

      update_session(service.info)
      logger.debug ("Session from uLogin: #{session.to_hash.inspect}")

      new_params = session.to_hash.select {|x| %w(_csrf_token name avatar_url uid info).include?(x) }

      redirect_back_or_to root_url, fallback_location: root_path(new_params)
   end

   def fetch_info
      raise(InvalidTokenError) unless params["token"]

      uri = URI('http://ulogin.ru/token.php')
      uri.query = URI.encode_www_form({ token: params["token"] })
     # uri.query = URI.encode_www_form({ token: params["token"], host: http_host })
      response = Net::HTTP.get_response(uri)

      raise(InvalidTokenError) unless response.code == "200"

      @info = JSON.parse(response.body)

      raise(UloginError.new(@info["error"])) if @info["error"]
   end

   def exception e
      Rails.logger.error e.inspect

      redirect_back_or_to root_url, error: e.message
   end

   def ulogin_error e
      Rails.logger.error e.inspect

      redirect_back_or_to root_url, error: e.message
   end

   def invalid_token_error e
      Rails.logger.error e.inspect

      head status: 401
   end

   def validate_csrf
      request.headers["X-CSRF-Token"] = params["_csfr_token"]

      verify_authenticity_token
   end
end
