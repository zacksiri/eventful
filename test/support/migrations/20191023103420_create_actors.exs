defmodule Eventful.Test.Repo.Migrations.CreateActors do
  use Ecto.Migration

  def change do
    create table(:actors) do
      add(:name, :string, null: false)
    end

    create table(:users) do
      add(:name, :string, null: false)
    end
  end
end
