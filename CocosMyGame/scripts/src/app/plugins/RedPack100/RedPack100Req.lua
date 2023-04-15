local treepack = cc.load('treepack')

local RedPack00Req = 
{
	REDPACK_BREAK_DATA={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nEndDate( int )	: maxsize = 4,
			-- [3] = nGetMoney( int )	: maxsize = 4,
			-- [4] = nAccumulateMoney( int )	: maxsize = 4,
			-- [5] = nAvailableBout( int )	: maxsize = 4,
			-- [6] = nRespCode( int )	: maxsize = 4,
													-- nMoneyArry	: maxsize = 16	=	4 * 4 * 1,
			[7] = { maxlen = 4 },
													-- szUserNameArry	: maxsize = 128	=	1 * 32 * 4,
			[8] = { maxlen = 32, maxwidth = 4, complexType = 'string_group' },
			-- [9] = nBreakCondRet( int )	: maxsize = 4,
			maxlen = 9
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nEndDate',		-- [2] ( int )
			'nGetMoney',		-- [3] ( int )
			'nAccumulateMoney',		-- [4] ( int )
			'nAvailableBout',		-- [5] ( int )
			'nRespCode',		-- [6] ( int )
			'nMoneyArry',		-- [7] ( int )
			'szUserNameArry',		-- [8] ( char )
			'nBreakCondRet',		-- [9] ( int )
		},
		formatKey = '<i10A4i',
		deformatKey = '<i10A32A32A32A32i',
		maxsize = 172
	},

	REDPACK_BREAK_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nUserBout( int )	: maxsize = 4,
			-- [3] = nChannelID( int )	: maxsize = 4,
			-- [4] = nBreakCond( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[5] = 32,
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nUserBout',		-- [2] ( int )
			'nChannelID',		-- [3] ( int )
			'nBreakCond',		-- [4] ( int )
			'szUserName',		-- [5] ( char )
		},
		formatKey = '<i4A',
		deformatKey = '<i4A32',
		maxsize = 48
	},
	
		REDPACK_QUERY_DATA={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nStartDate( int )	: maxsize = 4,
			-- [3] = nEndDate( int )	: maxsize = 4,
			-- [4] = nAccumulateMoney( int )	: maxsize = 4,
			-- [5] = nPlayedBout( int )	: maxsize = 4,
			-- [6] = nAvailableBout( int )	: maxsize = 4,
			-- [7] = nDestBout( int )	: maxsize = 4,
			-- [8] = nBtnStartShowDay( int )	: maxsize = 4,
			-- [9] = nRewardDate( int )	: maxsize = 4,
													-- szCompleteUsers	: maxsize = 128	=	1 * 32 * 4,
			[10] = { maxlen = 32, maxwidth = 4, complexType = 'string_group' },
			-- [11] = nRespCode( int )	: maxsize = 4,
			-- [12] = nShowMode( int )	: maxsize = 4,
			-- [13] = nCurrentDay( int )	: maxsize = 4,
			-- [14] = nCurrentData( int )	: maxsize = 4,
			-- [15] = nDestData( int )	: maxsize = 4,
			maxlen = 15
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nStartDate',		-- [2] ( int )
			'nEndDate',		-- [3] ( int )
			'nAccumulateMoney',		-- [4] ( int )
			'nPlayedBout',		-- [5] ( int )
			'nAvailableBout',		-- [6] ( int )
			'nDestBout',		-- [7] ( int )
			'nBtnStartShowDay',		-- [8] ( int )
			'nRewardDate',		-- [9] ( int )
			'szCompleteUsers',		-- [10] ( char )
			'nRespCode',		-- [11] ( int )
			'nShowMode',		-- [12] ( int )
			'nCurrentDay',		-- [13] ( int )
			'nCurrentData',		-- [14] ( int )
			'nDestData',		-- [15] ( int )
		},
		formatKey = '<i9A4i5',
		deformatKey = '<i9A32A32A32A32i5',
		maxsize = 184
	},
	
	REDPACK_QUERY_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nUserBout( int )	: maxsize = 4,
			-- [3] = nChannelID( int )	: maxsize = 4,
			-- [4] = bDateExpired( int )	: maxsize = 4,
			-- [5] = bChannelClose( int )	: maxsize = 4,
													-- szDeviceID	: maxsize = 32	=	1 * 32 * 1,
			[6] = 32,
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nUserBout',		-- [2] ( int )
			'nChannelID',		-- [3] ( int )
			'bDateExpired',		-- [4] ( int )
			'bChannelClose',		-- [5] ( int )
			'szDeviceID',		-- [6] ( char )
		},
		formatKey = '<i5A',
		deformatKey = '<i5A32',
		maxsize = 52
	},
	
	REDPACK_REWARD_DATA={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRewardCount( int )	: maxsize = 4,
			-- [3] = nRespCode( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRewardCount',		-- [2] ( int )
			'nRespCode',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},
	
	REDPACK_REWARD_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nAccumulateMoney( int )	: maxsize = 4,
			-- [3] = nRewardNum( int )	: maxsize = 4,
			-- [4] = nChannelID( int )	: maxsize = 4,
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nAccumulateMoney',		-- [2] ( int )
			'nRewardNum',		-- [3] ( int )
			'nChannelID',		-- [4] ( int )
		},
		formatKey = '<i4',
		deformatKey = '<i4',
		maxsize = 16
	},
    	
	REDPACK_UPDATE_DATA={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nAvailableBout( int )	: maxsize = 4,
			-- [3] = nPlayedBout( int )	: maxsize = 4,
													-- szCompleteUsers	: maxsize = 128	=	1 * 32 * 4,
			[4] = { maxlen = 32, maxwidth = 4, complexType = 'string_group' },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nAvailableBout',		-- [2] ( int )
			'nPlayedBout',		-- [3] ( int )
			'szCompleteUsers',		-- [4] ( char )
		},
		formatKey = '<i3A4',
		deformatKey = '<i3A32A32A32A32',
		maxsize = 140
	},
	
	REDPACK_UPDATE_REQ={
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

    NTF_TABLE_PLAYER_ADD_BOUT={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPlayBout( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPlayBout',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
	},
}

cc.load('treepack').resolveReference(RedPack00Req)

return RedPack00Req