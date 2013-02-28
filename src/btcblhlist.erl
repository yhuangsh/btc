-module(btcblhlist).
-compile(export_all).

-record(blhlist,
	{count,
	 block_locator_hashes,
	 hash_stop}).

%% Constructors
new() -> new(#blhlist{count=0, block_locator_hashes=[], hash_stop=<<>>}).

new(BlockLocatorHashes, HashStop) when is_list(BlockLocatorHashes), is_binary(HashStop) ->
    #blhlist{count = length(BlockLocatorHashes),  BlockLocatorHashes, HashStop}.

%% Getters
get_count(#blhlist{count = Count}) -> Count.
get_block_locator_hashes(#blhlist{block_locator_hashes = BlockLocatorHashes}) -> BlockLocatorHashes.
get_hash_stop(#blhlist{hash_stop = HashStop}) -> HashStop.
    
%% Setters
%% No setters

%% Interfaces

%% Binary serializers
from_binary(Blob) when is_binary(Blob) ->
    {BlockLocatorHashesBlob, Count} = btcvarint:from_binary(Blob),
    {NextBlob, Invecs} = from_binary_block_locator_hashes(Count, BlockLocatorHashesBlob),
    <<HashStop:32/bytes, NextNextBlob/binary>> = NextBlob,
    {NextNextBlob, #blhlist{count = Count, 
			    block_locator_hashes = BlockLocatorHashes,
			    hash_stop = HashStop}}.

to_binary(#blhlist{count = Count,
		   block_locator_hashes = BlockLocatorHashes,
		   hash_stop = HashStop}) ->
    CountBlob = btcvarint:to_binary(btcvarint:new(Count)),
    BlockLocatorHashesBlob = to_binary_block_location_hashes(Count, BlockLocatorHashes),
    <<CountBlob/binary, BlockLocatorHashesBlob/binary, HashStop/binary>>.

%% Internal funs
from_binary_block_locator_hashes(Count, BlockLocatorHashesBlob) -> 
    from_binary_block_locator_hashes(Count, BlockLocatorHashesBlob, []).
from_binary_block_locator_hashes(0, NextBlob, Acc) -> {NextBlob, lists:reverse(Acc)};
from_binary_block_locator_hashes(N, Blob, Acc) -> 
    <<BlockLocatorHash:32/bytes, NextBlob/bianry>> = Blob,
    from_binary_block_locator_hashes(N - 1, NextBlob, [BlockLocatorHash | Acc]).

to_binary_block_locator_hashes(Count, BlockLocatorHashes) -> 
    to_binary_block_locator_hashes(Count, BlockLocatorHashes, <<>>).
to_binary_block_locator_hashes(0, [], Acc) -> Acc;
to_binary_block_locator_hashes(N, [BlockLocatorHash|NextBlockLocatorHashes], Acc) -> 
    to_binary_invecs(N - 1, NextBlockLocatorHashes, <<BlockLocatorHash:32/bytes, Acc/binary>>).


    
    
    
    
