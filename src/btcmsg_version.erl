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
		nonce = btcmisc:nonce(64),
		user_agent = UserAgent,
		start_height = StartHeight}.

new(Version, Timestamp, AddrRecv, AddrFrom, UserAgent, StartHeight) ->
    new(Version, ['NODE_NETWORK'], Timestamp, AddrRecv, AddrFrom, UserAgent, StartHeight).

new(Version, AddrRecv, AddrFrom, UserAgent, StartHeight) ->
    new(Version, btcmisc:timestamp(), AddrRecv, AddrFrom, UserAgent, StartHeight).

%% Binary serializers
from_binary(Blob) when is_binary(Blob) ->
    {NextBlob, Msghd} = btcmsghd:from_binary(Blob),
    Length = btcmsghd:get_length(Msghd),
    Checksum = btcmsghd:get_checksum(Msghd),
    <<PayloadBlob:Length/bytes, BlobAfterPayload/binary>> = NextBlob,
    Checksum = btcalg:checksum(PayloadBlob),
    <<Version:32/little-unsigned-integer,
      Services:64/little-unsigned-integer,
      Timestamp:64/little-unsigned-integer,
      AddrRecvBlob:26/bytes,
      AddrFromBlob:26/bytes,
      Nonce:64/little-unsigned-integer,
      NextPayloadBlob/binary>> = PayloadBlob,
    {<<>>, AddrRecv} = btcnetaddr:from_binary_notime(AddrRecvBlob),
    {<<>>, AddrFrom} = btcnetaddr:from_binary_notime(AddrFromBlob),
    true = (Version >= 106),
    {NextNextPayloadBlob, UserAgent} = btcvarstr:from_binary(NextPayloadBlob),
    <<StartHeight:32/little-unsigned-integer>> = NextNextPayloadBlob,
    {BlobAfterPayload, {Msghd, #msgversion{version = Version,
					   services = btcmisc:integer_to_services(Services),
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
    ServicesInt = btcmisc:services_to_integer(Services),
    true = (btcnetaddr:get_time(AddrRecv) =:= null),
    true = (btcnetaddr:get_time(AddrFrom) =:= null),
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

   
    
