defmodule Eventful.Transitable do
  defmacro __using__(options) do
    field = Keyword.get(options, :eventful_state, :current_state)
    transitions_module = Keyword.fetch!(options, :transitions_module)

    quote do
      def state_changeset(%_{} = resource, attrs) do
        resource
        |> cast(attrs, [unquote(field)])
        |> validate_required(unquote(field))
        |> validate_inclusion(
          unquote(field),
          unquote(transitions_module).valid_states()
        )
      end
    end
  end
end
