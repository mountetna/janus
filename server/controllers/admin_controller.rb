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

  def send_bad_request()

    Rack::Response.new({ :success=> false, :error=> 'Bad request.' }.to_json())
  end

  def send_server_error()

    error_message = 'There was a server error.'
    Rack::Response.new({ :success=> false, :error=> error_message }.to_json())
  end
end