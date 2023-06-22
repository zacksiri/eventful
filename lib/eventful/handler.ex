defmodule Eventful.Handler do
  @callback call(struct, struct, map) :: {:ok | :error, any}
end
