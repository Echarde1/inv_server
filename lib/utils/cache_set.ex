defmodule Cache.Set do
  use GenServer

  def new() do
    {:ok, pid} = GenServer.start_link(__MODULE__, MapSet.new())
    pid
  end

  @impl GenServer
  def init(set) do
    {:ok, set}
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add, entry})
  end

  def get_entries(pid) do
    GenServer.call(pid, :get)
  end

  @impl GenServer
  def handle_cast({:add, entry}, set) do
    new_set = MapSet.put(set, entry)
    {:noreply, new_set}
  end

  @impl GenServer
  def handle_call(:get, _, set), do: {:reply, set, set}

end