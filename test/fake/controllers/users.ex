defmodule Geminex.Fake.Controllers.Users do
	use Geminex.Controller

	def index(conn, params) do
		Conn.content(conn, "users-index-#{params["format"]}")
	end

	def show(conn, params) do
		Conn.content(conn, "users-show-#{params["id"]}-#{params["format"]}")
	end
end
