#include "stdafx.h"

CReplayDelegate::CReplayDelegate(CCommonBaseServer* pServer)
    : CModuleDelegate(pServer)
{
}

CReplayDelegate::~CReplayDelegate()
{
}


void CReplayDelegate::OnHourTriggered(int wHour)
{
    if (wHour == 0)
    {
        int nThreadID = 0;
        //if (m_pServer->m_pReplaySave)
        //{
        //    nThreadID = m_pServer->m_pReplaySave->GetThreadID();
        //}

        //if (IsReplayActive() && nThreadID)
        //{
        //    int nSaveDay = GetPrivateProfileInt(_T("Replay"), _T("SaveDay"), 7, GetINIFileName());
        //    PostThreadMessage((ULONG)(m_pServer->m_pReplaySave)->GetThreadID(), UM_CLEAR_REPLAYFILE, nSaveDay, 0);
        //}
    }
}

BOOL CReplayDelegate::IsRoomReplayActive(int nRoomID)
{
    if (!IsReplayActive())
    {
        return FALSE;
    }

    std::string sRoomID;
    std::stringstream ss;
    ss << nRoomID;
    ss >> sRoomID;

    BOOL bActive = GetPrivateProfileInt(_T("Replay"), sRoomID.c_str(), 1, GetINIFileName());
    return bActive;
}

void CReplayDelegate::SaveReplayHeadAndTableInfo(CTable* pTable)
{
    SaveReplayHeadInfo(pTable);
    SaveReplayTableInfo(pTable);
    //((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord.ResetHeadValue();
}

void CReplayDelegate::SaveReplayHeadInfo(CTable* pTable)
{
    REP_HEAD stRepHead;
    memset(&stRepHead, 0, sizeof(REP_HEAD));
    strcpy_s(stRepHead.Mark, REPLAY_MARK);
    strcpy_s(stRepHead.szGameName, GAME_CLIENT);
    stRepHead.nGameID = GAME_ID;
    stRepHead.GameVesion.nMajorVer = GetMajorVersion();
    stRepHead.GameVesion.nMinorVer = GetMinorVersion();
    stRepHead.nTotalStep = -1;
    stRepHead.dwUnCompressLen = 0;

    stRepHead.nChairNO = pTable->m_nBanker; // 默认以庄家位置玩家的视角
    stRepHead.nUserID = 0;
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (stRepHead.nChairNO == i && pPlayer)
        {
            stRepHead.nUserID = pPlayer->m_nUserID;
            break;
        }
    }

    CTime timeEnd = CTime::GetCurrentTime();
    stRepHead.dwEndDate = timeEnd.GetYear() * 10000 + timeEnd.GetMonth() * 100 + timeEnd.GetDay();
    stRepHead.dwEndTime = timeEnd.GetHour() * 10000 + timeEnd.GetMinute() * 100 + timeEnd.GetSecond();

    //CTimeSpan timeSpan(0, 0, 0, ((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord.GetTotalTickCount() / 1000);
    //CTime timeStart = timeEnd - timeSpan;
    //stRepHead.dwStartDate = timeStart.GetYear() * 10000 + timeStart.GetMonth() * 100 + timeStart.GetDay();
    //stRepHead.dwStartTime = timeStart.GetHour() * 10000 + timeStart.GetMinute() * 100 + timeStart.GetSecond();

    //((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord.PushHead(&stRepHead, sizeof(stRepHead));
}

