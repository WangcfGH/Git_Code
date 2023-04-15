local AssistBaseReq = import("src.app.GameHall.models.assist.AssistBaseRequest")

local CardRecorderReq = {
    SCORE_INFO_FOR_PLAYER_REQ={
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

    QUERY_CARDMARKERINFO_RESP={
		lengthMap = {
			-- [1] = nUserId( int )	: maxsize = 4,
			-- [2] = nLastSeconds( int )	: maxsize = 4,
			-- [3] = nCardMakerNum( int )	: maxsize = 4,
			-- [4] = nLightingNum( int )	: maxsize = 4,
			-- [5] = nLightingNum10( int )	: maxsize = 4,
			-- [6] = nRoseNum( int )	: maxsize = 4,
			maxlen = 6
		},
		nameMap = {
			'nUserId',		-- [1] ( int )
			'nLastSeconds',		-- [2] ( int )
			'nCardMakerNum',		-- [3] ( int )
			'nLightingNum',		-- [4] ( int )
			'nLightingNum10',		-- [5] ( int )
			'nRoseNum',		-- [6] ( int )
		},
		formatKey = '<i6',
		deformatKey = '<i6',
		maxsize = 24
	},
}

return CardRecorderReq