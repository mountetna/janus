Sequel.migration do 

  up do

    create_table(:users) do

      primary_key :user_id
      String :email, :null=>false
      String :first_name
      String :last_name
      String :pass_hash, :null=>false
      DateTime :user_create_stamp, :null=>false, :default=>Time.now
    end

    create_table(:roles) do

      primary_key :role_id
      String :role_name, :null=>false
    end

    create_table(:apps) do

      primary_key :app_id
      String :app_name, :null=>false
    end

    create_table(:permissions) do

      primary_key :permission_id
      foreign_key :user_id, :users
      foreign_key :role_id, :roles
      foreign_key :app_id, :apps
    end

    create_table(:tokens) do

      primary_key :token_id
      String :token
      foreign_key :user_id, :users
      DateTime :token_create_stamp, :null=>false, :default=>Time.now
      DateTime :token_expire_stamp
    end
  end

  down do

    drop_table(:tokens)
    drop_table(:permissions)
    drop_table(:apps)
    drop_table(:roles)
    drop_table(:users)
  end
end