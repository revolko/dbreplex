defmodule PgSubscriber.RelationStore do
  @moduledoc """
  Agent storing information about known relations.
  The replication client receives RELATION message everytime
  a new relation is encountered (if the client is restarted,
  it will receive RELATION messages again). This agent is
  populated by those RELATION messages.
  """

  use Agent

  alias PgSubscriber.Utils
  alias PgSubscriber.Messages.Relation

  @spec start_link(map()) :: Agent.on_start()
  def start_link(init_state) do
    Agent.start_link(fn -> init_state end, name: __MODULE__)
  end

  @doc """
  Get PG Relation with given relation OID.
  """
  @spec get_relation(Utils.oid()) :: {:ok, Relation.t()} | {:error, nil}
  def get_relation(relation_oid) do
    Agent.get(__MODULE__, fn state ->
      case Map.get(state, relation_oid) do
        nil -> {:error, nil}
        value -> {:ok, value}
      end
    end)
  end

  @doc """
  Store a new relation. If the relation with given OID is
  already stored, it will be overridden.
  """
  @spec store_relation(Relation.t()) :: :ok
  def store_relation(relation) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, relation.relation_oid, relation)
    end)
  end
end
