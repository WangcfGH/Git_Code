local AssistBaseReq = import("src.app.GameHall.models.assist.AssistBaseRequest")

local LimitTimeGiftReq = {
    Limit_Time_Gift_Req={
        lengthMap = {
            -- [1] = nUserID( int ) : maxsize = 4,
            -- [2] = nPlatform( int )   : maxsize = 4,
            maxlen = 2
        },
        nameMap = {
            'nUserID',      -- [1] ( int )
            'nPlatform',        -- [2] ( int )
        },
        formatKey = '<i2',
        deformatKey = '<i2',
        maxsize = 8
    },
    
    Limit_Time_Gift_Resp={
        lengthMap = {
            -- [1] = nUserID( int ) : maxsize = 4,
            -- [2] = nGiftID( int ) : maxsize = 4,
                                                    -- szTrigTime    : maxsize = 32  =   1 * 32 * 1,
            [3] = 32,
            -- [4] = nCountdown( int )  : maxsize = 4,
            maxlen = 4
        },
        nameMap = {
            'nUserID',      -- [1] ( int )
            'nGiftID',      -- [2] ( int )
            'szTrigTime',        -- [3] ( char )
            'nCountdown',       -- [4] ( int )
        },
        formatKey = '<i2Ai',
        deformatKey = '<i2A32i',
        maxsize = 44
    },
    
    Limit_Time_Gift_Trig_Req={
        lengthMap = {
            -- [1] = nUserID( int ) : maxsize = 4,
            -- [2] = nGiftID( int ) : maxsize = 4,
            maxlen = 2
        },
        nameMap = {
            'nUserID',      -- [1] ( int )
            'nGiftID',      -- [2] ( int )
        },
        formatKey = '<i2',
        deformatKey = '<i2',
        maxsize = 8
    },
    
    Limit_Time_Gift_Trig_Resp={
        lengthMap = {
            -- [1] = nUserID( int ) : maxsize = 4,
            -- [2] = nGiftID( int ) : maxsize = 4,
                                                    -- szTrigTime    : maxsize = 32  =   1 * 32 * 1,
            [3] = 32,
            -- [4] = nCountdown( int )  : maxsize = 4,
            maxlen = 4
        },
        nameMap = {
            'nUserID',      -- [1] ( int )
            'nGiftID',      -- [2] ( int )
            'szTrigTime',        -- [3] ( char )
            'nCountdown',       -- [4] ( int )
        },
        formatKey = '<i2Ai',
        deformatKey = '<i2A32i',
        maxsize = 44
    },

    TIMEDBAG_LOG_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nIsNewHand( int )	: maxsize = 4,
			-- [3] = nTimedBagType( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nIsNewHand',		-- [2] ( int )
			'nTimedBagType',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},
}

return LimitTimeGiftReq