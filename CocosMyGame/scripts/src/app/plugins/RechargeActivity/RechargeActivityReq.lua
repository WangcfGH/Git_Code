local treepack = cc.load('treepack')

local RechargeActivityReq = 
{
    RECHARGE_INFO_REQ = {
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			maxlen = 1
		},
		nameMap = {
			"nUserID" -- [1] ( int )
		},
		formatKey = "<i",
		deformatKey = "<i",
		maxsize = 4
    },
    RECHARGE_LOTTERY_INFO_RESP={
		lengthMap = {
			-- [1] = open( int )	: maxsize = 4,
			-- [2] = nDraw( int )	: maxsize = 4,
			-- [3] = nTotalPay( int )	: maxsize = 4,
			-- [4] = AwardStatus( int )	: maxsize = 4,
			maxlen = 4
		},
		nameMap = {
			'open',		-- [1] ( int )
			'nDraw',		-- [2] ( int )
			'nTotalPay',		-- [3] ( int )
			'AwardStatus',		-- [4] ( int )
		},
		formatKey = '<i4',
		deformatKey = '<i4',
		maxsize = 16
	},
    RECHARGE_LOTTERY_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szUserName',		-- [2] ( char )
		},
		formatKey = '<iA',
		deformatKey = '<iA32',
		maxsize = 36
    },
    RECHARGE_LOTTERY_DRAW_RESP={
		lengthMap = {
			-- [1] = nResult( int )	: maxsize = 4,
			-- [2] = nIndex( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nResult',		-- [1] ( int )
			'nIndex',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
	},
}

cc.load('treepack').resolveReference(RechargeActivityReq)

return RechargeActivityReq