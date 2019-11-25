defmodule Eventful.Test.Model do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @valid_states ~w(
    created
    processing
    approved
  )

  schema "models" do
    field(:current_state, :string, default: "created")

    has_many :events, __MODULE__.Event
  end

  @doc false
  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [:current_state])
    |> validate_required([:current_state])
    |> validate_inclusion(:current_state, @valid_states)
  end
end
