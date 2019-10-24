defmodule Eventful.Test.Actor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "actors" do
    field :name, :string
  end

  @doc false
  def changeset(actor, attrs \\ %{}) do
    actor
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
