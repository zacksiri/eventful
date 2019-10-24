defmodule Eventful.Transition do
  @moduledoc """
  Providers Macro for Tracking Event with Update
  """
  defmacro __using__(options \\ []) do
    repo = Keyword.get(options, :repo)

    quote do
      alias Ecto.Multi

      import Eventful.Transition

      @eventful_state Keyword.get(unquote(options), :eventful_state, :current_state)

      @spec call(struct, map(), map()) ::
              {:ok, any}
              | {:error, any}
              | {:error, atom, struct}
              | {:error, any, any, map}

      @spec transit({Ecto.Changeset.t(), Ecto.Changeset.t()}) ::
              {:ok, any()}
              | {:error, any()}
              | {:error, Ecto.Multi.name(), any(), %{required(Ecto.Multi.name()) => any()}}
      def transit({changeset, event_changeset}) do
        Multi.new()
        |> Multi.insert(:event, event_changeset)
        |> Multi.update(:resource, changeset)
        |> unquote(repo).transaction()
      end

      @spec transit({Ecto.Changeset.t(), Ecto.Changeset.t()}, atom) ::
              {:ok, any()}
              | {:error, any()}
              | {:error, Ecto.Multi.name(), any(), %{required(Ecto.Multi.name()) => any()}}
      def transit({changeset, event_changeset}, module) do
        Multi.new()
        |> Multi.insert(:event, event_changeset)
        |> Multi.update(:resource, changeset)
        |> Multi.run(:trigger, module, :call, [])
        |> unquote(repo).transaction()
      end

      defp guard_transition(_resource, _actor, _event_name),
        do: {:ok, :passed}

      defoverridable guard_transition: 3
    end
  end

  defmacro transition(module, options, expression) do
    caller =
      __CALLER__.module
      |> Macro.underscore()
      |> String.split("/")
      |> List.last()

    current_state = Keyword.get(options, :from)
    to_state = Keyword.get(options, :to)
    event_name = Keyword.get(options, :via)

    quote do
      def call(
            actor,
            %unquote(module){@eventful_state => unquote(current_state)} = resource,
            %{domain: unquote(caller), name: unquote(event_name)} = params
          ) do
        with {:ok, :passed} <-
               guard_transition(resource, actor, unquote(event_name)) do
          resource
          |> unquote(module).changeset(%{@eventful_state => unquote(to_state)})
          |> unquote(module).Event.with_metadata(actor, resource, params)
          |> unquote(expression).()
        else
          _ -> {:error, :guard_failed, resource}
        end
      end
    end
  end
end