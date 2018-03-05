class AdminController < Janus::Controller
  def check_admin_token
    validate_admin_status
    success_json(success: true, administrator: true)
  end

  def get_users
    validate_admin_status
    success_json(success: true, users: User.all.map(&:to_hash))
  end

  def get_projects
    validate_admin_status
    success_json(success: true, projects: Project.all.map(&:to_hash))
  end

  def get_groups
    validate_admin_status
    success_json(success: true, groups: Group.all)
  end

  def get_permissions
    validate_admin_status
    success_json(success: true, permissions: Permission.all.map(&:to_hash))
  end

  def upload_permissions
    validate_admin_status

    raise Etna::BadRequest, 'No param: permissions' unless @params.key?(:permissions)

    saved = @params[:permissions].select do |perm|
      user = User[email: perm['user_email']]
      project = Project[project_name: perm['project_name']]

      next if !user || !project
      Permission.find_or_create(user: user, project: project) do |perm|
        perm.role = perm['role']
      end
    end

    success_json(success: true, permissions: saved)
  end

  def remove_permissions
    validate_admin_status

    raise Etna::BadRequest, 'No param: permissions' unless @params.key?(:permissions)

    deleted = @params[:permissions].select do |perm|
      # Check if the user and project are existant.
      user = User[email: perm['user_email']]
      project = Project[project_name: perm['project_name']]

      next if !user || !project

      # Check if this is the master system permission.
      next if project.project_name == 'Administration'

      # Check if there is currently a permission with the user and project.
      Permission.where(user_id: user.id, project_id: project.id).delete
    end

    success_json(success: true, permissions: deleted)
  end

  def logout_all
    validate_admin_status
    success_json(success: true, logout_count: Token.expire_all!)
  end

  private

  def validate_admin_status
    app = App[app_key: @params[:app_key]]

    # Check that an 'app_key' is present and valid.
    raise Etna::BadRequest, 'Invalid app key' unless app

    # Check if a token is present and valid.
    token = Token[token: @params[:token]]

    raise Etna::BadRequest, 'Invalid token' unless token && token.valid?

    # Get and check user and then check the token.
    raise Etna::BadRequest, 'User is not an admin' unless token.user && token.user.admin?
  end
end
