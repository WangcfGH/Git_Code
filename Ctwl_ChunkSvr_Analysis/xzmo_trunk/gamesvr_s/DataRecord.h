#pragma once
#include <map>
#include <set>

/*
    使用说明：
        1.初始化：
            a.在Sever.cpp添加本头文件
            b.在CGameServer::Initialize函数中添加如下代码：
                DataRecord::Instance()->init(m_szIniFile, this);
                DataRecord::Instance()->ReadInfos();

        2.重载TransmitGameResultEx，添加如下代码：
            BOOL ret = __super::TransmitGameResultEx(pTable, lpContext, lpRefreshResult, lpGameResult, nGameResultSize);
            if (!ret)
                return FALSE;

            DataRecord::Instance()->UpdateInfos(pTable, lpRefreshResult, lpGameResult);
            return ret;

        3.重载OnGameWin，添加如下代码：
            BOOL ret = __super::OnGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
            if (ret && !bout_invalid)
            {
                DataRecord::Instance()->UpdateRoomBout(roomid, pTable->m_nTableNO);
            }
            return ret;

        4.在Server.h的CGameServer类中添加friend class DataRecord;

        5.（此步也可忽略）在CGameServer析构函数中添加如下代码：
            DataRecord::Instance()->Purge();

    ini配置信息：
        添加了[DataRecordParams]配置
        1.timeInterval=180，表示保存间隔时间180秒，默认180秒
        2.formatLen=20，表示每个数据的字符串长度，方便对齐，默认20（由于是64位，正数长度是19个字符串长度，所以20是最小的长度，配置20以下的都取20）
        3.roomSvrName=roomsvr 表示roomsvr名称，有些游戏可能用的自定义的roomsvr，例如四川麻将roomsvrxzmo，默认roomsvr

    注意点：
        1.各个房间的活跃人数在重启会被重置，其他都会自动读取
*/

typedef struct _tagPlayerInfo
{
    INT64 nWinDeposit;      //银两赢取量
    int nBout;              //局数
    INT64 nFee;             //茶水费
    int nDeposit;           //剩余银两
    int nUserType;          //玩家类型(手机或pc)
    _tagPlayerInfo()
    {
        nWinDeposit = 0;
        nBout = 0;
        nFee = 0;
        nDeposit = 0;
        nUserType = 0;
    }
} PlayerInfo, *PPlayerInfo;

typedef struct _tagRoomInfo
{
    INT64 nFee;
    DWORD nBout;
    std::set<int> userIds;
    _tagRoomInfo()
    {
        nFee = 0;
        nBout = 0;
        userIds.clear();
    }
    const _tagRoomInfo& operator+=(const _tagRoomInfo& roominfo)
    {
        this->nFee += roominfo.nFee;
        this->nBout += roominfo.nBout;


        for (std::set<int>::const_iterator iter = roominfo.userIds.begin(); iter != roominfo.userIds.end(); ++iter)
        {
            this->userIds.insert(*iter);
        }
        //this->userIds.insert(roominfo.userIds.begin(), roominfo.userIds.end());
        return *this;
    }

    friend _tagRoomInfo operator+(const _tagRoomInfo& roominfo1, const _tagRoomInfo& roominfo2)
    {
        _tagRoomInfo roomInfo;
        roomInfo.nFee = roominfo1.nFee + roominfo2.nFee;
        roomInfo.nBout = roominfo1.nBout + roominfo2.nBout;
        std::set<int>::const_iterator iter;
        for (iter = roominfo1.userIds.begin(); iter != roominfo1.userIds.end(); ++iter)
        {
            roomInfo.userIds.insert(*iter);
        }
        for (iter = roominfo2.userIds.begin(); iter != roominfo2.userIds.end(); ++iter)
        {
            roomInfo.userIds.insert(*iter);
        }
        //      roomInfo.userIds.insert(roominfo1.userIds.begin(), roominfo1.userIds.end());
        //      roomInfo.userIds.insert(roominfo2.userIds.begin(), roominfo2.userIds.end());
        return roomInfo;
    }
} RoomInfo, *PRoomInfo;

typedef std::map<int, PlayerInfo> PlayerInfoMap;
typedef std::map<int, RoomInfo> RoomInfoMap;

class DataRecord
{
public:
    static DataRecord* Instance();
    static void Purge();
    DataRecord(CString strIniFile, CMyGameServer* pServer);
    virtual ~DataRecord();

    virtual void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    virtual void OnShutDown();
    virtual void OnCPGameWin(LPCONTEXT_HEAD lpContext, int roomid, CCommonBaseTable* pTable, void* pData);
    virtual void OnTransmitGameResultEx(CCommonBaseTable* pTable, LPCONTEXT_HEAD lpContext, LPREFRESH_RESULT_EX lpRefreshResult,
        LPGAME_RESULT_EX lpGameResult, int nGameResultSize);

    virtual void init();
    virtual void UpdateInfos(CTable* pTable, LPREFRESH_RESULT_EX lpRefreshResult, LPGAME_RESULT_EX lpGameResult);
    virtual void UpdateRoomBout(int roomid, int tableno);
    virtual void ReadInfos();
    virtual void SaveInfos(BOOL force = FALSE);
    virtual void ResetInfos();
protected:
    CString GetRecordFile();
    void FormatStr(CString& str, int nFomatLen);                //将str字符串用空格填充到nFomatLen长度
    CString FormatOneRowStr(CString strs[], int len, int nFomatLen);    //连接strs，返回一行写入数据
    int SplitStr(CString outStrs[], int len, const CString& str, TCHAR splitChar = ' ', bool removeNewLine = true); //以splitChar分割字符串

    int GetRoomKeyByNo(int roomid, int tableno);
    int GetRoomKeyByIndex(int roomid, int tableIndex);
    void ParseRoomKey(int roomKey, int& roomid, int& tableIndex);
    int GetTableIndex(int roomid, int tableno);     //获得桌银分布的index，如果不是桌银分布的话则返回0，该index从1开始

    //桌银限制
#define RM_TABLEDEPOSIT 0x00000200
    virtual BOOL IsTableDepositRoom(int roomid);
    BOOL GetRoomSvrIniFile(int roomid, CString& sRoomSvrIniFile);
protected:
    PlayerInfoMap m_playerInfos;
    RoomInfoMap m_roomInfos;
    CString m_szIniFile;

    CCritSec m_csInfo;
    CString m_strRecordFile;
    DWORD m_dwTimeLastSave;

    CMyGameServer* m_gameSvr;
};



