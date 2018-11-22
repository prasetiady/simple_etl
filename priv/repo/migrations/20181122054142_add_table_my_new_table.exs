defmodule SimpleEtl.Repo.Migrations.AddTableMyNewTable do
  use Ecto.Migration

  def up do
    create table(:my_new_table) do
      # :id => primary key, default
      timestamps() 
    end
  end
  
  def down do
    drop table(:my_new_table)
  end
end