int CReplayDelegate::YQW_OpeSaveReplayData(CTable* pTable)
{
    //if (IsReplayActive() && ((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord.IsAcitve())
    //{
    //    SaveReplayHeadAndTableInfo(pTable);
    ////    if (m_pServer->m_pReplaySave)
    ////    {
    ////        m_pServer->m_pReplaySave->Push(((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord);
    ////    }
    //}
    //int headSize = ((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord.GetHeadSize();
    //int dataSize = ((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord.GetDataSize();

    //int dataLen = headSize + dataSize;
    //BYTE* pData = new BYTE[dataLen];
    //if (NULL == pData)
    //{
    //    UwlLogFile(_T("WriteToFile new failed!"));
    //    return FALSE;
    //}
    //memset(pData, 0, dataLen);

    //memcpy(pData, ((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord.GetHeadBuff(), headSize);
    //memcpy(pData + headSize, ((CCommonBaseTable*)pTable)->m_pReplayModel->m_ReplayRecord.GetDataBuff(), dataSize);

    //try
    //{
    //    WriteDataFile(pTable->m_szYqwLocalReplay, pData, dataLen);
    //}
    //catch (...)
    //{
    //    UwlLogFile(_T("ReplayRecord model error, WriteDataFile failed!"));
    //    SAFE_DELETE_ARRAY(pData);
    //    return FALSE;
    //}
    //SAFE_DELETE_ARRAY(pData);
    return TRUE;
}

void CReplayDelegate::NotifyTableVisitors(CTable* pTable, UINT nRequest, void* pData, int nLen)
{
    if (!m_pServer->IsYQWRoom(pTable->m_nRoomID))
    {
        return;
    }

    CCommonBaseTable* pCommonBaseTable = dynamic_cast<CCommonBaseTable*>(pTable);
    /*if (pCommonBaseTable->m_pReplayModel->m_ReplayRecord.NeedSave() && RequestNeedRecord(nRequest))
    {
        REP_STEP stRepStep;
        memset(&stRepStep, 0, sizeof(stRepStep));
        stRepStep.dwTickCount = GetTickCount();
        stRepStep.nSize = nLen;
        stRepStep.nRequestID = nRequest;

        pCommonBaseTable->m_pReplayModel->m_ReplayRecord.PushStep(&stRepStep, sizeof(stRepStep));
        pCommonBaseTable->m_pReplayModel->m_ReplayRecord.PushData(pData, nLen);
    }*/
}

void CReplayDelegate::OnCPOnGameStarted(CTable* pTable, void* pData)
{
    // 录像
    if (IsRoomReplayActive(pTable->m_nRoomID) && m_pServer->IsYQWRoom(pTable->m_nRoomID))
    {
        //int nLen = 0;
        //nLen = pTable->GetGameStartSize();

        //CCommonBaseTable* pCommonYqwTable = dynamic_cast<CCommonBaseTable*>(pTable);
        //pCommonYqwTable->m_pReplayModel->m_ReplayRecord.Clear();
        //pCommonYqwTable->m_pReplayModel->m_ReplayRecord.SetRoomAndTableNO(pCommonYqwTable->m_nRoomID, pCommonYqwTable->m_nTableNO);

        //pCommonYqwTable->m_pReplayModel->m_ReplayRecord.SetAcitve(TRUE);
        //if (IsReplayDefSave())
        //{
        //    pCommonYqwTable->m_pReplayModel->m_ReplayRecord.SetSave(TRUE);
        //}

        //REP_STEP stRepStep;
        //memset(&stRepStep, 0, sizeof(stRepStep));
        //stRepStep.dwTickCount = 0;
        //stRepStep.nSize = nLen;
        //stRepStep.nRequestID = GR_GAME_START;

        //pCommonYqwTable->m_pReplayModel->m_ReplayRecord.PushStep(&stRepStep, sizeof(stRepStep));
        //pCommonYqwTable->m_pReplayModel->m_ReplayRecord.PushData(pData, nLen);

        //FillupReplayInitialData(pCommonYqwTable);
    }
}

