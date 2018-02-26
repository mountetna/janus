# This class handles the http request and routing
require_relative './server/controllers/janus_controller'
require_relative './server/controllers/admin_controller'
require_relative './server/controllers/authorization_controller'
class Janus 
  class Server < Etna::Server

    # Only one of these two end points gets used. If you are using Shibboleth
    # then enable the appropriate end point.
    get '/login', action: 'authorization#login'
    #get '/login', action: 'authorization#login_shib'

    post '/validate-login', action: 'authorization#validate_login'
    post '/logout', action: 'authorization#log_out'
    post '/check', action: 'authorization#check_log'

    # This generates nonces
    get '/time-signature', action: 'authorization#time_signature'
    # This uses a signed nonce to generate a new token
    get '/generate', action: 'authorization#generate'

    # Administrative endpoints.
    post '/check-admin', action: 'admin#check_admin'
    post '/check-admin-token', action: 'admin#check_admin_token'

    post '/get-users', action: 'admin#get_users'
    post '/get-projects', action: 'admin#get_projects'
    post '/get-permissions', action: 'admin#get_permissions'
    post '/get-groups', action: 'admin#get_groups'
    post '/upload-permissions', action: 'admin#upload_permissions'
    post '/remove-permissions', action: 'admin#remove_permissions'

    # Invalidate all tokens in the system.
    # This could cause problems with Metis if there are active uploads.
    post '/logout-all', action: 'admin#logout_all'

    def initialize(config)
      super
      application.setup_db
    end
  end
end
