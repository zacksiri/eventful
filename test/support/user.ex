defmodule Eventful.Test.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
  end

  @doc false
  def changeset(actor, attrs \\ %{}) do
    actor
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
