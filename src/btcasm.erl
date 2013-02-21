-module(btcasm).
-compile(export_all).

%% Disassemble

%% Constants
decode(0) -> 'OP_0'; 
decode(1) -> 'DATA1';
decode(2) -> 'DATA2';
decode(3) -> 'DATA3';
decode(4) -> 'DATA4';
decode(5) -> 'DATA5';
decode(6) -> 'DATA6';
decode(7) -> 'DATA7';
decode(8) -> 'DATA8';
decode(9) -> 'DATA9';
decode(10) -> 'DATA10';
decode(11) -> 'DATA11';
decode(12) -> 'DATA12';
decode(13) -> 'DATA13';
decode(14) -> 'DATA14';
decode(15) -> 'DATA15';
decode(16) -> 'DATA16';
decode(17) -> 'DATA17';
decode(18) -> 'DATA18';
decode(19) -> 'DATA19';
decode(20) -> 'DATA20';
decode(21) -> 'DATA21';
decode(22) -> 'DATA22';
decode(23) -> 'DATA23';
decode(24) -> 'DATA24';
decode(25) -> 'DATA25';
decode(26) -> 'DATA26';
decode(27) -> 'DATA27';
decode(28) -> 'DATA28';
decode(29) -> 'DATA29';
decode(30) -> 'DATA30';
decode(31) -> 'DATA31';
decode(32) -> 'DATA32';
decode(33) -> 'DATA33';
decode(34) -> 'DATA34';
decode(35) -> 'DATA35';
decode(36) -> 'DATA36';
decode(37) -> 'DATA37';
decode(38) -> 'DATA38';
decode(39) -> 'DATA39';
decode(40) -> 'DATA40';
decode(41) -> 'DATA41';
decode(42) -> 'DATA42';
decode(43) -> 'DATA43';
decode(44) -> 'DATA44';
decode(45) -> 'DATA45';
decode(46) -> 'DATA46';
decode(47) -> 'DATA47';
decode(48) -> 'DATA48';
decode(49) -> 'DATA49';
decode(50) -> 'DATA50';
decode(51) -> 'DATA51';
decode(52) -> 'DATA52';
decode(53) -> 'DATA53';
decode(54) -> 'DATA54';
decode(55) -> 'DATA55';
decode(56) -> 'DATA56';
decode(57) -> 'DATA57';
decode(58) -> 'DATA58';
decode(59) -> 'DATA59';
decode(60) -> 'DATA60';
decode(61) -> 'DATA61';
decode(62) -> 'DATA62';
decode(63) -> 'DATA63';
decode(64) -> 'DATA64';
decode(65) -> 'DATA65';
decode(66) -> 'DATA66';
decode(67) -> 'DATA67';
decode(68) -> 'DATA68';
decode(69) -> 'DATA69';
decode(70) -> 'DATA70';
decode(71) -> 'DATA71';
decode(72) -> 'DATA72';
decode(73) -> 'DATA73';
decode(74) -> 'DATA74';
decode(75) -> 'DATA75';
decode(76) -> 'OP_PUSHDATA1'; 
decode(77) -> 'OP_PUSHDATA2';
decode(78) -> 'OP_PUSHDATA4';
decode(79) -> 'OP_1NEGATE'; 
decode(81) -> 'OP_1';
decode(82) -> 'OP_2';
decode(83) -> 'OP_3';
decode(84) -> 'OP_4';
decode(85) -> 'OP_5';
decode(86) -> 'OP_6';
decode(87) -> 'OP_7';
decode(88) -> 'OP_8';
decode(89) -> 'OP_9';
decode(90) -> 'OP_10';
decode(91) -> 'OP_11';
decode(92) -> 'OP_12';
decode(93) -> 'OP_13';
decode(94) -> 'OP_14';
decode(95) -> 'OP_15';
decode(96) -> 'OP_16';

%% Flow Controls
decode(97) -> 'OP_NOP'; 
decode(99) -> 'OP_IF'; 
decode(100) -> 'OP_NOTIF'; 
decode(103) -> 'OP_ELSE';
decode(104) -> 'OP_ENDIF';
decode(105) -> 'OP_VERIFY';
decode(106) -> 'OP_RETURN';

