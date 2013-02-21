-module(btcvarstr).
-compile(export_all).

-record(varstr, 
	{ length,
	  string }).

%% Constructors
new(String) when is_list(String) ->
    #varstr{length = erlang:length(String),
	    string = String};
new(StrBlob) when is_binary(StrBlob) ->
    #varstr{length = byte_size(StrBlob),
	    string = binary_to_list(StrBlob)}.

%% Getters
length(VarStr) -> VarStr#varstr.length.
string(VarStr) -> VarStr#varstr.string.
    
%% Setters
%% No setters
      
%% Binary serializers
from_binary(Blob) when is_binary(Blob) ->
    {NextBlob, Length} = btcvarint:from_binary(Blob),
    <<StrBlob:Length/bytes, NextNextBlob/binary>> = NextBlob,
    {NextNextBlob, new(StrBlob)}.

to_binary(#varstr{length = Length,
		  string = String}) ->
    VarLenBlob = btcvarint:to_binary(btcvarint:new(Length)),
    StrBlob = list_to_binary(String),
    <<VarLenBlob/binary, StrBlob/binary>>.

    

