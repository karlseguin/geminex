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
		request("/roles/cp") |> assert_body("roles-cp-1")
		request("/roles/cap") |> assert_body("roles-cap-3")
		request("/roles/2cap") |> assert_body("roles-2cap-13")
	end

	test "halt plugs" do
		request("/roles/halt_plug") |> assert_meta("halt-1")
		request("/roles/halt_plug2") |> assert_meta("halt-17")
	end

	test "prompt" do
		request("/users/leto/delete") |>  assert_status(10) |> assert_meta("are you sure?")
		request("/users/paul/delete_sensitive") |> assert_status(11) |> assert_meta("are you sure??")

		request("/users/leto/delete?yes") |> assert_status(20) |> assert_body("users-delete-leto-yes")
		request("/users/leto/delete_sensitive?si%20si") |> assert_status(20) |> assert_body("users-delete_sensitive-leto-si si")
	end

	test "sendfile" do
		request("/contents/text_file") |> assert_meta("") |> assert_status(20) |> assert_body("hello\n")
		request("/contents/text_file?type=over/9000") |> assert_meta("over/9000") |> assert_status(20) |> assert_body("hello\n")
		request("/contents/text_file?found=N") |> assert_meta("not found") |> assert_status(40)
	end
end
