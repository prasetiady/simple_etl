defmodule SimpleEtl.Manager do
  use GenServer

  def start_link() do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def prepare_workers(last_id, worker_count) do
    GenServer.cast(__MODULE__, {:prepare_workers, last_id, worker_count})
  end

  def init(_) do
    last_id = 0
    worker_count = 0
    worker_references = %{}
    {:ok, {last_id, worker_count, worker_references}}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:prepare_workers, last_id, worker_count}, _) do
    rows_per_worker = div(last_id, worker_count)

    worker_references =
      1..worker_count
      |> Enum.reduce(%{}, fn worker_number, worker_references ->
        worker_last_id = worker_number * rows_per_worker
        worker_first_id = worker_last_id - rows_per_worker + 1

        {:ok, worker_pid} = SimpleEtl.Worker.start(worker_first_id, worker_last_id, 100)
        reference = Process.monitor(worker_pid)

        worker_references |> Map.put(reference, worker_number)
      end)

    {:noreply, {last_id, worker_count, worker_references}}
  end

  def handle_info(
        {:DOWN, reference, :process, _pid, reason},
        {last_id, worker_count, worker_references}
      ) do
    worker_number = worker_references |> Map.get(reference)
    worker_references = worker_references |> Map.delete(reference)

    worker_references =
      case reason do
        :normal ->
          IO.puts("worker #{worker_number} done")
          worker_references

        _ ->
          IO.puts("worker #{worker_number} die")
          {:ok, worker_pid} = restart_worker(last_id, worker_count, worker_number)
          reference = Process.monitor(worker_pid)
          worker_references |> Map.put(reference, worker_number)
      end

    {:noreply, {last_id, worker_count, worker_references}}
  end

  defp restart_worker(last_id, worker_count, worker_number) do
    rows_per_worker = div(last_id, worker_count)
    worker_last_id = worker_number * rows_per_worker
    worker_first_id = worker_last_id - rows_per_worker + 1

    last_inserted_id = get_last_inserted_id(worker_first_id, worker_last_id)

    SimpleEtl.Worker.start(last_inserted_id, worker_last_id, 100)
  end

  defp get_last_inserted_id(worker_first_id, worker_last_id) do
    query = "SELECT id FROM my_new_table WHERE id >= $1 AND id <= $2 ORDER BY id DESC LIMIT 1"

    %{rows: rows} =
      Ecto.Adapters.SQL.query!(SimpleEtl.Repo, query, [worker_first_id, worker_last_id])

    if Enum.empty?(rows) do
      worker_first_id
    else
      [[last_inserted_id]] = rows
      last_inserted_id + 1
    end
  end
end
