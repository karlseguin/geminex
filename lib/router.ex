defmodule Geminex.Router do
	defmacro __using__(_opts) do
		quote do
			import Geminex.Router, only: [route: 3]
			@before_compile Geminex.Router

			def dispatch(conn) do
				fast_match(conn.uri.path, conn, conn.params)
			end

			def not_found(conn, params), do: :not_found
			defoverridable [not_found: 2]
		end
	end

	defmacro route(path, controller, action) do
		case String.contains?(path, ":") do
			true -> create_route_for_parts(path, controller, action)
			false ->
				quote do
					defp fast_match(unquote(path), conn, params) do
						with %{halt: false} = conn <- unquote(controller).__geminex_plugs(conn, unquote(action)),
						     %{halt: false} = conn <- unquote(controller).__geminex_plugs(conn, :"*")
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
				with %{halt: false} = conn <- unquote(controller).__geminex_plugs(conn, unquote(action)),
				     %{halt: false} = conn <- unquote(controller).__geminex_plugs(conn, :"*")
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
			defp parts_match(_, conn, params) do
				not_found(conn, params)
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
