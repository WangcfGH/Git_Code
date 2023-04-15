#pragma once

//From tcgkd1.0
#define     GR_AUCTION_BANKER       (GAME_REQ_BASE_EX + 22070)      // ��ҽ�ׯ��Ϣ
#define     GR_THROW_CARDS          (GAME_REQ_BASE_EX + 22080)      // ��ҳ�����Ϣ
#define     GR_THROW_AGAIN          (GAME_REQ_BASE_EX + 22100)      // ���غϷ�����
#define     GR_BANKER_AUCTION       (GAME_REQ_BASE_EX + 22165)      // ��ҽ�ׯ֪ͨ
#define     GR_AUCTION_FINISHED     (GAME_REQ_BASE_EX + 22168)      // ��ׯ����֪ͨ
#define     GR_CARDS_THROW          (GAME_REQ_BASE_EX + 22170)      // ��ҳ���֪ͨ
#define     GR_INVALID_THROW        (GAME_REQ_BASE_EX + 22175)      // �Ƿ�����֪ͨ
#define     GR_MERGE_THROWCARDS     (GAME_REQ_BASE_EX + 29211)      // �ϲ���ĳ�����Ϣ   client->svr
#define     GR_MERGE_CARDSTHROW     (GAME_REQ_BASE_EX + 29212)      // �ϲ���ĳ�����Ϣ   svr->client
// req id from 229000 to 229999
// request (from game clients)
#define     GR_CATCH_CARD           (GAME_REQ_BASE_EX + 29000)      // ���ץ��
#define     GR_GUO_CARD             (GAME_REQ_BASE_EX + 29005)      // ��ҹ���
#define     GR_PREPENG_CARD         (GAME_REQ_BASE_EX + 29010)      // ���׼������
#define     GR_PREGANG_CARD         (GAME_REQ_BASE_EX + 29015)      // ���׼������
#define     GR_PRECHI_CARD          (GAME_REQ_BASE_EX + 29020)      // ���׼������

#define     GR_PENG_CARD            (GAME_REQ_BASE_EX + 29025)      // �������
#define     GR_CHI_CARD             (GAME_REQ_BASE_EX + 29030)      // ��ҳ���
#define     GR_MN_GANG_CARD         (GAME_REQ_BASE_EX + 29045)      // ��Ҹ���(����)
#define     GR_AN_GANG_CARD         (GAME_REQ_BASE_EX + 29047)      // ��Ҹ���(����)
#define     GR_PN_GANG_CARD         (GAME_REQ_BASE_EX + 29049)      // ��Ҹ���(����)
#define     GR_HUA_CARD             (GAME_REQ_BASE_EX + 29060)      // ��Ҳ���
#define     GR_HU_CARD              (GAME_REQ_BASE_EX + 29080)      // ��Һ���

// response (to game clients)
#define     GR_HU_GAINS_LESS        (GAME_REQ_BASE_EX + 29100)      // ����ʧ��(��������)
#define     GR_NO_CARD_CATCH        (GAME_REQ_BASE_EX + 29101)      // ץ��ʧ��(���ƿ�ץ)

// nofication (to game clients)
#define     GR_CARD_CAUGHT          (GAME_REQ_BASE_EX + 29160)      // ���ץ��
#define     GR_CARD_GUO             (GAME_REQ_BASE_EX + 29165)      // ��ҹ���
#define     GR_CARD_PREPENG         (GAME_REQ_BASE_EX + 29170)      // ���׼������
#define     GR_CARD_PRECHI          (GAME_REQ_BASE_EX + 29175)      // ���׼������
#define     GR_PREGANG_OK           (GAME_REQ_BASE_EX + 29180)      // ��ҿ��Ը���

