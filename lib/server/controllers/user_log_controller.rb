class UserLogController < Janus::Controller
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
    @params[:token] = pull_token_from_cookie
    return erb_view(:login_form) if !token

    # Check if the token is valid. If not then show the login dialog.
    return erb_view(:login_form) if !token_valid?

    # Make sure the refer url is valid.
    unless refer_valid?(@params[:refer])
      raise Etna::BadRequest, 'Invalid url refer' 
    end

    # The token is valid and the refer is ok, so go ahead and redirect the user.
    respond_with_cookie(token.user, @refer)
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

  private

  def respond_with_cookie(user, refer)
    # Set cookie and redirect.
    @response.redirect(refer, 302)
    @response.set_cookie(
      Janus.instance.config(:token_name),
      value: user.valid_token.token,
      path: '/',
      domain: Janus.instance.config(:token_domain),
      expires: Time.now+Janus.instance.config(:token_life)
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

  # Check to see if there is a Janus cookie set, and if it is valid.
  def pull_token_from_cookie
    tkn = nil
    return tkn unless @request.env['HTTP_COOKIE']

    cookies = @request.env['HTTP_COOKIE'].split(';')
    cookies.each do |cookie|
      if cookie.include?(Janus.instance.config(:token_name))
        tkn = cookie.split('=')[1]
        break
      end
    end

    return tkn
  end
end
