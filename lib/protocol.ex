defmodule Geminex.Protocol do
	@config Application.compile_env(:geminex, :server)

	if @config[:ssl] == nil do
		@tcp :gen_tcp
	else
		@tcp :ssl
	end

	def content(socket, status, meta, content) do
		@tcp.send(socket, [header(status, meta), content || ""])
	end

	if @tcp == :gen_tcp do

		def sendfile(socket, status, meta, file) do
			with {:ok, fd} <- :file.open(file, [:raw, :read, :binary]) do
				sendfd(socket, status, meta, fd)
			end
		end

		defp sendfd(socket, status, meta, fd) do
			@tcp.send(socket, header(status, meta))
			case :file.sendfile(fd, socket, 0, 0, []) do
				{:ok, _} -> :ok
				err -> err
			end
		after
			:file.close(fd)
		end

	else
		# TODO: If we are in TLS, it's possible we can use kernel-support TLS+sendfile
		def sendfile(socket, status, meta, file) do
			with {:ok, data} <- File.read(file) do
				@tcp.send(socket, [header(status, meta), data])
			end
		end
	end

	def error(socket, status, message) do
		@tcp.send(socket, header(status, message))
	end

	defp header(status, meta) do
		[status(status), meta || [], "\r\n"]
	end

	defp status(status) when is_binary(status), do: status
	for status <- 10..99 do
		s = Integer.to_string(status) <> " "
		defp status(unquote(status)), do: unquote(s)
	end
	defp status(nil), do: "20"
end
