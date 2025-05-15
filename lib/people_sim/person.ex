defmodule PeopleSim.Person do
  use GenServer
  alias PeopleSim.Activities

  defstruct [:id, :name, :location, :status, :activity, :needs]

  # Start a new person process
  def start_link(attrs) do
    GenServer.start_link(__MODULE__, attrs)
  end

  # Initialize person state
  def init(attrs) do
    # Schedule the first activity update
    schedule_activity_update()

    initial_state = %__MODULE__{
      id: attrs[:id] || System.unique_integer([:positive]),
      name: attrs[:name],
      location: "home",
      status: "sleeping",
      activity: nil,
      needs: %{
        energy: 100,
        hunger: 0,
        social: 0
      }
    }

    {:ok, initial_state}
  end

  # Update person's activity based on time, needs, etc.
  def handle_info(:update_activity, state) do
    # Determine new activity based on current state, time, needs
    {new_activity, new_location, new_status} = Activities.determine_next_activity(state)

    # Update needs based on current activity
    updated_needs = update_needs(state.needs, state.activity)

    if updated_needs.energy <= 0 do
      send(self(), :kill)
    end

    new_state = %{
      state
      | activity: new_activity,
        location: new_location,
        status: new_status,
        needs: updated_needs
    }

    # Broadcast the state change
    PeopleSim.PubSub.broadcast_update(new_state)

    # Schedule the next update
    schedule_activity_update()

    {:noreply, new_state}
  end

  def handle_info(:kill, state) do
    PeopleSim.PubSub.broadcast_delete(state)
    {:stop, :normal, state}
  end

  # Private functions
  defp schedule_activity_update do
    # Update every 5-15 seconds (randomized to make simulation more natural)
    update_interval = :rand.uniform(1_000) + 100
    Process.send_after(self(), :update_activity, update_interval)
  end

  defp update_needs(needs, activity) do
    # Update needs based on current activity
    # (simplified example)
    case activity do
      "sleeping" ->
        %{needs | energy: min(needs.energy + 5, 100), hunger: needs.hunger + 1}

      "eating" ->
        %{needs | hunger: max(needs.hunger - 10, 0)}

      "working" ->
        %{needs | energy: max(needs.energy - 3, 0), hunger: needs.hunger + 2}

      "socializing" ->
        %{needs | social: min(needs.social + 5, 100), energy: max(needs.energy - 1, 0)}

      _ ->
        needs
    end
  end
end
