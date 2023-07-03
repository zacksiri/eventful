defmodule Eventful.Test.Model.Event do
  alias Eventful.Test.{
    Model,
    Actor
  }

  use Eventful,
    parent: {:model, Model},
    actor: {:actor, Actor}

  handle(:transitions, using: Model.Transitions)
  handle(:publishings, using: Model.Publishings)
end

defimpl Eventful.Transit, for: Eventful.Test.Model do
  alias Eventful.Test.Model.Event

  def perform(model, actor, event_name, options \\ []) do
    comment = Keyword.get(options, :comment)
    parameters = Keyword.get(options, :parameters, %{})
    domain = Keyword.get(options, :domain, "transitions")

    Event.handle(model, actor, %{
      domain: domain,
      name: event_name,
      comment: comment,
      parameters: parameters
    })
  end
end
