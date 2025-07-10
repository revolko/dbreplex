defprotocol Core.Messages.MessageProtocol do
  @doc """
  Creates a core message representation from binary data.
  """
  @spec to_core_message(t()) :: any()
  def to_core_message(data)
end
