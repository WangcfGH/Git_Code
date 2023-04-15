#pragma once

#pragma warning(once:4996)

#define GR_DATARECORD_LOG_EVENT         (GAME_REQ_INDIVIDUAL+4101)      // 服务端记录日志
#define GR_DATARECORD_APP_UPLOAD        (GAME_REQ_INDIVIDUAL+4102)      // 客户端上传数据
#define GR_DATARECORD_DEL_DBDATA        (GAME_REQ_INDIVIDUAL+4103)      // 删除数据库数据
#define GR_DATARECORD_NEW_APP_UPLOAD    (GAME_REQ_INDIVIDUAL+4104)      // 客户端上传数据的新协议
#define GR_DATARECORD_CREATE_TABLE      (GAME_REQ_INDIVIDUAL+4109)      // 创建每天的数据库表
#define GR_DATARECORD_LOG_FUNC_USED     (GAME_REQ_INDIVIDUAL+4110)      // 用户功能使用率上传数据
#define GR_DB_LOG_FUNC_USED             (GAME_REQ_INDIVIDUAL+4111)      // 功能使用率上传数据库

#define DR_MAX_EXTRA_SIZE       1024        // 扩展字段最大长度
#ifndef MAX_SERIALNO_LEN
    #define MAX_SERIALNO_LEN        32          // 序列号最大长度
#endif // !MAX_SERIALNO_LEN

typedef enum _enLogEventID
{
    LOG_EVENT_START = 0,
    LOG_EVENT_PLAYERLOGON,          // 玩家登陆日志
    LOG_EVENT_PLAYERDATAYQW,        // 玩家数据日志
    LOG_EVENT_ROOMOPERATE,          // 操作房间日志
    LOG_EVENT_BOUTRESULTYQW,        // 房卡结算日志
    LOG_EVENT_3DCOUNT,              // 3D场景进入记录
    LOG_EVENT_LOOKON,               // 旁观请求记录
    LOG_EVENT_LOOKERENTER,          // 旁观玩家进入记录
    LOG_EVENT_SURRENDER,            // 投降信息日志
    //
} LOG_EVENT_ID;

typedef enum _enNetTypeList
{
    NET_TYPE_LIST_2G = 1,           // 2g
    NET_TYPE_LIST_3G,               // 3g
    NET_TYPE_LIST_WIFI,             // wifi
    NET_TYPE_LIST_4G,               // 4g
    NET_TYPE_LIST_OTHER,            // other
} NET_TYPE_LIST;

/************************************* 日志结构 ***************************************/
// 日志头
typedef struct _tagLogHead
{
    int nEventID;
} LOG_HEAD, *LPLOG_HEAD;

// 客户端上传数据
typedef struct _tagAppUploadData
{
    int     nUserID;
    TCHAR   szWeChatName[MAX_USERNAME_LEN];         // 微信昵称
    TCHAR   szPhoneNO[MAX_HARDID_LEN];              // 绑定手机号
    TCHAR   szDeviceName[MAX_HARDID_LEN];           // 设备名称
    TCHAR   szClientVer[MAX_HARDID_LEN];            // 客户端版本号

    int     nFirstLogon;                            // 首登标记
    int     nHappyCoin;                             // 欢乐点
    int     nFreeHappyCoin;                         // 免费欢乐点
    int     nScoreNum;                              // 积分数量
    int     nDepositNum;                            // 银子数量
    int     nSafeboxNum;                            // 保险箱数量

    int     nNetType;                               // 网络类型
    int     nChannelNO;                             // 渠道号

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // 扩展
    TCHAR   szHardID[MAX_HARDID_LEN];               // 硬件ID
} APPUPLOAD_DATA, *LPAPPUPLOAD_DATA;

// 玩家登录
typedef struct _tagPlayerLogonLog
{
    int     nUserID;
    TCHAR   szLogonTime[MAX_SERIALNO_LEN];          // 登录时间
    int     nFirstLogon;                            // 首登标记
    DWORD   dwIPAddress;                            // IP地址
    TCHAR   szWechatName[MAX_USERNAME_LEN];         // 微信名称
    int     nScoreNum;                              // 积分数量
    int     nDepositNum;                            // 银子数量
    int     nHappyCoin;                             // 欢乐点数量
    int     nFreeHappyCoin;                         // 免费欢乐点数量
    int     nSafeboxNum;                            // 保险箱银子数量
    int     nBoutYQW;                               // 房卡对局数
    int     nCheckRoomYQW;                          // 房卡建房数
    int     nNetType;                               // 网络类型
    int     nChanelNO;                              // 渠道号
    TCHAR   szHardID[MAX_HARDID_LEN];               // 硬件ID

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // 扩展
} PLAYERLOGON_LOG, *LPPLAYERLOGON_LOG;

