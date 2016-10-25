# postgres_service.rb

class PostgresService

  def initialize()

    db_config = {

      :adapter=> 'postgres',
      :host=> 'localhost', 
      :database=> 'janus',
      :user=> 'postgres',
      :password=> 'abc123'
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

  def get_pass_hash(email)

    user = @postgres[:users].where(:email=> email).all
    user[0][:pass_hash]
  end

  def get_token(email)

    user = @postgres[:users].where(:email=> email).all
    user_id = user[0][:user_id]

    tokens = @postgres[:tokens]
      .where(:user_id=> user_id)
      .order(:token_create_stamp)

    if tokens.count == 0

      return 0
    end

    return 0
  end

  def set_token(email, token)

    user = @postgres[:users].where(:email=> email).all
    user_id = user[0][:user_id]
    expires = Time.now + Conf::TOKEN_EXP

    row = {

      :token=> token, 
      :user_id=> user_id, 
      :token_expire_stamp=> expires # Time is in seconds, 0 = no expiration
    }

    tokens = @postgres[:tokens]
    tokens.insert(row)
  end

  def invalidate_token(email)

    # Get the user id and the current timestamp.
    user = @postgres[:users].where(:email=> email).all
    user_id = user[0][:user_id]
    now = Time.now

    # Get the tokens for user that could still be valid.
    tokens = @postgres[:tokens]
      .where('token_expire_stamp > ?', now)
      .or('token_expire_stamp IS NULL')
      .and(:user_id=> user_id)
      .order(:token_create_stamp)

    puts tokens.all

    # Loop the tokens and invalidate by setting the expiration to 'now'.
    tokens.each do |token|

      @postgres[:tokens]
        .where(:token_id=> token[:token_id])
        .update(:token_expire_stamp=> now)
    end
  end
end