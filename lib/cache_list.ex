defmodule Cache.List do
  use GenServer

  def new() do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    pid
  end

  @impl GenServer
  def init(list) do
    {:ok, list}
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add, entry})
  end

  def get_entries(pid) do
    GenServer.call(pid, :get)
  end

  @impl GenServer
  def handle_cast({:add, entry}, list) do
    new_list = [entry | list]
    {:noreply, new_list}
  end

  @impl GenServer
  def handle_call(:get, _, list), do: {:reply, list, list}

end