defmodule Eventful.Transitable do
  defmacro __using__(_options) do
    quote do
      Module.register_attribute(__MODULE__, :governors, accumulate: true)

      @before_compile {unquote(__MODULE__), :__before_compile__}

      import Eventful.Transitable
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def governors(), do: @governors

      def state_changeset(%_{} = resource, attrs) do
        fields = Enum.map(@governors, fn g -> g.governs end)

        changeset = cast(resource, attrs, fields)

        @governors
        |> Enum.reduce(changeset, fn g, acc ->
          validate_inclusion(acc, g.governs, g.module.valid_states())
        end)
      end
    end
  end

  defmacro governs(module, field, options) do
    on = Keyword.fetch!(options, :on)

    quote do
      @governors %{
        module: unquote(module),
        governs: unquote(field),
        via: unquote(on)
      }
    end
  end
end
