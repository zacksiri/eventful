defprotocol Eventful.Transit do
  @spec perform(struct, struct, binary, Keyword.t()) ::
          {:ok, %Eventful.Transition{}} | {:error, %Eventful.Error{}}
  def perform(resource, actor, event_name, options \\ [])
end