#define     GR_CARD_PENG            (GAME_REQ_BASE_EX + 29185)      // �������
#define     GR_CARD_CHI             (GAME_REQ_BASE_EX + 29190)      // ��ҳ���
#define     GR_CARD_MN_GANG         (GAME_REQ_BASE_EX + 29195)      // ��Ҹ���(����)
#define     GR_CARD_AN_GANG         (GAME_REQ_BASE_EX + 29197)      // ��Ҹ���(����)
#define     GR_CARD_PN_GANG         (GAME_REQ_BASE_EX + 29199)      // ��Ҹ���(����)
#define     GR_CARD_HUA             (GAME_REQ_BASE_EX + 29210)      // ��Ҳ���
//���������ع�begin
#define     GR_RECONS_CHI_CARD      (GAME_REQ_BASE_EX + 29213)      //��
#define     GR_RECONS_PENG_CARD     (GAME_REQ_BASE_EX + 29214)      //��
#define     GR_RECONS_MNGANG_CARD   (GAME_REQ_BASE_EX + 29215)      //����
#define     GR_RECONS_PNGANG_CARD   (GAME_REQ_BASE_EX + 29216)      //����
#define     GR_RECONS_ANGANG_CARD   (GAME_REQ_BASE_EX + 29217)      //����
#define     GR_RECONS_GUO_CARD      (GAME_REQ_BASE_EX + 29218)      //��
#define     GR_RECONS_FANGPAO       (GAME_REQ_BASE_EX + 29219)          //����
//end

#define     GR_GAMEDATA_ERROR   (GAME_REQ_BASE_EX + 29450)  //�ͻ��˷����������ݲ�ͬ��
//��sk2.0��ֲ��
#define     GR_SENDMSG_TO_PLAYER   (GAME_REQ_BASE_EX + 29500)       //ϵͳ֪ͨ��ת���������
#define     GR_SENDMSG_TO_SERVER   (GAME_REQ_BASE_EX + 29510)       //ϵͳ֪ͨ, ���͸�ϵͳ
#define     GR_INITIALLIZE_REPLAY  (GAME_REQ_BASE_EX + 29520)       //��ʼ��replay
#define     GAME_MSG_DATA_LENGTH 256

//һ��256+40BYTE
#define  GAME_MSG_DATA_LENGTH                      256
#define  GAME_MSG_SEND_EVERYONE                     -1 //�����Լ�,�����Թ�
#define  GAME_MSG_SEND_OTHER                        -2 //�����Լ�,�����Թ�
#define  GAME_MSG_SEND_EVERY_PLAYER                 -3 //���͸������Լ����������
#define  GAME_MSG_SEND_OTHER_PLAYER                 -4 //���͸������Լ����������
#define  GAME_MSG_SEND_VISITOR                      -5 //���͸������Թ���

enum GAMEMSG
{
    SYSMSG_BEGIN = 19840323,
    SYSMSG_RETURN_GAME,            //
    SYSMSG_PLAYER_ONLINE,          //�������
    SYSMSG_PLAYER_OFFLINE,         //���˵�����
    SYSMSG_GAME_CLOCK_STOP,        //��Ϸʱ��ֹͣ��ֹͣ5��ʱ���͸�����,
    SYSMSG_GAME_DATA_ERROR,        //��������֪ͨ�ͻ���������Ϣ���쳣
    SYSMSG_GAME_ON_AUTOPLAY,       //�ͻ����й�
    SYSMSG_GAME_CANCEL_AUTOPLAY,   //�й���ֹ
    SYSMSG_GAME_WIN,               //��Ϸ����
    SYSMSG_GAME_TEST,
    SYSMSG_END,
    //��Ϸ��Ϣ��ע��ͻ��˹�ͨ,������������Ϣ���ᱣ�浽replay
    LOCAL_GAME_MSG_BEGIN,
    LOCAL_GAME_MSG_AUTO_THROW,                //����
    LOCAL_GAME_MSG_AUTO_CATCH,                 //����
    LOCAL_GAME_MSG_FRIENDCARD,         //�Լ���
    LOCAL_GAME_MSG_END,
};

