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
      user_email: user.email
    }
  end

  def role_key
    privileged ? role[0].upcase : role[0]
  end

  def project_role
    [ role_key, project.project_name ]
  end
end
