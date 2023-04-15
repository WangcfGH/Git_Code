local AssistBaseReq = import("src.app.GameHall.models.assist.AssistBaseRequest")

local AssistCommonReq = {
    KPI_CLIENT_DATA = AssistBaseReq.KPI_CLIENT_DATA,

    NOTICY_ASSITSVR_USERID={
        lengthMap = {
			maxlen = 1
		},
		nameMap = {
            'nUserID'
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
    },

    JSON_REQUEST_INFO={
		lengthMap = {
			-- [1] = nUserId( int )	: maxsize = 4,
			-- [2] = nGameId( int )	: maxsize = 4,
													-- szExeName	: maxsize = 8	=	1 * 8 * 1,
			[3] = 8,
			-- [4] = channelId( int )	: maxsize = 4,
			-- [5] = vMajor( int )	: maxsize = 4,
			-- [6] = vMinor( int )	: maxsize = 4,
			-- [7] = vBuildNo( int )	: maxsize = 4,
			-- [8] = nRequestId( int )	: maxsize = 4,
			-- [9] = nJsonLen( int )	: maxsize = 4,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[10] = { maxlen = 4 },
			maxlen = 10
		},
		nameMap = {
			'nUserId',		-- [1] ( int )
			'nGameId',		-- [2] ( int )
			'szExeName',		-- [3] ( char )
			'channelId',		-- [4] ( int )
			'vMajor',		-- [5] ( int )
			'vMinor',		-- [6] ( int )
			'vBuildNo',		-- [7] ( int )
			'nRequestId',		-- [8] ( int )
			'nJsonLen',		-- [9] ( int )
			'nReserved',		-- [10] ( int )
		},
		formatKey = '<i2Ai10',
		deformatKey = '<i2A8i10',
		maxsize = 56
	},
	
	NOTICY_USERIDEX={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nChannelID( int )	: maxsize = 4,
			-- [3] = bNewPlayerCond1( int )	: maxsize = 4,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[4] = { maxlen = 4 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nChannelID',		-- [2] ( int )
			'bNewPlayerCond1',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i7',
		deformatKey = '<i7',
		maxsize = 28
	},
	
	JSON_RESPONSE_INFO={
		lengthMap = {
			-- [1] = nUserId( int )	: maxsize = 4,
			-- [2] = nGameId( int )	: maxsize = 4,
													-- szExeName	: maxsize = 8	=	1 * 8 * 1,
			[3] = 8,
			-- [4] = channelId( int )	: maxsize = 4,
			-- [5] = vMajor( int )	: maxsize = 4,
			-- [6] = vMinor( int )	: maxsize = 4,
			-- [7] = vBuildNo( int )	: maxsize = 4,
			-- [8] = nResponseId( int )	: maxsize = 4,
			-- [9] = nJsonLen( int )	: maxsize = 4,
			-- [10] = nAdditionDataLen( int )	: maxsize = 4,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[11] = { maxlen = 4 },
			maxlen = 11
		},
		nameMap = {
			'nUserId',		-- [1] ( int )
			'nGameId',		-- [2] ( int )
			'szExeName',		-- [3] ( char )
			'channelId',		-- [4] ( int )
			'vMajor',		-- [5] ( int )
			'vMinor',		-- [6] ( int )
			'vBuildNo',		-- [7] ( int )
			'nResponseId',		-- [8] ( int )
			'nJsonLen',		-- [9] ( int )
			'nAdditionDataLen',		-- [10] ( int )
			'nReserved',		-- [11] ( int )
		},
		formatKey = '<i2Ai11',
		deformatKey = '<i2A8i11',
		maxsize = 60
	},

    GET_JSON_HEAD_INFO={
        lengthMap = {			
			[4] = {maxlen = 4},
			maxlen = 4
		},
		nameMap = {
			'nUserID',		
            'nIsSupport',
            'nJsonLen',
			'nReserved',	
		},
		formatKey = '<i7',
		deformatKey = '<i7',
		maxsize = 28
    },

    JSON_BODY_TEMPLATE = {
		lengthMap = {	
            [1] = 0,    --需要改写		
			maxlen = 1
		},
		nameMap = {
			'szJson',
		},
		formatKey = '<A%d', --需要改写
		deformatKey = '<A%d',   --需要改写
		maxsize = 0 --需要改写
	},

    RECHARGE_LOG_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRechageType( int )	: maxsize = 4,
			-- [3] = nRechargePlace( int )	: maxsize = 4,
			-- [4] = nMoney( int )	: maxsize = 4,
			-- [5] = nSilverWhenRecharge( int )	: maxsize = 4,
			-- [6] = nSilverInSafeBox( int )	: maxsize = 4,
			-- [7] = nIsNewHand( int )	: maxsize = 4,
			-- [8] = nTimedBagType( int )	: maxsize = 4,
			maxlen = 8
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRechageType',		-- [2] ( int )
			'nRechargePlace',		-- [3] ( int )
			'nMoney',		-- [4] ( int )
			'nSilverWhenRecharge',		-- [5] ( int )
			'nSilverInSafeBox',		-- [6] ( int )
			'nIsNewHand',		-- [7] ( int )
			'nTimedBagType',		-- [8] ( int )
		},
		formatKey = '<i8',
		deformatKey = '<i8',
		maxsize = 32
	},

    SORTCARD_LOG_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRoomID( int )	: maxsize = 4,
			-- [3] = nVertical( int )	: maxsize = 4,
			-- [4] = nCross( int )	: maxsize = 4,
			-- [5] = nOrderSort( int )	: maxsize = 4,
			-- [6] = nColorSort( int )	: maxsize = 4,
			-- [7] = nBoomSort( int )	: maxsize = 4,
			-- [8] = nNumSort( int )	: maxsize = 4,
			-- [9] = nClickFlush( int )	: maxsize = 4,
			maxlen = 9
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRoomID',		-- [2] ( int )
			'nVertical',		-- [3] ( int )
			'nCross',		-- [4] ( int )
			'nOrderSort',		-- [5] ( int )
			'nColorSort',		-- [6] ( int )
			'nBoomSort',		-- [7] ( int )
			'nNumSort',		-- [8] ( int )
			'nClickFlush',		-- [9] ( int )
		},
		formatKey = '<i9',
		deformatKey = '<i9',
		maxsize = 36
	},

	RELIEF_LOG={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nTodayBouts( int )	: maxsize = 4,
			-- [3] = nTakeCount( int )	: maxsize = 4,
			-- [4] = nExchangeNum( int )	: maxsize = 4,
			-- [5] = nDeposit( int )	: maxsize = 4,
			-- [6] = nSafeboxDeposit( int )	: maxsize = 4,
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nTodayBouts',		-- [2] ( int )
			'nTakeCount',		-- [3] ( int )
			'nExchangeNum',		-- [4] ( int )
			'nDeposit',		-- [5] ( int )
			'nSafeboxDeposit',		-- [6] ( int )
		},
		formatKey = '<i6',
		deformatKey = '<i6',
		maxsize = 24
	},

	GAME_LOADING_LOG={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nLoadingTime( int )	: maxsize = 4,
			-- [3] = nIsEnterSuccess( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nLoadingTime',		-- [2] ( int )
			'nIsEnterSuccess',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},

    GET_JSON_CONFIG_REQ={
        lengthMap = {
                                                    -- cFileName : maxsize = 100 =   1 * 100 * 1,
            [1] = 100,
            maxlen = 1
        },
        nameMap = {
            'cFileName',     -- [1] ( char )
        },
        formatKey = '<A',
        deformatKey = '<A100',
        maxsize = 100
    },

    DOLE_EXCHANGE_VOUCHER={
        lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nType( int )	: maxsize = 4,
			-- [3] = nDayCount( int )	: maxsize = 4,
			-- [4] = nMember( int )	: maxsize = 4,
													-- kpiClientData	: 				maxsize = 568,
			[5] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nType',		-- [2] ( int )
			'nDayCount',		-- [3] ( int )
			'nMember',		-- [4] ( int )
			'kpiClientData',		-- [5] ( refer )
		},
		formatKey = '<i6Ai4Ai5A6i33Ai32L',
		deformatKey = '<i6A16i4A16i5A32A32A32A32A32A32i33A36i32L',
		maxsize = 584
	},

    -- 水浒传渠道开关
    SHZChannelConfig={
        lengthMap = {
                                                    -- sChannelSdkName  : maxsize = 32  =   1 * 32 * 1,
            [1] = 32,
            maxlen = 1
        },
        nameMap = {
            'sChannelSdkName',      -- [1] ( char )
        },
        formatKey = '<A',
        deformatKey = '<A32',
        maxsize = 32
    },

    SHZChannelConfigResp = {
        lengthMap = {
            maxlen = 1,
        },
        nameMap = {
            "openSHZ",
        },
		formatKey = '<i',
        deformatKey = '<i',
        maxsize = 4
    },

    ExchangeShopConfigResp = {
        lengthMap = {
            [3] = {maxlen = 5},
            [4] = {maxlen = 5},
            maxlen = 5,
        },
        nameMap = {
            "openSHZ",
            "checkinDayNum",
            "checkinExchange",
            "checkinMemberExchange",
            "newPlayerExchange",
        },
		formatKey = '<iiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiii',
        maxsize = 52
    },

    TASK_PARAM_REQ={
        lengthMap = {
            --,
            maxlen = 1
        },
        nameMap = {
            'nUserID'
        },
        formatKey = '<i',
        deformatKey = '<i',
        maxsize = 4
    },

    NOTIFY_CONFIG_MODIFIED_ITEM={
		lengthMap = {
													-- fileName	: maxsize = 64	=	1 * 64 * 1,
			[1] = 64,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[2] = { maxlen = 4 },
			maxlen = 2
		},
		nameMap = {
			'fileName',		-- [1] ( char )
			'nReserved',		-- [2] ( int )
		},
		formatKey = '<Ai4',
		deformatKey = '<A64i4',
		maxsize = 80
	},

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

    NO_SHUFFLE_REQ={
        lengthMap = {
            -- [1] = nOpenTag( int ) : maxsize = 4,
            -- [2] = nStartTime( int )   : maxsize = 4,
            -- [3] = nEndTime( int ) : maxsize = 4,
            maxlen = 3
        },
        nameMap = {
            'nOpenTag',      -- [1] ( int )
            'nStartTime',        -- [2] ( int ) 
            'nEndTime',      -- [3] ( int )
        },
        formatKey = '<i3',
        deformatKey = '<i3',
        maxsize = 12
    },

    QUICK_BUY_CONFIG={
        lengthMap = {
            [1] = {maxlen = 10},
            [2] = {maxlen = 10},
            maxlen = 2
        },
        nameMap = {
            'nDeposit',
            'nMoney'
        },
        formatKey = '<iiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiiiiiii',
        maxsize = 80
    },
}

cc.load('treepack').resolveReference(AssistCommonReq)

return AssistCommonReq