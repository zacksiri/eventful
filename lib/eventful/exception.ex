defmodule Eventful.Exception do
  defmodule UnexpectedReturnValue do
    defexception message: "Expecting either {:ok, any()} or {:error, any()}"
  end
end
