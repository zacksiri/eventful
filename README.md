# Eventful

![](https://github.com/zacksiri/eventful/workflows/Elixir%20CI/badge.svg) [![Hex.pm](https://img.shields.io/hexpm/v/eventful.svg)](https://hex.pm/packages/eventful) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/eventful)

Eventful is a library for anyone who needs a trackable state machine. With transitions and triggers and guards.

## Installation

You can add `eventful` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eventful, "~> 3.0.0"}
  ]
end
```

Eventful is a state machine library with an audit trail for your schemas. You can attach a state machine to any schema in your application.

In the following we will use a blogging app as an example. Let's imagine you had a schema like the following to store your blog post.

```elixir
defmodule MyApp.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
  end

  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:title, :content])
  end
end
```

## Event Schema

Let's imagine you want the ability to track the `state` of this post. You may have a collaboration feature where posts can be put into `draft` or `published` state, moreover you also want to track who did the transition. Let's assume you have a `User` schema of some kind. You could define an `Event` module like the following:

```elixir
defmodule MyApp.Post.UserEvent do
  alias MyApp.{
    Post,
    User
  }

  use Eventful,
    parent: {:post, Post},
    actor: {:user, User},
    table_name: "post_user_events"
end
```

## Migration

To make this work you'll also need to add a migration.

```elixir
defmodule MyApp.Repo.Migrations.CreatePostUserEvents do
  use Ecto.Migration

  def change do
    create table(:post_user_events) do
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

## State Machine
Next you'll need to define your `Transitions` this will allow you to define which states the post can transition to.

```elixir
defmodule MyApp.Post.Transitions do
  use Eventful.Transition, repo: MyApp.Repo

  @behaviour Eventful.Handler

  alias MyApp.Post

  Post
  |> transition([from: "draft", to: "published", via: "publish", fn changes ->
    transit(changes)
  end)

  Post
  |> transition([from: "published", to: "draft", via: "drafting", fn changes ->
    transit(changes)
  end)
end
```

Next you'll need to add some field to your `Post` schema which will be used to track the transitions. In this case let's add `:current_state` as the field and also define how the field is governed.

```elixir
defmodule MyApp.Post do
  # ...

  use Eventful.Transitable

  alias __MODULE__.UserEvent
  alias __MODULE__.Transitions

  Transitions
  |> governs(:current_state, on: UserEvent)

  schema "posts" do
    field :title, :string
    field :content, :string

    field :current_state, :string, default: "draft"
  end

  # ...
end
```

Also be sure to define the handler in your `UserEvent` module

```elixir
defmodule MyApp.Post.UserEvent do
  alias MyApp.{
    Post,
    User
  }

  use Eventful,
    parent: {:post, Post},
    actor: {:user, User},
    table_name: "post_user_events"

  handle(:transitions, using: Post.Transitions)
end

defimpl Eventful.Transit, for: MyApp.Post do
  alias MyApp.Post.UserEvent

  def create(resource, actor, event_name, options \\ []) do
    comment = Keyword.get(options, :comment)
    parameters = Keyword.get(options, :parameters)

    UserEvent.handle(post, user, %{
      domain: "transitions", 
      event_name: event_name,
      comment: comment,
      parameters: parameters
    })
  end
end
```

You'll also need to add a migration for the post. You can use `:string` or if you prefer `:citext` for your `:current_state` field.

```elixir
defmodule MyApp.Repo.Migrations.AddCurrentStateToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add(:current_state, :citext, default: "draft", null: false)
    end

    create(index(:posts, [:current_state]))
  end
end
```

## Transitioning the State

That's it! That's how your set up your first auditable state machine on your schema. You can how transition the post from state to state.

```elixir
{:ok, transition} = Eventful.Transit.perform(post, user, "publish")
```

## Copyright and License

Copyright (c) 2022, Zack Siri.

Eventful source code is licensed under the [MIT License](LICENSE.md).
