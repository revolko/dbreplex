# Core

**Core** is the shared library for defining the internal data representation and contracts used across the replication system. It provides:

- Canonical schemas for replication messages received from databases (e.g., PostgreSQL, MySQL).
- Contracts (interfaces) that target apps can implement to handle replicated messages.
- Utilities for encoding, decoding, and working with messages in a uniform way.

## Installation

This app is designed to be used within the umbrella.

## Usage

### Using the message structs

```elixir
alias Core.Messages.Insert

%Insert{
  table: "users",
  columns: %{"id" => 1, "name" => "Alice"}
}
```

### Implementing the target contract
In your custom target app, you can implement the Core.TargetContract behaviour:
```elixir
defmodule MyCustomTarget do
  @behaviour Core.TargetContract

  @impl true
  def handle_message(message) do
    # Do something with the message, e.g., send to a queue, update a cache, or update a database
    IO.inspect(message, label: "Received replication message")
    :ok
  end
end
```
