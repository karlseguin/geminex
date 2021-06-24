defmodule Geminex.Router do
	@moduledoc """
	The router controls how requests are routed. Since Gemini requests are simple,
	routing is based solely on the request path.

	Associating a path with an action is done by calling `route/3` and providing
	the path to match, the module which acts as the controller, and the name of
	the action (as an atom):

			route "/", My.App.Controller.Home, :home

	Routes can also take parameters:

			route "/post/:id", My.App.Controller.Post, :show
			route "/user/:user_id/books/:book_id", My.App.Controller.User, :show_user_book
	"""

	defmacro __using__(_opts) do
		quote do
			import Geminex.Router, only: [route: 3]
			@before_compile Geminex.Router

			def dispatch(conn) do
				fast_match(conn.uri.path, conn, conn.params)
			end

			def not_found(conn), do: Geminex.Conn.error(conn, "40", "not found")
			defoverridable [not_found: 1]

			def error(conn, _err), do: Geminex.Conn.error(conn, "50", "server error")
			defoverridable [error: 2]
		end
	end

	@doc """
	Routes request using the given `path` to the specific controller and function.
	"""
	defmacro route(path, controller, action) do
		case String.contains?(path, ":") do
			true -> create_route_for_parts(path, controller, action)
			false ->
				quote do
					defp fast_match(unquote(path), conn, params) do
						with %{halt: false} = conn <- unquote(controller).__geminex_plugs(conn, :"*"),
						     %{halt: false} = conn <- unquote(controller).__geminex_plugs(conn, unquote(action))
						do
							unquote(controller).unquote(action)(conn, params)
						else
							halted_conn -> halted_conn
						end
					end
				end
		end
	end

	# Given /user/:id/roles, we're going to match on ["user", id, "roles"].
	# This requires that we split the request path too
	defp create_route_for_parts(path, controller, action) do
		{match, params} = parse_path(path)
		quote location: :keep do
			defp parts_match(unquote(match), conn, params) do
				params = Map.merge(conn.params, unquote({:%{}, [], params}))
				with %{halt: false} = conn <- unquote(controller).__geminex_plugs(conn, :"*"),
				     %{halt: false} = conn <- unquote(controller).__geminex_plugs(conn, unquote(action))
				do
					unquote(controller).unquote(action)(conn, params)
				else
					halted_conn -> halted_conn
				end
			end
		end
	end

	defmacro __before_compile__(_env) do
		quote do
			# no fast_match was available, let's try a parts match
			defp fast_match(path, conn, params) do
				path
				|> String.split("/", trim: true)
				|> parts_match(conn, params)
			end

			# no parts match was available, all
			defp parts_match(_, conn, _params) do
				not_found(conn)
			end
		end
	end

	defp parse_path(path) do
		{match, params} = path
		|> String.split("/", trim: true)
		|> Enum.reduce({[], []}, fn
			<<":", name::binary>>, {match, params} ->
				var = name |> String.to_atom() |> Macro.var(nil)
				{[var | match], [{name, var} | params]}
			literal, {match, params} -> {[literal | match], params}
		end)
		match = Enum.reverse(match)
		{match, params}
	end
end
