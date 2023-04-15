local AssistBaseReq = import("src.app.GameHall.models.assist.AssistBaseRequest")

local TaskReq = {
    KPI_CLIENT_DATA = AssistBaseReq.KPI_CLIENT_DATA,

    TASK_DATA_REQ={
        lengthMap = {
            --,
            maxlen = 3
        },
        nameMap = {
            'nUserID',
            'nReqType',
            'nGroupID'
        },
        formatKey = '<iii',
        deformatKey = '<iii',
        maxsize = 12
    },

    TASK_DATA_RESP={
        lengthMap = {
            --,
            maxlen = 63
        },
        nameMap = {
            'nUserID',
            'nRequestType',
            'nTaskNum',
            'nGroupID1',
            'nID1',
            'nFlag1',
            'nGroupID2',
            'nID2',
            'nFlag2',
            'nGroupID3',
            'nID3',
            'nFlag3',
            'nGroupID4',
            'nID4',
            'nFlag4',
            'nGroupID5',
            'nID5',
            'nFlag5',
            'nGroupID6',
            'nID6',
            'nFlag6',
            'nGroupID7',
            'nID7',
            'nFlag7',
            'nGroupID8',
            'nID8',
            'nFlag8',
            'nGroupID9',
            'nID9',
            'nFlag9',
            'nGroupID10',
            'nID10',
            'nFlag10',
            'nGroupID11',
            'nID11',
            'nFlag11',
            'nGroupID12',
            'nID12',
            'nFlag12',
            'nGroupID13',
            'nID13',
            'nFlag13',
            'nGroupID14',
            'nID14',
            'nFlag14',
            'nGroupID15',
            'nID15',
            'nFlag15',
            'nGroupID16',
            'nID16',
            'nFlag16',
            'nGroupID17',
            'nID17',
            'nFlag17',
            'nGroupID18',
            'nID18',
            'nFlag18',
            'nGroupID19',
            'nID19',
            'nFlag19',
            'nGroupID20',
            'nID20',
            'nFlag20'
        },
        formatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 252
    },

    TASK_FINISH_REQ={
        lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGroupID( int )	: maxsize = 4,
			-- [3] = nTaskID( int )	: maxsize = 4,
													-- kpiClientData	: 				maxsize = 568,
			[4] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGroupID',		-- [2] ( int )
			'nTaskID',		-- [3] ( int )
			'kpiClientData',		-- [4] ( refer )
		},
		formatKey = '<i5Ai4Ai5A6i33Ai32L',
		deformatKey = '<i5A16i4A16i5A32A32A32A32A32A32i33A36i32L',
		maxsize = 580
	},
    Task_Reward={
		lengthMap = {
			-- [1] = nType( int )	: maxsize = 4,
			-- [2] = nMinValue( int )	: maxsize = 4,
			-- [3] = nMaxValue( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nType',		-- [1] ( int )
			'nMinValue',		-- [2] ( int )
			'nMaxValue',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},
    TASK_FINISH_RESP={
        lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nResult( int )	: maxsize = 4,
			-- [3] = nGroupID( int )	: maxsize = 4,
			-- [4] = nTaskID( int )	: maxsize = 4,
			-- [5] = nFlag( int )	: maxsize = 4,
			-- [6] = nNextTaskID( int )	: maxsize = 4,
													-- szWebID	: maxsize = 32	=	1 * 32 * 1,
			[7] = 32,
			-- [8] = nRewardNum( int )	: maxsize = 4,
													-- Reward	: maxsize = 120	=	12 * 10 * 1,
			[9] = { maxlen = 10, refered = 'Task_Reward', complexType = 'link_refer' },
													-- kpiClientData	: 				maxsize = 568,
			[10] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
			maxlen = 10
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nResult',		-- [2] ( int )
			'nGroupID',		-- [3] ( int )
			'nTaskID',		-- [4] ( int )
			'nFlag',		-- [5] ( int )
			'nNextTaskID',		-- [6] ( int )
			'szWebID',		-- [7] ( char )
			'nRewardNum',		-- [8] ( int )
			'Reward',		-- [9] ( refer )
			'kpiClientData',		-- [10] ( refer )
		},
		formatKey = '<i6Ai33Ai4Ai5A6i33Ai32L',
		deformatKey = '<i6A32i33A16i4A16i5A32A32A32A32A32A32i33A36i32L',
		maxsize = 748
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

    TASK_PARAM_RESP={
        lengthMap = {
            [1] = {maxlen = 28},
            maxlen = 1
        },
        nameMap = {
            'nParam'
        },
        formatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 112
    },

    TASK_DATA={
        lengthMap = {
            --,
            maxlen = 3
        },
        nameMap = {
            'nGroupID',
            'nID',
            'nFlag'
        },
        formatKey = '<iii',
        deformatKey = '<iii',
        maxsize = 12
    },

    TASK_PARAM={
        lengthMap = {
            --,
            maxlen = 4
        },
        nameMap = {
            'nUserID',
            'nAddParamType',
            'nAddParamValue',
            'nNowValue'
        },
        formatKey = '<iiii',
        deformatKey = '<iiii',
        maxsize = 16
    },

    TcyGameTask = {
        lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGetReward( int )	: maxsize = 4,
			-- [3] = nTaskFlag( int )	: maxsize = 4,
													-- kpiClientData	: 				maxsize = 568,
			[4] = { refered = 'KPI_CLIENT_DATA', complexType = 'link_refer' },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGetReward',		-- [2] ( int )
			'nTaskFlag',		-- [3] ( int )
			'kpiClientData',		-- [4] ( refer )
		},
		formatKey = '<i5Ai4Ai5A6i33Ai32L',
		deformatKey = '<i5A16i4A16i5A32A32A32A32A32A32i33A36i32L',
		maxsize = 580
    },
}

cc.load('treepack').resolveReference(TaskReq)

return TaskReq