class AdminController < BasicController

  def run()

    # Check that an 'app_key' is present and valid
    check_app_key()

    # Depending on whether we get token or email/pass combo we perform different
    # checks.
    unless @action == 'check_admin'

      # Check if a token is present and valid.
      if !postlog_valid?() then raise_err(:BAD_REQ, 1, __method__) end
      set_token()

      # Get and check user and then check the token.
      user = Models::User[:id=> @token.user_id]
      if !user || !user.admin?() then raise_err(:BAD_REQ, 2, __method__) end
    else

      # Check that the email/pass is valid.
      if !prelog_valid?() then raise_err(:BAD_REQ, 1, __method__) end

      # Get and check user and then check the password.
      user = Models::User[:email=> @params['email']]
      if !user || !user.authorized?(@params['pass']) || !user.admin?()

        raise_err(:BAD_REQ, 2, __method__) 
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

    set_unset_perms(){|perm| save_perm(perm)}
  end

  def remove_permissions()

    set_unset_perms(){|perm| del_perm(perm)}
  end

  private
  def set_unset_perms()

    if !@params.key?('permissions') then raise_err(:BAD_REQ, 0, __method__) end
    perms = parse_permissions(@params['permissions'])
    if !perms then raise_err(:BAD_REQ, 0, __method__) end

    perms = perms.map { |perm| if yield(perm) then perm else nil end }
    { :success=> true, :permissions=> perms }
  end

  def parse_permissions(perms)

    begin

      return JSON.parse(URI.unescape(perms))
    rescue JSON::ParserError=> error

      return nil
    end
  end

  def save_perm(perm)

    # Check if the user and project are existant.
    user = Models::User[:id=> perm['user_id']]
    pjkt = Models::Project[:id=> perm['project_id']]
    if !user || !pjkt then return false end

    # Check if there is currently a permission with the user and project.
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

  def del_perm(perm)

    # Check if the user and project are existant.
    user = Models::User[:id=> perm['user_id']]
    pjkt = Models::Project[:id=> perm['project_id']]
    if !user || !pjkt then return false end

    # Check if this is the master system permission.
    if master_perm?(perm) then return false end

    # Check if there is currently a permission with the user and project.
    permission = Models::Permission[:user_id=>user[:id],:project_id=>pjkt[:id]]
    if !permission then return false end

    permission.delete

    return true
  end

  def master_perm?(perm)

    (perm['user_id'] == 1 && perm['project_id'] == 1) ? true : false
  end
end