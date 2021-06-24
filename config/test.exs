import Config

# Because I used configs at compile-time (despite the community saying not to for
# years not), this is hard to test in both TLS and Plain mode. A proper CI
# could just run both.

config :geminex, :server, [
	port: 1966,
	ip: "127.0.0.1",
	read_timeout: 100, # ms
	router: Geminex.Fake.Router,
	ssl: [
		ca: "test/support/files/root.crt",
		key: "test/support/files/geminex.key",
		cert: "test/support/files/geminex.crt"
	]
]

# config :geminex, :server, [
# 	port: 1966,
# 	ip: "127.0.0.1",
# 	read_timeout: 100, # ms
# 	router: Geminex.Fake.Router
# ]
