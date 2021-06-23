defmodule Geminex.Tests.Integration do
	use Geminex.Tests

	test "basic requets" do
		request("/users") |> assert_status(20) |> assert_meta("") |> assert_body("users-index-")
		request("/users?format=json") |> assert_status(20) |> assert_meta("") |> assert_body("users-index-json")
	end

	test "requets with id" do
		request("/users/9000") |> assert_status(20) |> assert_meta("") |> assert_body("users-show-9000-")
		request("/users/9001?format=json") |> assert_status(20) |> assert_meta("") |> assert_body("users-show-9001-json")
	end

	test "plugs" do
		request("/roles/cp") |> assert_body("roles-cp-10")
		request("/roles/cap") |> assert_body("roles-cap-30")
	end
end
