class AdminController < Janus::Controller
  def main
    @janus_user = User[email: @user.email]
    @header = erb_partial(:header)
    erb_view(:projects)
  end
end
