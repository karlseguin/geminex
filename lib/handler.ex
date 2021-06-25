defmodule Geminex.Handler do
	require Logger
	alias Geminex.{Conn, Protocol}

	@config Application.compile_env(:geminex, :server)
	@router Keyword.fetch!(@config, :router)

	def execute(socket, request_line) do
		conn = Conn.new(socket, request_line)
		try do
			post_execute(@router.dispatch(conn), true)
		rescue
			err -> handle_error(conn, err, true)
		catch
			err -> handle_error(conn, err, true)
			:exit, err -> handle_error(conn, err, true)
		end
	end

	defp post_execute(conn, initial?) do
		response = conn.response
		status = response.status || "20"

		case reply(conn.socket, status, response.meta, response.body) do
			:ok -> :ok
			err -> handle_error(conn, err, initial?)
		end
	end

	# This is a catch-all. The error handler defined in the Router (either the
	# built-in one or the application-specific one) has failed. We'll try to
	# get a reply to the server anyways
	defp handle_error(conn, :not_found, false) do
		Logger.error(%{source: "geminex fallback not found", conn: conn})
		Protocol.error(conn.socket, "51", "not found")
	end

	defp handle_error(conn, err, false) do
		Logger.error(%{source: "geminex fallback error handler", conn: conn, error: err})
		Protocol.error(conn.socket, "40", "server error")
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
