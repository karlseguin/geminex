defmodule Geminex.Handler do
	alias Geminex.{Conn, Protocol}

	@config Application.compile_env(:geminex, :server)
	@router Keyword.fetch!(@config, :router)

	def execute(socket, request_line) do
		conn = Conn.new(socket, request_line)
		conn = @router.dispatch(conn)
		Conn.reply(conn)

	end
end
