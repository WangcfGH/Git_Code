#pragma once

#pragma warning(once:4996)

#define GR_DATARECORD_LOG_EVENT         (GAME_REQ_INDIVIDUAL+4101)      // ����˼�¼��־
#define GR_DATARECORD_APP_UPLOAD        (GAME_REQ_INDIVIDUAL+4102)      // �ͻ����ϴ�����
#define GR_DATARECORD_DEL_DBDATA        (GAME_REQ_INDIVIDUAL+4103)      // ɾ�����ݿ�����
#define GR_DATARECORD_NEW_APP_UPLOAD    (GAME_REQ_INDIVIDUAL+4104)      // �ͻ����ϴ����ݵ���Э��
#define GR_DATARECORD_CREATE_TABLE      (GAME_REQ_INDIVIDUAL+4109)      // ����ÿ������ݿ��
#define GR_DATARECORD_LOG_FUNC_USED     (GAME_REQ_INDIVIDUAL+4110)      // �û�����ʹ�����ϴ�����
#define GR_DB_LOG_FUNC_USED             (GAME_REQ_INDIVIDUAL+4111)      // ����ʹ�����ϴ����ݿ�

#define DR_MAX_EXTRA_SIZE       1024        // ��չ�ֶ���󳤶�
#ifndef MAX_SERIALNO_LEN
    #define MAX_SERIALNO_LEN        32          // ���к���󳤶�
#endif // !MAX_SERIALNO_LEN

