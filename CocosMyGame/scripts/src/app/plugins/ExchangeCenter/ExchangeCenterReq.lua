
local ExchangeCenterReq = {
    EXCHANGE_CENTER_BROAD_CAST={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nCount( int )	: maxsize = 4,
			-- [3] = nType( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[4] = 32,
													-- szPrizName	: maxsize = 32	=	1 * 32 * 1,
			[5] = 32,
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nCount',		-- [2] ( int )
			'nType',		-- [3] ( int )
			'szUserName',		-- [4] ( char )
			'szPrizName',		-- [5] ( char )
		},
		formatKey = '<i3A2',
		deformatKey = '<i3A32A32',
		maxsize = 76

	},

	EXCHANGE_CARDMARKER_REQ={
		lengthMap = {
			-- [1] = nUserId( int )	: maxsize = 4,
			-- [2] = nPropId( int )	: maxsize = 4,
													-- szUserToken	: maxsize = 252	=	1 * 252 * 1,
			[3] = 252,
			maxlen = 3
		},
		nameMap = {
			'nUserId',		-- [1] ( int )
			'nPropId',		-- [2] ( int )
			'szUserToken',		-- [3] ( char )
		},
		formatKey = '<i2A',
		deformatKey = '<i2A252',
		maxsize = 260
	},

	EXCHANGE_CARDMARKER_RESP={
		lengthMap = {
			-- [1] = nResult( int )	: maxsize = 4,
			-- [2] = nUserId( int )	: maxsize = 4,
			-- [3] = nPropId( int )	: maxsize = 4,
													-- szMessage	: maxsize = 64	=	1 * 64 * 1,
			[4] = 64,
			maxlen = 4
		},
		nameMap = {
			'nResult',		-- [1] ( int )
			'nUserId',		-- [2] ( int )
			'nPropId',		-- [3] ( int )
			'szMessage',		-- [4] ( char )
		},
		formatKey = '<i3A',
		deformatKey = '<i3A64',
		maxsize = 76
	},
}

cc.load('treepack').resolveReference(ExchangeCenterReq)

return ExchangeCenterReq