class UserLogController < Janus::Controller
  def response
    case @action
    when 'log_in'
      # Check that the email/pass/app_key is valid.
      check_app_key

      raise Etna::BadRequest, "Invalid login or password" unless email_password_valid?
    else
      # Check that a token/app_key is present and valid.
      check_app_key

      raise Etna::BadRequest, "Invalid token" unless token_valid?
    end

    # Execute the path that was requested
    return send(@action)
  end

  def log_in_shib
    # Check that this request came from shibboleth(shibd)
    email = @request.env['HTTP_X_SHIB_ATTRIBUTE'].downcase
    refer = extract_refer(@request.env['QUERY_STRING'])
    return view(:login) if email == '(null)' || refer.nil?

    # Get and check user. No password required.
    user = Models::User[email: email]
    return erb_view(:login_no_user) unless user 

    # Create a new token for the user.
    user.create_token!

    # Set cookie and redirect.
    @response.redirect(refer, 302)
    @response.set_cookie(
      Conf::TOKEN_NAME,
      value: user.valid_token,
      path: '/',
      domain: Janus.instance.config(:cookie_domain),
      expires: Time.now+Conf::TOKEN_EXP
    )
    return @response.finish
  end

  def log_in
    # Get and check user and then check the password.
    user = Models::User[email: @params[:email]]
    pass = @params[:pass]
    raise Etna::BadRequest, "Invalid login" unless user && user.authorized?(pass)

    # Create a new token for the user.
    user.create_token!

    # On success return the user info.
    return { success: true, user_info: user.to_hash }
  end

  def check_log
    # Pull the user info for the token.
    return { success: true, user_info: token.user.to_hash }
  end

  def log_out
    # Invalidate the token.
    token.invalidate!
    return { success: true, logged: false }
  end

  private
  def extract_refer(query_string='')
    return nil if query_string.empty?

    # split the string on & and =
    query_hash = Hash[URI.unescape(query_string).split('&').map { |i| i.split(/=/) }]

    # Check for 'refer' key
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
