#!/usr/bin/ruby

require 'digest'
require '../server/secrets'
require '../server/service/sign_service'

def print_help
  
  puts ''
  puts ' desc: A simple util to generate a passhash for the Janus Auth server.'
  puts 'usage: ./pass_hash_gen.rb [plain text password]'
  puts ''
end

# If the argument is 'nil', or if there are to many arguments, or if the
# argument is an empty string, then bail.
if ARGV[0].nil? || ARGV.length != 1 || ARGV[0].to_s.length == 0

  print_help
  exit 1
end

puts SignService::hash_password([ARGV[0].to_s, Secrets::PASS_SALT], Secrets::PASS_ALGO)