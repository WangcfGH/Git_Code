#include "stdafx.h"
#include <stdio.h>
#include "DataRecord.h"
#ifdef _DEBUG
    #define new DEBUG_NEW
#endif

const int USER_MAX_COLUMNS = 6;
const CString USER_TITLES[USER_MAX_COLUMNS] = {"�û�ID", "�û�����", "����Ӯȡ��", "����", "��ˮ��", "ʣ������"};
const int ROOM_MAX_COLUMNS = 4;
const CString  ROOM_TITLES[ROOM_MAX_COLUMNS] = {"����ID", "����", "��ˮ��", "��Ծ����"};
const int TABLE_MAX_COLUMNS = 5;
const CString  TABLE_TITLES[TABLE_MAX_COLUMNS] = {"����ID", "�����������", "����", "��ˮ��", "��Ծ����"};
const CString USER_TYPE[2] = {"PC��", "�ƶ���"};
const int ROOM_KEY_MULTI_NUM = 1000;

enum
{
    PlayerInfoStart = 1,
    TableInfoStart,
    RoomInfoStart,
};

DataRecord::DataRecord(CString strIniFile, CMyGameServer* pServer)
{
    m_szIniFile = strIniFile;
    m_gameSvr = pServer;
}

DataRecord::~DataRecord()
{
    SaveInfos(TRUE);
}

void DataRecord::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret)
    {
        init();
    }
}

void DataRecord::OnShutDown()
{
    SaveInfos(TRUE);
}

void DataRecord::OnCPGameWin(LPCONTEXT_HEAD lpContext, int roomid, CCommonBaseTable* pTable, void* pData)
{
    UpdateRoomBout(roomid, pTable->m_nTableNO);
}

void DataRecord::OnTransmitGameResultEx(CCommonBaseTable* pTable, LPCONTEXT_HEAD lpContext, LPREFRESH_RESULT_EX lpRefreshResult, LPGAME_RESULT_EX lpGameResult, int nGameResultSize)
{
    UpdateInfos(pTable, lpRefreshResult, lpGameResult);
}

void DataRecord::init()
{
    ResetInfos();
    ReadInfos();
}

void DataRecord::ResetInfos()
{
    CAutoLock lock(&m_csInfo);
    m_roomInfos.clear();
    m_playerInfos.clear();
    m_dwTimeLastSave = 0;
}

void DataRecord::UpdateInfos(CTable* pTable, LPREFRESH_RESULT_EX lpRefreshResult, LPGAME_RESULT_EX lpGameResult)
{
    if (!lpGameResult || !lpGameResult || lpRefreshResult->nResultCount <= 0)
    {
        return;
    }

    CString strRecordFile = GetRecordFile();
    if (m_strRecordFile != strRecordFile)
    {
        //�ļ������ڣ����߱�����ļ���ԭ�������ϣ����´����ļ����������
        m_strRecordFile = strRecordFile;
        ResetInfos();
    }

    {
        CAutoLock lock(&m_csInfo);
        for (int i = 0; i < lpRefreshResult->nResultCount; i++)
        {
            LPGAME_RESULT_EX lpgr = LPGAME_RESULT_EX((PBYTE)lpGameResult + i * sizeof(GAME_RESULT_EX));
            //���������Ϣ
            PlayerInfo& playerInfo = m_playerInfos[lpgr->nUserID];
            playerInfo.nUserType = pTable->m_ptrPlayers[lpgr->nChairNO]->m_nUserType;
            playerInfo.nDeposit = max(lpgr->nOldDeposit + lpgr->nDepositDiff, 0);
            playerInfo.nBout += lpgr->nBout;
            playerInfo.nFee += lpgr->nFee;
            playerInfo.nWinDeposit += lpgr->nDepositDiff > 0 ? lpgr->nDepositDiff + lpgr->nFee : 0;

            //���·�����Ϣ
            int key = GetRoomKeyByNo(lpgr->nRoomID, lpgr->nTableNO);
            RoomInfo& roomInfo = m_roomInfos[key];
            roomInfo.userIds.insert(lpgr->nUserID);
            roomInfo.nFee += lpgr->nFee;
        }
    }


    //SaveInfos();
}

