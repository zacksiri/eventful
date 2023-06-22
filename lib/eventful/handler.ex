defmodule Eventful.Handler do
  @callback call(actor :: struct, resource :: struct, event_params :: map) ::
              {:ok, %Eventful.Transition{}} | {:error, %Eventful.Error{}}
end
