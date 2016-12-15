# postgres_service.rb

class PostgresService

  def initialize()

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

  def pass_exsists?(email, pass)

    begin

      if user_exsists?(email)

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
    rescue Sequel::Error=> error

      # log error.message
      return false
    end
  end

  def user_exsists?(email)

    begin
      
      count = @postgres[:users].where(:email=> email).count
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
    rescue Sequel::Error=> error

      #puts error.message
      return false
    end
  end

  def get_token(email)

    begin

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
            .where(:id=> tkn[:id])
            .update(:token_logout_stamp=> now)
        end
      end

      return token
    rescue Sequel::Error=> error

      # log error.message
      return 0
    end
  end

  def set_token(email, token)

    begin

      user = @postgres[:users].where(:email=> email).all

      user_id = user[0][:id]
      expires = Time.now + Conf::TOKEN_EXP

      row = {

        :token=> token, 
        :user_id=> user_id,
        :token_login_stamp=> Time.now,
        :token_expire_stamp=> expires, # Time is in seconds, nil = no expiration
        :token_logout_stamp=> expires
      }

      tokens = @postgres[:tokens]
      tokens.insert(row)
    rescue Sequel::Error=> error

      # log error.message
    end
  end

  # Expire all the tokens for a user.
  def invalidate_token(email)

    begin

      now = Time.now
      user_id = get_user_id(email)
      tokens = pull_tokens_for_user(user_id)

      # Loop the tokens and invalidate by setting the expiration to 'now'.
      tokens.each do |token|

        @postgres[:tokens]
          .where(:id=> token[:id])
          .update(:token_logout_stamp=> now)
      end
    rescue Sequel::Error=> error

      # log error.message
    end
  end

  # Get the user's password hash.
  def get_pass_hash(email)

    begin
      
      user = @postgres[:users].where(:email=> email).all
      return user[0][:pass_hash]
    rescue Sequel::Error=> error

      # log error.message
      return 0
    end
  end

  # Get the user id from the user's email.
  def get_user_id(email)

    begin
      
      user = @postgres[:users].where(:email=> email).all
      if user.length == 0

        return 0
      else

        return user_id = user[0][:id]
      end
    rescue Sequel::Error=> error

      # log error.message
      return 0
    end
  end

  def get_user_info(email)

    begin

      user = @postgres[:users].where(:email=> email).all
      user_id = user[0][:id]
      first_name = user[0][:first_name]
      last_name = user[0][:last_name]

      permissions = @postgres[:permissions].where(:user_id=> user_id).all
  
      # Map postgres rows to objects, using the primary key 'id' as the 
      # object key.
      prjkts = @postgres[:projects].all

      projects = {}
      prjkts.each do |prjkt|

        projects[prjkt[:id]] = prjkt[:project_name]
      end
      # Add the project name to the permissions.
      permissions.each do |permission|

        permission[:project_name] = projects[permission[:project_id]]
        
        # Remove any information not required by the client.
        permission.delete(:id)
        permission.delete(:user_id)
      end

      return { 

        :email=> email,
        :first_name=> first_name, 
        :last_name=> last_name, 
        :permissions=>  permissions,
        :user_id=> user_id
      }

    rescue Sequel::Error=> error

      # log error.message
      return 0
    end
  end

  def check_log(auth_token)

    begin

      now = Time.now

      tokens = @postgres[:tokens]
        .where('token_expire_stamp > ?', now)
        .where('token_logout_stamp > ?', now)
        .and(:token=> auth_token)

      if tokens.count < 1

        return 0
      end

      token = tokens.all[0]
      user_id = token[:user_id]
      user = @postgres[:users].where(:id=> user_id).all[0]
      user_info = get_user_info(user[:email])

      return user_info

    rescue Sequel::Error=> error

      # log error.message
      return 0
    end
  end

  # Check if the application requesting the check is registered.
  def app_valid?(app_key)

    apps = @postgres[:apps].where(:app_key=> app_key).all

    if apps.length == 1

      return true
    end

    if apps.length > 1
        
      # log error! There should only be one application per key!
      return false
    end

    return false
  end

  # Get a list of all valid tokens by the user id. Put the last issued token
  # at the top.
  def pull_tokens_for_user(user_id)

    begin

      now = Time.now
      tokens = @postgres[:tokens]
        .where('token_expire_stamp > ?', now)
        .where('token_logout_stamp > ?', now)
        .and(:user_id=> user_id)
        .order(Sequel.desc(:token_expire_stamp))

      return tokens
    rescue Sequel::Error=> error

      # log error.message
    end
  end

  def fetch_all_users()

    begin

      return @postgres[:users].select(:id, :email, :first_name, :last_name).all
    rescue Sequel::Error=> error

      # log error.message
      return 0
    end
  end

  def fetch_all_groups()

    begin

    rescue Sequel::Error=> error

      # log error.message
    end
  end

  def fetch_all_projects()

    begin

      return @postgres[:projects].all
    rescue Sequel::Error=> error

      # log error.message
      return 0
    end
  end

  def fetch_all_permissions()

    begin

      @postgres[:permissions].all
    rescue Sequel::Error=> error

      # log error.message
      return 0
    end
  end
end