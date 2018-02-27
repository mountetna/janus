require_relative '../nonce'

class AuthorizationController < Janus::Controller
  def login_shib
    # Make sure the refer url is valid.
    refer = extract_refer(@request.env['QUERY_STRING'])
    if refer.nil? || !refer_valid?(refer)
      raise Etna::BadRequest, 'Invalid url refer'
    end

    # Check that this request came from shibboleth(shibd).
    email = @request.env['HTTP_X_SHIB_ATTRIBUTE'].downcase
    raise Etna::BadRequest, 'Invalid email' if email == '(null)'

    # Get and check user. No password required.
    user = User[email: email]
    raise Etna::BadRequest, 'Invalid user' unless user 

    # Create a new token for the user.
    user.create_token!

    respond_with_cookie(user, refer)
  end

  def login
    @refer = @params[:refer]

    # Check if the token is set. If not then show the login dialog.
    @params[:token] = @request.cookies[Janus.instance.config(:token_name)]

    # Check if the token is valid. If not then show the login dialog.
    return erb_view(:login_form) unless token_valid?

    # Make sure the refer url is valid.
    unless refer_valid?(@params[:refer])
      raise Etna::BadRequest, 'Invalid url refer' 
    end

    # The token is valid and the refer is ok, so go ahead and redirect the user.
    @response.redirect(@params[:refer], 302)

    @response.finish
  end

  def validate_login
    unless email_password_valid?
      raise Etna::BadRequest, 'Invalid email or password' 
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
    user.create_token!

    # On success return the user info.
    respond_with_cookie(user, @params[:refer])
  end

  def check_log
    raise Etna::BadRequest, 'Invalid app key' unless app_key_valid?
    raise Etna::BadRequest, 'Invalid token' unless token_valid?

    # Pull the user info for the token.
    success_json(token.user.to_hash)
  end

  def log_out
    # Invalidate the token.
    token.invalidate!
    success_json(success: true, logged: false)
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

    return failure(401, 'Validation token was not presented.') unless auth_token

    timesig64, email64, signature64 = auth_token.split(/\./)

    noauth = 'You are unauthorized'

    # validate the timesig
    return failure(401, noauth) unless Janus::Nonce.valid?(timesig64)

    # validate the email
    email = Base64.decode64(email64)
    return failure(401, noauth) if email =~ /[^[:print:]]/

    # find the user
    user = User[email: email]
    return failure(401, noauth) unless user

    # check the user's signature
    unless user.valid_signature?("#{timesig64}.#{email64}", Base64.decode64(signature64))
      return failure(401, noauth) 
    end

    user.create_token!

    return success(user.valid_token.token)
  end

  private

  def respond_with_cookie(user, refer)
    # Set cookie and redirect.
    @response.redirect(refer, 302)
    @response.set_cookie(
      Janus.instance.config(:token_name),
      value: user.valid_token.token,
      path: '/',
      domain: Janus.instance.config(:token_domain),
      expires: user.valid_token.token_expire_stamp
    )

    return @response.finish
  end

  def extract_refer(query_string='')
    return nil if query_string.empty?

    # Split the string on '&' and '='.
    query_hash = Hash[
      URI.unescape(query_string).split('&').map { |i| i.split(/=/) }
    ]

    # Check for 'refer' key.
    return nil unless query_hash.key?('refer')

    # Check that the refer url is valid and in our Mt. Etna network.
    return nil unless refer_valid?(query_hash['refer'])

    return query_hash['refer']
  end

  def refer_valid?(refer)

    # Attempt to parse the refer.
    begin
      uri = URI.parse(refer)
      host = uri.host.split('.')[-2,2].join('.') # Extract the root host.
    rescue
      return false
    end

    # Check to make sure the refer comes from the same domain as the token.
    return host == Janus.instance.config(:token_domain) ? true : false
  end
end
