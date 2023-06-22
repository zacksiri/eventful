defmodule Eventful.Error do
  @enforce_keys [:code]
  defstruct [:code, :message, :data]

  @type t :: %__MODULE__{
          code: atom,
          message: String.t() | atom | map,
          data: map | String.t()
        }
end
