# routes.rb
# This file initiates Metis and sets the routing of the http requests.

Janus = Janus.new()

Janus.add_route('GET', '/', 'ClientController#index')
Janus.add_route('POST', '/login', 'Controller#log_in')
Janus.add_route('POST', '/logout', 'Controller#log_out')
Janus.add_route('POST', '/checklog', 'Controller#check_log')