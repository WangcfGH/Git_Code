--[宝箱相关]
local ActivityCenterStruct = {
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

    REQ_TASK_CONFIG={
        lengthMap = {			
			maxlen = 1
		},
		nameMap = {
			'nUserID',
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
    },

    RET_TASK_CURDATE={
        lengthMap = {			
			maxlen = 1
		},
		nameMap = {
			'nCurDate',
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
    },

    RET_TASK_REDDOT_CNT={
        lengthMap = {			
			maxlen = 1
		},
		nameMap = {
			'nCount',
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
    },

    RET_TASK_REDDOT={
		lengthMap = {
			--,
			maxlen = 3
		},
		nameMap = {
			'nUserID',
			'nTaskGID',
			'nRedDotCnt'
		},
		formatKey = '<iii',
		deformatKey = '<iii',
		maxsize = 12
	},

    REQ_TASK_DATA={
		lengthMap = {
			[3] = 128,
			maxlen = 3
		},
		nameMap = {
			'nUserID',
			'nTaskGId',
            'nVersion'
		},
		formatKey = '<iiA',
		deformatKey = '<iiA128',
		maxsize = 136
	},

    REQ_TASK_REDDOT={
		lengthMap = {
			[2] = 128,
			maxlen = 2
		},
		nameMap = {
			'nUserID',
            'nVersion'
		},
		formatKey = '<iA',
		deformatKey = '<iA128',
		maxsize = 132
	},

    RET_TASK_GROUP={
		lengthMap = {
			--,
			maxlen = 3
		},
		nameMap = {
			'nUserID',
			'nTaskGId',
            'nTaskCnt'
		},
		formatKey = '<iii',
		deformatKey = '<iii',
		maxsize = 12
	},

    RET_TASK_DATA={
		lengthMap = {
			--,
			maxlen = 3
		},
		nameMap = {
			'nTaskID',
			'nTaskData',
            'nRewardFlag'
		},
		formatKey = '<iii',
		deformatKey = '<iii',
		maxsize = 12
	},

    REQ_TASK_REWARD={
		lengthMap = {
			--,
			maxlen = 3
		},
		nameMap = {
			'nUserID',
			'nTaskGId',
            'nTaskId'
		},
		formatKey = '<iii',
		deformatKey = '<iii',
		maxsize = 12
	},

    RET_TASK_REWARD={
		lengthMap = {
			--,
			maxlen = 4
		},
		nameMap = {
			'nUserID',
			'nTaskGId',
            'nTaskId',
            'nRewardFlag'
		},
		formatKey = '<iiii',
		deformatKey = '<iiii',
		maxsize = 16
	},
}

cc.load('treepack').resolveReference(ActivityCenterStruct)

return ActivityCenterStruct
