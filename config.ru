# The packages
require 'rack'
require 'json'
require 'pg'
require 'sequel'
require 'digest'
require 'logger'

# The details
require './server/conf'
require './server/secrets'
require './server/service/sign_service'

# The database
require './server/service/postgres_service'
PostgresService::connect()
require './server/models/models'

# The application
require './server/janus'
require './server/routes'
require './server/controllers/user_log_controller'
use Rack::Static, urls: ['/css', '/js', '/fonts', '/img'], root: 'client'
run(Janus)