defmodule Eventful do
  @moduledoc """
  This is the main Eventful module.
  
  ## Getting started

  Eventful makes it easy to define your state machines on a given field on your schema.

  You can even have multiple state machines on a single schema.

  Let's define the `Event` module.

      defmodule MyApp.Post.Event do
        alias MyApp.{
          Post,
          User
        }
        
        use Eventful,
          parent: {:post, Post},
          actor: {:user, User}
          
        handle(:transitions, using: Post.Transitions)
      end
      
  You will need to define a `Transitions` module for `MyApp.Post` 

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

  In this example we're defining `Transitions` on `:current_state`. Events will be stored using the `Event` schema.

      defmodule MyApp.Post do
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
  """

  defmacro __using__(options) do
    caller = __CALLER__.module
    binary_id = Keyword.get(options, :binary_id)
    {parent_relation, parent_module} = Keyword.get(options, :parent)
    {actor_relation, actor_module} = Keyword.get(options, :actor)

    table_name =
      Keyword.get(options, :table_name) || "#{parent_relation}_events"

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Eventful

      if unquote(binary_id) do
        @primary_key {:id, :binary_id, autogenerate: true}
        @foreign_key_type :binary_id
      end

      schema "#{unquote(table_name)}" do
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
        |> validate_required([
          :name,
          :domain,
          unquote(parent_relation),
          unquote(actor_relation)
        ])
      end

      def with_metadata(
            %{changes: changes} = resource_changeset,
            actor,
            resource,
            %{name: name, domain: domain} = params
          ) do
        event = %unquote(caller){
          unquote(actor_relation) => actor,
          unquote(parent_relation) => resource
        }

        {resource_changeset,
         changeset(event, %{
           domain: domain,
           name: name,
           metadata: Eventful.Metadata.build(resource, changes, params)
         })}
      end
    end
  end

  @doc """
  You can use the handle function to define the handler for a given domain:

      defmodule MyApp.Post.Event do
        alias MyApp.{
          Post,
          User
        }
        
        use Eventful,
          parent: {:post, Post},
          actor: {:user, User}
          
        handle(:transitions, using: Post.Transitions)
        handle(:visibilities, using: Post.Visibilities)
      end
  """
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
