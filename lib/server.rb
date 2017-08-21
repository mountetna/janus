# This class handles the http request and routing
class Janus 
  class Server < Etna::Server
    get '/', 'client#index'

    get '/login', 'user_log#log_in_shib'
    post '/login', 'user_log#log_in'
    post '/logout', 'user_log#log_out'
    post '/check', 'user_log#check_log'

    # Administrative endpoints
    post '/check-admin', 'admin#check_admin'
    post '/check-admin-token', 'admin#check_admin_token'

    post '/get-users', 'admin#get_users'
    post '/get-projects', 'admin#get_projects'
    post '/get-permissions', 'admin#get_permissions'
    post '/get-groups', 'admin#get_groups'
    post '/upload-permissions', 'admin#upload_permissions'
    post '/remove-permissions', 'admin#remove_permissions'

    # Invalidate all tokens in the system.
    # This could cause problems with Metis if there are active uploads.
    post '/logout-all', 'admin#logout_all'

    def initialize(config)
      super
      application.connect(application.config(:db))
      load_models
    end

    private 

    # At this point the postgres db should have it's connection and we can set
    # up the Sequel models.
    def load_models
      require_relative 'server/models'
    end
  end
end
