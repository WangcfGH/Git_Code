#pragma once

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;

#define CHARGE_CARD   101001   // ���ܳ�ֵ
#define CHARGE_APP    101002   // APP�ٷ���ֵ

#define REWARD_FIRST  102001   // �״ν���
#define REWARD_COMMON 102002   // ͨ�ý���

#define RETURN_PLAY   103001   // ��Ϸ����

#define GRANT_IN      104001   // �û�����

#define USE_PLAY      205001   // ��Ϸ����
#define USE_DK        205002   // ����������

#define GRANT_OUT     206001   // �û�����

typedef struct _tagHappycoin_
{
    CString strItemAddr;        // ���ֱ�����
    CString strItemAddrEx;      // ��Ӫ��ϵ����(������)
    CString strAppCode;         // �ڻ��ֱ���ϵ���������Ϸ��д
    CString strIP;
    CString strAwardGuid;       // �������Ψһ��ʶ
    CString strKey;             // ����У����Կ
    int nItemID;                // ���ֱ���ƷID
} HappyCoinConfig, *LPHappyCoinConfig;

class CItemSysHttpTool
{
public:
    static void GetHappyCoidConfig(LPHappyCoinConfig config);
    static int GrantUserVirtualItemBase(int nUserID, int nCount, BOOL bFirst = FALSE);

    static CString AES2MD5(CString& strSource, CString& key);
    static CString GetUniqueID(int nUserID);
    static BOOL IsEnable();

    static CCritSec g_lock;
    static CString strIniFileName;
};
