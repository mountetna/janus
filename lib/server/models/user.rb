class Janus
  class User < Sequel::Model
    one_to_many :permissions
    one_to_many :tokens

    def to_hash
      {
        email: email,
        first_name: first_name, 
        last_name: last_name, 
        user_id: id,
        token: valid_token,
        permissions:  permissions.map do |permission|
          {
            role: permission.role,
            project_id: permission.project_id,
            project_name: permission.project.project_name,
            project_name_full: permission.project.project_name_full,
            group_id: permission.project.group_id,
            group_name: permission.project.group.group_name
          }
        end
      }
    end

    # WARNING! In the event of a shibboleth login 'pass_hash' == nil!
    def create_token!
      expire_tokens!
 
      # Time is in seconds, nil = no expiration
      expires = Time.now + Janus.instance.config(:token_life)

      add_token(
        token: Janus::Token.generate(pass_hash), 
        token_login_stamp: Time.now,
        token_expire_stamp: expires,
        token_logout_stamp: expires
      )
    end

    def valid_token
      tokens.find(&:valid?)[:token]
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

      client_hash = SignService::hash_password(
        SignService::order_params(pass, Janus.instance.config(:pass_salt)),
        Janus.instance.config(:pass_algo)
      )
      return pass_hash == client_hash
    end

    def admin?
      permissions.any? do |permission|
        permission.role == 'administrator' && permission.project && permission.project.project_name == 'Administration'
      end
    end
  end
end
