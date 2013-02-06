-moduel(btclib).
-compile(export_all).

-record(btcblk, 
	{ magic,
	  size, 
	  header,
	  n_trans,
	  trans }).

-record(btcblkheader 
	{ version,
	  hash_prev_blk,
	  hash_merkle_root,
	  time,
	  bits,
	  nonce }).

parse_block(Blob) when is_binary(Blob) ->
    parse_block_ret(
      parse_transactions(
	parse_block_header(
	  chk_block_size(
	    chk_magic({Blob, #btcblk{}}))))).
parse_block_ret({Blob, undefined}) -> {Blob, undefined};
parse_block_ret({Blob, Parsed}) -> 
    NewTransList = lists:reverse(Parsed#btcblk.trans),
    {Blob, Parsed#btcblk{trans=NewTransList}}.

parse_transactions({Blob, undefined}) -> {Blob, undefined};
parse_transactions({<<N, Blob/binary>>, Parsed}) when N < 16#fd, is_record(Parsed, btcblk) ->
    parse_transactions(N, {Blob, Parsed#{n_trans=N}});
parse_transactions({<<16#fd, N:16/little-unsigned-integer, Blob/binary>>, Parsed}) when is_record(Parsed, btcblk) ->
    parse_transactions(N, {Blob, Parsed#{n_trans=N}});
parse_transactions({<<16#fe, N:32/little-unsigned-integer, Blob/binary>>, Parsed}) when is_record(Parsed, btcblk) ->
    parse_transactions(N, {Blob, Parsed#{n_trans=N}});
parse_transactions({<<16#ff, Counter:64/little-unsigned-integer, Blob/binary>>, Parsed}) when is_record(Parsed, btcblk) ->
    parse_transactions(N, {Blob, Parsed#{n_trans=N}});
parse_transactions({Blob, _} -> {Blob, undefined}.
			 
parse_transactions(0, {Blob, Parsed}) -> {Blob, Parsed};
parse_transactions(_, {Blob, undefined}) -> parse_transactions(0, {Blob, undefined});
parse_transactions(N, {Blob, Parsed}) -> parse_transactions_ret(parse_transaction({Blob, #btctr{}})).
parse_transactions_ret({NewBlob, undefined}) -> parse_transactions(N-1, {NewBlob, undefined});
parse_transactions_ret({NewBlob, NewTrans}) ->
    NewTransList = [NewTrans | Parsed#btcblk.trans],
    parse_transactions(N-1, {NewBlob, Parsed#btcblk{trans=NewTransList}}).

parse_transaction({Blob, ParsedTrans}) ->
    parse_trans_lock_time(
      parse_trans_outputs(
	parse_trans_n_out(
	  parse_trans_inputs(
	    parse_trans_n_in(
	      parse_trans_version({Blob, #btctr{}})))))).


		     
chk_magic({<<16#D9B4BEF9:32/little-unsigned, Blob/binary>>, Parsed}) when is_record(Parsed, btcblk) -> 
    {Blob, Parsed#{magic=16#D9B4BEF9}};
chk_magic({Blob, _}) -> {Blob, undefined}.

chk_block_size({<<BlockSize:4/little-unsigned, Blob/binary>>, Parsed}) when is_record(Parsed, btcblk) ->
    if 
	BlockSize > size(Blob) -> {Blob, undefined};
	true -> {Blob, Parsed#{size=BlockSize}}
    end;
chk_block_size(Raw, _) -> {Raw, undefined}.

parse_block_header(<<Version:32/little-unsigned, 
		     HashPrevBlock:32/bytes, 
		     HashMerkleRoot:32/bytes, 
		     Time:32/little-unsigned-integer,
		     Bits:32/little-unsigned-integer,
		     Nonce:32/little-unsigned-integer, Blob/binary>>, Parsed) when is_record(Parsed, btcblk) ->
    {Blob, Parsed#{header=#btcblkheader{version = Version,
					hash_prev_block = HashPrevBlock,
					hash_merkle_root = HashMerkleRoot,
					time = Time,
					bits = Bits,
					nonce = Nonce}}};
parse_block_header(Blob, _) -> {Blob, undefined}.

	
          
    
	    
		    
    

	    
