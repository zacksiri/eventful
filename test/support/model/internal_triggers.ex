defmodule Eventful.Test.Model.InternalTriggers do
  use Eventful.Trigger, eventful_state: :internal_state

  alias Eventful.Test.Model

  Model
  |> trigger([currently: "active"], fn _event, model ->
    {:ok, model}
  end)
end
