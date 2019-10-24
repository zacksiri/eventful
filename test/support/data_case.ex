defmodule Eventful.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Eventful.Test.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Eventful.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Eventful.Test.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Eventful.Test.Repo, {:shared, self()})
    end

    :ok
  end
end
