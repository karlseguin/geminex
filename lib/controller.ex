defmodule Geminex.Controller do

	defmacro __using__(_) do
		quote do
			alias Geminex.Conn
			import Geminex.Controller, only: [plug: 2, input: 1]

			@__geminex_plugs %{}
			@before_compile Geminex.Controller
		end
	end

	defmacro __before_compile__(_env) do
		plugs = Module.get_attribute(__CALLER__.module, :__geminex_plugs)
		plugs = Enum.map(plugs, fn
			{action, [{mod, opts}]} ->
				quote location: :keep do
					def __geminex_plugs(conn, unquote(action)), do: unquote(mod).call(conn, unquote(opts))
				end
			{action, plugs} ->
				plugs = Enum.reverse(plugs)
				quote location: :keep do
					def __geminex_plugs(conn, unquote(action)) do
						Enum.reduce_while(unquote(plugs), conn, fn {mod, opts}, conn ->
							conn = apply(mod, :call, [conn, opts])
							case conn.halt do
								true -> {:halt, conn}
								false -> {:cont, conn}
							end
						end)
					end
				end
		end)

		default = quote do
			def __geminex_plugs(conn, _), do: conn
		end

		[plugs, default]
	end

	defmacro input(opts) do
		quote do
			plug(Geminex.Plugs.Input, unquote(opts))
		end
	end

	defmacro plug(plug, {:when, _, [opts, {:==, _, [{:action, _, _}, action]}]}) when is_atom(action) do
		quote location: :keep, bind_quoted: [plug: plug, opts: opts, action: action] do
			value = {plug, plug.init(opts)}
			@__geminex_plugs Map.update(@__geminex_plugs, action, [value], fn e -> [value | e] end)
		end
	end

	defmacro plug(plug, {:when, _, [opts, {:in, _, [{:action, _, _}, actions]}]}) when is_list(actions) do
		Enum.map(actions, fn action ->
			quote location: :keep do
				plug unquote(plug), unquote(opts) when action == unquote(action)
			end
		end)
	end

	defmacro plug(_plug, {:when, _, _opts}) do
		raise "
			Plug condition can only be in the form of `when action $op $action` where
			$op can be `=` or `in`, and $action can be a single atom or a list of atoms
		"
	end

	defmacro plug(plug, opts) do
		quote location: :keep do
			plug unquote(plug), unquote(opts) when action == :"*"
		end
	end
end
