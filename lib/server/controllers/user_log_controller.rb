class UserLogController < Janus::Controller
  def log_in_shib
    # Check that this request came from shibboleth(shibd).
    email = @request.env['HTTP_X_SHIB_ATTRIBUTE'].downcase
    refer = extract_refer(@request.env['QUERY_STRING'])
    return view(:login) if email == '(null)' || refer.nil?

    # Get and check user. No password required.
    user = Janus::User[email: email]
    return view(:login_no_user) unless user 

    # Create a new token for the user.
    user.create_token!

    respond_with_cookie(refer)
  end

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

  def login
    @refer = @params[:refer]
    erb_view(:login_form)
  end

  def validate_login
    raise Etna::BadRequest, 'Invalid login or password' unless email_password_valid?
    # Get and check user and then check the password.
    user = Janus::User[email: @params[:email]]
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
    uri = URI.parse(refer)
    return (Conf::VALID_HOSTS.include?(uri.host)) ? true : false
  end
end