// 房卡玩家数据
typedef struct _tagPlayerDataYQWLog
{
    int     nUserID;
    int     nBout;                                  // 对局数量
    int     nWin;                                   // 胜利数量
    int     nLose;                                  // 失败数量
    int     nDraw;                                  // 平局数量
    int     nCheckRoom;                             // 建房数量

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // 扩展
} PLAYERDATAYQW_LOG, *LPPLAYERDATAYQW_LOG;

// 房间操作类型
typedef enum _enOperateRoomMode
{
    OPERATEROOM_MODE_OTHER = 0,
    OPERATEROOM_MODE_CREATE_YQW,                    // 一起玩创建房间
    OPERATEROOM_MODE_ENTER_NORMAL,                  // 正常进入房间
    OPERATEROOM_MODE_ENTER_DXXW,                    // 重连进入房间
    OPERATEROOM_MODE_LEAVE_UNSTART,                 // 未开始离开房间
    OPERATEROOM_MODE_BREAK_UNSTART,                 // 未开始解散房间
    OPERATEROOM_MODE_BREAK_CONSULT,                 // 协商解散房间
    OPERATEROOM_MODE_BREAK_AUTO,                    // 自动解散房间
    OPERATEROOM_MODE_LEAVE_FORCE,                   // 被强制离开房间
} OPERATE_ROOM_MODE;

// 房间开房类型
typedef enum _enCheckRoomMode
{
    CHECKROOM_MODE_CLASSIC = 0,                     // 经典房间
    CHECKROOM_MODE_PAY_HOST,                        // 房主支付
    CHECKROOM_MODE_PAY_SHARE,                       // 所有人平摊
    CHECKROOM_MODE_PAY_AGENT,                       // 客户端代开
    CHECKROOM_MODE_PAY_ASSISTANT,                   // 逍遥游助手代开
    CHECKROOM_MODE_PAY_OTHER,                       // 其他方式
    CHECKROOM_MODE_PAY_COUPON,                      // 欢乐券
    CHECKROOM_MODE_PAY_UNKNOWN,                     // 未知的支付方式
} CHECK_ROOM_MODE;

// 操作房间
typedef struct _tagRoomOperateLog
{
    int     nUserID;
    TCHAR   szOperateTime[MAX_SERIALNO_LEN];        // 建房时间
    DWORD   dwIPAddress;                            // IP地址
    int     nRoomNO;                                // 房间号
    int     nOperateType;                           // 操作类型
    int     nRoomType;                              // 房间类型
    int     nBoutCount;                             // 对局数量
    int     nPlayCount;                             // 玩的局数
    TCHAR   szSerialNO[MAX_SERIALNO_LEN];           // 建房序列号
    TCHAR   szGameRule[DR_MAX_EXTRA_SIZE];          // 房间规则
    int     nUseTime;                               // 房间时长

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // 扩展
} ROOMOPERATE_LOG, *LPROOMOPERATE_LOG;

//功能使用
typedef struct _tagFuncUsedLog
{
    int     nUserID;
    int     nFuncID;
} FUNCUSED_LOG, *LPFUNCUSED_LOG;

typedef struct _tagLogSurrender
{
    int     nUserID;
    int     nRoomNO;
    BOOL    bSuccess;
    int     nRefuseUserID;
    int     nSurrenderType;
    TCHAR   szDate[32];
    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];
} LOGSURRENDER, *LPLOGSURRENDER;

// 房卡结算
typedef struct _tagBoutResultYQWLog
{
    int     nUserID;
    TCHAR   szRecordTime[MAX_SERIALNO_LEN];         // 记录时间
    int     nWaitSecond;                            // 等待时长
    TCHAR   szRoomSerialNO[MAX_SERIALNO_LEN];       // 建房序列号
    TCHAR   szBoutSerialNO[MAX_SERIALNO_LEN];       // 对局序列号
    int     nCostSecond;                            // 游戏时长
    TCHAR   szCreateTime[MAX_SERIALNO_LEN];         // 建房时间
    int     nRoomType;                              // 房间类型
    int     nBoutIndex;                             // 游戏场次
    int     nWinPoint;                              // 输赢倍率
    int     nIdentity;                              // 玩家身份
    int     nScoreSum;                              // 最终分数
    int     nOfflineCount;                          // 掉线次数
    TCHAR   szHandCards[DR_MAX_EXTRA_SIZE];         // 开始手牌
    BOOL    bQuickRoom;                             // 快速场标记
    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // 扩展
} BOUTRESULTYQW_LOG, *LPBOUTRESULTYQW_LOG;
/**************************************************************************************/

