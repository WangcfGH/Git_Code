local PropReq = import('src.app.plugins.shop.prop.PropReq')

local ArenaReq = {
    DIFF_ARENA_INFO = {
        lengthMap = {
            [6] = 32,
            [10] = {maxlen = 4},
			maxlen = 10
		},
		nameMap = {
			'nUserID',
            'nLastRank',
            'nLastScore',
            'nCurRank',
            'nCurScore',
            'szUsername',
            'nSexSupportRule',
            'nRankSupportRule',
            'nScoreSupportRule',
            'nReserved'
		},
		formatKey = '<i5Ai7',
		deformatKey = '<i5A32i7',
		maxsize = 80,
    },

    GET_ARENA_RANK_MATCH_CONFIG = {
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

    --竞技场排行榜
    GET_INFO_WITH_USERID = PropReq.GET_INFO_WITH_USERID,

    REQ_MOVE_ARENA_USER_SCORE={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nSex( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[3] = 32,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[4] = { maxlen = 4 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nSex',		-- [2] ( int )
			'szUserName',		-- [3] ( char )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i2Ai4',
		deformatKey = '<i2A32i4',
		maxsize = 56
	},
	MOVE_ARENA_USER_SCORE_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nMoveOK( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nMoveOK',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
	},
    ARENA_RANK_INFO = {
		lengthMap = {
			maxlen = 8
		},
		nameMap = {
			'nUserID',
            'nOpen',
            'nBeginDate',
            'nEndDate',
            'nState',
            'nSortID',
            'nRankScore',
            'nRealCount'
		},
		formatKey = '<i8',
		deformatKey = '<i8',
		maxsize = 32
	},
    SINGLE_RANK_INFO = {
		lengthMap = {							
			[2] = 32,
            [6] = {maxlen = 4},
			maxlen = 6
		},
		nameMap = {
			'nUserID',
			'szUserName',
            'nSex',
			'nIndex',
			'nRankScore',
            'nReserved'
		},
		formatKey = '<iAi7',
		deformatKey = '<iA32i7',
		maxsize = 64
	},
    SIGN_UP_ARENA_RANK = {
    	lengthMap = {							
			[2] = 32,
            [5] = {maxlen = 4},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'szUserName',
            'nSex',
			'nDate',
			'nReserved',
		},
		formatKey = '<iAi6',
		deformatKey = '<iA32i6',
		maxsize = 60    
    },
    GET_ARENA_RANK_REWARD_LIST = {
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
    ARENA_RANK_REWARD_LIST = {
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nUserID',
            'nRealCount'
		},
		formatKey = '<ii',
		deformatKey = '<ii',
		maxsize = 8
	},
    ARENA_RANK_REWARD_LIST_ITEM = {
		lengthMap = {
			maxlen = 3
		},
		nameMap = {
			'nRankBegin',
            'nRankEnd',
            'nRealCount'
		},
		formatKey = '<iii',
		deformatKey = '<iii',
		maxsize = 12,
        realSize = 52  --实际大小,由于本版本的treepack不支持结构体套结构体数组，所以在这里加一个realSize来辅助
	},
    ARENA_RANK_REWARD_ITEM = {
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nPrizeID',
            'nNum'
		},
		formatKey = '<ii',
		deformatKey = '<ii',
		maxsize = 8
	},
    TAKE_ARENA_RANK_REWARD = {
    	lengthMap = {
            [2] = 32,
            [3] = {maxlen = 4},
			maxlen = 3
		},
		nameMap = {
			'nUserID',
            'szUserName',
            'nReserved'
		},
		formatKey = '<iAiiii',
		deformatKey = '<iA32iiii',
		maxsize = 52    
    },
    ARENA_RANK_REWARD = {
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
			-- [3] = nState( int )	: maxsize = 4,
			-- [4] = nRank( int )	: maxsize = 4,
			-- [5] = nScore( int )	: maxsize = 4,
			-- [6] = nRealCount( int )	: maxsize = 4,
													-- stReward	: maxsize = 40	=	8 * 5 * 1,
			[7] = { maxlen = 5, refered = 'ARENA_RANK_REWARD_ITEM', complexType = 'link_refer' },
			maxlen = 7
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szUserName',		-- [2] ( char )
			'nState',		-- [3] ( int )
			'nRank',		-- [4] ( int )
			'nScore',		-- [5] ( int )
			'nRealCount',		-- [6] ( int )
			'stReward',		-- [7] ( refer )
		},
		formatKey = '<iAi14',
		deformatKey = '<iA32i14',
		maxsize = 92
	},
}

cc.load('treepack').resolveReference(ArenaReq)

return ArenaReq