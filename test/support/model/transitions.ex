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

  Model
  |> transition(
    [from: "processing", to: "rejected", via: "reject"],
    fn changes -> transit(changes, Model.Triggers) end
  )

  Model
  |> transition(
    [from: "processing", to: "paused", via: "pause"],
    fn {resource_changeset, _event_changeset} = changes ->
      if resource_changeset.changes.current_state_version == 2 do
        {:error, "Cannot pause a model with version 2"}
      else
        transit(changes)
      end
    end
  )
end