/*********************************** 对外开放接口 **************************************/
// 扩展字段基类
class ExtraInterface
{
protected:
    int m_nExtraLen;

    BOOL AddExtraToStr(TCHAR szExtend[], int nLen, CString& csDataID, CString& csDataValue)
    {
        int nAddLen = csDataID.GetLength() + csDataValue.GetLength() + 2;
        if (nAddLen + m_nExtraLen < nLen)
        {
            strcat_s(szExtend, csDataID.GetLength(), csDataID.GetBuffer(0));
            strcat_s(szExtend, 1, ":");
            strcat_s(szExtend, csDataValue.GetLength(), csDataValue.GetBuffer(0));
            strcat_s(szExtend, 1, ";");
            m_nExtraLen += nAddLen;
            return TRUE;
        }
        return FALSE;
    }
public:
    ExtraInterface() : m_nExtraLen(0) {}

    virtual BOOL AddExtraValueInt(CString& csDataID, LONG nDataValue)
    {
        CString csDataValue;
        csDataValue.Format(_T("%d"), nDataValue);
        return AddExtraValueStr(csDataID, csDataValue);
    }
    virtual BOOL AddExtraValueStr(CString& csDataID, CString& csDataValue)
    {
        return FALSE;
    }
};

// 登录日志接口
class PLAYERLOGON_EVENT : public ExtraInterface
{
public:
    PLAYERLOGON_EVENT() : m_pLog(NULL) { }

    const LPPLAYERLOGON_LOG GetLog() const { return m_pLog; }
    int GetLogLen() const
    {
        if (!m_pLog)
        {
            return 0;
        }
        return sizeof(PLAYERLOGON_LOG) - sizeof(TCHAR) * (DR_MAX_EXTRA_SIZE - m_nExtraLen);
    }
    void Release() { if (m_pLog) { delete m_pLog; m_pLog = NULL; } }
    const LPPLAYERLOGON_LOG CreateLog()
    {
        Release();
        m_pLog = new PLAYERLOGON_LOG;
        ZeroMemory(m_pLog, sizeof(PLAYERLOGON_LOG));
        return m_pLog;
    }

    void SetUserID(int nValue)                  { if (!m_pLog) return; m_pLog->nUserID = nValue; }
    void SetLogonTime(const TCHAR szValue[])    { if (!m_pLog) return; strcpy_s(m_pLog->szLogonTime, szValue); }
    void SetFirstLogon(int nValue)              { if (!m_pLog) return; m_pLog->nFirstLogon = nValue; }
    void SetIPAddress(DWORD dwValue)            { if (!m_pLog) return; m_pLog->dwIPAddress = dwValue; }
    void SetWechatName(const TCHAR szValue[])   { if (!m_pLog) return; strcpy_s(m_pLog->szWechatName, szValue); }
    void SetScoreNum(int nValue)                { if (!m_pLog) return; m_pLog->nScoreNum = nValue; }
    void SetDepositNum(int nValue)              { if (!m_pLog) return; m_pLog->nDepositNum = nValue; }
    void SetHappyCoin(int nValue)               { if (!m_pLog) return; m_pLog->nHappyCoin = nValue; }
    void SetFreeHappyCoin(int nValue)           { if (!m_pLog) return; m_pLog->nFreeHappyCoin = nValue; }
    void SetSafeboxNum(int nValue)              { if (!m_pLog) return; m_pLog->nSafeboxNum = nValue; }
    void SetBoutYQW(int nValue)                 { if (!m_pLog) return; m_pLog->nBoutYQW = nValue; }
    void SetCheckRoomYQW(int nValue)            { if (!m_pLog) return; m_pLog->nCheckRoomYQW = nValue; }
    void SetNetType(int nValue)                 { if (!m_pLog) return; m_pLog->nNetType = nValue; }
    void SetChanelNO(int nValue)                { if (!m_pLog) return; m_pLog->nChanelNO = nValue; }
    void SetHardID(const TCHAR szValue[])       { if (!m_pLog) return; strcpy_s(m_pLog->szHardID, szValue); }

    BOOL AddExtraValueStr(CString& csDataID, CString& csDataValue)
    {
        if (!m_pLog)
        {
            return FALSE;
        }
        return AddExtraToStr(m_pLog->szExtend, DR_MAX_EXTRA_SIZE, csDataID, csDataValue);
    }

private:
    LPPLAYERLOGON_LOG m_pLog;
};

