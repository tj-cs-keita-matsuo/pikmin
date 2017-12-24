defmodule Pikmin.Supervisor do
  use Supervisor

  def start_link() do
    result = { :ok, pid } = Supervisor.start_link(__MODULE__, [])
    start_workers(pid)
    result
  end

  def start_workers(parent) do
    Supervisor.start_child(parent, worker(Pikmin.State, []))
    Supervisor.start_child(parent, worker(Pikmin.Scheduler, []))
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end
