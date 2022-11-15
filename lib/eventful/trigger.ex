defmodule Eventful.Trigger do
  @moduledoc """
  Handles the triggering of events

  You can define a trigger in the following way

      defmodule MyApp.Post.Triggers do
        use Eventful.Trigger
        
        alias MyApp.Post
        
        Post
        |> trigger([currently: "published"], fn event, post -> 
          # add your code here.
        end)
      end
  """

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

  @doc """
  The trigger macro function allows you to define a trigger in your trigger module

      Post
      |> trigger([currently: "published"], fn event, post -> 
        # add your code here.
      end)
  """
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
