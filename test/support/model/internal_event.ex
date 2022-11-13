defmodule Eventful.Test.Model.InternalEvent do
  alias Eventful.Test.{
    Model,
    Actor
  }

  use Eventful,
    parent: {:model, Model},
    actor: {:actor, Actor}

  handle(:internal_transitions, using: Model.InternalTransitions)
end