//yqwautoplay begin
enum GAMEMSG_EX
{
    //��Ϸ��Ϣ��ע��ͻ��˹�ͨ,������������Ϣ���ᱣ�浽replay
    GAMEMSGEX_BEGIN = LOCAL_GAME_MSG_END + 1,
    LOCAL_GAME_MSG_QUICK_CATCH,
    YQW_SYSMSG_PLAYER_ONLINE,
    LOCAL_GAME_MSG_CHI,
    LOCAL_GAME_MSG_PENG,
    LOCAL_GAME_MSG_MN_GANG,
    LOCAL_GAME_MSG_PN_GANG,
    LOCAL_GAME_MSG_AN_GANG,
    LOCAL_GAME_MSG_HU,
    LOCAL_GAME_MSG_ZIMO_HU,
    LOCAL_GAME_MSG_QGANG_HU,
    GAMEMSGEX_END
};
//yqwautoplay end
typedef struct _tagAUCTION_BANKER
{
    int nUserID;                                // �û�ID
    int nRoomID;                                // ����ID
    int nTableNO;                               // ����
    int nChairNO;                               // λ��
    BOOL bPassed;                               // ����
    int nGains;                                 // �з�
    int nReserved[4];
} AUCTION_BANKER, *LPAUCTION_BANKER;

typedef struct _tagBANKER_AUCTION
{
    int nUserID;                                // �û�ID
    int nChairNO;                               // λ��
    BOOL bPassed;                               // ����
    int nGains;                                 // �з�
    int nReserved[4];
} BANKER_AUCTION, *LPBANKER_AUCTION;

typedef struct _tagAUCTION_FINISHED
{
    int nBanker;                                // ׯ��
    int nObjectGains;                           // ���
    int nBottomIDs[MAX_BOTTOM_CARDS];           // ����ID
    int nReserved[4];
} AUCTION_FINISHED, *LPAUCTION_FINISHED;

typedef struct _tagTHROW_CARDS
{
    int nUserID;                                // �û�ID
    int nRoomID;                                // ����ID
    int nTableNO;                               // ����
    int nChairNO;                               // λ��
    BOOL bPassive;                              // �Ƿ񱻶�
    SENDER_INFO sender_info;                    // ��������Ϣ
    DWORD dwCardsType;                          // ����
    int nReserved[4];
    int nCardsCount;                            // ������
    int nCardIDs[MAX_CARDS_PER_CHAIR];          // �������(ID)
} THROW_CARDS, *LPTHROW_CARDS;

typedef struct _tagCARDS_THROW
{
    int nUserID;                                // �û�ID
    int nChairNO;                               // λ��
    int nNextChair;                             // ��һ��
    BOOL bNextFirst;                            // ��һ���Ƿ��һ�ֳ���
    BOOL bNextPass;                             // ��һ���Ƿ��Զ�����
    int nRemains;                               // ʣ�¼���
    DWORD dwFlags[MAX_CHAIR_COUNT];             // ��־
    DWORD dwCardsType;                          // ����
    int nThrowCount;                            // ���Ƶڼ��ּ���
    int nReserved[4];
    int nCardsCount;                            // ������
    int nCardIDs[MAX_CARDS_PER_CHAIR];          // �������(ID)
} CARDS_THROW, *LPCARDS_THROW;

typedef struct _tagTHROW_AGAIN
{
    int nReserved[4];
    int nCardsCount;                            // ������
    int nCardIDs[MAX_CARDS_PER_CHAIR];          // �������(ID)
} THROW_AGAIN, *LPTHROW_AGAIN;

typedef struct _tagTHROW_OK
{
    int nNextChair;                             // ��һ������
    BOOL bNextFirst;                            // �Ƿ��һ��
} THROW_OK, *LPTHROW_OK;
//From end