void DataRecord::UpdateRoomBout(int roomid, int tableno)
{
    {
        CAutoLock lock(&m_csInfo);
        RoomInfo& roomInfo = m_roomInfos[GetRoomKeyByNo(roomid, tableno)];
        roomInfo.nBout++;
    }
    SaveInfos();
}

void DataRecord::SaveInfos(BOOL force /* = FALSE */)
{
    try
    {
        CAutoLock lock(&m_csInfo);

        CString fileName = GetRecordFile();


        int nTimeSaveInterval = GetPrivateProfileInt(_T("DataRecordParams"), _T("timeInterval"), 180, m_szIniFile);
        if (!force && GetTickCount() - m_dwTimeLastSave < nTimeSaveInterval * 1000)
        {
            return;
        }
        m_dwTimeLastSave = GetTickCount();


        /////////////////////////////////////////////////////////////////////////////////////
        CStdioFile file;                                                //�ļ�����
        file.Open(fileName, CFile::modeCreate | CFile::modeWrite | CFile::shareDenyNone);

        UINT minlen = 20;
        const int ncRow = max(GetPrivateProfileInt(_T("DataRecordParams"), _T("formatLen"), minlen, m_szIniFile), minlen);          //ÿ��������ռ��
        CString strWrite;               //��д�������

        //======================================================
        // �����Ϣ
        //title
        CString tempStrs[USER_MAX_COLUMNS];
        int i = 0;
        for (i = 0; i < USER_MAX_COLUMNS; ++i)
        {
            tempStrs[i] = USER_TITLES[i];
        }
        strWrite = FormatOneRowStr(tempStrs, USER_MAX_COLUMNS, ncRow);
        file.WriteString(strWrite);


        //���ݲ���
        INT64 nTotalWinDeposit = 0;     //������Ӯȡ��
        INT64 nTotalFee = 0;            //�ܲ�ˮ��
        INT64 nTotalDeposit = 0;        //����ֵ����ʣ��������

        for (PlayerInfoMap::iterator iter = m_playerInfos.begin(); iter != m_playerInfos.end(); ++iter)
        {
            //д������
            int userId = iter->first;
            PlayerInfo& playerInfo = iter->second;
            tempStrs[0].Format("%d", userId);
            tempStrs[1] = USER_TYPE[IS_BIT_SET(playerInfo.nUserType, UT_HANDPHONE) ? 1 : 0];
            tempStrs[2].Format("%I64d", playerInfo.nWinDeposit);
            tempStrs[3].Format("%d", playerInfo.nBout);
            tempStrs[4].Format("%I64d", playerInfo.nFee);
            tempStrs[5].Format("%d", playerInfo.nDeposit);
            strWrite = FormatOneRowStr(tempStrs, USER_MAX_COLUMNS, ncRow);
            file.WriteString(strWrite);

            //ͳ������
            nTotalWinDeposit += playerInfo.nWinDeposit;
            nTotalFee += playerInfo.nFee;
            nTotalDeposit += playerInfo.nDeposit;
        }

        RoomInfoMap realRoomInfos;
        //==================================================
        // ������Ϣ
        //title
        file.WriteString("\r\n");
        CString tableTempStrs[TABLE_MAX_COLUMNS];
        for (i = 0; i < TABLE_MAX_COLUMNS; ++i)
        {
            tableTempStrs[i] = TABLE_TITLES[i];
        }
        strWrite = FormatOneRowStr(tableTempStrs, TABLE_MAX_COLUMNS, ncRow);
        file.WriteString(strWrite);
        //���ݲ���
        RoomInfoMap::iterator it;
        for (it = m_roomInfos.begin(); it != m_roomInfos.end(); ++it)
        {
            //д������
            int roomid, tableIndex;
            ParseRoomKey(it->first, roomid, tableIndex);
            RoomInfo& roomInfo = it->second;
            if (tableIndex > 0)
            {
                tableTempStrs[0].Format("%d", roomid);
                tableTempStrs[1].Format("%d", tableIndex);
                tableTempStrs[2].Format("%u", roomInfo.nBout);
                tableTempStrs[3].Format("%I64d", roomInfo.nFee);
                tableTempStrs[4].Format("%u", roomInfo.userIds.size());
                strWrite = FormatOneRowStr(tableTempStrs, TABLE_MAX_COLUMNS, ncRow);
                file.WriteString(strWrite);
            }

            realRoomInfos[roomid] += roomInfo;
        }

        //==================================================
        // ������Ϣ
        //title
        file.WriteString("\r\n");
        CString roomTempStrs[ROOM_MAX_COLUMNS];
        for (i = 0; i < ROOM_MAX_COLUMNS; ++i)
        {
            roomTempStrs[i] = ROOM_TITLES[i];
        }
        strWrite = FormatOneRowStr(roomTempStrs, ROOM_MAX_COLUMNS, ncRow);
        file.WriteString(strWrite);
        //���ݲ���
        DWORD nTotalBout = 0;           //�ܾ���
        for (it = realRoomInfos.begin(); it != realRoomInfos.end(); ++it)
        {
            //д������
            int roomid = it->first;
            RoomInfo& roomInfo = it->second;
            roomTempStrs[0].Format("%d", roomid);
            roomTempStrs[1].Format("%u", roomInfo.nBout);
            roomTempStrs[2].Format("%I64d", roomInfo.nFee);
            roomTempStrs[3].Format("%u", roomInfo.userIds.size());
            strWrite = FormatOneRowStr(roomTempStrs, ROOM_MAX_COLUMNS, ncRow);
            file.WriteString(strWrite);

            //ͳ������
            nTotalBout += roomInfo.nBout;
        }

        //====================================================
        //�ܺ�ͳ��
        strWrite.Format("\r\n[�ܺ�ͳ��]\r\n");
        file.WriteString(strWrite);

        strWrite.Format("��Ծ���� = %u\r\n", m_playerInfos.size());
        file.WriteString(strWrite);

        //@remark�þ��������л�Ծ�û��������ܺͣ��ǿɱ����γ���TOTAL_CHAIR���Ի��ʵ�ʾ������ɱ���������Ҫͨ��������ʽ�����������Ҫ���ʵ�ʵ��ټӽӿں���
        strWrite.Format("�ܾ��� = %u\r\n", nTotalBout);
        file.WriteString(strWrite);

        strWrite.Format("������Ӯȡ�� = %I64d\r\n", nTotalWinDeposit);
        file.WriteString(strWrite);

        INT64 nTotalCurrency = nTotalWinDeposit * 2;
        strWrite.Format("��������ͨ�� = %I64d\r\n", nTotalCurrency);
        file.WriteString(strWrite);

        strWrite.Format("�ܲ�ˮ�� = %I64d\r\n", nTotalFee);
        file.WriteString(strWrite);

        strWrite.Format("����ֵ����ʣ��������= %I64d\r\n", nTotalDeposit);
        file.WriteString(strWrite);

        double rate = nTotalCurrency != 0 ? (double)nTotalFee / (double)nTotalCurrency * 100.0 : 0.0;
        strWrite.Format("�ܲ�ˮ��/��������ͨ�� = %0.3f%%\r\n", rate);
        file.WriteString(strWrite);

        strWrite.Format("\r\n");
        file.WriteString(strWrite);

        file.Close();
    }
    catch (CException* e)
    {
        e->Delete();
    }
}

