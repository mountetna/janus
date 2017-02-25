module Models

  class App < Sequel::Model
  end

  class Permission < Sequel::Model
  end

  class Project < Sequel::Model
  end

  class Group < Sequel::Model
  end

  class User < Sequel::Model

    one_to_many :permissions

    def to_hash()

      user_hash = {

        :email=> email,
        :first_name=> first_name, 
        :last_name=> last_name, 
        :user_id=> id,

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

    def authorized?(pass)

      ordered_params = SignService::order_params(pass)
      client_hash = SignService::hash_password(ordered_params, Conf::PASS_ALGO)
      return (pass_hash == client_hash) ? true : false
    end
  end
end