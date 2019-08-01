require_relative '../nonce'

class AuthorizationController < Janus::Controller
  def login
    # Make sure the refer url is valid.
    unless refer_valid?(@params[:refer])
      raise Etna::BadRequest, 'Invalid url refer'
    end

    token = @request.cookies[Janus.instance.config(:token_name)]

    begin
      payload, header = Janus.instance.sign.jwt_decode(token)

      payload = payload.symbolize_keys.except(:exp)

      user = User[email: payload[:email]]

      raise 'Invalid payload!' if !user || payload != user.jwt_payload

      # they have a valid token
      @response.redirect(@params[:refer], 302)
      @response.finish
    rescue
      if Janus.instance.config(:auth_method) == 'shibboleth'
        return login_shib
      else
        return login_form
      end
    end
  end

  def validate_login
    require_params(:email, :password)

    unless email_valid?(@params[:email])
     raise Etna::BadRequest, 'Invalid email'
    end

    # Make sure the refer url is valid.
    unless refer_valid?(@params[:refer])
      raise Etna::BadRequest, 'Invalid url refer'
    end

    # Get and check user and then check the password.
    user = User[email: @params[:email]]

    unless user && user.authorized?(@params[:password])
      raise Etna::BadRequest, 'Invalid login'
    end

    # Create a new token for the user.
    token = user.create_token!

    # On success return the user info.
    respond_with_cookie(token, @params[:refer])
  end

  # generates a nonce for users to sign
  def time_signature
    # The message is the current moment in ISO
    # format
    return success(
      Janus::Nonce.new(DateTime.now.iso8601).to_s
    )
  end

  def generate
    # The user must authorize the request with
    # their signature

    auth_token = (@request.env['HTTP_AUTHORIZATION'] || '')[ /\ASigned-Nonce (.*)\z/, 1 ]

    return noauth unless auth_token

    timesig64, email64, signature64 = auth_token.split(/\./)

    # validate the timesig
    return noauth unless Janus::Nonce.valid?(timesig64)

    # validate the email
    email = Base64.decode64(email64)
    return noauth if email =~ /[^[:print:]]/

    # find the user
    user = User[email: email]
    return noauth unless user

    # check the user's signature
    unless user.valid_signature?("#{timesig64}.#{email64}", Base64.decode64(signature64))
      return noauth
    end

    return success(user.create_token!)
  end

  private

  def noauth
    failure(401, 'You are unauthorized')
  end

  def login_shib
    # Check that this request came from shibboleth(shibd).
    email = (@request.env['HTTP_X_SHIB_ATTRIBUTE'] || '').downcase
    raise Etna::Unauthorized if email == '(null)' || email.empty?

    # Get and check user. No password required.
    user = User[email: email]
    raise Etna::Unauthorized unless user

    # Create a new token for the user.
    token = user.create_token!

    respond_with_cookie(token, @params[:refer])
  end

  def login_form
    erb_view(:login_form)
  end

  def respond_with_cookie(token, refer)
    # Set redirect.
    @response.redirect(refer, 302)

    # Tear apart token to get expire time
    expire_time = Time.at(
      JSON.parse(
        Base64.decode64(
          token.split('.')[1]
        )
      )["exp"]
    )

    # Set cookie
    @response.set_cookie(
      Janus.instance.config(:token_name),
      value: token,
      path: '/',
      domain: Janus.instance.config(:token_domain),
      expires: expire_time
    )

    return @response.finish
  end

  def refer_valid?(refer)
    # Attempt to parse the refer.
    uri = URI.parse(refer)
    host = uri.host.split('.')[-2,2].join('.') # Extract the root host.

    # Check to make sure the refer comes from the same domain as the token.
    host == Janus.instance.config(:token_domain) ? true : false
  rescue
    return false
  end
end
