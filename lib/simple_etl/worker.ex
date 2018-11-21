defmodule SimpleEtl.Worker do
  use GenServer

  def start(first_id, last_id, rate) do
    GenServer.start(__MODULE__, {first_id, last_id, rate})
  end

  def init({first_id, last_id, rate}) do
    GenServer.cast(self(), :run_job)
    {:ok, {first_id, last_id, rate}}
  end

  def handle_cast(:run_job, {first_id, last_id, rate}) do
    random_terminator()
    current_last_id = min(last_id, first_id + rate)

    query = "INSERT INTO my_new_table (SELECT * FROM my_table WHERE id >= $1 AND id <= $2)"
    Ecto.Adapters.SQL.query!(SimpleEtl.Repo, query, [first_id, current_last_id])

    if current_last_id < last_id do
      GenServer.cast(self(), :run_job)
      {:noreply, {current_last_id + 1, last_id, rate}}
    else
      {:stop, :normal, nil}
    end
  rescue
    _ -> {:stop, :die, nil}
  end

  defp random_terminator do
    if :rand.uniform(100) == 1 do
      raise "ouch"
    end
  end
end
