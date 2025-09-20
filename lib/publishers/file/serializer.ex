defprotocol Publishers.File.Serializer do
  @moduledoc """
  Protocol defining serialization for Publishers.File.
  """

  @doc """
  Serialize Core message to binary so that it can be written to file.
  """
  @spec serialize(message :: t()) :: binary()
  def serialize(message)
end

defimpl Publishers.File.Serializer, for: Core.Messages.Insert do
  def serialize(%Core.Messages.Insert{} = message) do
    "INSERT INTO #{message.table_name} VALUES " <>
      (Enum.map(message.columns, fn col -> "#{col.value}" end)
       |> Enum.join(" "))
  end
end

defimpl Publishers.File.Serializer, for: Core.Messages.Update do
  def serialize(%Core.Messages.Update{} = message) do
    "UPDATE #{message.table_name} VALUES " <>
      (Enum.map(message.columns, fn col -> "#{col.value}" end) |> Enum.join(" ")) <>
      " WHERE " <>
      (Enum.map(message.where, fn col -> "#{col.name}=#{col.value}" end) |> Enum.join(" "))
  end
end

defimpl Publishers.File.Serializer, for: Core.Messages.Delete do
  def serialize(%Core.Messages.Delete{} = message) do
    "DELETE #{message.table_name} WHERE " <>
      (Enum.map(message.where, fn col -> "#{col.name}=#{col.value}" end) |> Enum.join(" "))
  end
end
