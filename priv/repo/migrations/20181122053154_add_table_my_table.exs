defmodule SimpleEtl.Repo.Migrations.AddTableMyTable do
  use Ecto.Migration
  
  def up do
    create table(:my_table) do
      # :id => primary key, default
      timestamps() 
    end
  end
  
  def down do
    drop table(:my_table)
  end
end
