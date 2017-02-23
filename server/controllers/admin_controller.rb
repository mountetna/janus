# admin_controller.rb

class AdminController

  def initialize(psql_service, request, action)

    @psql_service = psql_service
    @request = request
    @action = action
    @params = nil
    @user_info = nil
  end

  def run()

    # Get the params out of the POST
    @params = @request.POST()

    # Check for the correct parameters.
    if !@params.key?('token') || !@params.key?('app_key')

      return send_bad_request()
    end

    # Check to see if the client is registered with an app.
    if !@psql_service.app_valid?(@params['app_key'])

      return send_bad_request()
    end

    # Check if the user token is valid.
    @user_info = @psql_service.check_log(@params['token'])
    
    if @user_info == 0

      return send_bad_request()
    end

    # Check for the master permission.
    if !has_master_perms?()

      return send_bad_request()
    end

    send(@action)
  end

    # Check to see if the user is part of the administration project
  def has_master_perms?()

    masterPerms = false
    @user_info[:permissions].each do |permission|

      if permission[:project_name] == 'administration'

        if permission[:project_id] == 1

          if permission[:role] == 'administrator'

            masterPerms = true
          end
        end
      end
    end
    return masterPerms
  end

  def get_users()

    users = @psql_service.fetch_all_users()
    if users == 0

      return send_server_error()
    end

    return Rack::Response.new({ :success=> true, :users=> users }.to_json())
  end

  def get_projects()

    projects = @psql_service.fetch_all_projects()
    if projects == 0
      
      return send_server_error()
    end

    return Rack::Response.new({ :success=> true, :projects=> projects }.to_json())
  end

  def get_permissions()

    permissions = @psql_service.fetch_all_permissions()
    if permissions == 0

      return send_server_error()
    end

    users = @psql_service.fetch_all_users()
    if users == 0

      return send_server_error()
    end

    # Map ids to emails
    permissions.each do |permission|

      users.each do |user|

        if permission[:user_id] == user[:id]

          permission[:userEmail] = user[:email]
        end 
      end
    end

    projects = @psql_service.fetch_all_projects()
    if projects == 0
      
      return send_server_error()
    end

    # Map ids to project names
    permissions.each do |permission|

      projects.each do |project|

        if permission[:project_id] == project[:id]

          permission[:project_name] = project[:project_name]
        end
      end
    end

    return Rack::Response.new({ :success=> true, :permissions=> permissions }.to_json())
  end

  def upload_permissions()

    if !@params.key?('permissions')

      return send_bad_request()
    end

    begin

      permissions = JSON.parse(URI.unescape(@params['permissions']))

      a = 0
      permissions.each do |permission|

        if(permission_valid?(permission))

          permissions[a] = save_permission(permission)
        else

          permissions[a] = {}
        end
        a += 1
      end

      repsonse = { :success=> true, :permissions=> permissions }
      return Rack::Response.new(repsonse.to_json())
    rescue JSON::ParserError=> error

      # log error.message
      return send_bad_request()
    end
  end

  def permission_valid?(permission)

    valid = true

    if !permission.key?('id')           then valid = false end
    if !permission.key?('project_id')   then valid = false end
    if !permission.key?('project_name') then valid = false end
    if !permission.key?('role')         then valid = false end
    if !permission.key?('user_email')   then valid = false end
    if !permission.key?('user_id')      then valid = false end

    return valid
  end

  def save_permission(permission)

    # 1. Check if the user and project are existant and singular.
    project_id = @psql_service.get_project_id(permission['project_name'])
    if project_id <= 0

      return {}
    end

    user_id = @psql_service.get_user_id(permission['user_email'])
    if user_id <= 0

      return {}
    end

    # 2. Check if there is currently a permission with the user and project.
    perm_id = @psql_service.check_permission(user_id, project_id)
    if perm_id == 0

      permission['user_id'] = user_id
      permission['project_id'] = project_id
      return @psql_service.create_new_permission(permission)
    elsif perm_id <= -1

      return {}
    else

      return @psql_service.update_permission(permission)
    end
  end

  def get_groups()

    groups = @psql_service.fetch_all_groups()
    if groups == 0

      return send_server_error()
    else

      response = { 

        :success=> true,
        :groups=> groups
      }

      Rack::Response.new(response.to_json())
    end
  end

  def send_bad_request()

    Rack::Response.new({ :success=> false, :error=> 'Bad request.' }.to_json())
  end

  def send_server_error()

    error_message = 'There was a server error.'
    Rack::Response.new({ :success=> false, :error=> error_message }.to_json())
  end
end