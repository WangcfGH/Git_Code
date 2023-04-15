#include "StdAfx.h"

BOOL BuildDataDirectory(CString   strPath, BOOL bnBulid)
{
    while (strPath.Replace("\\\\", "\\")) {}

    CString   strSubPath;
    CString   strInfo;
    int   nCount   =   0;
    int   nIndex   =   0;

    //查找字符"\\"的个数
    do
    {
        nIndex   =   strPath.Find("\\", nIndex)   +   1;
        if (nIndex != strPath.GetLength()) //省略最后一个
        {
            nCount++;
        }
    } while ((nIndex - 1)   !=   -1);
    nIndex   =   0;

    //跳过盘符
    nIndex   =   strPath.Find("\\", nIndex)   +   1;
    nCount--;
    //检查，并创建目录
    while ((nCount - 1)   >=   0)
    {
        nIndex   =   strPath.Find("\\", nIndex)   +   1;
        if ((nIndex   -   1)   ==   -1)
        {
            strSubPath   =   strPath;
        }
        else
        {
            strSubPath   =   strPath.Left(nIndex - 1);
        }

        if (!IsFileExistEx(strSubPath))
        {
            if (bnBulid)
            {
                if (!::CreateDirectory(strSubPath, NULL))
                {
                    return   FALSE;
                }
            }
            else
            {
                return FALSE;
            }
        }
        nCount--;
    };
    return   TRUE;
}


BOOL WriteDataFile(LPSTR szPath, BYTE* data, DWORD length)
{
    // 若文件名含有目录结构, 则将'/'替换成可识别的'\\'
    for (int i = 0; i < (int)strlen(szPath); ++i)
    {
        if (szPath[i] == '/')
        {
            szPath[i] = '\\';
        }
    }

    // 打开文件
    FILE* fp = NULL;
    fopen_s(&fp, szPath, "wb+");
    if (fp == NULL)
    {
        return FALSE;
    }
    // 把整个文件内容读入缓冲区
    fseek(fp, 0, SEEK_SET);
    DWORD len = fwrite(data, length, 1, fp);
    if (len != 1)
    {
        fclose(fp);
        return FALSE;
    }
    fclose(fp);

    return TRUE;
}

BOOL DeleteDirectory(TCHAR* psDirName)
{
    CFileFind tempFind;
    TCHAR sTempFileFind[MAX_PATH] = { 0 };
    sprintf_s(sTempFileFind, "%s//*.*", psDirName);
    BOOL IsFinded = tempFind.FindFile(sTempFileFind);
    while (IsFinded)
    {
        IsFinded = tempFind.FindNextFile();
        if (!tempFind.IsDots())
        {
            char sFoundFileName[MAX_PATH] = { 0 };
            strcpy_s(sFoundFileName, tempFind.GetFileName().GetBuffer(0));
            if (tempFind.IsDirectory())
            {
                char sTempDir[MAX_PATH] = { 0 };
                sprintf_s(sTempDir, "%s//%s", psDirName, sFoundFileName);
                DeleteDirectory(sTempDir);
            }
            else
            {
                char sTempFileName[MAX_PATH] = { 0 };
                sprintf_s(sTempFileName, "%s//%s", psDirName, sFoundFileName);
                DeleteFile(sTempFileName);
            }
        }
    }
    tempFind.Close();

    if (!RemoveDirectory(psDirName))
    {
        return FALSE;
    }
    return TRUE;
}


CAutoStream::CAutoStream()
    : m_nUseSize(0)
    , m_nTotalSize(0)
    , m_data(NULL)
    , m_ptr(NULL)
{

}

CAutoStream::CAutoStream(const CAutoStream& stAutoStream)
{
    if (stAutoStream.m_data)
    {
        m_data = (BYTE*)malloc(stAutoStream.m_nUseSize);
        memcpy(m_data, stAutoStream.m_data, stAutoStream.m_nUseSize);
    }

    m_nTotalSize = stAutoStream.m_nTotalSize;
    m_nUseSize = stAutoStream.m_nUseSize;
    m_ptr = stAutoStream.m_ptr;
}

