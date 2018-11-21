defmodule SimpleEtl.ManagerTest do
  use ExUnit.Case

  setup_all :setup_sandbox

  test "should copy 100_000 rows from my_table to my_new_table" do
    assert get_my_new_table_count() == 0

    SimpleEtl.Manager.prepare_workers(100_000, 10)

    :ok = wait_till_all_worker_done()

    assert get_my_new_table_count() == 100_000
  end

  defp get_my_new_table_count do
    %{rows: [[count]]} =
      Ecto.Adapters.SQL.query!(SimpleEtl.Repo, "SELECT COUNT(id) FROM my_new_table")

    count
  end

  defp wait_till_all_worker_done do
    {_, _, worker_references} = SimpleEtl.Manager.get_state()

    if Enum.empty?(worker_references) do
      :ok
    else
      :timer.sleep(10)
      wait_till_all_worker_done()
    end
  end

  defp setup_sandbox(_context) do
    Ecto.Adapters.SQL.Sandbox.checkout(SimpleEtl.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(SimpleEtl.Repo, {:shared, self()})
  end
end
