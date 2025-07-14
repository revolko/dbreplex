defmodule MainApp do
  @moduledoc false

  use Application

  @subscribers Application.compile_env(:main_app, :subscribers, [])
  @publishers Application.compile_env(:main_app, :publishers, [])

  @impl true
  def start(_type, _args) do
    children = [
      get_children_spec(@publishers),
      get_children_spec(@subscribers)
    ]

    children = List.flatten(children)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MainApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_children_spec(config_properties) do
    Enum.with_index(config_properties)
    |> Enum.map(fn {property, index} ->
      %{
        id: "#{property.module}#{index}",
        start: {property.module, :start_link, [property.init_arg]}
      }
    end)
  end
end
