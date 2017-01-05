# config.ru

require 'rack'
require 'json'
require 'pg'
require 'sequel'
require 'digest'
# require 'omniauth-shibboleth' # UCSF MyAccess Auth

require './server/conf'

require './server/controllers/controller'
require './server/controllers/client_controller'
require './server/controllers/admin_controller'

require './server/service/sign_service'
require './server/service/postgres_service'

require './server/janus'
require './server/routes'

#use Rack::Session::Pool
#
#use OmniAuth::Builder do
#  
#  provider :shibboleth, {
#
#    :shib_session_id_field     => "Shib-Session-ID",
#    :shib_application_id_field => "Shib-Application-ID",
#    :request_type              => :header,
#    :debug                     => false,
#    :info_fields => {
#
#      :email => "email",
#      :ucsf_id => "ucsfEduIdNumber",
#    },
#    :extra_fields => [
#
#      :"unscoped-affiliation",
#      :entitlement
#    ]
#  }
#end

use Rack::Static, urls: ['/css', '/js', '/fonts', '/img'], root: 'client'

run(Janus)