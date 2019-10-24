defmodule Eventful.Handler do
  @callback call(actor :: struct, resource :: struct, event_params :: map) ::
              {:ok, term}
              | {:error, term}
              | {:error, atom, struct}
              | {:error, any(), any(), map()}
end
