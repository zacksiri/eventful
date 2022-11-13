# Eventful

![](https://github.com/zacksiri/eventful/workflows/Elixir%20CI/badge.svg)

Eventful is a library for anyone who needs a trackable state machine. With transitions and triggers and guards.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `eventful` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eventful, "~> 2.0.0"}
  ]
end
```

### Current State

You will need to create a `:current_state` field in your model

```elixir
schema "posts" do
  field :current_state, :string, default: "draft"
end

# migration

alter table(:posts) do
  field :current_state, :string, default: "draft", null: false
end
```

### Event Schema

Generally your events table will be used to track events for a specific model you have. Let's assume that in this case we have `MyApp.Post` and `MyApp.User` as the authenticated user in our app.

We may create something like this.

```elixir
defmodule MyApp.Post.Event do
  alias MyApp.{
    Post,
    User
  }

  use Eventful,
    parent: {:post, Post},
    actor: {:user, User}
end
```

### Migration

Generate a migration file for your events like this.

```elixir
defmodule MyApp.Repo.Migrations.CreatePostEvents do
  use Ecto.Migration

  def change do
    create table(:post_events) do
      add(:name, :string, null: false)
      add(:domain, :string, null: false)
      add(:metadata, :map, default: "{}")

      add(
        :post_id,
        references(:posts, on_delete: :restrict),
        null: false
      )

      add(
        :user_id,
        references(:users, on_delete: :restrict),
        null: false
      )

      timestamps()
    end

    create(index(:post_events, [:post_id]))
    create(index(:post_events, [:user_id]))
  end
end
```

### Transitions

The next thing is defining a `Transitions` module

```elixir
defmodule MyApp.Post.Transitions do
  alias MyApp.Post

  @behaviour Eventful.Handler

  use Eventful.Transition, repo: MyApp.Repo

  Post
  |> transition(
    [from: "draft", to: "reviewing", via: "review"],
    fn changes -> transit(changes) end)
  )

  Post
  |> transition(
    [from: "reviewing", to: "published", via: "publish"],
    fn changes -> transit(changes) end)
  )
end
```

and specify the transition module for the schema

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  use Eventful.Transitable
  
  alias Post.Transitions
  alias Post.Event
  
  Transitions
  |> governs(:current_state, on: Event)

  schema "posts" do
    field :current_state, :string, default: "draft"
  end
end
```

### Event Handler

You will now need to add the Transitions Handler to your Event module

```elixir
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
```

### Transitioning from State to State

```elixir
MyApp.Post.Event.handle(post, user, %{domain: "transitions", name: "review"})
```

This will now transition and track your model and also track who did it.

### Triggers

Triggers allow to run code whenever a transition has been made to a specific state

```elixir
defmodule MyApp.Post.Triggers do
  alias MyApp.Post

  use Eventful.Trigger

  Post
  |> trigger([currently: "reviewing"], fn event, post ->
    # user code
  end)
end
```

In order for the triggers to execute, you need to pass your custom `Triggers` module to the `transit/2` function

```elixir
defmodule MyApp.Post.Transitions do
  alias MyApp.Post

  @behaviour Eventful.Handler

  use Eventful.Transition, repo: MyApp.Repo

  Post
  |> transition(
    [from: "draft", to: "reviewing", via: "review"],
    fn changes -> transit(changes, Post.Triggers) end)
  )
end
```

### Guards

You may add guards allowing to validate an event for a particular resource and an actor (user or system originating the event). Guards are added into the transitions module.

The guards should either return `{:ok, :passed}` if the validation passed. Anything else will be considered as an error.

```elixir
defmodule MyApp.Post.Transitions do
  alias MyApp.Post

  @behaviour Eventful.Handler

  use Eventful.Transition, repo: MyApp.Repo

  Post
  |> transition(
    [from: "draft", to: "reviewing", via: "review"],
    fn changes -> transit(changes, Post.Triggers) end)
  )

  defp guard_transition(%Post{current_state: _current_state} = post, _originator, "review") do
    if MyApp.check_something(post),
      do: {:ok, :passed},
      else: {:error, :failed}
  end

  defp guard_transition(_activity, _originator, _), do: {:ok, :passed}
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/eventful](https://hexdocs.pm/eventful).
