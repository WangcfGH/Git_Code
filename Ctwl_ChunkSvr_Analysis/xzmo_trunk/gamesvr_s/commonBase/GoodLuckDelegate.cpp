#include "stdafx.h"
#include "GoodLuckModel.h"

CString GetINIFilePath()
{
	static std::string sIniFilePath;
	if (sIniFilePath.size() == 0)
	{
		sIniFilePath = GetINIFileName();
	}
	return sIniFilePath.c_str();
}

LPCSTR GetPath(void)
{
	static char szAppPath[MAX_PATH] = { '\0' };
	if (szAppPath[0] == '\0')
	{
		int i;
		GetModuleFileName(GetModuleHandle(NULL), szAppPath, MAX_PATH);
		for (i = (int)strlen(szAppPath) - 1; i > 0; --i)
		{
			if (szAppPath[i] == '\\')
			{
				break;
			}
		}
		szAppPath[i + 1] = '\0';
	}
	return szAppPath;
}

//-----------------------------------------------------------------------------
// 函数名: GetAbsPath();
// 功  能: 取应用程序目录下某子目录的绝对路径;
// 参  数: [szDir] - 子目录名;
// 返回值: [LPCSTR] - 子目录的绝对路径;
//-----------------------------------------------------------------------------
LPCSTR GetServerPath(LPCSTR szDir)
{
	static char szAbsPath[MAX_PATH];
	strcpy_s(szAbsPath, GetPath());
	strcat_s(szAbsPath, szDir);
	return szAbsPath;
}

void WriteGameServerLog(CString logName, CString logTitle, CString logData)
{

	CString strLogName;
	strLogName = GetServerPath(logName);

	FILE* fp = NULL;
	fopen_s(&fp, strLogName, "a+");
	if (fp)
	{
		int filelen = _filelength(_fileno(fp));
		if (filelen == 0)
		{
			fseek(fp, 0, SEEK_END);
			fwrite(logTitle, logTitle.GetLength(), 1, fp);
		}

		fseek(fp, 0, SEEK_END);
		fwrite(logData, logData.GetLength(), 1, fp);
		fclose(fp);
	}
}

CGoodLuckDelegate::CGoodLuckDelegate()
{
    CString strDateTime;
    CTime tmpTime = CTime::GetCurrentTime();
    strDateTime = tmpTime.Format("%Y%m%d");
    m_nCurrentGoodLuckDate = atoi(strDateTime);
}

void CGoodLuckDelegate::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_BUY_GOOD_LUCK_PROP, OnBuyGoodLuckProp);

		m_timerPtr = this->evp().loopTimer([this]() {
			this->OnHourTriggered();
		}, std::chrono::hours(1), strand());
	}
}

void CGoodLuckDelegate::OnShutdown()
{
	m_timerPtr = nullptr;
}

void CGoodLuckDelegate::OnNewTable(CCommonBaseTable* table)
{
	using namespace plana::events;
	table->m_entity.assign<CGoodLuckModel>();
	table->evResetAll += delegate(this, &CGoodLuckDelegate::OnRestAll);
}

void CGoodLuckDelegate::OnRestAll(CCommonBaseTable* table)
{
	auto* com = table->m_entity.component<CGoodLuckModel>();
	com->SetGoodLuckPropUserID(0);
	com->CleanWaitBuyGoodLuckUserID();
}

void CGoodLuckDelegate::YQW_CloseSoloTable(CCommonBaseTable* table, int roomid, DWORD dwAbortFlag)
{
	auto* com = table->m_entity.component<CGoodLuckModel>();
	int goodLuckPropUserID = com->GetGoodLuckPropUserID();
	if (goodLuckPropUserID > 0) {
		AddGoodLuckPropFreeCount(goodLuckPropUserID);
		CPlayer* pPlayer = table->GetPlayer(goodLuckPropUserID);
		if (pPlayer)
		{
			BUY_GOOD_LUCK_PROP goodLuckProp;
			memset(&goodLuckProp, 0, sizeof(goodLuckProp));
			goodLuckProp.nUserID = goodLuckPropUserID;
			goodLuckProp.nResult = -1;
			imNotifyOneUser.notify(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(goodLuckProp), FALSE);

			WriteGoodLuckLog(goodLuckPropUserID, table->m_nYqwRoomNo, GOOD_LUCK_RESULT_RETURN_FREE);
		}
	}
}

