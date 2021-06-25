defmodule Geminex.Plugs.Input do
	alias Geminex.Conn

	def init(opts) do
		prompt = Keyword.fetch!(opts, :prompt)

		if byte_size(prompt) > 1024 do
			raise "prompt has a maximum length of 1024"
		end

		status = case Keyword.get(opts, :sensitive, false) do
			true -> "11"
			false -> "10"
		end

		{status, prompt}
	end

	def call(conn, {status, prompt}) do
		case :maps.iterator(conn.params) |> :maps.next() do
			{input, "", :none} -> %Conn{conn | input: input}
			:none -> Conn.halt(conn, status, prompt)
		end
	end

end
