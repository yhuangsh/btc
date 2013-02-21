-module(btcmsghd).
-compile(export_all).

-define(BTC_MAGIC, 16#d9b4bef9).

-record(msghd,
	{ magic,
	  command,
	  length,
	  checksum }).

%% Constructors
new(Command, Payload) -> new(Command, byte_size(Payload), btcalg:checksum(Payload)).
new(Command, Length, Checksum) when is_atom(Command), 
				    is_integer(Length), 
				    is_binary(Checksum), byte_size(Checksum) =:= 4 ->    
    #msghd{magic = ?BTC_MAGIC,
	   command = command_to_binary(Command),
	   length = Length,
	   checksum = Checksum}.

%% Getters
command(#msghd{command = Command}) -> Command.
length(#msghd{length = Length}) -> Length.
checksum(#msghd{checksum = Checksum}) -> Checksum.
    
%% Setters
%% No setters

%% Binary serializers
from_binary(<<?BTC_MAGIC:32/little-unsigned-integer,
	      CmdBlob:12/bytes,
	      Length:32/little-unsigned-integer,
	      Checksum:4/bytes,
	      Payload/binary>>) ->
    Command = binary_to_command(CmdBlob),
    {Payload, #msghd{magic = ?BTC_MAGIC,
		     command = Command,
		     length = Length,
		     checksum = Checksum}}.

to_binary(#msghd{magic = ?BTC_MAGIC,
		 command = Command,
		 length = Length,
		 checksum = Checksum}) ->
    CmdBlob = command_to_binary(Command),
    <<?BTC_MAGIC:32/little-unsigned-integer,
      CmdBlob:12/bytes,
      Length:32/little-unsigned-integer,
      Checksum:4/bytes>>.

%% Internal funcs
binary_to_command(<<"version",           0, 0, 0, 0, 0>>) -> version;
binary_to_command(<<"verack",         0, 0, 0, 0, 0, 0>>) -> verack;
binary_to_command(<<"addr",     0, 0, 0, 0, 0, 0, 0, 0>>) -> addr;
binary_to_command(<<"inv",   0, 0, 0, 0, 0, 0, 0, 0, 0>>) -> inv;
binary_to_command(<<"getdata",           0, 0, 0, 0, 0>>) -> getdata;
binary_to_command(<<"getblocks",               0, 0, 0>>) -> getblocks;
binary_to_command(<<"getheaders",                 0, 0>>) -> getheaders;
binary_to_command(<<"tx", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) -> tx; 
binary_to_command(<<"block",       0, 0, 0, 0, 0, 0, 0>>) -> block;
binary_to_command(<<"headers",           0, 0, 0, 0, 0>>) -> headers;
binary_to_command(<<"getaddr",           0, 0, 0, 0, 0>>) -> getaddr;
binary_to_command(<<"submitorder",                   0>>) -> submitorder;
binary_to_command(<<"checkorder",                 0, 0>>) -> checkorder;
binary_to_command(<<"reply",       0, 0, 0, 0, 0, 0, 0>>) -> reply;
binary_to_command(<<"alert",       0, 0, 0, 0, 0, 0, 0>>) -> alert;
binary_to_command(<<"ping",           0, 0, 0, 0, 0, 0>>) -> ping.

command_to_binary(version)     -> <<"version",           0, 0, 0, 0, 0>>;
command_to_binary(verack)      -> <<"verack",         0, 0, 0, 0, 0, 0>>;
command_to_binary(addr)        -> <<"addr",     0, 0, 0, 0, 0, 0, 0, 0>>;
command_to_binary(inv)         -> <<"inv",   0, 0, 0, 0, 0, 0, 0, 0, 0>>;
command_to_binary(getdata)     -> <<"getdata",           0, 0, 0, 0, 0>>;
command_to_binary(getblocks)   -> <<"getblocks",               0, 0, 0>>;
command_to_binary(getheaders)  -> <<"getheaders",                 0, 0>>;
command_to_binary(tx)          -> <<"tx", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>;
command_to_binary(block)       -> <<"block",       0, 0, 0, 0, 0, 0, 0>>;
command_to_binary(headers)     -> <<"headers",           0, 0, 0, 0, 0>>;
command_to_binary(getaddr)     -> <<"getaddr",           0, 0, 0, 0, 0>>;
command_to_binary(submitorder) -> <<"submitorder",                   0>>;
command_to_binary(checkorder)  -> <<"checkorder",                 0, 0>>;
command_to_binary(reply)       -> <<"reply",       0, 0, 0, 0, 0, 0, 0>>;
command_to_binary(alert)       -> <<"alert",       0, 0, 0, 0, 0, 0, 0>>;
command_to_binary(ping)        -> <<"ping",           0, 0, 0, 0, 0, 0>>.

