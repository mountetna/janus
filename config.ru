# The packages
require 'rack'
require 'json'
require 'pg'
require 'sequel'
require 'digest'
require 'net/http'
require 'logger'
require 'erb'
require 'ostruct'
require 'uri'

# The details
require './server/conf'
require './server/secrets'
require './server/service/sign_service'

# The database
require './server/service/postgres_service'
PostgresService::connect()
require './server/models/models'

# The application
require './server/errors/basic_error'
require './server/janus'
require './server/routes'
require './server/controllers/basic_controller'
require './server/controllers/admin_controller'
require './server/controllers/client_controller'
require './server/controllers/user_log_controller'
use Rack::Static, urls: ['/css', '/js', '/fonts', '/img'], root: 'client'
run(Janus)
