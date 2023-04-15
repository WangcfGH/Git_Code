#pragma once
//////////////////////////////////////////////////////////////////////////
// ������� -- add by chenshu

/////////////////////////////////////////��RoomSvr��ͨѶ�Զ���Windows��Ϣ
#define     WM_GTR_RECORD_USER_NETWORK_TYPE_EX  (WM_USER+5004)           //���û��������ʹ���RoomSvr   
#define     UT_ROBOT                        0x40000000                   //������,�Զ����û�����



#define LOGDATA_PUSH_LOGDATA(d) ss << d << ","

#define DEFINE_VALUE_HAS_SET_GET(type, name)    \
public:                                         \
    void set##name(const type& t) {name = t;}   \
    type& get##name(){return name;}             \
protected:                                      \
    type    name = type();

#define DEFINE_VALUE_HAS_SET_GET_WITHVALUE(type, name,v)    \
public:                                         \
    void set##name(const type& t) {name = t;}   \
    type& get##name() {return name;}            \
protected:                                      \
    type    name = (v);


struct MTableData
{
    typedef std::shared_ptr<MTableData> Ptr;

    static std::string GetUniqeID();

    std::string guid = GetUniqeID();        // playrecord, ZuoPaiRecord��Ҫ��ͬ��guid���ðɣ����㣡
};
//////////////////////////////////////////////////////////////////////////

struct GameLogCom
{
    CTime m_startGameTime;

	int m_pkgType[TOTAL_CHAIRS];  //΢�Ŷ�����

	::google::protobuf::int32 m_nRecommandid[TOTAL_CHAIRS];
};

class CMyGameServer;
class GameLogData : public DataLogerModule
{
public:
    typedef std::shared_ptr<GameLogData>            Ptr;
    typedef std::map<std::string, MTableData::Ptr>  MTablePtrMap;

	// args:[int nUserId, tc::KPIClientData & data]
	ImportFunctional<BOOL(int, tc::KPIClientData&)> imGetKPIClientData;

    GameLogData(CString strIniFile, CMyGameServer* pServer);
    ~GameLogData();

    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnShutDown();

    void OnNewTable(CCommonBaseTable* pTable);
    void OnCPGameWin(LPCONTEXT_HEAD lpContext, int roomid, CCommonBaseTable* pTable, void* pData);
    void OnStartAfter(CCommonBaseTable* pTable);
	void OnStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* pTable, void* pData);
	void OnGameStarted(CCommonBaseTable* pTable, void* pData);
	void OnRestMembers(CCommonBaseTable* pTable);
protected:

    void            Init();
    void            UnInit();

    void                FreshCache(CMyGameTable* pTable);
    MTableData::Ptr     GetMTablePtr(int roomid, int tableno);

protected:
    std::string ToKey(int roomid, int tableno);
    virtual BOOL        _OnInit() override;
    virtual BOOL    OnTimerFreshFile(UINT id);

private:
    MTablePtrMap        m_tableCache;
    CMyGameServer* m_pMyServer;
};


