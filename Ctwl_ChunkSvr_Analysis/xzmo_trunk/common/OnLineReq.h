#pragma once

// ��Ϣ��;
#define	GR_ON_LING_DATA				(GAME_REQ_INDIVIDUAL + 3300)    // ���߻����;
#define	GR_ON_LING_GET_REWARDS		(GAME_REQ_INDIVIDUAL + 3301)    // ��ȡ���߽���;
#define GR_ON_LINE_SOAP_REWARDS     (GAME_REQ_INDIVIDUAL + 3302)    // soap��ȡ������;

enum ON_LINE_RESULT
{
	SUCCESS = 0,		//�ɹ�;
	FAIL_CONDITIONS,	//δ��������;
	FAIL_LIMIT,			//�Ѵ�����;
	FAIL_TASK			//������ȡʧ��;
};

typedef struct _tagONLINE_CONDITION
{
	int	nUserID;                // ���ID;
	int nValue;                 // ��������ֵ;
}ONLINE_CONDITION, *LPONLINE_CONDITION;