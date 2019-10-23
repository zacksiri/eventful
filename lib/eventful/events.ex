defmodule Eventful.Events do
  @moduledoc """
  Sets up Event Tracking Schema
  """

  defmacro __using__(options) do
    caller = __CALLER__.module
    {parent_relation, parent_module} = Keyword.get(options, :parent)
    {actor_relation, actor_module} = Keyword.get(options, :actor)

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Eventful.Events

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      schema "#{unquote(parent_relation)}_events" do
        belongs_to(unquote(parent_relation), unquote(parent_module))
        belongs_to(unquote(actor_relation), unquote(actor_module))

        field(:domain, :string)
        field(:metadata, :map, default: %{})
        field(:name, :string)

        timestamps(type: :utc_datetime_usec)
      end

      @doc false
      def changeset(%unquote(caller){} = event, attrs) do
        event
        |> cast(attrs, [:name, :domain, :metadata])
        |> cast_assoc(unquote(parent_relation))
        |> cast_assoc(unquote(actor_relation))
        |> validate_required([:name, :domain, unquote(parent_relation), unquote(actor_relation)])
      end

      def with_metadata(
            %{changes: changes} = resource_changeset,
            actor,
            resource,
            %{name: name, domain: domain} = _params
          ) do
        event = %unquote(caller){
          unquote(actor_relation) => actor,
          unquote(parent_relation) => resource
        }

        {resource_changeset,
         changeset(event, %{
           domain: domain,
           name: name,
           metadata:
             Enum.reduce(changes, %{}, fn {key, value}, acc ->
               Map.merge(acc, %{
                 key => %{from: Map.get(resource, key), to: value}
               })
             end)
         })}
      end
    end
  end

  defmacro handle(domain, options) do
    using = Keyword.get(options, :using)
    string_domain = Atom.to_string(domain)

    quote do
      def handle(
            resource,
            user,
            %{domain: unquote(string_domain)} = event_params
          ) do
        unquote(using).call(user, resource, event_params)
      rescue
        FunctionClauseError -> {:error, :invalid_transition_event}
      end
    end
  end
end
