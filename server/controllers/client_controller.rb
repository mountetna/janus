# This should only server a single user status page.
class ClientController

  def initialize(request, action)

    @request = request
    @params = request.POST()
    @action = action
  end

  def run()

    return Rack::Response.new(send(@action))
  end

  def index()

    return File.read('./server/views/index.html')
  end
end