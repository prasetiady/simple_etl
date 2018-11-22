defmodule SimpleEtl.Repo.Migrations.PopulateMyTable do
  use Ecto.Migration

  def up do
    1..1000 |> Enum.each(fn _ -> insert_100_rows() end)
  end
  
  def down do
    execute "TRUNCATE TABLE my_table"
  end
  
  defp insert_100_rows do
    values = 1..99 |> Enum.reduce("(now(), now())", fn _, values -> values <> ",(now(), now())" end)
    
    query = "INSERT INTO my_table (inserted_at, updated_at) VALUES #{values}"
    
    Ecto.Adapters.SQL.query!(SimpleEtl.Repo, query)
  end
end
