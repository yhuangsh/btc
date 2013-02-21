-module(btcvarint).
-compile(export_all).

%% Constructors
new(Integer) when is_integer(Integer) ->
    Integer.

%% Getters
%% No getters

%% Setters
%% No setters

%% Binary serializers
from_binary(<<N, Blob/binary>>) when N < 16#fd -> 
    {Blob, N};
from_binary(<<16#fd, N:16/little-unsigned-integer, Blob/binary>>) -> 
    {Blob, N};
from_binary(<<16#fe, N:32/little-unsigned-integer, Blob/binary>>) -> 
    {Blob, N};
from_bariny(<<16#ff, N:64/little-unsigned-integer, Blob/binary>>) -> 
    {Blob, N}.

to_binary(N) when N < 16#fd ->
    <<N>>;
to_binary(N) when 16#fd =< N, N =< 16#ffff ->
    <<16#fd, N:16/little-unsigned-integer>>;
to_binary(N) when 16#ffff < N, N =< 16#ffffffff->
    <<16#fe, N:32/little-unsigned-integer>>;
to_binary(N) when 16#ffffffff < N, N =< 16#ffffffffffffffff ->
    <<16#ff, N:64/little-unsigned-integer>>.



