defmodule Eventful.Transition do
  @moduledoc """
  Providers Macro for Tracking Event with Update
  """
  alias Station.Members.Employment

  defmacro __using__(_resource) do
    quote do
      alias Station.Repo
      alias Ecto.Multi

      import Station.Events.Transition

      @state_field :current_state

      @spec call(%Employment{}, map(), map()) ::
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
        |> Repo.transaction()
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
        |> Repo.transaction()
      end

      defp guard_transition(_resource, _employment, _event_name),
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
            %Employment{} = employment,
            %unquote(module){@state_field => unquote(current_state)} = resource,
            %{domain: unquote(caller), name: unquote(event_name)} = params
          ) do
        with {:ok, :passed} <-
               guard_transition(resource, employment, unquote(event_name)) do
          resource
          |> unquote(module).changeset(%{@state_field => unquote(to_state)})
          |> unquote(module).Event.with_metadata(employment, resource, params)
          |> unquote(expression).()
        else
          _ -> {:error, :guard_failed, resource}
        end
      end
    end
  end
end