//////////////////////////////////////////////////////////////////////////
// playrecordXZ begin
typedef struct _tagROLERECORDFORLOG_XZ
{
    //��ҶԾ���Ϣ
    //��Ϸ�Ծ���־start
    enum ROLE_TYPE
    {
        ROLE_NONE = 0,
        ROLE_BANKER,
        ROLE_XIANJIA,
        ROLE_COUNT,
    };

    DEFINE_VALUE_HAS_SET_GET(int, nUserID);                             //���ID
    DEFINE_VALUE_HAS_SET_GET(int, nTimeCost);                           //��ʱ(��)
    DEFINE_VALUE_HAS_SET_GET_WITHVALUE(int, nUserType, UT_COMMON);      //�������
    DEFINE_VALUE_HAS_SET_GET(int, nPlayerType);                         //�������
    DEFINE_VALUE_HAS_SET_GET(int, nTotalCountXueZhan);                  //Ѫս�ܶԾ���
    DEFINE_VALUE_HAS_SET_GET(int, nTotalCount);                         //�����ܶԾ���
    DEFINE_VALUE_HAS_SET_GET_WITHVALUE(ROLE_TYPE, nRole, ROLE_NONE);    //��ɫ
    DEFINE_VALUE_HAS_SET_GET(int, nWinIdx);                             //��Ӯ˳��
    DEFINE_VALUE_HAS_SET_GET(int, nBeginDeposit);                       //��ʼ����
    DEFINE_VALUE_HAS_SET_GET(int, nLeftDeposit);                        //ʣ������
    DEFINE_VALUE_HAS_SET_GET(int, nWinMultiple);                        //ʣ������
    DEFINE_VALUE_HAS_SET_GET(int, nVersion);                            //�汾
    DEFINE_VALUE_HAS_SET_GET(int, nSafeDepost);                         //��������ֵ
    DEFINE_VALUE_HAS_SET_GET(int, bIsMakeCard);                         // �Ƿ�����
    DEFINE_VALUE_HAS_SET_GET(bool, bWxMobile);                          //�ж��Ƿ���΢�Ŷ�
    DEFINE_VALUE_HAS_SET_GET(::google::protobuf::int32, nRecommandid);  //�������

public:
    std::string GetUserTypeNameByUserType()
    {
        std::string strName = "����";

        if (bWxMobile)
        {
            return "΢�Ŷ�";
        }

        if (IS_BIT_SET(nUserType, UT_HANDPHONE))
        {
            strName = "�ƶ���";
        }
        else if (IS_BIT_SET(nUserType, UT_COMMON) || IS_BIT_SET(nUserType, UT_MEMBER) || IS_BIT_SET(nUserType, UT_MATCH) || IS_BIT_SET(nUserType, UT_ADMIN) || IS_BIT_SET(nUserType, UT_SUPER))
        {
            strName = "PC��";
        }
        else if (IS_BIT_SET(nUserType, UT_ROBOT))
        {
            strName = "������";
        }

        return strName;
    }
    std::string GetUserRole()
    {
        static const std::string ROLE_TYPE_NAME[ROLE_COUNT] = { "����", "ׯ��", "�м�" };
        if (nRole < ROLE_NONE || nRole >= ROLE_COUNT)
        {
            return ROLE_TYPE_NAME[ROLE_NONE];
        }
        return ROLE_TYPE_NAME[nRole];
    }

    static ROLE_TYPE GetRoleType(int banker, int chairno)
    {
        return banker == chairno ? ROLE_BANKER : ROLE_XIANJIA;
    }

} ROLERECORDFORLOG_XZ, LPROLERECORDFORLOG_XZ;

typedef struct _tagPLAYRECORDFORLOG_XZ
{
    //��Ϸ�Ծ���Ϣ
    DEFINE_VALUE_HAS_SET_GET_WITHVALUE(CTime, time, CTime::GetCurrentTime());       //ʱ���
    DEFINE_VALUE_HAS_SET_GET(int, nRoomID);                                         //����ID
    DEFINE_VALUE_HAS_SET_GET(int, nFee);                                            //��ˮ��
    DEFINE_VALUE_HAS_SET_GET(int, nBaseDeposit);                                    //������
    DEFINE_VALUE_HAS_SET_GET(int, nTotalMultiple);                                  //�ܷ���
    DEFINE_VALUE_HAS_SET_GET(std::vector<ROLERECORDFORLOG_XZ>, roles);
} PLAYRECORDFORLOG_XZ, *LPPLAYRECORDFORLOG_XZ;

struct PlayRecordUtils
{
    struct TableDespositLine
    {
        // 0    =   0   | 49    | 500000 �����ĸ�ʽ
        // id       low   high    base
        int id = 0;
        int low = 0;
        int high = 0;
        int base = 0;
    };

    struct TableDesposit
    {
        std::vector<TableDespositLine>  config;

        std::string GetArea(int tableno);
    };

