defmodule Eventful.Handler do
  @callback call(struct, struct, map) ::
              {:ok, %Eventful.Transition{}} | {:error, %Eventful.Error{}}
end
