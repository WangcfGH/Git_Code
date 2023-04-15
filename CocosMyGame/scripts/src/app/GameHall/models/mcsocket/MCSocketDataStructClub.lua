local RequestInfoList = {
	CLUB_APPLY_EXITCLUB_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nClubNO( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nClubNO',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	
	CLUB_APPLY_JOINCLUB_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nClubNO( int )	: maxsize = 4,
			-- [3] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[4] = 16,
													-- nReserved	: maxsize = 28	=	4 * 7 * 1,
			[5] = { maxlen = 7 },
			-- [6] = nRemarkLength( int )	: maxsize = 4,
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nClubNO',		-- [2] ( int )
			'nGameID',		-- [3] ( int )
			'szGameCode',		-- [4] ( char )
			'nReserved',		-- [5] ( int )
			'nRemarkLength',		-- [6] ( int )
		},
		formatKey = '<i3Ai8',
		deformatKey = '<i3A16i8',
		maxsize = 60
	},
	
	CLUB_CLIENT_CREATEROOM_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nClubNO( int )	: maxsize = 4,
			-- [3] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[4] = 16,
			-- [5] = nRoomType( int )	: maxsize = 4,
			-- [6] = nAmount( int )	: maxsize = 4,
			-- [7] = nPayType( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[8] = { maxlen = 8 },
			-- [9] = nRuleLength( int )	: maxsize = 4,
			maxlen = 9
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nClubNO',		-- [2] ( int )
			'nGameID',		-- [3] ( int )
			'szGameCode',		-- [4] ( char )
			'nRoomType',		-- [5] ( int )
			'nAmount',		-- [6] ( int )
			'nPayType',		-- [7] ( int )
			'nReserved',		-- [8] ( int )
			'nRuleLength',		-- [9] ( int )
		},
		formatKey = '<i3Ai12',
		deformatKey = '<i3A16i12',
		maxsize = 76
	},
	
	CLUB_CLIENT_CREATEROOM_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nClubNO( int )	: maxsize = 4,
													-- stYQWRoomInfo	: 				maxsize = 48,
			[3] = { refered = 'CLUB_YQWROOMINFO', complexType = 'link_refer' },
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nClubNO',		-- [2] ( int )
			'stYQWRoomInfo',		-- [3] ( refer )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i22',
		deformatKey = '<i22',
		maxsize = 88
	},
	
	CLUB_CLUBGAME={
		lengthMap = {
			-- [1] = nClubNO( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[3] = 16,
													-- szGameName	: maxsize = 64	=	1 * 64 * 1,
			[4] = 64,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[5] = { maxlen = 8 },
			maxlen = 5
		},
		nameMap = {
			'nClubNO',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'szGameCode',		-- [3] ( char )
			'szGameName',		-- [4] ( char )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i2A2i8',
		deformatKey = '<i2A16A64i8',
		maxsize = 120
	},

	CLUB_CLUBINFO={
		lengthMap = {
			-- [1] = nClubNO( int )	: maxsize = 4,
			-- [2] = nOwnerID( int )	: maxsize = 4,
													-- szClubName	: maxsize = 128	=	1 * 128 * 1,
			[3] = 128,
													-- szClubPost	: maxsize = 512	=	1 * 512 * 1,
			[4] = 512,
													-- szUrl	: maxsize = 260	=	1 * 260 * 1,
			[5] = 260,
			-- [6] = nMaxPlayers( int )	: maxsize = 4,
			-- [7] = nPlayerCount( int )	: maxsize = 4,
			-- [8] = nAllowPlayerCreateRoom( int )	: maxsize = 4,
													-- nReserved	: maxsize = 28	=	4 * 7 * 1,
			[10] = { maxlen = 6 },
			maxlen = 9
		},
		nameMap = {
			'nClubNO',		-- [1] ( int )
			'nOwnerID',		-- [2] ( int )
			'szClubName',		-- [3] ( char )
			'szClubPost',		-- [4] ( char )
			'szUrl',		-- [5] ( char )
			'nMaxPlayers',		-- [6] ( int )
			'nPlayerCount',		-- [7] ( int )
			'nAllowPlayerCreateRoom',		-- [8] ( int )
                        'dwConfig', -- [9] ( unsigned long )
			'nReserved',		-- [10] ( int )
		},
		formatKey = '<i2A3i3Li6',
		deformatKey = '<i2A128A512A260i3Li6',
		maxsize = 948
	},
	
	CLUB_CLUBPEDIT_NTF={
		lengthMap = {
													-- stClubInfo	: 				maxsize = 948,
			[1] = { refered = 'CLUB_CLUBINFO', complexType = 'link_refer' },
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[2] = { maxlen = 8 },
			maxlen = 2
		},
		nameMap = {
			'stClubInfo',		-- [1] ( refer )
			'nReserved',		-- [2] ( int )
		},
		formatKey = '<i2A3i18',
		deformatKey = '<i2A128A512A260i18',
		maxsize = 980
	},
	
	CLUB_CLUBPLAYER_STATUS_NTF={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nClubNO( int )	: maxsize = 4,
			-- [3] = nStatus( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
													-- stPlayerInfo	: 				maxsize = 724,
			[5] = { refered = 'CLUB_PLAYERINFO', complexType = 'link_refer' },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nClubNO',		-- [2] ( int )
			'nStatus',		-- [3] ( int )
			'nReserved',		-- [4] ( int )
			'stPlayerInfo',		-- [5] ( refer )
		},
		formatKey = '<i12LA4i3A2i11',
		deformatKey = '<i12LA128A260A64A128i3A16A64i11',
		maxsize = 768
	},
	
	CLUB_ENTERCLUB_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nClubNO( int )	: maxsize = 4,
			-- [3] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[4] = 16,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[5] = { maxlen = 8 },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nClubNO',		-- [2] ( int )
			'nGameID',		-- [3] ( int )
			'szGameCode',		-- [4] ( char )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i3Ai8',
		deformatKey = '<i3A16i8',
		maxsize = 60
	},
	
	CLUB_GET_ALLINFO_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nClubID( int )	: maxsize = 4,
			-- [3] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[4] = 16,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[5] = { maxlen = 8 },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nClubID',		-- [2] ( int )
			'nGameID',		-- [3] ( int )
			'szGameCode',		-- [4] ( char )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i3Ai8',
		deformatKey = '<i3A16i8',
		maxsize = 60
	},
	
	CLUB_GET_ALLINFO_RESP={
		lengthMap = {
													-- stClubInfo	: 				maxsize = 948,
			[1] = { refered = 'CLUB_CLUBINFO', complexType = 'link_refer' },
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[2] = { maxlen = 8 },
			maxlen = 2
		},
		nameMap = {
			'stClubInfo',		-- [1] ( refer )
			'nReserved',		-- [2] ( int )
		},
		formatKey = '<i2A3i18',
		deformatKey = '<i2A128A512A260i18',
		maxsize = 980
	},
	
	CLUB_GET_CLUBLIST_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[3] = 16,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[4] = { maxlen = 8 },
			maxlen = 4
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'szGameCode',		-- [3] ( char )
			'nReserved',		-- [4] ( int )
		},
		formatKey = '<i2Ai8',
		deformatKey = '<i2A16i8',
		maxsize = 56
	},
	
	CLUB_GET_CLUBLIST_RESP={
		lengthMap = {
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[1] = { maxlen = 8 },
			maxlen = 1
		},
		nameMap = {
			'nReserved',		-- [1] ( int )
		},
		formatKey = '<i8',
		deformatKey = '<i8',
		maxsize = 32
	},
	
	CLUB_GET_PLAYERMSGS_RESP={
		lengthMap = {
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[1] = { maxlen = 8 },
			maxlen = 1
		},
		nameMap = {
			'nReserved',		-- [1] ( int )
		},
		formatKey = '<i8',
		deformatKey = '<i8',
		maxsize = 32
	},
	
	CLUB_GET_PLAYERMSG_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[2] = { maxlen = 8 },
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nReserved',		-- [2] ( int )
		},
		formatKey = '<i9',
		deformatKey = '<i9',
		maxsize = 36
	},
	
	CLUB_LOGOFF_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[2] = { maxlen = 8 },
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nReserved',		-- [2] ( int )
		},
		formatKey = '<i9',
		deformatKey = '<i9',
		maxsize = 36
	},
	
	CLUB_LOGON_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = dwIP( unsigned long )	: maxsize = 4,
													-- szNickName	: maxsize = 128	=	1 * 128 * 1,
			[3] = 128,
													-- szPortrait	: maxsize = 260	=	1 * 260 * 1,
			[4] = 260,
													-- szLbsInfo	: maxsize = 64	=	1 * 64 * 1,
			[5] = 64,
													-- szLbsArea	: maxsize = 128	=	1 * 128 * 1,
			[6] = 128,
			-- [7] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[8] = 16,
													-- szGameName	: maxsize = 64	=	1 * 64 * 1,
			[9] = 64,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[10] = { maxlen = 8 },
			maxlen = 10
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'dwIP',		-- [2] ( unsigned long )
			'szNickName',		-- [3] ( char )
			'szPortrait',		-- [4] ( char )
			'szLbsInfo',		-- [5] ( char )
			'szLbsArea',		-- [6] ( char )
			'nGameID',		-- [7] ( int )
			'szGameCode',		-- [8] ( char )
			'szGameName',		-- [9] ( char )
			'nReserved',		-- [10] ( int )
		},
		formatKey = '<iLA4iA2i8',
		deformatKey = '<iLA128A260A64A128iA16A64i8',
		maxsize = 704
	},
	
	CLUB_LOGON_RESP={
		lengthMap = {
													-- stClubPlayInfo	: 				maxsize = 724,
			[1] = { refered = 'CLUB_PLAYERINFO', complexType = 'link_refer' },
			-- [2] = bHasUnredMsg( int )	: maxsize = 4,
													-- nReserved	: maxsize = 28	=	4 * 7 * 1,
			[3] = { maxlen = 7 },
			maxlen = 3
		},
		nameMap = {
			'stClubPlayInfo',		-- [1] ( refer )
			'bHasUnreadMsg',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<iLA4i3A2i19',
		deformatKey = '<iLA128A260A64A128i3A16A64i19',
		maxsize = 756
	},
	
	CLUB_PLAYERINFO={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = dwIP( unsigned long )	: maxsize = 4,
													-- szNickName	: maxsize = 128	=	1 * 128 * 1,
			[3] = 128,
													-- szPortrait	: maxsize = 260	=	1 * 260 * 1,
			[4] = 260,
													-- szLBSInfo	: maxsize = 64	=	1 * 64 * 1,
			[5] = 64,
													-- szLbsArea	: maxsize = 128	=	1 * 128 * 1,
			[6] = 128,
			-- [7] = nCurrClubNO( int )	: maxsize = 4,
			-- [8] = nCurrYQWRoomNO( int )	: maxsize = 4,
			-- [9] = nCurrGameID( int )	: maxsize = 4,
													-- szCurrGameCode	: maxsize = 16	=	1 * 16 * 1,
			[10] = 16,
													-- szCurrGameName	: maxsize = 64	=	1 * 64 * 1,
			[11] = 64,
			-- [12] = nCurrChairNO( int )	: maxsize = 4,
			-- [13] = nLastReadMsgTime( int )	: maxsize = 4,
			-- [14] = nOnline( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[15] = { maxlen = 8 },
			maxlen = 15
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'dwIP',		-- [2] ( unsigned long )
			'szNickName',		-- [3] ( char )
			'szPortrait',		-- [4] ( char )
			'szLBSInfo',		-- [5] ( char )
			'szLbsArea',		-- [6] ( char )
			'nCurrClubNO',		-- [7] ( int )
			'nCurrYQWRoomNO',		-- [8] ( int )
			'nCurrGameID',		-- [9] ( int )
			'szCurrGameCode',		-- [10] ( char )
			'szCurrGameName',		-- [11] ( char )
			'nCurrChairNO',		-- [12] ( int )
			'nLastReadMsgTime',		-- [13] ( int )
			'nOnline',		-- [14] ( int )
			'nReserved',		-- [15] ( int )
		},
		formatKey = '<iLA4i3A2i11',
		deformatKey = '<iLA128A260A64A128i3A16A64i11',
		maxsize = 724
	},
	
	CLUB_PLAYERMSG={
		lengthMap = {
			-- [1] = nClubNO( int )	: maxsize = 4,
													-- szClubName	: maxsize = 128	=	1 * 128 * 1,
			[2] = 128,
			-- [3] = nUserID( int )	: maxsize = 4,
													-- szNickName	: maxsize = 128	=	1 * 128 * 1,
			[4] = 128,
			-- [5] = nType( int )	: maxsize = 4,
			-- [6] = nCreateTime( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[7] = { maxlen = 8 },
			maxlen = 7
		},
		nameMap = {
			'nClubNO',		-- [1] ( int )
			'szClubName',		-- [2] ( char )
			'nUserID',		-- [3] ( int )
			'szNickName',		-- [4] ( char )
			'nType',		-- [5] ( int )
			'nCreateTime',		-- [6] ( int )
			'nReserved',		-- [7] ( int )
		},
		formatKey = '<iAiAi10',
		deformatKey = '<iA128iA128i10',
		maxsize = 304
	},
	
	CLUB_PLAYER_ONLINE_NTF={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nOnline( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nOnline',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	
	CLUB_YQWROOMINFO={
		lengthMap = {
			-- [1] = nYQWRoomNO( int )	: maxsize = 4,
			-- [2] = nStatus( int )	: maxsize = 4,
			-- [3] = nMaxPlayerCount( int )	: maxsize = 4,
			-- [4] = nPayType( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[5] = { maxlen = 8 },
			maxlen = 5
		},
		nameMap = {
			'nYQWRoomNO',		-- [1] ( int )
			'nStatus',		-- [2] ( int )
			'nMaxPlayerCount',		-- [3] ( int )
			'nPayType',		-- [4] ( int )
			'nReserved',		-- [5] ( int )
		},
		formatKey = '<i12',
		deformatKey = '<i12',
		maxsize = 48
	},
	
	CLUB_YQWROOM_STATUS_NTF={
		lengthMap = {
			-- [1] = nClubNO( int )	: maxsize = 4,
													-- stYQWRoomInfo	: 				maxsize = 48,
			[2] = { refered = 'CLUB_YQWROOMINFO', complexType = 'link_refer' },
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nClubNO',		-- [1] ( int )
			'stYQWRoomInfo',		-- [2] ( refer )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i21',
		deformatKey = '<i21',
		maxsize = 84
	},
	
	GET_YQWCLUBBILL_REQ={
		lengthMap = {
			-- [1] = nClubNO( int )	: maxsize = 4,
			-- [2] = nPlayerID( int )	: maxsize = 4,
			-- [3] = nPayType( int )	: maxsize = 4,
			-- [4] = nDirection( int )	: maxsize = 4,
			-- [5] = nLastBillCreateTimestamp( int )	: maxsize = 4,
													-- szRoundBillID	: maxsize = 32	=	1 * 32 * 1,
			[6] = 32,
			-- [7] = nPageSize( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[8] = 16,
													-- aReserved	: maxsize = 32	=	4 * 8 * 1,
			[9] = { maxlen = 8 },
			maxlen = 9
		},
		nameMap = {
			'nClubNO',		-- [1] ( int )
			'nPlayerID',		-- [2] ( int )
			'nPayType',		-- [3] ( int )
			'nDirection',		-- [4] ( int )
			'nLastBillCreateTimestamp',		-- [5] ( int )
			'szRoundBillID',		-- [6] ( char )
			'nPageSize',		-- [7] ( int )
			'szGameCode',		-- [8] ( char )
			'aReserved',		-- [9] ( int )
		},
		formatKey = '<i5AiAi8',
		deformatKey = '<i5A32iA16i8',
		maxsize = 104
	},
	
	CLUB_FAILED_RESP={
		lengthMap = {
			-- [1] = eErrorCode( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[2] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'eErrorCode',		-- [1] ( int )
			'nReserved',		-- [2] ( int )
			'nMsgLength',
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	--扣玩家币start--
	CLUB_RULEDATA={
		lengthMap = {
			-- [1] = nID( int )	: maxsize = 4,
			-- [2] = nPayType( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[3] = { maxlen = 8 },
			maxlen = 3
		},
		nameMap = {
			'nID',		-- [1] ( int )
			'nPayType',		-- [2] ( int )
			'nReserved',		-- [3] ( int )
		},
		formatKey = '<i10',
		deformatKey = '<i10',
		maxsize = 40
	},
	CLUB_RULEEDIT_NTF={
		lengthMap = {
			-- [1] = nID( int )	: maxsize = 4,
			-- [2] = nClubNO( int )	: maxsize = 4,
			-- [3] = nGameID( int )	: maxsize = 4,
													-- szGameCode	: maxsize = 16	=	1 * 16 * 1,
			[4] = 16,
			-- [5] = nStatus( int )	: maxsize = 4,
													-- nReserved	: maxsize = 32	=	4 * 8 * 1,
			[6] = { maxlen = 8 },
			maxlen = 6
		},
		nameMap = {
			'nID',		-- [1] ( int )
			'nClubNO',		-- [2] ( int )
			'nGameID',		-- [3] ( int )
			'szGameCode',		-- [4] ( char )
			'nStatus',		-- [5] ( int )
			'nReserved',		-- [6] ( int )
		},
		formatKey = '<i3Ai9',
		deformatKey = '<i3A16i9',
		maxsize = 64
	}
	--扣玩家币end--
}

local TreePack = cc.load('treepack')
RequestInfoList.MR_CLUB_GET_CLUBLIST    	= RequestInfoList.CLUB_GET_CLUBLIST_REQ
RequestInfoList.MR_CLUB_GET_ALLINFO     	= RequestInfoList.CLUB_GET_ALLINFO_REQ
RequestInfoList.MR_LOGON_CLUB           	= RequestInfoList.CLUB_LOGON_REQ
RequestInfoList.MR_LOGOFF_CLUB          	= RequestInfoList.CLUB_LOGOFF_REQ
RequestInfoList.MR_CLUB_ENTERCLUB       	= RequestInfoList.CLUB_ENTERCLUB_REQ
RequestInfoList.MR_CLUB_GET_PLAYERMSGS  	= RequestInfoList.CLUB_GET_PLAYERMSG_REQ
RequestInfoList.CLUB_ENTERCLUB_RESP 		= RequestInfoList.CLUB_GET_ALLINFO_RESP
RequestInfoList.MR_GET_CLUBROUNDWIN         = RequestInfoList.GET_YQWCLUBBILL_REQ
RequestInfoList.MR_CLUB_CLIENT_CREATEROOM 	= { 
	lengthMap = function(dataList)
		local data = TreePack.alignpack(dataList, RequestInfoList.CLUB_CLIENT_CREATEROOM_REQ)
		return data..dataList.szRuleJson
	end,
    nameMap = {
		'nUserID',		-- [1] ( int )
		'nClubNO',		-- [2] ( int )
		'nGameID',		-- [3] ( int )
		'szGameCode',		-- [4] ( char )
		'nRoomType',		-- [5] ( int )
		'nAmount',		-- [6] ( int )
		'nPayType',		-- [7] ( int )
		'nReserved',		-- [8] ( int )
		'nRuleLength',		-- [9] ( int )
		'szRuleJson'
	}
}
RequestInfoList.MR_CLUB_APPLY_JOINCLUB		= {
	lengthMap = function(dataList)
		local data = TreePack.alignpack(dataList, RequestInfoList.CLUB_APPLY_JOINCLUB_REQ)
		return data..dataList.arrRemarkData
	end,
	nameMap = {
		'nUserID',		-- [1] ( int )
		'nClubNO',		-- [2] ( int )
		'nGameID',		-- [3] ( int )
		'szGameCode',		-- [4] ( char )
		'nReserved',		-- [5] ( int )
		'nRemarkLength',		-- [6] ( int )
		'arrRemarkData'
	},
}
RequestInfoList.MR_CLUB_APPLY_EXITCLUB		= RequestInfoList.CLUB_APPLY_EXITCLUB_REQ

return RequestInfoList