-module(btcnetaddr).
-compile(export_all).

-record(netaddr, 
	{ time,
	  services,
	  ip, 
	  port}).

%% Constructors
new(Ip) -> new(Ip, btcmisc:default_port()).
new(Ip, Port) -> new(btcmisc:default_services(), Ip, Port).
new(Services, Ip, Port) -> new(btcmisc:timestamp(), Services, Ip, Port).

new_notime(Ip) -> new_notime(Ip, btcmisc:default_port()).
new_notime(Ip, Port) -> new_notime(btcmisc:default_services(), Ip, Port).
new_notime(Services, Ip, Port) -> new(null, Services, Ip, Port).

new(Time, Services, Ip, Port) -> #netaddr{time = Time, 
					  services = Services, 
					  ip = Ip, 
					  port = Port}.

%% Getters
get_time(#netaddr{time = Time}) ->  Time.
get_services(#netaddr{services = Services}) -> Services.
get_ip(#netaddr{ip = Ip}) -> Ip.
get_port(#netaddr{port = Port}) -> Port.

%% Setters
set_time(NetAddr, NewTime) -> NetAddr#netaddr{time = NewTime}.
set_services(NetAddr, NewServices) -> NetAddr#netaddr{services = NewServices}.
set_ip(NetAddr, NewIp) -> NetAddr#netaddr{ip = NewIp}.
set_port(NetAddr, NewPort) -> NetAddr#netaddr{port = NewPort}.

%% Misc
is_no_timestamp(NetAddr) -> NetAddr#netaddr.time =:= null.

%% Binary serializers
from_binary_notime(<<Services:64/little-unsigned-integer,
		     Ip:16/bytes,
		     Port:16/big-unsigned-integer, 
		     Blob/binary>>) ->
    {Blob, #netaddr{time = null,
		    services = Services,
		    ip = binary_to_ip(Ip),
		    port = Port}}.

from_binary(<<Time:32/little-unsigned-integer, 
	      Blob/binary>>) ->
    {NextBlob, NetAddr} = from_binary_notime(Blob),
    {NextBlob, NetAddr#netaddr{time = Time}}.

to_binary(#netaddr{time = Time,
		   services = Services,
		   ip = Ip,
		   port = Port}) ->
    TimeBlob = time_to_binary(Time),
    IpBlob = ip_to_binary(Ip),
    ServicesInt = btcmisc:services_to_integer(Services),
    <<TimeBlob/binary, 
      ServicesInt:64/little-unsigned-integer, 
      IpBlob:16/bytes,
      Port:16/big-unsigned-integer>>.


%% Internal funs
binary_to_ip(<<16#ffff:96/big-unsigned-integer, A1, A2, A3, A4>>) ->
    {A1, A2, A3, A4};
binary_to_ip(<<A1:16/big-unsigned-integer, 
	       A2:16/big-unsigned-integer,
	       A3:16/big-unsigned-integer,
	       A4:16/big-unsigned-integer,
	       A5:16/big-unsigned-integer,
	       A6:16/big-unsigned-integer,
	       A7:16/big-unsigned-integer,
	       A8:16/big-unsigned-integer>>) ->
    {A1, A2, A3, A4, A5, A6, A7, A8}.

ip_to_binary({A1, A2, A3, A4}) ->
    <<16#ffff:96/big-unsigned-integer, A1, A2, A3, A4>>;
ip_to_binary({A1, A2, A3, A4, A5, A6, A7, A8}) ->
    <<A1:16/big-unsigned-integer, 
      A2:16/big-unsigned-integer,
      A3:16/big-unsigned-integer,
      A4:16/big-unsigned-integer,
      A5:16/big-unsigned-integer,
      A6:16/big-unsigned-integer,
      A7:16/big-unsigned-integer,
      A8:16/big-unsigned-integer>>.

time_to_binary(null) ->
    <<>>;
time_to_binary(N) when 0 < N, N =< 16#ffffffff ->
    <<N:32/little-unsigned-integer>>.

