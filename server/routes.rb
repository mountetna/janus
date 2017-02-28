# routes.rb
# This file initiates Metis and sets the routing of the http requests.

Janus = Janus.new()

Janus.add_route('POST', '/login', 'UserLogController#log_in')
Janus.add_route('POST', '/logout', 'UserLogController#log_out')
Janus.add_route('POST', '/check', 'UserLogController#check_log')