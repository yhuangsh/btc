-module(btclib).
-compile(export_all).

-record(btcblk, 
	{ magic,
	  size, 
	  header,
	  n_tx,
	  txs = []}).

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
	  ins = [],
	  n_out,
	  outs = [],
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

sign_blk(Blk) when is_record(Blk, btcblk) ->
    sign_blk(Blk#btcblk.header);
sign_blk(Blkhd) when is_record(Blkhd, btcblkhd) ->
    #btcblkhd{version=Version, 
	      hash_prev_blk=HashPrevBlk, 
	      hash_merkle_root=HashMerkleRoot,
	      time=Time,
	      bits=Bits,
	      nonce=Nonce} = Blkhd,
    Data = <<Version:32/little-unsigned-integer,
	     HashPrevBlk:32/bytes, 
	     HashMerkleRoot:32/bytes, 
	     Time:32/little-unsigned-integer,
	     Bits:32/little-unsigned-integer,
	     Nonce:32/little-unsigned-integer>>,
    sha256(sha256(Data)).
    
parse_blk(Blob) when is_binary(Blob) ->
    parse_txs(
      parse_n_tx(
	parse_blk_hd(
	  chk_blk_size(
	    chk_magic(Blob))))).

chk_magic(<<16#D9B4BEF9:32/little-unsigned-integer, Blob/binary>>) -> 
    {Blob, #btcblk{magic=16#d9b4bef9}}.

chk_blk_size({<<BlockSize:32/little-unsigned-integer, Blob/binary>>, Parsed}) when BlockSize =< size(Blob) ->
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
    
parse_tx_in(<<PrevTxHash:32/bytes, PrevTxOutIndex:32/little-unsigned-integer, Blob/binary>>) ->
    {NewBlob, ScriptLen} = parse_var_len(Blob),
    parse_tx_in_seq_no(
      parse_tx_in_script_sig({NewBlob, #btctxin{prev_tx_hash=PrevTxHash,
						prev_txout_idx=PrevTxOutIndex,
						script_len=ScriptLen}})).

parse_tx_in_script_sig({Blob, Parsed}) ->
    ScriptLen = Parsed#btctxin.script_len,
    <<ScriptBlob:ScriptLen/bytes, NewBlob/binary>> = Blob,
    {NewBlob, Parsed#btctxin{script=parse_script({ScriptBlob, []})}}.

parse_tx_in_seq_no({<<Seq:32/little-unsigned-integer, Blob/binary>>, Parsed}) ->
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
    <<ScriptBlob:ScriptLen/bytes, NewBlob/binary>> = Blob,
    {NewBlob, Parsed#btctxout{script=parse_script({ScriptBlob, []})}}.

parse_tx_lock_time({<<LockTime:32/little-unsigned-integer, Blob/binary>>, Parsed}) ->
    {Blob, Parsed#btctx{lock_time=LockTime}}.

parse_var_len(<<N, Blob/binary>>) when N < 16#fd -> {Blob, N};
parse_var_len(<<16#fd, N:16/little-unsigned-integer, Blob/binary>>) -> {Blob, N};
parse_var_len(<<16#fe, N:32/little-unsigned-integer, Blob/binary>>) -> {Blob, N};
parse_var_len(<<16#ff, N:64/little-unsigned-integer, Blob/binary>>) -> {Blob, N}.

parse_script({<<>>, Script}) ->
    lists:reverse(Script);
parse_script({Blob, Script}) ->
    parse_script(parse_opcode({Blob, Script})).

%% Opcodes with direct inputs (data followed by opcode)

%% DATA1...DATA75
parse_opcode({<<Opcode, Blob/binary>>, Script}) when 1 =< Opcode, Opcode =< 75 ->
    <<Data:Opcode/bytes, NewBlob/binary>> = Blob,
    {NewBlob, [{opcode(Opcode), Data} | Script]};

%% OP_PUSHDATA1, 2, 4
parse_opcode({<<76, DataLen:8/little-unsigned-integer, Blob/binary>>, Script}) ->
    <<Data:DataLen/bytes, NewBlob/binary>> = Blob,
    {NewBlob, [{opcode(76), Data} | Script]};
parse_opcode({<<77, DataLen:16/little-unsigned-integer, Blob/binary>>, Script}) ->
    <<Data:DataLen/bytes, NewBlob/binary>> = Blob,
    {NewBlob, [{opcode(77), Data} | Script]};
parse_opcode({<<78, DataLen:32/little-unsigned-integer, Blob/binary>>, Script}) ->
    <<Data:DataLen/bytes, NewBlob/binary>> = Blob,
    {NewBlob, [{opcode(78), Data} | Script]};

%% Opcodes with no direct inputs (either no inputs at all or inputs implied on stack)

parse_opcode({<<Opcode, Blob/binary>>, Script}) ->
    {Blob, [opcode(Opcode) | Script]}.


%% Opcode table

%% Constants
opcode(0) -> 'OP_0'; 
opcode(1) -> 'DATA1';
opcode(2) -> 'DATA2';
opcode(3) -> 'DATA3';
opcode(4) -> 'DATA4';
opcode(5) -> 'DATA5';
opcode(6) -> 'DATA6';
opcode(7) -> 'DATA7';
opcode(8) -> 'DATA8';
opcode(9) -> 'DATA9';
opcode(10) -> 'DATA10';
opcode(11) -> 'DATA11';
opcode(12) -> 'DATA12';
opcode(13) -> 'DATA13';
opcode(14) -> 'DATA14';
opcode(15) -> 'DATA15';
opcode(16) -> 'DATA16';
opcode(17) -> 'DATA17';
opcode(18) -> 'DATA18';
opcode(19) -> 'DATA19';
opcode(20) -> 'DATA20';
opcode(21) -> 'DATA21';
opcode(22) -> 'DATA22';
opcode(23) -> 'DATA23';
opcode(24) -> 'DATA24';
opcode(25) -> 'DATA25';
opcode(26) -> 'DATA26';
opcode(27) -> 'DATA27';
opcode(28) -> 'DATA28';
opcode(29) -> 'DATA29';
opcode(30) -> 'DATA30';
opcode(31) -> 'DATA31';
opcode(32) -> 'DATA32';
opcode(33) -> 'DATA33';
opcode(34) -> 'DATA34';
opcode(35) -> 'DATA35';
opcode(36) -> 'DATA36';
opcode(37) -> 'DATA37';
opcode(38) -> 'DATA38';
opcode(39) -> 'DATA39';
opcode(40) -> 'DATA40';
opcode(41) -> 'DATA41';
opcode(42) -> 'DATA42';
opcode(43) -> 'DATA43';
opcode(44) -> 'DATA44';
opcode(45) -> 'DATA45';
opcode(46) -> 'DATA46';
opcode(47) -> 'DATA47';
opcode(48) -> 'DATA48';
opcode(49) -> 'DATA49';
opcode(50) -> 'DATA50';
opcode(51) -> 'DATA51';
opcode(52) -> 'DATA52';
opcode(53) -> 'DATA53';
opcode(54) -> 'DATA54';
opcode(55) -> 'DATA55';
opcode(56) -> 'DATA56';
opcode(57) -> 'DATA57';
opcode(58) -> 'DATA58';
opcode(59) -> 'DATA59';
opcode(60) -> 'DATA60';
opcode(61) -> 'DATA61';
opcode(62) -> 'DATA62';
opcode(63) -> 'DATA63';
opcode(64) -> 'DATA64';
opcode(65) -> 'DATA65';
opcode(66) -> 'DATA66';
opcode(67) -> 'DATA67';
opcode(68) -> 'DATA68';
opcode(69) -> 'DATA69';
opcode(70) -> 'DATA70';
opcode(71) -> 'DATA71';
opcode(72) -> 'DATA72';
opcode(73) -> 'DATA73';
opcode(74) -> 'DATA74';
opcode(75) -> 'DATA75';
opcode(76) -> 'OP_PUSHDATA1'; 
opcode(77) -> 'OP_PUSHDATA2';
opcode(78) -> 'OP_PUSHDATA4';
opcode(79) -> 'OP_1NEGATE'; 
opcode(81) -> 'OP_1';
opcode(82) -> 'OP_2';
opcode(83) -> 'OP_3';
opcode(84) -> 'OP_4';
opcode(85) -> 'OP_5';
opcode(86) -> 'OP_6';
opcode(87) -> 'OP_7';
opcode(88) -> 'OP_8';
opcode(89) -> 'OP_9';
opcode(90) -> 'OP_10';
opcode(91) -> 'OP_11';
opcode(92) -> 'OP_12';
opcode(93) -> 'OP_13';
opcode(94) -> 'OP_14';
opcode(95) -> 'OP_15';
opcode(96) -> 'OP_16';

%% Flow Controls
opcode(97) -> 'OP_NOP'; 
opcode(99) -> 'OP_IF'; 
opcode(100) -> 'OP_NOTIF'; 
opcode(103) -> 'OP_ELSE';
opcode(104) -> 'OP_ENDIF';
opcode(105) -> 'OP_VERIFY';
opcode(106) -> 'OP_RETURN';

%% Stack
opcode(107) -> 'OP_TOALTSTACK';
opcode(108) -> 'OP_FROMALTSTACK';
opcode(109) -> 'OP_2DROP';
opcode(110) -> 'OP_2DUP';
opcode(111) -> 'OP_3DUP';
opcode(112) -> 'OP_2OVER';
opcode(113) -> 'OP_2ROT';
opcode(114) -> 'OP_2SWAP';
opcode(115) -> 'OP_IFDUP';
opcode(116) -> 'OP_DEPTH';
opcode(117) -> 'OP_DROP';
opcode(118) -> 'OP_DUP';
opcode(119) -> 'OP_NIP';
opcode(120) -> 'OP_OVER';
opcode(121) -> 'OP_PICK';
opcode(122) -> 'OP_ROLL';
opcode(123) -> 'OP_ROT';
opcode(124) -> 'OP_SWAP';
opcode(125) -> 'OP_TUCK';

%% Splice
opcode(126) -> 'OP_CAT';
opcode(127) -> 'OP_SUBSTR';
opcode(128) -> 'OP_LEFT';
opcode(129) -> 'OP_RIGHT';
opcode(130) -> 'OP_SIZE';

%% Bitwise logic
opcode(131) -> 'OP_INVERT';
opcode(132) -> 'OP_AND';
opcode(133) -> 'OP_OR';
opcode(134) -> 'OP_XOR';
opcode(135) -> 'OP_EQUAL';
opcode(136) -> 'OP_EQUALVERIFY';

%% Arithmetic
opcode(139) -> 'OP_1ADD';
opcode(140) -> 'OP_1SUB';
opcode(141) -> 'OP_2MUL';
opcode(142) -> 'OP_2DIV';
opcode(143) -> 'OP_NEGATE';
opcode(144) -> 'OP_ABS';
opcode(145) -> 'OP_NOT';
opcode(146) -> 'OP_0NOTEQUAL';
opcode(147) -> 'OP_ADD';
opcode(148) -> 'OP_SUB';
opcode(149) -> 'OP_MUL';
opcode(150) -> 'OP_DIV';
opcode(151) -> 'OP_MOD';
opcode(152) -> 'OP_LSHIFT';
opcode(153) -> 'OP_RSHIFT';
opcode(154) -> 'OP_BOOLAND';
opcode(155) -> 'OP_BOOLOR';
opcode(156) -> 'OP_NUMEQUAL';
opcode(157) -> 'OP_NUMEQUALVERIFY';
opcode(158) -> 'OP_NUMNOTEQUAL';
opcode(159) -> 'OP_LESSTHAN';
opcode(160) -> 'OP_GREATERTHAN';
opcode(161) -> 'OP_LESSTHANOREQUAL';
opcode(162) -> 'OP_GREATERTHANOREQUAL';
opcode(163) -> 'OP_MIN';
opcode(164) -> 'OP_MAX';
opcode(165) -> 'OP_WITHIN';

%% Crypto
opcode(166) -> 'OP_RIPEMD160';
opcode(167) -> 'OP_SHA1';
opcode(168) -> 'OP_SHA256';
opcode(169) -> 'OP_HASH160';
opcode(170) -> 'OP_HASH256';
opcode(171) -> 'OP_CODESEPARATOR';
opcode(172) -> 'OP_CHECKSIG';
opcode(173) -> 'OP_CHECKSIGVERIFY';
opcode(174) -> 'OP_CHECKMULTISIG';
opcode(175) -> 'OP_CHECKMULTISIGVERIFY';

%% Pseudo
opcode(253) -> 'OP_PUSHKEYHASH';
opcode(254) -> 'OP_PUBKEY';
opcode(255) -> 'OP_INVALIDOPCODE';

%% Reserved
opcode(80) -> 'OP_RESERVED';
opcode(98) -> 'OP_VER';
opcode(101) -> 'OP_VERIF';
opcode(102) -> 'OP_VERNOTIF';
opcode(137) -> 'OP_RESERVED1';
opcode(138) -> 'OP_RESERVED2';
opcode(176) -> 'OP_NOP1';
opcode(177) -> 'OP_NOP2';
opcode(178) -> 'OP_NOP3';
opcode(179) -> 'OP_NOP4';
opcode(180) -> 'OP_NOP5';
opcode(181) -> 'OP_NOP6';
opcode(182) -> 'OP_NOP7';
opcode(183) -> 'OP_NOP8';
opcode(184) -> 'OP_NOP9';
opcode(185) -> 'OP_NOP10';

opcode(_X) when is_integer(_X)  -> undefined.

%% Interface to SHA256 & RIPEMD160 & EC
sha256(X) ->
    erlsha2:sha256(X).

     
    
    
    
    
	    
		    
    

	    
