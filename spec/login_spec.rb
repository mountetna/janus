describe UserLogController do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end
  before(:each) do
    @client = create(:app, app_name: 'test', app_key: 'THE KEY')
  end

  context 'password login' do
    before(:each) do
      @refer = "https://#{Janus.instance.config(:token_domain)}"
      @password = 'password'
      @user = create(
        :user,
        email: 'janus@mount.etna',
        pass_hash: Janus.instance.sign.hash_password(@password)
      )
    end

    it 'gets a simple form' do
      get("/login?refer=#{@refer}")

      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/value='#{@refer}'/)
    end

    it 'redirects with a valid cookie' do
      token = create( :token, user: @user, token: 'xyzzy',
                     token_expire_stamp: Time.now+60,
                     token_logout_stamp: Time.now+60)
      set_cookie([ Janus.instance.config(:token_name), token.token ].join('='))

      get("/login?refer=#{@refer}")

      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq(@refer)
      expect(@user.valid_token).not_to be_nil
    end

    it 'complains without credentials' do
      json_post( 'validate-login', {} )
      expect(last_response.status).to eq(422)
    end

    it 'validates a password' do
      form_post(
        'validate-login', 
        email: @user.email,
        password: 'bassboard',
        app_key: @client.app_key,
        refer: @refer
      )
      expect(last_response.status).to eq(422)
    end

    it 'sets a cookie with the token on success' do
      form_post(
        'validate-login', 
        email: @user.email,
        password: 'password',
        app_key: @client.app_key,
        refer: @refer
      )
      cookies = parse_cookie(last_response.headers['Set-Cookie'])
      expect(cookies[Janus.instance.config(:token_name)]).not_to be_nil
      expect(last_response.status).to eq(302)
    end

    context 'cookie expiration time' do
      it 'sets the expiration time on the cookie correctly for a new token' do
        form_post(
          'validate-login', 
          email: @user.email,
          password: 'password',
          app_key: @client.app_key,
          refer: @refer
        )
        @user.refresh
        token = @user.valid_token
        cookies = parse_cookie(last_response.headers['Set-Cookie'])
        cookie_time = Time.parse(cookies['expires'])

        expect(cookies[Janus.instance.config(:token_name)]).not_to be_nil
        expect(cookie_time).to be_within(1).of(token.token_expire_stamp)
        expect(last_response.status).to eq(302)
      end

      it 'sets a fresh token on login' do
        token = create( :token, user: @user, token: 'xyzzy',
                       token_login_stamp: Time.now - 60,
                       token_expire_stamp: Time.now+10,
                       token_logout_stamp: Time.now+10)
        form_post(
          'validate-login', 
          email: @user.email,
          password: 'password',
          app_key: @client.app_key,
          refer: @refer
        )
        @user.refresh
        valid_token = @user.valid_token
        cookies = parse_cookie(last_response.headers['Set-Cookie'])
        cookie_time = Time.parse(cookies['expires'])

        expect(cookies[Janus.instance.config(:token_name)]).to eq(valid_token.token)
        expect(cookies[Janus.instance.config(:token_name)]).not_to eq(token.token)
        expect(cookie_time).to be_within(1).of(valid_token.token_expire_stamp)
        expect(last_response.status).to eq(302)
      end
    end

    it 'redirects to refer with credentials' do
      form_post(
        'validate-login', 
        email: @user.email,
        password: @password,
        app_key: @client.app_key,
        refer: @refer
      )

      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to eq(@refer)
      expect(@user.valid_token).not_to be_nil
    end
  end

  context 'logout' do
    it 'logs the user out' do
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

  context 'check_log' do
    it 'returns user information for a token' do
      user = create( :user, email: 'janus@mount.etna' )
      token = create( :token, user: user, token: 'xyzzy',
                     token_expire_stamp: Time.now+60,
                     token_logout_stamp: Time.now+60)

      json_post(:check,
                token: token.token,
                app_key: @client.app_key)

      json = JSON.parse(last_response.body)
      expect(json['email']).to eq(user.email)
    end
  end
end
