class Project < Sequel::Model
  one_to_many :permissions

  def to_hash
    {
      project_name: project_name,
      project_name_full: project_name_full
    }
  end
end