void DataRecord::ReadInfos()
{
    try
    {
        ResetInfos();
        CAutoLock lock(&m_csInfo);
        CString strRecordFile = GetRecordFile();
        m_strRecordFile = strRecordFile;
        CFileFind fFind;                                //�ļ�����
        if (!fFind.FindFile(strRecordFile))
        {
            //�ļ������ڣ����ö�ȡ
            return;
        }


        ///////////////////////////////////////////////////////////////////////////////////////////////////////
        //��ȡ�ļ�
        CStdioFile file;                                //�ļ�����
        file.Open(strRecordFile, CFile::modeCreate | CFile::modeNoTruncate | CFile::modeRead | CFile::shareDenyNone);

        CString strText;                                //��ȡ��ǰ�е��ı�
        CString strTemp[USER_MAX_COLUMNS];
        int dataFlag = 0;
        std::set<int> roomIDs;
        while (file.ReadString(strText))
        {
            int len = SplitStr(strTemp, max(max(USER_MAX_COLUMNS, ROOM_MAX_COLUMNS), TABLE_MAX_COLUMNS), strText, ' ', true);
            if (strTemp[1] == ROOM_TITLES[1])
            {
                dataFlag = RoomInfoStart;
            }
            else if (strTemp[1] == USER_TITLES[1])
            {
                dataFlag = PlayerInfoStart;
            }
            else if (strTemp[1] == TABLE_TITLES[1])
            {
                dataFlag = TableInfoStart;
            }

            int id = atoi(strTemp[0]);
            if (len <= 0 || id <= 0)
            {
                continue;
            }
            if (len == TABLE_MAX_COLUMNS && dataFlag == TableInfoStart)
            {
                //������Ϣ
                int tableIndex = atoi(strTemp[1]);
                RoomInfo& roomInfo = m_roomInfos[GetRoomKeyByIndex(id, tableIndex)];
                roomInfo.nBout = _atoi64(strTemp[2]);
                roomInfo.nFee = _atoi64(strTemp[3]);
                roomIDs.insert(id);
            }
            else if (len == ROOM_MAX_COLUMNS && dataFlag == RoomInfoStart)
            {
                if (roomIDs.find(id) == roomIDs.end())
                {
                    RoomInfo& roomInfo = m_roomInfos[GetRoomKeyByIndex(id, 0)];
                    roomInfo.nBout = _atoi64(strTemp[1]);
                    roomInfo.nFee = _atoi64(strTemp[2]);
                }
            }
            else if (len == USER_MAX_COLUMNS && dataFlag == PlayerInfoStart)
            {
                //�����Ϣ
                int userId = atoi(strTemp[0]);
                PlayerInfo& palyerInfo = m_playerInfos[userId];
                palyerInfo.nUserType = strTemp[1] == USER_TYPE[1] ? UT_HANDPHONE : UT_COMMON;
                palyerInfo.nWinDeposit = _atoi64(strTemp[2]);
                palyerInfo.nBout = atoi(strTemp[3]);
                palyerInfo.nFee = _atoi64(strTemp[4]);
                palyerInfo.nDeposit = atoi(strTemp[5]);
            }

        }
        file.Close();
    }
    catch (CException* e)
    {
        e->Delete();
    }
}

