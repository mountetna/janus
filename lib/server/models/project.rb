class Janus
  class Project < Sequel::Model
    one_to_many :permissions
    many_to_one :group

    def to_hash
      {
        project_id: id,
        group_id: group_id,
        group_name: group.group_name,
        project_name: project_name,
        project_name_full: project_name_full
      }
    end
  end
end
