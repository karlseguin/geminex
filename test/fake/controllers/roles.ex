defmodule Geminex.Fake.Controllers.Roles do
	use Geminex.Controller

	plug Geminex.Fake.Plugs.Plug1, 1

	def controller_plug(conn, _params) do
		content(conn, "roles-cp-#{conn.assigns[:plug1]}")
	end

	plug Geminex.Fake.Plugs.Plug1, 2 when action == :controller_and_action_plug
	def controller_and_action_plug(conn, _params) do
		content(conn, "roles-cap-#{conn.assigns[:plug1]}")
	end
end
