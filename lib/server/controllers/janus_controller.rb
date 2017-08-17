class Janus
  class Controller < Etna::Controller
    def initialize(request, action)
      super
      @token = nil
    end

    def default_checks
    end

    def response
      default_checks
      return send(@action)
    rescue Etna::BadRequest => e
      return failure(422, e.message)
    rescue Etna::ServerError => e
      return failure(500, e.message)
    end

    def success_json hash = {}
      success('application/json', hash.to_json)
    end

    def view name
      txt = File.read(File.expand_path("../views/#{name}.html", __dir__))
      @response['Content-Type'] = 'text/html'
      @response.write(txt)
      @response.finish
    end

    def erb_view name
      txt = File.read(File.expand_path("../views/#{name}.html.erb", __dir__))
      @response['Content-Type'] = 'text/html'
      @response.write(ERB.new(txt).result)
      @response.finish
    end

    def check_app_key
      raise Etna::BadRequest, "Param not present: app_key" if !@params.key?(:app_key)
      raise Etna::BadRequest, "Invalid app key" if !app_valid?(@params[:app_key])
    end

    # Checks for the user email and password. This is used before a user token is
    # generated.
    def email_password_valid?
      @params.key?(:email) && @params.key?(:pass) && email_valid?(@params[:email])
    end

    # Checks for the user token and makes sure that the user token is valid.
    def token_valid?
      @params.key?(:token) && token && token.valid?
    end

    def token
      @token ||= Janus::Token[token: @params[:token]]
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
