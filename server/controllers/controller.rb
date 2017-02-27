# The generic controller that handles validations and common processing tasks.

# Whatever you return from this class, make sure it's a hash that can be turned
# into JSON
class Controller

  def initialize(request, action, logger)

    @request = request
    @params = request.POST()
    @action = action
    @logger = logger
  end

  def run()

    m = __method__

    # Check that an 'app_key' is present and valid
    if !@params.key?('app_key') then return send_err(:BAD_REQ, 0, m) end
    if !app_valid?(@params['app_key']) then return send_err(:BAD_REQ, 1, m) end
    return send(@action)
  end

  def log_in()

    m = __method__

    # Check that the email and password are present.
    if @params.key?('email') && @params.key?('pass')

      # Quick and simple email validataion.
      if !email_valid?(@params['email']) then return send_err(:BAD_LOG,1,m) end

      # Get and check user and then check the password.
      user = Models::User[:email=> @params['email']]
      pass = @params['pass']
      if !user || !user.authorized?(pass) then return send_err(:BAD_LOG,2,m) end

      # Create a new token for the user.
      PostgresService::create_new_token!(user)

      # On success return the user info.
      return { :success=> true, :user_info=> user.to_hash() }
    else

      return send_err(:BAD_REQ, 0, m)
    end
  end

  # Quick check that the email is in a somewhat valid format.
  def email_valid?(eml)

    return (eml !~ Conf::EMAIL_MATCH || eml.to_s.length > 64) ? false : true
  end

  # Check to see if the application key is valid.
  def app_valid?(app_key)

    return (Models::App[:app_key=> app_key]) ? true : false
  end

  def log_out()

  end

  def check_log()

  end

  def send_err(type, id, method)

    ip = @request.env['HTTP_X_FORWARDED_FOR'].to_s
    ref_id = SecureRandom.hex(4).to_s
    response = { :success=> false, :ref=> ref_id }

    case type
    when :SERVER_ERR

      code = Conf::ERRORS[id].to_s
      @logger.error(ref_id+' - '+code+', '+method.to_s+', '+ip)
      response[:error] = 'Server error.'
    when :BAD_REQ

      code = Conf::WARNS[id].to_s
      @logger.warn(ref_id+' - '+code+', '+method.to_s+', '+ip)
      response[:error] = 'Bad request.'
    when :BAD_LOG

      code = Conf::WARNS[id].to_s
      @logger.warn(ref_id+' - '+code+', '+method.to_s+', '+ip)
      response[:error] = 'Invalid login.'
    else

      @logger.error(ref_id+' - UNKNOWN, '+method.to_s+', '+ip)
      response[:error] = 'Unknown error.'
    end

    return response
  end
end