#include   "stdafx.h"

#ifdef  _DEBUG
    #undef  THIS_FILE
    static  char   THIS_FILE[] = __FILE__;
    #define new   DEBUG_NEW
#endif

CCritSec m_cshttpAnsiLock;
inline char* ANSI_to_UTF8(const char* szAnsi, int& nUTF8Len)
{
    if (szAnsi == NULL)
    {
        return NULL;
    }

    _bstr_t   bstrTmp(szAnsi);
    int nLen = ::WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)bstrTmp, -1, NULL, 0, NULL, NULL);
    static char  pUTF8[128];//    * pUTF8 = new char[nLen+1] ;//直接写个128吧 不会超过的
    //static 重入 可能会有问题 修改为new 暂不考虑内存碎片问题
    //char  *pUTF8 = new char[nLen+1] ;
    ZeroMemory(pUTF8, 128 * sizeof(char));
    ::WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)bstrTmp, -1, pUTF8, nLen, NULL, NULL);
    nUTF8Len = nLen;
    return pUTF8;
}

BOOL ConvertStringToURLCoding(CString& strDest, const char* strAnsi)
{
    CAutoLock lock(&m_cshttpAnsiLock);
    int iLength = 0;
    char* strUTF8 = ANSI_to_UTF8(strAnsi, iLength);
    strDest.Empty();
    CString strTemp;
    int i = 0;
    while (i < iLength)
    {
        if ((unsigned)strUTF8[i] <= (unsigned char)0x7f)
        {
            //字母和数字不转换

            if ((strUTF8[i] >= '0' && strUTF8[i] <= '9') ||
                (strUTF8[i] >= 'A' && strUTF8[i] <= 'Z') ||
                (strUTF8[i] >= 'a' && strUTF8[i] <= 'z'))
            {
                strDest += (char)strUTF8[i];
            }

            else if (strUTF8[i] == ' ')    //空格转换成+号
            {
                strDest += '+';
            }
            else if (strUTF8[i] == 0)
            {
                break;
            }
            else
            {
                strTemp.Format("%%%02X", (unsigned char)strUTF8[i]);    //其他标点符号
                strDest += strTemp;
            }
            i++;
        }
        else
        {
            //汉字或者其他的uft8文字，每3个字节一转
            if (strUTF8[i] != 0)//我草 这里有问题
            {
                strTemp.Format("%%%02X", (unsigned char)strUTF8[i]);
                strDest += strTemp;
                i += 1;
            }

            if (strUTF8[i] != 0)
            {
                strTemp.Format("%%%02X", (unsigned char)strUTF8[i]);
                strDest += strTemp;
                i += 1;
            }

            if (strUTF8[i] != 0)
            {
                strTemp.Format("%%%02X", (unsigned char)strUTF8[i]);
                strDest += strTemp;
                i += 1;
            }
        }
    }

    if (i == 0)
    {
        return FALSE;
    }
    return TRUE;
}

TCHAR* ipDword2Str(DWORD dwIPAddr)
{
    static TCHAR szIP[MAX_IP_CHAR_LEN];
    memset(szIP, 0, sizeof(szIP));
    WORD hiWord = HIWORD(dwIPAddr);
    WORD loWord = LOWORD(dwIPAddr);
    BYTE nf1 = HIBYTE(hiWord);
    BYTE nf2 = LOBYTE(hiWord);
    BYTE nf3 = HIBYTE(loWord);
    BYTE nf4 = LOBYTE(loWord);

    sprintf_s(szIP, "%d.%d.%d.%d", nf4, nf3, nf2, nf1);
    return szIP;
}

CString  MD5String(LPTSTR lpszContent)
{
    CString sRet;

    MD5_CTX mdContext;
    UwlMD5Init(&mdContext);
    UwlMD5Update(&mdContext, (unsigned char*)(LPTSTR)lpszContent, lstrlen(lpszContent));
    UwlMD5Final(&mdContext);

    UwlConvertHexToStr(mdContext.digest, 16, sRet);

    return sRet;

}

CHttpClient::CHttpClient()
{
    m_dwRecvTimeOut = 15000;
}

CHttpClient::~CHttpClient()
{
}

