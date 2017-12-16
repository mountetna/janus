describe User do
  it 'can have multiple valid tokens' do
    user = create(:user, email: 'janus@two-faces.org')

    t1 = user.create_token!
    t2 = user.create_token!

    t1.refresh
    t2.refresh

    expect(t1).to be_valid
    expect(t2).to be_valid
  end

  it 'returns a JWT' do
    user = create(:user, first_name: 'Janus', last_name: 'Bifrons', email: 'janus@two-faces.org')
    mirror = create(:project, project_name: 'mirror', project_name_full: 'Mirror')
    gateway = create(:project, project_name: 'gateway', project_name_full: 'Gateway')
    tunnel = create(:project, project_name: 'tunnel', project_name_full: 'Tunnel')

    perm = create(:permission, project: mirror, user: user, role: 'editor')
    perm = create(:permission, project: gateway, user: user, role: 'editor')
    perm = create(:permission, project: tunnel, user: user, role: 'viewer')

    token = user.create_token!

    token.refresh

    expect(token.token).to match(%r!^[\w\-,]+\.[\w\-,]+\.[\w\-,]+$!)

    payload, headers = Janus.instance.sign.jwt_decode(token.token)

    expect(payload['email']).to eq(user.email)
    expect(payload['first']).to eq(user.first_name)
    expect(payload['last']).to eq(user.last_name)
    expect(payload['perm']).to eq('e:gateway,mirror;v:tunnel')
  end

  it 'expires the JWT' do
    now = Time.now
    Timecop.freeze(now)

    user = create(:user, first_name: 'Janus', last_name: 'Bifrons', email: 'janus@two-faces.org')

    token = user.create_token!

    rsa_private = Janus.instance.sign.private_key
    rsa_public = rsa_private.public_key

    expect {
        payload, headers = JWT.decode(
        token.token, 
        rsa_public,
        true, 
        algorithm: Janus.instance.config(:token_algo)
      )
    }.not_to raise_error(JWT::ExpiredSignature)

    Timecop.freeze(now + Janus.instance.config(:token_life) + 10) do
      expect {
        payload, headers = JWT.decode(
          token.token, 
          rsa_public,
          true, 
          algorithm: Janus.instance.config(:token_algo)
        )
      }.to raise_error(JWT::ExpiredSignature)
    end

    Timecop.return
  end
end