CString DataRecord::GetRecordFile()
{
    CTime NowTime = CTime::GetCurrentTime();
    TCHAR szFilePath[MAX_PATH];
    GetModuleFileName(NULL, szFilePath, MAX_PATH);
    *strrchr(szFilePath, '\\') = 0;
    CString strRecordFile;
    strRecordFile.Format(_T("%s\\CommonRecord%s%04d%02d%02d.log"),
        szFilePath, PRODUCT_NAME, NowTime.GetYear(), NowTime.GetMonth(), NowTime.GetDay());
    return strRecordFile;
}

void DataRecord::FormatStr(CString& str, int nFomatLen)
{
    while (str.GetLength() < nFomatLen)
    {
        str += " ";
    }
}

CString DataRecord::FormatOneRowStr(CString strs[], int len, int nFomatLen)
{
    CString retStr;
    CString tempStr;
    for (int i = 0; i < len; ++i)
    {
        tempStr = strs[i];
        if (i == len - 1)
        {
            tempStr += "\r\n";
        }
        else
        {
            FormatStr(tempStr, nFomatLen);
        }
        retStr += tempStr;
    }
    return retStr;
}

int DataRecord::SplitStr(CString outStrs[], int len, const CString& str, TCHAR splitChar /* = ' ' */, bool removeNewLine /* = true */)
{
    int count = 0;
    CString temp;
    for (int i = 0; i < str.GetLength(); ++i)
    {
        if (count >= len)
        {
            break;
        }
        TCHAR curChar = str.GetAt(i);

        if (splitChar != curChar)
        {
            temp += curChar;
        }

        if (splitChar == curChar || i == str.GetLength() - 1)
        {
            if (temp.GetLength() > 0)
            {
                if (removeNewLine)
                {
                    temp.Remove('\r');
                    temp.Remove('\n');
                }
                temp.TrimLeft();
                temp.TrimRight();
                outStrs[count++] = temp;
                temp = "";
            }
            continue;
        }
    }

    return count;
}

int DataRecord::GetRoomKeyByNo(int roomid, int tableno)
{
    return GetRoomKeyByIndex(roomid, GetTableIndex(roomid, tableno));
}

