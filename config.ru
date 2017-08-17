# The packages
require 'bundler'

Bundler.require(:default)

require 'json'
require 'yaml'
require 'digest'
require 'net/http'
require 'logger'
require 'erb'
require 'ostruct'
require 'uri'
require 'securerandom'

# The details
require_relative './lib/server/conf'
require_relative './lib/server/secrets'
require_relative './lib/server/service/sign_service'

# The application
require_relative './lib/janus'
require_relative './lib/server'
require_relative './lib/server/controllers/janus_controller'
require_relative './lib/server/controllers/admin_controller'
require_relative './lib/server/controllers/client_controller'
require_relative './lib/server/controllers/user_log_controller'

use Etna::ParseBody
use Etna::SymbolizeParams
use Rack::Static, urls: ['/css', '/js', '/fonts', '/img'], root: 'lib/client'

run Janus::Server.new(YAML.load(File.read("config.yml")))
