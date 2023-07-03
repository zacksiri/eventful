defmodule Eventful.Metadata do
  @moduledoc """
  This modules handles processing of the metadata for the event
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :changes, :map, default: %{}
    field :comment, :string
    field :parameters, :map, default: %{}
  end

  @doc false
  def changeset(metadata, params) do
    metadata
    |> cast(params, [:changes, :comment, :parameters])
  end

  @spec build(any, any, map) :: %{:changes => any, optional(:comment) => any}
  def build(resource, changes, params) do
    params
    |> maybe_merge(:comment)
    |> maybe_merge(:parameters)
    |> Map.merge(%{changes: changed_attributes(resource, changes)})
  end

  defp changed_attributes(resource, changes) do
    Enum.reduce(changes, %{}, fn {key, value}, acc ->
      Map.merge(acc, %{
        key => %{from: Map.get(resource, key), to: value}
      })
    end)
  end

  defp maybe_merge(params, key) do
    if Map.has_key?(params, key) && not is_nil(params[key]),
      do: Map.merge(params, %{key => params[key]}),
      else: params
  end
end
