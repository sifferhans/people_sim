defmodule PeopleSim.SimulationSupervisor do
  use Supervisor
  alias PeopleSim.Person

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    # Generate initial people
    children =
      Enum.map(1..100, fn i ->
        %{
          id: :"person_#{i}",
          start: {Person, :start_link, [%{name: generate_name()}]},
          restart: :transient
        }
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  # Add a new person to the simulation
  def add_person(name) do
    spec = %{
      id: :"person_#{System.unique_integer([:positive])}",
      start: {Person, :start_link, [%{name: name}]},
      restart: :permanent
    }

    Supervisor.start_child(__MODULE__, spec)
  end

  defp generate_name do
    first_names = [
      "James",
      "Mary",
      "John",
      "Patricia",
      "Robert",
      "Jennifer",
      "Michael",
      "Linda",
      "William",
      "Elizabeth"
    ]

    last_names = [
      "Smith",
      "Johnson",
      "Williams",
      "Brown",
      "Jones",
      "Miller",
      "Davis",
      "Garcia",
      "Rodriguez",
      "Wilson"
    ]

    "#{Enum.random(first_names)} #{Enum.random(last_names)}"
  end
end
