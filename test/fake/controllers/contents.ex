defmodule Geminex.Fake.Controllers.Contents do
	use Geminex.Controller

	def text_file(conn, %{"found" => "N"}) do
		Conn.file(conn, "test/fake/files/missing")
	end

	def text_file(conn, _params) do
		Conn.file(conn, "test/fake/files/hello.txt")
	end
end
