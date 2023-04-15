local RequestIdList=import('src.app.GameHall.models.mcsocket.RequestIdList')

local MCSocketDataStruct = {
	AREA={
		lengthMap = {
			[12] = 32,
			[13] = {maxlen = 8},
			maxlen = 13
		},
		nameMap = {
			'nAreaID',
			'nAreaType',
			'nSubType',
			'nStatus',
			'nLayOrder',
			'dwOptions',
			'nFontColor',
			'nIconID',
			'nGifID',
			'nGameID',
			'nServerID',
			'szAreaName',
			'nReserved'
		},
		formatKey = '<iiiiiLiiiiiAiiiiiiii',
		deformatKey = '<iiiiiLiiiiiA32iiiiiiii',
		maxsize = 108
	},

	AREAS={
		lengthMap = {
			[3] = {maxlen = 2},
			maxlen = 3
		},
		nameMap = {
			'nCount',
			'nLinkCount',
			'nReserved'
		},
		formatKey = '<iiii',
		deformatKey = '<iiii',
		maxsize = 16
	},

	ASK_ENTERGAME={
		lengthMap = {
			[9] = {maxlen = 8},
			maxlen = 9
		},
		nameMap = {
			'nUserID',
			'nRoomID',
			'nGameID',
			'nTableNO',
			'nChairNO',
			'nNetDelay',
			'nMinScore',
			'nMinDeposit',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiiiiiiii',
		maxsize = 64
	},

	BACK_DEPOSIT={
		lengthMap = {
			[3] = {maxlen = 4},
			maxlen = 3
		},
		nameMap = {
			'nUserID',
			'nBackDeposit',
			'nReserved'
		},
		formatKey = '<iiiiii',
		deformatKey = '<iiiiii',
		maxsize = 24
	},

	CHECK_VERSION_OK={
		lengthMap = {
			[5] = 64,
			[6] = 64,
			[8] = {maxlen = 4},
			maxlen = 8
		},
		nameMap = {
			'nMajorVer',
			'nMinorVer',
			'nBuildNO',
			'nCheckReturn',
			'szDLFile',
			'szUpdateWWW',
			'dwClientIP',
			'nReserved'
		},
		formatKey = '<iiiiAALiiii',
		deformatKey = '<iiiiA64A64Liiii',
		maxsize = 164
	},

	CLOAKING_DETAIL={
		lengthMap = {
			[3] = 256,
			[4] = 256,
			[5] = 256,
			[10] = {maxlen = 7},
			maxlen = 10
		},
		nameMap = {
			'nRoomID',
			'nGameID',
			'szLeftURL',
			'szRightURL',
			'szReservedURL',
			'nRightWidth',
			'nRightHeight',
			'nPlayerCount',
			'nCurrentSeconds',
			'nReserved'
		},
		formatKey = '<iiAAAiiiiiiiiiii',
		deformatKey = '<iiA256A256A256iiiiiiiiiii',
		maxsize = 820
	},

	DXXW_ROOM={
		lengthMap = {
			[5] = 32,
			[6] = {maxlen = 4},
			maxlen = 6
		},
		nameMap = {
			'nAgentGroupID',
			'nRoomID',
			'nGameID',
			'nAreaID',
			'szRoomName',
			'nReserved'
		},
		formatKey = '<iiiiAiiii',
		deformatKey = '<iiiiA32iiii',
		maxsize = 64
	},

	MR_ENTER_ROOM={
		lengthMap = {
			[12] = 32,
			[13] = 32,
			[14] = 32,
			[15] = 32,
			[16] = 16,
			[31] = {maxlen = 3},
			maxlen = 31
		},
		nameMap = {
			'nUserID',
			'nAreaID',
			'nGameID',
			'nGameVID',
			'nRoomID',
			'nRoomSvrID',
			'nExeMajorVer',
			'nExeMinorVer',
			'nEnterTime',
			'dwIPAddr',
			'dwEnterFlags',
			'szHardID',
			'szVolumeID',
			'szMachineID',
			'szUniqueID',
			'szPhysAddr',
			'dwScreenXY',
			'dwClientPort',
			'dwServerPort',
			'dwClientSockIP',
			'dwRemoteSockIP',
			'dwClientLANIP',
			'dwClientMask',
			'dwClientGateway',
			'dwClientDNS',
			'dwPixelsXY',
			'dwClientFlags',
			'nHostID',
			'nQuanID',
			'nExeBuildno',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiLLAAAAALLLLLLLLLLLiiiiii',
		deformatKey = '<iiiiiiiiiLLA32A32A32A32A16LLLLLLLLLLLiiiiii',
		maxsize = 256
	},

	MR_ENTER_ROOM_OK_ONLY={
		lengthMap = {
			[9] = {maxlen = 2},
			maxlen = 9
		},
		nameMap = {
			'nPlayerCount',
			'nTableCount',
			'nActiveTableCount',
			'nRoomTokenID',
			'dwEnterOKFlag',
			'nRoomPulseInterval',
			'dwClientIP',
			'nGiftDeposit',
			'nReserved'
		},
		formatKey = '<iiiiLiLiii',
		deformatKey = '<iiiiLiLiii',
		maxsize = 40
	},

	EXCHANGE_WEALTH={
		lengthMap = {
			[2] = 32,
			[7] = {maxlen = 8},
			maxlen = 7
		},
		nameMap = {
			'nUserID',
			'szHardID',
			'dwIPAddr',
			'dExchangeWealth',
			'dwSoapFlags',
			'nSoapReturn',
			'nReserved'
		},
		formatKey = '<iALdLiiiiiiiii',
		deformatKey = '<iA32LdLiiiiiiiii',
		maxsize = 88
	},

	EXCHANGE_WEALTH_OK={
		lengthMap = {
			[5] = {maxlen = 8},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'unused',
			'dExchangeWealth',
			'nExchangeDeposit',
			'nReserved'
		},
		formatKey = '<iidiiiiiiiii',
		deformatKey = '<iidiiiiiiiii',
		maxsize = 56
	},

	GAME_LEVEL={
		lengthMap = {
			[2] = 360,
			[3] = {maxlen = 4},
			maxlen = 3
		},
		nameMap = {
			'nGameID',
			'szLevelInfo',
			'nReserved'
		},
		formatKey = '<iAiiii',
		deformatKey = '<iA360iiii',
		maxsize = 380
	},

	GET_AREAS={
		unlockable=true,
		lengthMap = {
			[8] = {maxlen = 2},
			maxlen = 8
		},
		nameMap = {
			'nGameID',
			'nAreaType',
			'nSubType',
			'nAgentGroupID',
			'dwGetFlags',
			'dwVersion',
            'nUserID',
			'nReserved'
		},
		formatKey = '<iiiiLLiii',
		deformatKey = '<iiiiLLiii',
		maxsize = 36
	},

	MR_GET_FINISHED={
		lengthMap = {
			[7] = 32,
			[9] = {maxlen = 3},
			maxlen = 9
		},
		nameMap = {
			'nUserID',
			'nRoomID',
			'nAreaID',
			'nGameID',
			'nTableNO',
			'nChairNO',
			'szHardID',
			'dwGetFlag',
			'nReserved'
		},
		formatKey = '<iiiiiiALiii',
		deformatKey = '<iiiiiiA32Liii',
		maxsize = 72
	},

	MR_GET_FINISHED_OK={
		lengthMap = {
			[5] = {maxlen = 8},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'nTableNO',
			'nChairNO',
			'nPlayerCount',
			'nPlayerAry'
		},
		formatKey = '<iiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiiii',
		maxsize = 48
	},

	GET_GAMELEVEL={
		lengthMap = {
			[2] = {maxlen = 4},
			maxlen = 2
		},
		nameMap = {
			'nGameID',
			'nReserved'
		},
		formatKey = '<iiiii',
		deformatKey = '<iiiii',
		maxsize = 20
	},

	MR_GET_GAMEVERISON={
		lengthMap = {
			[5] = {maxlen = 16},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nRoomID',
			'dwGetFlags',
			'nReserved'
		},
		formatKey = '<iiiLiiiiiiiiiiiiiiii',
		deformatKey = '<iiiLiiiiiiiiiiiiiiii',
		maxsize = 80
	},

	MR_GET_GAMEVERISON_OK={
		lengthMap = {
			[5] = {maxlen = 8},
			maxlen = 5
		},
		nameMap = {
			'nGameID',
			'nMajorVer',
			'nMinorVer',
			'nBuildNO',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiiii',
		maxsize = 48
	},

	MR_GET_NEWTABLE={
		lengthMap = {
			[15] = {maxlen = 4},
			maxlen = 15
		},
		nameMap = {
			'nUserID',
			'nRoomID',
			'nAreaID',
			'nGameID',
			'nTableNO',
			'nChairNO',
			'nIPConfig',
			'nBreakReq',
			'nSpeedReq',
			'nMinScore',
			'nMinDeposit',
			'nWaitSeconds',
			'nNetDelay',
			'dwGetFlags',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiiiiLiiii',
		deformatKey = '<iiiiiiiiiiiiiLiiii',
		maxsize = 72
	},

    MR_NEW_PRIVATEROOM={
		lengthMap = {
			[15] = {maxlen = 4},
			maxlen = 15
		},
		nameMap = {
			'nUserID',
			'nRoomID',
			'nAreaID',
			'nGameID',
			'nTableNO',
			'nChairNO',
			'nIPConfig',
			'nBreakReq',
			'nSpeedReq',
			'nMinScore',
			'nMinDeposit',
			'nWaitSeconds',
			'nNetDelay',
			'dwGetFlags',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiiiiLiiii',
		deformatKey = '<iiiiiiiiiiiiiLiiii',
		maxsize = 72
	}, 

    MR_STAND_UP_SEAT={
		lengthMap = {
			[7] = 32,
			[12] = { maxlen = 2 },
			maxlen = 12
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRoomID',		-- [2] ( int )
			'nAreaID',		-- [3] ( int )
			'nGameID',		-- [4] ( int )
			'nTableNO',		-- [5] ( int )
			'nChairNO',		-- [6] ( int )
			'szHardID',		-- [7] ( char )
			'nWaitSeconds',		-- [8] ( int )
			'nNetDelay',		-- [9] ( int )
			'nDeposit',		-- [10] ( int )
			'nQuanID',		-- [11] ( int )
			'nReserved',		-- [12] ( int )
		},
		formatKey = '<i6Ai6',
		deformatKey = '<i6A32i6',
		maxsize = 80
	},

--    MR_STAND_UP_SEAT={
--		lengthMap = {
--			[8] = {maxlen = 32},
--			maxlen = 8
--		},
--		nameMap = {
--			'nUserID',
--			'nTableNO',
--			'nChairNO',
--			'nNetDelay',
--			'nMinScore',
--			'nMinDeposit',
--			'nFirstSeatedPlayer',
--			'szPassword'
--		},
--		formatKey = '<iiiiiiiA',
--		deformatKey = '<iiiiiiiA32',
--		maxsize = 60
--	},

	GET_RNDKEY={
		lengthMap = {
			[3] = 32,
			[4] = 32,
			[7] = {maxlen = 5},
			maxlen = 7
		},
		nameMap = {
			'nRegisterGroup',
			'nUserID',
			'szUsernameRaw',
			'szHardID',
			'dwIPAddr',
			'dwGetFlags',
			'nReserved'
		},
		formatKey = '<iiAALLiiiii',
		deformatKey = '<iiA32A32LLiiiii',
		maxsize = 100
	},

	GET_RNDKEY_OK={
		lengthMap = {
			[2] = {maxlen = 4},
			maxlen = 2
		},
		nameMap = {
			'nRndKey',
			'nReserved'
		},
		formatKey = '<iiiii',
		deformatKey = '<iiiii',
		maxsize = 20
	},

	GET_ROOMS={
		unlockable=true,
		lengthMap = {
			[6] = {maxlen = 3},
			maxlen = 6
		},
		nameMap = {
			'nAreaID',
			'nGameID',
			'nAgentGroupID',
			'dwGetFlags',
            'nUserID',
			'nReserved'
		},
		formatKey = '<iiiLiiii',
		deformatKey = '<iiiLiiii',
		maxsize = 32
	},

	GET_ROOMUSERS_BASE={
		lengthMap = {
			[3] = {maxlen = 3},
			[5] = {maxlen = 256},
			maxlen = 5
		},
		nameMap = {
			'nAgentGroupID',
			'dwGetFlags',
			'nReserved',
			'nRoomCount',
			'nRoomIDs'
		},
		formatKey = '<iLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
		deformatKey = '<iLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
		maxsize = 1048
	},

	GET_SERVERS={
		lengthMap = {
			[7] = {maxlen = 2},
			maxlen = 7
		},
		nameMap = {
			'nGameID',
			'nServerType',
			'nSubType',
			'nAgentGroupID',
			'dwGetFlags',
            'nUserID',
			'nReserved'
		},
		formatKey = '<iiiiLiii',
		deformatKey = '<iiiiLiii',
		maxsize = 32
	},

	GET_WEBSIGN={
		lengthMap = {
			[2] = 32,
			[3] = 32,
			[9] = {maxlen = 1},
			[11] = 256,
			maxlen = 11
		},
		nameMap = {
			'nUserID',
			'szPassword',
			'szHardID',
			'dwIPAddr',
			'dwSoapFlags',
			'dwGetFlags',
			'nHallSvrID',
			'lTokenID',
			'nReserved',
			'nValidSecond',
			'szWebSign'
		},
		formatKey = '<iAALLLiliiA',
		deformatKey = '<iA32A32LLLiliiA256',
		maxsize = 352
	},

	GET_WEBSIGN_OK={
		lengthMap = {
			[3] = 256,
			[5] = {maxlen = 3},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'nValidSecond',
			'szWebSign',
			'dwGetFlags',
			'nReserved'
		},
		formatKey = '<iiALiii',
		deformatKey = '<iiA256Liii',
		maxsize = 280
	},

	GIFT_DEPOSIT={
		lengthMap = {
			[5] = {maxlen = 6},
			[7] = 256,
			maxlen = 7
		},
		nameMap = {
			'nUserID',
			'dwGetFlags',
			'nDeposit',
			'nNextSeconds',
			'nReserved',
			'nRemarkLen',
			'szRemark'
		},
		formatKey = '<iLiiiiiiiiiA',
		deformatKey = '<iLiiiiiiiiiA256',
		maxsize = 300
	},

	HALLUSER_PULSE={
		lengthMap = {
			--,
			maxlen = 2
		},
		nameMap = {
			'nUserID',
			'nAgentGroupID'
		},
		formatKey = '<ii',
		deformatKey = '<ii',
		maxsize = 8
	},

	HTTP_GET_REQUEST={
		lengthMap = {
			[3] = 32,
			[5] = {maxlen = 8},
			[6] = 1024,
			maxlen = 6
		},
		nameMap = {
			'nUserID',
			'dwGetFlags',
			'szHardID',
			'nUrlLength',
			'nReserved',
			'szURL'
		},
		formatKey = '<iLAiiiiiiiiiA',
		deformatKey = '<iLA32iiiiiiiiiA1024',
		maxsize = 1100
	},

	ITEM_COUNT={
		lengthMap = {
			[5] = {maxlen = 1},
			maxlen = 5
		},
		nameMap = {
			'nCount',
			'nStatTime',
			'nSubCount',
			'dwGetFlags',
			'nReserved'
		},
		formatKey = '<iiiLi',
		deformatKey = '<iiiLi',
		maxsize = 20
	},

	ITEM_USERS={
		lengthMap = {
			--,
			maxlen = 2
		},
		nameMap = {
			'nItemID',
			'nUsers'
		},
		formatKey = '<ii',
		deformatKey = '<ii',
		maxsize = 8
	},

	MR_LEAVE_ROOM={
		lengthMap = {
			[5] = 32,
			[6] = {maxlen = 4},
			maxlen = 6
		},
		nameMap = {
			'nUserID',
			'nAreaID',
			'nGameID',
			'nRoomID',
			'szHardID',
			'nReserved'
		},
		formatKey = '<iiiiAiiii',
		deformatKey = '<iiiiA32iiii',
		maxsize = 64
	},

	LOGOFF_USER={
		lengthMap = {
			[7] = 32,
			[8] = 32,
			[9] = 32,
			[10] = {maxlen = 2},
			maxlen = 10
		},
		nameMap = {
			'nUserID',
			'nHallSvrID',
			'nAgentGroupID',
			'dwIPAddr',
			'dwLogoffFlags',
			'lTokenID',
			'szHardID',
			'szVolumeID',
			'szMachineID',
			'nReserved'
		},
		formatKey = '<iiiLLlAAAii',
		deformatKey = '<iiiLLlA32A32A32ii',
		maxsize = 128
	},

	LOGON_SUCCEED={
		lengthMap = {
			[11] = 16,
			[12] = 32,
			[13] = {maxlen = 4},
			maxlen = 13
		},
		nameMap = {
			'nUserID',
			'nNickSex',
			'nPortrait',
			'nUserType',
			'nClothingID',
			'nRegisterGroup',
			'nDownloadGroup',
			'nAgentGroupID',
			'nExpiration',
			'nPlayRoom',
			'szNickName',
			'szUniqueID',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiAAiiii',
		deformatKey = '<iiiiiiiiiiA16A32iiii',
		maxsize = 104
	},

	LOGON_USER={
		lengthMap = {
			[11] = 32,
			[12] = 32,
			[13] = 32,
			[14] = 32,
			[15] = 32,
			[16] = 34,
			[17] = 16,
			[18] = 2,
			[27] = {maxlen = 1},
			maxlen = 27
		},
		nameMap = {
			'nBlockSvrID',
			'nUserID',
			'nHallSvrID',
			'nAgentGroupID',
			'nGroupType',
			'dwIPAddr',
			'dwSoapFlags',
			'dwLogonFlags',
			'lTokenID',
			'nResponse',
			'szUsername',
			'szPassword',
			'szHardID',
			'szVolumeID',
			'szMachineID',
			'szHashPwd',
			'szRndKey',
			'unused',
			'dwSysVer',
			'nLogonSvrID',
			'nHallBuildNO',
			'nHallNetDelay',
			'nHallRunCount',
			'nGameID',
			'dwGameVer',
			'nRecommenderID',
			'nReserved'
		},
		formatKey = '<iiiiiLLLlIAAAAAAAALiiiiiLii',
		deformatKey = '<iiiiiLLLlIA32A32A32A32A32A34A16A2LiiiiiLii',
		maxsize = 288
	},

	MEMBER_INFO={
		lengthMap = {
			[6] = {maxlen = 4},
			maxlen = 6
		},
		nameMap = {
			'nUserID',
			'nMemberType',
			'nMemberAdds',
			'nMemberBegin',
			'nMemberEnd',
			'nReserved'
		},
		formatKey = '<iiiiiiiii',
		deformatKey = '<iiiiiiiii',
		maxsize = 36
	},

	MODIFY_USERNAME={
		lengthMap = {
			[4] = 32,
			[5] = 32,
			[6] = 32,
			[7] = 16,
			[10] = {maxlen = 4},
			maxlen = 10
		},
		nameMap = {
			'nAgentGroupID',
			'nGameID',
			'nUserID',
			'szOldName',
			'szNewName',
			'szHardID',
			'szRndKey',
			'dwIPAddr',
			'nKeyResult',
			'nReserved'
		},
		formatKey = '<iiiAAAALiiiii',
		deformatKey = '<iiiA32A32A32A16Liiiii',
		maxsize = 148
	},

	MOVE_SAFE_DEPOSIT={
		lengthMap = {
			[7] = 32,
			[15] = {maxlen = 3},
			maxlen = 15
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nRoomID',
			'nDeposit',
			'nKeyResult',
			'nPlayingGameID',
			'szHardID',
			'dwIPAddr',
			'nGameVID',
			'nTransferTotal',
			'nTransferLimit',
			'llMonthTransferTotal',
			'llMonthTransferLimit',
			'dwFlags',
			'nReserved'
		},
		formatKey = '<iiiiiiALiiiddLiii',
		deformatKey = '<iiiiiiA32LiiiddLiii',
		maxsize = 104
	},

    TAKE_BACKDEPOSIT={
		lengthMap = {
			[7] = 32,
			[15] = {maxlen = 3},
			maxlen = 15
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nRoomID',
			'nDeposit',
			'nKeyResult',
			'nPlayingGameID',
			'szHardID',
			'dwIPAddr',
			'nGameVID',
			'nTransferTotal',
			'nTransferLimit',
			'llMonthTransferTotal',
			'llMonthTransferLimit',
			'dwFlags',
			'nReserved'
		},
		formatKey = '<iiiiiiALiiiddLiii',
		deformatKey = '<iiiiiiA32LiiiddLiii',
		maxsize = 104
	},
	NTF_MR_GET_NEWTABLE={
		lengthMap = {
			[8] = {maxlen = 4},
			maxlen = 8
		},
		nameMap = {
			'nUserID',
			'nTableNO',
			'nChairNO',
			'nNetDelay',
			'nMinScore',
			'nMinDeposit',
			'nFirstSeatedPlayer',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiii',
		deformatKey = '<iiiiiiiiiii',
		maxsize = 44
	},

	NTF_PLAYER_NEWTABLE={
		lengthMap = {
			[9] = {maxlen = 3},
			maxlen = 9
		},
		nameMap = {
			'nUserID',
			'nTableNO',
			'nChairNO',
			'nNetDelay',
			'nMinScore',
			'nMinDeposit',
			'nFirstSeatedPlayer',
			'nHomeUserID',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiii',
		deformatKey = '<iiiiiiiiiii',
		maxsize = 44
	},

	PLAYER={
		lengthMap = {
			[10] = 32,
			[11] = 16,
			[22] = {maxlen = 1},
			[42] = 32,
			[43] = 32,
			[44] = 32,
			[45] = 32,
			[46] = 16,
			[71] = {maxlen = 1},
			maxlen = 71
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
			'nUserID1',
			'nBirthday',
			'nExpiration',
			'nPlayRoom',
			'nRegFrom',
			'nHaveBind',
			'nLogonSvrID',
			'nHallBuildNO',
			'nAgentGroupID',
			'nDownloadGroup',
			'nHallRunCount',
			'nHallNetDelay',
			'nOnRegMachine',
			'nEnterTime',
			'nStartupTime',
			'nEnterGameOKTime',
			'nRandomTableNO',
			'nRandomChairNO',
			'lTokenID',
			'szHardID',
			'szVolumeID',
			'szMachineID',
			'szUniqueID',
			'szPhysAddr',
			'dwPulseTime',
			'dwLatestTime',
			'dwLatestStartTime',
			'dwIPAddr',
			'dwSysVer',
			'dwScreenXY',
			'dwEnterFlags',
			'dwClientPort',
			'dwServerPort',
			'dwClientSockIP',
			'dwRemoteSockIP',
			'dwClientLANIP',
			'dwClientMask',
			'dwClientGateway',
			'dwClientDNS',
			'dwPwdCode',
			'dwPixelsXY',
			'dwClientFlags',
			'nDuan',
			'nDuanScore',
			'nRank',
			'bRealPlaying',
			'nGiftDeposit',
			'nQuanID',
			'nReserved1'
		},
		formatKey = '<iiiiiiiiiAAiiiiiiiiiiiiiiiiiiiiiiiiiiiiilAAAAALLLLLLLLLLLLLLLLLLiiiiiii',
		deformatKey = '<iiiiiiiiiA32A16iiiiiiiiiiiiiiiiiiiiiiiiiiiiilA32A32A32A32A16LLLLLLLLLLLLLLLLLLiiiiiii',
		maxsize = 448
	},

	PLAYER_EXTEND={
		lengthMap = {
			[20] = 32,
			[21] = 32,
			[22] = 32,
			[23] = 32,
			[24] = 16,
			[49] = {maxlen = 1},
			maxlen = 49
		},
		nameMap = {
			'nUserID',
			'nBirthday',
			'nExpiration',
			'nPlayRoom',
			'nRegFrom',
			'nHaveBind',
			'nLogonSvrID',
			'nHallBuildNO',
			'nAgentGroupID',
			'nDownloadGroup',
			'nHallRunCount',
			'nHallNetDelay',
			'nOnRegMachine',
			'nEnterTime',
			'nStartupTime',
			'nEnterGameOKTime',
			'nRandomTableNO',
			'nRandomChairNO',
			'lTokenID',
			'szHardID',
			'szVolumeID',
			'szMachineID',
			'szUniqueID',
			'szPhysAddr',
			'dwPulseTime',
			'dwLatestTime',
			'dwLatestStartTime',
			'dwIPAddr',
			'dwSysVer',
			'dwScreenXY',
			'dwEnterFlags',
			'dwClientPort',
			'dwServerPort',
			'dwClientSockIP',
			'dwRemoteSockIP',
			'dwClientLANIP',
			'dwClientMask',
			'dwClientGateway',
			'dwClientDNS',
			'dwPwdCode',
			'dwPixelsXY',
			'dwClientFlags',
			'nDuan',
			'nDuanScore',
			'nRank',
			'bRealPlaying',
			'nGiftDeposit',
			'nQuanID',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiiiiiiiiilAAAAALLLLLLLLLLLLLLLLLLiiiiiii',
		deformatKey = '<iiiiiiiiiiiiiiiiiilA32A32A32A32A16LLLLLLLLLLLLLLLLLLiiiiiii',
		maxsize = 320
	},

	PLAYER_POSITION={
		lengthMap = {
			--,
			maxlen = 4
		},
		nameMap = {
			'nUserID',
			'nTableNO',
			'nChairNO',
			'nNetDelay'
		},
		formatKey = '<iiii',
		deformatKey = '<iiii',
		maxsize = 16
	},

	QUERY_MEMBER={
		lengthMap = {
			[2] = 32,
			[5] = {maxlen = 3},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'szHardID',
			'dwIPAddr',
            'nGameID',
			'nReserved'
		},
		formatKey = '<iALiiii',
		deformatKey = '<iA32Liiii',
		maxsize = 56
	},

	QUERY_SAFE_DEPOSIT={
		lengthMap = {
			[2] = 32,
			[5] = {maxlen = 2},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'szHardID',
			'dwIPAddr',
			'nGameID',
			'nReserved'
		},
		formatKey = '<iALiii',
		deformatKey = '<iA32Liii',
		maxsize = 52
	},

    QUERY_BACKDEPOSIT={
		lengthMap = {
			[2] = 32,
			[5] = {maxlen = 2},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'szHardID',
			'dwIPAddr',
			'nGameID',
			'nReserved'
		},
		formatKey = '<iALiii',
		deformatKey = '<iA32Liii',
		maxsize = 52
	},
	QUERY_USERID={
		lengthMap = {
			[3] = 32,
			[4] = 32,
			[6] = {maxlen = 3},
			maxlen = 6
		},
		nameMap = {
			'nAgentGroupID',
			'nUserID',
			'szUsername',
			'szHardID',
			'dwIPAddr',
			'nReserved'
		},
		formatKey = '<iiAALiii',
		deformatKey = '<iiA32A32Liii',
		maxsize = 88
	},

	QUERY_USERID_OK={
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

	QUERY_USER_GAMEINFO={
		lengthMap = {
			[5] = 32,
			[7] = {maxlen = 3},
			maxlen = 7
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'dwQueryFlags',
			'dwIPAddr',
			'szHardID',
			'nGiftDeposit',
			'nReserved'
		},
		formatKey = '<iiLLAiiii',
		deformatKey = '<iiLLA32iiii',
		maxsize = 64
	},

	QUERY_WEALTH={
		lengthMap = {
			[2] = 32,
			[7] = {maxlen = 8},
			maxlen = 7
		},
		nameMap = {
			'nUserID',
			'szHardID',
			'dwIPAddr',
			'dwSoapFlags',
			'unused',
			'dSoapReturn',
			'nReserved'
		},
		formatKey = '<iALLidiiiiiiii',
		deformatKey = '<iA32LLidiiiiiiii',
		maxsize = 88
	},

	QUICK_REG={
		lengthMap = {
			[6] = 32,
			[7] = 32,
			[8] = 32,
			[9] = 32,
			[10] = 32,
			[12] = {maxlen = 8},
			maxlen = 12
		},
		nameMap = {
			'nAgentGroupID',
			'nGameID',
			'nRecommenderID',
			'dwIPAddr',
			'dwFlags',
			'szUsername',
			'szPassword',
			'szWifiID',
			'szSystemID',
			'szImeiID',
			'nVerifyReturn',
			'nReserved'
		},
		formatKey = '<iiiLLAAAAAiiiiiiiii',
		deformatKey = '<iiiLLA32A32A32A32A32iiiiiiiii',
		maxsize = 216
	},

	QUICK_REG_OK={
		lengthMap = {
			[1] = 32,
			[2] = 32,
			[3] = {maxlen = 8},
			maxlen = 3
		},
		nameMap = {
			'szUsername',
			'szPassword',
			'nReserved'
		},
		formatKey = '<AAiiiiiiii',
		deformatKey = '<A32A32iiiiiiii',
		maxsize = 96
	},

	MR_REFRESH_MEMBER={
		lengthMap = {
			[4] = 32,
			[5] = {maxlen = 4},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'nRoomID',
			'nMemberType',
			'szHardID',
			'nReserved'
		},
		formatKey = '<iiiAiiii',
		deformatKey = '<iiiA32iiii',
		maxsize = 60
	},

	REG_NICKINFO={
		lengthMap = {
			[2] = 16,
			[4] = 32,
			[6] = {maxlen = 3},
			maxlen = 6
		},
		nameMap = {
			'nUserID',
			'szNickName',
			'nNickSex',
			'szHardID',
			'dwIPAddr',
			'nReserved'
		},
		formatKey = '<iAiALiii',
		deformatKey = '<iA16iA32Liii',
		maxsize = 72
	},

	REG_USER={
		lengthMap = {
			[9] = {maxlen = 3},
			[12] = 32,
			[13] = 16,
			[14] = 32,
			[15] = 16,
			[16] = 32,
			[17] = 32,
			[18] = 32,
			[19] = 32,
			[20] = 32,
			[25] = {maxlen = 7},
			maxlen = 25
		},
		nameMap = {
			'nAgentGroupID',
			'nUserID',
			'nUserType',
			'nSubType',
			'nNickSex',
			'nPortrait',
			'nClothingID',
			'dwRegFlags',
			'nReserved',
			'dwSysVer',
			'dwIPAddr',
			'szUsername',
			'szRndKey',
			'szPassword',
			'szHandPhone',
			'szWifiID',
			'szSystemID',
			'szImeiID',
			'szImsiID',
			'szSimSerialNO',
			'nVerifyReturn',
			'nGiftDeposit',
			'nRecommenderID',
			'nGameID',
			'nReserved2'
		},
		formatKey = '<iiiiiiiLiiiLLAAAAAAAAAiiiiiiiiiii',
		deformatKey = '<iiiiiiiLiiiLLA32A16A32A16A32A32A32A32A32iiiiiiiiiii',
		maxsize = 352
	},

	REG_USER_OK={
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

	RESET_PASSWORD={
		lengthMap = {
			[3] = {maxlen = 4},
			[5] = 32,
			[6] = 16,
			[7] = 32,
			[8] = 16,
			[9] = 32,
			[10] = 32,
			[11] = 32,
			[12] = 32,
			[13] = 32,
			[15] = {maxlen = 7},
			maxlen = 15
		},
		nameMap = {
			'nAgentGroupID',
			'nUserID',
			'nReserved',
			'dwIPAddr',
			'szUsername',
			'szRndKey',
			'szPassword',
			'szHandPhone',
			'szWifiID',
			'szSystemID',
			'szImeiID',
			'szImsiID',
			'szSimSerialNO',
			'nGameID',
			'nReserved2'
		},
		formatKey = '<iiiiiiLAAAAAAAAAiiiiiiii',
		deformatKey = '<iiiiiiLA32A16A32A16A32A32A32A32A32iiiiiiii',
		maxsize = 316
	},

	ROOM={
		lengthMap = {
			[50] = 32,
			[51] = 32,
			[52] = 32,
			[53] = 64,
			[54] = 32,
			[56] = {maxlen = 7},
			maxlen = 56
		},
		nameMap = {
			'nRoomID',
			'nRoomType',
			'nSubType',
			'nStatus',
			'nLayOrder',
			'dwOptions',
			'nFontColor',
			'nIconID',
			'nGifID',
			'nGameID',
			'nGameVID',
			'nGameDBID',
			'nMatchID',
			'nAreaID',
			'nPort',
			'nGamePort',
			'nTableID',
			'nTableIDPlay',
			'nTableStyle',
			'nBoyClothing',
			'nGirlClothing',
			'nTableCount',
			'nChairCount',
			'nUsersOnline',
			'nMinScore',
			'nMaxScore',
			'nMinPlayScore',
			'nMaxPlayScore',
			'nMinDeposit',
			'nMaxDeposit',
			'nMinLevel',
			'nMinExperience',
			'nMaxUsers',
			'nExeMajorVer',
			'nExeMinorVer',
			'nInactiveSecond',
			'nHallBuildNO',
			'nGiftScore',
			'nGiftDeposit',
			'nGameParam',
			'nGameData',
			'nMinSalarySecond',
			'nMaxSalarySecond',
			'nUnitSalary',
			'nMinBoutSecond',
			'nMaxBoutSecond',
			'dwConfigs',
			'dwManages',
			'dwGameOptions',
			'szRoomName',
			'szGameIP',
			'szPassword',
			'szWWW',
			'szExeName',
			'dwActivityClothings',
			'nReserved'
		},
		formatKey = '<iiiiiLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiLLLAAAAALiiiiiii',
		deformatKey = '<iiiiiLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiLLLA32A32A32A64A32Liiiiiii',
		maxsize = 420
	},

	ROOMS={
		lengthMap = {
			[3] = {maxlen = 2},
			maxlen = 3
		},
		nameMap = {
			'nRoomCount',
			'nLinkCount',
			'nReserved'
		},
		formatKey = '<iiii',
		deformatKey = '<iiii',
		maxsize = 16
	},

	GR_ROOMUSER_PULSE={
		lengthMap = {
			--,
			maxlen = 2
		},
		nameMap = {
			'nUserID',
			'nRoomID'
		},
		formatKey = '<ii',
		deformatKey = '<ii',
		maxsize = 8
	},

	ROOM_NEEDSIGNUP={
		lengthMap = {
			[3] = {maxlen = 4},
			[4] = 256,
			maxlen = 4
		},
		nameMap = {
			'nRoomID',
			'nURLLen',
			'nReserved',
			'szSignUpURL'
		},
		formatKey = '<iiiiiiA',
		deformatKey = '<iiiiiiA256',
		maxsize = 280
	},

	SAFE_DEPOSIT={
		lengthMap = {
			[5] = {maxlen = 2},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'nSafeboxDeposit',
			'bHaveSecurePwd',
			'nRemindDeposit',
			'nReserved'
		},
		formatKey = '<iiiiii',
		deformatKey = '<iiiiii',
		maxsize = 24
	},

	SALARY_DEPOSIT={
		lengthMap = {
			[5] = {maxlen = 3},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nDeposit',
			'nTotalSalary',
			'nReserved'
		},
		formatKey = '<iiiiiii',
		deformatKey = '<iiiiiii',
		maxsize = 28
	},

	SERVER={
		lengthMap = {
			[3] = 32,
			[4] = 32,
			[5] = 64,
			[6] = 64,
			[14] = {maxlen = 2},
			maxlen = 14
		},
		nameMap = {
			'nServerID',
			'nServerType',
			'szServerName',
			'szServerIP',
			'szWWW',
			'szWWW2',
			'nUsersOnline',
			'nGroupID',
			'nSubType',
			'nPort',
			'nLayOrder',
			'nStatus',
			'dwOptions',
			'nReserved'
		},
		formatKey = '<iiAAAAiiiiiiLii',
		deformatKey = '<iiA32A32A64A64iiiiiiLii',
		maxsize = 236
	},

	SERVERS={
		lengthMap = {
			[2] = {maxlen = 4},
			maxlen = 2
		},
		nameMap = {
			'nServerCount',
			'nReserved'
		},
		formatKey = '<iiiii',
		deformatKey = '<iiiii',
		maxsize = 20
	},

	SYSTEM_MSG={
		lengthMap = {
			[5] = {maxlen = 6},
			[14] = 4096,
			maxlen = 14
		},
		nameMap = {
			'nMsgID',
			'dwDlgSize',
			'dwOptions',
			'nLifeTime',
			'nReserved',
			'nAgentGroupID',
			'nRoomID',
			'nClientID',
			'nMsgFrom',
			'nMsgTo',
			'nSendDate',
			'nSendTime',
			'nMsgLen',
			'szMsgText'
		},
		formatKey = '<iLLiiiiiiiiiiiiiiiA',
		deformatKey = '<iLLiiiiiiiiiiiiiiiA4096',
		maxsize = 4168
	},

	TAKE_GIFT_DEPOSIT={
		lengthMap = {
			[5] = 32,
			[6] = 32,
			[7] = 32,
			[11] = {maxlen = 5},
			[12] = 256,
			maxlen = 12
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nRoomID',
			'nDeposit',
			'szHardID',
			'szVolumeID',
			'szMachineID',
			'dwIPAddr',
			'dwGetFlags',
			'dwSoapFlags',
			'nReserved',
			'szRemark'
		},
		formatKey = '<iiiiAAALLLiiiiiA',
		deformatKey = '<iiiiA32A32A32LLLiiiiiA256',
		maxsize = 400
	},

	TAKE_SALARY_DEPOSIT={
		lengthMap = {
			[5] = 32,
			[9] = {maxlen = 4},
			maxlen = 9
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nRoomID',
			'nDeposit',
			'szHardID',
			'dwIPAddr',
			'nGameVID',
			'nRemainDeposit',
			'nReserved'
		},
		formatKey = '<iiiiALiiiiii',
		deformatKey = '<iiiiA32Liiiiii',
		maxsize = 76
	},

	TRANSFER_DEPOSIT={
		lengthMap = {
			[9] = 32,
			[15] = {maxlen = 7},
			maxlen = 15
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nToGame',
			'nFromRoom',
			'nToRoom',
			'nDeposit',
			'nPlayingGameID',
			'nVerifyGame',
			'szHardID',
			'dwIPAddr',
			'nGameVID',
			'nTransferTotal',
			'nTransferLimit',
			'dwFlags',
			'nReserved'
		},
		formatKey = '<iiiiiiiiALiiiLiiiiiii',
		deformatKey = '<iiiiiiiiA32LiiiLiiiiiii',
		maxsize = 112
	},

    SAVE_BACKDEPOSIT={
		lengthMap = {
			[9] = 32,
			[15] = {maxlen = 7},
			maxlen = 15
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nToGame',
			'nFromRoom',
			'nToRoom',
			'nDeposit',
			'nPlayingGameID',
			'nVerifyGame',
			'szHardID',
			'dwIPAddr',
			'nGameVID',
			'nTransferTotal',
			'nTransferLimit',
			'dwFlags',
			'nReserved'
		},
		formatKey = '<iiiiiiiiALiiiLiiiiiii',
		deformatKey = '<iiiiiiiiA32LiiiLiiiiiii',
		maxsize = 112
	},
	UPDATE_USERSPECIFYINFO={
		lengthMap = {
			[2] = 32,
			[5] = {maxlen = 8},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'szHardID',
			'dwIPAddr',
			'dwFlag',
			'nReserved'
		},
		formatKey = '<iALLiiiiiiii',
		deformatKey = '<iA32LLiiiiiiii',
		maxsize = 76
	},

	UPDATE_USERSPECIFYINFO_OK={
		lengthMap = {
			[5] = {maxlen = 8},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'dwFlag',
			'nClothingID',
			'nMember',
			'nReserved'
		},
		formatKey = '<iLiiiiiiiiii',
		deformatKey = '<iLiiiiiiiiii',
		maxsize = 48
	},

	USER_ACTIVATE={
		lengthMap = {
			[3] = 32,
			[4] = 64,
			[5] = {maxlen = 8},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'lTokenID',
			'szPassword',
			'szWWW',
			'nReserved'
		},
		formatKey = '<ilAAiiiiiiii',
		deformatKey = '<ilA32A64iiiiiiii',
		maxsize = 136
	},

	USER_GAMEINFO={
		lengthMap = {
			[17] = {maxlen = 7},
			maxlen = 17
		},
		nameMap = {
			'nUserID',
			'nGameID',
			'nDeposit',
			'nPlayerLevel',
			'nScore',
			'nExperience',
			'nBreakOff',
			'nWin',
			'nLoss',
			'nStandOff',
			'nBout',
			'nTimeCost',
			'nSalaryTime',
			'nSalaryDeposit',
			'nTotalSalary',
            'dwFlags',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiiiiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiiiiiiiiiiiiiii',
		maxsize = 92
	},

	USER_WEALTH={
		lengthMap = {
			[5] = {maxlen = 8},
			maxlen = 5
		},
		nameMap = {
			'nUserID',
			'unused',
			'dWealth',
			'nExchangeRatio',
			'nReserved'
		},
		formatKey = '<iidiiiiiiiii',
		deformatKey = '<iidiiiiiiiii',
		maxsize = 56
	},

	CHECK_VERSION={
		lengthMap = {
			[5] = 32,
			[6] = {maxlen = 4},
			maxlen = 6
		},
		nameMap = {
			'nMajorVer',
			'nMinorVer',
			'nBuildNO',
			'nGameID',
			'szExeName',
			'nReserved'
		},
		formatKey = '<iiiiAiiii',
		deformatKey = '<iiiiA32iiii',
		maxsize = 64
	},

	GET_ASSISTSVR={
		lengthMap = {
			[7] = {maxlen = 7},
			maxlen = 7
		},
		nameMap = {
			'nGameID',
			'nType',
			'nSubType',
			'nAgentGroupID',
			'dwGetFlags',
            'nUserID',
			'nReserved'
		},
		formatKey = '<iiiiLiiiiiiii',
		deformatKey = '<iiiiLiiiiiiii',
		maxsize = 52
	},

	ASSIST_SERVER_HEAD={
		lengthMap = {
			[5] = {maxlen = 1},
			maxlen = 5
		},
		nameMap = {
			'nCount',
			'nStatTime',
			'nSubCount',
			'dwGetFlags',
			'nReserved'
		},
		formatKey = '<iiiLi',
		deformatKey = '<iiiLi',
		maxsize = 20
	},

	ASSIST_SERVER={
		lengthMap = {
			[8] = 32,
			[9] = {maxlen = 16},
			maxlen = 9
		},
		nameMap = {
			'nID',
			'nGameID',
			'nType',
			'nSubType',
			'nStatus',
			'dwOptions',
			'nPort',
			'szIP',
			'nReserved'
		},
		formatKey = '<iiiiiLiAiiiiiiiiiiiiiiii',
		deformatKey = '<iiiiiLiA32iiiiiiiiiiiiiiii',
		maxsize = 124
	},

	PAY_RESULT={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPayTo( int )	: maxsize = 4,
			-- [3] = nPayFor( int )	: maxsize = 4,
			-- [4] = nGameID( int )	: maxsize = 4,
			-- [5] = llOperationID1( unsigned int )	: maxsize = 4,
			-- [6] = llOperationID2( int )	: maxsize = 4,
			-- [7] = llBalance1( unsigned int )	: maxsize = 4,
			-- [8] = llBalance2( int )	: maxsize = 4,
			-- [9] = nOperateAmount( int )	: maxsize = 4,
			-- [10] = nCreateTime( int )	: maxsize = 4,
			-- [11] = dwFlags( unsigned long )	: maxsize = 4,
			-- [12] = nRoomID( int )	: maxsize = 4,
													-- szGameGoodsID	: maxsize = 17	=	1 * 17 * 1,
			[13] = 17,
													-- szLinkNo	: maxsize = 33	=	1 * 33 * 1,
			[14] = 33,
													-- szReserve	: maxsize = 14	=	1 * 14 * 1,
			[15] = 14,
			maxlen = 15
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPayTo',		-- [2] ( int )
			'nPayFor',		-- [3] ( int )
			'nGameID',		-- [4] ( int )
			'llOperationID1',		-- [5] ( unsigned int )
			'llOperationID2',		-- [6] ( int )
			'llBalance1',		-- [7] ( unsigned int )
			'llBalance2',		-- [8] ( int )
			'nOperateAmount',		-- [9] ( int )
			'nCreateTime',		-- [10] ( int )
			'dwFlags',		-- [11] ( unsigned long )
			'nRoomID',		-- [12] ( int )
			'szGameGoodsID',		-- [13] ( char )
			'szLinkNo',		-- [14] ( char )
			'szReserve',		-- [15] ( char )
		},
		formatKey = '<i4IiIi3LiA3',
		deformatKey = '<i4IiIi3LiA17A33A14',
		maxsize = 112
	},

	PAY_VIP_RESULT={
		lengthMap = {
			[6] = 256,
			[7] = {maxlen = 8},
			maxlen = 7
		},
		nameMap = {
			'nUserID',
			'nMemberLevel',
			'nMemberExp',
			'nMemberEnd',
			'nCreateTime',
			'szUrl',
			'nReserved'
		},
		formatKey = '<iiiiiAiiiiiiii',
		deformatKey = '<iiiiiA256iiiiiiii',
		maxsize = 280
	},

    MR_FOUND_NEW_GROUP_TABLEROOMS={
        lengthMap = {
			[6] = {maxlen = 8},
			maxlen = 6
		},
		nameMap = {
            'nRoomID',
			'nUserID',
			'nGroupNum',
			'nTableIndex',
			'nTableValue',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiiiii',
		maxsize = 52
    },

    REPLY_NEW_GROUP_TABLEROOMS={
        lengthMap = {
        	[4] = {maxlen = 6},
			maxlen = 4
		},
		nameMap = {
			'nResultCount',
            'nLimitTeamMin',
            'nLimitTeamMax',
			'nReserved'
		},
		formatKey = '<iiiiiiiii',
		deformatKey = '<iiiiiiiii',
		maxsize = 36
    },

    ONE_TABLEROOM={
        lengthMap = {
        	[3] = 32,
			[9] = {maxlen = 8},
			maxlen = 9
		},
		nameMap = {
            'nNickSex',
			'nHomeUserID',
			'szUserName',
            'nTableId',
            'nAvgBounts',
            'nAvgWins',
            'nAvgScore',
            'nAvgDeposit',
            'nExistPlayerIDs'
		},
		formatKey = '<iiAiiiiiiiiiiiii',
		deformatKey = '<iiA32iiiiiiiiiiiii',
		maxsize = 92
    },

    MR_ASK_DETAIL_TABLEROOMS={
        lengthMap = {
        	[4] = {maxlen = 8},
			maxlen = 4
		},
		nameMap = {
            'nRoomID',
			'nUserID',
            'nTableID',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiii',
		deformatKey = '<iiiiiiiiiii',
		maxsize = 44
    },

    REPLY_DETAIL_TABLEROOMS={
        lengthMap = {
        	[3] = {maxlen = 8},
			maxlen = 3
		},
		nameMap = {
			'nHomeUserID',
            'nPlayerCount',
			'nReserved'
		},
		formatKey = '<iiiiiiiiii',
		deformatKey = '<iiiiiiiiii',
		maxsize = 40
    },

    ONE_TRPLAYER={
        lengthMap = {
        	[3] = 32,
			maxlen = 7
		},
		nameMap = {
            'nNickSex',
			'nUserID',
            'szUserName',
			'nWins',
            'nTotalBount',
            'nScore',
            'nDeposit'
		},
		formatKey = '<iiAiiii',
		deformatKey = '<iiA32iiii',
		maxsize = 56
    },

    MR_ASK_ENTER_PRIVATEROOM={
        lengthMap = {
        	[15] = {maxlen = 7},
			maxlen = 15
		},
		nameMap = {
			'nUserID',	
            'nHomeUserID',							 
	        'nRoomID',								 
	        'nAreaID',							 
	        'nGameID',
	        'nTableNO',
	        'nChairNO',
	        'nIPConfig',
	        'nBreakReq',
	        'nSpeedReq',
	        'nMinScore',
	        'nMinDeposit',
	        'nNetDelay',
            'nEnterGameFlag',
	        'nReserved',
        },
		formatKey = '<iiiiiiiiiiiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiiiiiiiiiiiii',
		maxsize = 84
    },

    MR_SET_OPENING_PRIVATEROOM={
        lengthMap = {
            [6] = {maxlen = 8},
            maxlen = 6
        },
        nameMap = {
            'nUserID',								 
            'nRoomID',									 						 
            'nTableNO',	
            'nChairNO',	
            'nIsOpening',	
            'nReserved'
        },
        formatKey = '<iiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiii',
        maxsize = 52
    },

    MR_SET_LOCK_TEAMROOM={
        lengthMap = {
            [6] = {maxlen = 8},
            maxlen = 6
        },
        nameMap = {
            'nUserID',								 
            'nRoomID',									 						 
            'nTableNO',	
            'nChairNO',	
            'nIsOpening',	
            'nReserved'
        },
        formatKey = '<iiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiii',
        maxsize = 52
    },

    MR_ASK_SYSTEM_FIND_PLAYERS={
        lengthMap = {
            [6] = 32,
            [7] = {maxlen = 8},
            maxlen = 7
        },
        nameMap = {
            'nUserID',								 
            'nRoomID',	
            'nGameID',								 						 
            'nTableNO',	
            'nChairNO',	
            'szHardID',	
            'nReserved'
        },
        formatKey = '<iiiiiAiiiiiiii',
        deformatKey = '<iiiiiA32iiiiiiii',
        maxsize = 84
    },

    BE_FOUND_BY_SYSTEM={
        lengthMap = {
            [2] = 32,
            [7] = {maxlen = 8},
            maxlen = 7
        },
        nameMap = {
            'nHomeUserID',		
            'szHUserName',						 
            'nRoomID',	
            'nAreaID',
            'nGameID',								 						 
            'nTableNO',
            'nReserved'
        },
        formatKey = '<iAiiiiiiiiiiii',
        deformatKey = '<iA32iiiiiiiiiiii',
        maxsize = 84
    },

    MR_TRYGOTO_OTHERROOM={
		lengthMap = {
			[12] = {maxlen = 6},
			maxlen = 12
		},
		nameMap = {
			'nUserID',
            'nGameID',
			'nRoomID',
			'nAreaID',
            'nIPConfig',
			'nBreakReq',
			'nSpeedReq',
			'nMinScore',
			'nMinDeposit',
			'nNetDelay',
            'nExcludedHomeID',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiiiiiiiii',
		maxsize = 68
	},

    TRYGOTORESULT={
        lengthMap = {
			maxlen = 6
		},
		nameMap = {
        'nHomeUserID',							 
	    'nRoomID',								 
	    'nGameID',
	    'nTableNO',
	    'nChairNO',
	    'nResultType'
        },
        formatKey = '<iiiiii',
		deformatKey = '<iiiiii',
		maxsize = 24
    },

    MR_SET_GAMEISACTIVED = {
    	lengthMap = {
    	    [7] ={maxlen = 4},
        	maxlen = 7,
    	},
    	nameMap = {
    		'nUserID',
    		'nGameID',
    		'nRoomID',
    		'nTableNO',
    		'nChairNO',
    		'nIsActived',
    		'nReserved'
    	},
    	formatKey = '<iiiiiiiiii',
    	deformatKey = '<iiiiiiiiii',
    	maxsize =  40,
    },

	MR_GET_WHEREISUSER={
		lengthMap = {
			[5] = 32,
			[6] = {maxlen = 4},
			maxlen = 6
		},
		nameMap = {
			'nTargetUserID',
			'nUserID',
			'nGameID',
			'nRoomID',
			'szHardID',
			'nReserved'
		},
		formatKey = '<iiiiAiiii',
		deformatKey = '<iiiiA32iiii',
		maxsize = 64
	},

	SEARCH_PLAYER_INGAME={
		lengthMap = {
			[5] = 32,
			[7] = {maxlen = 8},
			maxlen = 7
		},
		nameMap = {
			'nGameID',
			'nPlayer',
			'nAskerID',
			'nAgentGroupID',
			'szHardID',
			'dwIPAddr',
			'nReserved'
		},
		formatKey = '<iiiiALiiiiiiii',
		deformatKey = '<iiiiA32Liiiiiiii',
		maxsize = 84
	},
	
	SEARCH_PLAYER_INGAME_OK={
		lengthMap = {
			[7] = {maxlen = 16},
			maxlen = 7
		},
		nameMap = {
			'nUserID',
			'nAgentGroupID',
			'nGameID',
			'nAreaID',
			'nRoomID',
			'nAskerID',
			'nReserved'
		},
		formatKey = '<iiiiiiiiiiiiiiiiiiiiii',
		deformatKey = '<iiiiiiiiiiiiiiiiiiiiii',
		maxsize = 88
	},

    MR_ASK_DETAIL_TEAMROOM = {
        lengthMap = {
            [4] = {maxlen = 8},
            maxlen = 4
        },
        nameMap = {
            'nRoomID',
            'nUserID',
            'nTableID',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiii',
        deformatKey = '<iiiiiiiiiii',
        maxsize = 44
    },

    -- HALLUSER_PULSE = {
	-- 	lengthMap = {
	-- 		maxlen = 2
	-- 	},
	-- 	nameMap = {
	-- 		'nUserID',
	-- 		'nAgentGroupID',
	-- 	},
	-- 	formatKey = '<ii',
 	-- },

 	ROOMUSER_PULSE = {
		lengthMap = {
			maxlen = 2
		},
		nameMap = {
			'nUserID',
			'nRoomID',
		},
		formatKey = '<ii',
	},

	USER_DXXW_INFO={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nAreaID( int )	: maxsize = 4,
			-- [4] = nRoomID( int )	: maxsize = 4,
			-- [5] = nTableNO( int )	: maxsize = 4,
			-- [6] = nStartTime( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[7] = { maxlen = 8 },
			maxlen = 7
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nAreaID',		-- [3] ( int )
			'nRoomID',		-- [4] ( int )
			'nTableNO',		-- [5] ( int )
			'nStartTime',		-- [6] ( int )
			'nReserved',		-- [7] ( int )
		},
		formatKey = '<i14',
		deformatKey = '<i14',
		maxsize = 56
	},

	GET_USER_DXXW_INFO={
		lengthMap = {
			-- [1] = nGameID( int )	: maxsize = 4,
			-- [2] = nUserID( int )	: maxsize = 4,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[3] = 32,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
			maxlen = 4
		},
		nameMap = {
			'nGameID',		-- [1] ( int )
			'nUserID',		-- [2] ( int )
			'szHardID',		-- [3] ( char )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i2Ai8',
		deformatKey = '<i2A32i8',
		maxsize = 72
	},

	GET_ROOM={
		lengthMap = {
			-- [1] = nAgentGroupID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nRoomID( int )	: maxsize = 4,
			-- [4] = dwFlags( unsigned long )	: maxsize = 4,
													-- nReserved	: maxsize = 64	=	4 * 16 * 1,
			[5] = { maxlen = 16 },
			maxlen = 5
		},
		nameMap = {
			'nAgentGroupID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nRoomID',		-- [3] ( int )
			'dwFlags',		-- [4] ( unsigned long )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i3Li16',
		deformatKey = '<i3Li16',
		maxsize = 80
	},
	
	GET_YQWROOMINFO_REQ={
		lengthMap = {
			-- [1] = nYQWRoomNo( int )	: maxsize = 4,
			-- [2] = nUserID( int )	: maxsize = 4,
			-- [3] = nClubNo( int )	: maxsize = 4,
													-- nReserved	: maxsize = 88	=	4 * 22 * 1,
			[4] = { maxlen = 22 },
			maxlen = 4
		},
		nameMap = {
			'nYQWRoomNo',		-- [1] ( int )
			'nUserID',		-- [2] ( int )
			'nClubNo',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i25',
		deformatKey = '<i25',
		maxsize = 100
	},
	
	YQWROOM_INFO={
		lengthMap = {
			-- [1] = nYQWRoomNo( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
													-- szTAPPCode	: maxsize = 16	=	1 * 16 * 1,
			[3] = 16,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[4] = 16,
													-- szGameName	: maxsize = 64	=	1 * 64 * 1,
			[5] = 64,
			-- [6] = nRoomID( int )	: maxsize = 4,
			-- [7] = nTableNO( int )	: maxsize = 4,
			-- [8] = nYWQRoomType( int )	: maxsize = 4,
			-- [9] = nMasterID( int )	: maxsize = 4,
			-- [10] = nPlayerLimit( int )	: maxsize = 4,
			-- [11] = nPlayingNum( int )	: maxsize = 4,
			-- [12] = nYWQRoomStatus( int )	: maxsize = 4,
			-- [13] = nAllocFlag( int )	: maxsize = 4,
			-- [14] = nRuleLen( int )	: maxsize = 4,
			-- [15] = nMaxViewerCount( int )	: maxsize = 4,
			-- [16] = nClubNO( int )	: maxsize = 4,
													-- nReserved	: maxsize = 80	=	4 * 20 * 1,
			[17] = { maxlen = 20 },
			maxlen = 17
		},
		nameMap = {
			'nYQWRoomNo',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'szTAPPCode',		-- [3] ( char )
			'szGameCode',		-- [4] ( char )
			'szGameName',		-- [5] ( char )
			'nRoomID',		-- [6] ( int )
			'nTableNO',		-- [7] ( int )
			'nYWQRoomType',		-- [8] ( int )
			'nMasterID',		-- [9] ( int )
			'nPlayerLimit',		-- [10] ( int )
			'nPlayingNum',		-- [11] ( int )
			'nYWQRoomStatus',		-- [12] ( int )
			'dwAllocFlag',		-- [13] ( int )
			'nRuleLen',		-- [14] ( int )
			'nMaxViewerCount',		-- [15] ( int )
			'nClubNO',		-- [16] ( int )
			'nReserved',		-- [17] ( int )
		},
		formatKey = '<i2A3i31',
		deformatKey = '<i2A16A16A64i31',
		maxsize = 228
	},
	
	YQW_JOIN_ROOM={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRoomID( int )	: maxsize = 4,
			-- [3] = nTableNO( int )	: maxsize = 4,
			-- [4] = nChairNO( int )	: maxsize = 4,
			-- [5] = nAreaID( int )	: maxsize = 4,
			-- [6] = nGameID( int )	: maxsize = 4,
			-- [7] = nNetDelay( int )	: maxsize = 4,
			-- [8] = nOwnerId( int )	: maxsize = 4,
			-- [9] = nIdentity( int )	: maxsize = 4,
			-- [10] = nYqwRoomNo( int )	: maxsize = 4,
													-- nReserved	: maxsize = 20	=	4 * 5 * 1,
			[12] = { maxlen = 4 },
			maxlen = 12
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRoomID',		-- [2] ( int )
			'nTableNO',		-- [3] ( int )
			'nChairNO',		-- [4] ( int )
			'nAreaID',		-- [5] ( int )
			'nGameID',		-- [6] ( int )
			'nNetDelay',		-- [7] ( int )
			'nOwnerId',		-- [8] ( int )
			'nIdentity',		-- [9] ( int )
			'nYQWRoomNo',		-- [10] ( int )
			'dwChairFlag',
			'nReserved',		-- [11] ( int )
		},
		formatKey = '<i15',
		deformatKey = '<i15',
		maxsize = 60
	},
	
	YQW_ALLOC_ROOM={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRoomID( int )	: maxsize = 4,
			-- [3] = nAreaID( int )	: maxsize = 4,
			-- [4] = nGameID( int )	: maxsize = 4,
			-- [5] = nNetDelay( int )	: maxsize = 4,
			-- [6] = nIdentity( int )	: maxsize = 4,
			-- [7] = dwAllocFlag( DWORD )	: maxsize = 4,
			-- [8] = nCheckRoomNo( int )	: maxsize = 4,
													-- nReserved	: maxsize = 24	=	4 * 6 * 1,
			[12] = { maxlen = 3 },
			maxlen = 12
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRoomID',		-- [2] ( int )
			'nAreaID',		-- [3] ( int )
			'nGameID',		-- [4] ( int )
			'nNetDelay',		-- [5] ( int )
			'nIdentity',		-- [6] ( int )
			'dwAllocFlag',		-- [7] ( DWORD )
			'nCheckRoomNo',		-- [8] ( int )
			'nCheckCreator',
			'dwChairFlag',
			'nTheChairNO',
			'nReserved',		-- [9] ( int )
		},
		formatKey = '<i14',
		deformatKey = '<i14',
		maxsize = 56
	},

	GET_YQWPLAYERINFO_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- nReserved	: maxsize = 96	=	4 * 24 * 1,
			[3] = { maxlen = 23 },
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
            'nGameID',
			'nReserved',		-- [2] ( int )
		},
		formatKey = '<i25',
		deformatKey = '<i25',
		maxsize = 100
	},

	YQW_DON_HAPPY_COIN={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[3] = 32,
			-- [4] = nReceiveUserID( int )	: maxsize = 4,
			-- [5] = nAmount( int )	: maxsize = 4,
			-- [6] = nChannelID( int )	: maxsize = 4,
			-- [7] = nHttpFlag( int )	: maxsize = 4,
			-- [8] = pHttpAck( int )	: maxsize = 4,
			-- [9] = nFromType( int )	: maxsize = 4,
													-- szOrderID	: maxsize = 8	=	1 * 8 * 1,
			[10] = 8,
			-- [11] = nOrderDate( int )	: maxsize = 4,
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[12] = { maxlen = 4 },
			maxlen = 12
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'szHardID',		-- [3] ( char )
			'nReceiveUserID',		-- [4] ( int )
			'nAmount',		-- [5] ( int )
			'nChannelID',		-- [6] ( int )
			'nHttpFlag',		-- [7] ( int )
			'pHttpAck',		-- [8] ( int )
			'nFromType',		-- [9] ( int )
			'szOrderID',		-- [10] ( unsigned char )
			'nOrderDate',		-- [11] ( int )
			'nReserved',		-- [12] ( int )
		},
		formatKey = '<i2Ai6Ai5',
		deformatKey = '<i2A32i6b8i5',
		maxsize = 92
	},
	
	YQW_GET_HAPPY_COIN={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
			-- [3] = nHttpFlag( int )	: maxsize = 4,
			-- [4] = pHttpAck( int )	: maxsize = 4,
			-- [5] = nGameID( int )	: maxsize = 4,
			-- [6] = nGroupID( int )	: maxsize = 4,
			-- [7] = nFromType( int )	: maxsize = 4,
													-- nReserved	: maxsize = 20	=	4 * 5 * 1,
			[8] = { maxlen = 5 },
			maxlen = 8
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szHardID',		-- [2] ( char )
			'nHttpFlag',		-- [3] ( int )
			'pHttpAck',		-- [4] ( int )
			'nGameID',		-- [5] ( int )
			'nGroupID',		-- [6] ( int )
			'nFromType',		-- [7] ( int )
			'nReserved',		-- [8] ( int )
		},
		formatKey = '<iAi10',
		deformatKey = '<iA32i10',
		maxsize = 76
	},
	
	HAPPY_COIN_DATA={
		lengthMap = {
			-- [1] = nTotalBalance_LOW( unsigned int )	: maxsize = 4,
			-- [2] = nTotalBalance_HIGH( int )	: maxsize = 4,
			-- [3] = nDonateBalance_LOW( unsigned int )	: maxsize = 4,
			-- [4] = nDonateBalance_HIGH( int )	: maxsize = 4,
			-- [5] = nUserID( int )	: maxsize = 4,
			maxlen = 5
		},
		nameMap = {
			'nTotalBalance_LOW',		-- [1] ( unsigned int )
			'nTotalBalance_HIGH',		-- [2] ( int )
			'nDonateBalance_LOW',		-- [3] ( unsigned int )
			'nDonateBalance_HIGH',		-- [4] ( int )
			'nUserID',		-- [5] ( int )
		},
		formatKey = '<IiIi2',
		deformatKey = '<IiIi2',
		maxsize = 20
	},
	
	GAME_BILL={
		lengthMap = {
													-- szReplayUrl	: maxsize = 256	=	1 * 256 * 1,
			[1] = 256,
			-- [2] = nStartTimestamp( int )	: maxsize = 4,
			-- [3] = nEndTimestamp( int )	: maxsize = 4,
			-- [4] = nPlayerCount( int )	: maxsize = 4,
			-- [5] = nLapIndex( int )	: maxsize = 4,
													-- aReserved	: maxsize = 28	=	4 * 7 * 1,
			[6] = { maxlen = 7 },
			maxlen = 6
		},
		nameMap = {
			'szReplayUrl',		-- [1] ( char )
			'nStartTimestamp',		-- [2] ( int )
			'nEndTimestamp',		-- [3] ( int )
			'nPlayerCount',		-- [4] ( int )
			'nLapIndex',		-- [5] ( int )
			'aReserved',		-- [6] ( int )
		},
		formatKey = '<Ai11',
		deformatKey = '<A256i11',
		maxsize = 300
	},
	
	GET_YQWGAMEBILL_REQ={
		lengthMap = {
													-- szRoundBillID	: maxsize = 32	=	1 * 32 * 1,
			[1] = 32,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 7 },
			maxlen = 3
		},
		nameMap = {
			'szRoundBillID',		-- [1] ( char )
            'nNeedRule',            -- [2] (int)
			'nReserved',		-- [2] ( int )
		},
		formatKey = '<Ai8',
		deformatKey = '<A32i8',
		maxsize = 64
	},
	
	GET_YQWGAMEBILL_RESP={
		lengthMap = {
			-- [1] = nErrCode( int )	: maxsize = 4,
			-- [2] = nGameBillCount( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nErrCode',		-- [1] ( int )
			'nGameBillCount',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	
	GET_YQWROUNDBILL_REQ={
		lengthMap = {
			-- [1] = nPlayerID( int )	: maxsize = 4,
			-- [2] = nDirection( int )	: maxsize = 4,
			-- [3] = nLastBillTimestamp( int )	: maxsize = 4,
			-- [4] = nPageSize( int )	: maxsize = 4,
            -- [5] = szGameCode( char ) : maxsize = 16
													-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[5] = 16,
            [6] = { maxlen = 4 },
			maxlen = 6
		},
		nameMap = {
			'nPlayerID',		-- [1] ( int )
			'nDirection',		-- [2] ( int )
			'nLastBillTimestamp',		-- [3] ( int )
			'nPageSize',		-- [4] ( int )
            'szGameCode',       -- [5] ( char )
			'nReserved',		-- [6] ( int )
		},
		formatKey = '<i4Ai4',
		deformatKey = '<i4A16i4',
		maxsize = 48
	},
	
	GET_YQWROUNDBILL_RESP={
		lengthMap = {
			-- [1] = nErrCode( int )	: maxsize = 4,
			-- [2] = nRoundBillCount( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nErrCode',		-- [1] ( int )
			'nRoundBillCount',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	
	GAME_PLAYER_INFO={
		lengthMap = {
			-- [1] = nPlayerID( int )	: maxsize = 4,
			-- [2] = nScore( int )	: maxsize = 4,
			-- [3] = nWinFlag( int )	: maxsize = 4,
													-- szResultMessage	: maxsize = 32	=	1 * 32 * 1,
			[4] = 32,
													-- szExtra	: maxsize = 128	=	1 * 128 * 1,
			[5] = 128,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[6] = { maxlen = 8 },
			maxlen = 6
		},
		nameMap = {
			'nPlayerID',		-- [1] ( int )
			'nScore',		-- [2] ( int )
			'nWinFlag',		-- [3] ( int )
			'szResultMessage',		-- [4] ( char )
			'szExtra',		-- [5] ( char )
			'nReserved',		-- [6] ( int )
		},
		formatKey = '<i3A2i8',
		deformatKey = '<i3A32A128i8',
		maxsize = 204
	},
	
	ROUND_BILL={
		lengthMap = {
													-- szRoundBillID	: maxsize = 32	=	1 * 32 * 1,
			[1] = 32,
			-- [2] = nStartTimestamp( int )	: maxsize = 4,
			-- [3] = nEndTimestamp( int )	: maxsize = 4,
			-- [4] = nRoomNO( int )	: maxsize = 4,
			-- [5] = nRoomType( int )	: maxsize = 4,
													-- szTAPPCode	: maxsize = 16	=	1 * 16 * 1,
			[6] = 16,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[7] = 16,
													-- szGameName	: maxsize = 64	=	1 * 64 * 1,
			[8] = 64,
			-- [9] = nGameBillCount( int )	: maxsize = 4,
			-- [10] = dwColumnFlag( unsigned long )	: maxsize = 4,
			-- [11] = nPlayerCount( int )	: maxsize = 4,
			-- [12] = nRoomOwnerID( int )	: maxsize = 4,
			-- [13] = nRoomUnit( int )	: maxsize = 4,
													-- nReserved	: maxsize = 24	=	4 * 6 * 1,
			[14] = { maxlen = 6 },
			maxlen = 14
		},
		nameMap = {
			'szRoundBillID',		-- [1] ( char )
			'nStartTimestamp',		-- [2] ( int )
			'nEndTimestamp',		-- [3] ( int )
			'nRoomNO',		-- [4] ( int )
			'nRoomType',		-- [5] ( int )
			'szTAPPCode',		-- [6] ( char )
			'szGameCode',		-- [7] ( char )
			'szGameName',		-- [8] ( char )
			'nGameBillCount',		-- [9] ( int )
			'dwColumnFlag',		-- [10] ( unsigned long )
			'nPlayerCount',		-- [11] ( int )
			'nRoomOwnerID',		-- [12] ( int )
			'nRoomUnit',		-- [13] ( int )
			'nReserved',		-- [12] ( int )
		},
		formatKey = '<Ai4A3iLi9',
		deformatKey = '<A32i4A16A16A64iLi9',
		maxsize = 188
	},
	
	ROUND_PLAYER_INFO={
		lengthMap = {
			-- [1] = nPlayerID( int )	: maxsize = 4,
													-- szPlayerName	: maxsize = 128	=	1 * 128 * 1,
			[2] = 128,
													-- szPortraitUrl	: maxsize = 256	=	1 * 256 * 1,
			[3] = 256,
			-- [4] = nScore( int )	: maxsize = 4,
			-- [5] = nWinFlag( int )	: maxsize = 4,
													-- szResultMessage	: maxsize = 32	=	1 * 32 * 1,
			[6] = 32,
													-- szExtra	: maxsize = 128	=	1 * 128 * 1,
			[7] = 128,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[8] = { maxlen = 8 },
			maxlen = 8
		},
		nameMap = {
			'nPlayerID',		-- [1] ( int )
			'szPlayerName',		-- [2] ( char )
			'szPortraitUrl',		-- [3] ( char )
			'nScore',		-- [4] ( int )
			'nWinFlag',		-- [5] ( int )
			'szResultMessage',		-- [6] ( char )
			'szExtra',		-- [7] ( char )
			'nReserved',		-- [8] ( int )
		},
		formatKey = '<iA2i2A2i8',
		deformatKey = '<iA128A256i2A32A128i8',
		maxsize = 588
	},

	CURRENCY_EXCHANGE={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nContainer( int )	: maxsize = 4,
			-- [3] = nCurrency( int )	: maxsize = 4,
			-- [4] = nExchangeGameID( int )	: maxsize = 4,
			-- [5] = llOperationID( long long )	: maxsize = 8,
			-- [6] = llBalance( long long )	: maxsize = 8,
			-- [7] = nOperateAmount( int )	: maxsize = 4,
			-- [8] = nCreateTime( int )	: maxsize = 4,
			-- [9] = dwFlags( unsigned long )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[10] = { maxlen = 8 },
			maxlen = 10
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nContainer',		-- [2] ( int )
			'nCurrency',		-- [3] ( int )
			'nExchangeGameID',		-- [4] ( int )
			'llOperationID',		-- [5] ( long long )
			'llBalance',		-- [6] ( long long )
			'nOperateAmount',		-- [7] ( int )
			'nCreateTime',		-- [8] ( int )
			'dwFlags',		-- [9] ( unsigned long )
			'nReserved',		-- [10] ( int )
		},
		formatKey = '<i4d2i2Li8',
		deformatKey = '<i4d2i2Li8',
		maxsize = 76
	},
	
	CURRENCY_EXCHANGE_EX={
		lengthMap = {
													-- currencyExchange	: 				maxsize = 76,
			[1] = { refered = 'CURRENCY_EXCHANGE', complexType = 'link_refer' },
			-- [2] = dwNotifyFlags( unsigned long )	: maxsize = 4,
			-- [3] = nEnterRoomID( int )	: maxsize = 4,
													-- nReserved	: maxsize = 64	=	4 * 16 * 1,
			[4] = { maxlen = 16 },
			maxlen = 4
		},
		nameMap = {
			'currencyExchange',		-- [1] ( refer )
			'dwNotifyFlags',		-- [2] ( unsigned long )
			'nEnterRoomID',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i4d2i2Li8Li17',
		deformatKey = '<i4d2i2Li8Li17',
		maxsize = 148
	},

    CHECK_NETWORK = {
        lengthMap = {
            [4] = {maxlen = 8},
            maxlen = 4
        },
        nameMap = {
            'nGameID',
            'nUserID',
            'dwIP',
            'nReserved'
        },
        formatKey = '<iiLi8',
        deformatKey = '<iiLi8',
        maxsize = 44
    },

	MAILSYS_NOTIFY={
		lengthMap = {
			-- [1] = nValue( int )	: maxsize = 4,
													-- szGameVers	: maxsize = 256	=	1 * 256 * 1,
			[2] = 256,
													-- nReserved	: maxsize = 40	=	4 * 10 * 1,
			[3] = { maxlen = 10 },
			maxlen = 3
		},
		nameMap = {
			'nValue',		-- [1] ( int )
			'szGameVers',		-- [2] ( char )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<iAi10',
		deformatKey = '<iA256i10',
		maxsize = 300
	},

	GET_USABLE_COUPON_LIST={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
			-- [3] = nSrcPlatID( int )	: maxsize = 4,
			-- [4] = nGameID( int )	: maxsize = 4,
													-- nGameCode	: maxsize = 16	=	1 * 16 * 1,
			[5] = 16,
			-- [6] = dwOwnBeginTime( unsigned long )	: maxsize = 4,
			-- [7] = dwOwnEndTime( unsigned long )	: maxsize = 4,
			-- [8] = nSortBy( int )	: maxsize = 4,
			-- [9] = nPageIndex( int )	: maxsize = 4,
			-- [10] = nPageSize( int )	: maxsize = 4,
			-- [11] = nHttpFlag( int )	: maxsize = 4,
			-- [12] = pHttpAck( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[13] = { maxlen = 8 },
			maxlen = 13
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szHardID',		-- [2] ( char )
			'nSrcPlatID',		-- [3] ( int )
			'nGameID',		-- [4] ( int )
			'nGameCode',		-- [5] ( char )
			'dwOwnBeginTime',		-- [6] ( unsigned long )
			'dwOwnEndTime',		-- [7] ( unsigned long )
			'nSortBy',		-- [8] ( int )
			'nPageIndex',		-- [9] ( int )
			'nPageSize',		-- [10] ( int )
			'nHttpFlag',		-- [11] ( int )
			'pHttpAck',		-- [12] ( int )
			'nReserved',		-- [13] ( int )
		},
		formatKey = '<iAi2AL2i13',
		deformatKey = '<iA32i2A16L2i13',
		maxsize = 120
	},
	GET_EXPIRED_COUPON_LIST={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
			-- [3] = nSrcPlatID( int )	: maxsize = 4,
			-- [4] = nGameID( int )	: maxsize = 4,
													-- nGameCode	: maxsize = 16	=	1 * 16 * 1,
			[5] = 16,
			-- [6] = nExpiredHowLong( int )	: maxsize = 4,
			-- [7] = nPageIndex( int )	: maxsize = 4,
			-- [8] = nPageSize( int )	: maxsize = 4,
			-- [9] = nHttpFlag( int )	: maxsize = 4,
			-- [10] = pHttpAck( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[11] = { maxlen = 8 },
			maxlen = 11
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szHardID',		-- [2] ( char )
			'nSrcPlatID',		-- [3] ( int )
			'nGameID',		-- [4] ( int )
			'nGameCode',		-- [5] ( char )
			'nExpiredHowLong',		-- [6] ( int )
			'nPageIndex',		-- [7] ( int )
			'nPageSize',		-- [8] ( int )
			'nHttpFlag',		-- [9] ( int )
			'pHttpAck',		-- [10] ( int )
			'nReserved',		-- [11] ( int )
		},
		formatKey = '<iAi2Ai13',
		deformatKey = '<iA32i2A16i13',
		maxsize = 112
	},
	GET_USED_COUPON_LIST={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
			-- [3] = nSrcPlatID( int )	: maxsize = 4,
			-- [4] = nGameID( int )	: maxsize = 4,
													-- nGameCode	: maxsize = 16	=	1 * 16 * 1,
			[5] = 16,
			-- [6] = nUsedHowLong( int )	: maxsize = 4,
			-- [7] = nPageIndex( int )	: maxsize = 4,
			-- [8] = nPageSize( int )	: maxsize = 4,
			-- [9] = nHttpFlag( int )	: maxsize = 4,
			-- [10] = pHttpAck( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[11] = { maxlen = 8 },
			maxlen = 11
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szHardID',		-- [2] ( char )
			'nSrcPlatID',		-- [3] ( int )
			'nGameID',		-- [4] ( int )
			'nGameCode',		-- [5] ( int )
			'nUsedHowLong',		-- [6] ( int )
			'nPageIndex',		-- [7] ( int )
			'nPageSize',		-- [8] ( int )
			'nHttpFlag',		-- [9] ( int )
			'pHttpAck',		-- [10] ( int )
			'nReserved',		-- [11] ( int )
		},
		formatKey = '<iAi2Ai13',
		deformatKey = '<iA32i2A16i13',
		maxsize = 112
	},
	LOGON_USER_V2={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nHallSvrID( int )	: maxsize = 4,
			-- [3] = nAgentGroupID( int )	: maxsize = 4,
			-- [4] = dwIPAddr( unsigned long )	: maxsize = 4,
			-- [5] = dwLogonFlags( unsigned long )	: maxsize = 4,
			-- [6] = lTokenID( long )	: maxsize = 4,
													-- szUsername	: maxsize = 32	=	1 * 32 * 1,
			[7] = 32,
													-- szPassword	: maxsize = 32	=	1 * 32 * 1,
			[8] = 32,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[9] = 32,
													-- szVolumeID	: maxsize = 32	=	1 * 32 * 1,
			[10] = 32,
													-- szMachineID	: maxsize = 32	=	1 * 32 * 1,
			[11] = 32,
													-- szHashPwd	: maxsize = 36	=	1 * 36 * 1,
			[12] = 36,
													-- szRndKey	: maxsize = 16	=	1 * 16 * 1,
			[13] = 16,
			-- [14] = dwSysVer( unsigned long )	: maxsize = 4,
			-- [15] = nLogonSvrID( int )	: maxsize = 4,
			-- [16] = nHallBuildNO( int )	: maxsize = 4,
			-- [17] = nHallNetDelay( int )	: maxsize = 4,
			-- [18] = nHallRunCount( int )	: maxsize = 4,
			-- [19] = nGameID( int )	: maxsize = 4,
			-- [20] = dwGameVer( unsigned long )	: maxsize = 4,
			-- [21] = nRecommenderID( int )	: maxsize = 4,
			-- [22] = nChannelID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 8	=	1 * 8 * 1,
			[23] = 8,
													-- nReserved	: maxsize = 24	=	4 * 6 * 1,
			[24] = { maxlen = 6 },
			maxlen = 24
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nHallSvrID',		-- [2] ( int )
			'nAgentGroupID',		-- [3] ( int )
			'dwIPAddr',		-- [4] ( unsigned long )
			'dwLogonFlags',		-- [5] ( unsigned long )
			'lTokenID',		-- [6] ( long )
			'szUsername',		-- [7] ( char )
			'szPassword',		-- [8] ( char )
			'szHardID',		-- [9] ( char )
			'szVolumeID',		-- [10] ( char )
			'szMachineID',		-- [11] ( char )
			'szHashPwd',		-- [12] ( char )
			'szRndKey',		-- [13] ( char )
			'dwSysVer',		-- [14] ( unsigned long )
			'nLogonSvrID',		-- [15] ( int )
			'nHallBuildNO',		-- [16] ( int )
			'nHallNetDelay',		-- [17] ( int )
			'nHallRunCount',		-- [18] ( int )
			'nGameID',		-- [19] ( int )
			'dwGameVer',		-- [20] ( unsigned long )
			'nRecommenderID',		-- [21] ( int )
			'nChannelID',		-- [22] ( int )
			'szGameCode',		-- [23] ( char )
			'nReserved',		-- [24] ( int )
		},
		formatKey = '<i3L2lA7Li5Li2Ai6',
		deformatKey = '<i3L2lA32A32A32A32A32A36A16Li5Li2A8i6',
		maxsize = 304
	},
	LOGON_SUCCEED_V2={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nNickSex( int )	: maxsize = 4,
			-- [3] = nPortrait( int )	: maxsize = 4,
			-- [4] = nUserType( int )	: maxsize = 4,
			-- [5] = nClothingID( int )	: maxsize = 4,
			-- [6] = nRegisterGroup( int )	: maxsize = 4,
			-- [7] = nDownloadGroup( int )	: maxsize = 4,
			-- [8] = nAgentGroupID( int )	: maxsize = 4,
			-- [9] = nExpiration( int )	: maxsize = 4,
			-- [10] = nMemberLevel( int )	: maxsize = 4,
			-- [11] = nHallID( int )	: maxsize = 4,
													-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[12] = 32,
													-- szNickName	: maxsize = 32	=	1 * 32 * 1,
			[13] = 32,
													-- szUniqueID	: maxsize = 32	=	1 * 32 * 1,
			[14] = 32,
													-- szIMToken	: maxsize = 16	=	1 * 16 * 1,
			[15] = 16,
													-- szIDCard	: maxsize = 32	=	1 * 32 * 1,
			[16] = 32,
			maxlen = 16
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nNickSex',		-- [2] ( int )
			'nPortrait',		-- [3] ( int )
			'nUserType',		-- [4] ( int )
			'nClothingID',		-- [5] ( int )
			'nRegisterGroup',		-- [6] ( int )
			'nDownloadGroup',		-- [7] ( int )
			'nAgentGroupID',		-- [8] ( int )
			'nExpiration',		-- [9] ( int )
			'nMemberLevel',		-- [10] ( int )
			'nHallID',		-- [11] ( int )
			'szUserName',		-- [12] ( char )
			'szNickName',		-- [13] ( char )
			'szUniqueID',		-- [14] ( char )
			'szIMToken',		-- [15] ( char )
			'szIDCard',		-- [16] ( char )
		},
		formatKey = '<i11A5',
		deformatKey = '<i11A32A32A32A16A32',
		maxsize = 188
	},
	--旁观
    GR_GET_LOOKON={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nRoomID( int )	: maxsize = 4,
			-- [3] = nAreaID( int )	: maxsize = 4,
			-- [4] = nGameID( int )	: maxsize = 4,
			-- [5] = nTableNO( int )	: maxsize = 4,
			-- [6] = nChairNO( int )	: maxsize = 4,
													-- szPassword	: maxsize = 32	=	1 * 32 * 1,
			[7] = 32,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[8] = 32,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[9] = { maxlen = 8 },
			maxlen = 9
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRoomID',		-- [2] ( int )
			'nAreaID',		-- [3] ( int )
			'nGameID',		-- [4] ( int )
			'nTableNO',		-- [5] ( int )
			'nChairNO',		-- [6] ( int )
			'szPassword',		-- [7] ( char )
			'szHardID',		-- [8] ( char )
			'nReserved',		-- [9] ( int )
		},
		formatKey = '<i6A2i8',
		deformatKey = '<i6A32A32i8',
		maxsize = 120
	},
	
	UR_SOCKET_CONFIG = {
		lengthMap = {
			maxlen = 1
		},
		nameMap = {
			'dwConfig'
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
	},

    --竞技场
    ARENA_ACK_GIVEUP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nMatchID( int )	: maxsize = 4,
			-- [3] = nError( int )	: maxsize = 4,
                                                	-- szDes	: maxsize = 64	=	1 * 64 * 1,
			[4] = 64,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[5] = { maxlen = 8 },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nMatchID',		-- [2] ( int )
			'nError',		-- [3] ( int )
			'szDes',		-- [4] ( char )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i3Ai8',
		deformatKey = '<i3A64i8',
		maxsize = 108
	},
	
	ARENA_ACK_RANK={
		lengthMap = {
			-- [1] = nRankType( int )	: maxsize = 4,
			-- [2] = nListCount( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nRankType',		-- [1] ( int )
			'nListCount',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},



    ARENA_ACK_SIGNUP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nMatchID( int )	: maxsize = 4,
			-- [3] = nError( int )	: maxsize = 4,
													-- szDes	: maxsize = 64	=	1 * 64 * 1,
			[5] = 64,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[6] = { maxlen = 8 },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
            'nGameID',
			'nMatchID',		-- [2] ( int )
			'nError',		-- [3] ( int )
			'szDes',		-- [4] ( char )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i4Ai8',
		deformatKey = '<i4A64i8',
		maxsize = 112
	},
	
	ARENA_ACK_TICKET={
		lengthMap = {
			-- [1] = nTicketTypeCount( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[2] = { maxlen = 8 },
			maxlen = 2
		},
		nameMap = {
			'nTicketTypeCount',		-- [1] ( int )
			'nReserved',		-- [2] ( int )
		},
		formatKey = '<i9',
		deformatKey = '<i9',
		maxsize = 36
	},

    ARENA_AWARD_INFO={
		lengthMap = {
			-- [1] = nMatchScore( int )	: maxsize = 4,
			-- [2] = nAwardNumber( int )	: maxsize = 4,
													-- awardType	: maxsize = 64	=	8 * 8 * 1,
			[3] = { maxlen = 8, refered = 'ARENA_AWARD_TYPE', complexType = 'link_refer' },
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
			maxlen = 4
		},
		nameMap = {
			'nMatchScore',		-- [1] ( int )
			'nAwardNumber',		-- [2] ( int )
			'awardType',		-- [3] ( refer )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i26',
		deformatKey = '<i26',
		maxsize = 104
	},
	
	ARENA_AWARD_TYPE={
		lengthMap = {
			-- [1] = nType( int )	: maxsize = 4,
			-- [2] = nCount( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nType',		-- [1] ( int )
			'nCount',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
	},
	
	ARENA_CONFIG={
		lengthMap = {
			-- [1] = nInitHP( int )	: maxsize = 4,
			-- [2] = nMatchID( int )	: maxsize = 4,
													-- szMatchName	: maxsize = 64	=	1 * 64 * 1,
			[3] = 64,
			-- [4] = uStartTime( unsigned int )	: maxsize = 4,
			-- [5] = uEndTime( unsigned int )	: maxsize = 4,
			-- [6] = nMatchType( int )	: maxsize = 4,
			-- [7] = nSignUpPayType( int )	: maxsize = 4,
			-- [8] = nSilverNum( int )	: maxsize = 4,
			-- [9] = nTicketID( int )	: maxsize = 4,
			-- [10] = nTicketNum( int )	: maxsize = 4,
													-- szTicketName	: maxsize = 32	=	1 * 32 * 1,
			[11] = 32,
			-- [12] = nMinDeposit( int )	: maxsize = 4,
			-- [13] = nMinScore( int )	: maxsize = 4,
			-- [14] = nMaxSignUpDaily( int )	: maxsize = 4,
			-- [15] = IsForceQuit( int )	: maxsize = 4,
			-- [16] = nAwardInfoNumber( int )	: maxsize = 4,
													-- awardInfo	: maxsize = 832	=	104 * 8 * 1,
			[17] = { maxlen = 8, refered = 'ARENA_AWARD_INFO', complexType = 'link_refer' },
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[18] = { maxlen = 8 },
			maxlen = 18
		},
		nameMap = {
			'nInitHP',		-- [1] ( int )
			'nMatchID',		-- [2] ( int )
			'szMatchName',		-- [3] ( char )
			'uStartTime',		-- [4] ( unsigned int )
			'uEndTime',		-- [5] ( unsigned int )
			'nMatchType',		-- [6] ( int )
			'nSignUpPayType',		-- [7] ( int )
			'nSilverNum',		-- [8] ( int )
			'nTicketID',		-- [9] ( int )
			'nTicketNum',		-- [10] ( int )
			'szTicketName',		-- [11] ( char )
			'nMinDeposit',		-- [12] ( int )
			'nMinScore',		-- [13] ( int )
			'nMaxSignUpDaily',		-- [14] ( int )
			'IsForceQuit',		-- [15] ( int )
			'nAwardInfoNumber',		-- [16] ( int )
			'awardInfo',		-- [17] ( refer )
			'nReserved',		-- [18] ( int )
		},
		formatKey = '<i2AI2i5Ai221',
		deformatKey = '<i2A64I2i5A32i221',
		maxsize = 1016
	},
	
	ARENA_CONFIG_HEAD={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nMatchNum( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nMatchNum',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i11',
		deformatKey = '<i11',
		maxsize = 44
	},
	
	ARENA_RANK={
		lengthMap = {
			-- [1] = nRank( int )	: maxsize = 4,
			-- [2] = nRankType( int )	: maxsize = 4,
			-- [3] = nAchievement( int )	: maxsize = 4,
			-- [4] = nUserID( int )	: maxsize = 4,
                                                	-- szUserName	: maxsize = 32	=	1 * 32 * 1,
			[5] = 32,
			-- [6] = nNickSex( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[7] = { maxlen = 8 },
			maxlen = 7
		},
		nameMap = {
			'nRank',		-- [1] ( int )
			'nRankType',		-- [2] ( int )
			'nAchievement',		-- [3] ( int )
			'nUserID',		-- [4] ( int )
			'szUserName',		-- [5] ( char )
			'nNickSex',		-- [6] ( int )
			'nReserved',		-- [7] ( int )
		},
		formatKey = '<i4Ai9',
		deformatKey = '<i4A32i9',
		maxsize = 84
	},
	
	ARENA_REQ_GIVEUP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nMatchID( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
            'nGameID',
			'nMatchID',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i11',
		deformatKey = '<i11',
		maxsize = 44
	},
	
	ARENA_REQ_MY_RANK={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nRankType( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nRankType',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i11',
		deformatKey = '<i11',
		maxsize = 44
	},

	ARENA_USER_RANK={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nUserRank( int )	: maxsize = 4,
			-- [4] = nIsNewArenaPlayer( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 16	=	4 * 4 * 1,
			[5] = { maxlen = 4 },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nUserRank',		-- [3] ( int )
			'nIsNewArenaPlayer',		-- [4] ( int )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i8',
		deformatKey = '<i8',
		maxsize = 32
	},
	
	ARENA_REQ_RANK={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nRankType( int )	: maxsize = 4,
			-- [4] = nTargetRank( int )	: maxsize = 4,
			-- [5] = nRange( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[6] = { maxlen = 8 },
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nRankType',		-- [3] ( int )
			'nTargetRank',		-- [4] ( int )
			'nRange',		-- [5] ( int )
			'nReserved',		-- [6] ( int )
		},
		formatKey = '<i13',
		deformatKey = '<i13',
		maxsize = 52
	},
	
	ARENA_REQ_SIGNUP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nMatchID( int )	: maxsize = 4,
                                                	-- szName	: maxsize = 32	=	1 * 32 * 1,
			[4] = 32,
			-- [5] = nNickSex( int )	: maxsize = 4,
			-- [6] = nSignUpPayType( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[7] = { maxlen = 8 },
			maxlen = 7
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nMatchID',		-- [3] ( int )
			'szName',		-- [4] ( char )
			'nNickSex',		-- [5] ( int )
			'nSignUpPayType',		-- [6] ( int )
			'nReserved',		-- [7] ( int )
		},
		formatKey = '<i3Ai10',
		deformatKey = '<i3A32i10',
		maxsize = 84
	},
	
	ARENA_REQ_TICKET={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	
	ARENA_TICKET={
		lengthMap = {
			-- [1] = nTicketID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nMatchType( int )	: maxsize = 4,
                                                	-- szTicketName	: maxsize = 32	=	1 * 32 * 1,
			[4] = 32,
                                                	-- szGameName	: maxsize = 32	=	1 * 32 * 1,
			[5] = 32,
			-- [6] = nUserID( int )	: maxsize = 4,
			-- [7] = nTicketCount( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[8] = { maxlen = 8 },
			maxlen = 8
		},
		nameMap = {
			'nTicketID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nMatchType',		-- [3] ( int )
			'szTicketName',		-- [4] ( char )
			'szGameName',		-- [5] ( char )
			'nUserID',		-- [6] ( int )
			'nTicketCount',		-- [7] ( int )
			'nReserved',		-- [8] ( int )
		},
		formatKey = '<i3A2i10',
		deformatKey = '<i3A32A32i10',
		maxsize = 116
	},
	
	GET_ARENA_CONFIG={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 8	=	1 * 8 * 1,
			[3] = 8,
													-- nReserved	: maxsize = 24	=	4 * 6 * 1,
			[4] = { maxlen = 6 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'szGameCode',		-- [3] ( char )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i2Ai6',
		deformatKey = '<i2A8i6',
		maxsize = 40
	},
	
	GET_MY_ARENA_DETAIL={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	
	MY_ARENA_DETAIL={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nMatchID( int )	: maxsize = 4,
			-- [3] = nGameID( int )	: maxsize = 4,
			-- [4] = nDaySignUpCount( int )	: maxsize = 4,
			-- [5] = nHP( int )	: maxsize = 4,
			-- [6] = naddition( int )	: maxsize = 4,
			-- [7] = nBout( int )	: maxsize = 4,
			-- [8] = nStreaking( int )	: maxsize = 4,
			-- [9] = nTopStreaking( int )	: maxsize = 4,
			-- [10] = nWinBout( int )	: maxsize = 4,
			-- [11] = nMatchScore( int )	: maxsize = 4,
			-- [12] = nLevel( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[14] = { maxlen = 8 },
			maxlen = 14
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nMatchID',		-- [2] ( int )
			'nGameID',		-- [3] ( int )
			'nDaySignUpCount',		-- [4] ( int )
			'nHP',		-- [5] ( int )
			'nAddition',		-- [6] ( int )
			'nBout',		-- [7] ( int )
			'nStreaking',		-- [8] ( int )
			'nTopStreaking',		-- [9] ( int )
			'nWinBout',		-- [10] ( int )
			'nMatchScore',		-- [11] ( int )
			'nLevel',		-- [12] ( int )
            'nMatchStatus',
			'nReserved',		-- [13] ( int )
		},
		formatKey = '<i21',
		deformatKey = '<i21',
		maxsize = 84
	},

    ARENA_ONE_CONFIG={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nMatchID( int )	: maxsize = 4,
			-- [4] = nMatchSignUpDaily( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[5] = { maxlen = 8 },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nMatchID',		-- [3] ( int )
			'nMatchSignUpDaily',		-- [4] ( int )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i12',
		deformatKey = '<i12',
		maxsize = 48
	},
	
	ARENA_ONE_CONFIGREQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nMatchID( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nMatchID',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i11',
		deformatKey = '<i11',
		maxsize = 44
	},

	MY_ARENA_HONOR_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},

	MY_ARENA_HONOR={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
			-- [3] = nHistroyMaxScore( int )	: maxsize = 4,
                                                	-- nReserved	: maxsize = 80	=	4 * 20 * 1,
			[4] = { maxlen = 20 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nHistroyMaxScore',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i23',
		deformatKey = '<i23',
		maxsize = 92
	},

	-- 移动端选桌begin
	XZ_TABLE_HEAD={
        lengthMap = {
            [10] = {maxlen = 1},
            maxlen = 10
        },
        nameMap = {
            'nTableNO',
            'nStatus',
            'nPlayerCount',
            'nVisitorCount',
            'bHavePassword',
            'nFirstSeatedPlayer',
            'nMinScore',
            'nMinDeposit',
            'nTableDeposit',
            'nReserved'
        },
        formatKey = '<iiiiiiiiii',
        deformatKey = '<iiiiiiiiii',
        maxsize = 40
    },

    XZ_PLAYER_POS = {
        lengthMap = {
            maxlen = 2
        },
        nameMap = {
            'nChairNO',
            'nUserID'
        },
        formatKey = '<ii',
        deformatKey = '<ii',
        maxsize = 8
    },

    XZ_VISITOR_POS = {
        lengthMap = {
            maxlen = 2
        },
        nameMap = {
            'nChairNO',
            'nUserID'
        },
        formatKey = '<ii',
        deformatKey = '<ii',
        maxsize = 8
    },

    GR_GET_SEATED = {
        lengthMap = {
            [7] = 32,
            [13] = 32,
            [17] = {maxlen = 1},
            maxlen = 17
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nAreaID',
            'nGameID',
            'nTableNO',
            'nChairNO',
            'szPassword',
            'nIPConfig',
            'nBreakReq',
            'nSpeedReq',
            'nMinScore',
            'nMinDeposit',
            'szHardID',
            'nWaitSeconds',
            'nNetDelay',
            'nQuanID',
            'nReserved'
        },
        formatKey = '<iiiiiiAiiiiiAiiii',
        deformatKey = '<iiiiiiA32iiiiiA32iiii',
        maxsize = 124
    },

    MR_GET_SEATED_AND_START = {
        lengthMap = {
            [7] = 32,
            [15] = 32,
            [19] = {maxlen = 4},
            maxlen = 19
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nAreaID',
            'nGameID',
            'nTableNO',
            'nChairNO',
            'szPassword',
            'nIPConfig',
            'nBreakReq',
            'nSpeedReq',
            'nMinScore',
            'nMinDeposit',
            'nAllowLookon',
            'nWinRate',
            'szHardID',
            'nWaitSeconds',
            'nNetDelay',
            'dwGetFlags',
            'nReserved'
        },
        formatKey = '<iiiiiiAiiiiiiiAiiii4',
        deformatKey = '<iiiiiiA32iiiiiiiA32iiii4',
        maxsize = 144
    },

    MR_GET_NEWTABLE_EX = {
        lengthMap = {
            [7] = 32,
            [15] = 32,
            [19] = {maxlen = 4},
            maxlen = 19
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nAreaID',
            'nGameID',
            'nTableNO',
            'nChairNO',
            'szPassword',
            'nIPConfig',
            'nBreakReq',
            'nSpeedReq',
            'nMinScore',
            'nMinDeposit',
            'nAllowLookon',
            'nWinRate',
            'szHardID',
            'nWaitSeconds',
            'nNetDelay',
            'dwGetFlags',
            'nReserved'
        },
        formatKey = '<iiiiiiAiiiiiiiAiiii4',
        deformatKey = '<iiiiiiA32iiiiiiiA32iiii4',
        maxsize = 144
    },

    GR_GET_UNSEATED = {
        lengthMap = {
            [7] = 32,
            [12] = {maxlen = 2},
            maxlen = 12
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nAreaID',
            'nGameID',
            'nTableNO',
            'nChairNO',
            'szHardID',
            'nWaitSeconds',
            'nNetDelay',
            'nDeposit',
            'nQuanID',
            'nReserved'
        },
        formatKey = '<iiiiiiAiiiii2',
        deformatKey = '<iiiiiiA32iiiii2',
        maxsize = 80
	},
	
    GR_GET_STARTED = {
        lengthMap = {
            [7] = 32,
            [12] = {maxlen = 2},
            maxlen = 12
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nAreaID',
            'nGameID',
            'nTableNO',
            'nChairNO',
            'szHardID',
            'nWaitSeconds',
            'nNetDelay',
            'nDeposit',
            'nQuanID',
            'nReserved'
        },
        formatKey = '<iiiiiiAiiiii2',
        deformatKey = '<iiiiiiA32iiiii2',
        maxsize = 80
	},
    
    MR_XZ_RESUME = {
        lengthMap = {
            [4] = 32,
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nAppID',
            'szHardID',
            'nReserved'
        },
        formatKey = '<iiiAi',
        deformatKey = '<iiiA32i4',
        maxsize = 60
    },

    MR_GET_ROOM_INFO = {
        lengthMap = {
            [4] = 32,
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nAppID',
            'szHardID',
            'nReserved'
        },
        formatKey = '<iiiAi',
        deformatKey = '<iiiA32i4',
        maxsize = 60
    },    
	-- 移动端选桌end
}

MCSocketDataStruct.MR_ASK_ENTER_TEAMROOM = MCSocketDataStruct.MR_ASK_ENTER_PRIVATEROOM 
MCSocketDataStruct.MR_QUERY_DXXW_INFO    = MCSocketDataStruct.GET_USER_DXXW_INFO
MCSocketDataStruct.MR_GET_WEBSIGN        = MCSocketDataStruct.GET_WEBSIGN
MCSocketDataStruct.MR_GET_ROOM           = MCSocketDataStruct.GET_ROOM
MCSocketDataStruct.MR_GET_YQWROOMINFO    = MCSocketDataStruct.GET_YQWROOMINFO_REQ
MCSocketDataStruct.MR_GET_YQWPLAYERINFO  = MCSocketDataStruct.GET_YQWPLAYERINFO_REQ
MCSocketDataStruct.MR_YQW_JOIN_ROOM      = MCSocketDataStruct.YQW_JOIN_ROOM
MCSocketDataStruct.MR_YQW_ALLOC_ROOM     = MCSocketDataStruct.YQW_ALLOC_ROOM
MCSocketDataStruct.MR_YQW_GET_HAPPY_COIN = MCSocketDataStruct.YQW_GET_HAPPY_COIN
MCSocketDataStruct.MR_YQW_DON_HAPPY_COIN = MCSocketDataStruct.YQW_DON_HAPPY_COIN
MCSocketDataStruct.MR_GET_YQWROUNDWIN    = MCSocketDataStruct.GET_YQWROUNDBILL_REQ
MCSocketDataStruct.MR_GET_YQWGAMEWIN     = MCSocketDataStruct.GET_YQWGAMEBILL_REQ
MCSocketDataStruct.MR_LOGON_USER_V2		 = MCSocketDataStruct.LOGON_USER_V2
MCSocketDataStruct.GR_LOGON_SUCCEEDED_V2 = MCSocketDataStruct.LOGON_SUCCEED_V2

--竞技场
MCSocketDataStruct.MR_GET_ARENA_CONFIG      = MCSocketDataStruct.GET_ARENA_CONFIG
MCSocketDataStruct.MR_GET_MY_ARENA_DETAIL   = MCSocketDataStruct.GET_MY_ARENA_DETAIL
MCSocketDataStruct.MR_ARENA_REQ_SIGNUP      = MCSocketDataStruct.ARENA_REQ_SIGNUP
MCSocketDataStruct.MR_ARENA_REQ_GIVEUP      = MCSocketDataStruct.ARENA_REQ_GIVEUP
MCSocketDataStruct.MR_ARENA_REQ_RANK        = MCSocketDataStruct.ARENA_REQ_RANK
MCSocketDataStruct.MR_ARENA_REQ_MY_RANK     = MCSocketDataStruct.ARENA_REQ_MY_RANK
MCSocketDataStruct.MR_ARENA_REQ_TICKET      = MCSocketDataStruct.ARENA_REQ_TICKET
MCSocketDataStruct.MR_GET_ONE_ARENA_CONFIG  = MCSocketDataStruct.ARENA_ONE_CONFIGREQ
MCSocketDataStruct.MR_GET_MY_ARENA_HONOR    = MCSocketDataStruct.MY_ARENA_HONOR_REQ

table.merge(MCSocketDataStruct, import("src.app.GameHall.models.mcsocket.MCSocketDataStructClub"))
cc.load('treepack').resolveReference(MCSocketDataStruct)

local HallRequestIdReflact={}
for k,v in pairs(RequestIdList.hall) do
	HallRequestIdReflact[v]=k
end

local RoomRequestIdReflact={}
for k,v in pairs(RequestIdList.room) do
	RoomRequestIdReflact[v]=k
end

local function getExchMap(id, structFolder)

	if structFolder == 'hall' then
		local structName = HallRequestIdReflact[id]
		local exchangeMap = MCSocketDataStruct[structName]
		return exchangeMap, structFolder, structName
	elseif structFolder == 'room' then
		local structName = RoomRequestIdReflact[id]
		local exchangeMap = MCSocketDataStruct[structName]
		return exchangeMap, structFolder, structName
	elseif structFolder == 'respond' then
		local structName = RespondIdReflact[id]
		local exchangeMap = MCSocketDataStruct[structName]
		return exchangeMap, structFolder, structName
	else 
		local name=HallRequestIdReflact[id]
		local type='hall'

		if(name==nil)then
			name=RoomRequestIdReflact[id]
			type='room'
		end

		if(name==nil)then
			name=RequestIdList.RespondIdReflact[id]
			type='respond'
		end

		local exchMap=MCSocketDataStruct[name]
		return exchMap,type,name
	end
end

return {
	getExchMap = getExchMap,
	MCSocketDataStruct = MCSocketDataStruct,
}

