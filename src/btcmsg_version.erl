-module(btcmsg_version).
-compile(export_all).

-record(msgversion,
	{version,
	 services,
	 timestamp,
	 addr_recv,
	 addr_from,
	 nonce,
	 user_agent,
	 start_height}).

%% Constructors
new(Version, Services, Timestamp, AddrRecv, AddrFrom, UserAgent, StartHeight) ->
    #msgversion{version = Version,
		services = Services,
		timestamp = Timestamp,
		addr_recv = AddrRecv,
		addr_from = AddrFrom,
		nonce = btcalg:nonce(64),
		user_agent = UserAgent,
		start_height = StartHeight}.

new(Version, Timestamp, AddrRecv, AddrFrom, StartHeight) ->
    new(Version, ['NODE_NETWORK'], Timestamp, AddrRecv, AddrFrom, "", StartHeight).

new(Version, AddrRecv, AddrFrom, StartHeight) ->
    new(Version, btcalg:timestamp_now(), AddrRecv, AddrFrom, StartHeight).

%% Binary serializers
from_binary(Blob) when is_binary(Blob) ->
    {NextBlob, Msghd} = btcmsghd:from_binary(Blob),
    Length = btcmsghd:length(Msghd),
    Checksum = btcmsghd:checksum(Msghd),
    <<PayloadBlob:Length/bytes, BlobAfterPayload/binary>> = NextBlob,
    Checksum = btcalg:checksum(PayloadBlob),
    <<Version:32/little-unsigned-integer,
      Services:64/little-unsigned-integer,
      Timestamp:64/little-unsigned-integer,
      AddrRecvBlob:26/bytes,
      AddrFromBlob:26/bytes,
      Nonce:64/little-unsigned-integer,
      NextPayloadBlob>> = PayloadBlob,
    {<<>>, AddrRecv} = btcnetaddr:from_binary_without_timestamp(AddrRecvBlob),
    {<<>>, AddrFrom} = btcnetaddr:from_binary_without_timestamp(AddrFromBlob),
    true = (Version >= 106),
    {NextNextPayloadBlob, UserAgent} = btcvarstr:from_binary(NextPayloadBlob),
    <<StartHeight:32/little-unsigned-integer>> = NextNextPayloadBlob,
    {BlobAfterPayload, {Msghd, #msgversion{version = Version,
					   services = integer_to_services(Services),
					   timestamp = Timestamp,
					   addr_recv = AddrRecv,
					   addr_from = AddrFrom,
					   nonce = Nonce,
					   user_agent = UserAgent,
					   start_height = StartHeight}}}.

to_binary(#msgversion{version = Version,
		      services = Services,
		      timestamp = Timestamp,
		      addr_recv = AddrRecv,
		      addr_from = AddrFrom,
		      nonce = Nonce,
		      user_agent = UserAgent,
		      start_height = StartHeight}) ->
    ServicesInt = services_to_integer(Services),
    true = (btcnetaddr:time(AddrRecv) =:= null),
    true = (btcnetaddr:time(AddrFrom) =:= null),
    AddrRecvBlob = btcnetaddr:to_binary(AddrRecv),
    AddrFromBlob = btcnetaddr:to_binary(AddrFrom),
    UserAgentBlob = btcvarstr:to_binary(btcvarstr:new(UserAgent)),
    PayloadBlob = <<Version:32/little-unsigned-integer,
		    ServicesInt:64/little-unsigned-integer,
		    Timestamp:64/little-unsigned-integer,
		    AddrRecvBlob:26/bytes,
		    AddrFromBlob:26/bytes,
		    Nonce:64/little-unsigned-integer,
		    UserAgentBlob/binary,
		    StartHeight:32/little-unsigned-integer>>,
    MsghdBlob = btcmsghd:to_binary(btcmsghd:new(version, PayloadBlob)),
    <<MsghdBlob/binary, PayloadBlob/binary>>.

%% Internal funs
integer_to_services(1) -> ['NODE_NETWORK'].
services_to_integer(['NODE_NETWORK']) -> 1.
    
    
