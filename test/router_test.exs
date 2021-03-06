defmodule Geminex.Tests.Router do
	use Geminex.Tests
	use Geminex.Router
	use Geminex.Controller

	route "/", __MODULE__, :simple_route1
	route "/over/9000", __MODULE__, :simple_route2
	def simple_route1(_, _), do: :simple_route1
	def simple_route2(_, _), do: :simple_route2
	test "simple route" do
		assert test_match("/") == :simple_route1
		assert test_match("/over/9000") == :simple_route2
	end

	route "/over/:id", __MODULE__, :params_route3
	route "/over/:id/x/:id2", __MODULE__, :params_route4
	def params_route3(_, params), do: "params_route3_#{params["id"]}"
	def params_route4(_, params), do: "params_route4_#{params["id"]}_#{params["id2"]}"
	test "params" do
		assert test_match("/over/9001") == "params_route3_9001"
		assert test_match("/over/9002/x/9003") == "params_route4_9002_9003"
	end

	test "not found" do
		assert test_match("invalid").response.status == "51"
	end

	defp test_match(path) do
		conn = Geminex.Conn.new(:not_a_socket, path)
		dispatch(conn)
	end
end
