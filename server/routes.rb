# routes.rb
# This file initiates Metis and sets the routing of the http requests.

Janus = Janus.new()

Janus.add_route('GET', '/', 'ClientController#index')
Janus.add_route('POST', '/login', 'Controller#log_in')
Janus.add_route('POST', '/logout', 'Controller#log_out')
Janus.add_route('POST', '/check', 'Controller#check_log')

Janus.add_route('POST', '/get-users', 'AdminController#get_users')
Janus.add_route('POST', '/get-projects', 'AdminController#get_projects')
Janus.add_route('POST', '/get-permissions', 'AdminController#get_permissions')
Janus.add_route('POST', '/save-permission', 'AdminController#save_permission')
Janus.add_route('POST', '/upload-permissions', 'AdminController#upload_permissions')