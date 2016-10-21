# config.ru

require 'rack'
require 'json'

require './server/controllers/controller'
require './server/controllers/client_controller'

require './server/janus'
require './server/routes'

use Rack::Static, urls: ['/css', '/js', '/fonts', '/img'], root: 'client'

run(Janus)