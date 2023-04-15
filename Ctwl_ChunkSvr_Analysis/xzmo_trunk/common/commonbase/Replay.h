#pragma once

#define     REPLAY_SUFFIXES      _T(".rep") //
#define     REPLAY_MARK          _T("Rep")
#define     REPLAY_SAVE_SPACE    20

typedef struct _tagREP_TABLE_EX
{
    //From TABLE_INFO
    int     nRoomID;
    int     nTableNO;                           // ����
    int     nTotalChairs;                       // ������Ŀ
    DWORD   dwGameFlags;                        // ��Ϸ����ѡ��
    DWORD   dwRoomOption;                       // ��������
    BOOL    bNeedDeposit;                       // �Ƿ���Ҫ����
    int     nRoundCount;                        // �ڼ���
    int     nBoutCount;                         // �ڼ���
    int     nBanker;                            // ׯ��λ��
    int     nDices[MAX_DICE_NUM];               // ���Ӵ�С
    DWORD   dwStatus;                           // ��Ϸ״̬
    int     nBaseScore;                         // ���ֻ�������
    int     nBaseDeposit;                       // ���ֻ�������
    DWORD   dwRoomConfigs;                      // ��������
    //From TABLE_INFO_KD
    int     nTotalCards;                        // �Ƶ�����
    int     nTotalPacks;                        // ������
    int     nChairCards;                        // ÿ�˵�������
    int     nBottomCards;                       // ��������
    int     nJokerID;                           // ������ID
    //��������Ԥ��

    int     nRoomNo;                            //
    int     nUserId;                            //
    BOOL    bIsYQWAgent;                        // �Ƿ����
    int     nBoutPerRound;                      // �ܹ����پ�
    BOOL    bIsAsLap;                           // �Ƿ�Ȧ����
    int     nLapBoutCount;                      // ��Ȧ�ĵڼ���
    int     nTotalLap;                          // ����Ȧ
    int     nLapCount;                          // �ڼ�Ȧ
    int     nReserved[24];
} REP_TABLE_EX, *LPREP_TABLE_EX;

typedef struct _tagREP_YQWPLAYER
{
    //From SOLO_PLAYER
    int nUserID;                                // �û�ID
    int nUserType;                              // �û�����
    int nStatus;                                // ���״̬
    int nChairNO;                               // λ��
    int nNickSex;                               // ��ʾ�Ա� -1: δ֪; 0: ����; 1: Ů��
    int nPortrait;                              // ͷ��
    int nClothingID;                            // ��װID
    TCHAR szUsername[MAX_USERNAME_LEN];         // �û���
    TCHAR szNickName[MAX_NICKNAME_LEN];         // �º�
    int nDeposit;                               // ����
    int nPlayerLevel;                           // ����
    TCHAR szLevelName[MAX_LEVELNAME_LEN];
    int nScore;                                 // ����
    int nBreakOff;                              // ����
    int nWin;                                   // Ӯ
    int nLoss;                                  // ��
    int nStandOff;                              // ��
    int nBout;                                  // �غ�
    int nTimeCost;                              // ��ʱ
    YQW_PLAYER  yqwPlayerInfo;//һ������ҵ���Ϣ

    //��������Ԥ��
    int nReserved[16];
} REP_YQWPLAYER, *LPREP_YQWPLAYER;

extern BOOL IsFileExistEx(LPCTSTR szDir);  //��ѯĳ�ļ��Ƿ���ڣ�����·��
extern BOOL BuildDataDirectory(CString strPath, BOOL bnBulid = TRUE); //��������Ŀ¼�Ƿ���ڣ��粻���ڣ��򴴽���Ŀ¼

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
    BYTE*  m_data;//����ָ��
    BYTE*  m_ptr; //��ǰָ��
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
