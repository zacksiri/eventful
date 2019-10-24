# Eventful

![](https://github.com/zacksiri/eventful/workflows/Elixir%20CI/badge.svg)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `eventful` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:eventful, "~> 0.1.0"}
  ]
end
```

### Migration

Generate a migration file for your events like this

```elixir
defmodule MyApp.Repo.Migrations.CreateModelEvents do
  use Ecto.Migration

  def change do
    create table(:[model]_events, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :citext, null: false)
      add(:domain, :citext, null: false)
      add(:metadata, :map, default: "{}")

      add(
        :[model]_id,
        references(:[model]s, on_delete: :restrict, type: :binary_id),
        null: false
      )

      add(
        :[actor]_id,
        references(:[actor]s, on_delete: :restrict, type: :binary_id),
        null: false
      )

      timestamps()
    end

    create(index(:[model]_events, [:[model]_id]))
    create(index(:[model]_events, [:[actor]_id]))
  end
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/eventful](https://hexdocs.pm/eventful).