%% Stack
decode(107) -> 'OP_TOALTSTACK';
decode(108) -> 'OP_FROMALTSTACK';
decode(109) -> 'OP_2DROP';
decode(110) -> 'OP_2DUP';
decode(111) -> 'OP_3DUP';
decode(112) -> 'OP_2OVER';
decode(113) -> 'OP_2ROT';
decode(114) -> 'OP_2SWAP';
decode(115) -> 'OP_IFDUP';
decode(116) -> 'OP_DEPTH';
decode(117) -> 'OP_DROP';
decode(118) -> 'OP_DUP';
decode(119) -> 'OP_NIP';
decode(120) -> 'OP_OVER';
decode(121) -> 'OP_PICK';
decode(122) -> 'OP_ROLL';
decode(123) -> 'OP_ROT';
decode(124) -> 'OP_SWAP';
decode(125) -> 'OP_TUCK';

%% Splice
decode(126) -> 'OP_CAT';
decode(127) -> 'OP_SUBSTR';
decode(128) -> 'OP_LEFT';
decode(129) -> 'OP_RIGHT';
decode(130) -> 'OP_SIZE';

%% Bitwise logic
decode(131) -> 'OP_INVERT';
decode(132) -> 'OP_AND';
decode(133) -> 'OP_OR';
decode(134) -> 'OP_XOR';
decode(135) -> 'OP_EQUAL';
decode(136) -> 'OP_EQUALVERIFY';

%% Arithmetic
decode(139) -> 'OP_1ADD';
decode(140) -> 'OP_1SUB';
decode(141) -> 'OP_2MUL';
decode(142) -> 'OP_2DIV';
decode(143) -> 'OP_NEGATE';
decode(144) -> 'OP_ABS';
decode(145) -> 'OP_NOT';
decode(146) -> 'OP_0NOTEQUAL';
decode(147) -> 'OP_ADD';
decode(148) -> 'OP_SUB';
decode(149) -> 'OP_MUL';
decode(150) -> 'OP_DIV';
decode(151) -> 'OP_MOD';
decode(152) -> 'OP_LSHIFT';
decode(153) -> 'OP_RSHIFT';
decode(154) -> 'OP_BOOLAND';
decode(155) -> 'OP_BOOLOR';
decode(156) -> 'OP_NUMEQUAL';
decode(157) -> 'OP_NUMEQUALVERIFY';
decode(158) -> 'OP_NUMNOTEQUAL';
decode(159) -> 'OP_LESSTHAN';
decode(160) -> 'OP_GREATERTHAN';
decode(161) -> 'OP_LESSTHANOREQUAL';
decode(162) -> 'OP_GREATERTHANOREQUAL';
decode(163) -> 'OP_MIN';
decode(164) -> 'OP_MAX';
decode(165) -> 'OP_WITHIN';

%% Crypto
decode(166) -> 'OP_RIPEMD160';
decode(167) -> 'OP_SHA1';
decode(168) -> 'OP_SHA256';
decode(169) -> 'OP_HASH160';
decode(170) -> 'OP_HASH256';
decode(171) -> 'OP_CODESEPARATOR';
decode(172) -> 'OP_CHECKSIG';
decode(173) -> 'OP_CHECKSIGVERIFY';
decode(174) -> 'OP_CHECKMULTISIG';
decode(175) -> 'OP_CHECKMULTISIGVERIFY';

%% Pseudo
decode(253) -> 'OP_PUSHKEYHASH';
decode(254) -> 'OP_PUBKEY';
decode(255) -> 'OP_INVALIDDECODE';

%% Reserved
decode(80) -> 'OP_RESERVED';
decode(98) -> 'OP_VER';
decode(101) -> 'OP_VERIF';
decode(102) -> 'OP_VERNOTIF';
decode(137) -> 'OP_RESERVED1';
decode(138) -> 'OP_RESERVED2';
decode(176) -> 'OP_NOP1';
decode(177) -> 'OP_NOP2';
decode(178) -> 'OP_NOP3';
decode(179) -> 'OP_NOP4';
decode(180) -> 'OP_NOP5';
decode(181) -> 'OP_NOP6';
decode(182) -> 'OP_NOP7';
decode(183) -> 'OP_NOP8';
decode(184) -> 'OP_NOP9';
decode(185) -> 'OP_NOP10'.

