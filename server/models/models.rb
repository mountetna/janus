module Models

  class App < Sequel::Model
  end

  class Permission < Sequel::Model

    many_to_one :project
    many_to_one :user

    def to_hash()

      perm_hash = {

        :id=> id,
        :user_id=> user_id,
        :project_id=> project_id,
        :role=> role,
        :project_name=> project.project_name,
        :user_email=> user.email,
        :group_id=> project.group_id,
        :group_name=> project.group.group_name
      }
    end
  end

  class Project < Sequel::Model

    one_to_many :permissions
    many_to_one :group

    def to_hash()

      to_hash = {

        :project_id=> id,
        :group_id=> group_id,
        :group_name=> group.group_name,
        :project_name=> project_name,
      }
    end
  end

  class Group < Sequel::Model

    one_to_many :projects
  end

  class Token < Sequel::Model

    def valid?()

      now = Time.now
      (token_expire_stamp > now && token_logout_stamp > now) ? true : false
    end
  end

  class User < Sequel::Model

    one_to_many :permissions
    one_to_many :tokens

    def to_hash()

      user_hash = {

        :email=> email,
        :first_name=> first_name, 
        :last_name=> last_name, 
        :user_id=> id,
        :token=> get_token(),

        :permissions=>  permissions.map do |permission|

          perm = {

            :role=> permission.role,
            :project_id=> permission.project_id,
            :project_name=> permission.project.project_name,
            :group_id=> permission.project.group_id,
            :group_name=> permission.project.group.group_name
          }
        end
      }

      return user_hash
    end

    def get_token()

      # if there are no tokens
      if !(tokens.length) then return nil end

      tkns = tokens.map do |token|

        (token.valid?()) ? token.token : nil
      end

      return (tkns[tkns.length-1]) ? tkns[tkns.length-1] : nil
    end

    def authorized?(pass)

      # A password can be 'nil' if one logs in via Shibboleth/MyAccess.
      if pass_hash == nil then return false end

      ordered_params = SignService::order_params(pass)
      client_hash = SignService::hash_password(ordered_params, Secrets::PASS_ALGO)
      return (pass_hash == client_hash) ? true : false
    end

    def admin?()

      admin = false
      permissions.map do |permission|

        project = Models::Project[:id=> permission.project_id]
        if project.project_name == 'administration'

          if permission.role == 'administrator'

            admin = true
          end
        end
      end
      return admin
    end
  end
end