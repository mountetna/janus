Sequel.migration do
  change do
    alter_table(:projects) do
      add_column :resource, TrueClass, default: false
    end
  end
end