CString   CHttpClient::doGet(CString href)
{
    /*CString   httpsource="";
    CInternetSession   session1(NULL,0);
    //session1.SetOption(INTERNET_OPTION_RECEIVE_TIMEOUT,m_dwRecvTimeOut);
    CHttpFile*   pHTTPFile=NULL;
    try
    {   //不存缓存
        pHTTPFile=(CHttpFile*)session1.OpenURL(href,1,INTERNET_FLAG_TRANSFER_ASCII|INTERNET_FLAG_DONT_CACHE);
    //session1.
    }
    catch(...)
    {
        pHTTPFile=NULL;
    }

    try
    {
        if(pHTTPFile)
        {
            CString   text;
            for(int   i=0;pHTTPFile->ReadString(text);i++)
            {
                httpsource=httpsource+text;
            }
            pHTTPFile->Close();
            delete   pHTTPFile;
        }
        else
        {

        }
    }
    catch (...)
    {

    }

    return   httpsource;   */
    CString   httpsource = "";
    CInternetSession   session1;
    CHttpConnection*   conn1 = NULL;
    CHttpFile*   pFile   =   NULL;
    CString   strServerName;
    CString   strObject;
    INTERNET_PORT   nPort;
    DWORD   dwServiceType;
    AfxParseURL((LPCTSTR)href, dwServiceType,   strServerName,   strObject,   nPort);
    DWORD   retcode;
    char*   outBuff   =   CONTENT.GetBuffer(1000);
    try
    {
        conn1 = session1.GetHttpConnection(strServerName, nPort);
        pFile = conn1->OpenRequest(CHttpConnection::HTTP_VERB_GET, strObject, NULL, 1, NULL, "HTTP/1.1", INTERNET_FLAG_EXISTING_CONNECT | INTERNET_FLAG_NO_AUTO_REDIRECT);
        pFile->AddRequestHeaders("Content-Type:   application/x-www-form-urlencoded");
        pFile->AddRequestHeaders("Accept:   */*");
        POSITION pos = headers.GetHeadPosition();
        while (pos)
        {
            CString strHeader = headers.GetNext(pos);
            pFile->AddRequestHeaders(strHeader);
        }
        pFile->SendRequest(NULL, 0, outBuff, strlen(outBuff) + 1);
        pFile->QueryInfoStatusCode(retcode);
    }
    catch (...)
    {
        pFile = NULL;
    };

    if (pFile)
    {
        CString   text;
        for (int i = 0; pFile->ReadString(text); i++)
        {
            httpsource = httpsource + text + "\r\n";
        }
        pFile->Close();

        delete   pFile;
        delete   conn1;
        session1.Close();
    }
    else
    {

    }
    return   httpsource;
}

CString CHttpClient::doPost(CString href)
{
    CString httpsource = "";
    CInternetSession session1;
    CHttpConnection* conn1 = NULL;
    CHttpFile* pFile = NULL;

    DWORD dwServiceType;
    CString strServerName;
    CString strObject;
    INTERNET_PORT nPort;
    AfxParseURL((LPCTSTR)href, dwServiceType, strServerName, strObject, nPort);

    DWORD retcode;
    //char* outBuff = CONTENT.GetBuffer(1000);
    try
    {
        conn1 = session1.GetHttpConnection(strServerName, nPort);

        pFile = conn1->OpenRequest(CHttpConnection::HTTP_VERB_POST, strObject, NULL, 1, NULL, "HTTP/1.1", INTERNET_FLAG_EXISTING_CONNECT | INTERNET_FLAG_NO_AUTO_REDIRECT);
        pFile->AddRequestHeaders("Accept:*/*");
        POSITION pos = headers.GetHeadPosition();
        while (pos)
        {
            CString strHeader = headers.GetNext(pos);
            pFile->AddRequestHeaders(strHeader);
        }
        pFile->SendRequest(NULL, 0, CONTENT.GetBuffer(), CONTENT.GetLength());

        pFile->QueryInfoStatusCode(retcode);
        if (retcode == HTTP_STATUS_OK)
        {
        }
    }
    catch (...)
    {
        pFile = NULL;
    };

    if (pFile)
    {
        CString text;
        for (int i = 0; pFile->ReadString(text); i++)
        {
            httpsource = httpsource + text + "\r\n";
        }
        pFile->Close();

        delete   pFile;
        delete   conn1;
        session1.Close();
    }

    return   httpsource;
}

void   CHttpClient::addParam(CString name, CString value)
{
    names.AddTail((LPCTSTR)name);
    values.AddTail((LPCTSTR)value);
    CString   eq = "=";
    CString   an = "&";
    CONTENT = CONTENT + name + eq + value + an;
    CL = CONTENT.GetLength();
}

void CHttpClient::releaseHeaders()
{
    headers.RemoveAll();
}

void CHttpClient::addHeaders(CString name, CString value)
{
    headers.AddTail(name + ":" + value);
}
void CHttpClient::setBodyJson(CString strJSON)
{
    CONTENT = strJSON;
}

void   CHttpClient::SetRecvTimeOut(DWORD dwTime)
{
    m_dwRecvTimeOut = dwTime;
}