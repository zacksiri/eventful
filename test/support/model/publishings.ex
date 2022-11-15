defmodule Eventful.Test.Model.Publishings do
  @moduledoc false

  alias Eventful.Test.Model

  @behaviour Eventful.Handler

  use Eventful.Transition,
    repo: Eventful.Test.Repo,
    eventful_state: :publish_state

  Model
  |> transition(
    [from: "draft", to: "published", via: "publish"],
    fn changes -> transit(changes) end
  )
end
