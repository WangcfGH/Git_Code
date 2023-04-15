
local SKGameReq = {
    SK_START_INFO={
        lengthMap = {
            [1] = 32,
            maxlen = 13
        },
        nameMap = {
            'szSerialNO',
            'nBoutCount',
            'nBaseDeposit',
            'nBaseScore',
            'bNeedDeposit',
            'bForbidDesert',
            'nBanker',
            'nCurrentChair',
            'dwStatus',
            'nThrowWait',
            'nAutoGiveUp',
            'nOffline',
            'nInHandCount'
        },
        formatKey = '<AiiiiiiiLiiii',
        deformatKey = '<A32iiiiiiiLiiii',
        maxsize = 80
    },
    
    SK_PLAYER_INFO={
        lengthMap = {
            --,
            maxlen = 40
        },
        nameMap = {
            'nWaitTime1',
            'nThrowTime1',
            'nTotalThrowCost1',
            'nInHandCount1',
            'nAutoThrowCount1',
            'nWaitTime2',
            'nThrowTime2',
            'nTotalThrowCost2',
            'nInHandCount2',
            'nAutoThrowCount2',
            'nWaitTime3',
            'nThrowTime3',
            'nTotalThrowCost3',
            'nInHandCount3',
            'nAutoThrowCount3',
            'nWaitTime4',
            'nThrowTime4',
            'nTotalThrowCost4',
            'nInHandCount4',
            'nAutoThrowCount4',
            'nWaitTime5',
            'nThrowTime5',
            'nTotalThrowCost5',
            'nInHandCount5',
            'nAutoThrowCount5',
            'nWaitTime6',
            'nThrowTime6',
            'nTotalThrowCost6',
            'nInHandCount6',
            'nAutoThrowCount6',
            'nWaitTime7',
            'nThrowTime7',
            'nTotalThrowCost7',
            'nInHandCount7',
            'nAutoThrowCount7',
            'nWaitTime8',
            'nThrowTime8',
            'nTotalThrowCost8',
            'nInHandCount8',
            'nAutoThrowCount8'
        },
        formatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 160
    },
    
    SK_PUBLIC_INFO={
        lengthMap = {
            [6] = {maxlen = 64},
            [9] = {maxlen = 8},
            maxlen = 9
        },
        nameMap = {
            'nWaitChair',
            'dwCardType',
            'dwComPareType',
            'nMainValue',
            'nCardsCount',
            'nCardIDs',
            'nCurrentCatch',
            'nCurrentRank',
            'dwUserStatus'
        },
        formatKey = '<iLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiLLLLLLLL',
        deformatKey = '<iLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiLLLLLLLL',
        maxsize = 316
    },
    
    SK_TABLE_INFO={
        lengthMap = {
            [1] = 32,
            [19] = {maxlen = 64},
            [22] = {maxlen = 8},
            [63] = {maxlen = 4},
            maxlen = 63
        },
        nameMap = {
            'szSerialNO',
            'nBoutCount',
            'nBaseDeposit',
            'nBaseScore',
            'bNeedDeposit',
            'bForbidDesert',
            'nBanker',
            'nCurrentChair',
            'dwStatus',
            'nThrowWait',
            'nAutoGiveUp',
            'nOffline',
            'nInHandCount',
            'nWaitChair',
            'dwCardType',
            'dwComPareType',
            'nMainValue',
            'nCardsCount',
            'nCardIDs',
            'nCurrentCatch',
            'nCurrentRank',
            'dwUserStatus',
            'nWaitTime1',
            'nThrowTime1',
            'nTotalThrowCost1',
            'nInHandCount1',
            'nAutoThrowCount1',
            'nWaitTime2',
            'nThrowTime2',
            'nTotalThrowCost2',
            'nInHandCount2',
            'nAutoThrowCount2',
            'nWaitTime3',
            'nThrowTime3',
            'nTotalThrowCost3',
            'nInHandCount3',
            'nAutoThrowCount3',
            'nWaitTime4',
            'nThrowTime4',
            'nTotalThrowCost4',
            'nInHandCount4',
            'nAutoThrowCount4',
            'nWaitTime5',
            'nThrowTime5',
            'nTotalThrowCost5',
            'nInHandCount5',
            'nAutoThrowCount5',
            'nWaitTime6',
            'nThrowTime6',
            'nTotalThrowCost6',
            'nInHandCount6',
            'nAutoThrowCount6',
            'nWaitTime7',
            'nThrowTime7',
            'nTotalThrowCost7',
            'nInHandCount7',
            'nAutoThrowCount7',
            'nWaitTime8',
            'nThrowTime8',
            'nTotalThrowCost8',
            'nInHandCount8',
            'nAutoThrowCount8',
            'nReserved'
        },
        formatKey = '<AiiiiiiiLiiiiiLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<A32iiiiiiiLiiiiiLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 572
    },

    GAME_WIN_SK={
        lengthMap = {
            [6] = {maxlen = 8},
            [8] = {maxlen = 8},
            [11] = {maxlen = 8},
            [12] = {maxlen = 8},
            [13] = {maxlen = 8},
            [14] = {maxlen = 8},
            [15] = {maxlen = 8},
            [16] = {maxlen = 8},
            [17] = 16,
            [20] = {maxlen = 2},
            [23] = {maxlen = 4},
            maxlen = 23
        },
        nameMap = {
            'dwWinFlags',
            'dwNextFlags',
            'nTotalChairs',
            'nBoutCount',
            'nBanker',
            'nPartnerGroup',
            'bBankWin',
            'nWinPoints',
            'nBaseScore',
            'nBaseDeposit',
            'nOldScores',
            'nOldDeposits',
            'nScoreDiffs',
            'nDepositDiffs',
            'nWinFees',
            'nLevelIDs',
            'szLevelNames',
            'nNextBaseDeposit',
            'nIdlePlayerFlag',
            'nReserved',
            'nFirstChair',
            'nLastChair',
            'nReserved1'
        },
        formatKey = '<LLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiAiiiiiiiiii',
        deformatKey = '<LLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiA16iiiiiiiiii',
        maxsize = 344
    },
    
    GAME_ENTER_INFO={
        lengthMap = {
            [6] = {maxlen = 8},
            [9] = {maxlen = 7},
            [10] = {maxlen = 30,maxwidth = 8,complexType = 'matrix2'},
            [11] = {maxlen = 8},
            [12] = {maxlen = 4},
            maxlen = 12
        },
        nameMap = {
            'nRoomID',
            'nTableNO',
            'nTotalChair',
            'nBaseScore',
            'nBaseDeposit',
            'dwUserStatus',
            'nBout',
            'nKickOffTime',
            'nReserved',
            'nResultDiff',
            'nTotalResult',
            'nReserve'
        },
        formatKey = '<iiiiiLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 1096
    },
    
    AUCTION_BANKER={
        lengthMap = {
            [7] = {maxlen = 4},
            maxlen = 7
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'bPassed',
            'nGains',
            'nReserved'
        },
        formatKey = '<iiiiiiiiii',
        deformatKey = '<iiiiiiiiii',
        maxsize = 40
    },

    AUCTION_FINISHED={
        lengthMap = {
            [3] = {maxlen = 32},
            [4] = {maxlen = 4},
            maxlen = 4
        },
        nameMap = {
            'nBanker',
            'nObjectGains',
            'nBottomIDs',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 152
    },

    BANKER_AUCTION={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'bPassed',
            'nGains',
            'nReserved'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    CARDINFO={
        lengthMap = {
            --,
            maxlen = 8
        },
        nameMap = {
            'nCardID',
            'nCardIndex',
            'nShape',
            'nValue',
            'nCardStatus',
            'nChairNO',
            'nPositionIndex',
            'nUniteCount'
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    },

    CARDS_PASS={
        lengthMap = {
            [11] = {maxlen = 4},
            maxlen = 11
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nChairNO',
            'nTableNO',
            'nNextChair',
            'bNextFirst',
            'nWinChair',
            'nWinScore',
            'nWaitTime',
            'nRemains',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiii',
        maxsize = 56
    },

    CARDS_THROW={
        lengthMap = {
            [9] = {maxlen = 4},
            [14] = {maxlen = 64},
            maxlen = 14
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'bPassive',
            'nNextChair',
            'nWinPlayce',
            'nWaitTime',
            'nReserved',
            'dwCardType',
            'dwComPareType',
            'nMainValue',
            'nCardsCount',
            'nCardIDs'
        },
        formatKey = '<iiiiiiiiiiiiLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 320
    },
    
    THROW_CARDS_1={
        lengthMap = {
            [9] = 32,
            [10] = {maxlen = 4},
            [12] = {maxlen = 4},
            [14] = {maxlen = 64},
            maxlen = 14
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'bPassive',
            'nSendTable',
            'nSendChair',
            'nSendUser',
            'szHardID',
            'nReserved1',
            'dwCardsType',
            'nReserved2',
            'nCardsCount',
            'nCardIDs'
        },
        formatKey = '<iiiiiiiiAiiiiLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiA32iiiiLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 360
    },

    CARD_UNITE={
        lengthMap = {
            [5] = {maxlen = 64},
            maxlen = 6
        },
        nameMap = {
            'dwCardType',
            'dwComPareType',
            'nMainValue',
            'nCardsCount',
            'nCardIDs',
            'nTypeCount'
        },
        formatKey = '<LLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<LLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 276
    },

    GAME_MSG={
        lengthMap = {
            --,
            maxlen = 5
        },
        nameMap = {
            'nRoomID',
            'nUserID',
            'nMsgID',
            'nVerifyKey',
            'nDatalen'
        },
        formatKey = '<iiiii',
        deformatKey = '<iiiii',
        maxsize = 20
    },

    RETURNCARD={
        lengthMap = {
            --,
            maxlen = 4
        },
        nameMap = {
            'chairno',
            'nCardID',
            'nTributeChair',
            'nThrowChair'
        },
        formatKey = '<iiii',
        deformatKey = '<iiii',
        maxsize = 16
    },  

    TRIBUTE={
        lengthMap = {
            [5] = {maxlen = 2},
            maxlen = 5
        },
        nameMap = {
            'bnTribute',
            'winner',
            'nCardID',
            'bnFight',
            'nFightID'
        },
        formatKey = '<iiiiii',
        deformatKey = '<iiiiii',
        maxsize = 24
    },

    UNITE_TYPE={
        lengthMap = {
            [5] = {maxlen = 64},
            maxlen = 5
        },
        nameMap = {
            'dwCardType',
            'dwComPareType',
            'nMainValue',
            'nCardsCount',
            'nCardIDs'
        },
        formatKey = '<LLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<LLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 272
    },
    
    CARDS_INFO={
        lengthMap = {
            [4] = {maxlen = 64},
            maxlen = 4
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nCardsCount',
            'nCardIDs'
        },
        formatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 268
    },
    
    CARDS_THROW_1={
        lengthMap = {
            [7] = {maxlen = 8},
            [10] = {maxlen = 4},
            [12] = {maxlen = 64},
            maxlen = 12
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nNextChair',
            'bNextFirst',
            'bNextPass',
            'nRemains',
            'dwFlags',
            'dwCardsType',
            'nThrowCount',
            'nReserved',
            'nCardsCount',
            'nCardIDs'
        },
        formatKey = '<iiiiiiLLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiLLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 340
    },

    GAME_WIN_SK_1={
        lengthMap = {
            [6] = {maxlen = 8},
            [8] = {maxlen = 8},
            [9] = {maxlen = 8},
            [10] = {maxlen = 8},
            [13] = {maxlen = 8},
            [14] = {maxlen = 8},
            [15] = {maxlen = 8},
            [16] = {maxlen = 8},
            [17] = {maxlen = 8},
            [18] = {maxlen = 8},
            [19] = {maxlen = 8},
            [20] = {maxlen = 8},
            [21] = 16,
            [23] = {maxlen = 3},
            [25] = {maxlen = 4},
            [28] = {maxlen = 4},
            maxlen = 28
        },
        nameMap = {
            'dwWinFlags',
            'dwNextFlags',
            'nTotalChairs',
            'nBoutCount',
            'nBanker',
            'nPartnerGroup',
            'bBankWin',
            'nWinPoints',
            'nGains',
            'nBonus',
            'nBaseScore',
            'nBaseDeposit',
            'nOldScores',
            'nOldDeposits',
            'nBonusScores',
            'nBonusDeposits',
            'nScoreDiffs',
            'nDepositDiffs',
            'nWinFees',
            'nLevelIDs',
            'szLevelNames',
            'nNextBaseDeposit',
            'nReserved1',
            'nNewRound',
            'nReserved2',
            'nFirstChair',
            'nLastChair',
            'nReserved3'
        },
        formatKey = '<LLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiAiiiiiiiiiiiiiii',
        deformatKey = '<LLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiA16iiiiiiiiiiiiiii',
        maxsize = 492
    },

    SK_TABLE_INFO_1={
        lengthMap = {
            [6] = {maxlen = 8},
            [7] = {maxlen = 8},
            [20] = {maxlen = 8},
            [21] = {maxlen = 4},
            [24] = {maxlen = 8},
            [25] = {maxlen = 8},
            [26] = {maxlen = 8},
            [27] = {maxlen = 8},
            [31] = {maxlen = 8},
            [32] = {maxlen = 8},
            [33] = {maxlen = 8},
            [37] = {maxlen = 2},
            [45] = {maxlen = 16},
            [54] = {maxlen = 32},
            [55] = {maxlen = 64,maxwidth = 8,complexType = 'matrix2'},
            [57] = {maxlen = 7,maxwidth = 32,complexType = 'matrix2'},
            [63] = {maxlen = 64,maxwidth = 8,complexType = 'matrix2'},
            [64] = {maxlen = 8},
            [66] = {maxlen = 4},
            [69] = {maxlen = 64},
            [70] = {maxlen = 8},
            [72] = {maxlen = 4},
            maxlen = 72
        },
        nameMap = {
            'nTableNO',
            'nScoreMult',
            'nTotalChairs',
            'dwGameFlags',
            'nMaxAsks',
            'dwUserConfig',
            'dwRoomOption',
            'bTableEqual',
            'bNeedDeposit',
            'bForbidDesert',
            'nDepositMult',
            'nDepositMin',
            'nFeeRatio',
            'nMaxTrans',
            'nCutRatio',
            'nDepositLogDB',
            'nRoundCount',
            'nBoutCount',
            'nBanker',
            'nPartnerGroup',
            'nDices',
            'dwStatus',
            'nCurrentChair',
            'dwCostTime',
            'nAutoCount',
            'nBreakCount',
            'dwUserStatus',
            'nBaseScore',
            'nBaseDeposit',
            'dwWinFlags',
            'nGains',
            'nBonus',
            'nAskStandOff',
            'dwIntermitTime',
            'dwBoutFlags',
            'dwRoomConfigs',
            'nReserved1',
            'nTotalCards',
            'nTotalPacks',
            'nChairCards',
            'nBottomCards',
            'nLayoutNum',
            'nLayoutMod',
            'nLayoutNumEx',
            'nAbtPairs',
            'nThrowWait',
            'nMaxAutoThrow',
            'nEntrustWait',
            'nMaxAuction',
            'nMinAuction',
            'nDefAuction',
            'nFirstCatch',
            'nFirstThrow',
            'nBottomIDs',
            'nIDMatrix',
            'nAuctionCount',
            'nAuctions',
            'nObjectGains',
            'nCatchFrom',
            'nJokerNO',
            'nJokerID',
            'nWaitingGains',
            'nGainsCards',
            'nGainsCount',
            'nThrowCount',
            'nReserved2',
            'nWaitingChair',
            'dwWaitingType',
            'nWaitingCards',
            'nWinChairs',
            'nWinCount',
            'nReserved3'
        },
        formatKey = '<iiiLiLLLLLLLLLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiLiLLLLLLLLiiiiiiiiiiiiiiiiLLLLLLLLiiLiiiiiiiiiiiiiiiiiiiiiiiiLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiLiLLLLLLLLLLLLLLLLiiiiiiiiiiiiiiiiiiiiiiiiLiLLLLLLLLiiiiiiiiiiiiiiiiLLLLLLLLiiLiiiiiiiiiiiiiiiiiiiiiiiiLLLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiLiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 6080
    },

    THROW_AGAIN={
        lengthMap = {
            [1] = {maxlen = 4},
            [3] = {maxlen = 64},
            maxlen = 3
        },
        nameMap = {
            'nReserved',
            'nCardsCount',
            'nCardIDs'
        },
        formatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii',
        maxsize = 276
    },

    THROW_OK={
        lengthMap = {
            --,
            maxlen = 2
        },
        nameMap = {
            'nNextChair',
            'bNextFirst'
        },
        formatKey = '<ii',
        deformatKey = '<ii',
        maxsize = 8
    },
    
    CARDS_PASS_1={
        lengthMap = {
            [7] = {maxlen = 4},
            maxlen = 7
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nNextChair',
            'bNextFirst',
            'bNextPass',
            'nRemains',
            'nReserved'
        },
        formatKey = '<iiiiiiiiii',
        deformatKey = '<iiiiiiiiii',
        maxsize = 40
    },

    PASS_CARDS_1={
        lengthMap = {
            [9] = 32,
            [10] = {maxlen = 4},
            [11] = {maxlen = 4},
            maxlen = 11
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'bPassive',
            'nSendTable',
            'nSendChair',
            'nSendUser',
            'szHardID',
            'nReserved1',
            'nReserved2'
        },
        formatKey = '<iiiiiiiiAiiiiiiii',
        deformatKey = '<iiiiiiiiA32iiiiiiii',
        maxsize = 96
    },

    PASS_OK={
        lengthMap = {
            --,
            maxlen = 2
        },
        nameMap = {
            'nNextChair',
            'bNextFirst'
        },
        formatKey = '<ii',
        deformatKey = '<ii',
        maxsize = 8
    },
    
    CARDS_THROW_HEAD={
        lengthMap = {
            [9] = {maxlen = 4},
            maxlen = 13
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'bPassive',
            'nNextChair',
            'nWinPlayce',
            'nWaitTime',
            'nReserved',
            'dwCardType',
            'dwComPareType',
            'nMainValue',
            'nCardsCount'
        },
        formatKey = '<iiiiiiiiiiiiLLLi',
        deformatKey = '<iiiiiiiiiiiiLLLi',
        maxsize = 64
    },

    CARDS_THROW_HEAD_1={
        lengthMap = {
            [7] = {maxlen = 8},
            [10] = {maxlen = 4},
            maxlen = 11
        },
        nameMap = {
            'nUserID',
            'nChairNO',
            'nNextChair',
            'bNextFirst',
            'bNextPass',
            'nRemains',
            'dwFlags',
            'dwCardsType',
            'nThrowCount',
            'nReserved',
            'nCardsCount'
        },
        formatKey = '<iiiiiiLLLLLLLLLiiiiii',
        deformatKey = '<iiiiiiLLLLLLLLLiiiiii',
        maxsize = 84
    },
    
    CARDS_ID={
        lengthMap = {
            --,
            maxlen = 1
        },
        nameMap = {
            'nCardsID'
        },
        formatKey = '<i',
        deformatKey = '<i',
        maxsize = 4
    },
    
    TASKDATA={
        lengthMap = {
            --,
            maxlen = 7
        },
        nameMap = {
            'nUserID',
            'nGameCount',
            'nHuDieCount',
            'nXiQianCount',
            'nGouTui',
            'nWinGouTui',
            'nTaskCount'
        },
        formatKey = '<iiiiiii',
        deformatKey = '<iiiiiii',
        maxsize = 28
    },

    GAINS_BONUS={
        lengthMap = {
            [2] = {maxlen = 8},
            [3] = {maxlen = 8},
            [4] = {maxlen = 4},
            maxlen = 4
        },
        nameMap = {
            'nCurrentChair',
            'nGains',
            'nBonus',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiiiiiiii',
        maxsize = 84
    },

    USER_OFFLINE={
        lengthMap = {
            [5] = {maxlen = 4},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nRoomID',
            'nTableNO',
            'nChairNO',
            'nReserved'   
        },
        formatKey = '<iiiiiiii',
        deformatKey = '<iiiiiiii',
        maxsize = 32
    }
}

return SKGameReq