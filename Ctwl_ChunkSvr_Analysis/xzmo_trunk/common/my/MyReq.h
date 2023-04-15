#pragma once
#include "../common/TaskReq.h"
#define     GR_PB_ENTER_GAME        (GAME_REQ_BASE_EX + 19001)

#define     GR_GAMEDATA_ERROR       (GAME_REQ_BASE_EX + 29450)  //��Ϸ����
#define     GR_SYSTEMMSG            (GAME_REQ_BASE_EX + 29800)  //ϵͳ֪ͨ 
#define     GR_EXCHANGE_CARDS               (GAME_REQ_BASE_EX + 29820)  //��������
#define     GR_EXCHANGE3CARDS_FINISHED      (GAME_REQ_BASE_EX + 29821)  //��3�Ž���֪ͨ
#define     GR_TASK_AWARD                   (GAME_REQ_BASE_EX + 29830)  //�����н�����֪ͨ   
#define     GR_PLAYER_RECHARGE              (GAME_REQ_BASE_EX + 29840)  //���׼����ֵ
#define     GR_PLAYER_RECHARGEOK            (GAME_REQ_BASE_EX + 29841)  //���׼����ֵ
#define     GR_PLAYER_GOSENIOR              (GAME_REQ_BASE_EX + 29850)  //�����ʾȥ�߼���
#define     GR_GET_WELFAREPRESENT           (GAME_REQ_BASE_EX + 29860)  //��ȡ�ͱ�����
#define     GR_GET_CHARGE_INFO              (GAME_REQ_BASE_EX + 29870)  //��ҳ��ֵ��Ϣ
#define     GR_ABORTPLAYER_INFO_DXXW        (GAME_REQ_BASE_EX + 29880)  //�������棬���뿪�û�����Ϣ�·�

#define     GR_ENTER_IN_TABLE               (GAME_REQ_INDIVIDUAL + 101)  //�������Ӻ����Ϣ������idle,dxxw
#define     GR_ON_PLAYER_HU                 (GAME_REQ_INDIVIDUAL + 102)  //Ѫս�Ⱥ��ƽ���ؽ�����Ϣ����ȥ
#define     GR_MY_TAKE_SAFE_DEPOSIT         (GAME_REQ_INDIVIDUAL + 103)  //�ſ�������Ϸ��ȡ��
#define     GR_PLAYING_DEPOSIT_NOT_ENOUGH   (GAME_REQ_INDIVIDUAL + 104)  //���ƹ�����Ǯ����
#define     GR_ON_PLAYER_GIVE_UP            (GAME_REQ_INDIVIDUAL + 105)  //����
#define     GR_PRE_SAVE_RESULT              (GAME_REQ_INDIVIDUAL + 106)  //��ǰ����
#define     GR_MY_TAKE_BACK_DEPOSIT         (GAME_REQ_INDIVIDUAL + 107)  //�ſ�������Ϸ��ȡ��,����

#define     UR_OPERATE_CANCEL               (UR_REQ_BASE + 10110)

/////////////////////////////////////////��RoomSvr��ͨѶ�Զ���Windows��Ϣ
#define     WM_GTR_RECORD_USER_NETWORK_TYPE_EX  (WM_USER+5004)           //���û��������ʹ���RoomSvr   
/////////////////////////////////////////

#define     UT_ROBOT                        0x40000000                   //������,�Զ����û�����

enum XOGAMEMSGEX
{
    //��Ϸ��Ϣ��ע��ͻ��˹�ͨ,������������Ϣ���ᱣ�浽replay
    XOGAMEMSGEX_BEGIN = GAMEMSGEX_END + 1,

    SYSMSG_GAME_AUTOKICKOFF,                        //�Զ�����
    LOCAL_GAME_MSG_AUTO_HU,                         //����
    LOCAL_GAME_MSG_AUTO_GUO,                        //����˰����ͻ��˹���
    LOCAL_GAME_MSG_AUTO_FIXMISS,                    //��ȱ
    LOCAL_GAME_MSG_AUTO_EXCHANGECARDS,              //������
    LOCAL_GAME_MSG_AUTO_GIVEUP,                     //����

    XOGAMEMSGEX_END
};

enum GameResultFlag
{
    ResultByMnGang = 1,
    ResultByPnGang,
    ResultByAnGang,
    ResultByHu,
    ResultByGiveUp,
    ResultByFee,
};

typedef struct _tagLOOKER_GAME_START_INFO
{
    MJ_START_DATA StartData;

    DWORD   dwGameFlags;        //��Ϸ״̬
    int     nChairNO;// ��¼���Ӻţ��ͻ��˱���¼��ʱ����
    int     nCardsCount[TOTAL_CHAIRS];  // ÿ�����������Ƶ�����
    int     nChairCards[TOTAL_CHAIRS][CHAIR_CARDS]; // ����������
    int     nReserved[4];
} LOOKER_GAME_START_INFO, *LPLOOKER_GAME_START_INFO;

typedef struct _tagENTER_IN_TABLE
{
    int nMinDeposit;
    int nMaxDeposit;
    int nReserved[8];
} ENTER_IN_TABLE, *LPENTER_IN_TABLE;

typedef struct _tagCHECK_INFO
{
    int nHuaZhuPoint[TOTAL_CHAIRS];
    int nHuaZhuDeposit[TOTAL_CHAIRS];
    int nDaJiaoPoint[TOTAL_CHAIRS];
    int nDaJiaoDeposit[TOTAL_CHAIRS];
    int nDrawbackPoint[TOTAL_CHAIRS];
    int nDrawbackDeposit[TOTAL_CHAIRS];
    int nReserved[4];
} CHECK_INFO, *LPCHECK_INFO;

typedef struct _tagPRESAVE_INFO
{
    int nPreSaveDeposit;
    int nPreSaveAllDeposit;
    int nPreSaveAllFan;
    int nUserID;
} PRESAVE_INFO, *LPPRESAVE_INFO;

typedef struct _tagGIVEUP_INFO
{
    int nNeedDeposit;
    int nLastSecond;
    int nGiveUpChair[TOTAL_CHAIRS];
    int nReserved[4];
} GIVEUP_INFO, *LPGIVEUP_INFO;

typedef struct _tagPLAYER_RECHARGE
{
    int nUserID;                                // �û�ID
    int nRoomID;                                // ����ID
    int nTableNO;                               // ����
    int nChairNO;                               // λ��
    int nDelayTime;                             // ��ʱʱ��
    int nReserved[4];
} PLAYER_RECHARGE, *LPPLAYER_RECHARGE;

typedef struct _tagPRE_SAVE_RESULT
{
    int nFlag;
    int nHuStatus;
    int nOldScores[TOTAL_CHAIRS];                   // �ɻ���
    int nOldDeposits[TOTAL_CHAIRS];                 // ������
    int nScoreDiffs[TOTAL_CHAIRS];                  // ��������
    int nDepositDiffs[TOTAL_CHAIRS];                // ������Ӯ
    int nIdlePlayerFlag;                            // ���״̬;��λ0��7λ��ʾ�������״̬��1ΪIdlePlayer���Ѿ�����Ŀ�����ң����ߺ�������Ŀ������
    int nChairNO;
    int nPreSaveAllDeposit;
    int nReserved[2];
} PRE_SAVE_RESULT, *LPPRE_SAVE_RESULT;

typedef struct _tagHU_ITEM_INFO
{
    BOOL bWin;                                      //�Ƿ���Ӯ
    BOOL bSend;                                     //�Ƿ��Ѿ�����
    int nHuFlag;                                    //MJ_HU_FANG,MJ_HU_ZIMO,MJ_HU_QGNG��
    int nHuID;                                      //����ID
    int nHuFan;                                     //���Ʒ���(���ﴫ�ı���)
    int nHuDeposits;                                //������Ӯ
    int nHuGains[HU_MAX];                           //���Ʒ���
    int nRelateChair[TOTAL_CHAIRS];                 //��ϵ��ң������߻��߱������߻��߱���������
    int nReserved[4];
} HU_ITEM_INFO, *LPHU_ITEM_INFO;

