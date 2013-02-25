-module(btcinvec).
-compile(export_all).

-record(invec,
	{ type,
	  hash }).

%% Constructors
new(Type, Hash) when Type =:= error; Type =:= msg_tx; Type =:= msg_block, is_binary(Hash), byte_size(Hash) =:= 32 ->
    #invec{type = Type,
	   hash = Hash}.

%% Getters
get_type(#invec{type = Type}) -> Type.
get_hash(#invec{hash = Hash}) -> Hash.

%% Setters
set_type(#invec{hash = Hash}, Type) -> new(Type, Hash).
set_hash(#invec{type = Type}, Hash) -> new(Type, Hash).
    
%% Binary serializers
from_binary(<<TypeInt:32/little-unsigned-integer,
	      Hash:32/bytes, 
	      Blob/binary>>) ->
    {Blob, #invec{type = integer_to_type(TypeInt),
		  hash = Hash}}.

to_binary(#invec{type = Type,
		 hash = Hash}) ->
    TypeInt = type_to_integer(Type),
    <<TypeInt:32/little-unsigned-integer, Hash:32/bytes>>.

%% Internal funs
integer_to_type(0) -> 'ERROR';
integer_to_type(1) -> 'MSG_TX';
integer_to_type(2) -> 'MSG_BLOCK'.
type_to_integer('ERROR') -> 0;
type_to_integer('MSG_TX') -> 1;
type_to_integer('MSG_BLOBK') -> 2.
    
    