typedef struct _tagMJ_START_DATA
{
    TCHAR   szSerialNO[MAX_SERIALNO_LEN];
    int     nBoutCount;             // �ڼ���
    int     nBaseDeposit;           // ��������
    int     nBaseScore;             // ��������
    int     nBanker;                // ׯ�����Ӻ�
    int     nBankerHold;            // ������ׯ����
    int     nCurrentChair;          // ��ǰ����Ӻ�
    DWORD   dwStatus;               // ��ǰ״̬
    DWORD   dwCurrentFlags;         // ��ǰ�ܷ����

    int     nFirstCatch;            // �����Ƶ��˵���λ
    int     nFirstThrow;            // �ȳ��Ƶ��˵���λ

    int     nThrowWait;             // ���Ƶȴ�ʱ��(��)
    int     nMaxAutoThrow;          // ��ϵͳָ��������Զ�������,�ﵽ�����Ŀ�Ͷ���
    int     nEntrustWait;           // �йܵȴ�ʱ��(��)

    BOOL    bNeedDeposit;           // �Ƿ���Ҫ����
    BOOL    bForbidDesert;          // ��ֹǿ��

    int     nDices[MAX_DICE_NUM];   // ���Ӵ�С
    BOOL    bQuickCatch;            // ����ץ��
    BOOL    bAllowChi;              // �����
    BOOL    bAnGangShow;            // ���ܵ����ܷ���ʾ
    BOOL    bJokerSortIn;           // �����Ʋ��̶���ͷ��
    BOOL    bBaibanNoSort;          // ��������Ʋ������
    int     nBeginNO;               // ��ʼ����λ��
    int     nJokerNO;               // ����λ��
    int     nJokerID;               // ������ID
    int     nJokerID2;              // ������ID2
    int     nFanID;                 // ����ID
    int     nTailTaken;             // β�ϱ�ץ������
    int     nCurrentCatch;          // ��ǰץ��λ��
    int     nPGCHWait;              // ���ܳԺ��ȴ�ʱ��(��)
    int     nPGCHWaitEx;            // ���ܳԺ��ȴ�ʱ��(׷��)(��)

    int     nReserved[8];
} MJ_START_DATA, *LPMJ_START_DATA;

typedef struct _tagMJ_PLAY_DATA
{
    CARDS_UNIT  PengCards[MJ_CHAIR_COUNT][MJ_MAX_PENG]; // ��������
    int         nPengCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  ChiCards[MJ_CHAIR_COUNT][MJ_MAX_CHI];   // �Գ�����
    int         nChiCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  MnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // ���ܳ�����
    int         nMnGangCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  AnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // ���ܳ�����
    int         nAnGangCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  PnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // ���ܳ�����
    int         nPnGangCount[MJ_CHAIR_COUNT];
    int         nOutCards[MJ_CHAIR_COUNT][MJ_MAX_OUT];  // �������
    int         nOutCount[MJ_CHAIR_COUNT];
    int         nHuaCards[MJ_CHAIR_COUNT][MJ_MAX_HUA];  // �����������
    int         nHuaCount[MJ_CHAIR_COUNT];

    int     nReserved[8];
} MJ_PLAY_DATA, *LPMJ_PLAY_DATA;

