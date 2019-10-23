defmodule Eventful.Trigger do
  defmacro __using__(_) do
    quote do
      import Station.Events.Trigger

      @state_field :current_state
    end
  end

  defmacro trigger(module, options, fun) do
    current_state = Keyword.get(options, :currently)

    quote do
      def call(_repo, %{
            event: %unquote(module).Event{} = event,
            resource: %unquote(module){@state_field => unquote(current_state)} = resource
          }),
          do: unquote(fun).(event, resource)
    end
  end
end
