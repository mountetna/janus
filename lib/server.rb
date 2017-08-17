# This class handles the http request and routing
class Janus 
  class Server < Etna::Server
    def initialize(config)
      super
      application.connect(application.config(:db))
    end

    get '/', 'client#index'

    get '/login', 'user_log#log_in_shib'
    #get '/login', 'user_log#log_in_shib'
    post '/login', 'user_log#log_in'
    post '/logout', 'user_log#log_out'
    post '/check', 'user_log#check_log'

    # Administrative endpoints
    post '/check-admin', 'admin#check_admin'
    post '/check-admin-token', 'admin#check_admin_token'

    post '/get-users', 'admin#get_users'
    post '/get-projects', 'admin#get_projects'
    post '/get-permissions', 'admin#get_permissions'
    post '/get-groups', 'admin#get_groups'
    post '/upload-permissions', 'admin#upload_permissions'
    post '/remove-permissions', 'admin#remove_permissions'

    # Invalidate all tokens in the system.
    # This could cause problems with Metis if there are active uploads.
    post '/logout-all', 'admin#logout_all'

    def send_err(err)
      ip = @request.env['HTTP_X_FORWARDED_FOR'].to_s
      ref_id = SecureRandom.hex(4).to_s
      response = { success: false, ref: ref_id }
      m = err.method.to_s

      case err.type
      when :SERVER_ERR
        code = Conf::ERRORS[err.id].to_s
        @app_logger.error(ref_id+' - '+code+', '+m+', '+ip)
        response[:error] = 'Server error.'
      when :BAD_REQ
        code = Conf::WARNS[err.id].to_s
        @app_logger.warn(ref_id+' - '+code+', '+m+', '+ip)
        response[:error] = 'Bad request.'
      when :BAD_LOG
        code = Conf::WARNS[err.id].to_s
        @app_logger.warn(ref_id+' - '+code+', '+m+', '+ip)
        response[:error] = 'Invalid login.'
      else
        @app_logger.error(ref_id+' - UNKNOWN, '+m+', '+ip)
        response[:error] = 'Unknown error.'
      end
      return response
    end
  end
end