typedef struct _tagTABLE_INFO_MJ
{
    //From TABLE_INFO
    int     nTableNO;                           // ����
    int     nScoreMult;                         // ���ַŴ�
    int     nTotalChairs;                       // ������Ŀ
    DWORD   dwGameFlags;                        // ��Ϸ����ѡ��
    DWORD   dwUserConfig[MAX_CHAIRS_PER_TABLE]; // �û�����
    DWORD   dwRoomOption[MAX_CHAIRS_PER_TABLE]; // ��������
    BOOL    bTableEqual;                        // �Ƿ�������ͬ
    BOOL    bNeedDeposit;                       // �Ƿ���Ҫ����
    BOOL    bForbidDesert;                      // �Ƿ��ֹǿ��
    int     nDepositMult;                       // ���Ӽӱ�
    int     nDepositMin;                        // ��������
    int     nFeeRatio;                          // �����Ѱٷֱ�
    int     nMaxTrans;                          // �����Ӯ
    int     nCutRatio;                          // ���ܿ����ٷֱ�
    int     nDepositLogDB;                      // ��¼��־��С����
    int     nRoundCount;                        // �ڼ���
    int     nBoutCount;                         // �ڼ���
    int     nBanker;                            // ׯ��λ��
    int     nPartnerGroup[MAX_CHAIRS_PER_TABLE];// ������
    int     nDices[MAX_DICE_NUM];               // ���Ӵ�С
    DWORD   dwStatus;                           // ״̬
    int     nCurrentChair;                      // ��ǰ�λ��
    DWORD   dwCostTime[MAX_CHAIRS_PER_TABLE];   // �ܹ��ķ�ʱ��
    int     nAutoCount[MAX_CHAIRS_PER_TABLE];   // �Զ����Ƽ���
    int     nBreakCount[MAX_CHAIRS_PER_TABLE];  // �����������
    DWORD   dwUserStatus[MAX_CHAIRS_PER_TABLE]; // �û�״̬
    int     nBaseScore;                         // ���ֻ�������
    int     nBaseDeposit;                       // ���ֻ�������
    DWORD   dwWinFlags;                         // ��Ӯ��־
    DWORD   dwIntermitTime;                     // �ж�ʱ��
    DWORD   dwBoutFlags;                        // ������ر�־(���Ͼ�NextFlags��ֵ)
    DWORD   dwRoomConfigs;                      // ��������

    //Form TABLE_INFO_KD
    int     nTotalCards;                        // �Ƶ�����
    int     nTotalPacks;                        // ������
    int     nChairCards;                        // ÿ�˵�������
    int     nBottomCards;                       // ��������
    int     nLayoutNum;                         // �Ƶķ��󳤶�
    int     nLayoutMod;                         // ����ģ������
    int     nLayoutNumEx;                       // �Ƶķ��󳤶�(��չ)
    int     nThrowWait;                         // ���Ƶȴ�ʱ��(��)
    int     nMaxAutoThrow;                      // �����Զ����Ƶ�������
    int     nEntrustWait;                       // �йܵȴ�ʱ��(��)
    int     nMaxAuction;                        // �������з�
    int     nMinAuction;                        // ������С�з�
    int     nDefAuction;                        // Ĭ�Ͻз�
    int     nFirstCatch;                        // ��һ������
    int     nFirstThrow;                        // ��һ������
    int     nBottomIDs[MAX_BOTTOM_CARDS];       // ����ID
    int     nIDMatrix[MAX_CHAIRS_PER_TABLE][MAX_CARDS_PER_CHAIR];   // ��ID����
    int     nAuctionCount;                      // ��ׯ����
    AUCTION Auctions[MAX_AUCTION_COUNT];        // ��ׯ�����¼
    int     nObjectGains;                       // �зֱ��
    int     nCatchFrom;                         // ��ʼ����λ��
    int     nJokerNO;                           // ����λ��
    int     nJokerID;                           // ������ID
    int     nThrowCount;                        // ���Ƶڼ��ּ���

    int     nPGCHWait;          // ���ܳԺ��ȴ�ʱ��(��)
    int     nMaxBankerHold;     // ���������ׯ����
    DWORD   dwHuFlags[MJ_HU_FLAGS_ARYSIZE];     // ���������־����
    BOOL    bQuickCatch;        // ����ץ��
    int     nBankerHold;        // ������ׯ����
    int     nJokerID2;          // ������ID2
    int     nHeadTaken;         // ͷ�ϱ�ץ������
    int     nTailTaken;         // β�ϱ�ץ������
    int     nCurrentCatch;      // ��ǰץ��λ��
    DWORD   dwPGCHFlags[MJ_CHAIR_COUNT];    // ���ƺ����ܳԺ�״̬
    DWORD   dwGuoFlags[MJ_CHAIR_COUNT];     // ���ƺ��ܷ���Ʊ�־
    int     nGangID;            // ����ID
    int     nGangChair;         // ����λ��
    int     nCardChair;         // ������λ��
    int     nJokersThrown[MJ_CHAIR_COUNT]; // ����������
    int     nCaiPiaoChair;      // ��Ʈλ��
    int     nCaiPiaoCount;      // ��Ʈ����
    int     nGangKaiCount;      // �ܿ�����
    int     nPengFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT]; // ������������
    int     nChiFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT]; // �����˳Լ���
    int     nGangFeedCount[MJ_CHAIR_COUNT][MJ_CHAIR_COUNT]; // �����˸ܼ���
    CARDS_UNIT  PengCards[MJ_CHAIR_COUNT][MJ_MAX_PENG]; // ��������
    int         nPengCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  ChiCards[MJ_CHAIR_COUNT][MJ_MAX_CHI];   // �Գ�����
    int         nChiCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  MnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // ���ܳ�����
    int         nMnGangCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  AnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // ���ܳ�����
    int         nAnGangCount[MJ_CHAIR_COUNT];
    CARDS_UNIT  PnGangCards[MJ_CHAIR_COUNT][MJ_MAX_GANG];   // ���ܳ�����
    int         nPnGangCount[MJ_CHAIR_COUNT];
    int         nOutCards[MJ_CHAIR_COUNT][MJ_MAX_OUT];  // �������
    int         nOutCount[MJ_CHAIR_COUNT];
    int         nHuaCards[MJ_CHAIR_COUNT][MJ_MAX_HUA];  // �����������
    int         nHuaCount[MJ_CHAIR_COUNT];

    int         nResultDiff[MAX_CHAIR_COUNT][MAX_RESULT_COUNT];
    int         nTotalResult[MAX_CHAIR_COUNT];

    int         nReserved[4];
} TABLE_INFO_MJ, *LPTABLE_INFO_MJ;

