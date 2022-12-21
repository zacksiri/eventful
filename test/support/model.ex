defmodule Eventful.Test.Model do
  @moduledoc false

  use Eventful.Transitable

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__.Transitions
  alias __MODULE__.Publishings
  alias __MODULE__.Event

  alias __MODULE__.InternalTransitions
  alias __MODULE__.InternalEvent

  Transitions
  |> governs(:current_state, on: Event, lock: :current_state_versions)

  Publishings
  |> governs(:publish_state, on: Event)

  InternalTransitions
  |> governs(:internal_state, on: InternalEvent)

  schema "models" do
    field(:publish_state, :string, default: "draft")

    field(:current_state, :string, default: "created")
    field(:current_state_versions, :integer, default: 0)

    field(:internal_state, :string, default: "created")

    has_many :events, __MODULE__.Event
  end

  @doc false
  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [])
  end
end
