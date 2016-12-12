Sequel.migration do

  up do

    self[:groups].multi_insert([

      { :group_name=> 'administration' },
      { :group_name=> 'cip' },
      { :group_name=> 'ipi' }
    ])

    self[:projects].insert(

      :project_name=> 'administration',
      :group_id=> 1
    )

    self[:users].insert(

      :email=> 'jason.cater@ucsf.edu', 
      :first_name=> 'Jason',
      :last_name=> 'Cater',
      :pass_hash=> '8e731f52971566a8523a3ac61f5a4af18bb00e671a192c1448f02b2abe863f5e'
    )

    users = self[:users].where(:email=> 'jason.cater@ucsf.edu').all
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
        :app_key=> 'DGk8Of4gVY3LJy5r8SEwJzDnIUWXw4afa9b7sS6T29Q', 
        :app_name=> 'janus'
      },
      {

        :app_key=> 'fO0sQz1BeLKbAPBSzyMjm6IFzyO41UNaDl94d3YZ7yU',
        :app_name=> 'metis'
      },
      {

        :app_key=> 'w7D8v2WmnRtcG9p2VDwnYcwOgyvl45SJ1UAjSGOCPPg',
        :app_name=> 'magma'
      },
      {

        :app_key=> 'qPg2fbe7rOCzxr7odfsarccN8psbQ1ltJpTh42Mzbz0',
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