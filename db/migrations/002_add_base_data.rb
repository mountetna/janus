Sequel.migration do

  up do

    self[:projects].insert(

      :project_name=> 'administration'
    )

    self[:users].insert(

      :email=> '<%= @first_user_email %>', 
      :first_name=> '<%= @first_user_first_name %>',
      :last_name=> '<%= @first_user_last_name %>',
      :pass_hash=> '<%= @first_user_pass_hash %>'
    )

    users = self[:users].where(:email=> '<%= @first_user_email %>').all
    user_id = users[0][:id]

    projects = self[:projects].where(:project_name=> 'administration').all
    project_id = projects[0][:id]

    self[:permissions].insert(

      :user_id=> user_id,
      :project_id=> project_id,
      :role=> 'administrator'
    )

    self[:apps].multi_insert([
      { 
        :app_key=> '<%= @janus_app_key %>', 
        :app_name=> 'janus'
      },
      {

        :app_key=> '<%= @metis_app_key %>',
        :app_name=> 'metis'
      },
      {

        :app_key=> '<%= @magma_app_key %>',
        :app_name=> 'magma'
      },
      {

        :app_key=> '<%= @timur_app_key %>',
        :app_name=> 'timur'
      }
    ])    
  end

  down do

    self[:logs].truncate
    self[:permissions].truncate
    self[:users].truncate
    self[:projects].truncate
    self[:projects].truncate
  end
end