typedef struct _tagGAME_WIN_MJ
{
    GAME_WIN    gamewin;
    int         nNewRound;                      // ��һ������һ�ֿ�ʼ

    int nMnGangs[MJ_CHAIR_COUNT];
    int nAnGangs[MJ_CHAIR_COUNT];
    int nPnGangs[MJ_CHAIR_COUNT];
    int nHuaCount[MJ_CHAIR_COUNT];

    int nResults[MJ_CHAIR_COUNT];   // ���ƽ��
    int nHuChairs[MJ_CHAIR_COUNT];  // ����Ƿ����
    int nLoseChair;     // �ų���߱�������λ��
    int nHuChair;       // ����λ��
    int nHuCard;        // ����ID
    int nBankerHold;    // �����Ǽ���ׯ
    int nNextBanker;    // ��һ��˭��ׯ
    int nChengBaoID;    // �а���ID
    int nHuCount;       // ��������

    int nTingChairs[MJ_CHAIR_COUNT];    // ����Ƿ�����
    int nTingCount;                     // ��������
    int nDetailCount;                   // ��ϸ����

    int nReserved[26];
} GAME_WIN_MJ, *LPGAME_WIN_MJ;

typedef struct _tagCATCH_CARD
{
    int nUserID;                // �û�ID
    int nRoomID;                // ����ID
    int nTableNO;               // ����
    int nChairNO;               // λ��
    BOOL bPassive;              // �Ƿ񱻶�
    SENDER_INFO sender_info;    // ��������Ϣ
    int nReserved[4];
} CATCH_CARD, *LPCATCH_CARD;

typedef struct _tagCARD_CAUGHT
{
    int nChairNO;               // λ��
    int nCardID;                // ��ID
    int nCardNO;                // ��λ��
    DWORD dwFlags;              // ��־
    int nReserved[4];
} CARD_CAUGHT, *LPCARD_CAUGHT;