typedef struct _tagHU_ITEM_HEAD
{
    int nCount;
    int nChairNO;
    int nPreSaveAllDeposit;
    int nReserved[4];
} HU_ITEM_HEAD, *LPHU_ITEM_HEAD;

typedef struct _tagHU_ITEM_HEAD_PC
{
    int nItemCount[TOTAL_CHAIRS];
    int nReserved[4];
} HU_ITEM_HEAD_PC, *LPHU_ITEM_HEAD_PC;

typedef struct _tagHU_ID_HEAD
{
    int nCount[TOTAL_CHAIRS];
    int nReserved[4];
} HU_ID_HEAD, *LPHU_ID_HEAD;

typedef struct _tagHU_DETAILS_SMALL
{
    int nChairNO;
    DWORD dwHuFlags[2];                             // ���Ʊ�־
    int nHuGains[HU_MAX];                           // ���Ʒ���
    int nTotalGains;                                // �ܷ���
    int nTotalDeposits;                             // ����Ӯ
    int nLoseChair[TOTAL_CHAIRS];                   // ������ң�������
    CHECK_INFO stCheckInfo;                         // �����е÷�
    int nReserved[4];
} HU_DETAILS_SMALL, *LPHU_DETAILS_SMALL;

typedef struct _tagGAME_WIN_RESULT
{
    GAME_WIN_MJ gamewin;

    int     nCardsCount[TOTAL_CHAIRS];              // ÿ�����������Ƶ�����
    int     nChairCards[TOTAL_CHAIRS][CHAIR_CARDS]; // �Լ��������
    int     nFees[TOTAL_CHAIRS];
    int     nTotalDepositDiff[TOTAL_CHAIRS];        //һ��������Ӯ
    CARDS_UNIT  nOutCards[TOTAL_CHAIRS][4];     // ������ܳԳ�����(ÿ��������4��)
    int     nOutCount[TOTAL_CHAIRS];
    int     nReserved[8];
} GAME_WIN_RESULT, *LPGAME_WIN_RESULT;

//һ��255BYTE
typedef struct _tagSYSTEMMSG
{
    int  nRoomID;                                   // ����ID
    int  nUserID;                                   // �û�ID
    int  nMsgID;                                    // ��Ϣ��
    int  nChairNO;                                  // λ��
    int  nFangCardChairNO;                          // �ų�λ��
    DWORD nEventID;                                 // �¼���
    DWORD nMJID;                                    // �ƺ�
} SYSTEMMSG, *LPSYSTEMMSG;

//����
enum PLAYER_TYPE
{
    PLAYER_BASE = 0,    //�������
    PLAYER_NEW_LEVEL_ONE,       // һ�����
    PLAYER_NEW_LEVEL_TWO,       // �������
    PLAYER_ROBOT,
    PLAYER_ROBOT_USER,
    PLAYER_LOSS,        //�������ֽ�����һ��
    PLAYER_JUMP,        //��ת���������
    PLAYER_PAY,         //��ֵ�ɹ�������
    PALYER_MAX
};

#define  MAX_TYPE   PALYER_MAX

//����
enum INTERVENE_TYPE
{
    INTERVENE_CATCH_BASE = 0,    //�������
    INTERVENE_CATCH_ROBOT,
    INTERVENE_CATCH_ROBOTTING,
    INTERVENE_THROW_ROBOT,
    INTERVENE_THROW_TING,
};

typedef struct _tagMAKECARD_INFO
{
    int nHandScore; //��ʼ���Ʒ���
    int nMakeDeal; //0:δ���ƣ�1:shape��2:type
    int nMakeExchange; //0:δ����
    int nMakeCatch; //0:δ���ƣ�1:shape��2:type
    int nMakeCount; //���ƴ���
    int nLossCount; //�������
    int nJumpCount; //������ת�����
    int nPayCount;  //��ֵ�����
    int nWinBout;
    int nReserved[4];
} MAKECARD_INFO, *LPMAKECARD_INFO;

