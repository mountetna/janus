class AdminController < Janus::Controller
  def response
    # Check that an 'app_key' is present and valid
    check_app_key

    # Depending on whether we get token or email/pass combo we perform
    # different checks.
    unless @action == 'check_admin'
      # Check if a token is present and valid.
      raise Etna::BadRequest, "Invalid token" unless token_valid?

      # Get and check user and then check the token.
      raise Etna::BadRequest, "User is not an admin" unless token.user && token.user.admin?
    else
      # Check that the email/pass is valid.
      raise Etna::BadRequest, "Invalid login or password." unless email_password_valid?

      # Get and check user and then check the password.
      user = Janus::User[email: @params[:email]]
      raise Etna::BadRequest, "User is not an admin" unless user && user.admin? && user.authorized?(@params[:pass])
    end

    # Execute the path that was requested
    send(@action)
  end

# email/pass checks
  def check_admin()
    { success: true, administrator: true }
  end

# token checks
  def check_admin_token()
    { success: true, administrator: true }
  end

  def get_users()
    { success: true, users: Janus::User.all.map(&:to_hash) }
  end

  def get_projects()
    { success: true, projects: Janus::Project.all.map(&:to_hash) }
  end

  def get_groups()
    { success: true, groups: Janus::Group.all }
  end

  def get_permissions()
    { success: true, permissions: Janus::Permission.all.map(&:to_hash) }
  end

  def upload_permissions()
    raise Etna::BadRequest, "No param: permissions" unless @params.key?(:permissions)

    saved = @params[:permissions].select do |perm|
      user = Janus::User[email: perm['user_email']]
      project = Janus::Project[project_name: perm['project_name']]

      next if !user || !project
      Janus::Permission.find_or_create(user: user, project: project) do |perm|
        perm.role = perm['role']
      end
    end

    { success: true, permissions: saved }
  end

  def remove_permissions()
    raise Etna::BadRequest, "No param: permissions" unless @params.key?(:permissions)

    deleted = @params[:permissions].select do |perm|
      # Check if the user and project are existant.
      user = Models::User[email: perm['user_email']]
      project = Models::Project[project_name: perm['project_name']]

      next if !user || !project

      # Check if this is the master system permission.
      next if project.project_name == "Administration"

      # Check if there is currently a permission with the user and project.
      Janus::Permission.where(user_id: user.id, project_id: project.id).delete
    end

    { success: true, permissions: deleted }
  end

  def logout_all
    { success: true, logout_count: Janus::Token.expire_all! }
  end
end
