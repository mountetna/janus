class Project < Sequel::Model
  one_to_many :permissions

  PROJECT_NAME_MATCH=/(?!pg_)[a-z][a-z0-9]*(_[a-z][a-z0-9]*)*/

  def self.valid_name?(project_name)
    project_name =~ /\A#{PROJECT_NAME_MATCH.source}\Z/
  end
end
