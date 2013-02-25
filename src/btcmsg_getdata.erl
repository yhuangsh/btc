-module(btcmsg_getdata).
-compile(export_all).

-record(msggetdata, 
	{invec_list}).

%% Constructors
new() -> new([]).
new(InvecList) when is_list(InvecList) ->
    #msggetdata{invec_list = btcinveclist:new(InvecList)}.

%% Getters
get_invec_list(#msggetdata{invec_list = InvecList}) -> InvecList.

%% Setters
%% No setters

%% Binary serializers
from_binary(Blob) when is_binary(Blob) ->
    {NextBlob, Msghd} = btcmsghd:from_binary(Blob),
    Length = btcmsghd:length(Msghd),
    Checksum = btcmsghd:checksum(Msghd),
    <<PayloadBlob:Length/bytes, BlobAfterPayload/binary>> = NextBlob,
    Checksum = btcalg:checksum(PayloadBlob),

    {BlobAfterPayload, {Msghd, #msggetdata{invec_list = btcinveclist:from_binary(PayloadBlob)}}}.

to_binary(#msggetdata{invec_list = InvecList}) ->
    PayloadBlob = btcinveclist:to_binary(InvecList),
    MsghdBlob = btcmsghd:to_binary(btcmsghd:new(getdata, PayloadBlob)),
    <<MsghdBlob/binary, PayloadBlob/binary>>.


    
    
    
    
