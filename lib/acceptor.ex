defmodule Geminex.Acceptor do
	use Task

	@config Application.compile_env(:geminex, :server)
	@read_timeout @config[:read_timeout] || 10_000

	if @config[:ssl] == nil do
		@tcp :gen_tcp
	else
		@tcp :ssl
	end

	def child_spec(opts) do
		{id, opts} = Keyword.pop(opts, :id)
		%{
			id: id,
			restart: :transient,
			start: {__MODULE__, :start_link, [opts]}
		}
	end

	def start_link(opts) do
		Task.start_link(__MODULE__, :run, [opts])
	end

	def run(opts) do
		accept_loop(opts[:socket])
	end

	if @tcp == :gen_tcp do
		defp accept_loop(listen_socket) do
			case :gen_tcp.accept(listen_socket) do
				{:error, err} -> raise Exception.format_exit(err)
				{:ok, client_socket} ->
					pid = spawn fn -> connected(client_socket) end
					:gen_tcp.controlling_process(client_socket, pid)
					accept_loop(listen_socket)
			end
		end
	else
		defp accept_loop(listen_socket) do
			case :ssl.transport_accept(listen_socket) do
				{:error, err} -> raise Exception.format_exit(err)
				{:ok, client_socket} ->
					pid = spawn fn ->
						case :ssl.handshake(client_socket, @read_timeout) do
							{:ok, client_socket} -> connected(client_socket)
							{:error, err} ->
								:telemetry.execute([:geminex, :ssl_handshake_error], %{count: 1}, %{error: err})
								:ssl.close(client_socket)
						end
					end
					:ssl.controlling_process(client_socket, pid)
					accept_loop(listen_socket)
			end
		end
	end

	defp connected(socket) do
		with {:ok, line} <- read_request_line(),
		     len <- byte_size(line) - 2,
		     true <- len > 0 || :invalid_request,
		     <<line::bytes-size(len), "\r\n">> <- line
		do
			Geminex.Handler.execute(socket, line)
		else
			:timeout ->
				:telemetry.execute([:geminex, :read, :timeout], %{count: 1})
				Geminex.Protocol.error(socket, "59", "read timeout")
			_ ->
				:telemetry.execute([:geminex, :read, :invalid], %{count: 1})
				Geminex.Protocol.error(socket, "59", "invalid request")
		end
	after
		@tcp.close(socket)
	end

	defp read_request_line() do
		receive do
			{:tcp, _socket, line} -> {:ok, line}
			{:tcp_closed, _socket} -> {:error, :closed}
			{:tcp_error, _socket, reason} -> {:error, reason}
			{:ssl, _socket, line} -> {:ok, line}
			{:ssl_closed, _socket} -> {:error, :closed}
			{:ssl_error, _socket, reason} -> {:error, reason}
		after
			@read_timeout -> :timeout
		end
	end
end
