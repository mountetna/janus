Sequel.migration do 

  up do

    self[:users].insert(

      :email=> '<%= @first_user_email %>', 
      :first_name=> '<%= @first_user_first_name %>',
      :last_name=> '<%= @first_user_last_name %>',
      :pass_hash=> '<%= @first_user_pass_hash %>'
    )
  end

  down do

    # nil
  end
end