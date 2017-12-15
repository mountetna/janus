# The packages
require 'bundler'
Bundler.require(:default, ENV["JANUS_ENV"].to_sym)

require 'json'
require 'yaml'
require 'digest'
require 'net/http'
require 'logger'
require 'erb'
require 'ostruct'
require 'uri'
require 'securerandom'

# The application
require_relative './lib/janus'
require_relative './lib/server'
require_relative './lib/server/controllers/janus_controller'
require_relative './lib/server/controllers/admin_controller'
require_relative './lib/server/controllers/authorization_controller'

use Etna::ParseBody
use Etna::SymbolizeParams
use Rack::Static, urls: ['/css', '/js', '/fonts', '/img'], root: 'lib/client'

run Janus::Server.new(YAML.load(File.read('config.yml')))
