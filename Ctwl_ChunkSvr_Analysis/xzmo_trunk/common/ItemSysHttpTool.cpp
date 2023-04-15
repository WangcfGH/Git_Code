#include "StdAfx.h"
#include "json.h"

//库里已有函数，为了支持assistsvr使用直接拷贝出来，避免各种链接库文件
BOOL Aes128EncryptCbcEx(const BYTE* lpKey, const BYTE* lpInData, UINT uiInLength, BYTE* lpOutData, UINT& uiOutLength)
{
    UINT uiAlignLength = uiInLength + 16 - uiInLength % 16;
    if (lpOutData == NULL)
    {
        uiOutLength = uiAlignLength;
        return FALSE;
    }
    else if (uiOutLength < uiAlignLength)
    {
        return FALSE;
    }
    //padding
    BYTE* pAlignData = new BYTE[uiAlignLength];
    memcpy(pAlignData, lpInData, uiInLength);
    memset(pAlignData + uiInLength, uiAlignLength - uiInLength, uiAlignLength - uiInLength);
    //encrypt
    CRijndael aes;
    aes.set_key(lpKey, 128);

    BYTE iv[16];
    memcpy(iv, lpKey, 16);

    for (UINT i = 0; i < uiAlignLength; i += 16)
    {
        BYTE* p = pAlignData + i;
        BYTE* q = lpOutData + i;

        for (int j = 0; j < 16; j++)
        {
            p[j] ^= iv[j];
        }

        aes.encrypt(p, q);
        memcpy(iv, q, 16);
    }

    delete[] pAlignData;
    uiOutLength = uiAlignLength;
    return TRUE;
}

void CItemSysHttpTool::GetHappyCoidConfig(LPHappyCoinConfig config)
{
#ifdef _DEBUG
    config->nItemID = 21617;
    config->strItemAddr = "http://happycoinapi.ct108.org:1505";
    config->strItemAddrEx = "http://awardsysapi.uc108.org:1505";
#else
    config->nItemID = 21867;
    config->strItemAddr = "http://happycoinapi.tcy365.net";
    config->strItemAddrEx = "http://awardsysapi.uc108.net";
#endif

#ifdef _RS125
    config->nItemID = 21617;
    config->strItemAddr = "http://happycoinapi.ct108.org:1505";
    config->strItemAddrEx = "http://awardsysapi.uc108.org:1505";
#endif

    // appcode 和 key 是后台体系生成的一对
    // awardguid和itemid 是奖励体系生成的
    // 剩下的网址从本地配置读取
    char szBuffer[4096] = {0};
    //新增code和key的配置
    ::GetPrivateProfileString("RoomCard", "appcode", config->strAppCode, szBuffer, sizeof(szBuffer), strIniFileName);
    config->strAppCode.Format("%s", szBuffer);
    ZeroMemory(szBuffer, sizeof(szBuffer));
    ::GetPrivateProfileString("RoomCard", "appkey", config->strKey, szBuffer, sizeof(szBuffer), strIniFileName);
    config->strKey.Format("%s", szBuffer);
    ZeroMemory(szBuffer, sizeof(szBuffer));

    ::GetPrivateProfileString("RoomCard", "addr", config->strItemAddr, szBuffer, sizeof(szBuffer), strIniFileName);
    config->strItemAddr.Format("%s", szBuffer);
    ZeroMemory(szBuffer, sizeof(szBuffer));
    ::GetPrivateProfileString("RoomCard", "addrex", config->strItemAddrEx, szBuffer, sizeof(szBuffer), strIniFileName);
    config->strItemAddrEx.Format("%s", szBuffer);
    ZeroMemory(szBuffer, sizeof(szBuffer));
    config->nItemID = ::GetPrivateProfileInt("RoomCard", "itemid", config->nItemID, strIniFileName);

    ZeroMemory(szBuffer, sizeof(szBuffer));
    ::GetPrivateProfileString("RoomCard", "awardguid", config->strAwardGuid, szBuffer, sizeof(szBuffer), strIniFileName);
    config->strAwardGuid.Format("%s", szBuffer);
}

