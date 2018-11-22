defmodule SimpleEtl.WorkerTest do
  use ExUnit.Case

  setup_all :setup_sandbox

  test "should copy 1000 rows from my_table to my_new_table" do
    assert get_my_new_table_count() == 0

    {:ok, worker_pid} = SimpleEtl.Worker.start(1, 1000, 10)

    :ok = wait_till_worker_die(worker_pid)

    assert get_my_new_table_count() == 1000
  end

  defp get_my_new_table_count do
    %{rows: [[count]]} =
      Ecto.Adapters.SQL.query!(SimpleEtl.Repo, "SELECT COUNT(id) FROM my_new_table")

    count
  end

  defp wait_till_worker_die(worker_pid) do
    if Process.alive?(worker_pid) do
      :timer.sleep(10)
      wait_till_worker_die(worker_pid)
    else
      :ok
    end
  end

  defp setup_sandbox(_context) do
    Ecto.Adapters.SQL.Sandbox.checkout(SimpleEtl.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(SimpleEtl.Repo, {:shared, self()})
  end
end
