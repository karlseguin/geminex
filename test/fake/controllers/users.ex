defmodule Geminex.Fake.Controllers.Users do
	use Geminex.Controller

	def index(conn, params) do
		Conn.content(conn, "users-index-#{params["format"]}")
	end

	def show(conn, params) do
		Conn.content(conn, "users-show-#{params["id"]}-#{params["format"]}")
	end

	def exit(_conn, _params), do: exit("exitted")
	def raise(_conn, _params), do: raise("raised")
	def throw(_conn, _params), do: throw("thrown")

	input [prompt: "are you sure?"] when action == :delete
	def delete(conn, params) do
		Conn.content(conn, "users-delete-#{params["id"]}-#{conn.input}")
	end

	input [prompt: "are you sure??", sensitive: true] when action == :delete_sensitive
	def delete_sensitive(conn, params) do
		Conn.content(conn, "users-delete_sensitive-#{params["id"]}-#{conn.input}")
	end
end
