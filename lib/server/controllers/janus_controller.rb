class Janus
  class Controller < Etna::Controller
    VIEW_PATH = File.expand_path('../views', __dir__)

    def initialize(request, action)
      super
      @token = nil
    end

    private

    def success_json(hash = {})
      success('application/json', hash.to_json)
    end

    # Token comes from params but should probably come from headers.
    def token
      @token ||= Janus::Token[token: @params[:token]]
    end

    # Janus only takes requests from authorized applications.
    def app_key_valid?
      @params.key?(:app_key) && app_valid?(@params[:app_key])
    end

    # Checks for the user email and password. This is used before a user token
    # is generated.
    def email_password_valid?
      @params.key?(:email) &&
      @params.key?(:password) &&
      email_valid?(@params[:email])
    end

    # Checks for the user token and makes sure that the user token is valid.
    def token_valid?
      @params.key?(:token) && token && token.valid?
    end

    # Quick check that the email is in a somewhat valid format.
    def email_valid?(eml)
      eml =~ Conf::EMAIL_MATCH
    end

    # Check to see if the application key is valid.
    def app_valid?(app_key)
      return Janus::App[app_key: app_key]
    end
  end
end
