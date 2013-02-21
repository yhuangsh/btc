-module(btcnetaddr).
-compile(export_all).

-record(netaddr, 
	{ time,
	  services,
	  ip, 
	  port}).

%% Constructors
new(Services, Ip, Port) -> new(null, Services, Ip, Port).
new(Time, Services, Ip, Port) -> #netaddr{time = Time, 
					  services = Services, 
					  ip = Ip, 
					  port = Port}.

%% Getters
time(#netaddr{time = Time}) ->  Time.
services(#netaddr{services = Services) -> Services.
ip(#netaddr{ip = Ip}) -> Ip.
port(#netaddr{port = Port}) -> Port.

%% Setters
time(NetAddr, NewTime) -> NetAddr#netaddr{time = NewTime}.
services(NetAddr, NewServices) -> NetAddr#netaddr{services = NewServices}.
ip(NetAddr, NewIp) -> NetAddr#netaddr{ip = NewIp}.
port(NetAddr, NewPort) -> NetAddr#netaddr{port = NewPort}.

%% Misc
is_no_timestamp(NetAddr) -> NetAddr#netaddr.time =:= null.

%% Binary serializers
from_binary_without_timestamp(<<Services:64/little-unsigned-integer,
				Ip:16/bytes,
				Port:16/big-unsigned-integer, 
				Blob/binary>>) ->
    {Blob, #netaddr{time = null,
		    services = Services,
		    ip = binary_to_ip(Ip),
		    port = Port}}.

from_binary(<<Time:32/little-unsigned-integer, 
	      Blob/binary>>) ->
    {NextBlob, NetAddr} = from_binary_without_timestamp(Blob),
    {NextBlob, NetAddr#netaddr{time = Time}}.

to_binary(#netaddr{time = Time,
		   services = Services,
		   ip = Ip,
		   port = Port}) ->
    TimeBlob = time_to_binary(Time),
    IpBlob = ip_to_binary(Ip),
    <<TimeBlob/binary, 
      Services:64/little-unsigned-integer, 
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

