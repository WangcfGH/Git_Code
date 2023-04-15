local DataRecordRequest = {
    MessageMap = {
	GR_DATARECORD_APP_UPLOAD			= 404102,
	GR_DATARECORD_NEW_APP_UPLOAD		= 404104,
	GR_DATARECORD_LOG_FUNC_USED			= 404110
--    GR_DATARECORD_DEL_DBDATA	        = 404103, --代码评审 OK 服务端没有响应该消息
    },

    APPUPLOAD_DATA={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
													-- szWeChatName	: maxsize = 32	=	1 * 32 * 1,
			[2] = 32,
													-- szPhoneNO	: maxsize = 32	=	1 * 32 * 1,
			[3] = 32,
													-- szDeviceName	: maxsize = 32	=	1 * 32 * 1,
			[4] = 32,
													-- szClientVer	: maxsize = 32	=	1 * 32 * 1,
			[5] = 32,
			-- [6] = nFirstLogon( int )	: maxsize = 4,
			-- [7] = nHappyCoin( int )	: maxsize = 4,
			-- [8] = nFreeHappyCoin( int )	: maxsize = 4,
			-- [9] = nScoreNum( int )	: maxsize = 4,
			-- [10] = nDepositNum( int )	: maxsize = 4,
			-- [11] = nSafeboxNum( int )	: maxsize = 4,
			-- [12] = nNetType( int )	: maxsize = 4,
			-- [13] = nChannelNO( int )	: maxsize = 4,
													-- szExtend	: maxsize = 1024	=	1 * 1024 * 1,
			[14] = 1024,
													-- szHardID	: maxsize = 32	=	1 * 32 * 1,
			[15] = 32,
			maxlen = 15
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'szWeChatName',		-- [2] ( char )
			'szPhoneNO',		-- [3] ( char )
			'szDeviceName',		-- [4] ( char )
			'szClientVer',		-- [5] ( char )
			'nFirstLogon',		-- [6] ( int )
			'nHappyCoin',		-- [7] ( int )
			'nFreeHappyCoin',		-- [8] ( int )
			'nScoreNum',		-- [9] ( int )
			'nDepositNum',		-- [10] ( int )
			'nSafeboxNum',		-- [11] ( int )
			'nNetType',		-- [12] ( int )
			'nChannelNO',		-- [13] ( int )
			'szExtend',		-- [14] ( char )
			'szHardID',		-- [15] ( char )
		},
		formatKey = '<iA4i8A2',
		deformatKey = '<iA32A32A32A32i8A1024A32',
		maxsize = 1220
	},
	FUNCUSED_LOG={
		lengthMap = {
			-- [1] = nUserID( int )	: maxsize = 4,
			-- [2] = nFuncID( int )	: maxsize = 4,
			maxlen = 2
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nFuncID',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
	}
}

return DataRecordRequest