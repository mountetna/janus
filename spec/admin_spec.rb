describe AdminController do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  before(:each) do
    @client = create(:app, app_name: 'test', app_key: 'THE KEY')
    @admin = create(:user, email: 'admin@mount.etna' )
    @token = create(:token, user: @admin, token: 'godmode',
                     token_expire_stamp: Time.now+60,
                     token_logout_stamp: Time.now+60)
    @project = create(:project, project_name: 'Administration', project_name_full: 'janus test')
    @permission = create(:permission, user: @admin, project: @project, role: 'administrator')
  end

  it "forbids non-admin users" do
    user = create( :user, email: 'janus@mount.etna')
    token = create( :token, user: user, token: 'xyzzy',
                     token_expire_stamp: Time.now+60,
                     token_logout_stamp: Time.now+60)

    json_post('check-admin-token', token: token.token, app_key: @client.app_key)

    expect(last_response.status).to eq(422)
  end

  it "allows admin users" do
    json_post('check-admin-token', token: @token.token, app_key: @client.app_key)
    expect(last_response.status).to eq(200)
  end
end