typedef enum _enLogEventID
{
    LOG_EVENT_START = 0,
    LOG_EVENT_PLAYERLOGON,          // ��ҵ�½��־
    LOG_EVENT_PLAYERDATAYQW,        // ���������־
    LOG_EVENT_ROOMOPERATE,          // ����������־
    LOG_EVENT_BOUTRESULTYQW,        // ����������־
    LOG_EVENT_3DCOUNT,              // 3D���������¼
    LOG_EVENT_LOOKON,               // �Թ������¼
    LOG_EVENT_LOOKERENTER,          // �Թ���ҽ����¼
    LOG_EVENT_SURRENDER,            // Ͷ����Ϣ��־
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

/************************************* ��־�ṹ ***************************************/
// ��־ͷ
typedef struct _tagLogHead
{
    int nEventID;
} LOG_HEAD, *LPLOG_HEAD;

// �ͻ����ϴ�����
typedef struct _tagAppUploadData
{
    int     nUserID;
    TCHAR   szWeChatName[MAX_USERNAME_LEN];         // ΢���ǳ�
    TCHAR   szPhoneNO[MAX_HARDID_LEN];              // ���ֻ���
    TCHAR   szDeviceName[MAX_HARDID_LEN];           // �豸����
    TCHAR   szClientVer[MAX_HARDID_LEN];            // �ͻ��˰汾��

    int     nFirstLogon;                            // �׵Ǳ��
    int     nHappyCoin;                             // ���ֵ�
    int     nFreeHappyCoin;                         // ��ѻ��ֵ�
    int     nScoreNum;                              // ��������
    int     nDepositNum;                            // ��������
    int     nSafeboxNum;                            // ����������

    int     nNetType;                               // ��������
    int     nChannelNO;                             // ������

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // ��չ
    TCHAR   szHardID[MAX_HARDID_LEN];               // Ӳ��ID
} APPUPLOAD_DATA, *LPAPPUPLOAD_DATA;

// ��ҵ�¼
typedef struct _tagPlayerLogonLog
{
    int     nUserID;
    TCHAR   szLogonTime[MAX_SERIALNO_LEN];          // ��¼ʱ��
    int     nFirstLogon;                            // �׵Ǳ��
    DWORD   dwIPAddress;                            // IP��ַ
    TCHAR   szWechatName[MAX_USERNAME_LEN];         // ΢������
    int     nScoreNum;                              // ��������
    int     nDepositNum;                            // ��������
    int     nHappyCoin;                             // ���ֵ�����
    int     nFreeHappyCoin;                         // ��ѻ��ֵ�����
    int     nSafeboxNum;                            // ��������������
    int     nBoutYQW;                               // �����Ծ���
    int     nCheckRoomYQW;                          // ����������
    int     nNetType;                               // ��������
    int     nChanelNO;                              // ������
    TCHAR   szHardID[MAX_HARDID_LEN];               // Ӳ��ID

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // ��չ
} PLAYERLOGON_LOG, *LPPLAYERLOGON_LOG;

// �����������
typedef struct _tagPlayerDataYQWLog
{
    int     nUserID;
    int     nBout;                                  // �Ծ�����
    int     nWin;                                   // ʤ������
    int     nLose;                                  // ʧ������
    int     nDraw;                                  // ƽ������
    int     nCheckRoom;                             // ��������

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // ��չ
} PLAYERDATAYQW_LOG, *LPPLAYERDATAYQW_LOG;

// �����������
typedef enum _enOperateRoomMode
{
    OPERATEROOM_MODE_OTHER = 0,
    OPERATEROOM_MODE_CREATE_YQW,                    // һ���洴������
    OPERATEROOM_MODE_ENTER_NORMAL,                  // �������뷿��
    OPERATEROOM_MODE_ENTER_DXXW,                    // �������뷿��
    OPERATEROOM_MODE_LEAVE_UNSTART,                 // δ��ʼ�뿪����
    OPERATEROOM_MODE_BREAK_UNSTART,                 // δ��ʼ��ɢ����
    OPERATEROOM_MODE_BREAK_CONSULT,                 // Э�̽�ɢ����
    OPERATEROOM_MODE_BREAK_AUTO,                    // �Զ���ɢ����
    OPERATEROOM_MODE_LEAVE_FORCE,                   // ��ǿ���뿪����
} OPERATE_ROOM_MODE;

// ���俪������
typedef enum _enCheckRoomMode
{
    CHECKROOM_MODE_CLASSIC = 0,                     // ���䷿��
    CHECKROOM_MODE_PAY_HOST,                        // ����֧��
    CHECKROOM_MODE_PAY_SHARE,                       // ������ƽ̯
    CHECKROOM_MODE_PAY_AGENT,                       // �ͻ��˴���
    CHECKROOM_MODE_PAY_ASSISTANT,                   // ��ң�����ִ���
    CHECKROOM_MODE_PAY_OTHER,                       // ������ʽ
    CHECKROOM_MODE_PAY_COUPON,                      // ����ȯ
    CHECKROOM_MODE_PAY_UNKNOWN,                     // δ֪��֧����ʽ
} CHECK_ROOM_MODE;

// ��������
typedef struct _tagRoomOperateLog
{
    int     nUserID;
    TCHAR   szOperateTime[MAX_SERIALNO_LEN];        // ����ʱ��
    DWORD   dwIPAddress;                            // IP��ַ
    int     nRoomNO;                                // �����
    int     nOperateType;                           // ��������
    int     nRoomType;                              // ��������
    int     nBoutCount;                             // �Ծ�����
    int     nPlayCount;                             // ��ľ���
    TCHAR   szSerialNO[MAX_SERIALNO_LEN];           // �������к�
    TCHAR   szGameRule[DR_MAX_EXTRA_SIZE];          // �������
    int     nUseTime;                               // ����ʱ��

    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // ��չ
} ROOMOPERATE_LOG, *LPROOMOPERATE_LOG;

//����ʹ��
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

// ��������
typedef struct _tagBoutResultYQWLog
{
    int     nUserID;
    TCHAR   szRecordTime[MAX_SERIALNO_LEN];         // ��¼ʱ��
    int     nWaitSecond;                            // �ȴ�ʱ��
    TCHAR   szRoomSerialNO[MAX_SERIALNO_LEN];       // �������к�
    TCHAR   szBoutSerialNO[MAX_SERIALNO_LEN];       // �Ծ����к�
    int     nCostSecond;                            // ��Ϸʱ��
    TCHAR   szCreateTime[MAX_SERIALNO_LEN];         // ����ʱ��
    int     nRoomType;                              // ��������
    int     nBoutIndex;                             // ��Ϸ����
    int     nWinPoint;                              // ��Ӯ����
    int     nIdentity;                              // ������
    int     nScoreSum;                              // ���շ���
    int     nOfflineCount;                          // ���ߴ���
    TCHAR   szHandCards[DR_MAX_EXTRA_SIZE];         // ��ʼ����
    BOOL    bQuickRoom;                             // ���ٳ����
    TCHAR   szExtend[DR_MAX_EXTRA_SIZE];            // ��չ
} BOUTRESULTYQW_LOG, *LPBOUTRESULTYQW_LOG;
/**************************************************************************************/

/*********************************** ���⿪�Žӿ� **************************************/
// ��չ�ֶλ���
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

// ��¼��־�ӿ�
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

// �������ݽӿ�
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

// ��������ӿ�
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

// ��������ӿ�
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