    static bool ParseTableDesposit(int nRoomID, TableDesposit& tableDesposit);
};

template <>
struct DataLogerRecordParser<PLAYRECORDFORLOG_XZ> : public PlayRecordUtils
{
    static DataLogerRecord::Ptr Parse(const std::string& name, CMyGameTable* pTable, LPGAME_WIN pGameWin, CMyGameServer* svr)
    {
        std::shared_ptr<PLAYRECORDFORLOG_XZ>    pRecord = std::make_shared<PLAYRECORDFORLOG_XZ>();
        auto com = pTable->m_entity.component<GameLogCom>();
        pRecord->settime(com->m_startGameTime);
        pRecord->setnRoomID(pTable->m_nRoomID);

        int nTotalFee = 0;
        for (int i = 0; i < TOTAL_CHAIRS; ++i)
        {
            //nTotalFee += pGameWin->nWinFees[i];�Ĵ��齫����ֶ�û��ֵ����
            nTotalFee += pTable->m_nRoomFees[i];
        }
        pRecord->setnFee(nTotalFee);
        pRecord->setnBaseDeposit(pTable->m_nBaseDeposit);

        int nTotalMultiple = 0;
        for (int i = 0; i < TOTAL_CHAIRS; ++i)
        {
            nTotalMultiple += pTable->m_nMultiple[i];
        }
        pRecord->setnTotalMultiple(nTotalMultiple);

        std::vector<ROLERECORDFORLOG_XZ> roles;
        for (int i = 0; i < pTable->m_nTotalChairs; ++i)
        {
            ROLERECORDFORLOG_XZ role;
            role.setnUserID(pTable->m_PlayersBackup[i].nUserID);
            role.setnTimeCost(pTable->m_nTimeCost[i]);
            role.setnUserType(pTable->m_PlayersBackup[i].nUserType);
            role.setnPlayerType(pTable->m_nNewPlayer[i]);
            role.setnTotalCountXueZhan(pTable->m_nXZTotalGameCount[i]);
            role.setnTotalCount(pTable->m_nTotalGameCount[i]);
            role.setnRole(ROLERECORDFORLOG_XZ::GetRoleType(pTable->m_nBanker, i));
            role.setnWinIdx(pTable->m_nWinOrder[i]);
            role.setnBeginDeposit(pTable->m_nCoutInitialDeposits[i]);
            role.setnLeftDeposit(pGameWin->nOldDeposits[i] + pGameWin->nDepositDiffs[i]);
            role.setnWinMultiple(pTable->m_nMultiple[i]);
            //LPCTSTR lbs = LPCTSTR(pTable->m_PlayersBackup[i].GetPlayerCacheLBS());
            role.setnVersion(12345);
            role.setnSafeDepost(pTable->m_SafeDeposits[i].nDeposit);
            role.setbIsMakeCard(pTable->m_bIsMakeCard[i]);
            role.setnRecommandid(com->m_nRecommandid[i]);
            role.setbWxMobile(com->m_pkgType[i] == 300);
            roles.emplace_back(std::move(role));
        }
        pRecord->getroles().swap(std::move(roles));

        auto data_ = [pRecord]()
        {
            // worker�߳���ִ�е�
            auto parseTimeFunc = [](CTime & ct)
            {
                CString s = ct.Format("%H:%M:%S");
                return std::string(s);
            };
            auto parseDateFunc = [](CTime & ct)
            {
                CString s = ct.Format("%Y-%m-%d");
                return std::string(s);
            };
            auto parseDateTimeFunc = [](CTime & ct)
            {
                CString s = ct.Format("%Y-%m-%d %H:%M:%S");
                return std::string(s);
            };


            TableDesposit config;
            ParseTableDesposit(pRecord->getnRoomID(), config);
            std::stringstream ss;

            LOGDATA_PUSH_LOGDATA(parseDateTimeFunc(pRecord->gettime()));
            LOGDATA_PUSH_LOGDATA(pRecord->getnRoomID());
            LOGDATA_PUSH_LOGDATA(pRecord->getnFee());
            LOGDATA_PUSH_LOGDATA(pRecord->getnBaseDeposit());
            LOGDATA_PUSH_LOGDATA(pRecord->getnTotalMultiple());
            for (auto& role : pRecord->getroles())
            {
                LOGDATA_PUSH_LOGDATA(role.getnUserID());
                LOGDATA_PUSH_LOGDATA(role.getnTimeCost());
                LOGDATA_PUSH_LOGDATA(role.GetUserTypeNameByUserType());
                LOGDATA_PUSH_LOGDATA(role.getnTotalCountXueZhan());
                LOGDATA_PUSH_LOGDATA(role.getnTotalCount());
                LOGDATA_PUSH_LOGDATA(role.GetUserRole());
                LOGDATA_PUSH_LOGDATA(role.getnWinIdx());
                LOGDATA_PUSH_LOGDATA(role.getnBeginDeposit());
                LOGDATA_PUSH_LOGDATA(role.getnLeftDeposit());
                LOGDATA_PUSH_LOGDATA(role.getnWinMultiple());
                //LOGDATA_PUSH_LOGDATA(role.getnVersion());
                LOGDATA_PUSH_LOGDATA(role.getnSafeDepost());
                LOGDATA_PUSH_LOGDATA(role.getbIsMakeCard());
                LOGDATA_PUSH_LOGDATA(role.getnPlayerType());
                LOGDATA_PUSH_LOGDATA(role.getnRecommandid());
            }
            ss << std::endl;
            return ss.str();
        };

        return std::make_shared<DataLogerRecord>(name, data_);
    }
};

