-define(BTC_MAGIC, 16#d9b4bef9).

-record(btcmsg, 
	{ magic=?BTC_MAGIC,
	  command,
	  length,
	  checksum,
	  payload }).

-record(btcblk, 
	{ magic=?BTC_MAGIC,
	  size, 
	  header,
	  n_tx,
	  txs = [] }).

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
