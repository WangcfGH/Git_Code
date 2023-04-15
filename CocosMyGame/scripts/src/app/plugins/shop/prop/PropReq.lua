local AssistBaseReq = import("src.app.GameHall.models.assist.AssistBaseRequest")

local PropReq = {
    KPI_CLIENT_DATA = AssistBaseReq.KPI_CLIENT_DATA,

    GET_INFO_WITH_USERID = {
    	lengthMap = {
            [2] = {maxlen = 4},
			maxlen = 2
		},
		nameMap = {
			'nUserID',
            'nReserved'
		},
		formatKey = '<iiiii',
		deformatKey = '<iiiii',
		maxsize = 20    
    },

    --???????
    USER_PROP_INFO = {
    	lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRoomID( int )	: maxsize = 4,
			-- [3] = nTableNo( int )	: maxsize = 4,
			-- [4] = nChairNo( int )	: maxsize = 4,
													-- nPropID	: maxsize = 40	=	4 * 10 * 1,
			[5] = { maxlen = 10 },
													-- nPropNum	: maxsize = 40	=	4 * 10 * 1,
			[6] = { maxlen = 10 },
													-- nPropPrice	: maxsize = 40	=	4 * 10 * 1,
			[7] = { maxlen = 10 },
			-- [8] = nPropIDCurrent( int )	: maxsize = 4,
			maxlen = 8
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRoomID',		-- [2] ( int )
			'nTableNo',		-- [3] ( int )
			'nChairNo',		-- [4] ( int )
			'nPropID',		-- [5] ( int )
			'nPropNum',		-- [6] ( int )
			'nPropPrice',		-- [7] ( int )
			'nPropIDCurrent',		-- [8] ( int )
		},
		formatKey = '<i35',
		deformatKey = '<i35',
		maxsize = 140
    },
    PARAM_PROP_INFO = {
    	lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPropID( int )	: maxsize = 4,
			-- [3] = nPropNum( int )	: maxsize = 4,
			-- [4] = nOSType( int )	: maxsize = 4,
													-- kpiClientData	: 				maxsize = 568,
			[5] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
			-- [6] = nOpen( int )	: maxsize = 4,
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPropID',		-- [2] ( int )
			'nPropNum',		-- [3] ( int )
			'nOSType',		-- [4] ( int )
			'kpiClientData',		-- [5] ( refer )
			'nOpen',		-- [6] ( int )
		},
		formatKey = '<i6Ai4Ai5A6i33Ai32Li',
		deformatKey = '<i6A16i4A16i5A32A32A32A32A32A32i33A36i32Li',
		maxsize = 588
	},
    BUY_PROP_INFO_FAIL = {
    	lengthMap = {
            [1] = 64,
			maxlen = 1
		},
		nameMap = {
			'failMsg'
		},
		formatKey = '<A',
		deformatKey = '<A64',
		maxsize = 64
	},
	GAME_EXPRESSION_PROP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRoomID( int )	: maxsize = 4,
			-- [3] = nTableNO( int )	: maxsize = 4,
			-- [4] = nChairNO( int )	: maxsize = 4,
			-- [5] = nDestUserID( int )	: maxsize = 4,
			-- [6] = nDestChairNO( int )	: maxsize = 4,
			-- [7] = nPropID( int )	: maxsize = 4,
			-- [8] = nCurrentCount( int )	: maxsize = 4,
			-- [9] = nSilverType( int )	: maxsize = 4,
			-- [10] = nOpen( int )	: maxsize = 4,
			-- [11] = nOSType( int )	: maxsize = 4,
			maxlen = 11
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRoomID',		-- [2] ( int )
			'nTableNO',		-- [3] ( int )
			'nChairNO',		-- [4] ( int )
			'nDestUserID',		-- [5] ( int )
			'nDestChairNO',		-- [6] ( int )
			'nPropID',		-- [7] ( int )
			'nCurrentCount',		-- [8] ( int )
			'nSilverType',		-- [9] ( int )
			'nOpen',		-- [10] ( int )
			'nOSType',		-- [11] ( int )
		},
		formatKey = '<i11',
		deformatKey = '<i11',
		maxsize = 44
	},
}

cc.load('treepack').resolveReference(PropReq)

return PropReq