%% Assemble

%% Constants
encode('OP_0') -> 0; 
encode('DATA1') -> 1;
encode('DATA2') -> 2;
encode('DATA3') -> 3;
encode('DATA4') -> 4;
encode('DATA5') -> 5;
encode('DATA6') -> 6;
encode('DATA7') -> 7;
encode('DATA8') -> 8;
encode('DATA9') -> 9;
encode('DATA10') -> 10;
encode('DATA11') -> 11;
encode('DATA12') -> 12;
encode('DATA13') -> 13;
encode('DATA14') -> 14;
encode('DATA15') -> 15;
encode('DATA16') -> 16;
encode('DATA17') -> 17;
encode('DATA18') -> 18;
encode('DATA19') -> 19;
encode('DATA20') -> 20;
encode('DATA21') -> 21;
encode('DATA22') -> 22;
encode('DATA23') -> 23;
encode('DATA24') -> 24;
encode('DATA25') -> 25;
encode('DATA26') -> 26;
encode('DATA27') -> 27;
encode('DATA28') -> 28;
encode('DATA29') -> 29;
encode('DATA30') -> 30;
encode('DATA31') -> 31;
encode('DATA32') -> 32;
encode('DATA33') -> 33;
encode('DATA34') -> 34;
encode('DATA35') -> 35;
encode('DATA36') -> 36;
encode('DATA37') -> 37;
encode('DATA38') -> 38;
encode('DATA39') -> 39;
encode('DATA40') -> 40;
encode('DATA41') -> 41;
encode('DATA42') -> 42;
encode('DATA43') -> 43;
encode('DATA44') -> 44;
encode('DATA45') -> 45;
encode('DATA46') -> 46;
encode('DATA47') -> 47;
encode('DATA48') -> 48;
encode('DATA49') -> 49;
encode('DATA50') -> 50;
encode('DATA51') -> 51;
encode('DATA52') -> 52;
encode('DATA53') -> 53;
encode('DATA54') -> 54;
encode('DATA55') -> 55;
encode('DATA56') -> 56;
encode('DATA57') -> 57;
encode('DATA58') -> 58;
encode('DATA59') -> 59;
encode('DATA60') -> 60;
encode('DATA61') -> 61;
encode('DATA62') -> 62;
encode('DATA63') -> 63;
encode('DATA64') -> 64;
encode('DATA65') -> 65;
encode('DATA66') -> 66;
encode('DATA67') -> 67;
encode('DATA68') -> 68;
encode('DATA69') -> 69;
encode('DATA70') -> 70;
encode('DATA71') -> 71;
encode('DATA72') -> 72;
encode('DATA73') -> 73;
encode('DATA74') -> 74;
encode('DATA75') -> 75;
encode('OP_PUSHDATA1') -> 76; 
encode('OP_PUSHDATA2') -> 77;
encode('OP_PUSHDATA4') -> 78;
encode('OP_1NEGATE') -> 79; 
encode('OP_1') -> 81;
encode('OP_2') -> 82;
encode('OP_3') -> 83;
encode('OP_4') -> 84;
encode('OP_5') -> 85;
encode('OP_6') -> 86;
encode('OP_7') -> 87;
encode('OP_8') -> 88;
encode('OP_9') -> 89;
encode('OP_10') -> 90;
encode('OP_11') -> 91;
encode('OP_12') -> 92;
encode('OP_13') -> 93;
encode('OP_14') -> 94;
encode('OP_15') -> 95;
encode('OP_16') -> 96;

%% Flow Controls
encode('OP_NOP') -> 97; 
encode('OP_IF') -> 99; 
encode('OP_NOTIF') -> 100; 
encode('OP_ELSE') -> 103;
encode('OP_ENDIF') -> 104;
encode('OP_VERIFY') -> 105;
encode('OP_RETURN') -> 106;

