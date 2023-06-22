defmodule Eventful.Error do
  defstruct [:code, :message, :data]

  @enforce_keys [:code]
end
