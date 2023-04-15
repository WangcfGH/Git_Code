local WeakenScoreRoomReq = {
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
	
	SCORE_INFO_FOR_PLAYER_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nScore( int )	: maxsize = 4,
			-- [3] = nReward( int )	: maxsize = 4,
			-- [4] = nDate( int )	: maxsize = 4,
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nScore',		-- [2] ( int )
			'nReward',		-- [3] ( int )
			'nDate',		-- [4] ( int )
		},
		formatKey = '<i4',
		deformatKey = '<i4',
		maxsize = 16

    },
    TRIGGER_INFO_FOR_SCORE_ROOM_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nTrigger( int )	: maxsize = 4,
			-- [3] = nDate( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nTrigger',		-- [2] ( int )
			'nDate',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
    },
    BOUT_INFO_FOR_TODAY_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nBout( int )	: maxsize = 4,
			-- [3] = nDate( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nBout',		-- [2] ( int )
			'nDate',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
    },
}

return WeakenScoreRoomReq