typedef struct _tagGUO_CARD
{
    int nUserID;                // �û�ID
    int nRoomID;                // ����ID
    int nTableNO;               // ����
    int nChairNO;               // λ��
    int nCardChair;             // ������λ��
    int nCardID;                // ��ID
    int nReserved[4];
} GUO_CARD, *LPGUO_CARD;

typedef struct _tagCOMB_CARD
{
    int nUserID;                // �û�ID
    int nRoomID;                // ����ID
    int nTableNO;               // ����
    int nChairNO;               // λ��
    int nCardChair;             // ������������λ��
    int nCardID;                // ��������ID
    int nBaseIDs[MJ_UNIT_LEN - 1];// �������������
    DWORD dwFlags;              // ��־λ
    int nCardGot;               // �ܵ�����
    int nCardNO;                // �ܵ�����λ��
    int nReserved[4];
} COMB_CARD, *LPCOMB_CARD;

typedef COMB_CARD PREPENG_CARD;
typedef LPCOMB_CARD LPPREPENG_CARD;

typedef COMB_CARD CARD_PREPENG;
typedef LPCOMB_CARD LPCARD_PREPENG;

typedef COMB_CARD PREGANG_CARD;
typedef LPCOMB_CARD LPPREGANG_CARD;

typedef COMB_CARD CARD_PREGANG;
typedef LPCOMB_CARD LPCARD_PREGANG;

typedef COMB_CARD PRECHI_CARD;
typedef LPCOMB_CARD LPPRECHI_CARD;

typedef COMB_CARD CARD_PRECHI;
typedef LPCOMB_CARD LPCARD_PRECHI;

typedef COMB_CARD PENG_CARD;
typedef LPCOMB_CARD LPPENG_CARD;

typedef COMB_CARD CARD_PENG;
typedef LPCOMB_CARD LPCARD_PENG;

typedef COMB_CARD CHI_CARD;
typedef LPCOMB_CARD LPCHI_CARD;

typedef COMB_CARD CARD_CHI;
typedef LPCOMB_CARD LPCARD_CHI;

typedef COMB_CARD GANG_CARD;
typedef LPCOMB_CARD LPGANG_CARD;

typedef COMB_CARD CARD_GANG;
typedef LPCOMB_CARD LPCARD_GANG;

typedef struct _tagPREGANG_OK
{
    int nChairNO;               // λ��
    int nCardChair;             // ������������λ��
    int nCardID;                // ��������ID
    DWORD dwFlags;              // ��־λ
    DWORD dwResults[MJ_CHAIR_COUNT];
    int nReserved[4];
} PREGANG_OK, *LPPREGANG_OK;

typedef struct _tagHUA_CARD
{
    int nUserID;                // �û�ID
    int nRoomID;                // ����ID
    int nTableNO;               // ����
    int nChairNO;               // λ��
    int nCardID;                // ����ID
    int nCardGot;               // �ܵ�����
    int nCardNO;                // �ܵ�����λ��
    int nReserved[4];
} HUA_CARD, *LPHUA_CARD;

typedef HUA_CARD CARD_HUA;
typedef LPHUA_CARD LPCARD_HUA;

typedef struct _tagHU_CARD
{
    int nUserID;                // �û�ID
    int nRoomID;                // ����ID
    int nTableNO;               // ����
    int nChairNO;               // λ��
    int nCardChair;             // ��������λ��
    int nCardID;                // ����ID
    DWORD dwFlags;              // ��־λ
    DWORD dwSubFlags;           // ������־λ
    int nReserved[4];
} HU_CARD, *LPHU_CARD;

typedef struct _tagGAME_ENTER_INFO
{
    ENTER_INFO     ei;
    int            nResultDiff[MAX_CHAIR_COUNT][MAX_RESULT_COUNT];
    int            nTotalResult[MAX_CHAIR_COUNT];
    int            nReserve[4];
} GAME_ENTER_INFO, *LPGAME_ENTER_INFO;

