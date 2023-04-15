local treepack = cc.load('treepack')

local ExchangeLotteryReq = 
{
	KPIMBHardInfo={
		lengthMap = {
													-- ImeiId	: maxsize = 32	=	1 * 32 * 1,
			[1] = 32,
													-- WifiId	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
													-- ImsiId	: maxsize = 32	=	1 * 32 * 1,
			[3] = 32,
													-- SimSerialNo	: maxsize = 32	=	1 * 32 * 1,
			[4] = 32,
													-- SystemId	: maxsize = 32	=	1 * 32 * 1,
			[5] = 32,
													-- nReserved	: maxsize = 128	=	4 * 32 * 1,
			[6] = { maxlen = 32 },
			maxlen = 6
		},
		nameMap = {
			'ImeiId',		-- [1] ( char )
			'WifiId',		-- [2] ( char )
			'ImsiId',		-- [3] ( char )
			'SimSerialNo',		-- [4] ( char )
			'SystemId',		-- [5] ( char )
			'nReserved',		-- [6] ( int )
		},
		formatKey = '<A5i32',
		deformatKey = '<A32A32A32A32A32i32',
		maxsize = 288
	},
	KPI_CLIENT_DATA={
		lengthMap = {
			-- [1] = UserId( int )	: maxsize = 4,
			-- [2] = GameId( int )	: maxsize = 4,
													-- GameCode	: maxsize = 16	=	1 * 16 * 1,
			[3] = 16,
			-- [4] = ExeMajorVer( int )	: maxsize = 4,
			-- [5] = ExeMinorVer( int )	: maxsize = 4,
			-- [6] = ExeBuildno( int )	: maxsize = 4,
			-- [7] = RecomGameId( int )	: maxsize = 4,
													-- RecomGameCode	: maxsize = 16	=	1 * 16 * 1,
			[8] = 16,
			-- [9] = RecomExeMajorVer( int )	: maxsize = 4,
			-- [10] = RecomExeMinorVer( int )	: maxsize = 4,
			-- [11] = RecomExeBuildno( int )	: maxsize = 4,
			-- [12] = GroupId( int )	: maxsize = 4,
			-- [13] = Channel( int )	: maxsize = 4,
													-- HardId	: maxsize = 32	=	1 * 32 * 1,
			[14] = 32,
													-- MobileHardInfo	: 				maxsize = 288,
			[15] = { refered = 'KPIMBHardInfo', complexType = 'link_refer' },
			-- [16] = PkgType( int )	: maxsize = 4,
													-- CUID	: maxsize = 36	=	1 * 36 * 1,
			[17] = 36,
													-- nReserved	: maxsize = 128	=	4 * 32 * 1,
			[18] = { maxlen = 32 },
			-- [19] = dwRecordTime( unsigned long )	: maxsize = 4,
			maxlen = 19
		},
		nameMap = {
			'UserId',		-- [1] ( int )
			'GameId',		-- [2] ( int )
			'GameCode',		-- [3] ( char )
			'ExeMajorVer',		-- [4] ( int )
			'ExeMinorVer',		-- [5] ( int )
			'ExeBuildno',		-- [6] ( int )
			'RecomGameId',		-- [7] ( int )
			'RecomGameCode',		-- [8] ( char )
			'RecomExeMajorVer',		-- [9] ( int )
			'RecomExeMinorVer',		-- [10] ( int )
			'RecomExeBuildno',		-- [11] ( int )
			'GroupId',		-- [12] ( int )
			'Channel',		-- [13] ( int )
			'HardId',		-- [14] ( char )
			'MobileHardInfo',		-- [15] ( refer )
			'PkgType',		-- [16] ( int )
			'CUID',		-- [17] ( char )
			'nReserved',		-- [18] ( int )
			'dwRecordTime',		-- [19] ( unsigned long )
		},
		formatKey = '<i2Ai4Ai5A6i33Ai32L',
		deformatKey = '<i2A16i4A16i5A32A32A32A32A32A32i33A36i32L',
		maxsize = 568
	},		

	QUERY_WINNINGSTREAK_INFO={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
			-- [3] = nPlatformType( int )	: maxsize = 4,
													-- nReserved4	: maxsize = 16	=	4 * 4 * 1,
			[4] = { maxlen = 4 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szUserName',		-- [2] ( char )
			'nPlatformType',		-- [3] ( int )
			'nReserved4',		-- [4] ( int )
		},
		formatKey = '<iAi5',
		deformatKey = '<iA32i5',
		maxsize = 56
	},

    WINNINGSTREAK_INFO_RSP={
		lengthMap = {
			-- [1] = nChallengeType( int )	: maxsize = 4,
			-- [2] = nBout( int )	: maxsize = 4,
			-- [3] = nState( int )	: maxsize = 4,
													-- nChallengeCount	: maxsize = 16	=	4 * 4 * 1,
			[4] = { maxlen = 4 },
			-- [5] = bShow( int )	: maxsize = 4,
			-- [6] = bCanJoin( int )	: maxsize = 4,
			-- [7] = nStringLength( int )	: maxsize = 4,
			maxlen = 7
		},
		nameMap = {
			'nChallengeType',		-- [1] ( int )
			'nBout',		-- [2] ( int )
			'nState',		-- [3] ( int )
			'nChallengeCount',		-- [4] ( int )
			'bShow',		-- [5] ( int )
			'bCanJoin',		-- [6] ( int )
			'nStringLength',		-- [7] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	BUY_CHALLENGE_CHANCE={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPlatformType( int )	: maxsize = 4,
			-- [3] = nChallengeType( int )	: maxsize = 4,
			-- [4] = nBuyType( int )	: maxsize = 4,
													-- kpiClientData	: 				maxsize = 568,
			[5] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
													-- nReserved4	: maxsize = 16	=	4 * 4 * 1,
			[6] = { maxlen = 4 },
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPlatformType',		-- [2] ( int )
			'nChallengeType',		-- [3] ( int )
			'nBuyType',		-- [4] ( int )
			'kpiClientData',		-- [5] ( refer )
			'nReserved4',		-- [6] ( int )
		},
		formatKey = '<i6Ai4Ai5A6i33Ai32Li4',
		deformatKey = '<i6A16i4A16i5A32A32A32A32A32A32i33A36i32Li4',
		maxsize = 600
	},
	TAKE_CHALLELLENGE_AWARD={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
			-- [3] = nMultipleTake( int )	: maxsize = 4,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[4] = { maxlen = 4 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szUserName',		-- [2] ( char )
			'nMultipleTake',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<iAi5',
		deformatKey = '<iA32i5',
		maxsize = 56
	},
	TAKE_CHALLELLENGE_AWARD_RSP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nBout( int )	: maxsize = 4,
			-- [3] = nPlatformType( int )	: maxsize = 4,
			-- [4] = nChallengeType( int )	: maxsize = 4,
			-- [5] = nState( int )	: maxsize = 4,
													-- nChallengeCount	: maxsize = 16	=	4 * 4 * 1,
			[6] = { maxlen = 4 },
			-- [7] = bCanReChallenge( int )	: maxsize = 4,
			-- [8] = fMultiPower( float )	: maxsize = 4,
			-- [9] = nSliverTotalAward( int )	: maxsize = 4,
													-- szWebID	: maxsize = 32	=	1 * 32 * 1,
			[10] = 32,
			-- [11] = nActID( int )	: maxsize = 4,
			maxlen = 11
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nBout',		-- [2] ( int )
			'nPlatformType',		-- [3] ( int )
			'nChallengeType',		-- [4] ( int )
			'nState',		-- [5] ( int )
			'nChallengeCount',		-- [6] ( int )
			'bCanReChallenge',		-- [7] ( int )
			'fMultiPower',		-- [8] ( float )
			'nSliverTotalAward',		-- [9] ( int )
			'szWebID',		-- [10] ( char )
			'nActID',		-- [11] ( int )
		},
		formatKey = '<i10fiAi',
		deformatKey = '<i10fiA32i',
		maxsize = 84
	},

	CLICK_CHALLENGETYPE_LOG={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nClickFrom( int )	: maxsize = 4,
			-- [3] = nChallengeType( int )	: maxsize = 4,
			-- [4] = nButtonType( int )	: maxsize = 4,
													-- szClickTime	: maxsize = 32	=	1 * 32 * 1,
			[5] = 32,
													-- nReserved4	: maxsize = 16	=	4 * 4 * 1,
			[6] = { maxlen = 4 },
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nClickFrom',		-- [2] ( int )
			'nChallengeType',		-- [3] ( int )
			'nButtonType',		-- [4] ( int )
			'szClickTime',		-- [5] ( char )
			'nReserved4',		-- [6] ( int )
		},
		formatKey = '<i4Ai4',
		deformatKey = '<i4A32i4',
		maxsize = 64
	},
}

cc.load('treepack').resolveReference(ExchangeLotteryReq)

return ExchangeLotteryReq