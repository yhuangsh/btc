-module(btcmsg).


new() -> ok.
new(version) -> ok.
new(verack) -> ok.
new(addr) -> ok.
new(inv) -> ok.
new(getdata) -> ok.
new(getblocks) -> ok.
new(getheaders) -> ok.
new(tx) -> ok.
new(block) -> ok.
new(headers) -> ok.
new(getaddr) -> ok.
new(submitorder) -> ok.
new(checkorder) -> ok.
new(reply) -> ok.
new(alert) -> ok.
new(ping) -ok.

from_binary(<<HeaderBlob:24/bytes>>) ->
    from_binary(<<HeaderBlob, 0>>);
from_binary(<<HeaderBlob:24/bytes, Blob/binary>>) ->
    {<<>>, ParsedMsg} = from_binary_header(HeaderBlob),
    Command = ParsedMsg#btcmsg.command,
    Length = ParsedMsg#btcmsg.length,
    <<PayloadBlob:Length/bytes, NextBlob/binary>> = Blob,
    {NextNextBlob, ParsedPayload} = from_binary_payload(Command, PayloadBlob),
    Checksum = ParsedMsg#btcmsg.checksum,
    Checksum = generate_payload_checksum(ParsedPayload),
    {NextNextBlob, ParsedMsg#btcmsg{payload=ParsedPayload}}.

from_binary_headear(<<?BTC_MAGIC:32/little-unsigned-integer,
		      CmdStr:12/bytes,
		      Length:32/little-unsigned-integer,
		      Checksum:4/bytes,
		      Blob/binary>>) ->
    Command = string_to_command(CmdStr),
    {Blob, #btcmsg{command=Command,
		   length=Length,
		   checksum=Checksum}.

from_binary_payload(version, <<Version:32/little-unsigned-integer,
			       Service:64/little-unsigned-integer,
			       Timestamp:64/little-unsigned-integer,
			       AddrRecvBlob:26/bytes,
			       AddrFromBlob:26/bytes,
			       Nonce:64/little-unsigned-integer,
			       Blob>>) ->
    true = (Version >= 106),
    {<<>>, AddrRecv} = btclib:from_binary_netaddr_without_timestamp(AddrRecvBlob),
    {<<>>, AddrFrom} = btclib:from_binary_netaddr_without_timestamp(AddrFromBlob),
    {NextBlob, UserAgent} = btclib:from_binary_var_str(NextBlob),
    {RetBlob, StartHeight} = case NextBlob of
				      <<SH:32/little-unsigned-integer>> -> 
					  {NextBlob, SH};
				      <<SH:32/little-unsigned-integer, NextNextBlob>> ->
					  {NextNextBlob, SH}
				  end,
    {RetBlob, #btcversion{version = Version,
			  service = Service,
			  timestamp = Timestamp,
			  addr_recv = AddrRecv,
			  addr_from = AddrFrom,
			  user_agent = UserAgent,
			  start_height = StartHeight}};
from_binary_payload(verack, Blob) ->
    {Blob, null};
from_binary_payload(addr, Blob) ->
    {NextBlob, Count} = btclib:from_binary_var_int(Blob),
    {NextNextBlob, Addrs} = from_binary_netaddr_list(Count, NextBlob),
    {NextNextBlob, #btcaddrs{count = Count,
				addrs = Addrs}};
from_binary_payload(inv, Blob) ->
    {NextBlob, Count} = btclib:from_binary_var_int(Blob),
    {NextNextBlob, Invs} = from_binary_inventory_list(Count, NextBlob),
    {NextNextBlob, #btcinvs{count = Count,
			    invs = Invs}};
from_binary_payload(getdata, Blob) ->
    from_binary_payload(inv, Blob);
