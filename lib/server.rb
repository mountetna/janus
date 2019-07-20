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

    # This generates nonces
    get '/time-signature', action: 'authorization#time_signature'
    # This uses a signed nonce to generate a new token
    get '/generate', action: 'authorization#generate'

    def initialize(config)
      super
      application.setup_db
    end
  end
end
