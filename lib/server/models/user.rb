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

    def create_token!
      expire_tokens!
 
      # Time is in seconds, nil = no expiration
      expires = Time.now + Conf::TOKEN_EXP

      add_token(
        token: Janus::Token.generate(pass_hash), 
        token_login_stamp: Time.now,
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

      ordered_params = SignService::order_params(pass)
      client_hash = SignService::hash_password(ordered_params, Secrets::PASS_ALGO)
      return pass_hash == client_hash
    end

    def admin?
      permissions.any? do |permission|
        permission.role == 'administrator' && permission.project && permission.project.project_name == 'Administration'
      end
    end
  end
end
