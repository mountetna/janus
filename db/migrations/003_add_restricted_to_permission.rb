Sequel.migration do 
  change do
    alter_table(:permissions) do
      add_column :restricted, String
    end
  end
end
