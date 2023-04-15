local treepack = cc.load('treepack')

local ExchangeLotteryReq = 
{
    EXCHANGE_LOTTERY_REWARD={
		lengthMap = {
			-- [1] = nType( int )	: maxsize = 4,
			-- [2] = nCount( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nType',		-- [1] ( int )
			'nCount',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
    },
    EXCHANGE_LOTTERY_REWARD_LIST={
		lengthMap = {
			-- [1] = nNum( int )	: maxsize = 4,
													-- stReward	: maxsize = 80	=	8 * 10 * 1,
			[2] = { maxlen = 10, refered = 'EXCHANGE_LOTTERY_REWARD', complexType = 'link_refer' },
			maxlen = 2
		},
		nameMap = {
			'nNum',		-- [1] ( int )
			'stReward',		-- [2] ( refer )
		},
		formatKey = '<i21',
		deformatKey = '<i21',
		maxsize = 84
    },
    EXCHANGE_LOTTERY_RESULT={
		lengthMap = {
			-- [1] = nIndex( int )	: maxsize = 4,
			-- [2] = nType( int )	: maxsize = 4,
			-- [3] = nCount( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nIndex',		-- [1] ( int )
			'nType',		-- [2] ( int )
			'nCount',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
    },
		EXCHANGE_LOTTERY_RESULT_LIST={
			lengthMap = {
				-- [1] = nNum( int )	: maxsize = 4,
														-- stReward	: maxsize = 1200	=	12 * 100 * 1,
				[2] = { maxlen = 100, refered = 'EXCHANGE_LOTTERY_RESULT', complexType = 'link_refer' },
				maxlen = 2
			},
			nameMap = {
				'nNum',		-- [1] ( int )
				'stReward',		-- [2] ( refer )
			},
			formatKey = '<i301',
			deformatKey = '<i301',
			maxsize = 1204
		},
	EXCHANGE_LOTTERY_INFO_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nBout( int )	: maxsize = 4,
			-- [3] = nChannelID( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nBout',		-- [2] ( int )
			'nChannelID',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},
	EXCHANGE_LOTTERY_INFO_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nStateCode( int )	: maxsize = 4,
			-- [3] = nCount( int )	: maxsize = 4,
			-- [4] = nFirstFree( int )	: maxsize = 4,
			-- [5] = nGiveCardMaker( int )	: maxsize = 4,
			-- [6] = nBoutLimit( int )	: maxsize = 4,
													-- stRewardList	: 				maxsize = 84,
			[7] = { refered = 'EXCHANGE_LOTTERY_REWARD_LIST', complexType = 'link_refer' },
			maxlen = 7
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nStateCode',		-- [2] ( int )
			'nCount',		-- [3] ( int )
			'nFirstFree',		-- [4] ( int )
			'nGiveCardMaker',		-- [5] ( int )
			'nBoutLimit',		-- [6] ( int )
			'stRewardList',		-- [7] ( refer )
		},
		formatKey = '<i27',
		deformatKey = '<i27',
		maxsize = 108
	},
	EXCHANGE_LOTTERY_DRAW_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nBout( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[3] = 32,
			-- [4] = nChannelID( int )	: maxsize = 4,
			-- [5] = nDrawCount( int )	: maxsize = 4,
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nBout',		-- [2] ( int )
			'szUserName',		-- [3] ( char )
			'nChannelID',		-- [4] ( int )
			'nDrawCount',		-- [5] ( int )
		},
		formatKey = '<i2Ai2',
		deformatKey = '<i2A32i2',
		maxsize = 48
	},
	EXCHANGE_LOTTERY_DRAW_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nStateCode( int )	: maxsize = 4,
			-- [3] = nDrawCount( int )	: maxsize = 4,
			-- [4] = nUsedFirstFree( int )	: maxsize = 4,
													-- nResultList	: 				maxsize = 1204,
			[5] = { refered = 'EXCHANGE_LOTTERY_RESULT_LIST', complexType = 'link_refer' },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nStateCode',		-- [2] ( int )
			'nDrawCount',		-- [3] ( int )
			'nUsedFirstFree',		-- [4] ( int )
			'nResultList',		-- [5] ( refer )
		},
		formatKey = '<i305',
		deformatKey = '<i305',
		maxsize = 1220
	},
    EXCHANGE_LOTTERY_CONFIG_CHANGE={
		lengthMap = {
			-- [1] = nGiveCardMaker( int )	: maxsize = 4,
			-- [2] = nBoutLimit( int )	: maxsize = 4,
			-- [3] = nFirstFree( int )	: maxsize = 4,
													-- stRewardList	: 				maxsize = 84,
			[4] = { refered = 'EXCHANGE_LOTTERY_REWARD_LIST', complexType = 'link_refer' },
			maxlen = 4
		},
		nameMap = {
			'nGiveCardMaker',		-- [1] ( int )
			'nBoutLimit',		-- [2] ( int )
			'nFirstFree',		-- [3] ( int )
			'stRewardList',		-- [4] ( refer )
		},
		formatKey = '<i24',
		deformatKey = '<i24',
		maxsize = 96
	},
	GAME_EXPRESSION_LOTTERY={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nSeizeCount( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nSeizeCount',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
	},
}

cc.load('treepack').resolveReference(ExchangeLotteryReq)

return ExchangeLotteryReq