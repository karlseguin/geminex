import Config

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
