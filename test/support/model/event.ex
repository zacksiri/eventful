defmodule Eventful.Test.Model.Event do
  alias Eventful.Test.{
    Model,
    Actor
  }

  use Eventful,
    parent: {:model, Model},
    actor: {:actor, Actor}

  handle(:transitions, using: Model.Transitions)
end
