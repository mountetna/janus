module Models

  class App < Sequel::Model
  end

  class Permission < Sequel::Model
  end

  class Project < Sequel::Model
  end

  class Group < Sequel::Model
  end

  class Token < Sequel::Model

    def valid?()

    end

    def user()

    end

    def hash()

      return token
    end

    def invalidate!()

    end
  end

  class User < Sequel::Model

    one_to_many :permissions

    def authorized?(pass)

      ordered_params = SignService::order_params(pass)
      client_hash = SignService::hash_password(ordered_params, Conf::PASS_ALGO)
      return (pass_hash == client_hash) ? true : false
    end

    def to_hash()

      user_hash = {

        :email=> email,
        :first_name=> first_name, 
        :last_name=> last_name, 
        :user_id=> id,
        :token=> get_token(),

        :permissions=>  permissions.map do |permission|

          project = Models::Project[:id=> permission.project_id]
          group = Models::Group[:id=> project.group_id]

          perm = {

            :role=> permission.role,
            :project_id=> permission.project_id,
            :project_name=> project.project_name,
            :group_id=> project.group_id,
            :group_name=> group.group_name
          }
        end
      }

      return user_hash
    end

    def get_token()

      return PostgresService::valid_tokens(id)[0][:token]
    end
  end
end