//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// playrecordXL begin
typedef struct _tagROLERECORDFORLOG_XL
{
    //��ҶԾ���Ϣ
    //��Ϸ�Ծ���־start
    enum ROLE_TYPE
    {
        ROLE_NONE = 0,
        ROLE_BANKER,
        ROLE_XIANJIA,
        ROLE_COUNT,
    };

    DEFINE_VALUE_HAS_SET_GET(int, nUserID);                             //���ID
    DEFINE_VALUE_HAS_SET_GET(int, nTimeCost);                           //��ʱ(��)
    DEFINE_VALUE_HAS_SET_GET_WITHVALUE(int, nUserType, UT_COMMON);      //�������
    DEFINE_VALUE_HAS_SET_GET(int, nTotalCountXueLiu);                   //Ѫ���ܶԾ���
    DEFINE_VALUE_HAS_SET_GET(int, nTotalCount);                         //�����ܶԾ���
    DEFINE_VALUE_HAS_SET_GET_WITHVALUE(ROLE_TYPE, nRole, ROLE_NONE);    //��ɫ
    DEFINE_VALUE_HAS_SET_GET(int, nHuTimes);                            //���ƴ���
    DEFINE_VALUE_HAS_SET_GET(int, nBeginDeposit);                       //��ʼ����
    DEFINE_VALUE_HAS_SET_GET(int, nLeftDeposit);                        //ʣ������
    DEFINE_VALUE_HAS_SET_GET(int, nWinMultiple);                        //�����ܷ���
    DEFINE_VALUE_HAS_SET_GET(int, nVersion);                            //�汾
    DEFINE_VALUE_HAS_SET_GET(int, nSafeDepost);                         //��������ֵ
    DEFINE_VALUE_HAS_SET_GET(int, bIsMakeCard);                         //�Ƿ�����
    DEFINE_VALUE_HAS_SET_GET(int, nPlayerType);                         //�������
    DEFINE_VALUE_HAS_SET_GET(bool, bWxMobile);                          //�ж��Ƿ���΢�Ŷ�
    DEFINE_VALUE_HAS_SET_GET(::google::protobuf::int32, nRecommandid);                          //������

public:
    std::string GetUserTypeNameByUserType()
    {
        std::string strName = "����";
        if (bWxMobile)
        {
            return "΢�Ŷ�";
        }

        if (IS_BIT_SET(nUserType, UT_HANDPHONE))
        {
            strName = "�ƶ���";
        }
        else if (IS_BIT_SET(nUserType, UT_COMMON) || IS_BIT_SET(nUserType, UT_MEMBER) || IS_BIT_SET(nUserType, UT_MATCH) || IS_BIT_SET(nUserType, UT_ADMIN) || IS_BIT_SET(nUserType, UT_SUPER))
        {
            strName = "PC��";
        }
        else if (IS_BIT_SET(nUserType, UT_ROBOT))
        {
            strName = "������";
        }

        return strName;
    }
    std::string GetUserRole()
    {
        static const std::string ROLE_TYPE_NAME[ROLE_COUNT] = { "����", "ׯ��", "�м�" };
        if (nRole < ROLE_NONE || nRole >= ROLE_COUNT)
        {
            return ROLE_TYPE_NAME[ROLE_NONE];
        }
        return ROLE_TYPE_NAME[nRole];
    }

    static ROLE_TYPE GetRoleType(int banker, int chairno)
    {
        return banker == chairno ? ROLE_BANKER : ROLE_XIANJIA;
    }

} ROLERECORDFORLOG_XL, LPROLERECORDFORLOG_XL;

