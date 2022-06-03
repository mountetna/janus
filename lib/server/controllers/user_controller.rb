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

    success_json(user: @janus_user.to_hash)
  end

  def info
    @janus_user = User[email: @user.email]

    raise Etna::Forbidden, 'User not found' unless @janus_user

    success_json(user: @janus_user.to_hash)
  end

  def projects
    @janus_user = User[email: @user.email]

    raise Etna::Forbidden, 'User not found' unless @janus_user

    projects = @janus_user.permissions.map do |perm|
      # Don't use proj.to_hash because we don't necessarily want to send back
      #   all the information.
      {
        project_name: perm.project.project_name,
        project_name_full: perm.project.project_name_full,
        role: perm.role,
        privileged: perm.privileged?,
        resource: perm.project.resource,
        requires_agreement: perm.project.requires_agreement,
        cc_text: perm.project.cc_text,
      }
    end.concat(Project.where(resource: true).all.map do |proj|
      {
        project_name: proj.project_name,
        project_name_full: proj.project_name_full,
        resource: proj.resource,
        requires_agreement: proj.requires_agreement,
        cc_text: proj.cc_text,
      }
    end).uniq do |proj|
      proj[:project_name]
    end

    success_json({projects: projects})
  end

  def fetch_all
    success_json({
      users: User.all.map do |u|
        {
          email: u.email,
          name: u.name,
          flags: u.flags,
          projects: u.permissions.map { |p| p.project.project_name }
        }
      end
    })
  end
end
