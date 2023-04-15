local treepack = cc.load('treepack')

local PhoneFeeGiftReq = 
{
	PHONE_FEE_GIFT_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPlayBout( int )	: maxsize = 4,
													-- szDeviceID	: maxsize = 100	=	1 * 100 * 1,
			[3] = 100,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPlayBout',		-- [2] ( int )
			'szDeviceID',		-- [3] ( char )
		},
		formatKey = '<i2A',
		deformatKey = '<i2A100',
		maxsize = 108
	},

	PHONE_FEE_GIFT_RSP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nActStatus( int )	: maxsize = 4,
			-- [3] = nSignDate( int )	: maxsize = 4,
			-- [4] = nEndDate( int )	: maxsize = 4,
			-- [5] = nPlayBout( int )	: maxsize = 4,
			-- [6] = nDstBout( int )	: maxsize = 4,
			-- [7] = nRewardNum( int )	: maxsize = 4,
			-- [8] = isComplete( int )	: maxsize = 4,
			-- [9] = isTakeReward( int )	: maxsize = 4,
			maxlen = 9
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nActStatus',		-- [2] ( int )
			'nSignDate',		-- [3] ( int )
			'nEndDate',		-- [4] ( int )
			'nPlayBout',		-- [5] ( int )
			'nDstBout',		-- [6] ( int )
			'nRewardNum',		-- [7] ( int )
			'isComplete',		-- [8] ( int )
			'isTakeReward',		-- [9] ( int )
		},
		formatKey = '<i9',
		deformatKey = '<i9',
		maxsize = 36
	},

	PHONE_FEE_GIFT_REWARD_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPlayBout( int )	: maxsize = 4,
													-- szUserName	: maxsize = 100	=	1 * 100 * 1,
			[3] = 100,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPlayBout',		-- [2] ( int )
			'szUserName',		-- [3] ( char )
		},
		formatKey = '<i2A',
		deformatKey = '<i2A100',
		maxsize = 108
	},
	
	PHONE_FEE_GIFT_REWARD_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRewardNum( int )	: maxsize = 4,
			-- [3] = nStatusCode( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRewardNum',		-- [2] ( int )
			'nStatusCode',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},
    PHONE_FEE_GIFT_ADD_BOUT={
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
	PHONE_FEE_GIFT_TO_ASSIST={
		lengthMap = {
													-- info	: maxsize = 32	=	8 * 4 * 1,
			[1] = { maxlen = 4, refered = 'PHONE_FEE_GIFT_ADD_BOUT', complexType = 'link_refer' },
			maxlen = 1
		},
		nameMap = {
			'info',		-- [1] ( refer )
		},
		formatKey = '<i8',
		deformatKey = '<i8',
		maxsize = 32
	},
}

cc.load('treepack').resolveReference(PhoneFeeGiftReq)

return PhoneFeeGiftReq