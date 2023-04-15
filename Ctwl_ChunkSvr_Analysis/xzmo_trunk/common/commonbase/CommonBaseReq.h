#pragma once

#define  GR_MODIFY_TABLEANDCHAIR    (GAME_REQ_BASE_EX + 11001)  // �����dxxw������Ϸ�����Ӻź����ӺŲ�һ���޸���

#define     GR_THROW_PRO            (GAME_REQ_INDIVIDUAL + 5)       // ����ӵ�����Ϣ
#define     GR_SEND_LBSINFO         (GAME_REQ_INDIVIDUAL + 6)       // ��Ϸ��׼��ǰ����ϴ���λ��Ϣ
#define     GR_PROMPT_PLAYER        (GAME_REQ_INDIVIDUAL + 7) // �����������Ϣ
#define     GR_BUY_GOOD_LUCK_PROP   (GAME_REQ_INDIVIDUAL + 100) // ��ҹ��������;
#define     GR_SHOW_GOOD_LUCK_PROP  (GAME_REQ_INDIVIDUAL + 101) // ���������չʾ������;
#define     GR_GOOD_LUCK_PROP_STATE (GAME_REQ_INDIVIDUAL + 102) // �·���Ҹ��Եĺ���������;
#define     GR_ROOM_PROMPT_LINE     (GAME_REQ_BASE_EX + 40001)
#define     DEFAULT_PROMPT_LIME     -1

//���ֱҲ�����,0Ϊ��������;
enum HAPPYCOIN_DEDUCT_CODE
{
    GOOD_LUCK_DEDUCT = 1,
};

enum GOOD_LUCK_RESULT_TYPE
{
    GOOD_LUCK_RESULT_FREE = 1, //����ɹ�����ѣ�;
    GOOD_LUCK_RESULT_PAY,       //����ɹ������ѣ�;
    GOOD_LUCK_RESULT_ROBBED,    //����ʧ�ܣ�������;
    GOOD_LUCK_RESULT_HAPPYCOIN_NOT_ENOUGH,  //����ʧ�ܣ����ֱҲ��㣩;
    GOOD_LUCK_RESULT_RETURN_FREE,   //��������Ѵ�����;
    GOOD_LUCK_RESULT_ROOM_CHARGE_TOO_MORE,  //�����ֱҿ۳����㷿�ѣ�;
};

enum PROP_ID
{
    PROP_BEGIN = 0,
    PROP_CHICKEN,
    PROP_EGG,
    PROP_MEDAL,
    PROP_SLIPPER,
    PROP_FLOWER,
    PROP_END
};

typedef struct _tagSENDLBSINFO
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    TCHAR szLBSInfo[MAX_YQW_LBS_LEN];               // LBS��γ��
    TCHAR szLbsArea[MAX_YQW_AREA_LEN];              // "�㽭ʡ�����б���������·"[������ض�]
    int nReserved[4];
} SENDLBSINFO, *LPSENDLBSINFO;

typedef struct _tagTHROWPROP
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    int nDstChairNO;
    int nPropID;
} THROWPROP, *LPTHROWPROP;

struct REQ_REPLAY
{
    int  nUserID;                           // �û�ID
    int  nRoomID;                           // ����ID
    int  nTableNO;                          // ����
    int  nChairNO;                          // λ��
    int  nReserved[4];
};



typedef struct _tagSHOW_GOOD_LUCK_PROP
{
    int nUserID;
} SHOW_GOOD_LUCK_PROP, *LPSHOW_GOOD_LUCK_PROP;

typedef struct _tagGOOD_LUCK_PROP_STATE
{
    int nUserID;
    int nFreeCount;
    int nAmount;    //�۸�;
    int nNoticeType;    //֪ͨ���ͣ�1�ǽ���,Ŀǰֻ�н�����Ҫ����;
    int nGoodLuckUserID;    //�����˺����������ID;
} GOOD_LUCK_PROP_STATE, *LPGOOD_LUCK_PROP_STATE;

typedef struct _tagPROMPTPLAYER
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    int nPromptUserID;
    int  nReserved[4];
} PROMPTPLAYER, *LPPROMPTPLAYER;

typedef struct  _tagMODIFY_TABLEANDCHAIR
{
    int     nUserID;                               // �û�ID
    int     nRoomID;                               // ����ID
    int     nTableNO;                              // ����
    int     nChairNO;                              // λ��
    int     nReserved[8];
} MODIFY_TABLEANDCHAIR, *LPMODIFY_TABLEANDCHAIR;

typedef struct _tagROOM_PROMPT_LINE
{
    int nUserID;                // �û�ID
    int nRoomID;                // ����ID
    int nTableNO;               // ����
    int nChairNO;               // λ��
    int nRoomPromptLine;        // ������ʾ��
    int nReserved[4];
} ROOM_PROMPT_LINE, *LPROOM_PROMPT_LINE;