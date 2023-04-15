local AssistBaseRequest = {
    MessageMap = {
        GR_GAME_PULSE = 201020
    },

    GAME_PULSE =
    {
        lengthMap =
        {
            [4] = { maxlen = 1 },
            maxlen = 4
        },
        nameMap =
        {
            'nUserID',
            'dwAveDelay',
            'dwMaxDelay',
            'nReserved',
        },
        formatKey = '<iL2i',
        deformatKey = '<iL2i',
        maxsize = 16
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
}

cc.load('treepack').resolveReference(AssistBaseRequest)

return AssistBaseRequest