CAutoStream& CAutoStream::operator=(const CAutoStream& stAutoStream)
{
    if (stAutoStream.m_data != m_data)
    {
        if (m_data)
        {
            free(m_data);
            m_data = NULL;
        }

        if (stAutoStream.m_data)
        {
            m_data = (BYTE*)malloc(stAutoStream.m_nUseSize);
            memcpy(m_data, stAutoStream.m_data, stAutoStream.m_nUseSize);
        }
    }
    m_nTotalSize = stAutoStream.m_nTotalSize;
    m_nUseSize = stAutoStream.m_nUseSize;
    m_ptr = stAutoStream.m_ptr;

    return *this;
}


CAutoStream::~CAutoStream()
{
    Release();
}

void CAutoStream::Release()
{
    if (m_data)
    {
        free(m_data);
        m_data = NULL;
    }

    m_ptr = NULL;
    m_nUseSize = 0;
    m_nTotalSize = 0;
}

void* CAutoStream::GetHead()
{
    return m_data;
}

void* CAutoStream::GetCurrent()
{
    return m_ptr;
}

void* CAutoStream::GetPosition(int nPosition)
{
    if (m_data)
    {
        return (m_data + nPosition);
    }
    return NULL;
}

int CAutoStream::GetCurrentPostion()
{
    if (m_data && m_ptr)
    {
        return m_ptr - m_data;
    }
    return 0;
}

int CAutoStream::PushData(void* new_data, int new_size)
{
    if (!m_data)
    {
        int data_size = 256;
        while (data_size < new_size)
        {
            data_size = data_size * 2;
        }
        m_data = (BYTE*)malloc(data_size);
        if (!m_data)
        {
            throw 0;
        }
        memcpy(m_data, new_data, new_size);
        m_nTotalSize = data_size;
        m_nUseSize = new_size;
    }
    else
    {
        if (m_nTotalSize < m_nUseSize + new_size)
        {
            int nNewSize = m_nTotalSize;
            while (nNewSize < m_nUseSize + new_size)
            {
                nNewSize = nNewSize * 2;
            }
            AddMemory(nNewSize);

            m_nTotalSize = nNewSize;
        }

        memcpy(m_data + m_nUseSize, new_data, new_size);
        m_nUseSize = m_nUseSize + new_size;
    }

    return new_size;
}

void CAutoStream::AddMemory(int nNewSize)
{
    if (nNewSize <= 0)
    {
        return;
    }

    BYTE* data_new = (BYTE*)realloc((void*)m_data, nNewSize);
    if (!data_new)
    {
        throw 0;
    }
    if (data_new != m_data)
    {
        if (m_ptr)
        {
            m_ptr = data_new + (m_ptr - m_data);
        }

        m_data = data_new;
    }
}

int CAutoStream::GetSize()
{
    return m_nUseSize;
}

void CAutoStream::ClearData()
{
    m_nUseSize = 0;
}

void CAutoStream::MoveTo(int nPosition)
{
    if (!m_data)
    {
        return;
    }

    if (nPosition <= m_nUseSize)
    {
        m_ptr = m_data + nPosition;
    }
}

void CAutoStream::Move(int nOffset)
{
    if (!m_data)
    {
        return;
    }

    if (!m_ptr)
    {
        MoveTo(nOffset);
    }
    else if (m_ptr && (m_ptr - m_data + nOffset <= m_nUseSize))
    {
        m_ptr = m_ptr + nOffset;
    }
}

CReplayRecord::CReplayRecord()
{
    Clear();
}

CReplayRecord::~CReplayRecord()
{
}

void CReplayRecord::ReleaseData()
{
    Clear();

    m_stReplayHead.Release();
    m_stReplayData.Release();
}

void CReplayRecord::Clear()
{
    m_stReplayHead.ClearData();
    m_stReplayData.ClearData();

    m_bSave = FALSE;
    m_bActive = FALSE;
    m_nRoomID = 0;
    m_nTableNO = 0;
    m_nSaveSpace = REPLAY_SAVE_SPACE;

    m_nTotalStep = 0;
    m_dwStartTickCount = 0;
    m_dwTotalTickCount = 0;

    m_nInitPosition = -1;
}

