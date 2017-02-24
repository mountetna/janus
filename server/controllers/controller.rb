# controller.rb
# The generic controller that handles validations and common processing tasks.

class Controller

  def initialize(request, action, logger)

    @params = request.POST()
    @action = action
    @logger = logger
    @email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/
  end

  def run()

    msg = :PARAMS_NOT_PRESENT
    @params.key?('app_key')?send(@action):send_err(:bad_request,msg,__method__)
  end

  def log_in()

    if @params.key?('email') && @params.key?('pass')

      Rack::Response.new({ :success=> true, :msg=> 'sup' }.to_json())
    else

      msg = :PARAMS_NOT_PRESENT
      send_err(:bad_request, msg, __method__)
    end
  end

  def log_out()

  end

  def check_log()

  end

  def generate_token(email)

  end

  def check_pass(email, pass)

  end

  def send_bad_login()

  end

  def send_err(type, error_msg, method)

    ref_id = SecureRandom.hex(4)
    @logger.error(ref_id.to_s+' - '+error_msg.to_s+', '+method.to_s)
    response = {:success=> false, :ref=> ref_id}

    case type
    when :bad_request
      response[:error] = 'Bad request.'
    when :server_error 
      response[:error] = 'There was a server error.'
    else
      response[:error] = 'Unknown error.'
    end

    Rack::Response.new(response.to_json())
  end
end