Sequel.migration do
  change do
    alter_table(:projects) do
      drop_column :group_id
    end
    drop_table(:apps)
    drop_table(:groups)
  end
end
