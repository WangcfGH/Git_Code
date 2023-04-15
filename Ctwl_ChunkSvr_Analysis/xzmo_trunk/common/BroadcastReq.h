#pragma once

//////////////////////////////////////
#define     GR_BROADCAST                (GAME_REQ_INDIVIDUAL + 5000)  // �㲥��Ϣ
#define     GR_BROADCAST_CONFIG         (GAME_REQ_INDIVIDUAL + 5001)  // ��ȡ���������
#define     GR_BROADCAST_FROM_GAMESVR   (GAME_REQ_INDIVIDUAL + 5002)  // ����Ϸ�������Ĺ㲥��Ϣ

#define     MAX_MSG_LEN     256

enum enMSG_TYPE
{
    enMsgTypeNormal = 0,        //��ͨ��Ϣ
    enMsgTypeRollItem,          //����
    enMsgTypeLottery,           //ת�̳齱
    enMsgTypeImportant,         //������Ϣ, ���ȼ����
    enMsgTypeNotice,            //��վ����, ��վ��ȡ�Ĺ���
    enMsgTypeLocal,             //������Ϣ, ���ع���, ������Ҳ�ܲ���
    enMsgTypeTask,              //����
    enMsgTypeGame,              //��Ϸ
    enMsgTypeArena,             //����
    enMsgTypeExchange,          //�һ�
    enMsgTypeEmail,             //�ʼ�
    enMsgTypeChat,              //����

    enMsgTypeCustom = 100,      //�Զ�����Ϣ����ڸ�ֵ֮��
};

//���������
typedef struct _tagBROADCAST_CONFIG
{
    BOOL        bEnable;                    //�Ƿ�������ƹ���
    int         nMoveSpeed;                 //�����ٶ�
    TCHAR       szNoticeUrl[MAX_PATH];      //��̨������ַ

    int         nRunType;                   //��������, 0���ҵ���, 1��������
    int         nReserved[3];
} BROADCAST_CONFIG, *LPBROADCAST_CONFIG;

typedef struct _tagMESSAGE_INFO
{
    enMSG_TYPE  enMsgType;              //��Ϣ����
    TCHAR       szMsg[MAX_MSG_LEN];     //����

    int         nReserved[4];
} MESSAGE_INFO, *LPMESSAGE_INFO;

//������Ϣ��Ϣ
typedef struct _tagBROADCAST_MSG
{
    int         nDelaySec;              //�ӳ�N��㲥, �������

    MESSAGE_INFO MessageInfo;

    int         nRoadID;                //�ܵ�ID
    int         nRepeatTimes;           //�����ظ�����, ��һ�γ���
    int         nInterval;              //�ظ����(s)

    int         nReserved[4];

} BROADCAST_MSG, *LPBROADCAST_MSG;