//�¼�
typedef struct _tagGAME_EVENT
{
    DWORD dwEventTime;                //�¼�ʱ��
    DWORD dwEventIndex;               //�¼����
    DWORD dwOperateType;              //��������
    int   data[GAME_MSG_DATA_LENGTH]; //���ݶ�
} GAME_EVENT, *LPGAME_EVENT;

typedef struct _tagGAME_MSG
{
    int   nRoomID;
    int   nUserID;                    // �û�ID            4
    int   nMsgID;                     // ��Ϣ��            4
    int   nVerifyKey;                 // ��֤��            4
    int   nDatalen;                   // ���ݳ���          4
} GAME_MSG, *LPGAME_MSG;

typedef struct _tagMERGE_THROWCARDS
{
    int nUserID;                            // �û�ID
    int nRoomID;                            // ����ID
    int nTableNO;                           // ����
    int nChairNO;                           // λ��
    BOOL bPassive;                          // �Ƿ񱻶�
    SENDER_INFO sender_info;                 // ��������Ϣ
    DWORD dwCardsType;                      // ����
    int nReserved[4];
    int nCardsCount;                        // ������
    CARD_CAUGHT card_caught;                 // ץ�Ƶ�������Ϣ
    int nCardIDs[MAX_CARDS_PER_CHAIR];      // �������(ID)
} MERGE_THROWCARDS, *LPMERGE_THROWCARDS;

typedef struct _tagCARD_TING_DETAIL
{
    DWORD   dwflags;
    int     nChairNO;
    int     nThrowCardsTing[MJ_GF_14_HANDCARDS];
    BYTE    nThrowCardsTingLays[MJ_GF_14_HANDCARDS][MAX_CARDS_LAYOUT_NUM];  // ����ĳ����֮����������
    BYTE    nThrowCardsTingFan[MJ_GF_14_HANDCARDS][MAX_CARDS_LAYOUT_NUM];  //����ĳ����֮�����ķ���
    BYTE    nThrowCardsTingRemain[MJ_GF_14_HANDCARDS][MAX_CARDS_LAYOUT_NUM];//����ʣ�������
    int     nReserved[4];
} CARD_TING_DETAIL, *LPCARD_TING_DETAIL;

typedef struct _tagCARD_TING_DETAIL_16
{
    DWORD   dwflags;
    int     nChairNO;
    int     nThrowCardsTing[MJ_GF_17_HANDCARDS];
    BYTE    nThrowCardsTingLays[MJ_GF_17_HANDCARDS][MAX_CARDS_LAYOUT_NUM];  // ����ĳ����֮����������
    BYTE    nThrowCardsTingFan[MJ_GF_17_HANDCARDS][MAX_CARDS_LAYOUT_NUM];  //����ĳ����֮�����ķ���
    BYTE    nThrowCardsTingRemain[MJ_GF_17_HANDCARDS][MAX_CARDS_LAYOUT_NUM];//����ʣ�������
    int     nReserved[4];
} CARD_TING_DETAIL_16, *LPCARD_TING_DETAIL_16;

typedef struct _tagMERGE_CARDSTHROW
{
    int nUserID;                                    // �û�ID
    int nChairNO;                                   // λ��
    int nNextChair;                                 // ��һ��
    BOOL bNextFirst;                                // ��һ���Ƿ��һ�ֳ���
    BOOL bNextPass;                                 // ��һ���Ƿ��Զ�����
    int nRemains;                                   // ʣ�¼���
    DWORD dwFlags[MAX_CHAIR_COUNT];                 // ��־
    DWORD dwCardsType;                              // ����
    int nThrowCount;                                // ���Ƶڼ��ּ���
    int nReserved[4];
    int nCardsCount;                                // ������
    CARD_CAUGHT card_caught;                        // ץ�Ƶ�������Ϣ
    int nCardIDs[MAX_CARDS_PER_CHAIR];              // �������(ID)
} MERGE_CARDSTHROW, *LPMERGE_CARDSTHROW;
