-module(btctest).
-compile(export_all).


get_seeding_host_ips() ->
    SeedHosts = ["bitseed.xf2.org",
		 "dnsseed.bluematt.me",
		 "seed.bitcoin.sipa.be",
		 "dnsseed.bitcoin.dashjr.org"],
    lists:foldl(fun(H, AccIn) ->
			case inet:getaddrs(H, inet) of
			    {ok, Addrs} ->
				Addrs ++ AccIn;
			    _ ->
				AccIn
			end
		end,
		[],
		SeedHosts).

send_version() ->
    Msg = btcmsg_version:new(60002,
			     {61, 144, 128, 24},
			     {124, 127, 129, 210},
			     120000).

    
    
