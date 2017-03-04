# This should only server a single user status page.
class ClientController

  def run()

    return send(@action)
  end

  def index()

    return File.read('./server/views/index.html')
  end

  def login()

    return File.read('./server/views/login.html')
  end
end