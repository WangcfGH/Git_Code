
local MyJiSuGameReq = {
    UNITE_TYPE={
		lengthMap = {
			-- [1] = dwCardType( unsigned long )	: maxsize = 4,
			-- [2] = dwComPareType( unsigned long )	: maxsize = 4,
			-- [3] = nMainValue( unsigned long )	: maxsize = 4,
			-- [4] = nCardCount( int )	: maxsize = 4,
													-- nCardIDs	: maxsize = 256	=	4 * 64 * 1,
			[5] = { maxlen = 64 },
			maxlen = 5
		},
		nameMap = {
			'dwCardType',		-- [1] ( unsigned long )
			'dwComPareType',		-- [2] ( unsigned long )
			'nMainValue',		-- [3] ( unsigned long )
			'nCardCount',		-- [4] ( int )
			'nCardIDs',		-- [5] ( int )
		},
		formatKey = '<L3i65',
		deformatKey = '<L3i65',
		maxsize = 272
    },
    
    ADJUSTCARD={
		lengthMap = {
			-- [1] = nChairNO( int )	: maxsize = 4,
			-- [2] = bAdjustOver( int )	: maxsize = 4,
													-- cardType	: maxsize = 6528	=	272 * 8 * 3,
			[3] = { maxlen = 8, maxwidth = 3, refered = 'UNITE_TYPE', complexType = 'link_refer' },
													-- cardTypeCount	: maxsize = 12	=	4 * 3 * 1,
			[4] = { maxlen = 3 },
													-- cardMultiple	: maxsize = 12	=	4 * 3 * 1,
			[5] = { maxlen = 3 },
			-- [6] = bAllAdjustOver( int )	: maxsize = 4,
			-- [7] = nUsingQuickOpe( int )	: maxsize = 4,
			-- [8] = nAdjustTime( int )	: maxsize = 4,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[9] = { maxlen = 4 },
			maxlen = 9
		},
		nameMap = {
			'nChairNO',		-- [1] ( int )
			'bAdjustOver',		-- [2] ( int )
			'cardType',		-- [3] ( refer )
			'cardTypeCount',		-- [4] ( int )
			'cardMultiple',		-- [5] ( int )
			'bAllAdjustOver',		-- [6] ( int )
			'nUsingQuickOpe',		-- [7] ( int )
			'nAdjustTime',		-- [8] ( int )
			'nReserved',		-- [9] ( int )
		},
		formatKey = '<i2L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i78',
		deformatKey = '<i2L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i65L3i78',
		maxsize = 6588
	},

	GAME_MSG={
        lengthMap = {
            --,
            maxlen = 5
        },
        nameMap = {
            'nRoomID',
            'nUserID',
            'nMsgID',
            'bNeedEcho',
            'nDatalen'
        },
        formatKey = '<iiiii',
        deformatKey = '<iiiii',
        maxsize = 20
	},

	GAME_WIN={
		lengthMap = {
			-- [1] = dwWinFlags( unsigned long )	: maxsize = 4,
			-- [2] = dwNextFlags( unsigned long )	: maxsize = 4,
			-- [3] = nTotalChairs( int )	: maxsize = 4,
			-- [4] = nBoutCount( int )	: maxsize = 4,
			-- [5] = nBanker( int )	: maxsize = 4,
													-- nPartnerGroup	: maxsize = 32	=	4 * 8 * 1,
			[6] = { maxlen = 8 },
			-- [7] = bBankWin( int )	: maxsize = 4,
													-- nWinPoints	: maxsize = 32	=	4 * 8 * 1,
			[8] = { maxlen = 8 },
			-- [9] = nBaseScore( int )	: maxsize = 4,
			-- [10] = nBaseDeposit( int )	: maxsize = 4,
													-- nOldScores	: maxsize = 32	=	4 * 8 * 1,
			[11] = { maxlen = 8 },
													-- nOldDeposits	: maxsize = 32	=	4 * 8 * 1,
			[12] = { maxlen = 8 },
													-- nScoreDiffs	: maxsize = 32	=	4 * 8 * 1,
			[13] = { maxlen = 8 },
													-- nDepositDiffs	: maxsize = 32	=	4 * 8 * 1,
			[14] = { maxlen = 8 },
													-- nWinFees	: maxsize = 32	=	4 * 8 * 1,
			[15] = { maxlen = 8 },
													-- nLevelIDs	: maxsize = 32	=	4 * 8 * 1,
			[16] = { maxlen = 8 },
													-- szLevelNames	: maxsize = 128	=	1 * 16 * 8,
			[17] = { maxlen = 16, maxwidth = 8, complexType = 'string_group' },
			-- [18] = nNextBaseDeposit( int )	: maxsize = 4,
			-- [19] = nIdlePlayerFlag( int )	: maxsize = 4,
													-- nReserved2	: maxsize = 8	=	4 * 2 * 1,
			[20] = { maxlen = 2 },
			maxlen = 20
		},
		nameMap = {
			'dwWinFlags',		-- [1] ( unsigned long )
			'dwNextFlags',		-- [2] ( unsigned long )
			'nTotalChairs',		-- [3] ( int )
			'nBoutCount',		-- [4] ( int )
			'nBanker',		-- [5] ( int )
			'nPartnerGroup',		-- [6] ( int )
			'bBankWin',		-- [7] ( int )
			'nWinPoints',		-- [8] ( int )
			'nBaseScore',		-- [9] ( int )
			'nBaseDeposit',		-- [10] ( int )
			'nOldScores',		-- [11] ( int )
			'nOldDeposits',		-- [12] ( int )
			'nScoreDiffs',		-- [13] ( int )
			'nDepositDiffs',		-- [14] ( int )
			'nWinFees',		-- [15] ( int )
			'nLevelIDs',		-- [16] ( int )
			'szLevelNames',		-- [17] ( char )
			'nNextBaseDeposit',		-- [18] ( int )
			'nIdlePlayerFlag',		-- [19] ( int )
			'nReserved2',		-- [20] ( int )
		},
		formatKey = '<L2i70A8i4',
		deformatKey = '<L2i70A16A16A16A16A16A16A16A16i4',
		maxsize = 432
	},

	DUN_CARDS={
		lengthMap = {
													-- nCardIDs	: maxsize = 32	=	4 * 8 * 1,
			[1] = { maxlen = 8 },
			maxlen = 1
		},
		nameMap = {
			'nCardIDs',		-- [1] ( int )
		},
		formatKey = '<i8',
		deformatKey = '<i8',
		maxsize = 32
	},
	
	GAME_WIN_RESULT_JS={
		lengthMap = {
													-- gamewin	: 				maxsize = 432,
			[1] = { refered = 'GAME_WIN', complexType = 'link_refer' },
			-- [2] = bnResetGame( int )	: maxsize = 4,
			-- [3] = bEnableLeave( int )	: maxsize = 4,
													-- nPlace	: maxsize = 16	=	4 * 4 * 1,
			[4] = { maxlen = 4 },
													-- nUpRank	: maxsize = 16	=	4 * 4 * 1,
			[5] = { maxlen = 4 },
													-- nNextRank	: maxsize = 16	=	4 * 4 * 1,
			[6] = { maxlen = 4 },
													-- nBombCount	: maxsize = 16	=	4 * 4 * 1,
			[7] = { maxlen = 4 },
													-- nBombBoun	: maxsize = 16	=	4 * 4 * 1,
			[8] = { maxlen = 4 },
													-- nResultBoun	: maxsize = 16	=	4 * 4 * 1,
			[9] = { maxlen = 4 },
													-- nCardID	: maxsize = 528	=	4 * 33 * 4,
			[10] = { maxlen = 33, maxwidth = 4, complexType = 'matrix2' },
													-- nCardCount	: maxsize = 16	=	4 * 4 * 1,
			[11] = { maxlen = 4 },
			-- [12] = nNextBaseScore( int )	: maxsize = 4,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[13] = { maxlen = 4 },
													-- nLevelExpUp	: maxsize = 16	=	4 * 4 * 1,
			[14] = { maxlen = 4 },
													-- nExchangeVouNum	: maxsize = 16	=	4 * 4 * 1,
			[15] = { maxlen = 4 },
													-- nMultiple	: maxsize = 48	=	4 * 3 * 4,
			[16] = { maxlen = 3, maxwidth = 4, complexType = 'matrix2' },
													-- nDunMultiple	: maxsize = 16	=	4 * 4 * 1,
			[17] = { maxlen = 4 },
													-- nExtraMultiple	: maxsize = 16	=	4 * 4 * 1,
			[18] = { maxlen = 4 },
													-- nTotalMultiple	: maxsize = 16	=	4 * 4 * 1,
			[19] = { maxlen = 4 },
													-- nDaQiang	: maxsize = 64	=	4 * 4 * 4,
			[20] = { maxlen = 4, maxwidth = 4, complexType = 'matrix2' },
													-- dunCards	: maxsize = 384	=	32 * 3 * 4,
			[21] = { maxlen = 3, maxwidth = 4, refered = 'DUN_CARDS', complexType = 'link_refer' },
			maxlen = 21
		},
		nameMap = {
			'gamewin',		-- [1] ( refer )
			'bnResetGame',		-- [2] ( int )
			'bEnableLeave',		-- [3] ( int )
			'nPlace',		-- [4] ( int )
			'nUpRank',		-- [5] ( int )
			'nNextRank',		-- [6] ( int )
			'nBombCount',		-- [7] ( int )
			'nBombBoun',		-- [8] ( int )
			'nResultBoun',		-- [9] ( int )
			'nCardID',		-- [10] ( int )
			'nCardCount',		-- [11] ( int )
			'nNextBaseScore',		-- [12] ( int )
			'nReserved',		-- [13] ( int )
			'nLevelExpUp',		-- [14] ( int )
			'nExchangeVouNum',		-- [15] ( int )
			'nMultiple',		-- [16] ( int )
			'nDunMultiple',		-- [17] ( int )
			'nExtraMultiple',		-- [18] ( int )
			'nTotalMultiple',		-- [19] ( int )
			'nDaQiang',		-- [20] ( int )
			'dunCards',		-- [21] ( refer )
		},
		formatKey = '<L2i70A8i315',
		deformatKey = '<L2i70A16A16A16A16A16A16A16A16i315',
		maxsize = 1676
	},

	GAME_INFO_JS={
		lengthMap = {
													-- dunCards	: maxsize = 384	=	32 * 3 * 4,
			[1] = { maxlen = 3, maxwidth = 4, refered = 'DUN_CARDS', complexType = 'link_refer' },
													-- throwedCards	: maxsize = 128	=	4 * 8 * 4,
			[2] = { maxlen = 8, maxwidth = 4, complexType = 'matrix2' },
													-- dunResult	: maxsize = 48	=	4 * 3 * 4,
			[3] = { maxlen = 3, maxwidth = 4, complexType = 'matrix2' },
			-- [4] = currentDunIndex( int )	: maxsize = 4,
													-- adjustOver	: maxsize = 16	=	4 * 4 * 1,
			[5] = { maxlen = 4 },
			maxlen = 5
		},
		nameMap = {
			'dunCards',		-- [1] ( refer )
			'throwedCards',		-- [2] ( int )
			'dunResult',		-- [3] ( int )
			'currentDunIndex',		-- [4] ( int )
			'adjustOver',		-- [5] ( int )
		},
		formatKey = '<i145',
		deformatKey = '<i145',
		maxsize = 580
	},

	GAME_TABLE_INFO_JS={
		lengthMap = {
													-- szSerialNO	: maxsize = 32	=	1 * 32 * 1,
			[1] = 32,
			-- [2] = nBoutCount( int )	: maxsize = 4,
			-- [3] = nBaseDeposit( int )	: maxsize = 4,
			-- [4] = nBaseScore( int )	: maxsize = 4,
			-- [5] = bNeedDeposit( int )	: maxsize = 4,
			-- [6] = bForbidDesert( int )	: maxsize = 4,
			-- [7] = nBanker( int )	: maxsize = 4,
			-- [8] = nCurrentChair( int )	: maxsize = 4,
			-- [9] = dwStatus( unsigned long )	: maxsize = 4,
			-- [10] = nThrowWait( int )	: maxsize = 4,
			-- [11] = nAutoGiveUp( int )	: maxsize = 4,
			-- [12] = nOffline( int )	: maxsize = 4,
			-- [13] = nInHandCount( int )	: maxsize = 4,
													-- nThrowWaitEx	: maxsize = 12	=	4 * 3 * 1,
			[14] = { maxlen = 3 },
													-- nRank	: maxsize = 16	=	4 * 4 * 1,
			[15] = { maxlen = 4 },
													-- nRound	: maxsize = 16	=	4 * 4 * 1,
			[16] = { maxlen = 4 },
			-- [17] = nCurrentRank( int )	: maxsize = 4,
			-- [18] = bnTribute( int )	: maxsize = 4,
			-- [19] = winner( int )	: maxsize = 4,
			-- [20] = nCardID( int )	: maxsize = 4,
			-- [21] = bnFight( int )	: maxsize = 4,
													-- nFightID	: maxsize = 8	=	4 * 2 * 1,
			[22] = { maxlen = 2 },
			-- [23] = bnTribute1( int )	: maxsize = 4,
			-- [24] = winner1( int )	: maxsize = 4,
			-- [25] = nCardID1( int )	: maxsize = 4,
			-- [26] = bnFight1( int )	: maxsize = 4,
													-- nFightID1	: maxsize = 8	=	4 * 2 * 1,
			[27] = { maxlen = 2 },
			-- [28] = bnTribute2( int )	: maxsize = 4,
			-- [29] = winner2( int )	: maxsize = 4,
			-- [30] = nCardID2( int )	: maxsize = 4,
			-- [31] = bnFight2( int )	: maxsize = 4,
													-- nFightID2	: maxsize = 8	=	4 * 2 * 1,
			[32] = { maxlen = 2 },
			-- [33] = bnTribute3( int )	: maxsize = 4,
			-- [34] = winner3( int )	: maxsize = 4,
			-- [35] = nCardID3( int )	: maxsize = 4,
			-- [36] = bnFight3( int )	: maxsize = 4,
													-- nFightID3	: maxsize = 8	=	4 * 2 * 1,
			[37] = { maxlen = 2 },
													-- nPlace	: maxsize = 16	=	4 * 4 * 1,
			[38] = { maxlen = 4 },
			-- [39] = bnShowRank( int )	: maxsize = 4,
			-- [40] = bnResetGame( int )	: maxsize = 4,
													-- nHandID	: maxsize = 132	=	4 * 33 * 1,
			[41] = { maxlen = 33 },
													-- nFriendID	: maxsize = 132	=	4 * 33 * 1,
			[42] = { maxlen = 33 },
													-- nFaceID	: maxsize = 16	=	4 * 4 * 1,
			[43] = { maxlen = 4 },
													-- nLastScoreDiffs	: maxsize = 16	=	4 * 4 * 1,
			[44] = { maxlen = 4 },
													-- nTotalScoreDiffs	: maxsize = 16	=	4 * 4 * 1,
			[45] = { maxlen = 4 },
			-- [46] = bnCardMasterChairUse( int )	: maxsize = 4,
			-- [47] = nObjectGains( int )	: maxsize = 4,
			-- [48] = nFanPaiCardID( int )	: maxsize = 4,
			-- [49] = nRanker( int )	: maxsize = 4,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[50] = { maxlen = 4 },
			-- [51] = nWaitChair( int )	: maxsize = 4,
			-- [52] = dwCardType( unsigned long )	: maxsize = 4,
			-- [53] = dwComPareType( unsigned long )	: maxsize = 4,
			-- [54] = nMainValue( unsigned long )	: maxsize = 4,
			-- [55] = nCardCount( int )	: maxsize = 4,
													-- nCardIDs	: maxsize = 256	=	4 * 64 * 1,
			[56] = { maxlen = 64 },
			-- [57] = nCurrentCatch( int )	: maxsize = 4,
			-- [58] = nCurrentRank1( int )	: maxsize = 4,
													-- dwUserStatus	: maxsize = 32	=	4 * 8 * 1,
			[59] = { maxlen = 8 },
			-- [60] = nCardID4( int )	: maxsize = 4,
			-- [61] = nCardIndex( int )	: maxsize = 4,
			-- [62] = nShape( int )	: maxsize = 4,
			-- [63] = nValue( int )	: maxsize = 4,
			-- [64] = nCardStatus( int )	: maxsize = 4,
			-- [65] = nChairNO( int )	: maxsize = 4,
			-- [66] = nPositionIndex( int )	: maxsize = 4,
			-- [67] = nUniteCount( int )	: maxsize = 4,
			-- [68] = nCardID5( int )	: maxsize = 4,
			-- [69] = nCardIndex1( int )	: maxsize = 4,
			-- [70] = nShape1( int )	: maxsize = 4,
			-- [71] = nValue1( int )	: maxsize = 4,
			-- [72] = nCardStatus1( int )	: maxsize = 4,
			-- [73] = nChairNO1( int )	: maxsize = 4,
			-- [74] = nPositionIndex1( int )	: maxsize = 4,
			-- [75] = nUniteCount1( int )	: maxsize = 4,
			-- [76] = nCardID6( int )	: maxsize = 4,
			-- [77] = nCardIndex2( int )	: maxsize = 4,
			-- [78] = nShape2( int )	: maxsize = 4,
			-- [79] = nValue2( int )	: maxsize = 4,
			-- [80] = nCardStatus2( int )	: maxsize = 4,
			-- [81] = nChairNO2( int )	: maxsize = 4,
			-- [82] = nPositionIndex2( int )	: maxsize = 4,
			-- [83] = nUniteCount2( int )	: maxsize = 4,
			-- [84] = nCardID7( int )	: maxsize = 4,
			-- [85] = nCardIndex3( int )	: maxsize = 4,
			-- [86] = nShape3( int )	: maxsize = 4,
			-- [87] = nValue3( int )	: maxsize = 4,
			-- [88] = nCardStatus3( int )	: maxsize = 4,
			-- [89] = nChairNO3( int )	: maxsize = 4,
			-- [90] = nPositionIndex3( int )	: maxsize = 4,
			-- [91] = nUniteCount3( int )	: maxsize = 4,
			-- [92] = nCardID8( int )	: maxsize = 4,
			-- [93] = nCardIndex4( int )	: maxsize = 4,
			-- [94] = nShape4( int )	: maxsize = 4,
			-- [95] = nValue4( int )	: maxsize = 4,
			-- [96] = nCardStatus4( int )	: maxsize = 4,
			-- [97] = nChairNO4( int )	: maxsize = 4,
			-- [98] = nPositionIndex4( int )	: maxsize = 4,
			-- [99] = nUniteCount4( int )	: maxsize = 4,
			-- [100] = nCardID9( int )	: maxsize = 4,
			-- [101] = nCardIndex5( int )	: maxsize = 4,
			-- [102] = nShape5( int )	: maxsize = 4,
			-- [103] = nValue5( int )	: maxsize = 4,
			-- [104] = nCardStatus5( int )	: maxsize = 4,
			-- [105] = nChairNO5( int )	: maxsize = 4,
			-- [106] = nPositionIndex5( int )	: maxsize = 4,
			-- [107] = nUniteCount5( int )	: maxsize = 4,
			-- [108] = nCardID10( int )	: maxsize = 4,
			-- [109] = nCardIndex6( int )	: maxsize = 4,
			-- [110] = nShape6( int )	: maxsize = 4,
			-- [111] = nValue6( int )	: maxsize = 4,
			-- [112] = nCardStatus6( int )	: maxsize = 4,
			-- [113] = nChairNO6( int )	: maxsize = 4,
			-- [114] = nPositionIndex6( int )	: maxsize = 4,
			-- [115] = nUniteCount6( int )	: maxsize = 4,
			-- [116] = nCardID11( int )	: maxsize = 4,
			-- [117] = nCardIndex7( int )	: maxsize = 4,
			-- [118] = nShape7( int )	: maxsize = 4,
			-- [119] = nValue7( int )	: maxsize = 4,
			-- [120] = nCardStatus7( int )	: maxsize = 4,
			-- [121] = nChairNO7( int )	: maxsize = 4,
			-- [122] = nPositionIndex7( int )	: maxsize = 4,
			-- [123] = nUniteCount7( int )	: maxsize = 4,
			-- [124] = nCardID12( int )	: maxsize = 4,
			-- [125] = nCardIndex8( int )	: maxsize = 4,
			-- [126] = nShape8( int )	: maxsize = 4,
			-- [127] = nValue8( int )	: maxsize = 4,
			-- [128] = nCardStatus8( int )	: maxsize = 4,
			-- [129] = nChairNO8( int )	: maxsize = 4,
			-- [130] = nPositionIndex8( int )	: maxsize = 4,
			-- [131] = nUniteCount8( int )	: maxsize = 4,
			-- [132] = nCardID13( int )	: maxsize = 4,
			-- [133] = nCardIndex9( int )	: maxsize = 4,
			-- [134] = nShape9( int )	: maxsize = 4,
			-- [135] = nValue9( int )	: maxsize = 4,
			-- [136] = nCardStatus9( int )	: maxsize = 4,
			-- [137] = nChairNO9( int )	: maxsize = 4,
			-- [138] = nPositionIndex9( int )	: maxsize = 4,
			-- [139] = nUniteCount9( int )	: maxsize = 4,
			-- [140] = nCardID14( int )	: maxsize = 4,
			-- [141] = nCardIndex10( int )	: maxsize = 4,
			-- [142] = nShape10( int )	: maxsize = 4,
			-- [143] = nValue10( int )	: maxsize = 4,
			-- [144] = nCardStatus10( int )	: maxsize = 4,
			-- [145] = nChairNO10( int )	: maxsize = 4,
			-- [146] = nPositionIndex10( int )	: maxsize = 4,
			-- [147] = nUniteCount10( int )	: maxsize = 4,
			-- [148] = nCardID15( int )	: maxsize = 4,
			-- [149] = nCardIndex11( int )	: maxsize = 4,
			-- [150] = nShape11( int )	: maxsize = 4,
			-- [151] = nValue11( int )	: maxsize = 4,
			-- [152] = nCardStatus11( int )	: maxsize = 4,
			-- [153] = nChairNO11( int )	: maxsize = 4,
			-- [154] = nPositionIndex11( int )	: maxsize = 4,
			-- [155] = nUniteCount11( int )	: maxsize = 4,
			-- [156] = nCardID16( int )	: maxsize = 4,
			-- [157] = nCardIndex12( int )	: maxsize = 4,
			-- [158] = nShape12( int )	: maxsize = 4,
			-- [159] = nValue12( int )	: maxsize = 4,
			-- [160] = nCardStatus12( int )	: maxsize = 4,
			-- [161] = nChairNO12( int )	: maxsize = 4,
			-- [162] = nPositionIndex12( int )	: maxsize = 4,
			-- [163] = nUniteCount12( int )	: maxsize = 4,
			-- [164] = nCardID17( int )	: maxsize = 4,
			-- [165] = nCardIndex13( int )	: maxsize = 4,
			-- [166] = nShape13( int )	: maxsize = 4,
			-- [167] = nValue13( int )	: maxsize = 4,
			-- [168] = nCardStatus13( int )	: maxsize = 4,
			-- [169] = nChairNO13( int )	: maxsize = 4,
			-- [170] = nPositionIndex13( int )	: maxsize = 4,
			-- [171] = nUniteCount13( int )	: maxsize = 4,
			-- [172] = nCardID18( int )	: maxsize = 4,
			-- [173] = nCardIndex14( int )	: maxsize = 4,
			-- [174] = nShape14( int )	: maxsize = 4,
			-- [175] = nValue14( int )	: maxsize = 4,
			-- [176] = nCardStatus14( int )	: maxsize = 4,
			-- [177] = nChairNO14( int )	: maxsize = 4,
			-- [178] = nPositionIndex14( int )	: maxsize = 4,
			-- [179] = nUniteCount14( int )	: maxsize = 4,
			-- [180] = nCardID19( int )	: maxsize = 4,
			-- [181] = nCardIndex15( int )	: maxsize = 4,
			-- [182] = nShape15( int )	: maxsize = 4,
			-- [183] = nValue15( int )	: maxsize = 4,
			-- [184] = nCardStatus15( int )	: maxsize = 4,
			-- [185] = nChairNO15( int )	: maxsize = 4,
			-- [186] = nPositionIndex15( int )	: maxsize = 4,
			-- [187] = nUniteCount15( int )	: maxsize = 4,
			-- [188] = nCardID20( int )	: maxsize = 4,
			-- [189] = nCardIndex16( int )	: maxsize = 4,
			-- [190] = nShape16( int )	: maxsize = 4,
			-- [191] = nValue16( int )	: maxsize = 4,
			-- [192] = nCardStatus16( int )	: maxsize = 4,
			-- [193] = nChairNO16( int )	: maxsize = 4,
			-- [194] = nPositionIndex16( int )	: maxsize = 4,
			-- [195] = nUniteCount16( int )	: maxsize = 4,
			-- [196] = nCardID21( int )	: maxsize = 4,
			-- [197] = nCardIndex17( int )	: maxsize = 4,
			-- [198] = nShape17( int )	: maxsize = 4,
			-- [199] = nValue17( int )	: maxsize = 4,
			-- [200] = nCardStatus17( int )	: maxsize = 4,
			-- [201] = nChairNO17( int )	: maxsize = 4,
			-- [202] = nPositionIndex17( int )	: maxsize = 4,
			-- [203] = nUniteCount17( int )	: maxsize = 4,
			-- [204] = nCardID22( int )	: maxsize = 4,
			-- [205] = nCardIndex18( int )	: maxsize = 4,
			-- [206] = nShape18( int )	: maxsize = 4,
			-- [207] = nValue18( int )	: maxsize = 4,
			-- [208] = nCardStatus18( int )	: maxsize = 4,
			-- [209] = nChairNO18( int )	: maxsize = 4,
			-- [210] = nPositionIndex18( int )	: maxsize = 4,
			-- [211] = nUniteCount18( int )	: maxsize = 4,
			-- [212] = nCardID23( int )	: maxsize = 4,
			-- [213] = nCardIndex19( int )	: maxsize = 4,
			-- [214] = nShape19( int )	: maxsize = 4,
			-- [215] = nValue19( int )	: maxsize = 4,
			-- [216] = nCardStatus19( int )	: maxsize = 4,
			-- [217] = nChairNO19( int )	: maxsize = 4,
			-- [218] = nPositionIndex19( int )	: maxsize = 4,
			-- [219] = nUniteCount19( int )	: maxsize = 4,
			-- [220] = nCardID24( int )	: maxsize = 4,
			-- [221] = nCardIndex20( int )	: maxsize = 4,
			-- [222] = nShape20( int )	: maxsize = 4,
			-- [223] = nValue20( int )	: maxsize = 4,
			-- [224] = nCardStatus20( int )	: maxsize = 4,
			-- [225] = nChairNO20( int )	: maxsize = 4,
			-- [226] = nPositionIndex20( int )	: maxsize = 4,
			-- [227] = nUniteCount20( int )	: maxsize = 4,
			-- [228] = nCardID25( int )	: maxsize = 4,
			-- [229] = nCardIndex21( int )	: maxsize = 4,
			-- [230] = nShape21( int )	: maxsize = 4,
			-- [231] = nValue21( int )	: maxsize = 4,
			-- [232] = nCardStatus21( int )	: maxsize = 4,
			-- [233] = nChairNO21( int )	: maxsize = 4,
			-- [234] = nPositionIndex21( int )	: maxsize = 4,
			-- [235] = nUniteCount21( int )	: maxsize = 4,
			-- [236] = nCardID26( int )	: maxsize = 4,
			-- [237] = nCardIndex22( int )	: maxsize = 4,
			-- [238] = nShape22( int )	: maxsize = 4,
			-- [239] = nValue22( int )	: maxsize = 4,
			-- [240] = nCardStatus22( int )	: maxsize = 4,
			-- [241] = nChairNO22( int )	: maxsize = 4,
			-- [242] = nPositionIndex22( int )	: maxsize = 4,
			-- [243] = nUniteCount22( int )	: maxsize = 4,
			-- [244] = nCardID27( int )	: maxsize = 4,
			-- [245] = nCardIndex23( int )	: maxsize = 4,
			-- [246] = nShape23( int )	: maxsize = 4,
			-- [247] = nValue23( int )	: maxsize = 4,
			-- [248] = nCardStatus23( int )	: maxsize = 4,
			-- [249] = nChairNO23( int )	: maxsize = 4,
			-- [250] = nPositionIndex23( int )	: maxsize = 4,
			-- [251] = nUniteCount23( int )	: maxsize = 4,
			-- [252] = nCardID28( int )	: maxsize = 4,
			-- [253] = nCardIndex24( int )	: maxsize = 4,
			-- [254] = nShape24( int )	: maxsize = 4,
			-- [255] = nValue24( int )	: maxsize = 4,
			-- [256] = nCardStatus24( int )	: maxsize = 4,
			-- [257] = nChairNO24( int )	: maxsize = 4,
			-- [258] = nPositionIndex24( int )	: maxsize = 4,
			-- [259] = nUniteCount24( int )	: maxsize = 4,
			-- [260] = nCardID29( int )	: maxsize = 4,
			-- [261] = nCardIndex25( int )	: maxsize = 4,
			-- [262] = nShape25( int )	: maxsize = 4,
			-- [263] = nValue25( int )	: maxsize = 4,
			-- [264] = nCardStatus25( int )	: maxsize = 4,
			-- [265] = nChairNO25( int )	: maxsize = 4,
			-- [266] = nPositionIndex25( int )	: maxsize = 4,
			-- [267] = nUniteCount25( int )	: maxsize = 4,
			-- [268] = nCardID30( int )	: maxsize = 4,
			-- [269] = nCardIndex26( int )	: maxsize = 4,
			-- [270] = nShape26( int )	: maxsize = 4,
			-- [271] = nValue26( int )	: maxsize = 4,
			-- [272] = nCardStatus26( int )	: maxsize = 4,
			-- [273] = nChairNO26( int )	: maxsize = 4,
			-- [274] = nPositionIndex26( int )	: maxsize = 4,
			-- [275] = nUniteCount26( int )	: maxsize = 4,
			-- [276] = nCardID31( int )	: maxsize = 4,
			-- [277] = nCardIndex27( int )	: maxsize = 4,
			-- [278] = nShape27( int )	: maxsize = 4,
			-- [279] = nValue27( int )	: maxsize = 4,
			-- [280] = nCardStatus27( int )	: maxsize = 4,
			-- [281] = nChairNO27( int )	: maxsize = 4,
			-- [282] = nPositionIndex27( int )	: maxsize = 4,
			-- [283] = nUniteCount27( int )	: maxsize = 4,
			-- [284] = nCardID32( int )	: maxsize = 4,
			-- [285] = nCardIndex28( int )	: maxsize = 4,
			-- [286] = nShape28( int )	: maxsize = 4,
			-- [287] = nValue28( int )	: maxsize = 4,
			-- [288] = nCardStatus28( int )	: maxsize = 4,
			-- [289] = nChairNO28( int )	: maxsize = 4,
			-- [290] = nPositionIndex28( int )	: maxsize = 4,
			-- [291] = nUniteCount28( int )	: maxsize = 4,
			-- [292] = nCardID33( int )	: maxsize = 4,
			-- [293] = nCardIndex29( int )	: maxsize = 4,
			-- [294] = nShape29( int )	: maxsize = 4,
			-- [295] = nValue29( int )	: maxsize = 4,
			-- [296] = nCardStatus29( int )	: maxsize = 4,
			-- [297] = nChairNO29( int )	: maxsize = 4,
			-- [298] = nPositionIndex29( int )	: maxsize = 4,
			-- [299] = nUniteCount29( int )	: maxsize = 4,
			-- [300] = nCardID34( int )	: maxsize = 4,
			-- [301] = nCardIndex30( int )	: maxsize = 4,
			-- [302] = nShape30( int )	: maxsize = 4,
			-- [303] = nValue30( int )	: maxsize = 4,
			-- [304] = nCardStatus30( int )	: maxsize = 4,
			-- [305] = nChairNO30( int )	: maxsize = 4,
			-- [306] = nPositionIndex30( int )	: maxsize = 4,
			-- [307] = nUniteCount30( int )	: maxsize = 4,
			-- [308] = nCardID35( int )	: maxsize = 4,
			-- [309] = nCardIndex31( int )	: maxsize = 4,
			-- [310] = nShape31( int )	: maxsize = 4,
			-- [311] = nValue31( int )	: maxsize = 4,
			-- [312] = nCardStatus31( int )	: maxsize = 4,
			-- [313] = nChairNO31( int )	: maxsize = 4,
			-- [314] = nPositionIndex31( int )	: maxsize = 4,
			-- [315] = nUniteCount31( int )	: maxsize = 4,
			-- [316] = nCardID36( int )	: maxsize = 4,
			-- [317] = nCardIndex32( int )	: maxsize = 4,
			-- [318] = nShape32( int )	: maxsize = 4,
			-- [319] = nValue32( int )	: maxsize = 4,
			-- [320] = nCardStatus32( int )	: maxsize = 4,
			-- [321] = nChairNO32( int )	: maxsize = 4,
			-- [322] = nPositionIndex32( int )	: maxsize = 4,
			-- [323] = nUniteCount32( int )	: maxsize = 4,
			-- [324] = nCardID37( int )	: maxsize = 4,
			-- [325] = nCardIndex33( int )	: maxsize = 4,
			-- [326] = nShape33( int )	: maxsize = 4,
			-- [327] = nValue33( int )	: maxsize = 4,
			-- [328] = nCardStatus33( int )	: maxsize = 4,
			-- [329] = nChairNO33( int )	: maxsize = 4,
			-- [330] = nPositionIndex33( int )	: maxsize = 4,
			-- [331] = nUniteCount33( int )	: maxsize = 4,
			-- [332] = nCardID38( int )	: maxsize = 4,
			-- [333] = nCardIndex34( int )	: maxsize = 4,
			-- [334] = nShape34( int )	: maxsize = 4,
			-- [335] = nValue34( int )	: maxsize = 4,
			-- [336] = nCardStatus34( int )	: maxsize = 4,
			-- [337] = nChairNO34( int )	: maxsize = 4,
			-- [338] = nPositionIndex34( int )	: maxsize = 4,
			-- [339] = nUniteCount34( int )	: maxsize = 4,
			-- [340] = nCardID39( int )	: maxsize = 4,
			-- [341] = nCardIndex35( int )	: maxsize = 4,
			-- [342] = nShape35( int )	: maxsize = 4,
			-- [343] = nValue35( int )	: maxsize = 4,
			-- [344] = nCardStatus35( int )	: maxsize = 4,
			-- [345] = nChairNO35( int )	: maxsize = 4,
			-- [346] = nPositionIndex35( int )	: maxsize = 4,
			-- [347] = nUniteCount35( int )	: maxsize = 4,
			-- [348] = nCardID40( int )	: maxsize = 4,
			-- [349] = nCardIndex36( int )	: maxsize = 4,
			-- [350] = nShape36( int )	: maxsize = 4,
			-- [351] = nValue36( int )	: maxsize = 4,
			-- [352] = nCardStatus36( int )	: maxsize = 4,
			-- [353] = nChairNO36( int )	: maxsize = 4,
			-- [354] = nPositionIndex36( int )	: maxsize = 4,
			-- [355] = nUniteCount36( int )	: maxsize = 4,
			-- [356] = nCardID41( int )	: maxsize = 4,
			-- [357] = nCardIndex37( int )	: maxsize = 4,
			-- [358] = nShape37( int )	: maxsize = 4,
			-- [359] = nValue37( int )	: maxsize = 4,
			-- [360] = nCardStatus37( int )	: maxsize = 4,
			-- [361] = nChairNO37( int )	: maxsize = 4,
			-- [362] = nPositionIndex37( int )	: maxsize = 4,
			-- [363] = nUniteCount37( int )	: maxsize = 4,
			-- [364] = nCardID42( int )	: maxsize = 4,
			-- [365] = nCardIndex38( int )	: maxsize = 4,
			-- [366] = nShape38( int )	: maxsize = 4,
			-- [367] = nValue38( int )	: maxsize = 4,
			-- [368] = nCardStatus38( int )	: maxsize = 4,
			-- [369] = nChairNO38( int )	: maxsize = 4,
			-- [370] = nPositionIndex38( int )	: maxsize = 4,
			-- [371] = nUniteCount38( int )	: maxsize = 4,
			-- [372] = nCardID43( int )	: maxsize = 4,
			-- [373] = nCardIndex39( int )	: maxsize = 4,
			-- [374] = nShape39( int )	: maxsize = 4,
			-- [375] = nValue39( int )	: maxsize = 4,
			-- [376] = nCardStatus39( int )	: maxsize = 4,
			-- [377] = nChairNO39( int )	: maxsize = 4,
			-- [378] = nPositionIndex39( int )	: maxsize = 4,
			-- [379] = nUniteCount39( int )	: maxsize = 4,
			-- [380] = nCardID44( int )	: maxsize = 4,
			-- [381] = nCardIndex40( int )	: maxsize = 4,
			-- [382] = nShape40( int )	: maxsize = 4,
			-- [383] = nValue40( int )	: maxsize = 4,
			-- [384] = nCardStatus40( int )	: maxsize = 4,
			-- [385] = nChairNO40( int )	: maxsize = 4,
			-- [386] = nPositionIndex40( int )	: maxsize = 4,
			-- [387] = nUniteCount40( int )	: maxsize = 4,
			-- [388] = nCardID45( int )	: maxsize = 4,
			-- [389] = nCardIndex41( int )	: maxsize = 4,
			-- [390] = nShape41( int )	: maxsize = 4,
			-- [391] = nValue41( int )	: maxsize = 4,
			-- [392] = nCardStatus41( int )	: maxsize = 4,
			-- [393] = nChairNO41( int )	: maxsize = 4,
			-- [394] = nPositionIndex41( int )	: maxsize = 4,
			-- [395] = nUniteCount41( int )	: maxsize = 4,
			-- [396] = nCardID46( int )	: maxsize = 4,
			-- [397] = nCardIndex42( int )	: maxsize = 4,
			-- [398] = nShape42( int )	: maxsize = 4,
			-- [399] = nValue42( int )	: maxsize = 4,
			-- [400] = nCardStatus42( int )	: maxsize = 4,
			-- [401] = nChairNO42( int )	: maxsize = 4,
			-- [402] = nPositionIndex42( int )	: maxsize = 4,
			-- [403] = nUniteCount42( int )	: maxsize = 4,
			-- [404] = nCardID47( int )	: maxsize = 4,
			-- [405] = nCardIndex43( int )	: maxsize = 4,
			-- [406] = nShape43( int )	: maxsize = 4,
			-- [407] = nValue43( int )	: maxsize = 4,
			-- [408] = nCardStatus43( int )	: maxsize = 4,
			-- [409] = nChairNO43( int )	: maxsize = 4,
			-- [410] = nPositionIndex43( int )	: maxsize = 4,
			-- [411] = nUniteCount43( int )	: maxsize = 4,
			-- [412] = nCardID48( int )	: maxsize = 4,
			-- [413] = nCardIndex44( int )	: maxsize = 4,
			-- [414] = nShape44( int )	: maxsize = 4,
			-- [415] = nValue44( int )	: maxsize = 4,
			-- [416] = nCardStatus44( int )	: maxsize = 4,
			-- [417] = nChairNO44( int )	: maxsize = 4,
			-- [418] = nPositionIndex44( int )	: maxsize = 4,
			-- [419] = nUniteCount44( int )	: maxsize = 4,
			-- [420] = nCardID49( int )	: maxsize = 4,
			-- [421] = nCardIndex45( int )	: maxsize = 4,
			-- [422] = nShape45( int )	: maxsize = 4,
			-- [423] = nValue45( int )	: maxsize = 4,
			-- [424] = nCardStatus45( int )	: maxsize = 4,
			-- [425] = nChairNO45( int )	: maxsize = 4,
			-- [426] = nPositionIndex45( int )	: maxsize = 4,
			-- [427] = nUniteCount45( int )	: maxsize = 4,
			-- [428] = nCardID50( int )	: maxsize = 4,
			-- [429] = nCardIndex46( int )	: maxsize = 4,
			-- [430] = nShape46( int )	: maxsize = 4,
			-- [431] = nValue46( int )	: maxsize = 4,
			-- [432] = nCardStatus46( int )	: maxsize = 4,
			-- [433] = nChairNO46( int )	: maxsize = 4,
			-- [434] = nPositionIndex46( int )	: maxsize = 4,
			-- [435] = nUniteCount46( int )	: maxsize = 4,
			-- [436] = nCardID51( int )	: maxsize = 4,
			-- [437] = nCardIndex47( int )	: maxsize = 4,
			-- [438] = nShape47( int )	: maxsize = 4,
			-- [439] = nValue47( int )	: maxsize = 4,
			-- [440] = nCardStatus47( int )	: maxsize = 4,
			-- [441] = nChairNO47( int )	: maxsize = 4,
			-- [442] = nPositionIndex47( int )	: maxsize = 4,
			-- [443] = nUniteCount47( int )	: maxsize = 4,
			-- [444] = nCardID52( int )	: maxsize = 4,
			-- [445] = nCardIndex48( int )	: maxsize = 4,
			-- [446] = nShape48( int )	: maxsize = 4,
			-- [447] = nValue48( int )	: maxsize = 4,
			-- [448] = nCardStatus48( int )	: maxsize = 4,
			-- [449] = nChairNO48( int )	: maxsize = 4,
			-- [450] = nPositionIndex48( int )	: maxsize = 4,
			-- [451] = nUniteCount48( int )	: maxsize = 4,
			-- [452] = nCardID53( int )	: maxsize = 4,
			-- [453] = nCardIndex49( int )	: maxsize = 4,
			-- [454] = nShape49( int )	: maxsize = 4,
			-- [455] = nValue49( int )	: maxsize = 4,
			-- [456] = nCardStatus49( int )	: maxsize = 4,
			-- [457] = nChairNO49( int )	: maxsize = 4,
			-- [458] = nPositionIndex49( int )	: maxsize = 4,
			-- [459] = nUniteCount49( int )	: maxsize = 4,
			-- [460] = nCardID54( int )	: maxsize = 4,
			-- [461] = nCardIndex50( int )	: maxsize = 4,
			-- [462] = nShape50( int )	: maxsize = 4,
			-- [463] = nValue50( int )	: maxsize = 4,
			-- [464] = nCardStatus50( int )	: maxsize = 4,
			-- [465] = nChairNO50( int )	: maxsize = 4,
			-- [466] = nPositionIndex50( int )	: maxsize = 4,
			-- [467] = nUniteCount50( int )	: maxsize = 4,
			-- [468] = nCardID55( int )	: maxsize = 4,
			-- [469] = nCardIndex51( int )	: maxsize = 4,
			-- [470] = nShape51( int )	: maxsize = 4,
			-- [471] = nValue51( int )	: maxsize = 4,
			-- [472] = nCardStatus51( int )	: maxsize = 4,
			-- [473] = nChairNO51( int )	: maxsize = 4,
			-- [474] = nPositionIndex51( int )	: maxsize = 4,
			-- [475] = nUniteCount51( int )	: maxsize = 4,
			-- [476] = nCardID56( int )	: maxsize = 4,
			-- [477] = nCardIndex52( int )	: maxsize = 4,
			-- [478] = nShape52( int )	: maxsize = 4,
			-- [479] = nValue52( int )	: maxsize = 4,
			-- [480] = nCardStatus52( int )	: maxsize = 4,
			-- [481] = nChairNO52( int )	: maxsize = 4,
			-- [482] = nPositionIndex52( int )	: maxsize = 4,
			-- [483] = nUniteCount52( int )	: maxsize = 4,
			-- [484] = nCardID57( int )	: maxsize = 4,
			-- [485] = nCardIndex53( int )	: maxsize = 4,
			-- [486] = nShape53( int )	: maxsize = 4,
			-- [487] = nValue53( int )	: maxsize = 4,
			-- [488] = nCardStatus53( int )	: maxsize = 4,
			-- [489] = nChairNO53( int )	: maxsize = 4,
			-- [490] = nPositionIndex53( int )	: maxsize = 4,
			-- [491] = nUniteCount53( int )	: maxsize = 4,
			-- [492] = nCardID58( int )	: maxsize = 4,
			-- [493] = nCardIndex54( int )	: maxsize = 4,
			-- [494] = nShape54( int )	: maxsize = 4,
			-- [495] = nValue54( int )	: maxsize = 4,
			-- [496] = nCardStatus54( int )	: maxsize = 4,
			-- [497] = nChairNO54( int )	: maxsize = 4,
			-- [498] = nPositionIndex54( int )	: maxsize = 4,
			-- [499] = nUniteCount54( int )	: maxsize = 4,
			-- [500] = nCardID59( int )	: maxsize = 4,
			-- [501] = nCardIndex55( int )	: maxsize = 4,
			-- [502] = nShape55( int )	: maxsize = 4,
			-- [503] = nValue55( int )	: maxsize = 4,
			-- [504] = nCardStatus55( int )	: maxsize = 4,
			-- [505] = nChairNO55( int )	: maxsize = 4,
			-- [506] = nPositionIndex55( int )	: maxsize = 4,
			-- [507] = nUniteCount55( int )	: maxsize = 4,
			-- [508] = nCardID60( int )	: maxsize = 4,
			-- [509] = nCardIndex56( int )	: maxsize = 4,
			-- [510] = nShape56( int )	: maxsize = 4,
			-- [511] = nValue56( int )	: maxsize = 4,
			-- [512] = nCardStatus56( int )	: maxsize = 4,
			-- [513] = nChairNO56( int )	: maxsize = 4,
			-- [514] = nPositionIndex56( int )	: maxsize = 4,
			-- [515] = nUniteCount56( int )	: maxsize = 4,
			-- [516] = nCardID61( int )	: maxsize = 4,
			-- [517] = nCardIndex57( int )	: maxsize = 4,
			-- [518] = nShape57( int )	: maxsize = 4,
			-- [519] = nValue57( int )	: maxsize = 4,
			-- [520] = nCardStatus57( int )	: maxsize = 4,
			-- [521] = nChairNO57( int )	: maxsize = 4,
			-- [522] = nPositionIndex57( int )	: maxsize = 4,
			-- [523] = nUniteCount57( int )	: maxsize = 4,
			-- [524] = nCardID62( int )	: maxsize = 4,
			-- [525] = nCardIndex58( int )	: maxsize = 4,
			-- [526] = nShape58( int )	: maxsize = 4,
			-- [527] = nValue58( int )	: maxsize = 4,
			-- [528] = nCardStatus58( int )	: maxsize = 4,
			-- [529] = nChairNO58( int )	: maxsize = 4,
			-- [530] = nPositionIndex58( int )	: maxsize = 4,
			-- [531] = nUniteCount58( int )	: maxsize = 4,
			-- [532] = nCardID63( int )	: maxsize = 4,
			-- [533] = nCardIndex59( int )	: maxsize = 4,
			-- [534] = nShape59( int )	: maxsize = 4,
			-- [535] = nValue59( int )	: maxsize = 4,
			-- [536] = nCardStatus59( int )	: maxsize = 4,
			-- [537] = nChairNO59( int )	: maxsize = 4,
			-- [538] = nPositionIndex59( int )	: maxsize = 4,
			-- [539] = nUniteCount59( int )	: maxsize = 4,
			-- [540] = nCardID64( int )	: maxsize = 4,
			-- [541] = nCardIndex60( int )	: maxsize = 4,
			-- [542] = nShape60( int )	: maxsize = 4,
			-- [543] = nValue60( int )	: maxsize = 4,
			-- [544] = nCardStatus60( int )	: maxsize = 4,
			-- [545] = nChairNO60( int )	: maxsize = 4,
			-- [546] = nPositionIndex60( int )	: maxsize = 4,
			-- [547] = nUniteCount60( int )	: maxsize = 4,
			-- [548] = nCardID65( int )	: maxsize = 4,
			-- [549] = nCardIndex61( int )	: maxsize = 4,
			-- [550] = nShape61( int )	: maxsize = 4,
			-- [551] = nValue61( int )	: maxsize = 4,
			-- [552] = nCardStatus61( int )	: maxsize = 4,
			-- [553] = nChairNO61( int )	: maxsize = 4,
			-- [554] = nPositionIndex61( int )	: maxsize = 4,
			-- [555] = nUniteCount61( int )	: maxsize = 4,
			-- [556] = nCardID66( int )	: maxsize = 4,
			-- [557] = nCardIndex62( int )	: maxsize = 4,
			-- [558] = nShape62( int )	: maxsize = 4,
			-- [559] = nValue62( int )	: maxsize = 4,
			-- [560] = nCardStatus62( int )	: maxsize = 4,
			-- [561] = nChairNO62( int )	: maxsize = 4,
			-- [562] = nPositionIndex62( int )	: maxsize = 4,
			-- [563] = nUniteCount62( int )	: maxsize = 4,
			-- [564] = nCardID67( int )	: maxsize = 4,
			-- [565] = nCardIndex63( int )	: maxsize = 4,
			-- [566] = nShape63( int )	: maxsize = 4,
			-- [567] = nValue63( int )	: maxsize = 4,
			-- [568] = nCardStatus63( int )	: maxsize = 4,
			-- [569] = nChairNO63( int )	: maxsize = 4,
			-- [570] = nPositionIndex63( int )	: maxsize = 4,
			-- [571] = nUniteCount63( int )	: maxsize = 4,
			-- [572] = nCardID68( int )	: maxsize = 4,
			-- [573] = nCardIndex64( int )	: maxsize = 4,
			-- [574] = nShape64( int )	: maxsize = 4,
			-- [575] = nValue64( int )	: maxsize = 4,
			-- [576] = nCardStatus64( int )	: maxsize = 4,
			-- [577] = nChairNO64( int )	: maxsize = 4,
			-- [578] = nPositionIndex64( int )	: maxsize = 4,
			-- [579] = nUniteCount64( int )	: maxsize = 4,
			-- [580] = nCardID69( int )	: maxsize = 4,
			-- [581] = nCardIndex65( int )	: maxsize = 4,
			-- [582] = nShape65( int )	: maxsize = 4,
			-- [583] = nValue65( int )	: maxsize = 4,
			-- [584] = nCardStatus65( int )	: maxsize = 4,
			-- [585] = nChairNO65( int )	: maxsize = 4,
			-- [586] = nPositionIndex65( int )	: maxsize = 4,
			-- [587] = nUniteCount65( int )	: maxsize = 4,
			-- [588] = nCardID70( int )	: maxsize = 4,
			-- [589] = nCardIndex66( int )	: maxsize = 4,
			-- [590] = nShape66( int )	: maxsize = 4,
			-- [591] = nValue66( int )	: maxsize = 4,
			-- [592] = nCardStatus66( int )	: maxsize = 4,
			-- [593] = nChairNO66( int )	: maxsize = 4,
			-- [594] = nPositionIndex66( int )	: maxsize = 4,
			-- [595] = nUniteCount66( int )	: maxsize = 4,
			-- [596] = nCardID71( int )	: maxsize = 4,
			-- [597] = nCardIndex67( int )	: maxsize = 4,
			-- [598] = nShape67( int )	: maxsize = 4,
			-- [599] = nValue67( int )	: maxsize = 4,
			-- [600] = nCardStatus67( int )	: maxsize = 4,
			-- [601] = nChairNO67( int )	: maxsize = 4,
			-- [602] = nPositionIndex67( int )	: maxsize = 4,
			-- [603] = nUniteCount67( int )	: maxsize = 4,
			-- [604] = nCardID72( int )	: maxsize = 4,
			-- [605] = nCardIndex68( int )	: maxsize = 4,
			-- [606] = nShape68( int )	: maxsize = 4,
			-- [607] = nValue68( int )	: maxsize = 4,
			-- [608] = nCardStatus68( int )	: maxsize = 4,
			-- [609] = nChairNO68( int )	: maxsize = 4,
			-- [610] = nPositionIndex68( int )	: maxsize = 4,
			-- [611] = nUniteCount68( int )	: maxsize = 4,
			-- [612] = nCardID73( int )	: maxsize = 4,
			-- [613] = nCardIndex69( int )	: maxsize = 4,
			-- [614] = nShape69( int )	: maxsize = 4,
			-- [615] = nValue69( int )	: maxsize = 4,
			-- [616] = nCardStatus69( int )	: maxsize = 4,
			-- [617] = nChairNO69( int )	: maxsize = 4,
			-- [618] = nPositionIndex69( int )	: maxsize = 4,
			-- [619] = nUniteCount69( int )	: maxsize = 4,
			-- [620] = nCardID74( int )	: maxsize = 4,
			-- [621] = nCardIndex70( int )	: maxsize = 4,
			-- [622] = nShape70( int )	: maxsize = 4,
			-- [623] = nValue70( int )	: maxsize = 4,
			-- [624] = nCardStatus70( int )	: maxsize = 4,
			-- [625] = nChairNO70( int )	: maxsize = 4,
			-- [626] = nPositionIndex70( int )	: maxsize = 4,
			-- [627] = nUniteCount70( int )	: maxsize = 4,
			-- [628] = nCardID75( int )	: maxsize = 4,
			-- [629] = nCardIndex71( int )	: maxsize = 4,
			-- [630] = nShape71( int )	: maxsize = 4,
			-- [631] = nValue71( int )	: maxsize = 4,
			-- [632] = nCardStatus71( int )	: maxsize = 4,
			-- [633] = nChairNO71( int )	: maxsize = 4,
			-- [634] = nPositionIndex71( int )	: maxsize = 4,
			-- [635] = nUniteCount71( int )	: maxsize = 4,
			-- [636] = nCardID76( int )	: maxsize = 4,
			-- [637] = nCardIndex72( int )	: maxsize = 4,
			-- [638] = nShape72( int )	: maxsize = 4,
			-- [639] = nValue72( int )	: maxsize = 4,
			-- [640] = nCardStatus72( int )	: maxsize = 4,
			-- [641] = nChairNO72( int )	: maxsize = 4,
			-- [642] = nPositionIndex72( int )	: maxsize = 4,
			-- [643] = nUniteCount72( int )	: maxsize = 4,
			-- [644] = nCardID77( int )	: maxsize = 4,
			-- [645] = nCardIndex73( int )	: maxsize = 4,
			-- [646] = nShape73( int )	: maxsize = 4,
			-- [647] = nValue73( int )	: maxsize = 4,
			-- [648] = nCardStatus73( int )	: maxsize = 4,
			-- [649] = nChairNO73( int )	: maxsize = 4,
			-- [650] = nPositionIndex73( int )	: maxsize = 4,
			-- [651] = nUniteCount73( int )	: maxsize = 4,
			-- [652] = nCardID78( int )	: maxsize = 4,
			-- [653] = nCardIndex74( int )	: maxsize = 4,
			-- [654] = nShape74( int )	: maxsize = 4,
			-- [655] = nValue74( int )	: maxsize = 4,
			-- [656] = nCardStatus74( int )	: maxsize = 4,
			-- [657] = nChairNO74( int )	: maxsize = 4,
			-- [658] = nPositionIndex74( int )	: maxsize = 4,
			-- [659] = nUniteCount74( int )	: maxsize = 4,
			-- [660] = nCardID79( int )	: maxsize = 4,
			-- [661] = nCardIndex75( int )	: maxsize = 4,
			-- [662] = nShape75( int )	: maxsize = 4,
			-- [663] = nValue75( int )	: maxsize = 4,
			-- [664] = nCardStatus75( int )	: maxsize = 4,
			-- [665] = nChairNO75( int )	: maxsize = 4,
			-- [666] = nPositionIndex75( int )	: maxsize = 4,
			-- [667] = nUniteCount75( int )	: maxsize = 4,
			-- [668] = nCardID80( int )	: maxsize = 4,
			-- [669] = nCardIndex76( int )	: maxsize = 4,
			-- [670] = nShape76( int )	: maxsize = 4,
			-- [671] = nValue76( int )	: maxsize = 4,
			-- [672] = nCardStatus76( int )	: maxsize = 4,
			-- [673] = nChairNO76( int )	: maxsize = 4,
			-- [674] = nPositionIndex76( int )	: maxsize = 4,
			-- [675] = nUniteCount76( int )	: maxsize = 4,
			-- [676] = nCardID81( int )	: maxsize = 4,
			-- [677] = nCardIndex77( int )	: maxsize = 4,
			-- [678] = nShape77( int )	: maxsize = 4,
			-- [679] = nValue77( int )	: maxsize = 4,
			-- [680] = nCardStatus77( int )	: maxsize = 4,
			-- [681] = nChairNO77( int )	: maxsize = 4,
			-- [682] = nPositionIndex77( int )	: maxsize = 4,
			-- [683] = nUniteCount77( int )	: maxsize = 4,
			-- [684] = nCardID82( int )	: maxsize = 4,
			-- [685] = nCardIndex78( int )	: maxsize = 4,
			-- [686] = nShape78( int )	: maxsize = 4,
			-- [687] = nValue78( int )	: maxsize = 4,
			-- [688] = nCardStatus78( int )	: maxsize = 4,
			-- [689] = nChairNO78( int )	: maxsize = 4,
			-- [690] = nPositionIndex78( int )	: maxsize = 4,
			-- [691] = nUniteCount78( int )	: maxsize = 4,
			-- [692] = nCardID83( int )	: maxsize = 4,
			-- [693] = nCardIndex79( int )	: maxsize = 4,
			-- [694] = nShape79( int )	: maxsize = 4,
			-- [695] = nValue79( int )	: maxsize = 4,
			-- [696] = nCardStatus79( int )	: maxsize = 4,
			-- [697] = nChairNO79( int )	: maxsize = 4,
			-- [698] = nPositionIndex79( int )	: maxsize = 4,
			-- [699] = nUniteCount79( int )	: maxsize = 4,
			-- [700] = nCardID84( int )	: maxsize = 4,
			-- [701] = nCardIndex80( int )	: maxsize = 4,
			-- [702] = nShape80( int )	: maxsize = 4,
			-- [703] = nValue80( int )	: maxsize = 4,
			-- [704] = nCardStatus80( int )	: maxsize = 4,
			-- [705] = nChairNO80( int )	: maxsize = 4,
			-- [706] = nPositionIndex80( int )	: maxsize = 4,
			-- [707] = nUniteCount80( int )	: maxsize = 4,
			-- [708] = nCardID85( int )	: maxsize = 4,
			-- [709] = nCardIndex81( int )	: maxsize = 4,
			-- [710] = nShape81( int )	: maxsize = 4,
			-- [711] = nValue81( int )	: maxsize = 4,
			-- [712] = nCardStatus81( int )	: maxsize = 4,
			-- [713] = nChairNO81( int )	: maxsize = 4,
			-- [714] = nPositionIndex81( int )	: maxsize = 4,
			-- [715] = nUniteCount81( int )	: maxsize = 4,
			-- [716] = nCardID86( int )	: maxsize = 4,
			-- [717] = nCardIndex82( int )	: maxsize = 4,
			-- [718] = nShape82( int )	: maxsize = 4,
			-- [719] = nValue82( int )	: maxsize = 4,
			-- [720] = nCardStatus82( int )	: maxsize = 4,
			-- [721] = nChairNO82( int )	: maxsize = 4,
			-- [722] = nPositionIndex82( int )	: maxsize = 4,
			-- [723] = nUniteCount82( int )	: maxsize = 4,
			-- [724] = nCardID87( int )	: maxsize = 4,
			-- [725] = nCardIndex83( int )	: maxsize = 4,
			-- [726] = nShape83( int )	: maxsize = 4,
			-- [727] = nValue83( int )	: maxsize = 4,
			-- [728] = nCardStatus83( int )	: maxsize = 4,
			-- [729] = nChairNO83( int )	: maxsize = 4,
			-- [730] = nPositionIndex83( int )	: maxsize = 4,
			-- [731] = nUniteCount83( int )	: maxsize = 4,
			-- [732] = nCardID88( int )	: maxsize = 4,
			-- [733] = nCardIndex84( int )	: maxsize = 4,
			-- [734] = nShape84( int )	: maxsize = 4,
			-- [735] = nValue84( int )	: maxsize = 4,
			-- [736] = nCardStatus84( int )	: maxsize = 4,
			-- [737] = nChairNO84( int )	: maxsize = 4,
			-- [738] = nPositionIndex84( int )	: maxsize = 4,
			-- [739] = nUniteCount84( int )	: maxsize = 4,
			-- [740] = nCardID89( int )	: maxsize = 4,
			-- [741] = nCardIndex85( int )	: maxsize = 4,
			-- [742] = nShape85( int )	: maxsize = 4,
			-- [743] = nValue85( int )	: maxsize = 4,
			-- [744] = nCardStatus85( int )	: maxsize = 4,
			-- [745] = nChairNO85( int )	: maxsize = 4,
			-- [746] = nPositionIndex85( int )	: maxsize = 4,
			-- [747] = nUniteCount85( int )	: maxsize = 4,
			-- [748] = nCardID90( int )	: maxsize = 4,
			-- [749] = nCardIndex86( int )	: maxsize = 4,
			-- [750] = nShape86( int )	: maxsize = 4,
			-- [751] = nValue86( int )	: maxsize = 4,
			-- [752] = nCardStatus86( int )	: maxsize = 4,
			-- [753] = nChairNO86( int )	: maxsize = 4,
			-- [754] = nPositionIndex86( int )	: maxsize = 4,
			-- [755] = nUniteCount86( int )	: maxsize = 4,
			-- [756] = nCardID91( int )	: maxsize = 4,
			-- [757] = nCardIndex87( int )	: maxsize = 4,
			-- [758] = nShape87( int )	: maxsize = 4,
			-- [759] = nValue87( int )	: maxsize = 4,
			-- [760] = nCardStatus87( int )	: maxsize = 4,
			-- [761] = nChairNO87( int )	: maxsize = 4,
			-- [762] = nPositionIndex87( int )	: maxsize = 4,
			-- [763] = nUniteCount87( int )	: maxsize = 4,
			-- [764] = nCardID92( int )	: maxsize = 4,
			-- [765] = nCardIndex88( int )	: maxsize = 4,
			-- [766] = nShape88( int )	: maxsize = 4,
			-- [767] = nValue88( int )	: maxsize = 4,
			-- [768] = nCardStatus88( int )	: maxsize = 4,
			-- [769] = nChairNO88( int )	: maxsize = 4,
			-- [770] = nPositionIndex88( int )	: maxsize = 4,
			-- [771] = nUniteCount88( int )	: maxsize = 4,
			-- [772] = nCardID93( int )	: maxsize = 4,
			-- [773] = nCardIndex89( int )	: maxsize = 4,
			-- [774] = nShape89( int )	: maxsize = 4,
			-- [775] = nValue89( int )	: maxsize = 4,
			-- [776] = nCardStatus89( int )	: maxsize = 4,
			-- [777] = nChairNO89( int )	: maxsize = 4,
			-- [778] = nPositionIndex89( int )	: maxsize = 4,
			-- [779] = nUniteCount89( int )	: maxsize = 4,
			-- [780] = nCardID94( int )	: maxsize = 4,
			-- [781] = nCardIndex90( int )	: maxsize = 4,
			-- [782] = nShape90( int )	: maxsize = 4,
			-- [783] = nValue90( int )	: maxsize = 4,
			-- [784] = nCardStatus90( int )	: maxsize = 4,
			-- [785] = nChairNO90( int )	: maxsize = 4,
			-- [786] = nPositionIndex90( int )	: maxsize = 4,
			-- [787] = nUniteCount90( int )	: maxsize = 4,
			-- [788] = nCardID95( int )	: maxsize = 4,
			-- [789] = nCardIndex91( int )	: maxsize = 4,
			-- [790] = nShape91( int )	: maxsize = 4,
			-- [791] = nValue91( int )	: maxsize = 4,
			-- [792] = nCardStatus91( int )	: maxsize = 4,
			-- [793] = nChairNO91( int )	: maxsize = 4,
			-- [794] = nPositionIndex91( int )	: maxsize = 4,
			-- [795] = nUniteCount91( int )	: maxsize = 4,
			-- [796] = nCardID96( int )	: maxsize = 4,
			-- [797] = nCardIndex92( int )	: maxsize = 4,
			-- [798] = nShape92( int )	: maxsize = 4,
			-- [799] = nValue92( int )	: maxsize = 4,
			-- [800] = nCardStatus92( int )	: maxsize = 4,
			-- [801] = nChairNO92( int )	: maxsize = 4,
			-- [802] = nPositionIndex92( int )	: maxsize = 4,
			-- [803] = nUniteCount92( int )	: maxsize = 4,
			-- [804] = nCardID97( int )	: maxsize = 4,
			-- [805] = nCardIndex93( int )	: maxsize = 4,
			-- [806] = nShape93( int )	: maxsize = 4,
			-- [807] = nValue93( int )	: maxsize = 4,
			-- [808] = nCardStatus93( int )	: maxsize = 4,
			-- [809] = nChairNO93( int )	: maxsize = 4,
			-- [810] = nPositionIndex93( int )	: maxsize = 4,
			-- [811] = nUniteCount93( int )	: maxsize = 4,
			-- [812] = nCardID98( int )	: maxsize = 4,
			-- [813] = nCardIndex94( int )	: maxsize = 4,
			-- [814] = nShape94( int )	: maxsize = 4,
			-- [815] = nValue94( int )	: maxsize = 4,
			-- [816] = nCardStatus94( int )	: maxsize = 4,
			-- [817] = nChairNO94( int )	: maxsize = 4,
			-- [818] = nPositionIndex94( int )	: maxsize = 4,
			-- [819] = nUniteCount94( int )	: maxsize = 4,
			-- [820] = nCardID99( int )	: maxsize = 4,
			-- [821] = nCardIndex95( int )	: maxsize = 4,
			-- [822] = nShape95( int )	: maxsize = 4,
			-- [823] = nValue95( int )	: maxsize = 4,
			-- [824] = nCardStatus95( int )	: maxsize = 4,
			-- [825] = nChairNO95( int )	: maxsize = 4,
			-- [826] = nPositionIndex95( int )	: maxsize = 4,
			-- [827] = nUniteCount95( int )	: maxsize = 4,
			-- [828] = nCardID100( int )	: maxsize = 4,
			-- [829] = nCardIndex96( int )	: maxsize = 4,
			-- [830] = nShape96( int )	: maxsize = 4,
			-- [831] = nValue96( int )	: maxsize = 4,
			-- [832] = nCardStatus96( int )	: maxsize = 4,
			-- [833] = nChairNO96( int )	: maxsize = 4,
			-- [834] = nPositionIndex96( int )	: maxsize = 4,
			-- [835] = nUniteCount96( int )	: maxsize = 4,
			-- [836] = nCardID101( int )	: maxsize = 4,
			-- [837] = nCardIndex97( int )	: maxsize = 4,
			-- [838] = nShape97( int )	: maxsize = 4,
			-- [839] = nValue97( int )	: maxsize = 4,
			-- [840] = nCardStatus97( int )	: maxsize = 4,
			-- [841] = nChairNO97( int )	: maxsize = 4,
			-- [842] = nPositionIndex97( int )	: maxsize = 4,
			-- [843] = nUniteCount97( int )	: maxsize = 4,
			-- [844] = nCardID102( int )	: maxsize = 4,
			-- [845] = nCardIndex98( int )	: maxsize = 4,
			-- [846] = nShape98( int )	: maxsize = 4,
			-- [847] = nValue98( int )	: maxsize = 4,
			-- [848] = nCardStatus98( int )	: maxsize = 4,
			-- [849] = nChairNO98( int )	: maxsize = 4,
			-- [850] = nPositionIndex98( int )	: maxsize = 4,
			-- [851] = nUniteCount98( int )	: maxsize = 4,
			-- [852] = nCardID103( int )	: maxsize = 4,
			-- [853] = nCardIndex99( int )	: maxsize = 4,
			-- [854] = nShape99( int )	: maxsize = 4,
			-- [855] = nValue99( int )	: maxsize = 4,
			-- [856] = nCardStatus99( int )	: maxsize = 4,
			-- [857] = nChairNO99( int )	: maxsize = 4,
			-- [858] = nPositionIndex99( int )	: maxsize = 4,
			-- [859] = nUniteCount99( int )	: maxsize = 4,
			-- [860] = nCardID104( int )	: maxsize = 4,
			-- [861] = nCardIndex100( int )	: maxsize = 4,
			-- [862] = nShape100( int )	: maxsize = 4,
			-- [863] = nValue100( int )	: maxsize = 4,
			-- [864] = nCardStatus100( int )	: maxsize = 4,
			-- [865] = nChairNO100( int )	: maxsize = 4,
			-- [866] = nPositionIndex100( int )	: maxsize = 4,
			-- [867] = nUniteCount100( int )	: maxsize = 4,
			-- [868] = nCardID105( int )	: maxsize = 4,
			-- [869] = nCardIndex101( int )	: maxsize = 4,
			-- [870] = nShape101( int )	: maxsize = 4,
			-- [871] = nValue101( int )	: maxsize = 4,
			-- [872] = nCardStatus101( int )	: maxsize = 4,
			-- [873] = nChairNO101( int )	: maxsize = 4,
			-- [874] = nPositionIndex101( int )	: maxsize = 4,
			-- [875] = nUniteCount101( int )	: maxsize = 4,
			-- [876] = nCardID106( int )	: maxsize = 4,
			-- [877] = nCardIndex102( int )	: maxsize = 4,
			-- [878] = nShape102( int )	: maxsize = 4,
			-- [879] = nValue102( int )	: maxsize = 4,
			-- [880] = nCardStatus102( int )	: maxsize = 4,
			-- [881] = nChairNO102( int )	: maxsize = 4,
			-- [882] = nPositionIndex102( int )	: maxsize = 4,
			-- [883] = nUniteCount102( int )	: maxsize = 4,
			-- [884] = nCardID107( int )	: maxsize = 4,
			-- [885] = nCardIndex103( int )	: maxsize = 4,
			-- [886] = nShape103( int )	: maxsize = 4,
			-- [887] = nValue103( int )	: maxsize = 4,
			-- [888] = nCardStatus103( int )	: maxsize = 4,
			-- [889] = nChairNO103( int )	: maxsize = 4,
			-- [890] = nPositionIndex103( int )	: maxsize = 4,
			-- [891] = nUniteCount103( int )	: maxsize = 4,
			-- [892] = nCardID108( int )	: maxsize = 4,
			-- [893] = nCardIndex104( int )	: maxsize = 4,
			-- [894] = nShape104( int )	: maxsize = 4,
			-- [895] = nValue104( int )	: maxsize = 4,
			-- [896] = nCardStatus104( int )	: maxsize = 4,
			-- [897] = nChairNO104( int )	: maxsize = 4,
			-- [898] = nPositionIndex104( int )	: maxsize = 4,
			-- [899] = nUniteCount104( int )	: maxsize = 4,
			-- [900] = nCardID109( int )	: maxsize = 4,
			-- [901] = nCardIndex105( int )	: maxsize = 4,
			-- [902] = nShape105( int )	: maxsize = 4,
			-- [903] = nValue105( int )	: maxsize = 4,
			-- [904] = nCardStatus105( int )	: maxsize = 4,
			-- [905] = nChairNO105( int )	: maxsize = 4,
			-- [906] = nPositionIndex105( int )	: maxsize = 4,
			-- [907] = nUniteCount105( int )	: maxsize = 4,
			-- [908] = nCardID110( int )	: maxsize = 4,
			-- [909] = nCardIndex106( int )	: maxsize = 4,
			-- [910] = nShape106( int )	: maxsize = 4,
			-- [911] = nValue106( int )	: maxsize = 4,
			-- [912] = nCardStatus106( int )	: maxsize = 4,
			-- [913] = nChairNO106( int )	: maxsize = 4,
			-- [914] = nPositionIndex106( int )	: maxsize = 4,
			-- [915] = nUniteCount106( int )	: maxsize = 4,
			-- [916] = nCardID111( int )	: maxsize = 4,
			-- [917] = nCardIndex107( int )	: maxsize = 4,
			-- [918] = nShape107( int )	: maxsize = 4,
			-- [919] = nValue107( int )	: maxsize = 4,
			-- [920] = nCardStatus107( int )	: maxsize = 4,
			-- [921] = nChairNO107( int )	: maxsize = 4,
			-- [922] = nPositionIndex107( int )	: maxsize = 4,
			-- [923] = nUniteCount107( int )	: maxsize = 4,
													-- bnChairWin	: maxsize = 16	=	4 * 4 * 1,
			[924] = { maxlen = 4 },
													-- nResultDiff	: maxsize = 960	=	4 * 30 * 8,
			[925] = { maxlen = 30, maxwidth = 8, complexType = 'matrix2' },
													-- nTotalResult	: maxsize = 32	=	4 * 8 * 1,
			[926] = { maxlen = 8 },
													-- nReserved1	: maxsize = 16	=	4 * 4 * 1,
			[927] = { maxlen = 4 },
			-- [928] = nWaitTime( int )	: maxsize = 4,
			-- [929] = nThrowTime( int )	: maxsize = 4,
			-- [930] = nTotalThrowCost( int )	: maxsize = 4,
			-- [931] = nInHandCount1( int )	: maxsize = 4,
			-- [932] = nAutoThrowCount( int )	: maxsize = 4,
													-- nThrowID	: maxsize = 432	=	4 * 108 * 1,
			[933] = { maxlen = 108 },
													-- nBombCount	: maxsize = 16	=	4 * 4 * 1,
			[934] = { maxlen = 4 },
			-- [935] = nThrowCount( int )	: maxsize = 4,
			-- [936] = nAskExitCount( int )	: maxsize = 4,
													-- nReserved2	: maxsize = 16	=	4 * 4 * 1,
			[937] = { maxlen = 4 },
			-- [938] = nWaitTime1( int )	: maxsize = 4,
			-- [939] = nThrowTime1( int )	: maxsize = 4,
			-- [940] = nTotalThrowCost1( int )	: maxsize = 4,
			-- [941] = nInHandCount2( int )	: maxsize = 4,
			-- [942] = nAutoThrowCount1( int )	: maxsize = 4,
													-- nThrowID1	: maxsize = 432	=	4 * 108 * 1,
			[943] = { maxlen = 108 },
													-- nBombCount1	: maxsize = 16	=	4 * 4 * 1,
			[944] = { maxlen = 4 },
			-- [945] = nThrowCount1( int )	: maxsize = 4,
			-- [946] = nAskExitCount1( int )	: maxsize = 4,
													-- nReserved3	: maxsize = 16	=	4 * 4 * 1,
			[947] = { maxlen = 4 },
			-- [948] = nWaitTime2( int )	: maxsize = 4,
			-- [949] = nThrowTime2( int )	: maxsize = 4,
			-- [950] = nTotalThrowCost2( int )	: maxsize = 4,
			-- [951] = nInHandCount3( int )	: maxsize = 4,
			-- [952] = nAutoThrowCount2( int )	: maxsize = 4,
													-- nThrowID2	: maxsize = 432	=	4 * 108 * 1,
			[953] = { maxlen = 108 },
													-- nBombCount2	: maxsize = 16	=	4 * 4 * 1,
			[954] = { maxlen = 4 },
			-- [955] = nThrowCount2( int )	: maxsize = 4,
			-- [956] = nAskExitCount2( int )	: maxsize = 4,
													-- nReserved4	: maxsize = 16	=	4 * 4 * 1,
			[957] = { maxlen = 4 },
			-- [958] = nWaitTime3( int )	: maxsize = 4,
			-- [959] = nThrowTime3( int )	: maxsize = 4,
			-- [960] = nTotalThrowCost3( int )	: maxsize = 4,
			-- [961] = nInHandCount4( int )	: maxsize = 4,
			-- [962] = nAutoThrowCount3( int )	: maxsize = 4,
													-- nThrowID3	: maxsize = 432	=	4 * 108 * 1,
			[963] = { maxlen = 108 },
													-- nBombCount3	: maxsize = 16	=	4 * 4 * 1,
			[964] = { maxlen = 4 },
			-- [965] = nThrowCount3( int )	: maxsize = 4,
			-- [966] = nAskExitCount3( int )	: maxsize = 4,
													-- nReserved5	: maxsize = 16	=	4 * 4 * 1,
			[967] = { maxlen = 4 },
													-- nReserved6	: maxsize = 16	=	4 * 4 * 1,
			[968] = { maxlen = 4 },
													-- gameInfoJS	: 				maxsize = 580,
			[969] = { refered = 'GAME_INFO_JS', complexType = 'link_refer' },
			maxlen = 969
		},
		nameMap = {
			'szSerialNO',		-- [1] ( char )
			'nBoutCount',		-- [2] ( int )
			'nBaseDeposit',		-- [3] ( int )
			'nBaseScore',		-- [4] ( int )
			'bNeedDeposit',		-- [5] ( int )
			'bForbidDesert',		-- [6] ( int )
			'nBanker',		-- [7] ( int )
			'nCurrentChair',		-- [8] ( int )
			'dwStatus',		-- [9] ( unsigned long )
			'nThrowWait',		-- [10] ( int )
			'nAutoGiveUp',		-- [11] ( int )
			'nOffline',		-- [12] ( int )
			'nInHandCount',		-- [13] ( int )
			'nThrowWaitEx',		-- [14] ( int )
			'nRank',		-- [15] ( int )
			'nRound',		-- [16] ( int )
			'nCurrentRank',		-- [17] ( int )
			'bnTribute',		-- [18] ( int )
			'winner',		-- [19] ( int )
			'nCardID',		-- [20] ( int )
			'bnFight',		-- [21] ( int )
			'nFightID',		-- [22] ( int )
			'bnTribute1',		-- [23] ( int )
			'winner1',		-- [24] ( int )
			'nCardID1',		-- [25] ( int )
			'bnFight1',		-- [26] ( int )
			'nFightID1',		-- [27] ( int )
			'bnTribute2',		-- [28] ( int )
			'winner2',		-- [29] ( int )
			'nCardID2',		-- [30] ( int )
			'bnFight2',		-- [31] ( int )
			'nFightID2',		-- [32] ( int )
			'bnTribute3',		-- [33] ( int )
			'winner3',		-- [34] ( int )
			'nCardID3',		-- [35] ( int )
			'bnFight3',		-- [36] ( int )
			'nFightID3',		-- [37] ( int )
			'nPlace',		-- [38] ( int )
			'bnShowRank',		-- [39] ( int )
			'bnResetGame',		-- [40] ( int )
			'nHandID',		-- [41] ( int )
			'nFriendID',		-- [42] ( int )
			'nFaceID',		-- [43] ( int )
			'nLastScoreDiffs',		-- [44] ( int )
			'nTotalScoreDiffs',		-- [45] ( int )
			'bnCardMasterChairUse',		-- [46] ( int )
			'nObjectGains',		-- [47] ( int )
			'nFanPaiCardID',		-- [48] ( int )
			'nRanker',		-- [49] ( int )
			'nReserved',		-- [50] ( int )
			'nWaitChair',		-- [51] ( int )
			'dwCardType',		-- [52] ( unsigned long )
			'dwComPareType',		-- [53] ( unsigned long )
			'nMainValue',		-- [54] ( unsigned long )
			'nCardCount',		-- [55] ( int )
			'nCardIDs',		-- [56] ( int )
			'nCurrentCatch',		-- [57] ( int )
			'nCurrentRank1',		-- [58] ( int )
			'dwUserStatus',		-- [59] ( unsigned long )
			'nCardID4',		-- [60] ( int )
			'nCardIndex',		-- [61] ( int )
			'nShape',		-- [62] ( int )
			'nValue',		-- [63] ( int )
			'nCardStatus',		-- [64] ( int )
			'nChairNO',		-- [65] ( int )
			'nPositionIndex',		-- [66] ( int )
			'nUniteCount',		-- [67] ( int )
			'nCardID5',		-- [68] ( int )
			'nCardIndex1',		-- [69] ( int )
			'nShape1',		-- [70] ( int )
			'nValue1',		-- [71] ( int )
			'nCardStatus1',		-- [72] ( int )
			'nChairNO1',		-- [73] ( int )
			'nPositionIndex1',		-- [74] ( int )
			'nUniteCount1',		-- [75] ( int )
			'nCardID6',		-- [76] ( int )
			'nCardIndex2',		-- [77] ( int )
			'nShape2',		-- [78] ( int )
			'nValue2',		-- [79] ( int )
			'nCardStatus2',		-- [80] ( int )
			'nChairNO2',		-- [81] ( int )
			'nPositionIndex2',		-- [82] ( int )
			'nUniteCount2',		-- [83] ( int )
			'nCardID7',		-- [84] ( int )
			'nCardIndex3',		-- [85] ( int )
			'nShape3',		-- [86] ( int )
			'nValue3',		-- [87] ( int )
			'nCardStatus3',		-- [88] ( int )
			'nChairNO3',		-- [89] ( int )
			'nPositionIndex3',		-- [90] ( int )
			'nUniteCount3',		-- [91] ( int )
			'nCardID8',		-- [92] ( int )
			'nCardIndex4',		-- [93] ( int )
			'nShape4',		-- [94] ( int )
			'nValue4',		-- [95] ( int )
			'nCardStatus4',		-- [96] ( int )
			'nChairNO4',		-- [97] ( int )
			'nPositionIndex4',		-- [98] ( int )
			'nUniteCount4',		-- [99] ( int )
			'nCardID9',		-- [100] ( int )
			'nCardIndex5',		-- [101] ( int )
			'nShape5',		-- [102] ( int )
			'nValue5',		-- [103] ( int )
			'nCardStatus5',		-- [104] ( int )
			'nChairNO5',		-- [105] ( int )
			'nPositionIndex5',		-- [106] ( int )
			'nUniteCount5',		-- [107] ( int )
			'nCardID10',		-- [108] ( int )
			'nCardIndex6',		-- [109] ( int )
			'nShape6',		-- [110] ( int )
			'nValue6',		-- [111] ( int )
			'nCardStatus6',		-- [112] ( int )
			'nChairNO6',		-- [113] ( int )
			'nPositionIndex6',		-- [114] ( int )
			'nUniteCount6',		-- [115] ( int )
			'nCardID11',		-- [116] ( int )
			'nCardIndex7',		-- [117] ( int )
			'nShape7',		-- [118] ( int )
			'nValue7',		-- [119] ( int )
			'nCardStatus7',		-- [120] ( int )
			'nChairNO7',		-- [121] ( int )
			'nPositionIndex7',		-- [122] ( int )
			'nUniteCount7',		-- [123] ( int )
			'nCardID12',		-- [124] ( int )
			'nCardIndex8',		-- [125] ( int )
			'nShape8',		-- [126] ( int )
			'nValue8',		-- [127] ( int )
			'nCardStatus8',		-- [128] ( int )
			'nChairNO8',		-- [129] ( int )
			'nPositionIndex8',		-- [130] ( int )
			'nUniteCount8',		-- [131] ( int )
			'nCardID13',		-- [132] ( int )
			'nCardIndex9',		-- [133] ( int )
			'nShape9',		-- [134] ( int )
			'nValue9',		-- [135] ( int )
			'nCardStatus9',		-- [136] ( int )
			'nChairNO9',		-- [137] ( int )
			'nPositionIndex9',		-- [138] ( int )
			'nUniteCount9',		-- [139] ( int )
			'nCardID14',		-- [140] ( int )
			'nCardIndex10',		-- [141] ( int )
			'nShape10',		-- [142] ( int )
			'nValue10',		-- [143] ( int )
			'nCardStatus10',		-- [144] ( int )
			'nChairNO10',		-- [145] ( int )
			'nPositionIndex10',		-- [146] ( int )
			'nUniteCount10',		-- [147] ( int )
			'nCardID15',		-- [148] ( int )
			'nCardIndex11',		-- [149] ( int )
			'nShape11',		-- [150] ( int )
			'nValue11',		-- [151] ( int )
			'nCardStatus11',		-- [152] ( int )
			'nChairNO11',		-- [153] ( int )
			'nPositionIndex11',		-- [154] ( int )
			'nUniteCount11',		-- [155] ( int )
			'nCardID16',		-- [156] ( int )
			'nCardIndex12',		-- [157] ( int )
			'nShape12',		-- [158] ( int )
			'nValue12',		-- [159] ( int )
			'nCardStatus12',		-- [160] ( int )
			'nChairNO12',		-- [161] ( int )
			'nPositionIndex12',		-- [162] ( int )
			'nUniteCount12',		-- [163] ( int )
			'nCardID17',		-- [164] ( int )
			'nCardIndex13',		-- [165] ( int )
			'nShape13',		-- [166] ( int )
			'nValue13',		-- [167] ( int )
			'nCardStatus13',		-- [168] ( int )
			'nChairNO13',		-- [169] ( int )
			'nPositionIndex13',		-- [170] ( int )
			'nUniteCount13',		-- [171] ( int )
			'nCardID18',		-- [172] ( int )
			'nCardIndex14',		-- [173] ( int )
			'nShape14',		-- [174] ( int )
			'nValue14',		-- [175] ( int )
			'nCardStatus14',		-- [176] ( int )
			'nChairNO14',		-- [177] ( int )
			'nPositionIndex14',		-- [178] ( int )
			'nUniteCount14',		-- [179] ( int )
			'nCardID19',		-- [180] ( int )
			'nCardIndex15',		-- [181] ( int )
			'nShape15',		-- [182] ( int )
			'nValue15',		-- [183] ( int )
			'nCardStatus15',		-- [184] ( int )
			'nChairNO15',		-- [185] ( int )
			'nPositionIndex15',		-- [186] ( int )
			'nUniteCount15',		-- [187] ( int )
			'nCardID20',		-- [188] ( int )
			'nCardIndex16',		-- [189] ( int )
			'nShape16',		-- [190] ( int )
			'nValue16',		-- [191] ( int )
			'nCardStatus16',		-- [192] ( int )
			'nChairNO16',		-- [193] ( int )
			'nPositionIndex16',		-- [194] ( int )
			'nUniteCount16',		-- [195] ( int )
			'nCardID21',		-- [196] ( int )
			'nCardIndex17',		-- [197] ( int )
			'nShape17',		-- [198] ( int )
			'nValue17',		-- [199] ( int )
			'nCardStatus17',		-- [200] ( int )
			'nChairNO17',		-- [201] ( int )
			'nPositionIndex17',		-- [202] ( int )
			'nUniteCount17',		-- [203] ( int )
			'nCardID22',		-- [204] ( int )
			'nCardIndex18',		-- [205] ( int )
			'nShape18',		-- [206] ( int )
			'nValue18',		-- [207] ( int )
			'nCardStatus18',		-- [208] ( int )
			'nChairNO18',		-- [209] ( int )
			'nPositionIndex18',		-- [210] ( int )
			'nUniteCount18',		-- [211] ( int )
			'nCardID23',		-- [212] ( int )
			'nCardIndex19',		-- [213] ( int )
			'nShape19',		-- [214] ( int )
			'nValue19',		-- [215] ( int )
			'nCardStatus19',		-- [216] ( int )
			'nChairNO19',		-- [217] ( int )
			'nPositionIndex19',		-- [218] ( int )
			'nUniteCount19',		-- [219] ( int )
			'nCardID24',		-- [220] ( int )
			'nCardIndex20',		-- [221] ( int )
			'nShape20',		-- [222] ( int )
			'nValue20',		-- [223] ( int )
			'nCardStatus20',		-- [224] ( int )
			'nChairNO20',		-- [225] ( int )
			'nPositionIndex20',		-- [226] ( int )
			'nUniteCount20',		-- [227] ( int )
			'nCardID25',		-- [228] ( int )
			'nCardIndex21',		-- [229] ( int )
			'nShape21',		-- [230] ( int )
			'nValue21',		-- [231] ( int )
			'nCardStatus21',		-- [232] ( int )
			'nChairNO21',		-- [233] ( int )
			'nPositionIndex21',		-- [234] ( int )
			'nUniteCount21',		-- [235] ( int )
			'nCardID26',		-- [236] ( int )
			'nCardIndex22',		-- [237] ( int )
			'nShape22',		-- [238] ( int )
			'nValue22',		-- [239] ( int )
			'nCardStatus22',		-- [240] ( int )
			'nChairNO22',		-- [241] ( int )
			'nPositionIndex22',		-- [242] ( int )
			'nUniteCount22',		-- [243] ( int )
			'nCardID27',		-- [244] ( int )
			'nCardIndex23',		-- [245] ( int )
			'nShape23',		-- [246] ( int )
			'nValue23',		-- [247] ( int )
			'nCardStatus23',		-- [248] ( int )
			'nChairNO23',		-- [249] ( int )
			'nPositionIndex23',		-- [250] ( int )
			'nUniteCount23',		-- [251] ( int )
			'nCardID28',		-- [252] ( int )
			'nCardIndex24',		-- [253] ( int )
			'nShape24',		-- [254] ( int )
			'nValue24',		-- [255] ( int )
			'nCardStatus24',		-- [256] ( int )
			'nChairNO24',		-- [257] ( int )
			'nPositionIndex24',		-- [258] ( int )
			'nUniteCount24',		-- [259] ( int )
			'nCardID29',		-- [260] ( int )
			'nCardIndex25',		-- [261] ( int )
			'nShape25',		-- [262] ( int )
			'nValue25',		-- [263] ( int )
			'nCardStatus25',		-- [264] ( int )
			'nChairNO25',		-- [265] ( int )
			'nPositionIndex25',		-- [266] ( int )
			'nUniteCount25',		-- [267] ( int )
			'nCardID30',		-- [268] ( int )
			'nCardIndex26',		-- [269] ( int )
			'nShape26',		-- [270] ( int )
			'nValue26',		-- [271] ( int )
			'nCardStatus26',		-- [272] ( int )
			'nChairNO26',		-- [273] ( int )
			'nPositionIndex26',		-- [274] ( int )
			'nUniteCount26',		-- [275] ( int )
			'nCardID31',		-- [276] ( int )
			'nCardIndex27',		-- [277] ( int )
			'nShape27',		-- [278] ( int )
			'nValue27',		-- [279] ( int )
			'nCardStatus27',		-- [280] ( int )
			'nChairNO27',		-- [281] ( int )
			'nPositionIndex27',		-- [282] ( int )
			'nUniteCount27',		-- [283] ( int )
			'nCardID32',		-- [284] ( int )
			'nCardIndex28',		-- [285] ( int )
			'nShape28',		-- [286] ( int )
			'nValue28',		-- [287] ( int )
			'nCardStatus28',		-- [288] ( int )
			'nChairNO28',		-- [289] ( int )
			'nPositionIndex28',		-- [290] ( int )
			'nUniteCount28',		-- [291] ( int )
			'nCardID33',		-- [292] ( int )
			'nCardIndex29',		-- [293] ( int )
			'nShape29',		-- [294] ( int )
			'nValue29',		-- [295] ( int )
			'nCardStatus29',		-- [296] ( int )
			'nChairNO29',		-- [297] ( int )
			'nPositionIndex29',		-- [298] ( int )
			'nUniteCount29',		-- [299] ( int )
			'nCardID34',		-- [300] ( int )
			'nCardIndex30',		-- [301] ( int )
			'nShape30',		-- [302] ( int )
			'nValue30',		-- [303] ( int )
			'nCardStatus30',		-- [304] ( int )
			'nChairNO30',		-- [305] ( int )
			'nPositionIndex30',		-- [306] ( int )
			'nUniteCount30',		-- [307] ( int )
			'nCardID35',		-- [308] ( int )
			'nCardIndex31',		-- [309] ( int )
			'nShape31',		-- [310] ( int )
			'nValue31',		-- [311] ( int )
			'nCardStatus31',		-- [312] ( int )
			'nChairNO31',		-- [313] ( int )
			'nPositionIndex31',		-- [314] ( int )
			'nUniteCount31',		-- [315] ( int )
			'nCardID36',		-- [316] ( int )
			'nCardIndex32',		-- [317] ( int )
			'nShape32',		-- [318] ( int )
			'nValue32',		-- [319] ( int )
			'nCardStatus32',		-- [320] ( int )
			'nChairNO32',		-- [321] ( int )
			'nPositionIndex32',		-- [322] ( int )
			'nUniteCount32',		-- [323] ( int )
			'nCardID37',		-- [324] ( int )
			'nCardIndex33',		-- [325] ( int )
			'nShape33',		-- [326] ( int )
			'nValue33',		-- [327] ( int )
			'nCardStatus33',		-- [328] ( int )
			'nChairNO33',		-- [329] ( int )
			'nPositionIndex33',		-- [330] ( int )
			'nUniteCount33',		-- [331] ( int )
			'nCardID38',		-- [332] ( int )
			'nCardIndex34',		-- [333] ( int )
			'nShape34',		-- [334] ( int )
			'nValue34',		-- [335] ( int )
			'nCardStatus34',		-- [336] ( int )
			'nChairNO34',		-- [337] ( int )
			'nPositionIndex34',		-- [338] ( int )
			'nUniteCount34',		-- [339] ( int )
			'nCardID39',		-- [340] ( int )
			'nCardIndex35',		-- [341] ( int )
			'nShape35',		-- [342] ( int )
			'nValue35',		-- [343] ( int )
			'nCardStatus35',		-- [344] ( int )
			'nChairNO35',		-- [345] ( int )
			'nPositionIndex35',		-- [346] ( int )
			'nUniteCount35',		-- [347] ( int )
			'nCardID40',		-- [348] ( int )
			'nCardIndex36',		-- [349] ( int )
			'nShape36',		-- [350] ( int )
			'nValue36',		-- [351] ( int )
			'nCardStatus36',		-- [352] ( int )
			'nChairNO36',		-- [353] ( int )
			'nPositionIndex36',		-- [354] ( int )
			'nUniteCount36',		-- [355] ( int )
			'nCardID41',		-- [356] ( int )
			'nCardIndex37',		-- [357] ( int )
			'nShape37',		-- [358] ( int )
			'nValue37',		-- [359] ( int )
			'nCardStatus37',		-- [360] ( int )
			'nChairNO37',		-- [361] ( int )
			'nPositionIndex37',		-- [362] ( int )
			'nUniteCount37',		-- [363] ( int )
			'nCardID42',		-- [364] ( int )
			'nCardIndex38',		-- [365] ( int )
			'nShape38',		-- [366] ( int )
			'nValue38',		-- [367] ( int )
			'nCardStatus38',		-- [368] ( int )
			'nChairNO38',		-- [369] ( int )
			'nPositionIndex38',		-- [370] ( int )
			'nUniteCount38',		-- [371] ( int )
			'nCardID43',		-- [372] ( int )
			'nCardIndex39',		-- [373] ( int )
			'nShape39',		-- [374] ( int )
			'nValue39',		-- [375] ( int )
			'nCardStatus39',		-- [376] ( int )
			'nChairNO39',		-- [377] ( int )
			'nPositionIndex39',		-- [378] ( int )
			'nUniteCount39',		-- [379] ( int )
			'nCardID44',		-- [380] ( int )
			'nCardIndex40',		-- [381] ( int )
			'nShape40',		-- [382] ( int )
			'nValue40',		-- [383] ( int )
			'nCardStatus40',		-- [384] ( int )
			'nChairNO40',		-- [385] ( int )
			'nPositionIndex40',		-- [386] ( int )
			'nUniteCount40',		-- [387] ( int )
			'nCardID45',		-- [388] ( int )
			'nCardIndex41',		-- [389] ( int )
			'nShape41',		-- [390] ( int )
			'nValue41',		-- [391] ( int )
			'nCardStatus41',		-- [392] ( int )
			'nChairNO41',		-- [393] ( int )
			'nPositionIndex41',		-- [394] ( int )
			'nUniteCount41',		-- [395] ( int )
			'nCardID46',		-- [396] ( int )
			'nCardIndex42',		-- [397] ( int )
			'nShape42',		-- [398] ( int )
			'nValue42',		-- [399] ( int )
			'nCardStatus42',		-- [400] ( int )
			'nChairNO42',		-- [401] ( int )
			'nPositionIndex42',		-- [402] ( int )
			'nUniteCount42',		-- [403] ( int )
			'nCardID47',		-- [404] ( int )
			'nCardIndex43',		-- [405] ( int )
			'nShape43',		-- [406] ( int )
			'nValue43',		-- [407] ( int )
			'nCardStatus43',		-- [408] ( int )
			'nChairNO43',		-- [409] ( int )
			'nPositionIndex43',		-- [410] ( int )
			'nUniteCount43',		-- [411] ( int )
			'nCardID48',		-- [412] ( int )
			'nCardIndex44',		-- [413] ( int )
			'nShape44',		-- [414] ( int )
			'nValue44',		-- [415] ( int )
			'nCardStatus44',		-- [416] ( int )
			'nChairNO44',		-- [417] ( int )
			'nPositionIndex44',		-- [418] ( int )
			'nUniteCount44',		-- [419] ( int )
			'nCardID49',		-- [420] ( int )
			'nCardIndex45',		-- [421] ( int )
			'nShape45',		-- [422] ( int )
			'nValue45',		-- [423] ( int )
			'nCardStatus45',		-- [424] ( int )
			'nChairNO45',		-- [425] ( int )
			'nPositionIndex45',		-- [426] ( int )
			'nUniteCount45',		-- [427] ( int )
			'nCardID50',		-- [428] ( int )
			'nCardIndex46',		-- [429] ( int )
			'nShape46',		-- [430] ( int )
			'nValue46',		-- [431] ( int )
			'nCardStatus46',		-- [432] ( int )
			'nChairNO46',		-- [433] ( int )
			'nPositionIndex46',		-- [434] ( int )
			'nUniteCount46',		-- [435] ( int )
			'nCardID51',		-- [436] ( int )
			'nCardIndex47',		-- [437] ( int )
			'nShape47',		-- [438] ( int )
			'nValue47',		-- [439] ( int )
			'nCardStatus47',		-- [440] ( int )
			'nChairNO47',		-- [441] ( int )
			'nPositionIndex47',		-- [442] ( int )
			'nUniteCount47',		-- [443] ( int )
			'nCardID52',		-- [444] ( int )
			'nCardIndex48',		-- [445] ( int )
			'nShape48',		-- [446] ( int )
			'nValue48',		-- [447] ( int )
			'nCardStatus48',		-- [448] ( int )
			'nChairNO48',		-- [449] ( int )
			'nPositionIndex48',		-- [450] ( int )
			'nUniteCount48',		-- [451] ( int )
			'nCardID53',		-- [452] ( int )
			'nCardIndex49',		-- [453] ( int )
			'nShape49',		-- [454] ( int )
			'nValue49',		-- [455] ( int )
			'nCardStatus49',		-- [456] ( int )
			'nChairNO49',		-- [457] ( int )
			'nPositionIndex49',		-- [458] ( int )
			'nUniteCount49',		-- [459] ( int )
			'nCardID54',		-- [460] ( int )
			'nCardIndex50',		-- [461] ( int )
			'nShape50',		-- [462] ( int )
			'nValue50',		-- [463] ( int )
			'nCardStatus50',		-- [464] ( int )
			'nChairNO50',		-- [465] ( int )
			'nPositionIndex50',		-- [466] ( int )
			'nUniteCount50',		-- [467] ( int )
			'nCardID55',		-- [468] ( int )
			'nCardIndex51',		-- [469] ( int )
			'nShape51',		-- [470] ( int )
			'nValue51',		-- [471] ( int )
			'nCardStatus51',		-- [472] ( int )
			'nChairNO51',		-- [473] ( int )
			'nPositionIndex51',		-- [474] ( int )
			'nUniteCount51',		-- [475] ( int )
			'nCardID56',		-- [476] ( int )
			'nCardIndex52',		-- [477] ( int )
			'nShape52',		-- [478] ( int )
			'nValue52',		-- [479] ( int )
			'nCardStatus52',		-- [480] ( int )
			'nChairNO52',		-- [481] ( int )
			'nPositionIndex52',		-- [482] ( int )
			'nUniteCount52',		-- [483] ( int )
			'nCardID57',		-- [484] ( int )
			'nCardIndex53',		-- [485] ( int )
			'nShape53',		-- [486] ( int )
			'nValue53',		-- [487] ( int )
			'nCardStatus53',		-- [488] ( int )
			'nChairNO53',		-- [489] ( int )
			'nPositionIndex53',		-- [490] ( int )
			'nUniteCount53',		-- [491] ( int )
			'nCardID58',		-- [492] ( int )
			'nCardIndex54',		-- [493] ( int )
			'nShape54',		-- [494] ( int )
			'nValue54',		-- [495] ( int )
			'nCardStatus54',		-- [496] ( int )
			'nChairNO54',		-- [497] ( int )
			'nPositionIndex54',		-- [498] ( int )
			'nUniteCount54',		-- [499] ( int )
			'nCardID59',		-- [500] ( int )
			'nCardIndex55',		-- [501] ( int )
			'nShape55',		-- [502] ( int )
			'nValue55',		-- [503] ( int )
			'nCardStatus55',		-- [504] ( int )
			'nChairNO55',		-- [505] ( int )
			'nPositionIndex55',		-- [506] ( int )
			'nUniteCount55',		-- [507] ( int )
			'nCardID60',		-- [508] ( int )
			'nCardIndex56',		-- [509] ( int )
			'nShape56',		-- [510] ( int )
			'nValue56',		-- [511] ( int )
			'nCardStatus56',		-- [512] ( int )
			'nChairNO56',		-- [513] ( int )
			'nPositionIndex56',		-- [514] ( int )
			'nUniteCount56',		-- [515] ( int )
			'nCardID61',		-- [516] ( int )
			'nCardIndex57',		-- [517] ( int )
			'nShape57',		-- [518] ( int )
			'nValue57',		-- [519] ( int )
			'nCardStatus57',		-- [520] ( int )
			'nChairNO57',		-- [521] ( int )
			'nPositionIndex57',		-- [522] ( int )
			'nUniteCount57',		-- [523] ( int )
			'nCardID62',		-- [524] ( int )
			'nCardIndex58',		-- [525] ( int )
			'nShape58',		-- [526] ( int )
			'nValue58',		-- [527] ( int )
			'nCardStatus58',		-- [528] ( int )
			'nChairNO58',		-- [529] ( int )
			'nPositionIndex58',		-- [530] ( int )
			'nUniteCount58',		-- [531] ( int )
			'nCardID63',		-- [532] ( int )
			'nCardIndex59',		-- [533] ( int )
			'nShape59',		-- [534] ( int )
			'nValue59',		-- [535] ( int )
			'nCardStatus59',		-- [536] ( int )
			'nChairNO59',		-- [537] ( int )
			'nPositionIndex59',		-- [538] ( int )
			'nUniteCount59',		-- [539] ( int )
			'nCardID64',		-- [540] ( int )
			'nCardIndex60',		-- [541] ( int )
			'nShape60',		-- [542] ( int )
			'nValue60',		-- [543] ( int )
			'nCardStatus60',		-- [544] ( int )
			'nChairNO60',		-- [545] ( int )
			'nPositionIndex60',		-- [546] ( int )
			'nUniteCount60',		-- [547] ( int )
			'nCardID65',		-- [548] ( int )
			'nCardIndex61',		-- [549] ( int )
			'nShape61',		-- [550] ( int )
			'nValue61',		-- [551] ( int )
			'nCardStatus61',		-- [552] ( int )
			'nChairNO61',		-- [553] ( int )
			'nPositionIndex61',		-- [554] ( int )
			'nUniteCount61',		-- [555] ( int )
			'nCardID66',		-- [556] ( int )
			'nCardIndex62',		-- [557] ( int )
			'nShape62',		-- [558] ( int )
			'nValue62',		-- [559] ( int )
			'nCardStatus62',		-- [560] ( int )
			'nChairNO62',		-- [561] ( int )
			'nPositionIndex62',		-- [562] ( int )
			'nUniteCount62',		-- [563] ( int )
			'nCardID67',		-- [564] ( int )
			'nCardIndex63',		-- [565] ( int )
			'nShape63',		-- [566] ( int )
			'nValue63',		-- [567] ( int )
			'nCardStatus63',		-- [568] ( int )
			'nChairNO63',		-- [569] ( int )
			'nPositionIndex63',		-- [570] ( int )
			'nUniteCount63',		-- [571] ( int )
			'nCardID68',		-- [572] ( int )
			'nCardIndex64',		-- [573] ( int )
			'nShape64',		-- [574] ( int )
			'nValue64',		-- [575] ( int )
			'nCardStatus64',		-- [576] ( int )
			'nChairNO64',		-- [577] ( int )
			'nPositionIndex64',		-- [578] ( int )
			'nUniteCount64',		-- [579] ( int )
			'nCardID69',		-- [580] ( int )
			'nCardIndex65',		-- [581] ( int )
			'nShape65',		-- [582] ( int )
			'nValue65',		-- [583] ( int )
			'nCardStatus65',		-- [584] ( int )
			'nChairNO65',		-- [585] ( int )
			'nPositionIndex65',		-- [586] ( int )
			'nUniteCount65',		-- [587] ( int )
			'nCardID70',		-- [588] ( int )
			'nCardIndex66',		-- [589] ( int )
			'nShape66',		-- [590] ( int )
			'nValue66',		-- [591] ( int )
			'nCardStatus66',		-- [592] ( int )
			'nChairNO66',		-- [593] ( int )
			'nPositionIndex66',		-- [594] ( int )
			'nUniteCount66',		-- [595] ( int )
			'nCardID71',		-- [596] ( int )
			'nCardIndex67',		-- [597] ( int )
			'nShape67',		-- [598] ( int )
			'nValue67',		-- [599] ( int )
			'nCardStatus67',		-- [600] ( int )
			'nChairNO67',		-- [601] ( int )
			'nPositionIndex67',		-- [602] ( int )
			'nUniteCount67',		-- [603] ( int )
			'nCardID72',		-- [604] ( int )
			'nCardIndex68',		-- [605] ( int )
			'nShape68',		-- [606] ( int )
			'nValue68',		-- [607] ( int )
			'nCardStatus68',		-- [608] ( int )
			'nChairNO68',		-- [609] ( int )
			'nPositionIndex68',		-- [610] ( int )
			'nUniteCount68',		-- [611] ( int )
			'nCardID73',		-- [612] ( int )
			'nCardIndex69',		-- [613] ( int )
			'nShape69',		-- [614] ( int )
			'nValue69',		-- [615] ( int )
			'nCardStatus69',		-- [616] ( int )
			'nChairNO69',		-- [617] ( int )
			'nPositionIndex69',		-- [618] ( int )
			'nUniteCount69',		-- [619] ( int )
			'nCardID74',		-- [620] ( int )
			'nCardIndex70',		-- [621] ( int )
			'nShape70',		-- [622] ( int )
			'nValue70',		-- [623] ( int )
			'nCardStatus70',		-- [624] ( int )
			'nChairNO70',		-- [625] ( int )
			'nPositionIndex70',		-- [626] ( int )
			'nUniteCount70',		-- [627] ( int )
			'nCardID75',		-- [628] ( int )
			'nCardIndex71',		-- [629] ( int )
			'nShape71',		-- [630] ( int )
			'nValue71',		-- [631] ( int )
			'nCardStatus71',		-- [632] ( int )
			'nChairNO71',		-- [633] ( int )
			'nPositionIndex71',		-- [634] ( int )
			'nUniteCount71',		-- [635] ( int )
			'nCardID76',		-- [636] ( int )
			'nCardIndex72',		-- [637] ( int )
			'nShape72',		-- [638] ( int )
			'nValue72',		-- [639] ( int )
			'nCardStatus72',		-- [640] ( int )
			'nChairNO72',		-- [641] ( int )
			'nPositionIndex72',		-- [642] ( int )
			'nUniteCount72',		-- [643] ( int )
			'nCardID77',		-- [644] ( int )
			'nCardIndex73',		-- [645] ( int )
			'nShape73',		-- [646] ( int )
			'nValue73',		-- [647] ( int )
			'nCardStatus73',		-- [648] ( int )
			'nChairNO73',		-- [649] ( int )
			'nPositionIndex73',		-- [650] ( int )
			'nUniteCount73',		-- [651] ( int )
			'nCardID78',		-- [652] ( int )
			'nCardIndex74',		-- [653] ( int )
			'nShape74',		-- [654] ( int )
			'nValue74',		-- [655] ( int )
			'nCardStatus74',		-- [656] ( int )
			'nChairNO74',		-- [657] ( int )
			'nPositionIndex74',		-- [658] ( int )
			'nUniteCount74',		-- [659] ( int )
			'nCardID79',		-- [660] ( int )
			'nCardIndex75',		-- [661] ( int )
			'nShape75',		-- [662] ( int )
			'nValue75',		-- [663] ( int )
			'nCardStatus75',		-- [664] ( int )
			'nChairNO75',		-- [665] ( int )
			'nPositionIndex75',		-- [666] ( int )
			'nUniteCount75',		-- [667] ( int )
			'nCardID80',		-- [668] ( int )
			'nCardIndex76',		-- [669] ( int )
			'nShape76',		-- [670] ( int )
			'nValue76',		-- [671] ( int )
			'nCardStatus76',		-- [672] ( int )
			'nChairNO76',		-- [673] ( int )
			'nPositionIndex76',		-- [674] ( int )
			'nUniteCount76',		-- [675] ( int )
			'nCardID81',		-- [676] ( int )
			'nCardIndex77',		-- [677] ( int )
			'nShape77',		-- [678] ( int )
			'nValue77',		-- [679] ( int )
			'nCardStatus77',		-- [680] ( int )
			'nChairNO77',		-- [681] ( int )
			'nPositionIndex77',		-- [682] ( int )
			'nUniteCount77',		-- [683] ( int )
			'nCardID82',		-- [684] ( int )
			'nCardIndex78',		-- [685] ( int )
			'nShape78',		-- [686] ( int )
			'nValue78',		-- [687] ( int )
			'nCardStatus78',		-- [688] ( int )
			'nChairNO78',		-- [689] ( int )
			'nPositionIndex78',		-- [690] ( int )
			'nUniteCount78',		-- [691] ( int )
			'nCardID83',		-- [692] ( int )
			'nCardIndex79',		-- [693] ( int )
			'nShape79',		-- [694] ( int )
			'nValue79',		-- [695] ( int )
			'nCardStatus79',		-- [696] ( int )
			'nChairNO79',		-- [697] ( int )
			'nPositionIndex79',		-- [698] ( int )
			'nUniteCount79',		-- [699] ( int )
			'nCardID84',		-- [700] ( int )
			'nCardIndex80',		-- [701] ( int )
			'nShape80',		-- [702] ( int )
			'nValue80',		-- [703] ( int )
			'nCardStatus80',		-- [704] ( int )
			'nChairNO80',		-- [705] ( int )
			'nPositionIndex80',		-- [706] ( int )
			'nUniteCount80',		-- [707] ( int )
			'nCardID85',		-- [708] ( int )
			'nCardIndex81',		-- [709] ( int )
			'nShape81',		-- [710] ( int )
			'nValue81',		-- [711] ( int )
			'nCardStatus81',		-- [712] ( int )
			'nChairNO81',		-- [713] ( int )
			'nPositionIndex81',		-- [714] ( int )
			'nUniteCount81',		-- [715] ( int )
			'nCardID86',		-- [716] ( int )
			'nCardIndex82',		-- [717] ( int )
			'nShape82',		-- [718] ( int )
			'nValue82',		-- [719] ( int )
			'nCardStatus82',		-- [720] ( int )
			'nChairNO82',		-- [721] ( int )
			'nPositionIndex82',		-- [722] ( int )
			'nUniteCount82',		-- [723] ( int )
			'nCardID87',		-- [724] ( int )
			'nCardIndex83',		-- [725] ( int )
			'nShape83',		-- [726] ( int )
			'nValue83',		-- [727] ( int )
			'nCardStatus83',		-- [728] ( int )
			'nChairNO83',		-- [729] ( int )
			'nPositionIndex83',		-- [730] ( int )
			'nUniteCount83',		-- [731] ( int )
			'nCardID88',		-- [732] ( int )
			'nCardIndex84',		-- [733] ( int )
			'nShape84',		-- [734] ( int )
			'nValue84',		-- [735] ( int )
			'nCardStatus84',		-- [736] ( int )
			'nChairNO84',		-- [737] ( int )
			'nPositionIndex84',		-- [738] ( int )
			'nUniteCount84',		-- [739] ( int )
			'nCardID89',		-- [740] ( int )
			'nCardIndex85',		-- [741] ( int )
			'nShape85',		-- [742] ( int )
			'nValue85',		-- [743] ( int )
			'nCardStatus85',		-- [744] ( int )
			'nChairNO85',		-- [745] ( int )
			'nPositionIndex85',		-- [746] ( int )
			'nUniteCount85',		-- [747] ( int )
			'nCardID90',		-- [748] ( int )
			'nCardIndex86',		-- [749] ( int )
			'nShape86',		-- [750] ( int )
			'nValue86',		-- [751] ( int )
			'nCardStatus86',		-- [752] ( int )
			'nChairNO86',		-- [753] ( int )
			'nPositionIndex86',		-- [754] ( int )
			'nUniteCount86',		-- [755] ( int )
			'nCardID91',		-- [756] ( int )
			'nCardIndex87',		-- [757] ( int )
			'nShape87',		-- [758] ( int )
			'nValue87',		-- [759] ( int )
			'nCardStatus87',		-- [760] ( int )
			'nChairNO87',		-- [761] ( int )
			'nPositionIndex87',		-- [762] ( int )
			'nUniteCount87',		-- [763] ( int )
			'nCardID92',		-- [764] ( int )
			'nCardIndex88',		-- [765] ( int )
			'nShape88',		-- [766] ( int )
			'nValue88',		-- [767] ( int )
			'nCardStatus88',		-- [768] ( int )
			'nChairNO88',		-- [769] ( int )
			'nPositionIndex88',		-- [770] ( int )
			'nUniteCount88',		-- [771] ( int )
			'nCardID93',		-- [772] ( int )
			'nCardIndex89',		-- [773] ( int )
			'nShape89',		-- [774] ( int )
			'nValue89',		-- [775] ( int )
			'nCardStatus89',		-- [776] ( int )
			'nChairNO89',		-- [777] ( int )
			'nPositionIndex89',		-- [778] ( int )
			'nUniteCount89',		-- [779] ( int )
			'nCardID94',		-- [780] ( int )
			'nCardIndex90',		-- [781] ( int )
			'nShape90',		-- [782] ( int )
			'nValue90',		-- [783] ( int )
			'nCardStatus90',		-- [784] ( int )
			'nChairNO90',		-- [785] ( int )
			'nPositionIndex90',		-- [786] ( int )
			'nUniteCount90',		-- [787] ( int )
			'nCardID95',		-- [788] ( int )
			'nCardIndex91',		-- [789] ( int )
			'nShape91',		-- [790] ( int )
			'nValue91',		-- [791] ( int )
			'nCardStatus91',		-- [792] ( int )
			'nChairNO91',		-- [793] ( int )
			'nPositionIndex91',		-- [794] ( int )
			'nUniteCount91',		-- [795] ( int )
			'nCardID96',		-- [796] ( int )
			'nCardIndex92',		-- [797] ( int )
			'nShape92',		-- [798] ( int )
			'nValue92',		-- [799] ( int )
			'nCardStatus92',		-- [800] ( int )
			'nChairNO92',		-- [801] ( int )
			'nPositionIndex92',		-- [802] ( int )
			'nUniteCount92',		-- [803] ( int )
			'nCardID97',		-- [804] ( int )
			'nCardIndex93',		-- [805] ( int )
			'nShape93',		-- [806] ( int )
			'nValue93',		-- [807] ( int )
			'nCardStatus93',		-- [808] ( int )
			'nChairNO93',		-- [809] ( int )
			'nPositionIndex93',		-- [810] ( int )
			'nUniteCount93',		-- [811] ( int )
			'nCardID98',		-- [812] ( int )
			'nCardIndex94',		-- [813] ( int )
			'nShape94',		-- [814] ( int )
			'nValue94',		-- [815] ( int )
			'nCardStatus94',		-- [816] ( int )
			'nChairNO94',		-- [817] ( int )
			'nPositionIndex94',		-- [818] ( int )
			'nUniteCount94',		-- [819] ( int )
			'nCardID99',		-- [820] ( int )
			'nCardIndex95',		-- [821] ( int )
			'nShape95',		-- [822] ( int )
			'nValue95',		-- [823] ( int )
			'nCardStatus95',		-- [824] ( int )
			'nChairNO95',		-- [825] ( int )
			'nPositionIndex95',		-- [826] ( int )
			'nUniteCount95',		-- [827] ( int )
			'nCardID100',		-- [828] ( int )
			'nCardIndex96',		-- [829] ( int )
			'nShape96',		-- [830] ( int )
			'nValue96',		-- [831] ( int )
			'nCardStatus96',		-- [832] ( int )
			'nChairNO96',		-- [833] ( int )
			'nPositionIndex96',		-- [834] ( int )
			'nUniteCount96',		-- [835] ( int )
			'nCardID101',		-- [836] ( int )
			'nCardIndex97',		-- [837] ( int )
			'nShape97',		-- [838] ( int )
			'nValue97',		-- [839] ( int )
			'nCardStatus97',		-- [840] ( int )
			'nChairNO97',		-- [841] ( int )
			'nPositionIndex97',		-- [842] ( int )
			'nUniteCount97',		-- [843] ( int )
			'nCardID102',		-- [844] ( int )
			'nCardIndex98',		-- [845] ( int )
			'nShape98',		-- [846] ( int )
			'nValue98',		-- [847] ( int )
			'nCardStatus98',		-- [848] ( int )
			'nChairNO98',		-- [849] ( int )
			'nPositionIndex98',		-- [850] ( int )
			'nUniteCount98',		-- [851] ( int )
			'nCardID103',		-- [852] ( int )
			'nCardIndex99',		-- [853] ( int )
			'nShape99',		-- [854] ( int )
			'nValue99',		-- [855] ( int )
			'nCardStatus99',		-- [856] ( int )
			'nChairNO99',		-- [857] ( int )
			'nPositionIndex99',		-- [858] ( int )
			'nUniteCount99',		-- [859] ( int )
			'nCardID104',		-- [860] ( int )
			'nCardIndex100',		-- [861] ( int )
			'nShape100',		-- [862] ( int )
			'nValue100',		-- [863] ( int )
			'nCardStatus100',		-- [864] ( int )
			'nChairNO100',		-- [865] ( int )
			'nPositionIndex100',		-- [866] ( int )
			'nUniteCount100',		-- [867] ( int )
			'nCardID105',		-- [868] ( int )
			'nCardIndex101',		-- [869] ( int )
			'nShape101',		-- [870] ( int )
			'nValue101',		-- [871] ( int )
			'nCardStatus101',		-- [872] ( int )
			'nChairNO101',		-- [873] ( int )
			'nPositionIndex101',		-- [874] ( int )
			'nUniteCount101',		-- [875] ( int )
			'nCardID106',		-- [876] ( int )
			'nCardIndex102',		-- [877] ( int )
			'nShape102',		-- [878] ( int )
			'nValue102',		-- [879] ( int )
			'nCardStatus102',		-- [880] ( int )
			'nChairNO102',		-- [881] ( int )
			'nPositionIndex102',		-- [882] ( int )
			'nUniteCount102',		-- [883] ( int )
			'nCardID107',		-- [884] ( int )
			'nCardIndex103',		-- [885] ( int )
			'nShape103',		-- [886] ( int )
			'nValue103',		-- [887] ( int )
			'nCardStatus103',		-- [888] ( int )
			'nChairNO103',		-- [889] ( int )
			'nPositionIndex103',		-- [890] ( int )
			'nUniteCount103',		-- [891] ( int )
			'nCardID108',		-- [892] ( int )
			'nCardIndex104',		-- [893] ( int )
			'nShape104',		-- [894] ( int )
			'nValue104',		-- [895] ( int )
			'nCardStatus104',		-- [896] ( int )
			'nChairNO104',		-- [897] ( int )
			'nPositionIndex104',		-- [898] ( int )
			'nUniteCount104',		-- [899] ( int )
			'nCardID109',		-- [900] ( int )
			'nCardIndex105',		-- [901] ( int )
			'nShape105',		-- [902] ( int )
			'nValue105',		-- [903] ( int )
			'nCardStatus105',		-- [904] ( int )
			'nChairNO105',		-- [905] ( int )
			'nPositionIndex105',		-- [906] ( int )
			'nUniteCount105',		-- [907] ( int )
			'nCardID110',		-- [908] ( int )
			'nCardIndex106',		-- [909] ( int )
			'nShape106',		-- [910] ( int )
			'nValue106',		-- [911] ( int )
			'nCardStatus106',		-- [912] ( int )
			'nChairNO106',		-- [913] ( int )
			'nPositionIndex106',		-- [914] ( int )
			'nUniteCount106',		-- [915] ( int )
			'nCardID111',		-- [916] ( int )
			'nCardIndex107',		-- [917] ( int )
			'nShape107',		-- [918] ( int )
			'nValue107',		-- [919] ( int )
			'nCardStatus107',		-- [920] ( int )
			'nChairNO107',		-- [921] ( int )
			'nPositionIndex107',		-- [922] ( int )
			'nUniteCount107',		-- [923] ( int )
			'bnChairWin',		-- [924] ( int )
			'nResultDiff',		-- [925] ( int )
			'nTotalResult',		-- [926] ( int )
			'nReserved1',		-- [927] ( int )
			'nWaitTime',		-- [928] ( int )
			'nThrowTime',		-- [929] ( int )
			'nTotalThrowCost',		-- [930] ( int )
			'nInHandCount1',		-- [931] ( int )
			'nAutoThrowCount',		-- [932] ( int )
			'nThrowID',		-- [933] ( int )
			'nBombCount',		-- [934] ( int )
			'nThrowCount',		-- [935] ( int )
			'nAskExitCount',		-- [936] ( int )
			'nReserved2',		-- [937] ( int )
			'nWaitTime1',		-- [938] ( int )
			'nThrowTime1',		-- [939] ( int )
			'nTotalThrowCost1',		-- [940] ( int )
			'nInHandCount2',		-- [941] ( int )
			'nAutoThrowCount1',		-- [942] ( int )
			'nThrowID1',		-- [943] ( int )
			'nBombCount1',		-- [944] ( int )
			'nThrowCount1',		-- [945] ( int )
			'nAskExitCount1',		-- [946] ( int )
			'nReserved3',		-- [947] ( int )
			'nWaitTime2',		-- [948] ( int )
			'nThrowTime2',		-- [949] ( int )
			'nTotalThrowCost2',		-- [950] ( int )
			'nInHandCount3',		-- [951] ( int )
			'nAutoThrowCount2',		-- [952] ( int )
			'nThrowID2',		-- [953] ( int )
			'nBombCount2',		-- [954] ( int )
			'nThrowCount2',		-- [955] ( int )
			'nAskExitCount2',		-- [956] ( int )
			'nReserved4',		-- [957] ( int )
			'nWaitTime3',		-- [958] ( int )
			'nThrowTime3',		-- [959] ( int )
			'nTotalThrowCost3',		-- [960] ( int )
			'nInHandCount4',		-- [961] ( int )
			'nAutoThrowCount3',		-- [962] ( int )
			'nThrowID3',		-- [963] ( int )
			'nBombCount3',		-- [964] ( int )
			'nThrowCount3',		-- [965] ( int )
			'nAskExitCount3',		-- [966] ( int )
			'nReserved5',		-- [967] ( int )
			'nReserved6',		-- [968] ( int )
			'gameInfoJS',		-- [969] ( refer )
		},
		formatKey = '<Ai7Li133L3i67L8i1761',
		deformatKey = '<A32i7Li133L3i67L8i1761',
		maxsize = 7952
	},
}
cc.load('treepack').resolveReference(MyJiSuGameReq)
return MyJiSuGameReq