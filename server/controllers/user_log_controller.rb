# The generic controller that handles validations and common processing tasks.

# Whatever you return from this class, make sure it's a hash that can be turned
# into JSON
class UserLogController < BasicController

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

  def check_log()

    m = __method__

    if @params.key?('token')

      token = Models::Token[:token=> @params['token']]
      if !token || !token.valid?() then return send_err(:BAD_REQ, 3, m) end

      user = Models::User[:id=> token.user_id]
      if !user then return send_err(:SERVER_ERR, 0, m) end

      # On success return the user info.
      return { :success=> true, :user_info=> user.to_hash() }
    else

      return send_err(:BAD_REQ, 0, m)
    end
  end

  def log_out()

    m = __method__

    if @params.key?('token')

      token = Models::Token[:token=> @params['token']]
      if !token || !token.valid?() then return send_err(:BAD_REQ, 3, m) end

      # Invalidate the token
      token.token_logout_stamp = Time.now
      token.save_changes()

      return { :success=> true, :logged=> false }
    else

      return send_err(:BAD_REQ, 0, m)
    end
  end
end