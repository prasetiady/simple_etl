defmodule SimpleEtl.RepoTest do
  use ExUnit.Case

  setup_all :setup_sandbox

  describe "Repo" do
    test "db connection" do
      Ecto.Adapters.SQL.query!(SimpleEtl.Repo, """
        INSERT INTO my_new_table (SELECT * FROM my_table WHERE id >= 1 AND id <= 100)
      """)

      %{rows: [[count]]} =
        Ecto.Adapters.SQL.query!(SimpleEtl.Repo, """
          SELECT COUNT(id) FROM my_new_table
        """)

      assert count == 100
    end
  end

  defp setup_sandbox(_context) do
    Ecto.Adapters.SQL.Sandbox.checkout(SimpleEtl.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(SimpleEtl.Repo, {:shared, self()})
  end
end
