defmodule Geminex.Fake.Controllers.Roles do
	use Geminex.Controller

	alias Geminex.Fake.Plugs.Plug1

	# applied to all actions in this controller
	plug Plug1, "1"

	def controller_plug(conn, _params) do
		Conn.content(conn, "roles-cp-#{conn.assigns[:plug1]}")
	end

	plug Plug1, "2" when action == :controller_and_action_plug
	def controller_and_action_plug(conn, _params) do
		Conn.content(conn, "roles-cap-#{conn.assigns[:plug1]}")
	end

	plug Plug1, "4" when action == :two_controller_and_action_plug
	plug Plug1, "8" when action == :two_controller_and_action_plug
	def two_controller_and_action_plug(conn, _params) do
		Conn.content(conn, "roles-2cap-#{conn.assigns[:plug1]}")
	end

	plug Plug1, "-99" when action == :halt_plug
	def halt_plug(_conn, _params) do
		raise "should not be called"
	end

	plug Plug1, "16" when action == :halt_plug2
	plug Plug1, "-99" when action == :halt_plug2
	def halt_plug2(_conn, _params) do
		raise "should not be called"
	end
end
