class UserLogController < BasicController

  def run()

    # Check that an 'app_key' is present and valid
    check_app_key()

    # Depending on whether we get token or email/pass combo we perform different
    # checks.
    unless @action == 'log_in'

      # Check that a token is present and valid.
      raise_err(:BAD_REQ, 1, __method__) if !postlog_valid?()
      set_token()
    else

      # Check that the email/pass is valid.
      raise_err(:BAD_REQ, 1, __method__) if !prelog_valid?()
    end

    # Execute the path that was requested
    return send(@action).to_json()
  end

  def log_in()

    m = __method__

    # Get and check user and then check the password.
    user = Models::User[:email=> @params['email']]
    pass = @params['pass']
    raise_err(:BAD_LOG,2,m) if !user || !user.authorized?(pass)

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