defmodule Geminex.Protocol do
	@config Application.compile_env(:geminex, :server)
	if @config[:ssl] == nil do
		@tcp :gen_tcp
	else
		@tcp :ssl
	end

	def content(socket, status, meta, content) do
		@tcp.send(socket, [status(status), meta || [], "\r\n", content || ""])
		@tcp.close(socket)
	end

	def error(socket, status, message) do
		@tcp.send(socket, "#{status} #{message}\r\n")
		@tcp.close(socket)
	end

	for status <- 10..99 do
		s = Integer.to_string(status) <> " "
		defp status(unquote(status)), do: unquote(s)
	end
end
