defmodule Eventful.Test.Model do
  @moduledoc false

  use Eventful.Transitable

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__.Transitions
  alias __MODULE__.Event
  
  alias __MODULE__.InternalTransitions
  alias __MODULE__.InternalEvent

  Transitions
  |> governs(:current_state, on: Event)
  
  InternalTransitions
  |> governs(:internal_state, on: InternalEvent)

  schema "models" do
    field(:current_state, :string, default: "created")
    field(:internal_state, :string, default: "created")

    has_many :events, __MODULE__.Event
  end

  @doc false
  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [])
  end
end
