# routes.rb
# This file initiates Metis and sets the routing of the http requests.

Janus = Janus.new()

Janus.add_route('GET', '/', 'ClientController#index')
#
#Janus.add_route('POST', '/upload-start', 'UploadController#start_upload')
#Janus.add_route('POST', '/upload-blob', 'UploadController#upload_blob')
#Janus.add_route('POST', '/upload-pause', 'UploadController#pause_upload')
#Janus.add_route('POST', '/upload-stop', 'UploadController#stop_upload')
#
#Janus.add_route('POST', '/magma-end-point', 'MagmaController#magma_end_point')