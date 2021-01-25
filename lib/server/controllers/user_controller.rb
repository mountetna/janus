class UserController < Janus::Controller
  def update_key
    @janus_user = User[email: @user.email]

    raise Etna::Forbidden, 'User not found' unless @janus_user

    # parse the key
    begin
      key = OpenSSL::PKey.read(@params[:pem])
      raise Etna::BadRequest, 'Key must be RSA' unless key.is_a?(OpenSSL::PKey::RSA)
      raise Etna::BadRequest, 'Cannot use a private key' if key.private?
      raise Etna::BadRequest, 'Key must be 2048 bits' unless key.n.num_bits >= 2048
    rescue OpenSSL::PKey::PKeyError
      raise Etna::BadRequest, 'Improperly formatted key'
    end

    @janus_user.public_key = @params[:pem]
    @janus_user.save

    success('User Public Key updated')
  end

  def refresh_token
    @janus_user = User[email: @user.email]

    raise Etna::Forbidden, 'User not found' unless @janus_user

    success(@janus_user.create_token!)
  end

  def viewer_token
    @janus_user = User[email: @user.email]

    raise Etna::Forbidden, 'User not found' unless @janus_user

    success(@janus_user.create_token!(viewer_only: true))
  end

  def projects
    @janus_user = User[email: @user.email]

    raise Etna::Forbidden, 'User not found' unless @janus_user

    projects = @janus_user.permissions.map do |perm|
      perm.project
    end.uniq.map do |proj|
      @params[:full] ? proj.to_hash :
      # Don't use proj.to_hash because we don't necessarily want to send back
      #   all the information.
      {
        project_name: proj.project_name,
        project_name_full: proj.project_name_full,
        project_description: proj.project_description
      }
    end

    success_json({projects: projects})
  end
end
