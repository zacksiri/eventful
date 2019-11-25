defmodule Eventful.Test.Model.Transitions do
  @moduledoc false

  alias Eventful.Test.Model

  @behaviour Eventful.Handler

  use Eventful.Transition, repo: Eventful.Test.Repo

  Model
  |> transition(
    [from: "created", to: "processing", via: "process"],
    fn changes -> transit(changes) end
  )

  Model
  |> transition(
    [from: "processing", to: "approved", via: "approve"],
    fn changes -> transit(changes, Model.Triggers) end
  )
end
