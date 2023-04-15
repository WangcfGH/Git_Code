
local BaseGameReq = {
    ASK_NEWTABLECHAIR={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

	ENTER_GAME={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nUserType( int )	: maxsize = 4,
			-- [3] = nGameID( int )	: maxsize = 4,
			-- [4] = nRoomID( int )	: maxsize = 4,
			-- [5] = nTableNO( int )	: maxsize = 4,
			-- [6] = nChairNO( int )	: maxsize = 4,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[7] = 32,
			-- [8] = bLookOn( int )	: maxsize = 4,
			-- [9] = nRoomConfigs( unsigned long )	: maxsize = 4,
			-- [10] = nGameVID( int )	: maxsize = 4,
													-- dwParentGameCode	: maxsize = 4	=	1 * 4 * 1,
			[11] = 4,
			-- [12] = dwUserConfigs( unsigned long )	: maxsize = 4,
													-- nReserved2	: maxsize = 12	=	4 * 3 * 1,
			[13] = { maxlen = 3 },
			-- [14] = nRoomTokenID( int )	: maxsize = 4,
			-- [15] = nMbNetType( int )	: maxsize = 4,
			-- [16] = nMatchId( int )	: maxsize = 4,
			-- [17] = nParentGameId( int )	: maxsize = 4,
													-- nReserved3	: maxsize = 4	=	4 * 1 * 1,
			[18] = { maxlen = 1 },
			-- [19] = nUserID( int )	: maxsize = 4,
			-- [20] = nUserType( int )	: maxsize = 4,
			-- [21] = nStatus( int )	: maxsize = 4,
			-- [22] = nTableNO( int )	: maxsize = 4,
			-- [23] = nChairNO( int )	: maxsize = 4,
			-- [24] = nNickSex( int )	: maxsize = 4,
			-- [25] = nPortrait( int )	: maxsize = 4,
			-- [26] = nNetSpeed( int )	: maxsize = 4,
			-- [27] = nClothingID( int )	: maxsize = 4,
													-- szUsername	: maxsize = 32	=	1 * 32 * 1,
			[28] = 32,
													-- szNickName	: maxsize = 16	=	1 * 16 * 1,
			[29] = 16,
			-- [30] = nDeposit( int )	: maxsize = 4,
			-- [31] = nPlayerLevel( int )	: maxsize = 4,
			-- [32] = nScore( int )	: maxsize = 4,
			-- [33] = nBreakOff( int )	: maxsize = 4,
			-- [34] = nWin( int )	: maxsize = 4,
			-- [35] = nLoss( int )	: maxsize = 4,
			-- [36] = nStandOff( int )	: maxsize = 4,
			-- [37] = nBout( int )	: maxsize = 4,
			-- [38] = nTimeCost( int )	: maxsize = 4,
			-- [39] = bRefuse( int )	: maxsize = 4,
													-- nReserved1	: maxsize = 12	=	4 * 3 * 1,
			[40] = { maxlen = 3 },
			maxlen = 40
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nUserType',		-- [2] ( int )
			'nGameID',		-- [3] ( int )
			'nRoomID',		-- [4] ( int )
			'nTableNO',		-- [5] ( int )
			'nChairNO',		-- [6] ( int )
			'szHardID',		-- [7] ( char )
			'bLookOn',		-- [8] ( int )
			'nRoomConfigs',		-- [9] ( unsigned long )
			'nGameVID',		-- [10] ( int )
			'dwParentGameCode',		-- [11] ( char )
			'dwUserConfigs',		-- [12] ( unsigned long )
			'nReserved2',		-- [13] ( int )
			'nRoomTokenID',		-- [14] ( int )
			'nMbNetType',		-- [15] ( int )
			'nMatchId',		-- [16] ( int )
			'nParentGameId',		-- [17] ( int )
			'nReserved3',		-- [18] ( int )
			'nUserID1',		-- [1] ( int )
			'nUserType1',		-- [2] ( int )
			'nStatus',		-- [21] ( int )
			'nTableNO1',		-- [5] ( int )
			'nChairNO1',		-- [6] ( int )
			'nNickSex',		-- [24] ( int )
			'nPortrait',		-- [25] ( int )
			'nNetSpeed',		-- [26] ( int )
			'nClothingID',		-- [27] ( int )
			'szUsername',		-- [28] ( char )
			'szNickName',		-- [29] ( char )
			'nDeposit',		-- [30] ( int )
			'nPlayerLevel',		-- [31] ( int )
			'nScore',		-- [32] ( int )
			'nBreakOff',		-- [33] ( int )
			'nWin',		-- [34] ( int )
			'nLoss',		-- [35] ( int )
			'nStandOff',		-- [36] ( int )
			'nBout',		-- [37] ( int )
			'nTimeCost',		-- [38] ( int )
			'bRefuse',		-- [39] ( int )
			'nReserved1',		-- [40] ( int )
		},
		formatKey = '<i6AiLiALi17A2i13',
		deformatKey = '<i6A32iLiA4Li17A32A16i13',
		maxsize = 244
    },

    GAME_ABORT={
        lengthMap = {
            [10] = {maxlen = 2},
            maxlen = 10
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'bForce',
            'nOldScore',
            'nOldDeposit',
            'nScoreDiff',
            'nDepositDfif',
            'nTableNO',
            'nAbortFlag',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiii',
        deformatKey = '<iiiiiiiiiii',
        maxsize = 44
    },

    GAME_ENTER_INFO={
        lengthMap = {
            [6] = {maxlen = 8},
            [9] = {maxlen = 7},
            [10] = {maxlen = 30,maxwidth = 8,complexType = 'matrix2'},
            [11] = {maxlen = 8},
            [12] = {maxlen = 4},
            maxlen = 12
        },
        nameMap = {
            'nRoomID',
            'nTableNO',
            'nTotalChair',
            'nBaseScore',
            'nBaseDeposit',
            'dwUserStatus',
            'nBout',
            'nKickOffTime',
            'nReserved',
            'nResultDiff',
            'nTotalResult',
            'nReserve'
        },
        formatKey = '<iiiiiLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 1096
    },

    GETVERSION={
        lengthMap = {
            [1] = 32,
            [2] = {maxlen = 4},
            maxlen = 2
        },
        nameMap = {
            'szExeName',
            'nReserved'
        },
        formatKey = '<Aiiii',
        deformatKey = '<A32iiii',
        maxsize = 48
    },

    CHECKVERSION={
        lengthMap = {
            [1] = 32,
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'szExeName',
            'nExeMajorVer',
            'nExeMinorVer',
            'nExeBuildno',
            'nReserved'
        },
        formatKey = '<Aiiiiiii',
        deformatKey = '<A32iiiiiii',
        maxsize = 60
    },

    LEAVE_GAME={
        lengthMap = {
            [9] = 32,
            [10] = {maxlen = 4},
            [11] = {maxlen = 4},
            maxlen = 11
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'bPassive',
            'nSendTable',
            'nSendChair',
            'nSendUser',
            'szHardID',
            'nReserved',
            'nReserved1'
        },
        formatKey = '<iiiiiiiiAiiiiiiii',
        deformatKey = '<iiiiiiiiA32iiiiiiii',
        maxsize = 96
    },

    SOLOPLAYER_HEAD={
        lengthMap = {
            [4] = {maxlen = 8},
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nRoomID',
            'nTableNO',
            'nPlayerCount',
            'dwUserStatus',
            'nReserved'
        },
        formatKey = '<iiiLLLLLLLLiiii',
        deformatKey = '<iiiLLLLLLLLiiii',
        maxsize = 60
    },

    SOLO_PLAYER={
        lengthMap = {
            [10] = 32,
            [11] = 16,
            [21] = {maxlen = 4},
            maxlen = 21
        },
        nameMap = {
            'nUserID',
            'nUserType',
            'nStatus',
            'nTableNO',
            'nChairNO',
            'nNickSex',
            'nPortrait',
            'nNetSpeed',
            'nClothingID',
            'szUserName',
            'szNickName',
            'nDeposit',
            'nPlayerLevel',
            'nScore',
            'nBreakOff',
            'nWin',
            'nLoss',
            'nStandOff',
            'nBout',
            'nTimeCost',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiAAiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiA32A16iiiiiiiiiiiii',
        maxsize = 136
    },

    START_GAME={
        lengthMap = {
            [6] = {maxlen = 3},
            maxlen = 6
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nMatchID',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    START_TEAM_READY={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    CANCEL_TEAM_MATCH={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    USER_POSITION={
        lengthMap = {
            [6] = {maxlen = 8},
            [9] = {maxlen = 2},
            maxlen = 9
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nPlayerCount',
            'dwUserStatus',
            'dwTableStatus',
            'nCountdown',
            'nReserved'
        },
        formatKey = '<iiiiiLLLLLLLLLiii',
        deformatKey = '<iiiiiLLLLLLLLLiii',
        maxsize = 68
    },

    GAME_PULSE={
        lengthMap = {
            [4] = {maxlen = 1},
            maxlen = 4
        },
        nameMap = {
            'nUserID',
            'dwAveDelay',
            'dwMaxDelay',
            'nReserved'
        },
        formatKey = '<iLLi',
        deformatKey = '<iLLi',
        maxsize = 16
    },

    VERSION={
        lengthMap = {
            [4] = {maxlen = 4},
            maxlen = 4
        },
        nameMap = {
            'nMajorVer',
            'nMinorVer',
            'nBuildNO',
            'nReserved'
        },
        formatKey = '<iiiiiii',
        deformatKey = '<iiiiiii',
        maxsize = 28
    },
    
    LEAVE_GAME_TOOFAST={
        lengthMap = {
            --,
            maxlen = 1
        },
        nameMap = {
            'nSecond'
        },
        formatKey = '<i',
        deformatKey = '<i',
        maxsize = 4
    },

    CHAT_TO_TABLE={
        lengthMap = {
            [5] = 32,
            [6] = 64,
            [7] = {maxlen = 4},
            maxlen = 7
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'szHardID',
            'szChatMsg',
            'nReserved'
        },
        formatKey = '<iiiiAAiiii',
        deformatKey = '<iiiiA32A64iiii',
        maxsize = 128
    },

    DEPOSIT_NOT_ENOUGH={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nDeposit',
            'nMinDeposit',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    DEPOSIT_TOO_HIGH={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nDeposit',
            'nMaxDeposit',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    SCORE_NOT_ENOUGH={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nScore',
            'nMinScore',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    SCORE_TOO_HIGH={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nScore',
            'nMaxScore',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    USER_BOUT_TOO_HIGH={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nBout',
            'nMaxBout',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    TABLE_BOUT_TOO_HIGH={
        lengthMap = {
            [4] = {maxlen = 4},
            maxlen = 4
        },
        nameMap = {
            'nTableNO',
            'nBout',
            'nMaxBout',
            'nReserved'
        },
        formatKey = '<iiiiiii',
        deformatKey = '<iiiiiii',
        maxsize = 28
    },

    USER_DEPOSITEVENT={
        lengthMap = {
            [7] = {maxlen = 4},
            maxlen = 7
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nEvent',
            'nDepositDiff',
            'nDeposit',
            'nBaseDeposit',
            'nReserved'
        },
        formatKey = '<iiiiiiiiii',
        deformatKey = '<iiiiiiiiii',
        maxsize = 40
    },

    LOOK_SAFE_DEPOSIT={
        lengthMap = {
            [4] = 32,
            [5] = {maxlen = 8},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nGameID',
            'dwIPAddr',
            'szHardID',
            'nReserved'
        },
        formatKey = '<iiLAiiiiiiii',
        deformatKey = '<iiLA32iiiiiiii',
        maxsize = 76
    },

    SAFE_DEPOSIT_EX={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nDeposit',
            'bHaveSecurePwd',
            'nRemindDeposit',
            'nReserved'
        },
        formatKey = '<iiliiiii',
        deformatKey = '<iiliiiii',
        maxsize = 32
    },

    TAKESAVE_SAFE_DEPOSIT={
        lengthMap = {
            [13] = 32,
            [18] = {maxlen = 2},
            maxlen = 18
        },
        nameMap = {
            'nUserID',
            'nGameID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nDeposit',
            'nKeyResult',
            'nPlayingGameID',
            'nGameVID',
            'nTransferTotal',
            'nTransferLimit',
            'dwIPAddr',
            'szHardID',
            'nGameDeposit',
            'dwFlags',
            'llMonthTransferTotal',
            'llMonthTransferLimit',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiiiLAiLddii',
        deformatKey = '<iiiiiiiiiiiLA32iLddii',
        maxsize = 112
    },

    SOLO_TABLE={
        lengthMap = {
            [4] = {maxlen = 8},
            [5] = {maxlen = 5},
            maxlen = 5
        },
        nameMap = {
            'nRoomID',
            'nTableNO',
            'nUserCount',
            'nUserIDs',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiii',
        maxsize = 64
    },

    GET_TABLE_INFO={
        lengthMap = {
            [6] = {maxlen = 3},
            maxlen = 6
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'dwFlags',
            'nReserved'
        },
        formatKey = '<iiiiLiii',
        deformatKey = '<iiiiLiii',
        maxsize = 32
    },

    ENTER_BKGFKG={
        lengthMap = {
            [7] = {maxlen = 4},
            maxlen = 7
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'dwFlag',
            'nRecordTime',
            'nReserved'
        },
        formatKey = '<iiiiLiiiii',
        deformatKey = '<iiiiLiiiii',
        maxsize = 40
    },

    DEPOSIT_NOT_ENOUGH={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nDeposit',
            'nMinDeposit',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    DEPOSIT_TOO_HIGH={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nDeposit',
            'nMaxDeposit',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    GAME_ABORT={
        lengthMap = {
            [10] = {maxlen = 2},
            maxlen = 10
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'bForce',
            'nOldScore',
            'nOldDeposit',
            'nScoreDiff',
            'nDepositDfif',
            'nTableNO',
            'nAbortFlag',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiii',
        deformatKey = '<iiiiiiiiiii',
        maxsize = 44
    },
    CHAT_FROM_TABLE={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 6
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'dwFlags',
            'nHeadLen',
            'nReserved',
            'nMsgLen'
        },
        formatKey = '<iiLiiiiii',
        deformatKey = '<iiLiiiiii',
        maxsize = 36
    },

    SAFE_RNDKEY={
        lengthMap = {
            [3] = {maxlen = 4},
            maxlen = 3
        },
        nameMap = {
            'nUserID',
            'nRndKey',
            'nReserved'
        },
        formatKey = '<iiiiii',
        deformatKey = '<iiiiii',
        maxsize = 24
    },
    CHAT_TO_TABLE={
        lengthMap = {
            [5] = 32,
            [6] = 64,
            [7] = {maxlen = 4},
            maxlen = 7
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'szHardID',
            'szChatMsg',
            'nReserved'
        },
        formatKey = '<iiiiAAiiii',
        deformatKey = '<iiiiA32A64iiii',
        maxsize = 128
    },

     ASK_ONLY_CHANGE_CHAIR={
        lengthMap = {
            [6] = {maxlen = 4},
            maxlen = 6
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nToChairNO',
            'nReserved'
        },
        formatKey = '<iiiiiiiii',
        deformatKey = '<iiiiiiiii',
        maxsize = 36
    },

    SOMEONE_NEWCHAIR={
        lengthMap = {
            [6] = {maxlen = 4},
            maxlen = 6
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nOldChairNO',
            'nNewChairNO',
            'nReserved'
        },
        formatKey = '<iiiiiiiii',
        deformatKey = '<iiiiiiiii',
        maxsize = 36
    },

    HOME_TICK_PLAYER={
        lengthMap = {
            [8] = {maxlen = 4},
            maxlen = 8
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nTickModel',
            'nTargetUserID',
            'nTargetChairNO',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiii',
        deformatKey = '<iiiiiiiiiii',
        maxsize = 44
    },

    TELLLIENT_KICKOFF_EX={
        lengthMap = {
            [7] = {maxlen = 4},
            maxlen = 7
        },
        nameMap = {
            'nHomeUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nUserID',
            'nTickModel',
            'nReserved'
        },
        formatKey = '<iiiiiiiiii',
        deformatKey = '<iiiiiiiiii',
        maxsize = 40
    },

    TELLLIENT_HOMEUSERCHANGED={
        lengthMap = {
            [4] = {maxlen = 4},
            maxlen = 4
        },
        nameMap = {
            'nHomeUserID',
            'nRoomID',
            'nTableNO',
            'nReserved'
        },
        formatKey = '<iiiiiiiiii',
        deformatKey = '<iiiiiiiiii',
        maxsize = 28
    },

    GR_SYNCH_SOCLALLY_INFO={
        lengthMap = {
            [6] = 128,
            [7] = 256,
            [8] = {maxlen = 8},
            maxlen = 8
        },
        nameMap = {
            'nUserID',
            'nGameID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'szHeadUrl',
            'szLBSInfo',
            'nReserved'
        },
        formatKey = '<iiiiiAAiiiiiiii',
        deformatKey = '<iiiiiA256A256iiiiiiii',
        maxsize = 436
    },

    ONE_PLAYER_SOCLALLY={
        lengthMap = {
            [2] = 128,
            [3] = 256,
            maxlen = 3
        },
        nameMap = {
            'nUserID',
            'szHeadUrl',
            'szLBSInfo'
        },
        formatKey = '<iAA',
        deformatKey = '<iA128A256',
        maxsize = 388
    },

    TELLCLIENT_SOCLALLY={
        lengthMap = {
            [2] = {maxlen = 8},
            maxlen = 2
        },
        nameMap = {
            'nCount',
            'nReserved'
        },
        formatKey = '<iiiiiiiii',
        deformatKey = '<iiiiiiiii',
        maxsize = 36
    },

    TOCLIENT_HOMEINFO_ONDXXW={
        lengthMap = {
            [4] = {maxlen = 3},
            maxlen = 4
        },
        nameMap = {
            'nHomeUserID',
            'nHomeChairID',
            'nEnterFlag',
            'nReserved'
        },
        formatKey = '<ii iiii',
        deformatKey = '<ii iiii',
        maxsize = 24
    },

    ERROR_INFO={
        lengthMap = {
            [5] = 64,
            [6] = {maxlen = 8},
            maxlen = 6
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'szMsg',
            'nReserved',
        },
        formatKey = '<iiiiAiiiiiiii',
        deformatKey = '<iiiiA64iiiiiiii',
        maxsize = 112
    },

    TEAM_GAME_ROOM_LEAVE_GAME={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    USER_ARENA_RESULT={
        lengthMap = {
            -- [1] = nMatchID( int )	: maxsize = 4,
            -- [2] = nUserID( int )	: maxsize = 4,
            -- [3] = nGameID( int )	: maxsize = 4,
            -- [4] = nRoomID( int )	: maxsize = 4,
            -- [5] = nTableID( int )	: maxsize = 4,
            -- [6] = nChairID( int )	: maxsize = 4,
            -- [7] = nHP( int )	: maxsize = 4,
            -- [8] = nDiffHP( int )	: maxsize = 4,
            -- [9] = nAddition( int )	: maxsize = 4,
            -- [10] = nBoutAddition( int )	: maxsize = 4,
            -- [11] = nMatchScore( int )	: maxsize = 4,
            -- [12] = nMatchDiffScore( int )	: maxsize = 4,
            -- [13] = nStreaking( int )	: maxsize = 4,
            -- [14] = nMaxStreaking( int )	: maxsize = 4,
            -- [15] = nTotalBout( int )	: maxsize = 4,
            -- [16] = nWinBout( int )	: maxsize = 4,
            -- [17] = nRewardLevelOld( int )	: maxsize = 4,
            -- [18] = nRewardLevelNew( int )	: maxsize = 4,
                    -- nReserved	: maxsize = 32	=	4 * 8 * 1,
            [19] = { maxlen = 5 },
            [20] = { maxlen = 5 },
            [23] = { maxlen = 6 },
            maxlen = 23
        },
        nameMap = {
            'nMatchID', -- [1] ( int )
            'nUserID',  -- [2] ( int )
            'nGameID',  -- [3] ( int )
            'nRoomID',  -- [4] ( int )
            'nTableID', -- [5] ( int )
            'nChairID', -- [6] ( int )
            'nHP',              -- [7] ( int )
            'nDiffHP',          -- [8] ( int )
            'nAddition',        -- [9] ( int )
            'nBoutAddition',    -- [10] ( int )
            'nMatchScore',      -- [11] ( int )
            'nMatchDiffScore',  -- [12] ( int )
            'nStreaking',       -- [13] ( int )
            'nMaxStreaking',    -- [14] ( int )
            'nTotalBout',       -- [15] ( int )
            'nWinBout',         -- [16] ( int )
            'nRewardLevelOld',  -- [17] ( int )
            'nRewardLevelNew',  -- [18] ( int )
            'nAdditionDetail',  -- [19] ( int )
            'nNextAddiDetail',  
            'nSilverDiff',  
            'nScoreDiff',  
            'nReserved',        -- [20] ( int )
        },
        formatKey = '<i36',
        deformatKey = '<i36',
        maxsize = 144
    },

    MATCH_ARENA_EVENT={
        lengthMap = {
            -- [1] = nEventType( int )	: maxsize = 4,
            -- [2] = nEventValue( int )	: maxsize = 4,
            -- nReserved	: maxsize = 32	=	4 * 8 * 1,
            [3] = { maxlen = 8 },
            maxlen = 3
        },
        nameMap = {
            'nEventType',       -- [1] ( int )
            'nEventValue',      -- [2] ( int )
            'nReserved',        -- [3] ( int )
        },
        formatKey = '<i10',
        deformatKey = '<i10',
        maxsize = 40
    },
    MATCH_ARENA_REWARD={
        lengthMap = {
            -- [1] = nUserID( int )	: maxsize = 4,
            -- [2] = nGameID( int )	: maxsize = 4,
            -- [3] = nMatchID( int )	: maxsize = 4,
            -- [4] = nIsReissue( int )	: maxsize = 4,
            -- szNotifyContent	: maxsize = 128	=	1 * 128 * 1,
            [5] = 128,
            -- nReserved	: maxsize = 32	=	4 * 8 * 1,
            [6] = { maxlen = 8 },
            maxlen = 6
        },
        nameMap = {
            'nUserID',          -- [1] ( int )
            'nGameID',          -- [2] ( int )
            'nMatchID',         -- [3] ( int )
            'nIsReissue',        -- [4] ( int )
            'szNotifyContent',  -- [5] ( char )
            'nReserved',        -- [6] ( int )
        },
        formatKey = '<i4Ai8',
        deformatKey = '<i4A128i8',
        maxsize = 176
    },

    MATCHERONDXXW={
        lengthMap = {
            -- [1] = nUserID( int )	: maxsize = 4,
            -- [2] = nMatchID( int )	: maxsize = 4,
            -- [3] = nHP( int )	: maxsize = 4,
            -- [4] = nBoutScore( int )	: maxsize = 4,
            -- nReserved	: maxsize = 16	=	4 * 4 * 1,
            [5] = { maxlen = 4 },
            maxlen = 5
        },
        nameMap = {
            'nUserID',      -- [1] ( int )
            'nMatchID',     -- [2] ( int )
            'nHP',          -- [3] ( int )
            'nBoutScore',   -- [4] ( int )
            'nReserved',    -- [5] ( int )
        },
        formatKey = '<i8',
        deformatKey = '<i8',
        maxsize = 32
    },
}

local GamePublicInterface = import("src.app.Game.mMyGame.GamePublicInterface")

if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
end

return BaseGameReq
