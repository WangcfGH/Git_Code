#if   !defined(AFX_HTTPCLIENT_H__EA769DCB_AAB9_47CD_BD87_FBD6913592C5__INCLUDED_)
#define   AFX_HTTPCLIENT_H__EA769DCB_AAB9_47CD_BD87_FBD6913592C5__INCLUDED_

#if   _MSC_VER > 1000
    #pragma   once
#endif   //   _MSC_VER > 1000
#include   "wininet.h"
#include   "afxinet.h"

#define MAX_IP_CHAR_LEN         64

inline char* ANSI_to_UTF8(const char* szAnsi, int& nUTF8Len);
CString  MD5String(LPTSTR lpszContent);
TCHAR* ipDword2Str(DWORD dwIPAddr);
BOOL ConvertStringToURLCoding(CString& strDest, const char* strAnsi);

class   CHttpClient
{
public:
    CHttpClient();
    virtual     ~CHttpClient();
    CString     doGet(CString href);
    CString     doPost(CString href);
    void        releaseHeaders();
    void        addHeaders(CString name, CString value);
    void        addParam(CString name, CString value);
    void        setBodyJson(CString strJSON);
    void        SetRecvTimeOut(DWORD dwTime);

private:
    int         CL;
    CString     CONTENT;
    CStringList headers;
    CStringList values;
    CStringList names;
    DWORD       m_dwRecvTimeOut;
};

#endif   //   !defined(AFX_HTTPCLIENT_H__EA769DCB_AAB9_47CD_BD87_FBD6913592C5__INCLUDED_)
