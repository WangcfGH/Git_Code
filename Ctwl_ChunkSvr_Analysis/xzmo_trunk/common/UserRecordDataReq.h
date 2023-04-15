#pragma once

#pragma warning(once:4996)

#define GR_DATARECORD_LOG_USERBEHAVIOR  (GAME_REQ_INDIVIDUAL+4120)      // ����13.9 �û�������

#define GR_DATARECORD_APP_UPLOAD        (GAME_REQ_INDIVIDUAL+4102)      // �ͻ����ϴ�����
#define GR_DATARECORD_NEW_APP_UPLOAD    (GAME_REQ_INDIVIDUAL+4104)      // �ͻ����ϴ����ݵ���Э��
#define GR_DATARECORD_LOG_FUNC_USED     (GAME_REQ_INDIVIDUAL+4110)      // �û�����ʹ�����ϴ�����

#define DR_TIMESTR_SIZE         20
#define DR_MAX_VERSION_SIZE     16

typedef struct _tagUserBehavior
{
    int     nUserID;
    int     nBehaviorID;
    TCHAR   szGameVersion[DR_MAX_VERSION_SIZE];
    TCHAR   szPlatformVersion[DR_MAX_VERSION_SIZE];
    TCHAR   szChannelID[DR_MAX_VERSION_SIZE];
    //TCHAR   szRecordTime[DR_TIMESTR_SIZE];
} USERBEHAVIOR, *LPUSERBEHAVIOR;