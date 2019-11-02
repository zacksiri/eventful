defmodule Eventful.Metadata do
  @spec build(any, any, map) :: %{:changes => any, optional(:comment) => any}
  def build(resource, changes, params) do
    params
    |> starting_map()
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
    if Map.has_key?(params, :comment),
      do: %{comment: params.comment},
      else: %{}
  end
end
