defmodule PeopleSimWeb.SimulationLive do
  use PeopleSimWeb, :live_view
  alias PeopleSim.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe()
    end

    {:ok, stream(socket, :people, [])}
  end

  def handle_info({:person_delete, person}, socket) do
    {:noreply, stream_delete(socket, :people, person)}
  end

  def handle_info({:person_update, person}, socket) do
    {:noreply, stream_insert(socket, :people, person)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <h1 class="text-2xl font-bold my-4">People Simulation</h1>

      <div
        id="people"
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 text-sm"
        phx-update="stream"
      >
        <%= for {dom_id, person} <- @streams.people do %>
          <div
            id={dom_id}
            class={["border rounded-md p-4 shadow-sm", person.needs.energy <= 0 && "opacity-30"]}
          >
            <h3 class="font-bold">{person.name}</h3>
            <div class="mt-2">
              <div><span class="font-semibold">Status:</span> {person.status}</div>
              <div><span class="font-semibold">Location:</span> {person.location}</div>
              <div><span class="font-semibold">Activity:</span> {person.activity}</div>

              <div class="mt-2">
                <div class="flex items-center">
                  <span class="w-16">Energy:</span>
                  <div class="h-2 bg-gray-200 rounded-full flex-1">
                    <div
                      class="h-2 bg-green-500 rounded-full"
                      style={"width: #{person.needs.energy}%"}
                    >
                    </div>
                  </div>
                </div>

                <div class="flex items-center mt-1">
                  <span class="w-16">Hunger:</span>
                  <div class="h-2 bg-gray-200 rounded-full flex-1">
                    <div class="h-2 bg-red-500 rounded-full" style={"width: #{person.needs.hunger}%"}>
                    </div>
                  </div>
                </div>

                <div class="flex items-center mt-1">
                  <span class="w-16">Social:</span>
                  <div class="h-2 bg-gray-200 rounded-full flex-1">
                    <div class="h-2 bg-blue-500 rounded-full" style={"width: #{person.needs.social}%"}>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
