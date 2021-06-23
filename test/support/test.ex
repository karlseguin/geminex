defmodule Geminex.Tests do
	defmacro __using__(opts) do
		quote do
			use ExUnit.Case, async: unquote(opts)
			import Geminex.Tests
		end
	end

	import ExUnit.Assertions

	def request(url) do
		{:ok, socket} = :ssl.connect('127.0.0.1', 1966, active: true, verify: :verify_none, log_level: :none)
		:ok = :ssl.send(socket, url <> "\r\n")
		case read([]) do
			{:error, err} -> raise err
			{:ok, data} -> parse_response(data)
		end
	end

	def assert_status(res, expected) do
		assert res.status == expected
		res
	end

	def assert_meta(res, expected) do
		assert res.meta == expected
		res
	end

	def assert_body(res, expected) do
		assert res.body == expected
		res
	end

	defp read(acc) do
		receive do
			{:ssl, _socket, data} -> read([acc, data])
			{:ssl_closed, _socket} -> {:ok, :erlang.iolist_to_binary(acc)}
			{:ssl_error, _socket, reason} -> {:error, reason}
		after
			100 -> raise "read timeout"
		end
	end

	defp parse_response(data) do
		{status, data} = Integer.parse(data)
		case status < 20 || status > 29 do
			true -> %{status: status, meta: String.trim(data)}
			false ->
				[header, body] = String.split(data, "\n", parts: 2)
				%{status: status, meta: String.trim(header), body: body}
		end

	end
end
