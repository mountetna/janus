class Token < Sequel::Model
  many_to_one :user

  class << self
    def generate(user)
      SignService.jwt_token(user)
    end

    def expire_all!
      now = Time.now
      tokens = self.where('token_expire_stamp > ?', now)
        .where('token_logout_stamp > ?', now)

      count = tokens.count
      tokens.update( token_logout_stamp: now )

      return count
    end
  end

  def valid?
    token_expire_stamp > Time.now && token_logout_stamp > Time.now
  end

  def invalidate!
    update(token_logout_stamp: Time.now)
  end
end
