describe UserLogController do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end
  before(:each) do
    @client = create(:app, app_name: 'test', app_key: 'THE KEY')
  end

  context "password login" do
    before(:each) do
      @password = 'password'
      @user = create(
        :user,
        email: 'janus@mount.etna',
        pass_hash: SignService.hash_password(
          SignService.order_params(@password), Secrets::PASS_ALGO
        )
      )
    end

    it "complains without credentials" do
      json_post( :login, {} )
      expect(last_response.status).to eq(422)
    end

    it "validates a password" do
      json_post(
        :login, 
        email: @user.email,
        pass: 'bassboard',
        app_key: @client.app_key
      )
      expect(last_response.status).to eq(422)
    end

    it "returns success with credentials" do
      json_post(
        :login, 
        email: @user.email,
        pass: @password,
        app_key: @client.app_key
      )
      expect(last_response.status).to eq(200)
      expect(@user.valid_token).not_to be_nil
    end
  end

  context "logout" do
    it "logs the user out" do
      user = create( :user, email: 'janus@mount.etna' )
      token = create( :token, user: user, token: 'xyzzy',
                     token_expire_stamp: Time.now+60,
                     token_logout_stamp: Time.now+60)

      json_post(:logout,
                token: token.token,
                app_key: @client.app_key)
      user.refresh

      expect(user.valid_token).to be_nil
    end
  end

  context "check_log" do
    it "returns user information for a token" do
      user = create( :user, email: 'janus@mount.etna' )
      token = create( :token, user: user, token: 'xyzzy',
                     token_expire_stamp: Time.now+60,
                     token_logout_stamp: Time.now+60)

      json_post(:check,
                token: token.token,
                app_key: @client.app_key)

      json = JSON.parse(last_response.body)
      expect(json["user_info"]["email"]).to eq(user.email)
    end
  end
end
