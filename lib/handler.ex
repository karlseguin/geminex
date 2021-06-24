defmodule Geminex.Handler do
	require Logger
	alias Geminex.{Conn, Protocol}

	@config Application.compile_env(:geminex, :server)
	@router Keyword.fetch!(@config, :router)

	def execute(socket, request_line) do
		conn = Conn.new(socket, request_line)
		post_execute(@router.dispatch(conn), true)
	end

	defp post_execute(conn, initial?) do
		response = conn.response
		status = response.status || "20"

		case reply(conn.socket, status, response.meta, response.body) do
			:ok -> :ok
			err -> handle_error(conn, err, initial?)
		end
	end

	# intial error handling fail, break the loop
	defp handle_error(conn, :not_found, false) do
		Protocol.error(conn.socket, "40", "not found")
	end

	defp handle_error(conn, :server_error, false) do
		Protocol.error(conn.socket, "50", "server error")
	end

	defp handle_error(conn, err, false) do
		Logger.error("error in error handlers", inspect(err))
		Protocol.error(conn.socket, "59", "server error (loop)")
	end

	defp handle_error(conn, :not_found, true) do
		post_execute(@router.not_found(conn), false)
	end

	defp handle_error(conn, err, true) do
		post_execute(@router.error(conn, err), false)
	end

	defp reply(socket, status, meta, {:file, file}) do
		case Protocol.sendfile(socket, status, meta, file) do
			{:error, :enoent} -> :not_found
			err_or_ok -> err_or_ok
		end
	end

	defp reply(socket, status, meta, content) do
		Protocol.content(socket, status, meta, content)
	end
end
