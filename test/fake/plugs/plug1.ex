defmodule Geminex.Fake.Plugs.Plug1 do
	def init(i), do: i * 10

	def call(conn, i) do
		existing = conn.assigns[:plug1] || 0
		Geminex.Conn.assign(conn, :plug1, existing + i)
	end
end
