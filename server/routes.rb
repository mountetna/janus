# routes.rb
# This file initiates Metis and sets the routing of the http requests.

Janus = Janus.new()

Janus.add_route('GET', '/', 'ClientController#index')
Janus.add_route('POST', '/login', 'Controller#start_log')