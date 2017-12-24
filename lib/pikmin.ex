defmodule Pikmin do
  use Application

  def start(_type, _args) do
    { :ok, _pid } = Pikmin.Supervisor.start_link()
  end
end
