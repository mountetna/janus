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
    return Rack::Response.new(send(@action).to_json())
  end

  def log_in_shib()

    # Check that this request came from shibboleth(shibd)
    email = @request.env['HTTP_X_SHIB_ATTRIBUTE'].downcase()
    refer = extract_refer(@request.env['QUERY_STRING'])
    if email == '(null)' || refer == ''

      template = File.read('./server/views/login.html')
      return Rack::Response.new(ERB.new(template).result())
    end

    # Get and check user. No password required.
    user = Models::User[:email=> email]
    if !user 

      template = File.read('./server/views/login_no_user.html.erb')
      return Rack::Response.new(ERB.new(template).result())
    end

    # Create a new token for the user.
    PostgresService::create_new_token!(user)

    # Set cookie and redirect.
    response = Rack::Response.new
    response.redirect(refer, 302)
    response.set_cookie(Conf::TOKEN_NAME, {:value => user.get_token(), :path => '/', :domain=> 'ucsf.edu', :expires => Time.now+Conf::TOKEN_EXP})

    return response.finish
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

  private
  def extract_refer(query_string)

    if query_string == '' then return '' end
    query_string = URI.unescape(query_string)
    query_array = query_string.split('&')
    query_hash = {}
    query_array.each do |query|

      query = query.split('=')
      query_hash[query[0]] = query[1]
    end

    # Check for that 'refer' key
    unless query_hash.key?('refer') then return '' end

    # Check that the refer url is valid and in our Mt. Etna network.
    unless refer_valid?(query_hash['refer']) then return '' end

    return query_hash['refer']
  end

  def refer_valid?(refer)

    uri = URI.parse(refer)
    return (Conf::VALID_HOSTS.include?(uri.host)) ? true : false
  end
end