describe "Token Generation" do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def request_token rsa_key, nonce, email
    payload = [
      nonce,
      Base64.strict_encode64(email)
    ].join('.')

    # sign it and base64 encode
    my_sig = Base64.strict_encode64(
      rsa_key.sign(
        OpenSSL::Digest::SHA256.new,
        payload
      )
    )

    return [ payload, my_sig ].join('.')
  end

  before(:each) do 
    @rsa_key = OpenSSL::PKey::RSA.generate 1024

    @user = create(
      :user,
      email: 'janus@mount.etna',
      public_key: @rsa_key.public_key.to_s
    )
  end

  it "returns a signed timestamp token" do
    Timecop.freeze
    get('/time-signature')

    expect(last_response.status).to eq(200)
    date, sig = Base64.decode64(last_response.body).split(/\./)

    date = DateTime.parse(date)
    expect(date.iso8601).to eq(DateTime.now.iso8601)
    expect(sig).to match(/\A[0-9a-f]+\z/)
  end

  it "allows token generation with a user signature" do
    # First the user gets a nonce
    get('/time-signature')

    # Encode your authorization request
    request = request_token(@rsa_key, last_response.body,'janus@mount.etna')

    header('Authorization', "Basic #{request}")
    get('/generate')

    expect(last_response.status).to eq(200)

    # A new token was returned
    token = Token.first
    expect(last_response.body).to eq(token.token)
  end

  it "rejects token generation with an invalid nonce" do
    # This time we don't get a valid nonce from the
    # server but make up our own
    fake_nonce = Base64.strict_encode64(
      Digest::SHA256.hexdigest(
        @rsa_key.sign(OpenSSL::Digest::SHA256.new, DateTime.now.iso8601)
      )
    )

    # We sign it correctly as ourselves
    request = request_token(@rsa_key, fake_nonce, 'janus@mount.etna')

    header 'Authorization', "Basic #{request}"
    get('/generate')

    # The request is rejected
    expect(last_response.status).to eq(401)
  end

  it "rejects token generation with an invalid email" do
    # We get the valid nonce
    get('/time-signature')

    # But we ask for the wrong identity
    request = request_token(@rsa_key, last_response.body,'polyphemus@mount.etna')

    header 'Authorization', "Basic #{request}"
    get('/generate')

    # The request is rejected
    expect(last_response.status).to eq(401)
  end

  it "rejects token generation with an invalid signature" do
    # We get the valid nonce
    get('/time-signature')

    # But we set a different key for signing
    bad_rsa_key = OpenSSL::PKey::RSA.generate(1024)

    request = request_token(bad_rsa_key, last_response.body,'janus@mount.etna')

    header 'Authorization', "Basic #{request}"
    get('/generate')

    # The request is rejected
    expect(last_response.status).to eq(401)
  end
end