typedef struct _tagPLAYRECORDFORLOG_XL
{
    //��Ϸ�Ծ���Ϣ
    DEFINE_VALUE_HAS_SET_GET_WITHVALUE(CTime, time, CTime::GetCurrentTime());       //ʱ���
    DEFINE_VALUE_HAS_SET_GET(int, nRoomID);                                         //����ID
    DEFINE_VALUE_HAS_SET_GET(int, nFee);                                            //��ˮ��
    DEFINE_VALUE_HAS_SET_GET(int, nBaseDeposit);                                    //������
    DEFINE_VALUE_HAS_SET_GET(int, nTotalMultiple);                                  //�ܷ���
    DEFINE_VALUE_HAS_SET_GET(std::vector<ROLERECORDFORLOG_XL>, roles);
} PLAYRECORDFORLOG_XL, *LPPLAYRECORDFORLOG_XL;

template <>
struct DataLogerRecordParser<PLAYRECORDFORLOG_XL> : public PlayRecordUtils
{
    static DataLogerRecord::Ptr Parse(const std::string& name, CMyGameTable* pTable, LPGAME_WIN pGameWin, CMyGameServer* svr)
    {
        std::shared_ptr<PLAYRECORDFORLOG_XL>    pRecord = std::make_shared<PLAYRECORDFORLOG_XL>();
        auto com = pTable->m_entity.component<GameLogCom>();
        pRecord->settime(com->m_startGameTime);
        pRecord->setnRoomID(pTable->m_nRoomID);

        int nTotalFee = 0;
        for (int i = 0; i < TOTAL_CHAIRS; ++i)
        {
            //nTotalFee += pGameWin->nWinFees[i];�Ĵ��齫����ֶ�û��ֵ����
            nTotalFee += pTable->m_nRoomFees[i];
        }
        pRecord->setnFee(nTotalFee);
        pRecord->setnBaseDeposit(pTable->m_nBaseDeposit);

        int nTotalMultiple = 0;
        for (int i = 0; i < TOTAL_CHAIRS; ++i)
        {
            nTotalMultiple += pTable->m_nMultiple[i];
        }
        pRecord->setnTotalMultiple(nTotalMultiple);

        std::vector<ROLERECORDFORLOG_XL> roles;
        for (int i = 0; i < pTable->m_nTotalChairs; ++i)
        {
            ROLERECORDFORLOG_XL role;
            role.setnUserID(pTable->m_PlayersBackup[i].nUserID);
            role.setnTimeCost(pTable->m_nTimeCost[i]);
            role.setnUserType(pTable->m_PlayersBackup[i].nUserType);
            role.setnPlayerType(pTable->m_nNewPlayer[i]);
            role.setnTotalCountXueLiu(pTable->m_nXLTotalGameCount[i]);
            role.setnTotalCount(pTable->m_nTotalGameCount[i]);
            role.setnRole(ROLERECORDFORLOG_XL::GetRoleType(pTable->m_nBanker, i));
            role.setnHuTimes(pTable->m_nHuTimes[i]);
            role.setnBeginDeposit(pTable->m_nCoutInitialDeposits[i]);
            role.setnLeftDeposit(pGameWin->nOldDeposits[i] + pGameWin->nDepositDiffs[i]);
            role.setnWinMultiple(pTable->m_nMultiple[i]);
            //LPCTSTR lbs = LPCTSTR(pTable->m_PlayersBackup[i].GetPlayerCacheLBS());
            role.setnVersion(12345);
            role.setnSafeDepost(pTable->m_SafeDeposits[i].nDeposit);
            role.setbIsMakeCard(pTable->m_bIsMakeCard[i]);
            role.setnRecommandid(com->m_nRecommandid[i]);
            role.setbWxMobile(com->m_pkgType[i] == 300);
            roles.emplace_back(std::move(role));
        }
        pRecord->getroles().swap(std::move(roles));

        auto data_ = [pRecord]()
        {
            // worker�߳���ִ�е�
            auto parseTimeFunc = [](CTime & ct)
            {
                CString s = ct.Format("%H:%M:%S");
                return std::string(s);
            };
            auto parseDateFunc = [](CTime & ct)
            {
                CString s = ct.Format("%Y-%m-%d");
                return std::string(s);
            };
            auto parseDateTimeFunc = [](CTime & ct)
            {
                CString s = ct.Format("%Y-%m-%d %H:%M:%S");
                return std::string(s);
            };


            TableDesposit config;
            ParseTableDesposit(pRecord->getnRoomID(), config);
            std::stringstream ss;

            LOGDATA_PUSH_LOGDATA(parseDateTimeFunc(pRecord->gettime()));
            LOGDATA_PUSH_LOGDATA(pRecord->getnRoomID());
            LOGDATA_PUSH_LOGDATA(pRecord->getnFee());
            LOGDATA_PUSH_LOGDATA(pRecord->getnBaseDeposit());
            LOGDATA_PUSH_LOGDATA(pRecord->getnTotalMultiple());
            for (auto& role : pRecord->getroles())
            {
                LOGDATA_PUSH_LOGDATA(role.getnUserID());
                LOGDATA_PUSH_LOGDATA(role.getnTimeCost());
                LOGDATA_PUSH_LOGDATA(role.GetUserTypeNameByUserType());

                LOGDATA_PUSH_LOGDATA(role.getnTotalCountXueLiu());
                LOGDATA_PUSH_LOGDATA(role.getnTotalCount());
                LOGDATA_PUSH_LOGDATA(role.GetUserRole());
                LOGDATA_PUSH_LOGDATA(role.getnHuTimes());
                LOGDATA_PUSH_LOGDATA(role.getnBeginDeposit());
                LOGDATA_PUSH_LOGDATA(role.getnLeftDeposit());
                LOGDATA_PUSH_LOGDATA(role.getnWinMultiple());
                //LOGDATA_PUSH_LOGDATA(role.getnVersion());
                LOGDATA_PUSH_LOGDATA(role.getnSafeDepost());
                LOGDATA_PUSH_LOGDATA(role.getbIsMakeCard());
                LOGDATA_PUSH_LOGDATA(role.getnPlayerType());
                LOGDATA_PUSH_LOGDATA(role.getnRecommandid());
            }
            ss << std::endl;
            return ss.str();
        };

        return std::make_shared<DataLogerRecord>(name, data_);
    }
};

//////////////////////////////////////////////////////////////////////////


#undef LOGDATA_PUSH_LOGDATA
#undef DEFINE_VALUE_HAS_SET_GET
#undef DEFINE_VALUE_HAS_SET_GET_WITHVALUE