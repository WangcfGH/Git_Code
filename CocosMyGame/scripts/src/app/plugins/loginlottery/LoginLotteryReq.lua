local AssistBaseReq = import("src.app.GameHall.models.assist.AssistBaseRequest")

local LoginLotteryReq = {
    KPI_CLIENT_DATA = AssistBaseReq.KPI_CLIENT_DATA,

    LOTTERY_REQ={
        lengthMap = {
            [2] = 12,
            maxlen = 4
        },
        nameMap = {
            'nUserID',
            'szPhoneNO',
            'bIsmember',
            'nPlatform'
        },
        formatKey = '<iAii',
        deformatKey = '<iA12ii',
        maxsize = 24
    },

    LOTTERY_COUNT_RESP={
        lengthMap = {
            [7] = {maxlen = 4},
            maxlen = 7
        },
        nameMap = {
            'nUserID',
            'nWinCount',
            'nLeftCount',
            'nLotteryCount',
            'nTopPrizeCount',
            'bRunOut',
            'nReserved'
        },
        formatKey = '<iiiiiiiiii',
        deformatKey = '<iiiiiiiiii',
        maxsize = 40
    },

    LOGIN_LOTTERY_INFO_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szDeviceID	: maxsize = 100	=	1 * 100 * 1,
			[2] = 100,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szDeviceID',		-- [2] ( char )
		},
		formatKey = '<iA',
		deformatKey = '<iA100',
		maxsize = 104
	},
	
	LOGIN_LOTTERY_INFO_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nLotteryCount( int )	: maxsize = 4,
			-- [3] = nLotteryStatus( int )	: maxsize = 4,
			-- [4] = nContinuousLoginDays( int )	: maxsize = 4,
													-- nDays	: maxsize = 16	=	4 * 4 * 1,
			[5] = { maxlen = 4 },
													-- bTakes	: maxsize = 16	=	4 * 4 * 1,
			[6] = { maxlen = 4 },
			-- [7] = nTotalFreeLotteryCount( int )	: maxsize = 4,
			-- [8] = nVideoCount( int )	: maxsize = 4,
			-- [9] = nExtraRewardIdx( int )	: maxsize = 4,
			maxlen = 9
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nLotteryCount',		-- [2] ( int )
			'nLotteryStatus',		-- [3] ( int )
			'nContinuousLoginDays',		-- [4] ( int )
			'nDays',		-- [5] ( int )
			'bTakes',		-- [6] ( int )
			'nTotalFreeLotteryCount',		-- [7] ( int )
			'nVideoCount',		-- [8] ( int )
			'nExtraRewardIdx',		-- [9] ( int )
		},
		formatKey = '<i15',
		deformatKey = '<i15',
		maxsize = 60
	},

    LOGIN_LOTTERY_DRAW_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
													-- szDeviceID	: maxsize = 100	=	1 * 100 * 1,
			[3] = 100,
													-- kpiClientData	: 				maxsize = 568,
			[4] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szUserName',		-- [2] ( char )
			'szDeviceID',		-- [3] ( char )
			'kpiClientData',		-- [4] ( refer )
		},
		formatKey = '<iA2i2Ai4Ai5A6i33Ai32L',
		deformatKey = '<iA32A100i2A16i4A16i5A32A32A32A32A32A32i33A36i32L',
		maxsize = 704
	},
	LOGIN_LOTTERY_DRAW_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nResult( int )	: maxsize = 4,
			-- [3] = isDouble( int )	: maxsize = 4,
			-- [4] = nLotteryCount( int )	: maxsize = 4,
			-- [5] = nExtraRewardIdx( int )	: maxsize = 4,
			-- [6] = nVideoCount( int )	: maxsize = 4,
													-- nReserved2	: maxsize = 8	=	4 * 2 * 1,
			[7] = { maxlen = 2 },
			maxlen = 7
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nResult',		-- [2] ( int )
			'isDouble',		-- [3] ( int )
			'nLotteryCount',		-- [4] ( int )
			'nExtraRewardIdx',		-- [5] ( int )
			'nVideoCount',		-- [6] ( int )
			'nReserved2',		-- [7] ( int )
		},
		formatKey = '<i8',
		deformatKey = '<i8',
		maxsize = 32
	},

    LOGIN_LOTTERY_REWARD_REQ_EX={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nDays( int )	: maxsize = 4,
			-- [3] = nCount( int )	: maxsize = 4,
													-- kpiClientData	: 				maxsize = 568,
			[4] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nDays',		-- [2] ( int )
			'nCount',		-- [3] ( int )
			'kpiClientData',		-- [4] ( refer )
		},
		formatKey = '<i5Ai4Ai5A6i33Ai32L',
		deformatKey = '<i5A16i4A16i5A32A32A32A32A32A32i33A36i32L',
		maxsize = 580
	},
	LOGIN_LOTTERY_REWARD_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nResult( int )	: maxsize = 4,
			-- [3] = isDouble( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nResult',		-- [2] ( int )
			'isDouble',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},
	LOGIN_LOTTERY_TAKE_EXTRA_REWARD={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nExtraRewardIdx( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nExtraRewardIdx',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
	},
	
	LOGIN_LOTTERY_TAKE_EXTRA_REWARD_RSP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nResult( int )	: maxsize = 4,
			-- [3] = nCount( int )	: maxsize = 4,
													-- nRewardType	: maxsize = 48	=	4 * 12 * 1,
			[4] = { maxlen = 12 },
													-- nRewardCount	: maxsize = 48	=	4 * 12 * 1,
			[5] = { maxlen = 12 },
			-- [6] = nVideoCount( int )	: maxsize = 4,
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nResult',		-- [2] ( int )
			'nCount',		-- [3] ( int )
			'nRewardType',		-- [4] ( int )
			'nRewardCount',		-- [5] ( int )
			'nVideoCount',		-- [6] ( int )
		},
		formatKey = '<i28',
		deformatKey = '<i28',
		maxsize = 112
	},
}

cc.load('treepack').resolveReference(LoginLotteryReq)

return LoginLotteryReq