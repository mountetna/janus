class AdminController < BasicController

  def run()

    m = __method__

    # Check that an 'app_key' is present and valid
    if !@params.key?('app_key') then return send_err(:BAD_REQ, 0, m) end
    if !app_valid?(@params['app_key']) then return send_err(:BAD_REQ, 1, m) end

    # Depending on whether we get token or email/pass combo we perform different
    # checks.
    unless @action == 'check_admin'

      # Check if a token is present and valid.
      if !postlog_valid?() then return send_err(:BAD_REQ, 1, m) end
      set_token()

      # Get and check user and then check the token.
      user = Models::User[:id=> @token.user_id]
      if !user || !user.administrator?()

        return send_err(:BAD_REQ, 2, m)
      end
    else

      # Check that the email/pass is valid.
      if !prelog_valid?() then return send_err(:BAD_REQ, 1, m) end

      # Get and check user and then check the password.
      user = Models::User[:email=> @params['email']]
      if !user || !user.authorized?(@params['pass']) || !user.administrator?()

        return send_err(:BAD_REQ, 2, m) 
      end
    end

    # Execute the path that was requested
    return send(@action).to_json()
  end

# email/pass checks
  def check_admin()

    { :success=> true, :administrator=> true }
  end

# token checks
  def check_admin_token()

    { :success=> true, :administrator=> true }
  end

  def get_users()

    { :success=> true, :users=> PostgresService::fetch_all_users() }
  end

  def get_projects()

    { :success=> true, :projects=> PostgresService::fetch_all_projects() }
  end

  def get_groups()

    { :success=> true, :groups=> PostgresService::fetch_all_groups() }
  end

  def get_permissions()

    { :success=> true, :permissions=> PostgresService::fetch_all_permissions() }
  end

  def upload_permissions()

    m = __method__
    if !@params.key?('permissions') then return send_err(:BAD_REQ, 0, m) end

    # Catch if the permissions are malformed
    begin

      perms = JSON.parse(URI.unescape(@params['permissions']))

      # If a perm save is successful then return it, if not, return nil.
      perms = perms.map{|perm| if save_permission(perm) then perm else nil end }
      return { :success=> true, :permissions=> perms }
    rescue JSON::ParserError=> error

      send_err(:BAD_REQ, 1, m)
    end
  end

  def save_permission(perm)

    # 1. Check if the user and project are existant.
    user = Models::User[:id=> perm['user_id']]
    pjkt = Models::Project[:id=> perm['project_id']]
    if !user || !pjkt then return false end

    # 2. Check if there is currently a permission with the user and project.
    permission = Models::Permission[:user_id=>user[:id],:project_id=>pjkt[:id]]
    if permission

      # Update permission
      permission.update(:role=> perm['role'])
    else

      # Create new permission
      PostgresService::create_new_permission(perm)
    end

    return true
  end
end