int CReplayRecord::GetHeadSize()
{
    return m_stReplayHead.GetSize();
}

int CReplayRecord::GetDataSize()
{
    return m_stReplayData.GetSize();
}

void* CReplayRecord::GetPlayerInfo()
{
    m_stReplayHead.MoveTo(sizeof(REP_HEAD) + sizeof(REP_TABLE));
    return m_stReplayHead.GetCurrent();
}

void* CReplayRecord::GetDataBuff()
{
    return m_stReplayData.GetHead();
}

void* CReplayRecord::GetHeadBuff()
{
    return m_stReplayHead.GetHead();
}

void CReplayRecord::PushHead(void* pData, int nSize)
{
    m_stReplayHead.PushData(pData, nSize);
}

void CReplayRecord::ResetHeadValue()
{
    REP_HEAD* pRepHead = (REP_HEAD*)m_stReplayHead.GetHead();
    if (pRepHead)
    {
        pRepHead->nInitialPostion = GetHeadSize() + m_nInitPosition;
        pRepHead->nTotalStep = m_nTotalStep;
        pRepHead->nTotalTickCount = m_dwTotalTickCount;
        pRepHead->dwUnCompressLen = GetDataSize() + GetHeadSize() - sizeof(REP_HEAD);
    }
}

void CReplayRecord::PushInitStep(void* pData, int nSize)
{
    m_nInitPosition = m_stReplayData.GetSize();
    m_dwStartTickCount = GetTickCount();

    m_nTotalStep = m_nTotalStep + 1;

    m_stReplayData.PushData(pData, nSize);
}

void CReplayRecord::PushStep(void* pData, int nSize)
{
    REP_STEP* step = (REP_STEP*)pData;
    if (step)
    {
        step->dwTickCount = step->dwTickCount - m_dwStartTickCount;
        m_nTotalStep = m_nTotalStep + 1;
        m_dwTotalTickCount = step->dwTickCount;
    }

    m_stReplayData.PushData(pData, nSize);
}

void CReplayRecord::PushData(void* pData, int nSize)
{
    m_stReplayData.PushData(pData, nSize);
}

CString CReplayRecord::BuildFilePath(CString& strPath)
{
    strPath.TrimRight('\\');
    strPath += '\\';

    BuildDataDirectory(strPath);

    SYSTEMTIME timeNow;
    GetLocalTime(&timeNow);

    CString strFileName;
    strFileName.Format(_T("%s_%d房%04d年%02d月%02d日%02d时%02d分%02d秒%03d毫秒%s")
        , GAME_APPNAME
        , m_nRoomID
        , timeNow.wYear
        , timeNow.wMonth
        , timeNow.wDay
        , timeNow.wHour
        , timeNow.wMinute
        , timeNow.wSecond
        , timeNow.wMilliseconds
        , REPLAY_SUFFIXES
    );
    m_strFileName = strFileName;

    strPath += strFileName;
    return strPath;
}

BOOL CReplayRecord::WriteToFile(CString strPath)
{
    if (strPath.IsEmpty())
    {
        return FALSE;
    }

    BOOL bRet = TRUE;
    CString strFilePth = BuildFilePath(strPath);

    int nHeadLen = m_stReplayHead.GetSize();
    int nDataLen = m_stReplayData.GetSize();
    BYTE* pData = new BYTE[nHeadLen + nDataLen];
    if (NULL == pData)
    {
        UwlLogFile(_T("WriteToFile new failed!"));
        return FALSE;
    }

    memcpy(pData, m_stReplayHead.GetHead(), nHeadLen);
    memcpy(pData + nHeadLen, m_stReplayData.GetHead(), nDataLen);

    try
    {
        bRet = WriteDataFile(strFilePth.GetBuffer(0), pData, nHeadLen + nDataLen);
    }
    catch (...)
    {
        UwlLogFile(_T("ReplayRecord model error, WriteDataFile failed!"));
        if (pData)
        {
            delete[] pData;
            pData = NULL;
        }
        return FALSE;
    }

    if (pData)
    {
        delete []pData;
        pData = NULL;
    }

    return bRet;
}
