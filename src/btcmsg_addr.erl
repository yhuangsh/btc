-module(btcmsg_addr).
-compile(export_all).

-record(msgaddr,
	{count,
	 addr_list}).

%% Constructors
new() -> new([]).

new(NetAddrList) when is_list(NetAddrList) ->
    #msgaddr{count = length(NetAddrList),
	     addr_list = NetAddrList}.

%% Getters
get_count(#msgaddr{count = Count}) -> Count.
get_addr_list(#msgaddr{addr_list = AddrList}) -> AddrList.

%% Setters
%% No setters

%% Interfaces
insert_addr(#msgaddr{addr_list = AddrList}, Addr) -> new([Addr | AddrList]).
append_addr(#msgaddr{addr_list = AddrList}, Addr) -> new([AddrList | [Addr]]).

%% Binary serializers
from_binary(Blob) when is_binary(Blob) ->
    {NextBlob, Msghd} = btcmsghd:from_binary(Blob),
    Length = btcmsghd:length(Msghd),
    Checksum = btcmsghd:checksum(Msghd),
    <<PayloadBlob:Length/bytes, BlobAfterPayload/binary>> = NextBlob,
    Checksum = btcalg:checksum(PayloadBlob),

    {AddrListBlob, Count} = btcvarint:from_binary(PayloadBlob),
    AddrList = from_binary_netaddr_list(Count, AddrListBlob),
    {BlobAfterPayload, {Msghd, #msgaddr{count = Count, 
					addr_list = AddrList}}}.

to_binary(#msgaddr{count = Count,
		   addr_list = AddrList}) ->
    CountBlob = btcvarint:to_binary(btcvarint:new(Count)),
    AddrListBlob = to_binary_netaddr_list(Count, AddrList),
    PayloadBlob = <<CountBlob/binary, AddrListBlob/binary>>,
    MsghdBlob = btcmsghd:to_binary(btcmsghd:new(addr, PayloadBlob)),
    <<MsghdBlob/binary, PayloadBlob/binary>>.

%% Internal funs
from_binary_netaddr_list(Count, AddrListBlob) -> from_binary_netaddr_list(Count, AddrListBlob, []).
from_binary_netaddr_list(0, <<>>, Acc) -> lists:reverse(Acc);
from_binary_netaddr_list(N, Blob, Acc) -> 
    {NextBlob, NetAddr} = btcnetaddr:from_binary(Blob),
    from_binary_netaddr_list(N - 1, NextBlob, [NetAddr | Acc]).

to_binary_netaddr_list(Count, AddrList) -> to_binary_netaddr_list(Count, AddrList, <<>>).
to_binary_netaddr_list(0, [], Acc) -> Acc;
to_binary_netaddr_list(N, [NetAddr|NextAddrs], Acc) -> 
    NetAddrBlob = btcnetaddr:to_binary(NetAddr),
    to_binary_netaddr_list(N - 1, NextAddrs, <<NetAddrBlob/binary, Acc/binary>>).


    
    
    
    