void CReplayDelegate::OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CTable* pTable, void* pData)
{
    int nTableSize = sizeof(SOLO_TABLE) + pStartSoloTable->nUserCount * sizeof(SOLO_PLAYER);
    int nStartSize = pTable->GetGameStartSize();
    int nLen = nStartSize + nTableSize;
    //***********************************录像***********************************/
    if (IsRoomReplayActive(pTable->m_nRoomID) && m_pServer->IsYQWRoom(pTable->m_nRoomID))
    {
        //CCommonBaseTable* pGameTable = (CCommonBaseTable*)pTable;
        //pGameTable->m_pReplayModel->m_ReplayRecord.Clear();
        //pGameTable->m_pReplayModel->m_ReplayRecord.SetRoomAndTableNO(pGameTable->m_nRoomID, pGameTable->m_nTableNO);

        //pGameTable->m_pReplayModel->m_ReplayRecord.SetAcitve(TRUE);
        //if (IsReplayDefSave())
        //{
        //    pGameTable->m_pReplayModel->m_ReplayRecord.SetSave(TRUE);
        //}

        //REP_STEP stRepStep;
        //memset(&stRepStep, 0, sizeof(stRepStep));
        //stRepStep.dwTickCount = 0;
        //stRepStep.nSize = nLen;
        //stRepStep.nRequestID = GR_START_SOLOTABLE;

        //pGameTable->m_pReplayModel->m_ReplayRecord.PushStep(&stRepStep, sizeof(stRepStep));
        //pGameTable->m_pReplayModel->m_ReplayRecord.PushData(pData, nLen);

        //FillupReplayInitialData(pGameTable);
    }
    //***********************************录像************************************/
}

void CReplayDelegate::YQW_OpeSaveGameWinData(CTable* pTable, UINT nRequest, void* _pData, int _nLen, LONG tokenExcept /*= 0*/, BOOL compressed /*= FALSE*/)
{
    //针对一起玩  特殊结构体处理
    void* pData = (BYTE*)_pData + sizeof(GAME_WIN);
    int nLen = _nLen - sizeof(GAME_WIN);

    CCommonBaseTable* pGameTable = dynamic_cast<CCommonBaseTable*>(pTable);

    //if (pGameTable->m_pReplayModel->m_ReplayRecord.NeedSave() && RequestNeedRecord(nRequest))
    //{
    //    REP_STEP stRepStep;
    //    memset(&stRepStep, 0, sizeof(stRepStep));
    //    stRepStep.dwTickCount = GetTickCount();
    //    stRepStep.nSize = nLen;
    //    stRepStep.nRequestID = nRequest;

    //    pGameTable->m_pReplayModel->m_ReplayRecord.PushStep(&stRepStep, sizeof(stRepStep));
    //    pGameTable->m_pReplayModel->m_ReplayRecord.PushData(pData, nLen);
    //}
}

void CReplayDelegate::OnCPDealReplayGameWinData(CTable* pTable, void* pData, int nLen)
{
    auto pCommonBaseTable = dynamic_cast<CCommonBaseTable*>(pTable);

    //if (pCommonBaseTable->IsYQWTable() && IsReplayActive() && pCommonBaseTable->m_pReplayModel->m_ReplayRecord.IsAcitve())
    //{
    //    //memcpy(pCommonBaseTable->m_pReplayModel->m_nReplayYQWScore, pTable->m_nYqwScores, sizeof(pCommonBaseTable->m_pReplayModel->m_nReplayYQWScore));
    //    YQW_OpeSaveGameWinData(pTable, GR_YQW_GAME_WIN, pData, nLen, 0, TRUE);
    //    YQW_OpeSaveReplayData(pTable);
    //}
}

void CReplayDelegate::OnGameWin(CTable* pTable)
{
    CCommonBaseTable* pGameTable = dynamic_cast<CCommonBaseTable*>(pTable);

    if (!pGameTable->IsYQWTable())
    {
        return;
    }
    //if (IsReplayActive() && pGameTable->m_pReplayModel->m_ReplayRecord.IsAcitve())
    //{
    //    SaveReplayHeadAndTableInfo(pGameTable);
    ////    if (m_pServer->m_pReplaySave)
    ////    {
    ////        m_pServer->m_pReplaySave->Push(pGameTable->m_pReplayModel->m_ReplayRecord);
    ////    }
    //}
}

