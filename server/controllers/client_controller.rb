# client_controller.rb
# This controller serves the client pages and code. 

class ClientController

  def initialize(request, action)

    @request = request
    @action = action
  end

  def run()  

    send(@action)
  end

  def index()

    template = File.read('./server/views/index.html')
    Rack::Response.new(template)
  end
end