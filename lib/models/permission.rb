class Janus
  class Permission < Sequel::Model
    many_to_one :project
    many_to_one :user

    def to_hash
      {
        id: id,
        user_id: user_id,
        project_id: project_id,
        role: role,
        project_name: project.project_name,
        user_email: user.email,
        group_id: project.group_id,
        group_name: project.group.group_name
      }
    end
  end
end
