defmodule PeopleSim.Activities do
  # Determine the next activity based on person's state and time
  def determine_next_activity(person) do
    current_hour = Time.utc_now().hour

    cond do
      # Morning routine
      current_hour in 6..8 and person.status == "sleeping" ->
        {"morning routine", "home", "waking up"}

      # Work hours
      current_hour in 9..17 and person.location != "work" and weekday?() ->
        {"working", "work", "busy"}

      # Lunch break
      current_hour in 12..13 and person.location == "work" ->
        {"eating", "restaurant", "having lunch"}

      # Evening at home
      current_hour in 18..22 ->
        choose_evening_activity(person)

      # Sleep time
      current_hour in [23, 0, 1, 2, 3, 4, 5] ->
        {"sleeping", "home", "asleep"}

      # Default - free time
      true ->
        choose_random_activity(person)
    end
  end

  # Helper functions
  defp weekday? do
    day = Date.day_of_week(Date.utc_today())
    # Monday to Friday
    day in 1..5
  end

  defp choose_evening_activity(person) do
    activities = [
      {"watching TV", "home", "relaxing"},
      {"having dinner", "home", "eating"},
      {"reading", "home", "focused"},
      {"socializing", "bar", "chatting"},
      {"exercising", "gym", "active"}
    ]

    # Choose based on needs
    if person.needs.social < 30 do
      {"socializing", "bar", "chatting"}
    else
      Enum.random(activities)
    end
  end

  defp choose_random_activity(person) do
    activities = [
      {"shopping", "store", "browsing"},
      {"walking", "park", "enjoying outdoors"},
      {"coffee break", "cafe", "sipping coffee"},
      {"meeting friends", "cafe", "socializing"},
      {"browsing internet", person.location, "online"}
    ]

    Enum.random(activities)
  end
end
