defmodule PeopleSim.PubSub do
  @topic "people_updates"

  def subscribe do
    Phoenix.PubSub.subscribe(PeopleSim.PubSub, @topic)
  end

  def broadcast_update(person) do
    Phoenix.PubSub.broadcast(
      PeopleSim.PubSub,
      @topic,
      {:person_update, person}
    )
  end

  def broadcast_delete(person) do
    Phoenix.PubSub.broadcast(
      PeopleSim.PubSub,
      @topic,
      {:person_delete, person}
    )
  end
end