void CGoodLuckDelegate::OnCPGameStarted(CCommonBaseTable* table, void* pData)
{
	if (table->IsYQWTable()) {
		OnShowGoodLuckProp(table);
	}
}

void CGoodLuckDelegate::YQW_OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CCommonBaseTable* pTable, void* pData)
{
	OnSendGoodLuckPropStateWhenGameWin(pTable);
}

void CGoodLuckDelegate::OnCPEnterGameDXXW(LPCONTEXT_HEAD lpContext, int nRoomid, CCommonBaseTable* pTable, CPlayer* pPlayer)
{
	if (pTable->IsYQWTable()) {
		CYQWGameData yqwGameData;
		if (imYQW_LookupGameData.notify(pTable->m_nRoomID, pTable->m_nTableNO, yqwGameData) && !yqwGameData.IsAgentTblRoom())
		{
			if (pTable->m_nYqwHistoryBoutCount <= 0)
			{
				if (pPlayer->m_nUserID == yqwGameData.game_data.nUserId)
				{
					OnSendGoodLuckPropStateByPlayer(pTable, pPlayer);
				}
			}
			else
			{
				OnSendGoodLuckPropStateByPlayer(pTable, pPlayer);
			}
		}
	}
}

BOOL CGoodLuckDelegate::OnBuyGoodLuckProp(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LOG_TRACE(_T("CGoodLuckDelegate::OnBuyGoodLuckProp"));
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;

    CCommonBaseTable* pTable = NULL;

    LPBUY_GOOD_LUCK_PROP pData = LPBUY_GOOD_LUCK_PROP(PBYTE(lpRequest->pDataPtr));
    roomid = pData->nRoomID;
    tableno = pData->nTableNO;
    userid = pData->nUserID;
    chairno = pData->nChairNO;

    EXCH_GAME_GOODS exchGameGoods;
    memset(&exchGameGoods, 0, sizeof(EXCH_GAME_GOODS));
    if (lpRequest->nDataLen == sizeof(BUY_GOOD_LUCK_PROP) + sizeof(EXCH_GAME_GOODS))
    {
        LPEXCH_GAME_GOODS pExchGameGoods = LPEXCH_GAME_GOODS(PBYTE(lpRequest->pDataPtr) + sizeof(BUY_GOOD_LUCK_PROP));
        exchGameGoods = *pExchGameGoods;
    }
    else if (lpRequest->nDataLen != sizeof(BUY_GOOD_LUCK_PROP))
    {
        return FALSE;
    }
    if (!(pTable = imGetTablePtr.notify(roomid, tableno, FALSE, 0)))
    {
        return TRUE;
    }

    if (pTable && pTable->IsYQWTable())
    {
        CCommonBaseTable* pGameTable = dynamic_cast<CCommonBaseTable*>(pTable);
        CAutoLock lock(&(pGameTable->m_csTable));
        if (pTable->IsVisitor2(userid) || IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  //游戏已经开始，直接过滤;
        {
            return TRUE;
        }
		auto* com = pGameTable->m_entity.component<CGoodLuckModel>();

        if (com->GetGoodLuckPropUserID() > 0)
        {
            CPlayer* pPlayer = pTable->GetPlayer(userid);
            if (pPlayer)
            {
                BUY_GOOD_LUCK_PROP goodLuckProp;
                memset(&goodLuckProp, 0, sizeof(goodLuckProp));
                goodLuckProp.nUserID = com->GetGoodLuckPropUserID();
                goodLuckProp.nResult = GOOD_LUCK_RESULT_ROBBED;
				imNotifyOneUser.notify(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(goodLuckProp), FALSE);
            }
            WriteGoodLuckLog(userid, pTable->m_nYqwRoomNo, GOOD_LUCK_RESULT_ROBBED);
            return TRUE;
        }
        //有人正在购买,加入队列;
        if (com->GetGoodLuckPropUserID() == -1)
        {
			com->PushWaitBuyGoodLuckUserID(*pData);
			com->PushWaitExchGameGoods(exchGameGoods);
            return TRUE;
        }

        BuyGoodLuckProp(pTable, userid, pData->nHappyCoin, exchGameGoods);
    }

    return TRUE;
}

void CGoodLuckDelegate::YQW_OnCPDeductHappyCoinResult(CCommonBaseTable* pTable, LPYQW_DEDUCT_HAPPYCOIN pDeductReq, LPYQW_HAPPYCOIN_CHANGE pDeductRet)
{
    //CAutoLock lock(&(pTable->m_csTable));
    //CCommonBaseTable* pYqwCommonBaseTable = (CCommonBaseTable*)pTable;
    //BUY_GOOD_LUCK_PROP goodLuckProp;
    //memset(&goodLuckProp, 0, sizeof(goodLuckProp));
    //goodLuckProp.nUserID = pDeductRet->nUserID;
    //if (pDeductRet->nResult == YQW_HAPPYCOIN_RESULT_SUCCESS)
    //{
    //    pYqwCommonBaseTable->m_pGoodLuckModel->SetGoodLuckPropUserID(pDeductRet->nUserID);
    //    goodLuckProp.nResult = 1;
    //    m_pServer->NotifyTablePlayers(pTable, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(BUY_GOOD_LUCK_PROP));
    //    m_pServer->NotifyTableVisitors(pTable, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(BUY_GOOD_LUCK_PROP));

    //    WriteGoodLuckLog(pDeductRet->nUserID, pTable->m_nYqwRoomNo, GOOD_LUCK_RESULT_PAY);


    //    CPlayer* pPlayer = pTable->GetPlayer(pDeductRet->nUserID);
    //    if (pPlayer)
    //    {
    //        LPCONTEXT_HEAD lpContext = new CONTEXT_HEAD;
    //        lpContext->hSocket = pPlayer->m_hSocket;
    //        lpContext->lTokenID = pPlayer->m_lTokenID;
    //        //m_pServer->m_pTaskDelegate->UpdateTaskRecordByAddParam(lpContext, pTable, pPlayer->m_nChairNO, TASK_GAME_GOOD_LUCK_COUNT);
    //        SAFE_DELETE(lpContext);
    //    }
    //}
    //else
    //{
    //    NextPlayerBuyGood(pTable);
    //    WriteGoodLuckLog(pDeductRet->nUserID, pTable->m_nYqwRoomNo, GOOD_LUCK_RESULT_HAPPYCOIN_NOT_ENOUGH);
    //}
}

void CGoodLuckDelegate::OnCPExchGameGoods(int nUserID, int nStatusCode, LPEXCH_GOODS_DATA pData)
{
    USER_DATA userData;
    if (!imLookupUserData.notify(nUserID, userData))
    {
        return;
    }
    CCommonBaseTable* pTable = NULL;

    if (!(pTable = imGetTablePtr.notify(userData.nRoomID, userData.nTableNO, FALSE, 0)))
    {
        return;
    }

    if (pTable && pTable->IsYQWTable())
    {
        CAutoLock lock(&(pTable->m_csTable));
        CCommonBaseTable* pYqwCommonBaseTable = dynamic_cast<CCommonBaseTable*>(pTable);
        BUY_GOOD_LUCK_PROP goodLuckProp;
        memset(&goodLuckProp, 0, sizeof(goodLuckProp));
        goodLuckProp.nUserID = nUserID;
        if (!(nStatusCode == 0 || nStatusCode == 2001))
        {
            NextPlayerBuyGood(pTable);
            WriteGoodLuckLog(nUserID, pTable->m_nYqwRoomNo, GOOD_LUCK_RESULT_HAPPYCOIN_NOT_ENOUGH);
            UwlLogFile(_T("userid = %d, statusCode = %d"), nUserID, nStatusCode);

            CPlayer* pPlayer = pTable->GetPlayer(nUserID);
            if (pPlayer)
            {
                goodLuckProp.nResult = GOOD_LUCK_RESULT_HAPPYCOIN_NOT_ENOUGH;
                imNotifyOneUser.notify(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(goodLuckProp), FALSE);
            }
        }
        else
        {
            //pYqwCommonBaseTable->m_pGoodLuckModel->SetGoodLuckPropUserID(nUserID);
            goodLuckProp.nResult = 1;
            imNotifyTablePlayers.notify(pTable, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(BUY_GOOD_LUCK_PROP),0, FALSE);
            imNotifyTableVisitors.notify(pTable, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(BUY_GOOD_LUCK_PROP),0, FALSE);

            WriteGoodLuckLog(nUserID, pTable->m_nYqwRoomNo, GOOD_LUCK_RESULT_PAY);


            CPlayer* pPlayer = pTable->GetPlayer(nUserID);
            if (pPlayer)
            {
                LPCONTEXT_HEAD lpContext = new CONTEXT_HEAD;
                lpContext->hSocket = pPlayer->m_hSocket;
                lpContext->lTokenID = pPlayer->m_lTokenID;
                //m_pServer->m_pTaskDelegate->UpdateTaskRecordByAddParam(lpContext, pTable, pPlayer->m_nChairNO, TASK_GAME_GOOD_LUCK_COUNT);
                SAFE_DELETE(lpContext);
            }
        }
    }
}

void CGoodLuckDelegate::OnHourTriggered()
{
	SYSTEMTIME tm;
	ZeroMemory(&tm, sizeof(tm));
	GetLocalTime(&tm);
    if (tm.wHour == 0)
    {
        /*int lastGoodLuckDate = m_nCurrentGoodLuckDate;
        CString strDateTime;
        CTime tmpTime = CTime::GetCurrentTime();
        strDateTime = tmpTime.Format("%Y%m%d");
        m_nCurrentGoodLuckDate = atoi(strDateTime);

        CRedisMgr* pRedisMgr = m_pServer->GetRedisContext();

        CString strCommand;
        strCommand.Format("DEL GoodLuckUserCount:%d ", lastGoodLuckDate);

        if (pRedisMgr)
        {
            pRedisMgr->RedisCommand((LPCTSTR)strCommand);
        }
        strCommand.Format("DEL GoodLuckFreeCount:%d ", lastGoodLuckDate);
        if (pRedisMgr)
        {
            pRedisMgr->RedisCommand((LPCTSTR)strCommand);
        }*/
    }
}

void CGoodLuckDelegate::NextPlayerBuyGood(CCommonBaseTable* pTable)
{
    //CCommonBaseTable* pYqwCommonBaseTable = (CCommonBaseTable*)pTable;
    //pYqwCommonBaseTable->m_pGoodLuckModel->SetGoodLuckPropUserID(0);
    //BUY_GOOD_LUCK_PROP nextBuyGoodLuckProp = pYqwCommonBaseTable->m_pGoodLuckModel->PopWaitBuyGoodLuckUserID();
    //EXCH_GAME_GOODS goods = pYqwCommonBaseTable->m_pGoodLuckModel->PopWaitExchGameGoods();
    //if (nextBuyGoodLuckProp.nUserID > 0)
    //{
    //    BuyGoodLuckProp(pTable, nextBuyGoodLuckProp.nUserID, nextBuyGoodLuckProp.nHappyCoin, goods);
    //}
}

void CGoodLuckDelegate::BuyGoodLuckProp(CCommonBaseTable* pTable, int userid, int nHappyCoin, EXCH_GAME_GOODS goods)
{
    //CRedisMgr* pRedisMgr = m_pServer->GetRedisContext();
    //int freeCount = GetPrivateProfileInt(_T("GoodLuck"), _T("freeCount"), 0, GetINIFileName());
    //int useCount = 0;
    //int haveFreeCount = 0;
    //{
    //    CString strCommand;
    //    CString strValue;
    //    strCommand.Format("HGET GoodLuckUserCount:%d %d", m_nCurrentGoodLuckDate, userid);
    //    if (pRedisMgr)
    //    {
    //        strValue = pRedisMgr->RedisCommand((LPCTSTR)strCommand);
    //        useCount = atoi(strValue);
    //    }

    //    strCommand.Format("HGET GoodLuckFreeCount:%d %d", m_nCurrentGoodLuckDate, userid);
    //    if (pRedisMgr)
    //    {
    //        strValue = pRedisMgr->RedisCommand((LPCTSTR)strCommand);
    //        haveFreeCount = atoi(strValue);
    //    }
    //}
    //if (useCount < freeCount || haveFreeCount > 0)
    //{
    //    {
    //        CString strCommand;
    //        strCommand.Format("HINCRBY GoodLuckUserCount:%d %d %d", m_nCurrentGoodLuckDate, userid, 1);
    //        if (pRedisMgr)
    //        {
    //            pRedisMgr->RedisCommand((LPCTSTR)strCommand);
    //        }
    //        if (useCount >= freeCount)
    //        {
    //            strCommand.Format("HINCRBY GoodLuckFreeCount:%d %d %d", m_nCurrentGoodLuckDate, userid, -1);
    //            if (pRedisMgr)
    //            {
    //                pRedisMgr->RedisCommand((LPCTSTR)strCommand);
    //            }
    //        }
    //    }
    //    ((CCommonBaseTable*)pTable)->m_pGoodLuckModel->SetGoodLuckPropUserID(userid);
    //    BUY_GOOD_LUCK_PROP goodLuckProp;
    //    memset(&goodLuckProp, 0, sizeof(goodLuckProp));
    //    goodLuckProp.nUserID = userid;
    //    goodLuckProp.nResult = 1;
    //    m_pServer->NotifyTablePlayers(pTable, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(BUY_GOOD_LUCK_PROP));
    //    m_pServer->NotifyTableVisitors(pTable, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(BUY_GOOD_LUCK_PROP));

    //    WriteGoodLuckLog(userid, pTable->m_nYqwRoomNo, GOOD_LUCK_RESULT_FREE);
    //}
    //else
    //{
    //    int price = GetPrivateProfileInt(_T("GoodLuck"), _T("price"), 20, GetINIFileName());
    //    if ((pTable->m_nYqwHistoryBoutCount <= 0 || (pTable->IsYQWAsLap() && pTable->m_nYqwLapCount > 1 && (pTable->m_nYqwHistoryBoutCount - 1) % pTable->m_nYqwBoutPerRound == 0))
    //        && (nHappyCoin - price) < pTable->YQW_CalcDeductHappyCoin())
    //    {
    //        CPlayer* pPlayer = pTable->GetPlayer(userid);
    //        if (pPlayer)
    //        {
    //            BUY_GOOD_LUCK_PROP goodLuckProp;
    //            memset(&goodLuckProp, 0, sizeof(goodLuckProp));
    //            goodLuckProp.nUserID = userid;
    //            goodLuckProp.nResult = GOOD_LUCK_RESULT_ROOM_CHARGE_TOO_MORE;
    //            m_pServer->NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_BUY_GOOD_LUCK_PROP, &goodLuckProp, sizeof(goodLuckProp));

    //            NextPlayerBuyGood(pTable);
    //        }
    //        return;
    //    }

    //    ((CCommonBaseTable*)pTable)->m_pGoodLuckModel->SetGoodLuckPropUserID(-1);

    //    if (goods.nUserID > 0)
    //    {
    //        CONTEXT_HEAD context;
    //        memset(&context, 0, sizeof(context));
    //        goods.nCurrency = price;
    //        goods.nGoodsId = GetPrivateProfileInt(_T("GoodLuck"), _T("goodsId"), 0, GetINIFileName());
    //        REQUEST request;
    //        memset(&request, 0, sizeof(request));
    //        request.head.nRequest = MR_EXCH_GAME_GOODS;
    //        request.nDataLen = sizeof(EXCH_GAME_GOODS);
    //        request.pDataPtr = &goods;
    //        m_pServer->OnExchGameGoods(&context, &request, NULL);
    //    }
    //    else
    //    {
    //        CYQWGameData yqwGameData;
    //        if (!m_pServer->YQW_LookupGameData(pTable->m_nRoomID, pTable->m_nTableNO, yqwGameData))
    //        {
    //            return;
    //        }
    //        //生成订单号;
    //        TCHAR szBusinessOrderCode[MAX_HAPPYCOIN_BUSINESSORDER_LEN];
    //        SYSTEMTIME sysTime;
    //        GetLocalTime(&sysTime);
    //        int sprintfLen = _stprintf_s(szBusinessOrderCode, _T("%d%s%02d%02d%02d%03d%04d%02d%02d"), userid, "goodluck",
    //                sysTime.wHour, sysTime.wMinute, sysTime.wSecond, sysTime.wMilliseconds, sysTime.wYear, sysTime.wMonth, sysTime.wDay);

    //        m_pServer->YQW_EjectDeductHappyCoinFull(pTable, price, userid, EHCDOC_ITEM, GOOD_LUCK_DEDUCT, szBusinessOrderCode);
    //    }
    //}
}

BOOL CGoodLuckDelegate::OnShowGoodLuckProp(CCommonBaseTable* pTable)
{
	auto* com = pTable->m_entity.component<CGoodLuckModel>();
    int goodLuckPropUserID = com->GetGoodLuckPropUserID();
    if (goodLuckPropUserID > 0)
    {
        SHOW_GOOD_LUCK_PROP showGoodLuckProp;
        memset(&showGoodLuckProp, 0, sizeof(showGoodLuckProp));
        showGoodLuckProp.nUserID = goodLuckPropUserID;
		imNotifyTablePlayers.notify(pTable, GR_SHOW_GOOD_LUCK_PROP, &showGoodLuckProp, sizeof(SHOW_GOOD_LUCK_PROP), 0, FALSE);

		imNotifyTableVisitors.notify(pTable, GR_SHOW_GOOD_LUCK_PROP, &showGoodLuckProp, sizeof(SHOW_GOOD_LUCK_PROP), 0, FALSE);
		com->SetGoodLuckPropUserID(0);
    }
    return TRUE;
}

BOOL CGoodLuckDelegate::OnSendGoodLuckPropStateWhenGameWin(CCommonBaseTable* pTable)
{
	
	int freeCount = 0;
	imGetIniInt("GoodLuck", "freeCount", freeCount);

	int price = 20;
	imGetIniInt("GoodLuck", "price", price);
	
    for (int i = 0; i < pTable->m_nTotalChairs; ++i)
    {
        CPlayer* ptrPlayer = pTable->m_ptrPlayers[i];
        if (ptrPlayer)
        {
            GOOD_LUCK_PROP_STATE goodLuckPropState;
            memset(&goodLuckPropState, 0, sizeof(goodLuckPropState));
            goodLuckPropState.nUserID = ptrPlayer->m_nUserID;
            goodLuckPropState.nAmount = price;

			/*            CRedisMgr* pRedisMgr = m_pServer->GetRedisContext();
            CString strCommand;
            CString strValue;
            int useCount = 0;
            {
                strCommand.Format("HGET GoodLuckUserCount:%d %d", m_nCurrentGoodLuckDate, ptrPlayer->m_nUserID);
                if (pRedisMgr)
                {
                    strValue = pRedisMgr->RedisCommand((LPCTSTR)strCommand);
                }
                useCount = atoi(strValue);
            }
            goodLuckPropState.nFreeCount = 0;
            if (freeCount - useCount > 0)
            {
                goodLuckPropState.nFreeCount = freeCount - useCount;
            }
            strCommand.Format("HGET GoodLuckFreeCount:%d %d", m_nCurrentGoodLuckDate, ptrPlayer->m_nUserID);
            int haveFreeCount = 0;
            if (pRedisMgr)
            {
                strValue = pRedisMgr->RedisCommand((LPCTSTR)strCommand);
                haveFreeCount = atoi(strValue);
            }
			goodLuckPropState.nFreeCount += haveFreeCount;
			*/

            goodLuckPropState.nNoticeType = 1;
            imNotifyOneUser.notify(ptrPlayer->m_hSocket, ptrPlayer->m_lTokenID, GR_GOOD_LUCK_PROP_STATE, &goodLuckPropState, sizeof(goodLuckPropState), FALSE);
        }
    }
	auto* com = pTable->m_entity.component<CGoodLuckModel>();
	com->CleanWaitBuyGoodLuckUserID();
    return TRUE;
}

BOOL CGoodLuckDelegate::OnSendGoodLuckPropStateByPlayer(CCommonBaseTable* pTable, CPlayer* pPlayer)
{
    /*int freeCount = GetPrivateProfileInt(_T("GoodLuck"), _T("freeCount"), 0, GetINIFileName());
    int price = GetPrivateProfileInt(_T("GoodLuck"), _T("price"), 20, GetINIFileName());
    if (pPlayer)
    {
        GOOD_LUCK_PROP_STATE goodLuckPropState;
        memset(&goodLuckPropState, 0, sizeof(goodLuckPropState));
        goodLuckPropState.nUserID = pPlayer->m_nUserID;
        goodLuckPropState.nAmount = price;

        CRedisMgr* pRedisMgr = m_pServer->GetRedisContext();
        CString strCommand;
        CString strValue;
        int useCount = 0;
        {
            strCommand.Format("HGET GoodLuckUserCount:%d %d", m_nCurrentGoodLuckDate, pPlayer->m_nUserID);
            if (pRedisMgr)
            {
                strValue = pRedisMgr->RedisCommand((LPCTSTR)strCommand);
            }
            useCount = atoi(strValue);
        }
        goodLuckPropState.nFreeCount = 0;
        if (freeCount - useCount > 0)
        {
            goodLuckPropState.nFreeCount = freeCount - useCount;
        }

        strCommand.Format("HGET GoodLuckFreeCount:%d %d", m_nCurrentGoodLuckDate, pPlayer->m_nUserID);
        int haveFreeCount = 0;
        if (pRedisMgr)
        {
            strValue = pRedisMgr->RedisCommand((LPCTSTR)strCommand);
            haveFreeCount = atoi(strValue);
        }
        goodLuckPropState.nFreeCount += haveFreeCount;
        goodLuckPropState.nGoodLuckUserID = ((CCommonBaseTable*)pTable)->m_pGoodLuckModel->GetGoodLuckPropUserID();

        m_pServer->NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_GOOD_LUCK_PROP_STATE, &goodLuckPropState, sizeof(goodLuckPropState));
    }*/

    return TRUE;
}

void CGoodLuckDelegate::AddGoodLuckPropFreeCount(int userid, int count /* = 1 */)
{
    /*CRedisMgr* pRedisMgr = m_pServer->GetRedisContext();
    CString strCommand;
    strCommand.Format("HINCRBY GoodLuckFreeCount:%d %d %d", m_nCurrentGoodLuckDate, userid, count);
    if (pRedisMgr)
    {
        pRedisMgr->RedisCommand((LPCTSTR)strCommand);
    }*/
}

void CGoodLuckDelegate::WriteGoodLuckLog(int userid, int roomNo, int result)
{
    CTime t = CTime::GetCurrentTime();
    CString strLogName;
    strLogName.Format("GoodLuckLog_%d%02d%02d.log", t.GetYear(), t.GetMonth(), t.GetDay());
    CString strLogTitle;
    strLogTitle.Format("时间,ID,RoomID,购买结果\r\n");
    CString strLogData;
    strLogData.Format("%02d:%02d:%02d,%d,%d,%d\r\n", t.GetHour(), t.GetMinute(), t.GetSecond(), userid, roomNo, result);
    void WriteGameServerLog(CString logName, CString logTitle, CString logData);
    WriteGameServerLog(strLogName, strLogTitle, strLogData);
}