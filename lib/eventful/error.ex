defmodule Eventful.Error do
  @enforce_keys [:code]
  defstruct [:code, :message, :data]
end
