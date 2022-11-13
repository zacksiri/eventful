defmodule Eventful.Transitable do
  @moduledoc """
  This module is the one you'll use to define your main schema which require the state machine. 
  
  For example imagine the following:
  
  defmodule Post do
    use Ecto.Schema
    import Ecto.Changeset
    
    schema "posts" do
      field :current_state, :string, default: "created"
    end
  end
  
  You can add a state machine like this assuming you've setup the `Event` module already:
  
  defmodule Post do
    use Ecto.Schema
    import Ecto.Changeset
    
    use Eventful.Transitable
    
    alias __MODULE__.Event
    alias __MODULE__.Transitions
    
    Transitions
    |> governs(:current_state, on: Event)
    
    schema "posts" do
      field :current_state, :string, default: "created"
    end
  end
  
  You can also setup multiple state machines with multiple fields:any()
  
  defmodule Post do
    use Ecto.Schema
    import Ecto.Changeset
    
    use Eventful.Transitable
    
    alias __MODULE__.Event
    alias __MODULE__.Transitions
    alias __MODULE__.Publishings
    
    Transitions
    |> governs(:current_state, on: Event)
    
    Publishings
    |> governs(:publish_state, on: Event)
    
    schema "posts" do
      field :current_state, :string, default: "created"
      field :publish_state, :string, default: "draft"
    end
  end
  """
  
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
