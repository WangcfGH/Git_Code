#pragma once

#define GR_EXPLAYERINFO_QUERY               (GAME_REQ_INDIVIDUAL + 7111)    //��ѯ���������Ϣ
#define GR_EXPLAYERINFO_CHANGE_PARAM        (GAME_REQ_INDIVIDUAL + 7112)    //�ı���������Ϣ

#define TOTAL_CHAIRS 4

enum RoomType
{
    EXPLAEYER_COUT_XZ = 1,          // Ѫս
    EXPLAEYER_COUT_XL               // Ѫ��
};

typedef struct _tagExPlayerInfoParamQuery
{
    int nRoomID;                    //����ID
    int nTableNo;                   //����
    int nUserID[TOTAL_CHAIRS];      // userid

    int nReserved[4];            // �����ֶ�
} EXPLAYERINFOPARAMQUERY, *LPEXPLAYERINFOPARAMQUERY;

typedef struct _tagExPlayerInfoParamQueryRsp
{
    int nRoomID;                    //����ID
    int nTableNo;                   //����
    int nUserID[TOTAL_CHAIRS];      // userid
    int nXZCount[TOTAL_CHAIRS];     // Ѫս�Ծ�
    int nXLCount[TOTAL_CHAIRS];     // Ѫ���Ծ�
    int nPerDayCount[TOTAL_CHAIRS]; // ���նԾ�

    int nReserved[4];            // �����ֶ�
} EXPLAYERINFOPARAMQUERYRSP, *LPEXPLAYERINFOPARAMQUERYRSP;

typedef struct _tagExPlayerInfoParamChange
{
    int nUserID;                 // userid
    BOOL bIsHandPhone;           // �Ƿ��ֻ����û�
    int nType;                   // ��������
    int nValue;                  // ������ֵ
    int nRoomID;                // ����ID
    int nTableNo;               // ����
    int nChairNo;               // λ�ú�

    int nReserved[4];            // �����ֶ�
} EXPLAYERINFOPARAMCHANGE, *LPEXPLAYERINFOPARAMCHANGE;

typedef struct _tagExPlayerInfoParamChangeRsp
{
    int nUserID;                // userid
    int nRoomID;                // ����ID
    int nTableNo;               // ����
    int nChairNo;               // λ�ú�
    int nXZCount;               // Ѫս�Ծ�
    int nXLCount;               // Ѫ���Ծ�
    int nPerDayCount;           // ���նԾ�

    int nReserved[4];            // �����ֶ�
} EXPLAYERINFOPARAMCHANGERSP, *LPEXPLAYERINFOPARAMCHANGERSP;

typedef struct _tagExPlayerInfoPerAdd
{
    int nUserId;
    int nAddCount;
    int type;
} EXPLAYERINFOPERADD, *LPEXPLAYERINFOPERADD;

typedef struct _tagExPlayerInfoPer
{
    int nUserId;
    int nXueZhanCount;
    int nXueLiuCount;
} EXPLAYERINFOPER, *LPEXPLAYERINFOPER;
