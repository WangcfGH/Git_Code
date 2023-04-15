local treepack = cc.load('treepack')
local GoldSilverReq = 
{
	GOLDSILVER_MULTIPIER={
		lengthMap = {
			-- [1] = nLose( int )	: maxsize = 4,
			-- [2] = nEquality( int )	: maxsize = 4,
			-- [3] = nOneWin( int )	: maxsize = 4,
			-- [4] = nDoubleWin( int )	: maxsize = 4,
			maxlen = 4
		},
		nameMap = {
			'nLose',		-- [1] ( int )
			'nEquality',		-- [2] ( int )
			'nOneWin',		-- [3] ( int )
			'nDoubleWin',		-- [4] ( int )
		},
		formatKey = '<i4',
		deformatKey = '<i4',
		maxsize = 16
    },
    GOLDSILVER_INICHANGE={
		lengthMap = {
			-- [1] = nOpen( int )	: maxsize = 4,
			-- [2] = nPayLevelA( int )	: maxsize = 4,
			-- [3] = nPayLevelB( int )	: maxsize = 4,
			-- [4] = nMaxDailyScore( int )	: maxsize = 4,
													-- stRoomScore	: maxsize = 112	=	16 * 7 * 1,
			[5] = { maxlen = 7, refered = 'GOLDSILVER_MULTIPIER', complexType = 'link_refer' },
			maxlen = 5
		},
		nameMap = {
			'nOpen',		-- [1] ( int )
			'nPayLevelA',		-- [2] ( int )
			'nPayLevelB',		-- [3] ( int )
			'nMaxDailyScore',		-- [4] ( int )
			'stRoomScore',		-- [5] ( refer )
		},
		formatKey = '<i32',
		deformatKey = '<i32',
		maxsize = 128
    },
    
	GOLDSILVERINFO_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPackageType( int )	: maxsize = 4,
			-- [3] = nChannelID( int )	: maxsize = 4,
													-- szFileTime	: maxsize = 16	=	1 * 16 * 1,
			[4] = 16,
													-- szDeviceID	: maxsize = 100	=	1 * 100 * 1,
			[5] = 100,
			-- [6] = nResult( int )	: maxsize = 4,
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPackageType',		-- [2] ( int )
			'nChannelID',		-- [3] ( int )
			'szFileTime',		-- [4] ( char )
			'szDeviceID',		-- [5] ( char )
			'nResult',		-- [6] ( int )
		},
		formatKey = '<i3A2i',
		deformatKey = '<i3A16A100i',
		maxsize = 132
	},
    
    GOLDSILVERPROCESS_HEAD={
		lengthMap = {
			-- [1] = nLeavel( int )	: maxsize = 4,
			maxlen = 1
		},
		nameMap = {
			'nLeavel',		-- [1] ( int )
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
    },
    
    GOLDSILVERREWARD={
		lengthMap = {
			-- [1] = nFreeSilver( int )	: maxsize = 4,
			-- [2] = nFreeTicket( int )	: maxsize = 4,
			-- [3] = nSilverSilver( int )	: maxsize = 4,
			-- [4] = nSilverTicket( int )	: maxsize = 4,
			-- [5] = nGoldSilver( int )	: maxsize = 4,
			-- [6] = nGoldTicket( int )	: maxsize = 4,
			maxlen = 6
		},
		nameMap = {
			'nFreeSilver',		-- [1] ( int )
			'nFreeTicket',		-- [2] ( int )
			'nSilverSilver',		-- [3] ( int )
			'nSilverTicket',		-- [4] ( int )
			'nGoldSilver',		-- [5] ( int )
			'nGoldTicket',		-- [6] ( int )
		},
		formatKey = '<i6',
		deformatKey = '<i6',
		maxsize = 24
    },
    
	GOLDSILVERINFO_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nStatusCode( int )	: maxsize = 4,
			-- [3] = nPackageType( int )	: maxsize = 4,
			-- [4] = nPayLevel( int )	: maxsize = 4,
			-- [5] = nDailyScore( int )	: maxsize = 4,
			-- [6] = nTotalScore( int )	: maxsize = 4,
			-- [7] = nSilverBuyStatus( int )	: maxsize = 4,
			-- [8] = nGoldBuyStatus( int )	: maxsize = 4,
			-- [9] = llfreelowStatus( long long )	: maxsize = 8,
			-- [10] = llfreehighStatus( long long )	: maxsize = 8,
			-- [11] = llsilverlowStatus( long long )	: maxsize = 8,
			-- [12] = llsilverhighStatus( long long )	: maxsize = 8,
			-- [13] = llgoldlowStatus( long long )	: maxsize = 8,
			-- [14] = llgoldhighStatus( long long )	: maxsize = 8,
													-- szFileTime	: maxsize = 16	=	1 * 16 * 1,
			[15] = 16,
			-- [16] = nUpdateConfig( int )	: maxsize = 4,
													-- head	: 				maxsize = 4,
			[17] = { refered = 'GOLDSILVERPROCESS_HEAD', complexType = 'link_refer' },
			maxlen = 17
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nStatusCode',		-- [2] ( int )
			'nPackageType',		-- [3] ( int )
			'nPayLevel',		-- [4] ( int )
			'nDailyScore',		-- [5] ( int )
			'nTotalScore',		-- [6] ( int )
			'nSilverBuyStatus',		-- [7] ( int )
			'nGoldBuyStatus',		-- [8] ( int )
			'llfreelowStatus',		-- [9] ( long long )
			'llfreehighStatus',		-- [10] ( long long )
			'llsilverlowStatus',		-- [11] ( long long )
			'llsilverhighStatus',		-- [12] ( long long )
			'llgoldlowStatus',		-- [13] ( long long )
			'llgoldhighStatus',		-- [14] ( long long )
			'szFileTime',		-- [15] ( char )
			'nUpdateConfig',		-- [16] ( int )
			'head',		-- [17] ( refer )
		},
		formatKey = '<i8d6Ai2',
		deformatKey = '<i8d6A16i2',
		maxsize = 104
    },
    
    GOLDSILVERPROCESS={
		lengthMap = {
			-- [1] = nNeedScore( int )	: maxsize = 4,
													-- stReward	: 				maxsize = 24,
			[2] = { refered = 'GOLDSILVERREWARD', complexType = 'link_refer' },
			maxlen = 2
		},
		nameMap = {
			'nNeedScore',		-- [1] ( int )
			'stReward',		-- [2] ( refer )
		},
		formatKey = '<i7',
		deformatKey = '<i7',
		maxsize = 28
	},
	
	GOLDSILVERSTATE={
		lengthMap = {
			-- [1] = nStateLow( long )	: maxsize = 4,
			-- [2] = nStateHigh( long )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nStateLow',		-- [1] ( long )
			'nStateHigh',		-- [2] ( long )
		},
		formatKey = '<l2',
		deformatKey = '<l2',
		maxsize = 8
	},

	GOLDSILVERINFO_RESPEX={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nStatusCode( int )	: maxsize = 4,
			-- [3] = nPackageType( int )	: maxsize = 4,
			-- [4] = nPayLevel( int )	: maxsize = 4,
			-- [5] = nDailyScore( int )	: maxsize = 4,
			-- [6] = nTotalScore( int )	: maxsize = 4,
			-- [7] = nSilverBuyStatus( int )	: maxsize = 4,
			-- [8] = nGoldBuyStatus( int )	: maxsize = 4,
													-- llfreelowStatus	: 				maxsize = 8,
			[9] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llfreehighStatus	: 				maxsize = 8,
			[10] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llsilverlowStatus	: 				maxsize = 8,
			[11] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llsilverhighStatus	: 				maxsize = 8,
			[12] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llgoldlowStatus	: 				maxsize = 8,
			[13] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llgoldhighStatus	: 				maxsize = 8,
			[14] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- stRoomScore	: maxsize = 112	=	16 * 7 * 1,
			[15] = { maxlen = 7, refered = 'GOLDSILVER_MULTIPIER', complexType = 'link_refer' },
													-- szFileTime	: maxsize = 16	=	1 * 16 * 1,
			[16] = 16,
			-- [17] = nUpdateConfig( int )	: maxsize = 4,
			-- [18] = nSeason( int )	: maxsize = 4,
			-- [19] = nMaxDailyScore( int )	: maxsize = 4,
			-- [20] = nRecharge( int )	: maxsize = 4,
													-- head	: 				maxsize = 4,
			[21] = { refered = 'GOLDSILVERPROCESS_HEAD', complexType = 'link_refer' },
			maxlen = 21
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nStatusCode',		-- [2] ( int )
			'nPackageType',		-- [3] ( int )
			'nPayLevel',		-- [4] ( int )
			'nDailyScore',		-- [5] ( int )
			'nTotalScore',		-- [6] ( int )
			'nSilverBuyStatus',		-- [7] ( int )
			'nGoldBuyStatus',		-- [8] ( int )
			'llfreelowStatus',		-- [9] ( refer )
			'llfreehighStatus',		-- [10] ( refer )
			'llsilverlowStatus',		-- [11] ( refer )
			'llsilverhighStatus',		-- [12] ( refer )
			'llgoldlowStatus',		-- [13] ( refer )
			'llgoldhighStatus',		-- [14] ( refer )
			'stRoomScore',		-- [15] ( refer )
			'szFileTime',		-- [16] ( char )
			'nUpdateConfig',		-- [17] ( int )
			'nSeason',		-- [18] ( int )
			'nMaxDailyScore',		-- [19] ( int )
			'nRecharge',		-- [20] ( int )
			'head',		-- [21] ( refer )
		},
		formatKey = '<i8l12i28Ai5',
		deformatKey = '<i8l12i28A16i5',
		maxsize = 228
	},

	GOLDSILVERTAKEREWARD_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPackageType( int )	: maxsize = 4,
			-- [3] = nChannelID( int )	: maxsize = 4,
													-- szDeviceID	: maxsize = 100	=	1 * 100 * 1,
			[4] = 100,
			-- [5] = nTakeType( int )	: maxsize = 4,
			-- [6] = nLevel( int )	: maxsize = 4,
			-- [7] = nResult( int )	: maxsize = 4,
			maxlen = 7
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPackageType',		-- [2] ( int )
			'nChannelID',		-- [3] ( int )
			'szDeviceID',		-- [4] ( char )
			'nTakeType',		-- [5] ( int )
			'nLevel',		-- [6] ( int )
			'nResult',		-- [7] ( int )
		},
		formatKey = '<i3Ai3',
		deformatKey = '<i3A100i3',
		maxsize = 124
	},
	
	GOLDSILVERTAKEREWARD_RESPEX={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nStatusCode( int )	: maxsize = 4,
			-- [3] = nSilver( int )	: maxsize = 4,
			-- [4] = nTicket( int )	: maxsize = 4,
													-- llfreelowStatus	: 				maxsize = 8,
			[5] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llfreehighStatus	: 				maxsize = 8,
			[6] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llsilverlowStatus	: 				maxsize = 8,
			[7] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llsilverhighStatus	: 				maxsize = 8,
			[8] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llgoldlowStatus	: 				maxsize = 8,
			[9] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
													-- llgoldhighStatus	: 				maxsize = 8,
			[10] = { refered = 'GOLDSILVERSTATE', complexType = 'link_refer' },
			maxlen = 10
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nStatusCode',		-- [2] ( int )
			'nSilver',		-- [3] ( int )
			'nTicket',		-- [4] ( int )
			'llfreelowStatus',		-- [5] ( refer )
			'llfreehighStatus',		-- [6] ( refer )
			'llsilverlowStatus',		-- [7] ( refer )
			'llsilverhighStatus',		-- [8] ( refer )
			'llgoldlowStatus',		-- [9] ( refer )
			'llgoldhighStatus',		-- [10] ( refer )
		},
		formatKey = '<i4l12',
		deformatKey = '<i4l12',
		maxsize = 64
	},

	GOLDSILVERPAY_REQ={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPayType( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPayType',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
	},
	
	GOLDSILVERPAY_RESP={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nPayType( int )	: maxsize = 4,
			-- [3] = nResult( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nPayType',		-- [2] ( int )
			'nResult',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},

	GOLDSILVER_SCORECHANGE={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nDailyScore( int )	: maxsize = 4,
			-- [3] = nTotalScore( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nDailyScore',		-- [2] ( int )
			'nTotalScore',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},

	GOLDSILVER_BUYSTATUSCHANGE={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nSilverState( int )	: maxsize = 4,
			-- [3] = nGoldState( int )	: maxsize = 4,
			maxlen = 3
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nSilverState',		-- [2] ( int )
			'nGoldState',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
	},

	GOLDSILVER_NOTIFYCLIENT={
		lengthMap = {
			-- [1] = nUpdateConfig( int )	: maxsize = 4,
			maxlen = 1
		},
		nameMap = {
			'nUpdateConfig',		-- [1] ( int )
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
	},

	GOLDSILVER_INICHANGE={
		lengthMap = {
			-- [1] = nOpen( int )	: maxsize = 4,
			-- [2] = nPayLevelA( int )	: maxsize = 4,
			-- [3] = nPayLevelB( int )	: maxsize = 4,
			-- [4] = nMaxDailyScore( int )	: maxsize = 4,
													-- stRoomScore	: maxsize = 112	=	16 * 7 * 1,
			[5] = { maxlen = 7, refered = 'GOLDSILVER_MULTIPIER', complexType = 'link_refer' },
			maxlen = 5
		},
		nameMap = {
			'nOpen',		-- [1] ( int )
			'nPayLevelA',		-- [2] ( int )
			'nPayLevelB',		-- [3] ( int )
			'nMaxDailyScore',		-- [4] ( int )
			'stRoomScore',		-- [5] ( refer )
		},
		formatKey = '<i32',
		deformatKey = '<i32',
		maxsize = 128
	},
}

cc.load('treepack').resolveReference(GoldSilverReq)
return GoldSilverReq