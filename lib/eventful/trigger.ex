defmodule Eventful.Trigger do
  defmacro __using__(options \\ []) do
    quote do
      import Eventful.Trigger

      @eventful_state Keyword.get(
                        unquote(options),
                        :eventful_state,
                        :current_state
                      )
    end
  end

  defmacro trigger(module, options, fun) do
    current_state = Keyword.get(options, :currently)

    quote do
      def call(_repo, %{
            event: %unquote(module).Event{} = event,
            resource:
              %unquote(module){@eventful_state => unquote(current_state)} =
                resource
          }),
          do: unquote(fun).(event, resource)
    end
  end
end
