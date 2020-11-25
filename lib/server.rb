# This class handles the http request and routing
require_relative './server/controllers/janus_controller'
require_relative './server/controllers/admin_controller'
require_relative './server/controllers/user_controller'
require_relative './server/controllers/authorization_controller'

class Janus
  class Server < Etna::Server

    # Only one of these two end points gets used. If you are using Shibboleth
    # then enable the appropriate end point.
    get '/login', action: 'authorization#login', auth: { noauth: true }

    post '/validate-login', action: 'authorization#validate_login', auth: { noauth: true }

    # This generates nonces
    get '/time-signature', action: 'authorization#time_signature', auth: { noauth: true }

    # This uses a signed nonce to generate a new token
    get '/generate', action: 'authorization#generate', auth: { noauth: true }

    get '/', action: 'admin#main'

    get '/project/:project_name', action: 'admin#project', auth: { user: { can_edit?: :project_name } }

    get '/projects', action: 'user#projects', auth: { user: { active?: true } }

    get '/refresh_token', action: 'user#refresh_token', auth: { user: { active?: true } }

    # Once we figure out a long-term token strategy, this should probably get
    #   consolidated with /refresh_token so we don't just keep creating
    #   small token-related views.
    get '/viewer_token', action: 'user#viewer_token', auth: { user: { is_superuser?: true } }

    post '/update_permission/:project_name', action: 'admin#update_permission', auth: { user: { is_admin?: :project_name } }

    post '/add_user/:project_name', action: 'admin#add_user', auth: { user: { is_admin?: :project_name } }

    post '/add_project', action: 'admin#add_project', auth: { user: { is_superuser?: true } }

    post '/flag_user', action: 'admin#flag_user', auth: { user: { is_superuser?: true } }

    post '/update_key', action: 'user#update_key'

    def initialize
      super
      application.setup_db
    end
  end
end
