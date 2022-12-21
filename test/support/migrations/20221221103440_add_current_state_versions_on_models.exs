defmodule Eventful.Test.Repo.Migrations.AddCurrentStateVersionsOnModels do
  use Ecto.Migration

  def change do
    alter table(:models) do
      add(:current_state_versions, :integer, null: false, default: 0)
    end
  end
end
