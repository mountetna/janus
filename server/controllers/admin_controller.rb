class AdminController < BasicController

  def check_admin()

    m = __method__

    # Check that the email and password are present.
    if @params.key?('email') && @params.key?('pass')

      # Quick and simple email validataion.
      if !email_valid?(@params['email']) then return send_err(:BAD_LOG,1,m) end

      # Get and check user and then check the password.
      user = Models::User[:email=> @params['email']]
      if user && user.authorized?(@params['pass']) && user.administrator?()

        return { :success=> true, :administrator=> true }
      else

        send_err(:BAD_REQ, 2, m) 
      end
    else

      return send_err(:BAD_REQ, 0, m)
    end
  end

  def check_admin_token()

    m = __method__
    if @params.key?('token')

      token = Models::Token[:token=> @params['token']]
      if !token || !token.valid?() then return send_err(:BAD_REQ, 3, m) end

      # Get and check user and then check the password.
      user = Models::User[:id=> token.user_id]
      if user && user.administrator?()

        return { :success=> true, :administrator=> true }
      else

        send_err(:BAD_REQ, 2, m) 
      end
    else

      return send_err(:BAD_REQ, 0, m)
    end
  end
end