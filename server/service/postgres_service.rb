# postgres_service.rb

class PostgresService

  def initialize()

    db_config = {

      :adapter=> 'postgres',
      :host=> 'localhost', 
      :database=> 'janus',
      :user=> Conf::PSQL_USER,
      :password=> Conf::PSQL_PASS
    }

    @postgres = Sequel.connect(db_config)
  end

  def check_pass_exsists(email, pass)

    if check_user_exsists(email)

      user = @postgres[:users].where(:email=>email).all
      if user[0][:pass_hash].nil? || pass == ''

        return false
      else

        return true
      end
      return false
    else

      return false
    end
  end

  def check_user_exsists(email)

    begin
      
      count = @postgres[:users].where(:email=>email).count
      if count == 0

        # The email doesn't exist.
        return false
      elsif count > 1

        # There are multiple copies of the email which should not be since the 
        # DB column should be set to "UNIQUE". Send an error message/alert and
        # log.
        return false
      elsif count == 1

        # The email exists, so continue.
        return true
      else

        # Some other condition was met that is out of the integer domain. 
        # Send and error message/alert and log.
        return false
      end
    rescue Sequel::Error => error

      # log error.message
      return false
    end
  end

  def get_token(email)

    now = Time.now
    user_id = get_user_id(email)
    tokens = pull_tokens_for_user(user_id)

    token = 0
    if tokens.count > 0

      # Select the token with the longest expiration time left and expire 
      # all others for the user.
      token = tokens.all[0][:token]

      tokens.drop(1).each do |tkn|

        tokens
          .where(:token_id=> tkn[:token_id])
          .update(:token_expire_stamp=> now)
      end
    end

    return token
  end

  def set_token(email, token)

    user = @postgres[:users].where(:email=> email).all
    user_id = user[0][:user_id]
    expires = Time.now + Conf::TOKEN_EXP

    row = {

      :token=> token, 
      :user_id=> user_id, 
      :token_expire_stamp=> expires # Time is in seconds, nil = no expiration
    }

    tokens = @postgres[:tokens]
    tokens.insert(row)
  end

  # Expire all the tokens for a user.
  def invalidate_token(email)

    now = Time.now
    user_id = get_user_id(email)
    tokens = pull_tokens_for_user(user_id)

    # Loop the tokens and invalidate by setting the expiration to 'now'.
    tokens.each do |token|

      @postgres[:tokens]
        .where(:token_id=> token[:token_id])
        .update(:token_expire_stamp=> now)
    end
  end

  # Get the user's password hash.
  def get_pass_hash(email)

    user = @postgres[:users].where(:email=> email).all
    user[0][:pass_hash]
  end

  # Get the user id from the user's email.
  def get_user_id(email)

    user = @postgres[:users].where(:email=> email).all
    user_id = user[0][:user_id]
  end

  def get_user_name(email)

    user = @postgres[:users].where(:email=> email).all
    first_name = user[0][:first_name]
    last_name = user[0][:last_name]

    { first_name: first_name, last_name: last_name }
  end

  def check_log(auth_token)

    now = Time.now
    tokens = @postgres[:tokens]
      .where('token_expire_stamp > ?', now)
      .or('token_expire_stamp IS NULL')
      .and(:token=> auth_token)

    if tokens.count < 1

      return 0
    end

    token = tokens.all[0]
    user_id = token[:user_id]
    user = @postgres[:users].where(:user_id=> user_id).all[0]

    {

      email: user[:email],
      first_name: user[:first_name],
      last_name: user[:last_name]
    }
  end

  # Get a list of all valid tokens by the user id. Put the last issued token
  # at the top.
  def pull_tokens_for_user(user_id)

    now = Time.now
    tokens = @postgres[:tokens]
      .where('token_expire_stamp > ?', now)
      .or('token_expire_stamp IS NULL')
      .and(:user_id=> user_id)
      .order(Sequel.desc(:token_expire_stamp))
  end
end