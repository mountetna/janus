# controller.rb
# The generic controller that handles validations and common processing tasks.

class Controller

  def initialize(request, action, logger)

    @request = request
    @action = action
    @email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/
  end

  def run()

    send(@action)
  end

  def log_in()

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

  def send_error(type, error_msg, method)

    ref_id = SecureRandom.hex(4)
    @logger.error(ref_id.to_s+' - '+error_msg+', '+method.to_s)
    response = {:success => false, :reference_id => ref_id}

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