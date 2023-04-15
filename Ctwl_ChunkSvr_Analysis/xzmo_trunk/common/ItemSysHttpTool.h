#pragma once

#import "XYSoapClient.dll"
using namespace XYSOAPCLIENTLib;

#define CHARGE_CARD   101001   // 卡密充值
#define CHARGE_APP    101002   // APP官方充值

#define REWARD_FIRST  102001   // 首次奖励
#define REWARD_COMMON 102002   // 通用奖励

#define RETURN_PLAY   103001   // 游戏返还

#define GRANT_IN      104001   // 用户赠入

#define USE_PLAY      205001   // 游戏消耗
#define USE_DK        205002   // 代开房消耗

#define GRANT_OUT     206001   // 用户赠出

typedef struct _tagHappycoin_
{
    CString strItemAddr;        // 欢乐币链接
    CString strItemAddrEx;      // 运营体系链接(赠送用)
    CString strAppCode;         // 在欢乐币体系里申请的游戏缩写
    CString strIP;
    CString strAwardGuid;       // 发奖活动的唯一标识
    CString strKey;             // 发奖校验密钥
    int nItemID;                // 欢乐币物品ID
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
