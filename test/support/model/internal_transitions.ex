defmodule Eventful.Test.Model.InternalTransitions do
  @moduledoc false

  alias Eventful.Test.Model

  @behaviour Eventful.Handler

  use Eventful.Transition,
    repo: Eventful.Test.Repo,
    eventful_state: :internal_state

  Model
  |> transition(
    [from: "created", to: "active", via: "activate"],
    fn changes -> transit(changes, Model.InternalTriggers) end
  )
end
