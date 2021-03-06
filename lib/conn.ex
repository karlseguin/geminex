defmodule Geminex.Conn do
	alias __MODULE__

	@enforce_keys [
		# The full URI (https://hexdocs.pm/elixir/URI.html)
		:uri,

		# Set to true when processing should stop and the response returned
		:halt,

		# The underlying socket
		:socket,

		# string => string map. Query parameters + URL parameters
		:params,

		# Abitrary container for application-specific data. See assign/3
		:assigns,

		# The resposne object
		:response,

		# String which is set when browser is responding to an input request
		# (status codes 10 or 11)
		:input,

		# The original request line
		:request_line
	]
	defstruct @enforce_keys

	defmodule Response do
		@enforce_keys [:body, :meta, :status]
		defstruct @enforce_keys
	end

	def new(socket, request_line) do
		uri = URI.parse(request_line)
		params = case uri.query do
			nil -> %{}
			query -> URI.decode_query(query)
		end

		response = %Response{body: nil, meta: nil, status: nil}
		%Conn{
			uri: uri,
			input: nil,
			halt: false,
			assigns: [],
			socket: socket,
			params: params,
			response: response,
			request_line: request_line
		}
	end

	@doc """
	Stops further processing of the request. Generally called from a Plug.
	"""
	def halt(conn, status, meta) do
		%Conn{conn |
			halt: true,
			response: %Response{status: status, meta: meta, body: nil}
		}
	end

	def error(conn, status, meta) do
		%Conn{conn | response: %{conn.response | status: status, meta: meta, body: nil}}
	end

	@doc """
	Sets the meta portion of the response.
	"""
	def meta(conn, meta), do: %Conn{conn | response: %{conn.response | meta: meta}}

	@doc """
	Sets the status portion of ther reponse.
	"""
	def status(conn, status), do: %Conn{conn | response: %{conn.response | status: status}}

	@doc """
	Sets the status and meta portion of ther reponse.
	"""
	def status_meta(conn, status, meta), do: %Conn{conn | response: %{conn.response | status: status, meta: meta}}

	@doc """
	Sets the content of a response to an binary or iolist.
	"""
	def content(conn, body), do: %Conn{conn | response: %{conn.response | body: body}}

	@doc """
	Sets the content of a response to an binary or iolist with the give meta data
	"""
	def content(conn, body, meta) do
		%Conn{conn | response: %{conn.response | body: body, meta: meta}}
	end

	@doc """
	Will send the content of the file at `path` as the response. When
	doing TLS termination, this reads the contents of the file and then writes
	it to the socket. When not doing TLS termination, sendfile(2) will be used
	if available.
	"""
	def file(conn, path), do: %Conn{conn | response: %{conn.response | body: {:file, path}}}

	@doc """
	Will send the content of the file at `path` as the response with the given meta data.
	When doing TLS termination, this reads the contents of the file and then writes
	it to the socket. When not doing TLS termination, sendfile(2) will be used
	if available.
	"""
	def file(conn, path, meta) do
		%Conn{conn | response: %{conn.response | body: {:file, path}, meta: meta}}
	end

	@doc """
	Associate application-specific data with the connection.
	"""
	def assign(conn, key, value), do: put_in(conn.assigns[key], value)
end
