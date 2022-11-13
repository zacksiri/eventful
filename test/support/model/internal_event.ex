defmodule Eventful.Test.Model.InternalEvent do
  alias Eventful.Test.{
    Model,
    User
  }

  use Eventful,
    parent: {:model, Model},
    actor: {:user, User},
    table_name: "model_internal_events"

  handle(:internal_transitions, using: Model.InternalTransitions)
end
