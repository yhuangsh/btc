-module(btcblkhd).
-compile(export_all).

-record(blkhd,
	{ version,
	  prev_block,
	  merkle_root,
	  timestamp,
	  bits,
	  nonce,
	  txn_count}).

%% Constructors
new(Version, Bits) ->
    #blkhd{version = Version, 
	   bits = Bits}.
new(Version, PrevBlock, MerkleRoot, Timestamp, Bits, Nonce, TxnCount) ->
    #blkhd{version = Version,
	   prev_block = PrevBlock,
	   merkle_root = MerkleRoot,
	   timestamp = Timestamp,
	   bits = Bits,
	   nonce = Nonce,
	   txn_count = TxnCount}.

%% Getters
version(#blkhd{version = Version}) -> Version.
prev_block_hash(#blkhd{prev_block = PrevBlock}) -> PrevBlock.
merkle_root(#blkhd{merkle_root = MerkleRoot}) -> MerkleRoot.
timestamp(#blkhd{timestamp = Timestamp}) -> Timestamp.
bits(#blkhd{bits = Bits}) -> Bits.
nonce(#blkhd{nonce = Nonce}) -> Nonce.
txn_count(#blkhd{txn_count = TxnCount}) -> TxnCount.

%% Setters
prev_block_hash(Blkhd, PrevBlock) -> Blkhd#blkhd{prev_block = PrevBlock}.
merkle_root(Blkhd, MerkleRoot) -> Blkhd#blkhd{prev_block = MerkleRoot}.
timestamp(Blkhd, Timestamp) -> Blkhd#blkhd{timestamp = Timestamp}.
bits(Blkhd, Bits) -> Blkhd#blkhd{bits = Bits}.
nonce(Blkhd, Nonce) -> Blkhd#blkhd{nonce = Nonce}.
txn_count(Blkhd, TxnCount) -> Blkhd#blkhd{txn_count = TxnCount}.
    
%% Binary serializers
from_binary(<<Version:32/little-unsigned, 
	      PrevBlock:32/bytes, 
	      MerkleRoot:32/bytes, 
	      Timestamp:32/little-unsigned-integer,
	      Bits:32/little-unsigned-integer,
	      Nonce:32/little-unsigned-integer, 
	      Blob/binary>>) ->
    {NextBlob, TxnCount} = btcvarint:from_binary(Blob),
    {NextBlob, #blkhd{version = Version,
		      prev_block = PrevBlock,
		      merkle_root = MerkleRoot,
		      timestamp = Timestamp,
		      bits = Bits,
		      nonce = Nonce,
		      txn_count = TxnCount}}.

to_binary(#blkhd{version = Version,
		 prev_block = PrevBlock,
		 merkle_root = MerkleRoot,
		 timestamp = Timestamp,
		 bits = Bits,
		 nonce = Nonce,
		 txn_count = TxnCount}) ->
    TxnCountBlob = btcvarint:to_binary(TxnCount),
    <<Version:32/little-unsigned, 
      PrevBlock:32/bytes, 
      MerkleRoot:32/bytes, 
      Timestamp:32/little-unsigned-integer,
      Bits:32/little-unsigned-integer,
      Nonce:32/little-unsigned-integer, 
      TxnCountBlob/binary>>.
