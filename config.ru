# config.ru

require 'rack'
require 'json'
require 'pg'
require 'sequel'
require 'digest'
require 'logger'

require './server/conf'
require './server/models/user'
require './server/controllers/controller'
require './server/service/sign_service'
require './server/service/postgres_service'

require './server/janus'
require './server/routes'

use Rack::Static, urls: ['/css', '/js', '/fonts', '/img'], root: 'client'

run(Janus)