typedef struct _tagMAKECARD_CONFIG
{

    int nDealOpen;              //���ƿ���
    int nExchangeOpen;          //�����ſ���
    int nCatchOpen;             //���ƿ���

    int nTotalBount[MAX_TYPE];  // �����û��ȼ��ж�����: �ܾ���
    int nWinBount[MAX_TYPE];    // �����û��ȼ��ж�����: ʤ��

    int nDealPercent[MAX_TYPE]; //���Ƹ���
    int nDShapeScore[MAX_TYPE]; //���ƻ�ɫ��Ԥ��
    int nDTypeScore[MAX_TYPE];  //�������͸�Ԥ��

    int nGangScore;             //����������
    int nPengScore;             //����������
    int nDuizScore;             //����������
    int nShunScore;             //˳��������

    int nCatchPercent;          //ץ�Ƹ���
    int nCXZExpectBei;          //ѪսԤ�ڱ���
    int nCXLExpectBei;          //Ѫ��Ԥ�ڱ���
    int nCGPDPercent[3];        //�����Եı���
    int nCShapeScore[MAX_TYPE]; //���ƻ�ɫ��Ԥ��
    int nCTypeScore[MAX_TYPE];  //�������͸�Ԥ��

    int nReserved[4];
} MAKECARD_CONFIG, *LPMAKECARD_CONFIG;

typedef struct _tagPROB
{
    int    nRemainCout;
    int    nGangCardProb;
    int    nPengCardProb;
    int    nHuCardProb;
    int    nNotDingQueCardProb;
} PROB, *LPPROB;

typedef struct _tagMAKECARDPROB
{
    //���Ƹ�Ԥ����
    vector<PROB>    vPlayBoutCatch;
    vector<PROB>    vRobotBoutCatch;
    vector<PROB>    vRobotBoutTingCatch;

    //�����˳��Ƹ���
    vector<PROB>    vRobotBoutThrow;
    vector<PROB>    vRobotBoutTingThrow; //�û����ƺ�����˳��Ƹ���

    int nReserved[4];
} MAKECARD_PROB, *LPMAKECARDPROB;

//��ȱ
typedef struct _tagAUCTION_DINGQUE
{
    int nDingQueCardType[TOTAL_CHAIRS];             //��ȱ���� nCards
    BOOL bAuto;                                     //
    int nUserID;                                    // �û�ID
    int nRoomID;                                    // ����ID
    int nTableNO;                                   // ����
    int nChairNO;                                   // λ��
    DWORD dPGCH[TOTAL_CHAIRS];
    int nReserved[4];
} AUCTION_DINGQUE, *LPAUCTION_DINGQUE;

//������
typedef struct _tagEXCHANGE3CARDS
{
    int nUserID;                                    // �û�ID
    int nRoomID;                                    // ����ID
    int nTableNO;                                   // ����
    int nChairNO;                                   // λ��
    int nSendTable;                                 //
    int nSendChair;
    int nSendUser;
    int nExchange3CardsCount;
    int nExchangeDirection;
    int nExchange3Cards[TOTAL_CHAIRS][EXCHANGE3CARDS_COUNT];//jiaohuan����
    int nReserved[4];
} EXCHANGE3CARDS, *LPEXCHANGE3CARDS;

typedef struct _tagCOMB_CARD_EX
{
    int nUserID;                                    // �û�ID
    int nRoomID;                                    // ����ID
    int nTableNO;                                   // ����
    int nChairNO;                                   // λ��
    int nCardChair;                                 // ������������λ��
    int nCardID;                                    // ��������ID
    int nBaseIDs[MJ_UNIT_LEN - 1];                  // �������������
    DWORD dwFlags;                                  // ��־λ
    int nCardGot;                                   // �ܵ�����
    int nCardNO;                                    // �ܵ�����λ��
    int nGangPoint[TOTAL_CHAIRS];
    int nReserved[4];
} COMB_CARD_EX, *LPCOMB_CARD_EX;

