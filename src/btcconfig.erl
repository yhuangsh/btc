-module(btcconfig).
-compile(export_all).

-record(config,
	{client_only = true,
	 external_ip = {0, 0, 0, 0},
	 external_port = 0,
	 protocol_version = 60001,
	 client_version = 2,
	 txn_format_version = 1,
	 user_agent = "/bitcoind-erlang:0.0.1/"}).

    
