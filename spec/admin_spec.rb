describe AdminController do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  context 'main' do
    it 'returns a list of user projects' do
      user = create(:user, first_name: 'Janus', last_name: 'Bifrons', email: 'janus@two-faces.org')

      gateway = create(:project, project_name: 'gateway', project_name_full: 'Gateway')
      tunnel = create(:project, project_name: 'tunnel', project_name_full: 'Tunnel')
      mirror = create(:project, project_name: 'mirror', project_name_full: 'Mirror')

      perm = create(:permission, project: mirror, user: user, role: 'editor')
      perm = create(:permission, project: gateway, user: user, role: 'editor')

      auth_header(:janus)
      get('/')

      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/Your Projects/)
      expect(last_response.body).to match(/Gateway/)
      expect(last_response.body).to match(/Mirror/)
      expect(last_response.body).not_to match(/Tunnel/)
    end

    it 'returns the user public key fingerprint' do
      pkey = OpenSSL::PKey::RSA.new(1024)
      user = create(:user, first_name: 'Janus', last_name: 'Bifrons', email: 'janus@two-faces.org', public_key: pkey.public_key)

      auth_header(:janus)

      get('/')

      expect(last_response.status).to eq(200)
      expect(last_response.body).to match(/Your Keys/)
      expect(last_response.body).to match(/#{user.key_fingerprint}/i)
    end
  end
end