// 房卡数据接口
class PLAYERDATAYQW_EVENT : public ExtraInterface
{
public:
    PLAYERDATAYQW_EVENT() : m_pLog(NULL) { }

    const LPPLAYERDATAYQW_LOG GetLog() const { return m_pLog; }
    int GetLogLen() const
    {
        if (!m_pLog)
        {
            return 0;
        }
        return sizeof(PLAYERDATAYQW_LOG) - sizeof(TCHAR) * (DR_MAX_EXTRA_SIZE - m_nExtraLen);
    }

    const LPPLAYERDATAYQW_LOG CreateLog()
    {
        Release();

        m_pLog = new PLAYERDATAYQW_LOG;
        ZeroMemory(m_pLog, sizeof(PLAYERDATAYQW_LOG));
        return m_pLog;
    }
    void Release() { if (m_pLog) { delete m_pLog; m_pLog = NULL; } }

    void SetUserID(int nValue)                  { if (!m_pLog) return; m_pLog->nUserID = nValue; }
    void SetWin(int nValue = 1)                 { if (!m_pLog) return; m_pLog->nWin = nValue; m_pLog->nBout = nValue; }
    void SetLose(int nValue = 1)                { if (!m_pLog) return; m_pLog->nLose = nValue; m_pLog->nBout = nValue; }
    void SetDraw(int nValue = 1)                { if (!m_pLog) return; m_pLog->nDraw = nValue; m_pLog->nBout = nValue; }
    void SetCheckRoom(int nValue = 1)           { if (!m_pLog) return; m_pLog->nCheckRoom = nValue; }

    virtual BOOL AddExtraValueStr(CString& csDataID, CString& csDataValue)
    {
        if (!m_pLog)
        {
            return FALSE;
        }
        return AddExtraToStr(m_pLog->szExtend, DR_MAX_EXTRA_SIZE, csDataID, csDataValue);
    }

private:
    LPPLAYERDATAYQW_LOG m_pLog;
};

// 房间操作接口
class ROOMOPERATE_EVENT : public ExtraInterface
{
public:
    ROOMOPERATE_EVENT() : m_pLog(NULL) { }

    const LPROOMOPERATE_LOG GetLog() const { return m_pLog; }
    int GetLogLen() const
    {
        if (!m_pLog)
        {
            return 0;
        }
        return sizeof(ROOMOPERATE_LOG) - sizeof(TCHAR) * (DR_MAX_EXTRA_SIZE - m_nExtraLen);
    }

    const LPROOMOPERATE_LOG CreateLog()
    {
        Release();

        m_pLog = new ROOMOPERATE_LOG;
        ZeroMemory(m_pLog, sizeof(ROOMOPERATE_LOG));
        return m_pLog;
    }
    void Release() { if (m_pLog) { delete m_pLog; m_pLog = NULL; } }

    void SetUserID(int nValue)                  { if (!m_pLog) return; m_pLog->nUserID = nValue; }
    void SetOperateTime(const TCHAR szValue[])  { if (!m_pLog) return; strcpy_s(m_pLog->szOperateTime, szValue); }
    void SetIPAddress(DWORD dwValue)            { if (!m_pLog) return; m_pLog->dwIPAddress = dwValue; }
    void SetRoomNO(int nValue)                  { if (!m_pLog) return; m_pLog->nRoomNO = nValue; }
    void SetOperateType(int nValue)             { if (!m_pLog) return; m_pLog->nOperateType = nValue; }
    void SetRoomType(int nValue)                { if (!m_pLog) return; m_pLog->nRoomType = nValue; }
    void SetBoutCount(int nValue)               { if (!m_pLog) return; m_pLog->nBoutCount = nValue; }
    void SetPlayCount(int nValue)               { if (!m_pLog) return; m_pLog->nPlayCount = nValue; }
    void SetSerialNO(const TCHAR szValue[])     { if (!m_pLog) return; strcpy_s(m_pLog->szSerialNO, szValue); }
    void SetGameRule(const TCHAR szValue[])     { if (!m_pLog) return; strcpy_s(m_pLog->szGameRule, szValue); }
    void SetUseTime(int nValue)                 { if (!m_pLog) return; m_pLog->nUseTime = nValue; }
    void SetExtendStr(CString& extendStr)
    {
        if (m_pLog && extendStr.GetLength() < DR_MAX_EXTRA_SIZE)
        {
            strncpy_s(m_pLog->szExtend, extendStr.GetBuffer(0), extendStr.GetLength());
            m_nExtraLen = extendStr.GetLength();
        }
    }

