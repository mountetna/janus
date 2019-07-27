class AdminController < Janus::Controller
  def main
    @janus_user = User[email: @user.email]
    erb_view(:main)
  end
end
