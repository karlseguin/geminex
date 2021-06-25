defmodule Geminex.Fake.Router do
	use Geminex.Router

	alias Geminex.Fake.Controllers

	route "/users", Controllers.Users, :index
	route "/users/:id", Controllers.Users, :show
	route "/users/:id/delete", Controllers.Users, :delete
	route "/users/:id/delete_sensitive", Controllers.Users, :delete_sensitive

	route "/roles/cp", Controllers.Roles, :controller_plug
	route "/roles/cap", Controllers.Roles, :controller_and_action_plug
	route "/roles/2cap", Controllers.Roles, :two_controller_and_action_plug
	route "/roles/halt_plug", Controllers.Roles, :halt_plug
	route "/roles/halt_plug2", Controllers.Roles, :halt_plug2

	route "/contents/text_file", Controllers.Contents, :text_file
end
