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
          SignService.order_params(@password, Janus.instance.config(:pass_salt)),
          Janus.instance.config(:pass_algo)
        )
      )
    end

    it "gets a simple form" do
      refer = 'http://test.st'
      get("/login?refer=#{refer}")

      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/value='#{refer}'/)
    end

    it "complains without credentials" do
      json_post( :login, {} )
      expect(last_response.status).to eq(422)
    end

    it "validates a password" do
      form_post(
        :login, 
        email: @user.email,
        password: 'bassboard',
        app_key: @client.app_key
      )
      expect(last_response.status).to eq(422)
    end

    it "redirects to refer with credentials" do
      refer = "https://test.host"
      form_post(
        :login, 
        email: @user.email,
        password: @password,
        app_key: @client.app_key,
        refer: refer
      )

      expect(last_response.status).to eq(302)
      expect(last_response.headers["Location"]).to eq(refer)
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
      expect(json["email"]).to eq(user.email)
    end
  end
end
