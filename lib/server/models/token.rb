class Janus
  class Token < Sequel::Model
    many_to_one :user
    def self.generate(pass_hash)
      params = [Time.now.getutc.to_s, pass_hash, Secrets::TOKEN_SALT]
      return SignService::hash_password(params, Secrets::TOKEN_ALGO)
    end

    def self.expire_all!
      now = Time.now
      tokens = self.where('token_expire_stamp > ?', now)
        .where('token_logout_stamp > ?', now)

      count = tokens.count
      tokens.update( token_logout_stamp: now )

      return count
    end

    def valid?
      token_expire_stamp > Time.now && token_logout_stamp > Time.now
    end

    def invalidate!
      update(token_logout_stamp: Time.now)
    end
  end
end
