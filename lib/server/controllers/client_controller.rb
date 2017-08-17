# This should only server a single user status page.
class ClientController < Janus::Controller
  def index
    view :index
  end
end
