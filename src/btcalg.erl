-module(btcalg).
-compile(export_all).

hash256(Blob) when is_binary(Blob) -> erlsha2:sha256(erlsha2:sha256(Blob)).

hash160(Blob) when is_binary(Blob) -> ucrypto:ripemd160(erlsha2:sha256(Blob)).
    
checksum(Blob) when is_binary(Blob) ->
    <<FirstFourBytes:4/bytes, _/binary>> = hash256(Blob),
    FirstFourBytes.


    