int DataRecord::GetRoomKeyByIndex(int roomid, int tableIndex)
{
    return roomid * ROOM_KEY_MULTI_NUM + tableIndex;
}

void DataRecord::ParseRoomKey(int roomKey, int& roomid, int& tableIndex)
{
    roomid = roomKey / ROOM_KEY_MULTI_NUM;
    tableIndex = roomKey % ROOM_KEY_MULTI_NUM;
}

int DataRecord::GetTableIndex(int roomid, int tableno)
{
    int ret = 0;
    if (IsTableDepositRoom(roomid))
    {
        CString sRoomSvrIniFile;
        if (!GetRoomSvrIniFile(roomid, sRoomSvrIniFile))
        {
            return ret;
        }

        TCHAR szSection[32];
        memset(szSection, 0, sizeof(szSection));
        sprintf_s(szSection, "TableDeposit%d", roomid);

        int nCount = GetPrivateProfileInt(szSection, _T("Count"), 0, sRoomSvrIniFile);
        if (nCount <= 0 || nCount > 32)
        {
            return ret;
        }

        CString sTmp;
        for (int i = 0; i < nCount; i++)
        {
            TCHAR szValue[64];
            memset(szValue, 0, sizeof(szValue));
            sTmp.Format(_T("%d"), i);
            GetPrivateProfileString(szSection, sTmp, _T(""), szValue, sizeof(szValue), sRoomSvrIniFile);
            if (szValue[0] == 0)
            {
                return ret;
            }
            TCHAR* fields[8];
            memset(fields, 0, sizeof(fields));
            TCHAR* p1, *p2;
            p1 = szValue;
            int nFields = Svr_RetrieveFields(p1, fields, 8, &p2) ;
            if (nFields < 3)
            {
                return ret;
            }

            int nTableNO1 = atoi(fields[0]);
            int nTableNO2 = atoi(fields[1]);
            if (tableno >= nTableNO1 && tableno <= nTableNO2)
            {
                return i + 1;
            }
        }
    }

    return ret;
}

//��������
BOOL DataRecord::IsTableDepositRoom(int roomid)
{
    return IS_BIT_SET(m_gameSvr->GetRoomManage(roomid), RM_TABLEDEPOSIT);
}

BOOL DataRecord::GetRoomSvrIniFile(int roomid, CString& sRoomSvrIniFile)
{
    if (roomid <= 0)
    {
        return FALSE;
    }

    HWND hRoomSvrWnd = m_gameSvr->GetRoomSvrWnd(roomid);

    if (!hRoomSvrWnd)
    {
        return FALSE;
    }

    TCHAR szTemp[MAX_PATH];
    GetModuleFileName(GetModuleHandle(NULL), szTemp, sizeof(szTemp));

    //��ȡ��ϷĿ¼
    CString sFolder;
    sFolder.Format(_T("%s"), szTemp);
    int nIndex = sFolder.ReverseFind('\\');
    if (nIndex < 0)
    {
        return FALSE;
    }
    sFolder = sFolder.Left(nIndex);
    nIndex = sFolder.ReverseFind('\\');
    if (nIndex < 0)
    {
        return FALSE;
    }
    sFolder = sFolder.Left(nIndex + 1);

    int hWnd = 0;
    TCHAR roomsvrName[32];
    GetPrivateProfileString(_T("DataRecordParams"), _T("roomSvrName"), _T("roomsvr"), roomsvrName, sizeof(roomsvrName), m_szIniFile);
    for (int i = 0; i < 16; i++)
    {
        if (i == 0)
        {
            sRoomSvrIniFile.Format(_T("%s%s\\%s.ini"), sFolder, roomsvrName, roomsvrName);
        }
        else
        {
            sRoomSvrIniFile.Format(_T("%s%s%d\\%s.ini"), sFolder, roomsvrName, i + 1, roomsvrName);
        }

        memset(szTemp, 0, sizeof(szTemp));
        GetPrivateProfileString(_T("listen"), _T("hwnd"), _T(""), szTemp, sizeof(szTemp), sRoomSvrIniFile);
        if (strlen(szTemp) > 0)
        {
            hWnd = atoi(szTemp);
            if (hWnd == (int)hRoomSvrWnd)
            {
                return TRUE;
            }
        }
    }

    return FALSE;
}