typedef struct _tagCARD_CAUGHT_EX
{
    int nChairNO;                                   // λ��
    int nCardID;                                    // ��ID
    int nCardNO;                                    // ��λ��
    DWORD dwFlags;                                  // ��־
    int nGangPoint[TOTAL_CHAIRS];
    int nReserved[4];
} CARD_CAUGHT_EX, *LPCARD_CAUGHT_EX;

typedef COMB_CARD_EX GANG_CARD_EX;
typedef LPCOMB_CARD_EX LPGANG_CARD_EX;
typedef COMB_CARD_EX CARD_GANG_EX;
typedef LPCOMB_CARD_EX LPCARD_GANG_EX;


// ����
/////////////////////////////////////////////////////////////////////

#define MAX_TYPE_COUNT 3

typedef struct _tagPLAYERTASKINFO
{
    int nUserID;
    TASKDATAEX taskDataEx[MAX_TYPE_COUNT];
} PLAYERTASKINFO, *LPPLAYERTASKINFO;

#define     EXCEPTION_PLAY_TIME         (60*60)     //�쳣�Ծ�ʱ��(��)

typedef struct _tagROLERECORD
{
    //��ҶԾ���Ϣ
    int         nUserID;                            //���ID
    int         nUserType;                          //�������
    int         nBeginDeposit;                      //��ʼ����
    int         nTakeDeposit;                       //�ӱ���������ȡ��������
    int         nLeftDeposit;                       //ʣ������
    int         nDepositDiff;                       //��Ӯ����
    int         nTimeCost;                          //��ս��ʱ��ʱ
    int         nHuCount;                           //���ƴ���
    int         nHuTotalFan;                        //�ܷ���
    int         nHandScore;                         //��ʼ����ֵ
    int         nMakeDeal;                          //���Ƹ�Ԥ
    int         nMakeCatch;                         //���Ƹ�Ԥ
    int         nPengCount;                         //������
    int         nGangCount;                         //�ܴ���
    //CTime     goSeniorTime;                       //���ȥ�߼���ʱ��

    _tagROLERECORD()
    {
        nUserID = 0;
        nUserType = UT_COMMON;
        nBeginDeposit = 0;
        nTakeDeposit = 0;
        nLeftDeposit = 0;
        nDepositDiff = 0;
        nTimeCost = 0;
        nHuCount = 0;
        nHuTotalFan = 0;
        nHandScore = 0;
        nMakeDeal = 0;
        nMakeCatch = 0;
        nPengCount = 0;
        nGangCount = 0;
        //goSeniorTime = CTime(2018, 11, 11, 0, 0, 0);
    }
} ROLE, LPROLE;

typedef struct _tagPLAYRECORD
{
    //��Ϸ�Ծ���Ϣ
    CTime   time;                                   //ʱ���
    int     nRoomID;                                //����ID
    int     nTotalTimeCost;                         //�ܺ�ʱ(��)
    int     nBaseDeposit;                           //������
    int     nFee;                                   //��ˮ��
    int     nMakeExchange;                          //�����Ÿ�Ԥ
    int     nDelayCount;                            //�ӳ��������
    CString strSerialNO;                            //�������к�
    ROLE    role[TOTAL_CHAIRS];                     //����б�
    BOOL    isGameOver;                             //�Ծ��Ƿ����
    _tagPLAYRECORD()
    {
        nRoomID = 0;
        nTotalTimeCost = 0;
        nBaseDeposit = 0;
        nFee = 0;
        nMakeExchange = 0;
        nDelayCount = 0;
        isGameOver = FALSE;
    }
} PLAYRECORD, *LPPLAYRECORD;

