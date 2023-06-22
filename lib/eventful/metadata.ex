defmodule Eventful.Metadata do
  @moduledoc """
  This modules handles processing of the metadata for the event
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :changes, :map
    field :comment, :string
    field :parameters, :map
  end

  @doc false
  def changeset(metadata, params) do
    metadata
    |> cast(params, [:changes, :comment, :parameters])
  end

  @spec build(any, any, map) :: %{:changes => any, optional(:comment) => any}
  def build(resource, changes, params) do
    params
    |> starting_map()
    |> maybe_merge_parameters()
    |> Map.merge(%{changes: changed_attributes(resource, changes)})
  end

  defp changed_attributes(resource, changes) do
    Enum.reduce(changes, %{}, fn {key, value}, acc ->
      Map.merge(acc, %{
        key => %{from: Map.get(resource, key), to: value}
      })
    end)
  end

  defp starting_map(params) do
    if Map.has_key?(params, :comment) && not is_nil(params.comment),
      do: %{comment: params.comment},
      else: params
  end

  defp maybe_merge_parameters(params) do
    if Map.has_key?(params, :parameters) && not is_nil(params.parameters),
      do: Map.merge(params, %{parameters: params.parameters}),
      else: params
  end
end
