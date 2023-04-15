
local TreePack=cc.load('treepack')
local MCSocketDataStruct=import('src.app.GameHall.models.mcsocket.MCSocketDataStruct')
local mcrc=MCSocketDataStruct.MCSocketDataStruct

local MCSocketDataStructExt = {
    CHECK_VERSION = mcrc.VERSION,

	PLAYER_ONLY={
		lengthMap = {
			[10] = 32,
			[11] = 16,
			[22] = {maxlen = 1},
			maxlen = 22
		},
		nameMap = {
			'nUserID',
			'nUserType',
			'nStatus',
			'nTableNO',
			'nChairNO',
			'nNickSex',
			'nPortrait',
			'nNetSpeed',
			'nClothingID',
			'szUsername',
			'szNickName',
			'nDeposit',
			'nPlayerLevel',
			'nScore',
			'nBreakOff',
			'nWin',
			'nLoss',
			'nStandOff',
			'nBout',
			'nTimeCost',
			'nGrowthLevel',
			'nReserved',
		},
		formatKey = '<iiiiiiiiiAAiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiA32A16iiiiiiiiiii',
		maxsize = 128
	},

	GET_ROOMUSERS={
		lengthMap=function (dataMap)
			local exchMap=clone(mcrc.GET_ROOMUSERS_BASE)
			local orgMaxLen=exchMap.lengthMap[5].maxlen
			exchMap.lengthMap[5].maxlen=dataMap.nRoomCount
			dataMap.nReserved={0,0,0}
			local formatKey=exchMap.formatKey
			local cutlen=formatKey:len()-orgMaxLen+dataMap.nRoomCount
			exchMap.formatKey=formatKey:sub(1,cutlen)
			local data=TreePack.alignpack(dataMap,exchMap)
			return data

		end,
		nameMap=mcrc.GET_ROOMUSERS_BASE.nameMap,
		nonblock = true,
	},

	INPUTLIMIT_DAILY={
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nTransferTotal',
			'nTransferLimit',
		},
		formatKey = '<ii',
		deformatKey = '<ii'
	},

	BOUT_NOTENOUGH={
		lengthMap = {
			maxlen = 1
		},
		nameMap = {
			'nMinBout',
		},
		formatKey = '<i',
		deformatKey = '<i'
	},

	TIMECOST_NOTENOUGH={
		lengthMap = {
			maxlen = 1
		},
		nameMap = {
			'nMinMinute',
		},
		formatKey = '<i',
		deformatKey = '<i'
	},

	FORBID_UNEXPIRATION={
		lengthMap = {
			maxlen = 1
		},
		nameMap = {
			'nForbidExpiration',
		},
		formatKey = '<i',
		deformatKey = '<i'
	},

	EXPERIENCE_NOTENOUGH={
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nPlayerExperience',
			'nMinRoomExperience',
		},
		formatKey = '<ii',
		deformatKey = '<ii'
	},

	SCORE_NOTENOUGH={
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nPlayerScore',
			'nMinRoomScore',
		},
		formatKey = '<ii',
		deformatKey = '<ii'
	},

	SCORE_NOTENOUGH={
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nPlayerScore',
			'nMaxRoomScore',
		},
		formatKey = '<ii',
		deformatKey = '<ii'
	},

	PLAYSCORE_OVERFLOW={
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nPlayerScore',
			'nMinRoomScore',
		},
		formatKey = '<ii',
		deformatKey = '<ii'
	},

	FORBID_PROXYIP={
		lengthMap = {
			maxlen = 1
		},
		nameMap = {
			'dwIP',
		},
		formatKey = '<i',
		deformatKey = '<i'
	},

	KEEPDEPOSIT_LIMIT={
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nGameDeposit',
			'nKeepDeposit',
		},
		formatKey = '<ii',
		deformatKey = '<ii'
	},
    MR_FOUND_GROUP_TEAMROOMS = mcrc.MR_FOUND_NEW_GROUP_TABLEROOMS,
    MR_NEW_TEAMROOM = mcrc.MR_NEW_PRIVATEROOM,
    MR_ASK_ENTER_TEAMROOM = mcrc.MR_ASK_ENTER_TEAMROOM,
}

for k,v in pairs(MCSocketDataStructExt) do
	mcrc[k]=v
end

return MCSocketDataStructExt