typedef struct _tagTransferInfo
{
    int nAniChairNo;                        //��Ǯ���chairNO
    int nDeposit[MAX_CHAIR_COUNT];          //������Ӯ�仯
} TRANSFER_INFO, *LPTRANSFER_INFO;

typedef struct _tagGameEndCheckInfo
{
    int nHuaZhuPoint[TOTAL_CHAIRS];
    int nHuaZhuDePosit[TOTAL_CHAIRS];
    int nDajiaoPoint[TOTAL_CHAIRS];
    int nDajiaoDePosit[TOTAL_CHAIRS];
    int nDrawBackPoint[TOTAL_CHAIRS];
    int nDrawBackDeposit[TOTAL_CHAIRS];
    int nTransferPoint[TOTAL_CHAIRS];
    int nTransferDeposit[TOTAL_CHAIRS];
    int nHuPoint[TOTAL_CHAIRS];
    int nHuDeposit[TOTAL_CHAIRS];
    int nFlag;
    int nReserved[4];
} GAMEEND_CHECK_INFO, *LPGAMEEND_CHECK_INFO;

//�������� begin
typedef struct _tagPlayerNewbieTaskINFO
{
    int nUserID;                // userid
    int nType;                 //��������
    int nCompleteNum; //��ɼ���
    int nReserved[4];       // �����ֶ�
} PLAYERNEWBITASKINFO, *LPPLAYERNEWBITASKINFO;

//�������� end

typedef struct _tagPLAYER_ABORT_HEAD
{
    int nRoomID;                                // ����ID
    int nTableNO;                               // ����
    int nAbortPlayerCount;                      // ���뿪�����
    int nReserved[4];
} PLAYER_ABORT_HEAD, *LPPLAYER_ABORT_HEAD;

typedef struct _tagABORTPLAYER_INFO
{
    int nUserID;                                // �û�ID
    int nTableNO;                               // ����
    int nChairNO;                               // λ��
    TCHAR szUsername[MAX_USERNAME_LEN];         // �û���
    int nDeposit;                               // ����
    int nNickSex;                               // ��ʾ�Ա� -1: δ֪; 0: ����; 1: Ů��
    int nPortrait;                              // ͷ��
    int nWin;                                   // Ӯ
    int nLoss;                                  // ��
    int nStandOff;                              // ��
    int nReserved[4];
} ABORTPLAYER_INFO, *LPABORTPLAYER_INFO;

typedef struct _tagGET_WELFARE_PRESENT_OK
{
    int   nUserID;
    int   nActivityID;          // �ID
    int   nCount;                //ʣ�����
    int   nReserved[5];
} GET_WELFARE_PRESENT_OK, *LPGET_WELFARE_PRESENT_OK;

typedef struct _tagCHARGE_INFO
{
    TCHAR   BaseUrl[MAX_PATH];
    int   nReserved[4];
} CHARGE_INFO, *LPCHARGE_INFO;

typedef struct _tagPLAYER_GO_SENIOR
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    int nSeniorID;
    BOOL bShowSenior;
    TCHAR szSerialNO[MAX_SERIALNO_LEN]; //�������к�
    int nReserved[4];
} PLAYER_GO_SENIOR, *LPPLAYER_GO_SENIOR;

typedef struct _tagGET_WELFAREPRESENT
{
    int   nUserID;
    int   nRoomID;                              // ����ID
    int   nTableNO;                             // ����
    int   nChairNO;                             // λ��
    DWORD dwIPAddr;
    int   nActivityID;                          // �ID
    TCHAR szHardID[MAX_HARDID_LEN];
    DWORD dwSoapFlags;
    TCHAR szSoapReturn[MAX_SOAP_URL_LEN];
    DWORD dwFlags;
    int   nReserved[8];
} GET_WELFAREPRESENT, *LPGET_WELFAREPRESENT;

#define TASK_TYPE_COUNT 3     //�����������
typedef int GRUOPID;
typedef struct  _tagTaskConInfo
{
    int nGroupId;        //������ID
    int nSubId;          //������ID
    int nConType;        //��������
    int nConValue;       //�����������
} TASK_CONDINFO, *LPTASK_CONDINFO;

