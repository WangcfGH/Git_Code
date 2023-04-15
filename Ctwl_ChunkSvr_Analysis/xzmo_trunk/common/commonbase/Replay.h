#pragma once

#define     REPLAY_SUFFIXES      _T(".rep") //
#define     REPLAY_MARK          _T("Rep")
#define     REPLAY_SAVE_SPACE    20

typedef struct _tagREP_TABLE_EX
{
    //From TABLE_INFO
    int     nRoomID;
    int     nTableNO;                           // 桌号
    int     nTotalChairs;                       // 椅子数目
    DWORD   dwGameFlags;                        // 游戏特征选项
    DWORD   dwRoomOption;                       // 房间设置
    BOOL    bNeedDeposit;                       // 是否需要银子
    int     nRoundCount;                        // 第几轮
    int     nBoutCount;                         // 第几局
    int     nBanker;                            // 庄家位置
    int     nDices[MAX_DICE_NUM];               // 骰子大小
    DWORD   dwStatus;                           // 游戏状态
    int     nBaseScore;                         // 本局基本积分
    int     nBaseDeposit;                       // 本局基本银子
    DWORD   dwRoomConfigs;                      // 房间设置
    //From TABLE_INFO_KD
    int     nTotalCards;                        // 牌的张数
    int     nTotalPacks;                        // 几副牌
    int     nChairCards;                        // 每人的牌张数
    int     nBottomCards;                       // 底牌张数
    int     nJokerID;                           // 财神牌ID
    //不够请用预留

    int     nRoomNo;                            //
    int     nUserId;                            //
    BOOL    bIsYQWAgent;                        // 是否代开
    int     nBoutPerRound;                      // 总共多少局
    BOOL    bIsAsLap;                           // 是否圈结算
    int     nLapBoutCount;                      // 当圈的第几局
    int     nTotalLap;                          // 共几圈
    int     nLapCount;                          // 第几圈
    int     nReserved[24];
} REP_TABLE_EX, *LPREP_TABLE_EX;

typedef struct _tagREP_YQWPLAYER
{
    //From SOLO_PLAYER
    int nUserID;                                // 用户ID
    int nUserType;                              // 用户类型
    int nStatus;                                // 玩家状态
    int nChairNO;                               // 位置
    int nNickSex;                               // 显示性别 -1: 未知; 0: 男性; 1: 女性
    int nPortrait;                              // 头像
    int nClothingID;                            // 服装ID
    TCHAR szUsername[MAX_USERNAME_LEN];         // 用户名
    TCHAR szNickName[MAX_NICKNAME_LEN];         // 绰号
    int nDeposit;                               // 银子
    int nPlayerLevel;                           // 级别
    TCHAR szLevelName[MAX_LEVELNAME_LEN];
    int nScore;                                 // 积分
    int nBreakOff;                              // 断线
    int nWin;                                   // 赢
    int nLoss;                                  // 输
    int nStandOff;                              // 和
    int nBout;                                  // 回合
    int nTimeCost;                              // 花时
    YQW_PLAYER  yqwPlayerInfo;//一起玩玩家的信息

    //不够请用预留
    int nReserved[16];
} REP_YQWPLAYER, *LPREP_YQWPLAYER;

extern BOOL IsFileExistEx(LPCTSTR szDir);  //查询某文件是否存在，绝对路径
extern BOOL BuildDataDirectory(CString strPath, BOOL bnBulid = TRUE); //检查输入的目录是否存在，如不存在，则创建新目录

extern BOOL WriteDataFile(LPSTR szPath, BYTE* data, DWORD length);
extern BOOL DeleteDirectory(TCHAR* psDirName);

class CAutoStream
{
public:
    CAutoStream();
    CAutoStream(const CAutoStream& stAutoStream);
    virtual ~CAutoStream();

    CAutoStream& operator=(const CAutoStream& stAutoStream);

    void   CopyData(const CAutoStream& stAutoStream);

    void   Release();
    void*  GetHead();
    void*  GetCurrent();
    void*  GetPosition(int nPosition);
    int    GetCurrentPostion();
    int    PushData(void* new_data, int new_size);
    int    GetSize();
    void   ClearData();
    void   MoveTo(int nPosition);
    void   Move(int nOffset);
private:
    void   AddMemory(int nNewSize);
    int    m_nUseSize;
    int    m_nTotalSize;
    BYTE*  m_data;//数据指针
    BYTE*  m_ptr; //当前指针
};

class CReplayRecord
{
public:
    CReplayRecord();
    virtual ~CReplayRecord();

    void    ReleaseData();
    void    Clear();
    void    PushHead(void* pData, int nSize);
    void    PushStep(void* pData, int nSize);
    void    PushInitStep(void* pData, int nSize);
    void    PushData(void* pData, int nSize);

    void    ResetHeadValue();

    void*   GetPlayerInfo();
    void*   GetDataBuff();
    void*   GetHeadBuff();
    int     GetHeadSize();
    int     GetDataSize();

    BOOL    NeedSave() const { return m_bSave; }
    void    SetSave(BOOL bSave) { m_bSave = bSave; }
    void    SetRoomAndTableNO(int nRoomID, int nTableNO) { m_nRoomID = nRoomID; m_nTableNO = nTableNO; }
    void    SetAcitve(BOOL bActive) { m_bActive = bActive; }
    BOOL    IsAcitve() const { return m_bActive; }

    DWORD   GetTotalTickCount() const { return m_dwTotalTickCount; }
    DWORD   GetStartTickCount() const { return m_dwStartTickCount; }

    CString GetFileName() const { return m_strFileName; };
    virtual BOOL WriteToFile(CString strPath);
    virtual CString BuildFilePath(CString& strPath);

    BOOL    ReachSaveTime() { return (m_nSaveSpace <= 0); }
    BOOL    ComeDownSaveSpace() { if (m_nSaveSpace > 0) --m_nSaveSpace;  return (m_nSaveSpace <= 0); }
protected:
    CAutoStream m_stReplayData;
    CAutoStream m_stReplayHead;
    int         m_nTotalStep;
    DWORD       m_dwTotalTickCount;
    DWORD       m_dwStartTickCount;
    int         m_nInitPosition;
    BOOL        m_bActive;
    BOOL        m_bSave;
    int         m_nRoomID;
    int         m_nTableNO;
    CString     m_strFileName;
    int         m_nSaveSpace;
};
