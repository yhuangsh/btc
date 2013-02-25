-module(btcinveclist).
-compile(export_all).

-record(inveclist,
	{count,
	 invecs}).

%% Constructors
new() -> new(#inveclist{count=0, invecs=[]}).

new(Invecs) when is_list(Invecs) ->
    #inveclist{count = length(Invecs),
	       invecs = Invecs}.

%% Getters
get_count(#inveclist{count = Count}) -> Count.
get_invecs(#inveclist{invecs = Invecs}) -> Invecs.

%% Setters
%% No setters

%% Interfaces
insert_invec(#inveclist{invecs = Invecs}, Invec) -> new([Invec | Invecs]).
append_invec(#inveclist{invecs = Invecs}, Invec) -> new([Invecs | [Invec]]).

%% Binary serializers
from_binary(Blob) when is_binary(Blob) ->
    {InvecListBlob, Count} = btcvarint:from_binary(Blob),
    {NextBlob, Invecs} = from_binary_invecs(Count, InvecListBlob),
    {NextBlob, #inveclist{count = Count, 
			   invecs = Invecs}}.

to_binary(#inveclist{count = Count,
		     invecs = Invecs}) ->
    CountBlob = btcvarint:to_binary(btcvarint:new(Count)),
    InvecsBlob = to_binary_invecs(Count, Invecs),
    <<CountBlob/binary, InvecsBlob/binary>>.

%% Internal funs
from_binary_invecs(Count, InvecListBlob) -> from_binary_invecs(Count, InvecListBlob, []).
from_binary_invecs(0, NextBlob, Acc) -> {NextBlob, lists:reverse(Acc)};
from_binary_invecs(N, Blob, Acc) -> 
    {NextBlob, Invec} = btcinvec:from_binary(Blob),
    from_binary_invecs(N - 1, NextBlob, [Invec | Acc]).

to_binary_invecs(Count, InvecList) -> to_binary_invecs(Count, InvecList, <<>>).
to_binary_invecs(0, [], Acc) -> Acc;
to_binary_invecs(N, [Invec|NextInvecs], Acc) -> 
    InvecBlob = btcnetaddr:to_binary(Invec),
    to_binary_invecs(N - 1, NextInvecs, <<InvecBlob/binary, Acc/binary>>).


    
    
    
    
