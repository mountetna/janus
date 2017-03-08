class BasicController

  def initialize(request, action, logger)

    @request = request
    @params = request.POST()
    @action = action
    @logger = logger

    @token = nil
  end

  # Checks for the user email and password. This is used before a user token is
  # generated.
  def prelog_valid?()

    if !@params.key?('email') || !@params.key?('pass') then return false end
    if !email_valid?(@params['email']) then return false end
    return true
  end

  # Checks for the user token and makes sure that the user token is valid.
  def postlog_valid?()

    if !@params.key?('token') then return false end
    token = Models::Token[:token=> @params['token']]
    if !token || !token.valid?() then return false end
    return true
  end

  def set_token()

    @token = Models::Token[:token=> @params['token']]
  end

  # Quick check that the email is in a somewhat valid format.
  def email_valid?(eml)

    return (eml !~ Conf::EMAIL_MATCH || eml.to_s.length > 64) ? false : true
  end

  # Check to see if the application key is valid.
  def app_valid?(app_key)

    return (Models::App[:app_key=> app_key]) ? true : false
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

    return response.to_json()
  end
end