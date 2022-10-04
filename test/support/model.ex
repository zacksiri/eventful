defmodule Eventful.Test.Model do
  @moduledoc false

  use Eventful.Transitable, transitions_module: __MODULE__.Transitions

  use Ecto.Schema

  import Ecto.Changeset

  schema "models" do
    field(:current_state, :string, default: "created")

    has_many :events, __MODULE__.Event
  end

  @doc false
  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [])
  end
end
