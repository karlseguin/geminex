defmodule Geminex.Conn do
	require Record

	alias __MODULE__
	alias Geminex.Protocol

	Record.defrecord(:response, status: 20, meta: nil, body: nil)

	defstruct [
		:uri,
		:halt,
		:socket,
		:params,
		:assigns,
		:response
	]

	def new(socket, request_line) do
		uri = URI.parse(request_line)
		params = case uri.query do
			nil -> %{}
			query -> URI.decode_query(query)
		end

		%Conn{uri: uri, halt: false, socket: socket, params: params, response: response(), assigns: []}
	end

	def reply(conn) do
		res = conn.response
		socket = conn.socket

		meta = response(res, :meta)
		status = response(res, :status)

		case response(res, :body) do
			body -> Protocol.content(socket, status, meta, body)
		end
	end

	def assign(conn, key, value) do
		put_in(conn.assigns[key], value)
	end
end
