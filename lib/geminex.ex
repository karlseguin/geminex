defmodule Geminex do
	use Supervisor

	@config Application.compile_env(:geminex, :server)
	if @config[:ssl] == nil do
		@tcp :gen_tcp
	else
		@tcp :ssl
	end

	def start_link(opts) do
		Supervisor.start_link(__MODULE__, opts)
	end

	def init(_opts) do
		# make sure this exists earlier
		port = Keyword.get(@config, :port, 1965)
		ip = @config |> Keyword.get(:ip, "0.0.0.0") |> String.to_charlist()

		address = case :inet.parse_address(ip) do
			{:ok, address} -> address
			err -> raise err
		end

		opts = [
			:binary,
			ip: address,
			recbuf: 1026, # 1024 URL + \r\n
			backlog: 1024,
			active: :once,
			packet: :line,
			reuseaddr: true,
		] ++ ssl_options(@config[:ssl])

		{:ok, socket} = @tcp.listen(port, opts)
		opts = [socket: socket]
		children = [
			{Geminex.Acceptor, opts ++ [id: :geminex_acceptor_1]},
			{Geminex.Acceptor, opts ++ [id: :geminex_acceptor_2]}
		]

		Supervisor.init(children, strategy: :one_for_one)
	end

	defp ssl_options(nil), do: []
	defp ssl_options(config) do
		[
			keyfile: config[:key],
			certfile: config[:cert],
			cacertfile: config[:ca],
			versions: config[:protocol] || [:"tlsv1.3"],
			ciphers: config[:ciphers] || ["ECDHE-ECDSA-AES128-SHA256", "ECDHE-ECDSA-AES128-SHA"]
		]
	end

end