int CReplayDelegate::YQW_OpeSaveErrorReplayData(CTable* pTable, DWORD dwAbortFlag)
{
    //LOG_TRACE(_T("YQW_OpeSaveErrorReplayData"));
    //CCommonBaseTable* pCommonBaseTable = dynamic_cast<CCommonBaseTable*>(pTable);
    //if (!pCommonBaseTable->m_pReplayModel->m_ReplayRecord.IsAcitve() || m_pServer->m_pReplaySave == NULL)
    //{
    //    return FALSE;
    //}

    //SaveReplayHeadAndTableInfo(pTable);
    //m_pServer->m_pReplaySave->Push(pCommonBaseTable->m_pReplayModel->m_ReplayRecord);

    //int headSize = pCommonBaseTable->m_pReplayModel->m_ReplayRecord.GetHeadSize();
    //int dataSize = pCommonBaseTable->m_pReplayModel->m_ReplayRecord.GetDataSize();

    //int dataLen = headSize + dataSize;
    //BYTE* pData = new BYTE[dataLen];
    //if (NULL == pData)
    //{
    //    UwlLogFile(_T("WriteToFile new failed!"));
    //    return FALSE;
    //}
    //memset(pData, 0, dataLen);

    //memcpy(pData, pCommonBaseTable->m_pReplayModel->m_ReplayRecord.GetHeadBuff(), headSize);
    //memcpy(pData + headSize, pCommonBaseTable->m_pReplayModel->m_ReplayRecord.GetDataBuff(), dataSize);

    ////构造文件路径和文件名
    //CString strSavePath = m_pServer->m_pReplaySave->BuildDaySavePath();
    //strSavePath.TrimRight('\\');
    //strSavePath += '\\';
    //SYSTEMTIME timeNow;
    //GetLocalTime(&timeNow);
    //CString strFileName;
    //strFileName.Format(_T("%s_房间号%d_异常标志%d_%04d年%02d月%02d日%02d时%02d分%02d秒%s")
    //    , GAME_APPNAME
    //    , pTable->m_nYqwRoomNo
    //    , dwAbortFlag
    //    , timeNow.wYear
    //    , timeNow.wMonth
    //    , timeNow.wDay
    //    , timeNow.wHour
    //    , timeNow.wMinute
    //    , timeNow.wSecond
    //    , REPLAY_SUFFIXES
    //);
    //strSavePath += strFileName;

    ////CString strFilePth = BuildFilePath(strSavePath);
    //try
    //{
    //    BOOL bRet = WriteDataFile(strSavePath.GetBuffer(0), pData, dataLen);
    //    BOOL bAddRule = (GetPrivateProfileInt(_T("replay"), _T("addrule"), FALSE, GetINIFileName()) != 0);
    //    if (bAddRule)
    //    {
    //        CYQWGameData yqwGameData;
    //        if (!m_pServer->YQW_LookupGameData(pTable->m_nRoomID, pTable->m_nTableNO, yqwGameData))
    //        {
    //            return FALSE;
    //        }

    //        CFile fLocalReplay;
    //        if (!fLocalReplay.Open(strSavePath.GetBuffer(0), CFile::modeWrite))
    //        {
    //            UwlLogFile(_T("extend replay file failed"));
    //            return FALSE;
    //        }

    //        DWORD dwExtendOffset = fLocalReplay.GetLength();
    //        DWORD dwExtendSign = YQW_REPLAY_EXTEND_SIGN;
    //        DWORD dwExtendLabel = YQW_REPLAY_LABEL_RULE;
    //        DWORD dwExtendLength = yqwGameData.baRuleData.GetSize();

    //        fLocalReplay.SeekToEnd();
    //        fLocalReplay.Write(&dwExtendSign, sizeof(dwExtendSign));
    //        fLocalReplay.Write(&dwExtendLabel, sizeof(dwExtendLabel));
    //        fLocalReplay.Write(&dwExtendLength, sizeof(dwExtendLength));
    //        if (dwExtendLength > 0)
    //        {
    //            fLocalReplay.Write(yqwGameData.baRuleData.GetData(), dwExtendLength);
    //        }
    //        fLocalReplay.Write(&dwExtendOffset, sizeof(dwExtendOffset));
    //        fLocalReplay.Close();
    //    }
    //}

    //catch (...)
    //{
    //    UwlLogFile(_T("ReplayRecord model error, WriteDataFile failed!"));
    //    SAFE_DELETE_ARRAY(pData)
    //    return FALSE;
    //}

    //if (pData)
    //{
    //    delete[]
    //    pData;
    //    pData = NULL;
    //}
    return TRUE;
}
