-module(btcmisc).
-compile(export_all).

%% Port
default_port() -> 8333.
    
%% Timestamp
timestamp() ->
    {X, Y, _} = now(),
    X * 1000000 + Y.

%% Nonce
nonce(64) ->
    Blob = crypto:strong_rand_bytes(8),
    <<N:64/integer>> = Blob,
    N.

%% Services <-> Integer
default_services_integer() -> 1.
default_services() -> integer_to_services(default_services_integer()).
    
integer_to_services(1) -> ['NODE_NETWORK'].
services_to_integer(['NODE_NETWORK']) -> 1.
    
