defmodule Eventful.Test.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models) do
      add(:publish_state, :string, default: "draft", null: false)
      add(:current_state, :string, default: "created", null: false)
      add(:internal_state, :string, defalt: "created", null: false)
    end
  end
end
