defmodule Geminex.Fake.Router do
	use Geminex.Router

	alias Geminex.Fake.Controllers

	route "/users", Controllers.Users, :index
	route "/users/:id", Controllers.Users, :show

	route "/roles/cp", Controllers.Roles, :controller_plug
	route "/roles/cap", Controllers.Roles, :controller_and_action_plug
	route "/roles/2cap", Controllers.Roles, :two_controller_and_action_plug
	route "/roles/halt_plug", Controllers.Roles, :halt_plug
	route "/roles/halt_plug2", Controllers.Roles, :halt_plug2
end