int CItemSysHttpTool::GrantUserVirtualItemBase(int nUserID, int nCount, BOOL bFirst)
{
    if (!IsEnable())
    {
        return 0;
    }
    HappyCoinConfig config;
    GetHappyCoidConfig(&config);
    CAutoLock lock(&g_lock);
    CString strUniqueID = GetUniqueID(nUserID);
    CString signString;
    signString.Format("AppCode=%s&OperateVersion=%s&UserId=%d&UserIp=%s",
        config.strAppCode, strUniqueID, nUserID, CR_LOCAL_IP);
    CString strSign = AES2MD5(signString, config.strKey);

    CHttpClient http;
    http.addHeaders("Authorization", "Basic sign=" + strSign);
    http.addHeaders("AwardSysApi-Version", "2");
    http.addHeaders("content-type", "application/json");

    Json::Value jstring;
    jstring["AppCode"] = config.strAppCode.GetBuffer(config.strAppCode.GetLength() + 1);
    jstring["AwardGuid"] = config.strAwardGuid.GetBuffer(config.strAwardGuid.GetLength() + 1);
    jstring["OperateVersion"] = (LPCTSTR)strUniqueID;
    jstring["UserId"] = nUserID;
    jstring["UserIp"] = CR_LOCAL_IP;
    jstring["NewItemID"] = config.nItemID;
    jstring["Number"] = nCount;
    jstring["ExtendJson"]["gameid"] = GAME_ID;
    if (bFirst)
    {
        jstring["ExtendJson"]["HappyCoinOperateCode"] = REWARD_FIRST;
    }
    else
    {
        jstring["ExtendJson"]["HappyCoinOperateCode"] = REWARD_COMMON;
    }

    http.setBodyJson(jstring.toStyledString().c_str());
    CString strReq;
    strReq.Format("%s/api//activity//doaward", config.strItemAddrEx);
    CString strRet = http.doPost(strReq);
    strRet.TrimRight();
    UwlLogFile("GrantUserVirtualItemBase url:%s\nparam:%s\nret:%s", strReq, jstring.toStyledString().c_str(), strRet);
    int nStatusCode = -1;
    Json::Reader reader;
    Json::Value value;
    int nRetLen = strRet.GetLength();
    if (reader.parse(strRet.GetBuffer(nRetLen + 1), value, false))
    {
        if (!value.isNull())
        {
            Json::Value s = value["StatusCode"];
            if (!s.isNull())
            {
                nStatusCode = s.asInt();
            }
        }
    }
    return nStatusCode;
}

CString CItemSysHttpTool::AES2MD5(CString& strSource, CString& strkey)
{
    LPCTSTR szSignString = strSource;
    LPCTSTR szKey = strkey;
    UINT uiSrcLen = strlen(szSignString);

    UINT uiAesLen = 0;
    Aes128EncryptCbcEx((BYTE*)szKey, (BYTE*)szSignString, uiSrcLen, NULL, uiAesLen);

    CByteArray baAes;
    baAes.SetSize(uiAesLen);
    Aes128EncryptCbcEx((BYTE*)szKey, (BYTE*)szSignString, uiSrcLen, baAes.GetData(), uiAesLen);

    UINT uiB64Len = (uiAesLen + 2) / 3 * 4;

    CString sBase64;
    CBase64Coding b64;
    b64.Encode(baAes, sBase64);
    sBase64.Replace(_T("\r\n"), _T(""));
    sBase64 = sBase64.Left(uiB64Len);
    LPCTSTR szBase64 = sBase64;
    return MD5String((char*)szBase64);
}

CString CItemSysHttpTool::GetUniqueID(int nUserID)
{
    SYSTEMTIME st;
    GetLocalTime(&st);

    USES_CONVERSION;
    GUID Guid;
    ::CoCreateGuid(&Guid);
    OLECHAR szClassID[39];
    int cchGuid = ::StringFromGUID2(Guid, szClassID, sizeof(szClassID));
    CString sGuid = OLE2CT(szClassID);
    sGuid.Replace(_T("{"), _T(""));
    sGuid.Replace(_T("}"), _T(""));
    sGuid.Replace(_T("-"), _T(""));

    CString strRet;
    strRet.Format(_T("%s%04d%02d%02d"), sGuid, st.wYear, st.wMonth, st.wDay);
    return strRet;
}

BOOL CItemSysHttpTool::IsEnable()
{
    return ::GetPrivateProfileInt("RoomCard", "enable", 1, strIniFileName);
}

CCritSec CItemSysHttpTool::g_lock;

CString CItemSysHttpTool::strIniFileName = "";
