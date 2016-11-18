# controller.rb
# The generic controller that handles validations and common processing tasks.

class Controller

  def initialize(psql_service, request, action)

    @psql_service = psql_service
    @request = request
    @action = action
    @email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/
  end

  def run()  

    send(@action)
  end
  
  def log_in()

    # Get the params out of the POST
    params = @request.POST()

    # Check for the correct parameters.
    if params.key?('email') && params.key?('pass') && params.key?('app_key')

      # Check to see if the client is registered with an app.
      if !@psql_service.app_valid?(params['app_key'])

        return send_bad_request()
      end

      # Quick check that the email is in a somewhat valid format.
      if params['email'] !~ @email_regex || params['email'].to_s.length > 64

        return send_bad_login()
      end

      # Check that the user and a valid pass is set.
      if !@psql_service.check_pass_exsists(params['email'], params['pass'])

        return send_bad_login()
      end

      # Verify the password.
      if !check_pass(params['email'], params['pass'])

        return send_bad_login()
      end

      # Get or generate a valid token.
      token = @psql_service.get_token(params['email'])
      if token == 0 
 
        token = generate_token(params['email'])
        if token == 0
 
          return send_server_error()
        end
 
        @psql_service.set_token(params['email'], token)
      end

      # Get the user information.
      user_info = @psql_service.get_user_info(params['email'])
      if user_info == 0

        return send_server_error()
      end

      user_info['auth_token'] = token
      Rack::Response.new({ success: true, user_info: user_info }.to_json())
    else

      return send_bad_request()
    end    
  end

  def log_out()

    # Get the params out of the POST
    params = @request.POST()

    # Check for the correct parameters.
    if params.key?('email') && params.key?('token') && params.key?('app_key')

      # Check to see if the client is registered with an app.
      if !@psql_service.app_valid?(params['app_key'])

        return send_bad_request()
      end

      # Check the validity of the token
      token = @psql_service.check_log(params['token'])

      # If the token is valid and the email matches the user that owns the token
      # then invalidate any token for that user.
      if token != 0 && token[:email] == params['email']

        @psql_service.invalidate_token(params['email'])
      end

      return Rack::Response.new({ success: true, logged: false }.to_json())
    else

      return send_bad_request()
    end
  end

  def check_log()

    # Get the params out of the POST
    params = @request.POST()

    # Check for the correct parameters.
    if params.key?('token') && params.key?('app_key')

      # Check to see if the client is registered with an app.
      if !@psql_service.app_valid?(params['app_key'])

        return send_bad_request()
      end

      user_info = @psql_service.check_log(params['token'])

      if user_info == 0

        repsonse = { 

          success: true, 
          message: 'Invalid token.',
          logged: false
        }
      else

        user_info['auth_token'] = params['token']
        repsonse = { 

          success: true, 
          user_info: user_info,
          logged: true
        }
      end

      Rack::Response.new(repsonse.to_json())
    else

      return send_bad_request()
    end
  end

  def generate_token(email)
  
    pass_hash = @psql_service.get_pass_hash(email)
    if pass_hash == 0
  
      return 0
    end
  
    time = Time.now.getutc.to_s
    params = [time, pass_hash, Conf::TOKEN_SALT]
    return SignService::hash_password(params, Conf::TOKEN_ALGO)
  end

  def check_pass(email, pass)

    db_pass_hash = @psql_service.get_pass_hash(email)
    if db_pass_hash == 0

      return false
    end

    ordered_params = SignService::order_params(pass)
    pass_hash = SignService::hash_password(ordered_params, Conf::PASS_ALGO)

    if db_pass_hash == pass_hash

      return true
    else

      return false
    end
  end

  def send_bad_login()

    Rack::Response.new({ success: false, error: 'Invalid login.' }.to_json())
  end

  def send_bad_request()

    Rack::Response.new({ success: false, error: 'Bad request.' }.to_json())
  end

  def send_server_error()

    error_message = 'There was a server error.'
    Rack::Response.new({ success: false, error: error_message }.to_json())
  end
end