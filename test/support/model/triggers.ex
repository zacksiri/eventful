defmodule Eventful.Test.Model.Triggers do
  @moduledoc false

  use Eventful.Trigger

  alias Eventful.Test.Model

  @triggerable_states ~w(approved)

  Model
  |> trigger([currently: current_state], fn _event, _model ->
    if current_state in @triggerable_states do
      {:ok, :something_got_triggered}
    else
      {:error, :something_went_wrong}
    end
  end)
end
