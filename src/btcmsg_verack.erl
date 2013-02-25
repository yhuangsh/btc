-module(btcmsg_verack).
-compile(export_all).

-record(msgverack, {}).

%% Constructors
new() -> #msgverack{}.

%% Getters
%% No getters

%% Setters
%% No setters

%% Bnary serializers
from_binary(Blob) when is_binary(Blob) ->
    {NextBlob, Msghd} = btcmsghd:from_binary(Blob),
    Length = btcmsghd:get_length(Msghd),
    Checksum = btcmsghd:get_checksum(Msghd),
    Length = 0,
    Checksum = btcalg:checksum(<<>>),

    {NextBlob, {Msghd, <<>>}}.

to_binary(#msgverack{}) ->
    btcmsghd:to_binary(btcmsghd:new(verack, <<>>)).

    
    
