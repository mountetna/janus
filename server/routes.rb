# routes.rb
# This file initiates Metis and sets the routing of the http requests.

Janus = Janus.new()

Janus.add_route('POST', '/login', 'Controller#log_in')
Janus.add_route('POST', '/logout', 'Controller#log_out')
Janus.add_route('POST', '/check', 'Controller#check_log')