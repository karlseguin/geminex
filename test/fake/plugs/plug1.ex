defmodule Geminex.Fake.Plugs.Plug1 do
	alias Geminex.Conn

	def init(i), do: String.to_integer(i)

	def call(conn, -99) do
		Conn.halt(conn, 40, "halt-#{conn.assigns[:plug1] || 0}")
	end

	def call(conn, i) do
		existing = conn.assigns[:plug1] || 0
		Geminex.Conn.assign(conn, :plug1, existing + i)
	end
end
