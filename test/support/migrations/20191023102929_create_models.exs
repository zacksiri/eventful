defmodule Eventful.Test.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models) do
      add(:current_state, :string, default: "created", null: false)
    end
  end
end
