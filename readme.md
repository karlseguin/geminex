An early version of a [Gemini](https://gemini.circumlunar.space/) server written in Elixir.

While this is currently functional, it lacks many of the necessary features for building more complex sites.

## Usage

### Configuration
Define a config for `:geminex, :server`:

```elixir
config :geminex, :server, [
    port: 1965, 
    ip: "0.0.0.0",
    read_timeout: 10_000, # ms
    router: My.App.Router,
    ssl: [
        ca: "root.crt",
        key: "site.key",
        cert: "site.crt"
    ]
]
```

Only `router` is required. However, the three `ssl` values are required for TLS, which Gemini requires. The only reason to omit the `ssl` values is for local development or when offloading TLS-termination (e.g. with haproxy).

### Router
Create your router:

```elixir
defmodule My.App.Router do
  use Geminex.Router

  alias My.App.Controllers

  route "/", Controllers.Home, :index
  route "/posts", Controllers.Post, :index
  route "/posts/:id", Controller.Post, :show
end
```

The router can optionally implement `not_found/1` and/or `error/2`. The default implementation are:

```elixir
def not_found(conn), do: Geminex.Conn.error(conn, "40", "not found")
def error(conn, _err), do: Geminex.Conn.error(conn, "50", "server error")
```

### Controllers
Create your controllers. Currently, controllers can only return text. More advanced support (files, templates) is planned.

```elixir
defmodule My.App.Controllers.Posts do
  use Geminex.Controller

  def index(conn, params) do
    Conn.content(conn, "hello world")
  end

  def show(conn, %{"id" => id} = param) do
    case Post.load(id) do
      nil -> Conn.error(conn, 40, "not found")
      post -> Conn.content(conn, post)
    end
  end
end
```

### Plugs
Controller-level and action-level plugs can be defined:

```elixir
defmodule My.App.Controllers.Posts do
  use Geminex.Controller

  plug My.App.Plugs.Verify

  plug My.App.Plugs.Validate, [page: [:int, default: 1]] when action == :index
  def index(conn, params) do
    Conn.content(conn, "hello world")
  end

  def show(conn, %{"id" => id} = param) do
    case Post.load(id) do
      nil -> Conn.error(conn, 40, "not_found")
      post -> Conn.content(conn, post)
    end
  end
end
```

This will execute the `Verify` plug for both the `index` and `show` actions. Additionally, the `Validate` plug will be executed for the `index` action (controller plugs are executed first, followed by action plugs).

Plugs behave like Phoenix plugs: relying on the `init/1` and `call/2` function:

```elixir
defmodule My.App.Plugs.Validate do
  alias Geminex.Conn

  # init is called at compile time and lets you tranform the parameters
  # which will be passed to call/2 
  def init(opts), do opts

  def call(conn, opts) do
    case validate(conn, opts) do
      :ok -> conn
      :invalid -> Conn.halt(conn, 41, "invalid content")
    end
  end
end
```
