defmodule Eventful.Test.Repo.Migrations.CreateModelEvents do
  use Ecto.Migration

  def change do
    create table(:model_events) do
      add(:name, :string, null: false)
      add(:domain, :string, null: false)
      add(:metadata, :map, default: "{}")

      add(:model_id, references(:models, on_delete: :restrict), null: false)

      add(:actor_id, references(:actors, on_delete: :restrict), null: false)

      timestamps()
    end
    
    create table(:model_internal_events) do
      add(:name, :string, null: false)
      add(:domain, :string, null: false)
      add(:metadata, :map, default: "{}")
    
      add(:model_id, references(:models, on_delete: :restrict), null: false)
    
      add(:actor_id, references(:actors, on_delete: :restrict), null: false)
    
      timestamps()
    end

    create(index(:model_events, [:model_id]))
    create(index(:model_events, [:actor_id]))
    
    create(index(:model_internal_events), [:model_id])
    create(index(:model_internal_events), [:actor_id])
  end
end