    virtual BOOL AddExtraValueStr(CString& csDataID, CString& csDataValue)
    {
        if (!m_pLog)
        {
            return FALSE;
        }
        return AddExtraToStr(m_pLog->szExtend, DR_MAX_EXTRA_SIZE, csDataID, csDataValue);
    }

private:
    LPROOMOPERATE_LOG m_pLog;
};

// 房卡结算接口
class BOUTRESULTYQW_EVENT : public ExtraInterface
{
public:
    BOUTRESULTYQW_EVENT() : m_pLog(NULL) { }

    const LPBOUTRESULTYQW_LOG GetLog() const { return m_pLog; }
    int GetLogLen() const
    {
        if (!m_pLog)
        {
            return 0;
        }
        return sizeof(BOUTRESULTYQW_LOG) - sizeof(TCHAR) * (DR_MAX_EXTRA_SIZE - m_nExtraLen);
    }
    void Release() { if (m_pLog) { delete m_pLog; m_pLog = NULL; } }
    const LPBOUTRESULTYQW_LOG CreateLog()
    {
        Release();
        m_pLog = new BOUTRESULTYQW_LOG;
        ZeroMemory(m_pLog, sizeof(BOUTRESULTYQW_LOG));
        return m_pLog;
    }

    void SetUserID(int nValue)                  { if (!m_pLog) return; m_pLog->nUserID = nValue; }
    void SetRecordTime(const TCHAR szValue[])   { if (!m_pLog) return; strcpy_s(m_pLog->szRecordTime, szValue); }
    void SetWaitSecond(int nValue)              { if (!m_pLog) return; m_pLog->nWaitSecond = nValue; }
    void SetRoomSerialNO(const TCHAR szValue[]) { if (!m_pLog) return; strcpy_s(m_pLog->szRoomSerialNO, szValue); }
    void SetBoutSerialNO(const TCHAR szValue[]) { if (!m_pLog) return; strcpy_s(m_pLog->szBoutSerialNO, szValue); }
    void SetCostSecond(int nValue)              { if (!m_pLog) return; m_pLog->nCostSecond = nValue; }
    void SetCreateTime(const TCHAR szValue[])   { if (!m_pLog) return; strcpy_s(m_pLog->szCreateTime, szValue); }
    void SetRoomType(int nValue)                { if (!m_pLog) return; m_pLog->nRoomType = nValue; }
    void SetBoutIndex(int nValue)               { if (!m_pLog) return; m_pLog->nBoutIndex = nValue; }
    void SetWinPoint(int nValue)                { if (!m_pLog) return; m_pLog->nWinPoint = nValue; }
    void SetIdentity(int nValue)                { if (!m_pLog) return; m_pLog->nIdentity = nValue; }
    void SetScoreSum(int nValue)                { if (!m_pLog) return; m_pLog->nScoreSum = nValue; }
    void SetOfflineCount(int nValue)            { if (!m_pLog) return; m_pLog->nOfflineCount = nValue; }
    void SetHandCards(const TCHAR szValue[])    { if (!m_pLog) return; strcpy_s(m_pLog->szHandCards, szValue); }
    void SetIsQuickRoom(BOOL nValue)            { if (!m_pLog) return; m_pLog->bQuickRoom = nValue; }
    void SetExtendStr(CString& extendStr)
    {
        if (m_pLog && extendStr.GetLength() < DR_MAX_EXTRA_SIZE)
        {
            strncpy_s(m_pLog->szExtend, extendStr.GetBuffer(0), extendStr.GetLength());
            m_nExtraLen = extendStr.GetLength();
        }
    }

    BOOL AddExtraValueStr(CString& csDataID, CString& csDataValue)
    {
        if (!m_pLog)
        {
            return FALSE;
        }
        return AddExtraToStr(m_pLog->szExtend, DR_MAX_EXTRA_SIZE, csDataID, csDataValue);
    }

private:
    LPBOUTRESULTYQW_LOG m_pLog;
};
/************************************************************************************/

typedef struct _tagLog3dData
{
    int     date;
    int     nUserID;
    int     n3DCount;
    int     n2DCount;
    int     support3D;

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];
} LOG3DDATA, *LPLOG3DDATA;

typedef struct _tagLogLookonData
{
    TCHAR   szLookonTime[MAX_SERIALNO_LEN];
    int     nUserID;
    int     nWatcherID;
    int     nRoomNO;
    int     nPermitCount;

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];
} LOGLOOKONDATA, *LPLOGLOOKONDATA;

typedef struct _tagLogLookerEnter
{
    int     date;
    int     nUserID;
    int     LookOnCount;

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];
} LOGLOOKERENTER, *LPLOGLOOKERENTER;