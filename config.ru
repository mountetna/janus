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
require_relative './lib/server/throttle'

use Etna::ParseBody
use Etna::SymbolizeParams
use Rack::Static, urls: ['/css', '/js', '/fonts', '/img'], root: 'lib/client'

use Janus::Throttle, max: 100
run Janus::Server.new(YAML.load(File.read('config.yml')))
