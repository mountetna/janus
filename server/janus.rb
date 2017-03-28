# This class handles the http request and routing
class Janus

  def initialize()

    @routes = {}
    @request = {}

    # Log file details
    path = ::File.dirname(::File.expand_path(__FILE__))
    log_file = ::File.join(path,'..','log','app.log')
    @app_logger = ::Logger.new(log_file, 5, 1048576)
    @app_logger.level = Logger::WARN
  end

  def call(env)

    # Parse the request
    @request = Rack::Request.new(env)
    route = @routes[[@request.request_method, @request.path]]

    if route

      begin

        call_action_for(route)
      rescue BasicError=> err

        Rack::Response.new(send_err(err).to_json)
      end
    else

      Rack::Response.new('File not found.', 404)
    end
  end

  # Routes are added in the './routes.rb' file
  def add_route(method, path, handler)

    @routes[[method, path]] = handler
  end

  private 
  def call_action_for(route)

    controller, action = route.split('#')
    controller_class = Kernel.const_get(controller)
    controller_class.new(@request, action).run()
  end

  def send_err(err)

    ip = @request.env['HTTP_X_FORWARDED_FOR'].to_s
    ref_id = SecureRandom.hex(4).to_s
    response = { :success=> false, :ref=> ref_id }
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