from_binary_payload(getblocks, <<Version:32/little-unsigned-integer,
				 Blob>>) ->
    {NextBlob, HashCount} = btclib:from_binary_var_int(Blob),
    {NextNextBlob, BlockLocatorHashs} = btclib:from_binary_hash_list(HashCount, NextBlob),
    {RetBlob, HashStop} = case NextNextBlob of
			      <<HS:32/bytes>> ->
				  {<<>>, HS};
			      <<HS:32/bytes, NextNextNextBlob/binary>> ->
				  {NextNextNextBlob, HS}
			  end,
    {RetBlob, #btcblklocs{hash_count = Count,
			  block_locator_hashs = BlockLocatorHashs,
			  hash_stop = HashStop}};
from_binary_payload(getheaders, Blob) ->
    from_binary_payload(getblocks, Blob);
from_binary_payload(tx, Blob) ->
    

    

			      
			      
    







to_binary(Blob) -> ok.
    
string_to_command({<<"version",           0, 0, 0, 0, 0>>) -> version;
string_to_command({<<"verack",         0, 0, 0, 0, 0, 0>>) -> verack;
string_to_command({<<"addr",     0, 0, 0, 0, 0, 0, 0, 0>>) -> addr;
string_to_command({<<"inv",   0, 0, 0, 0, 0, 0, 0, 0, 0>>) -> inv;
string_to_command({<<"getdata",           0, 0, 0, 0, 0>>) -> getdata;
string_to_command({<<"getblocks",               0, 0, 0>>) -> getblocks;
string_to_command({<<"getheaders",                 0, 0>>) -> getheaders;
string_to_command({<<"tx", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) -> tx; 
string_to_command({<<"block",       0, 0, 0, 0, 0, 0, 0>>) -> block;
string_to_command({<<"headers",           0, 0, 0, 0, 0>>) -> headers;
string_to_command({<<"getaddr",           0, 0, 0, 0, 0>>) -> getaddr;
string_to_command({<<"submitorder",                   0>>) -> submitorder;
string_to_command({<<"checkorder",                 0, 0>>) -> checkorder;
string_to_command({<<"reply",       0, 0, 0, 0, 0, 0, 0>>) -> reply;
string_to_command({<<"alert",       0, 0, 0, 0, 0, 0, 0>>) -> alert;
string_to_command({<<"ping",           0, 0, 0, 0, 0, 0>>) -> ping.

extract_payload(0, _) ->
    {<<>>, <<>>};
extract_payload(Length, Blob) ->
    if
	<<Payload:Length/bytes, NextBlob>> = Blob ->
	    {Payload, NextBlob};
	<<Payload:Length/bytes>> = Blob ->
	    {Blob, <<>>}
    end.

from_binary_payload(version, <<Version:32/little-unsigned-integer,
			       Service:64/little-unsigned-integer,
			       Timestamp:64/little-unsigned-integer,
			       AddrRecvBlob:26/bytes,
			       Blob>>) ->
    {<<>>, AddrRecv} = btclib:netaddr_without_timestamp_from_binary(AddrRecvBlob),
    true = (Version >= 106),
    <<AddrFromBlob:26/bytes,
      Nonce:64/little-unsigned-integer,
      NextBlob>> = Blob,
    {_, AddrFrom} = btclib:parse_netaddr_without_timestamp(AddrFromBlob),
    {NextNextBlob, UserAgent} = btclib:parse_var_str(NextBlob),
    <<StartHeight:32/little-unsigned-integer, NextNextNextBlob>> = NextNextBlob,
    {NextNextNextBlob, #btcmsg_ver{version = Version,
				   service = Service,
				   timestamp = Timestamp,
				   addr_recv = AddrRecv,
				   addr_from = AddrFrom,
				   user_agent = UserAgent,
				   start_height = StartHeight}};
    end;
    

    
parse_msg(Blob) when is_binary(Blob) ->
    parse_msg_payload(
      parse_msg_checksum(
	parse_msg_length(
	  parse_msg_command(
	    {btclib:check_magic(Blob), #btcmsg{}})))).

parse_msg_cmd({<<"version",           0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=version}};
parse_msg_cmd({<<"verack",         0, 0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=verack}};
parse_msg_cmd({<<"addr",     0, 0, 0, 0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=addr}};
parse_msg_cmd({<<"inv",   0, 0, 0, 0, 0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=inv}};
parse_msg_cmd({<<"getdata",           0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=getdata}};
parse_msg_cmd({<<"getblocks",               0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=getblocks}};
parse_msg_cmd({<<"getheaders",                 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=getheaders}};
parse_msg_cmd({<<"tx", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=tx}}; 
parse_msg_cmd({<<"block",       0, 0, 0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=block}};
parse_msg_cmd({<<"headers",           0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=headers}};
parse_msg_cmd({<<"getaddr",           0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=getaddr}};
parse_msg_cmd({<<"submitorder",                   0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=submitorder}};
parse_msg_cmd({<<"checkorder",                 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=checkorder}};
parse_msg_cmd({<<"reply",       0, 0, 0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=reply}};
parse_msg_cmd({<<"alert",       0, 0, 0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=alert}};
parse_msg_cmd({<<"ping",           0, 0, 0, 0, 0, 0, Blob/binary>>, Parsed) -> {Blob, Parsed#btcmsg{command=ping}}.

parse_msg_length({<<Length:32/little-unsigned-integer, Blob/binary>>, Parsed}) ->
    {Blob, Parsed#btcmsg{length=Length}}.

parse_msg_checksum({<<Checksum:4/bytes, Blob/binary>>, Parsed}) ->
    {Blob, Parsed#btcmsg{checksum=Checksum}}.

parse_msg_payload({Blob, Parsed}) ->
    Length = Parsed#btcmsg.length,
    Checksum = Parsed#btcmsg.checksum,
    Command = Parsed#btcmsg.command,
    <<Payload:Length/bytes, NextBlob/binary>> = Blob,
    Checksum = hash256(Payload),
    {NextNextBlob, ParsedPayloadContent} = parse_msg_payload_content(Command, Payload),
    {NextNextBlob, Parsed#btcmsg{payload=ParsedPayloadContent}}.

parse_msg_payload_content(version, Blob) -> 
    {NextBlob, Parsed} = parse_msg_version_1({Blob, #btcmsg_version{}}),
    Version = Parsed#btcmsg_version.version,
    if 
	Version >= 106 ->
	    parse_msg_version_2({NextBlob, Parsed});
	Version < 106 ->
	    {NextBlob, Parsed}
    end.

parse_msg_version_1({Blob, Parsed}) ->
    parse_netaddr_without_timestamp(
      parse_timestamp(
	parse_service(
	  parse_version({Blob, Parsed})
	
parse_msg_command(verack, Blob) -> parse_msg_verack({Blob, #btcmsg_verack{}});
parse_msg_command(addr, Blob} -> parse_msg_addr({Blob, #btcmsg_addr{}}).

parse_msg_version({Blob, Parsed}) ->
    {NextBlob, Parsed} = 
<<Version:32/little-unsigned-integer,
			     Service:64/little-unsigned-integer,
			     Timestamp:64/little-unsigned-integer,
			     AddrRecvBlob:26/bytes,
			     Blob>>) ->
    AddrRecv = decode_netaddr_without_timestamp(AddrRecvBlob),
    if
	Version >= 106 ->
	    <<AddrFromBlob:26/bytes,
	      Nonce:64/little-unsigned-integer,
	      NextBlob>> = Blob,
	    AddrFrom = decode_netaddr_without_timestamp(AddrFromBlob),
	    {NextNextBlob, UserAgent} = parse_var_str(NextBlob),
	    <<StartHeight:32/little-unsigned-integer>> = NextNextBlob,
	    #btcmsg_ver{version = Version,
			service = Service,
			timestamp = Timestamp,
			addr_recv = AddrRecv,
			addr_from = AddrFrom,
			user_agent = UserAgent,
				 start_height = StartHeight};
	Version < 106 ->
	    #btcmsg_ver{version = Version,
			service = Service,
			timestamp = Timestamp,
			addr_recv = AddrRecv}
    end;
decode_msg_payload(verack, ) ->

    
	
    
