class UserLogController < BasicController

  def run()

    case @action
    when 'log_in_shib'

      return send(@action)
    when 'log_in'

      # Check that the email/pass/app_key is valid.
      check_app_key()
      raise_err(:BAD_REQ, 1, __method__) if !prelog_valid?()
    else

      # Check that a token/app_key is present and valid.
      check_app_key()
      raise_err(:BAD_REQ, 1, __method__) if !postlog_valid?()
      set_token()
    end

    # Execute the path that was requested
    return send(@action).to_json()
  end

  def log_in_shib()

    # Check that this request came from shibboleth(shibd)
    email = @request.env['HTTP_X_SHIB_ATTRIBUTE'].downcase()
    if email == '(null)'

      template = File.read('./server/views/login.html.erb')
      return ERB.new(template).result()
    end

    # Get and check user. No password required.
    user = Models::User[:email=> email]
    if !user 

      template = File.read('./server/views/login_no_user.html.erb')
      return ERB.new(template).result()
    end

    # Create a new token for the user.
    PostgresService::create_new_token!(user)

    # Generate the HTML to return.
    template_vars = OpenStruct.new
    template_vars.token = user.get_token()
    template_vars.query_string = @request.env['QUERY_STRING']
    template = File.read('./server/views/login_shib.html.erb')
    return ERB.new(template).result(template_vars.instance_eval { binding })
  end

  def log_in()

    # Get and check user and then check the password.
    user = Models::User[:email=> @params['email']]
    pass = @params['pass']
    raise_err(:BAD_LOG, 2 , __method__) if !user || !user.authorized?(pass)

    # Create a new token for the user.
    PostgresService::create_new_token!(user)

    # On success return the user info.
    return { :success=> true, :user_info=> user.to_hash() }
  end

  def check_log()

    # Pull the user info for the token.
    user = Models::User[:id=> @token.user_id]
    raise_err(:SERVER_ERR, 0, __method__) if !user
    return { :success=> true, :user_info=> user.to_hash() }
  end

  def log_out()

    # Invalidate the token.
    @token.token_logout_stamp = Time.now
    @token.save_changes()
    return { :success=> true, :logged=> false }
  end
end