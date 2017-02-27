module PostgresService

  def self.connect()

    db_config = {

      :adapter=> 'postgres',
      :host=> 'localhost', 
      :database=> 'janus',

      :user=> Conf::PSQL_USER,
      :password=> Conf::PSQL_PASS,
      :search_path=>['private']
    }

    @postgres = Sequel.connect(db_config)
  end

  def self.create_new_token!(user)

    self.expire_tokens!(user.id)

    expires = Time.now + Conf::TOKEN_EXP
    row = {

      :token=> self.generate_token(user.pass_hash), 
      :user_id=> user.id,
      :token_login_stamp=> Time.now,
      :token_expire_stamp=> expires, # Time is in seconds, nil = no expiration
      :token_logout_stamp=> expires
    }
    Models::Token.create(row)
  end

  def self.generate_token(pass_hash)

    params = [Time.now.getutc.to_s, pass_hash, Conf::TOKEN_SALT]
    return SignService::hash_password(params, Conf::TOKEN_ALGO)
  end

  def self.expire_tokens!(user_id)

    tokens = self.valid_tokens(user_id)
    self.invalidate_tokens(tokens)
  end

  def self.valid_tokens(user_id)

    now = Time.now
    tokens = @postgres[:tokens]
      .where('token_expire_stamp > ?', now)
      .where('token_logout_stamp > ?', now)
      .and(:user_id=> user_id)
      .order(Sequel.desc(:token_expire_stamp))
      .all
  end

  def self.invalidate_tokens(tokens)

    tokens.each do |token|

      @postgres[:tokens]
        .where(:id=> token[:id])
        .update(:token_logout_stamp=> Time.now)
    end
  end
end