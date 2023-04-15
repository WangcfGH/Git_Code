local treepack = cc.load('treepack')

local NewPlayerGiftReq = 
{
    NEWPLAYER_GIFT_INFO_REQ={
        lengthMap = {
            -- [1] = nUserID( int )	: maxsize = 4,
            maxlen = 1
        },
        nameMap = {
            'nUserID',		-- [1] ( int )
        },
        formatKey = '<i',
        deformatKey = '<i',
        maxsize = 4
    },
    NEWPLAYER_GIFT_INFO_RESP={
    lengthMap = {
        -- [1] = nGiftIndex( int )	: maxsize = 4,
        -- [2] = nGiftTime( int )	: maxsize = 4,
        maxlen = 2
    },
    nameMap = {
        'nGiftIndex',		-- [1] ( int )
        'nGiftTime',		-- [2] ( int )
    },
    formatKey = '<i2',
    deformatKey = '<i2',
    maxsize = 8
    },
    GET_NEWPLAYER_GIFT_REQ={
    lengthMap = {
        -- [1] = nUserID( int )	: maxsize = 4,
        -- [2] = nGiftIndex( int )	: maxsize = 4,
        -- [3] = nCount( int )	: maxsize = 4,
                                                -- kpiClientData	: 				maxsize = 568,
        [4] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
        maxlen = 4
    },
    nameMap = {
        'nUserID',		-- [1] ( int )
        'nGiftIndex',		-- [2] ( int )
        'nCount',		-- [3] ( int )
        'kpiClientData',		-- [4] ( refer )
    },
    formatKey = '<i5Ai4Ai5A6i33Ai32L',
    deformatKey = '<i5A16i4A16i5A32A32A32A32A32A32i33A36i32L',
    maxsize = 580
    },
    GET_NEWPLAYER_GIFT_RESP={
    lengthMap = {
        -- [1] = nUserID( int )	: maxsize = 4,
        -- [2] = nResult( int )	: maxsize = 4,
        -- [3] = nGiftTime( int )	: maxsize = 4,
                                                -- kpiClientData	: 				maxsize = 568,
        [4] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
        maxlen = 4
    },
    nameMap = {
        'nUserID',		-- [1] ( int )
        'nResult',		-- [2] ( int )
        'nGiftTime',		-- [3] ( int )
        'kpiClientData',		-- [4] ( refer )
    },
    formatKey = '<i5Ai4Ai5A6i33Ai32L',
    deformatKey = '<i5A16i4A16i5A32A32A32A32A32A32i33A36i32L',
    maxsize = 580
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
}

cc.load('treepack').resolveReference(NewPlayerGiftReq)
return NewPlayerGiftReq