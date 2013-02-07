-module(btclib).
-compile(export_all).

-record(btcblk, 
	{ magic,
	  size, 
	  header,
	  n_tx,
	  txs }).

-record(btcblkhd,
	{ version,
	  hash_prev_blk,
	  hash_merkle_root,
	  time,
	  bits,
	  nonce }).

-record(btctx,
	{ version,
	  n_in,
	  ins,
	  n_out,
	  outs,
	  lock_time }).

-record(btctxin,
	{ prev_tx_hash,
	  prev_txout_idx,
	  script_len,
	  script,
	  seq }).

-record(btctxout,
	{ value,
	  script_len,
	  script }).

parse_blk(Blob) when is_binary(Blob) ->
    parse_txs(
      parse_n_tx(
	parse_blk_hd(
	  chk_blk_size(
	    chk_magic(Blob))))).

chk_magic(<<16#D9B4BEF9:32/little-unsigned-integer, Blob/binary>>) -> 
    {Blob, #btcblk{magic=16#d9b4bef9}}.

chk_blk_size({<<BlockSize:4/little-unsigned-integer, Blob/binary>>, Parsed}) when BlockSize > size(Blob) ->
    {Blob, Parsed#btcblk{size=BlockSize}}.

parse_blk_hd({<<Version:32/little-unsigned, 
		HashPrevBlock:32/bytes, 
		HashMerkleRoot:32/bytes, 
		Time:32/little-unsigned-integer,
		Bits:32/little-unsigned-integer,
		Nonce:32/little-unsigned-integer, Blob/binary>>, Parsed}) ->
    {Blob, Parsed#btcblk{header=#btcblkhd{version = Version,
					  hash_prev_blk = HashPrevBlock,
					  hash_merkle_root = HashMerkleRoot,
					  time = Time,
					  bits = Bits,
					  nonce = Nonce}}}.

parse_n_tx({Blob, Parsed}) ->
    {NewBlob, N} = parse_var_len(Blob),
    {NewBlob, Parsed#btcblk{n_tx=N}}.
    
parse_txs({Blob, Parsed}) -> 
    parse_txs(Parsed#btcblk.n_tx, {Blob, Parsed}).
	    
parse_txs(0, {Blob, Parsed}) -> 
    TxList = lists:reverse(Parsed#btcblk.txs),
    {Blob, Parsed#btcblk{txs=TxList}};
parse_txs(N, {Blob, Parsed}) -> 
    {NewBlob, Tx} = parse_tx(Blob),
    TxList = [Tx | Parsed#btcblk.txs],
    parse_txs(N-1, {NewBlob, Parsed#btcblk{txs=TxList}}).

parse_tx(Blob) ->
    parse_tx_lock_time(
      parse_tx_outs(
	parse_tx_n_out(
	  parse_tx_ins(
	    parse_tx_n_in(
	      parse_tx_version(Blob)))))).

parse_tx_version(<<Version:32/little-unsigned-integer, Blob/binary>>) -> 
    {Blob, #btctx{version=Version}}.

parse_tx_n_in({Blob, Parsed}) -> 
    {NewBlob, N} = parse_var_len(Blob),
    {NewBlob, Parsed#btctx{n_in=N}}.

parse_tx_ins({Blob, Parsed}) ->
    parse_tx_ins(Parsed#btctx.n_in, {Blob, Parsed}).

parse_tx_ins(0, {Blob, Parsed}) ->
    Ins = lists:reverse(Parsed#btctx.ins),
    {Blob, Parsed#btctx{ins=Ins}};
parse_tx_ins(N, {Blob, Parsed}) ->
    {NewBlob, I} = parse_tx_in(Blob),
    Ins = [I|Parsed#btctx.ins], 
    parse_tx_ins(N-1, {NewBlob, Parsed#btctx{ins=Ins}}).
    
parse_tx_in(<<PrevTxHash:32/bytes, PrevTxOutIndex:4/little-unsigned-integer, Blob/binary>>) ->
    {NewBlob, ScriptLen} = parse_var_len(Blob),
    parse_tx_in_seq_no(
      parse_tx_in_script_sig({NewBlob, #btctxin{prev_tx_hash=PrevTxHash,
						prev_txout_idx=PrevTxOutIndex,
						script_len=ScriptLen}})).

parse_tx_in_script_sig({Blob, Parsed}) ->
    ScriptLen = Parsed#btctxin.script_len,
    <<Script:ScriptLen/bytes, NewBlob/binary>> = Blob,
    {NewBlob, Parsed#btctxin{script=Script}}.

parse_tx_in_seq_no({<<Seq:32/little-unsigned-integer, Blob>>, Parsed}) ->
    {Blob, Parsed#btctxin{seq=Seq}}.

parse_tx_n_out({Blob, Parsed}) -> 
    {NewBlob, N} = parse_var_len(Blob),
    {NewBlob, Parsed#btctx{n_out=N}}.

parse_tx_outs({Blob, Parsed}) ->
    parse_tx_outs(Parsed#btctx.n_out, {Blob, Parsed}).

parse_tx_outs(0, {Blob, Parsed}) ->
    Outs = lists:reverse(Parsed#btctx.outs),
    {Blob, Parsed#btctx{outs=Outs}};
parse_tx_outs(N, {Blob, Parsed}) ->    
    {NewBlob, O} = parse_tx_out(Blob),
    Outs = [O|Parsed#btctx.outs], 
    parse_tx_outs(N-1, {NewBlob, Parsed#btctx{outs=Outs}}).
    
parse_tx_out(<<Value:64/little-unsigned-integer, Blob/binary>>) ->
    {NewBlob, ScriptLen} = parse_var_len(Blob),
    parse_tx_out_script_puk({NewBlob, #btctxout{value=Value, script_len=ScriptLen}}).

parse_tx_out_script_puk({Blob, Parsed}) ->
    ScriptLen = Parsed#btctxout.script_len,
    <<Script:ScriptLen/bytes, NewBlob/binary>> = Blob, 
    {NewBlob, Parsed#btctxout{script=Script}}.

parse_tx_lock_time({<<LockTime:32/little-unsigned-integer, Blob/binary>>, Parsed}) ->
    {Blob, Parsed#btctx{lock_time=LockTime}}.

parse_var_len(<<N, Blob/binary>>) when N < 16#fd -> {Blob, N};
parse_var_len(<<16#fd, N:16/little-unsigned-integer, Blob/binary>>) -> {Blob, N};
parse_var_len(<<16#fe, N:32/little-unsigned-integer, Blob/binary>>) -> {Blob, N};
parse_var_len(<<16#ff, N:64/little-unsigned-integer, Blob/binary>>) -> {Blob, N}.


    
          
    
	    
		    
    

	    
