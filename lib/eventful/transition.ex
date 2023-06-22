defmodule Eventful.Transition do
  defstruct [:event, :resource, :trigger]

  @moduledoc """
  This module providers the macros for building the transition modules

  Here is an example:

      defmodule MyApp.Post.Transitions do
        use Eventful.Transition, repo: MyApp.Repo

        @behaviour Eventful.Handler

        alias MyApp.Post

        Post
        |> transition([from: "created", to: "published", via: "publish", fn changes ->
          transit(changes)
        end)

        Post
        |> transition([from: "created", to: "deleted", via: "delete", fn changes ->
          transit(changes)
        end)
      end

  You can also define multiple state machines for example for a given `post` you can also have a machine for your `:visibility` field

      defmodule MyApp.Post.Visibilities do
        use Eventful.Transition, repo: MyApp.Repo, eventful_state: :visibility

        @behaviour Eventful.Handler

        alias MyApp.Post

        Post
        |> transition([from: "private", to: "public", via: "publicize", fn changes ->
          transit(changes)
        end)

        Post
        |> transition([from: "public", to: "private", via: "privatize", fn changes ->
          transit(changes)
        end)
      end
  """
  defmacro __using__(options \\ []) do
    repo = Keyword.get(options, :repo)
    timeout = Keyword.get(options, :timeout, 15_000)

    quote do
      Module.register_attribute(__MODULE__, :transitions, accumulate: true)

      @before_compile {unquote(__MODULE__), :__before_compile__}

      alias Ecto.Multi

      import Eventful.Transition

      @eventful_state Keyword.get(
                        unquote(options),
                        :eventful_state,
                        :current_state
                      )

      @spec call(struct, map(), map()) ::
              {:ok, %Eventful.Transition{}} | {:error, %Eventful.Error{}}

      @spec transit({Ecto.Changeset.t(), Ecto.Changeset.t()}) ::
              {:ok, %Eventful.Transition{}} | {:error, %Eventful.Error{}}
      def transit({changeset, event_changeset}) do
        Multi.new()
        |> Multi.insert(:event, event_changeset)
        |> Multi.update(:resource, changeset)
        |> unquote(repo).transaction(timeout: unquote(timeout))
        |> case do
          {:ok, transaction} ->
            {:ok,
             %Eventful.Transition{
               event: transaction.event,
               resource: transaction.resource
             }}

          {:error, value} ->
            {:error, %Eventful.Error{code: :transaction, data: value}}

          {:error, :resource, message, data} ->
            {:error,
             %Eventful.Error{
               code: :resource,
               message: message,
               data: data
             }}

          {:error, :event, message, data} ->
            {:error,
             %Eventful.Error{
               code: :event,
               message: message,
               data: data
             }}
        end
      end

      @spec transit({Ecto.Changeset.t(), Ecto.Changeset.t()}, atom) ::
              {:ok, %Eventful.Transition{}} | {:error, %Eventful.Error{}}

      def transit({changeset, event_changeset}, module) do
        Multi.new()
        |> Multi.insert(:event, event_changeset)
        |> Multi.update(:resource, changeset)
        |> Multi.run(:trigger, module, :call, [])
        |> unquote(repo).transaction(timeout: unquote(timeout))
        |> case do
          {:ok, transaction} ->
            {:ok,
             %Eventful.Transition{
               event: transaction.event,
               resource: transaction.resource,
               trigger: transaction.trigger
             }}

          {:error, value} ->
            {:error, %Eventful.Error{code: :transaction, data: value}}

          {:error, :trigger, message, data} ->
            {:error,
             %Eventful.Error{code: :trigger, message: message, data: data}}

          {:error, :resource, message, data} ->
            {:error,
             %Eventful.Error{code: :resource, message: message, data: data}}

          {:error, :event, message, data} ->
            {:error,
             %Eventful.Error{code: :event, message: message, data: data}}
        end
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def all, do: @transitions

      def valid_states do
        @transitions
        |> Enum.map(fn t -> [t.from, t.to] end)
        |> List.flatten()
        |> Enum.uniq()
      end

      def possible_events(resource) do
        Enum.filter(@transitions, fn state ->
          state.from == Map.get(resource, @eventful_state)
        end)
      end
    end
  end

  @doc """
  The transition macro allows you to define the state machine for your transitions

      Post
      |> transition([from: "created", to: "published", via: "publish", fn changes ->
        transit(changes)
      end)
  """
  defmacro transition(module, options, expression) do
    caller_module = __CALLER__.module

    caller =
      caller_module
      |> Macro.underscore()
      |> String.split("/")
      |> List.last()

    current_state = Keyword.get(options, :from)
    to_state = Keyword.get(options, :to)
    event_name = Keyword.get(options, :via)

    quote do
      @transitions %{
        from: unquote(current_state),
        to: unquote(to_state),
        via: unquote(event_name)
      }

      def call(
            actor,
            %unquote(module){@eventful_state => unquote(current_state)} =
              resource,
            %{domain: unquote(caller), name: unquote(event_name)} = params
          ) do
        governor =
          Enum.find(unquote(module).governors(), fn governor ->
            governor.module == unquote(caller_module)
          end)

        resource
        |> unquote(module).state_changeset(%{
          @eventful_state => unquote(to_state)
        })
        |> governor.via.with_metadata(actor, resource, params)
        |> unquote(expression).()
        |> case do
          {:ok, %Eventful.Transition{} = transition} ->
            {:ok, transition}

          {:error, %Eventful.Error{} = error} ->
            {:error, error}

          {:error, message} ->
            {:error, %Eventful.Error{code: :transit, message: message}}

          _ ->
            raise Eventful.Exception.UnexpectedReturnValue
        end
      end
    end
  end
end
