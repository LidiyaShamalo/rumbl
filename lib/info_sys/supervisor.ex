defmodule InfoSys.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      InfoSys.Cache,
      {Task.Supervisor, name: InfoSys.TaskSupervisor},
      
      Supervisor.child_spec({InfoSys.Counter, 15}, id: :long),
      Supervisor.child_spec({InfoSys.Counter, 5}, id: :short),
      Supervisor.child_spec({InfoSys.Counter, 10}, id: :medium),
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

end
