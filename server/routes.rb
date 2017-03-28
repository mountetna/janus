# routes.rb
# This file initiates Metis and sets the routing of the http requests.

Janus = Janus.new()

Janus.add_route('GET', '/', 'ClientController#index')

Janus.add_route('GET', '/login', 'UserLogController#log_in_shib')
Janus.add_route('POST', '/login', 'UserLogController#log_in')
Janus.add_route('POST', '/logout', 'UserLogController#log_out')
Janus.add_route('POST', '/check', 'UserLogController#check_log')

# Administrative endpoints
Janus.add_route('POST', '/check-admin', 'AdminController#check_admin')
Janus.add_route('POST', '/check-admin-token', 'AdminController#check_admin_token')

Janus.add_route('POST', '/get-users', 'AdminController#get_users')
Janus.add_route('POST', '/get-projects', 'AdminController#get_projects')
Janus.add_route('POST', '/get-permissions', 'AdminController#get_permissions')
Janus.add_route('POST', '/get-groups', 'AdminController#get_groups')
Janus.add_route('POST', '/upload-permissions', 'AdminController#upload_permissions')
Janus.add_route('POST', '/remove-permissions', 'AdminController#remove_permissions')

# Invalidate all tokens in the system.
# This could cause problems with Metis if there are active uploads.
Janus.add_route('POST', '/logout-all', 'AdminController#logout_all')