%% Stack
encode('OP_TOALTSTACK') -> 107;
encode('OP_FROMALTSTACK') -> 108;
encode('OP_2DROP') -> 109;
encode('OP_2DUP') -> 110;
encode('OP_3DUP') -> 111;
encode('OP_2OVER') -> 112;
encode('OP_2ROT') -> 113;
encode('OP_2SWAP') -> 114;
encode('OP_IFDUP') -> 115;
encode('OP_DEPTH') -> 116;
encode('OP_DROP') -> 117;
encode('OP_DUP') -> 118;
encode('OP_NIP') -> 119;
encode('OP_OVER') -> 120;
encode('OP_PICK') -> 121;
encode('OP_ROLL') -> 122;
encode('OP_ROT') -> 123;
encode('OP_SWAP') -> 124;
encode('OP_TUCK') -> 125;

%% Splice
encode('OP_CAT') -> 126;
encode('OP_SUBSTR') -> 127;
encode('OP_LEFT') -> 128;
encode('OP_RIGHT') -> 129;
encode('OP_SIZE') -> 130;

%% Bitwise logic
encode('OP_INVERT') -> 131;
encode('OP_AND') -> 132;
encode('OP_OR') -> 133;
encode('OP_XOR') -> 134;
encode('OP_EQUAL') -> 135;
encode('OP_EQUALVERIFY') -> 136;

%% Arithmetic
encode('OP_1ADD') -> 139;
encode('OP_1SUB') -> 140;
encode('OP_2MUL') -> 141;
encode('OP_2DIV') -> 142;
encode('OP_NEGATE') -> 143;
encode('OP_ABS') -> 144;
encode('OP_NOT') -> 145;
encode('OP_0NOTEQUAL') -> 146;
encode('OP_ADD') -> 147;
encode('OP_SUB') -> 148;
encode('OP_MUL') -> 149;
encode('OP_DIV') -> 150;
encode('OP_MOD') -> 151;
encode('OP_LSHIFT') -> 152;
encode('OP_RSHIFT') -> 153;
encode('OP_BOOLAND') -> 154;
encode('OP_BOOLOR') -> 155;
encode('OP_NUMEQUAL') -> 156;
encode('OP_NUMEQUALVERIFY') -> 157;
encode('OP_NUMNOTEQUAL') -> 158;
encode('OP_LESSTHAN') -> 159;
encode('OP_GREATERTHAN') -> 160;
encode('OP_LESSTHANOREQUAL') -> 161;
encode('OP_GREATERTHANOREQUAL') -> 162;
encode('OP_MIN') -> 163;
encode('OP_MAX') -> 164;
encode('OP_WITHIN') -> 165;

%% Crypto
encode('OP_RIPEMD160') -> 166;
encode('OP_SHA1') -> 167;
encode('OP_SHA256') -> 168;
encode('OP_HASH160') -> 169;
encode('OP_HASH256') -> 170;
encode('OP_CODESEPARATOR') -> 171;
encode('OP_CHECKSIG') -> 172;
encode('OP_CHECKSIGVERIFY') -> 173;
encode('OP_CHECKMULTISIG') -> 174;
encode('OP_CHECKMULTISIGVERIFY') -> 175;

%% Pseudo
encode('OP_PUSHKEYHASH') -> 253;
encode('OP_PUBKEY') -> 254;
encode('OP_INVALIDDECODE') -> 255;

%% Reserved
encode('OP_RESERVED') -> 80;
encode('OP_VER') -> 98;
encode('OP_VERIF') -> 101;
encode('OP_VERNOTIF') -> 102;
encode('OP_RESERVED1') -> 137;
encode('OP_RESERVED2') -> 138;
encode('OP_NOP1') -> 176;
encode('OP_NOP2') -> 177;
encode('OP_NOP3') -> 178;
encode('OP_NOP4') -> 179;
encode('OP_NOP5') -> 180;
encode('OP_NOP6') -> 181;
encode('OP_NOP7') -> 182;
encode('OP_NOP8') -> 183;
encode('OP_NOP9') -> 184;
encode('OP_NOP10') -> 185.
     
    
    
    
    
	    
		    
    

	    
