defmodule Geminex.Fake.Router do
	use Geminex.Router

	alias Geminex.Fake.Controllers

	route "/users", Controllers.Users, :index
	route "/users/:id", Controllers.Users, :show

	route "/roles/cp", Controllers.Roles, :controller_plug
	route "/roles/cap", Controllers.Roles, :controller_and_action_plug
end
