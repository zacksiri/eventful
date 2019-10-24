ExUnit.start()

Eventful.Test.Repo.start_link()
Ecto.Adapters.SQL.Sandbox.mode(Eventful.Test.Repo, :manual)
