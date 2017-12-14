class User < Sequel::Model
  one_to_many :permissions
  one_to_many :tokens, order: Sequel.desc(:token_login_stamp)

  def to_hash
    {
      email: email,
      first_name: first_name, 
      last_name: last_name, 
      token: valid_token.token,
      permissions:  permissions.map do |permission|
        {
          role: permission.role,
          project_name: permission.project.project_name,
          project_name_full: permission.project.project_name_full,
          group_name: permission.project.group.group_name
        }
      end
    }
  end

  def jwt_payload
    {
      email: email,
      first: first_name, 
      last: last_name, 
      perm:  permissions.group_by(&:role).sort_by(&:first).map do |role, perms|
        [ role[0], perms.map{|p| p.project.project_name}.sort.join(",") ].join(":")
      end.join(";")
    }
  end

  # WARNING! In the event of a shibboleth login 'pass_hash' == nil!
  def create_token!
    # Time is in seconds, nil = no expiration
    expires = Time.now.utc + Janus.instance.config(:token_life)

    add_token(
      token: Token.generate(self, expires), 
      token_login_stamp: Time.now.utc,
      token_expire_stamp: expires,
      token_logout_stamp: expires
    )
  end

  def valid_token
    tokens.find(&:valid?)
  end

  def valid_tokens
    tokens.select(&:valid?)
  end

  def expire_tokens!
    valid_tokens.each(&:invalidate!)
  end

  def authorized?(pass)
    # A password can be 'nil' if one logs in via Shibboleth/MyAccess.
    return false unless pass_hash

    client_hash = Janus.instance.sign.hash_password(pass)
    return pass_hash == client_hash
  end

  def admin?
    permissions.any? do |permission|
      permission.role == 'administrator' && permission.project && permission.project.project_name == 'Administration'
    end
  end
end
