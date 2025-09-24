defmodule Core do
  @moduledoc """
  The root module of the Core lib.
  Used to define boundary.
  """
  use Boundary,
    exports: [Messages.{Column, Insert, Update, Delete, MessageProtocol}, PublisherContract]
end
