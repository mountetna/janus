class BasicController

  def initialize(request, action)

    @request = request
    @params = request.POST()
    @action = action

    @token = nil
  end

  def check_app_key()

    raise_err(:BAD_REQ, 0, __method__) if !@params.key?('app_key')
    raise_err(:BAD_REQ, 1, __method__) if !app_valid?(@params['app_key'])
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

  # Proxy the exception.
  def raise_err(type, id, method)

    raise BasicError.new(type, id, method)
  end
end