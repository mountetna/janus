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

    t1 = user.create_token!

    t1.refresh

    expect(t1.token).to match(%r!^[\w\-,]+\.[\w\-,]+\.[\w\-,]+$!)

    rsa_private = SignService.rsa_key
    rsa_public = rsa_private.public_key

    payload, headers = JWT.decode(
      t1.token, 
      rsa_public,
      true, 
      algorithm: Janus.instance.config(:token_algo)
    )

    expect(payload['email']).to eq(user.email)
    expect(payload['first']).to eq(user.first_name)
    expect(payload['last']).to eq(user.last_name)
    expect(payload['perm']).to eq('e:gateway,mirror;v:tunnel')
  end
end