typedef struct _tagHU_MULTI_INFO
{
    int nHuFlag;
    int nHuCard;
    int nHuCount;
    int nHuChair[TOTAL_CHAIRS];
    int nLossChair[TOTAL_CHAIRS];
} HU_MULTI_INFO, *LPHU_MULTI_INFO;

typedef struct _tagGAME_TABLE_INFO
{
    MJ_START_DATA StartData;
    MJ_PLAY_DATA PlayData;

    DWORD   dwGameFlags;        //��Ϸ״̬
    int     nCardsCount[TOTAL_CHAIRS];              // ÿ�����������Ƶ�����
    int     nChairCards[CHAIR_CARDS];               // �Լ��������
    int     nAskExit[TOTAL_CHAIRS];                 //�����˳��Ĵ���
    int     nGangKaiCount;                          // �ܸ���
    int     nResultDiff[MAX_CHAIR_COUNT][MAX_RESULT_COUNT];
    int     nTotalResult[MAX_CHAIR_COUNT];
    int     nHuReady[TOTAL_CHAIRS];                 //�������
    int     nHuMJID[TOTAL_CHAIRS];                  //������
    int     nDingQueCardType[TOTAL_CHAIRS];         //��ȱ����
    int     nDingQueWait;                           //��ȱ�ȴ�ʱ��
    int     nGiveupWait;                            //�����ȴ�ʱ��
    int     nExchange3CardsWait;                    //�����ŵȴ�ʱ��
    int     nExchange3Cards[EXCHANGE3CARDS_COUNT];  //�����ŵ���
    int     nShowTask;                              //�ͻ����Ƿ���ʾ����
    int     nLastThrowNO;                           //���һ�γ������
    DWORD   dwPGCHFlags[TOTAL_CHAIRS];
    DWORD   dwPregGangFlags;                        // ���ܺ��к�̨������
    int     nPreGangCardID;
    int     nReserved[4];
} GAME_TABLE_INFO, * LPGAME_TABLE_INFO;

typedef struct _tagHU_DETAILS_EX
{
    int     nChairNO;
    DWORD   dwHuFlags[2];       // ���Ʊ�־
    int     nHuGains[HU_MAX];   // ���Ʒ���
    int     nTotalGains;        // �ܷ���
    int     nGangGains;         // ���ƽ���
    int     nHasGang;           // �Ƿ�ܹ���
    int     nFourBao;           // 4������
    int     nFeiBao;            // �ɱ�����
    int     nBankerHold;        //��ׯ����
    int     nReserved[4];
} HU_DETAILS_EX, * LPHU_DETAILS_EX;

typedef struct _tagGAME_START_INFO
{
    MJ_START_DATA StartData;

    int     nCardsCount[TOTAL_CHAIRS];              // ÿ�����������Ƶ�����
    int     nChairCards[CHAIR_CARDS];               // �Լ��������
    int     nDingQueWait;                           //��ȱ�ȴ�ʱ��
    int     nGiveupWait;                            //�����ȴ�ʱ��
    int     nShowTask;                              //�ͻ����Ƿ���ʾ����
    int     nReserved[4];

} GAME_START_INFO, * LPGAME_START_INFO;

typedef struct _tagLOOKER_TABLE_INFO
{
    BOOL    bRefuse[TOTAL_CHAIRS];
    BOOL    bAllowd[TOTAL_CHAIRS];
    int     nCardsCount[TOTAL_CHAIRS];  // ÿ�����������Ƶ�����
    int     nChairCards[TOTAL_CHAIRS][CHAIR_CARDS]; // ����������
    int     nReserved[4];
} LOOKER_TABLE_INFO, * LPLOOKER_TABLE_INFO;


typedef struct _tagGAME_TIMER
{
    int     nRoomID;
    int     nTableNO;
    int     nChairNO;
    DWORD   dwStatus;
} GAME_TIMER, *LPGAME_TIMER;