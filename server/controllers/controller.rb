# controller.rb
# The generic controller that handles validations and common processing tasks.

class Controller

  def initialize(psql_service, request, action)

    @psql_service = psql_service
    @request = request
    @action = action
  end

  def run()  

    send(@action)
  end

  def start_log()

    # get the params out of the POST
    params = @request.POST()

    if params.key?('email') && params.key?('pass')

      if !@psql_service.check_pass_exsists(params['email'], params['pass'])

        return send_bad_login()
      end

      if !check_pass(params['email'], params['pass'])

        return send_bad_login()
      end

      token = @psql_service.get_token(params['email'])
      if token == 0 

        token = generate_token(params['email'])
        @psql_service.set_token(params['email'], token)
      end

      Rack::Response.new({ success: true, session_token: token }.to_json())
    else

      return send_bad_request()
    end    
  end

  def generate_token(email)

    pass_hash = @psql_service.get_pass_hash(email)
    time = Time.now.getutc.to_s
    params = [time, pass_hash, Conf::TOKEN_SALT]
    SignService::hash_password(params, Conf::TOKEN_ALGO)
  end

  def check_pass(email, pass)

    db_pass_hash = @psql_service.get_pass_hash(email)

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
end