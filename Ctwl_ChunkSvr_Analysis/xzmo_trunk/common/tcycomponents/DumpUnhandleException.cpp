#include "StdAfx.h"
#include "DumpUnhandleException.h"

#include  <dbghelp.h >
#pragma comment(lib,  "dbghelp.lib")

struct MiniDumpUtls
{
    static void WriteMiniDMP(struct _EXCEPTION_POINTERS* pExp)
    {
        CString   strDumpFile;
        TCHAR szFilePath[MAX_PATH];
        GetModuleFileName(NULL, szFilePath, MAX_PATH);
        *strrchr(szFilePath, '\\') = 0;
        strDumpFile.Format("%s\\%d.dmp", szFilePath, CTime::GetCurrentTime().GetTickCount());
        HANDLE   hFile = CreateFile(strDumpFile, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
        if (hFile != INVALID_HANDLE_VALUE)
        {
            MINIDUMP_EXCEPTION_INFORMATION   ExInfo;
            ExInfo.ThreadId = ::GetCurrentThreadId();
            ExInfo.ExceptionPointers = pExp;
            ExInfo.ClientPointers = NULL;
            //   write   the   dump
            BOOL   bOK = MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), hFile, MiniDumpWithFullMemoryInfo, &ExInfo, NULL, NULL);
            CloseHandle(hFile);
        }
    }

    static LONG WINAPI ExpFilter(struct _EXCEPTION_POINTERS* pExp)
    {
        WriteMiniDMP(pExp);
        return EXCEPTION_EXECUTE_HANDLER;
    }


    static void DisableSetUnhandledExceptionFilter()
    {
        void* addr = (void*)GetProcAddress(LoadLibrary(_T("kernel32.dll")), "SetUnhandledExceptionFilter");
        if (addr)
        {
            unsigned char code[16];
            int size = 0;

            code[size++] = 0x33;
            code[size++] = 0xC0;
            code[size++] = 0xC2;
            code[size++] = 0x04;
            code[size++] = 0x00;
            DWORD dwOldFlag, dwTempFlag;

            VirtualProtect(addr, size, PAGE_READWRITE, &dwOldFlag);
            WriteProcessMemory(GetCurrentProcess(), addr, code, size, NULL);
            VirtualProtect(addr, size, dwOldFlag, &dwTempFlag);
        }
    }

    static std::string getOSName()
    {
        std::string osName = ("");
        int i = 0, j = 0;
        _asm
        {
            pushad
            mov ebx, fs:[0x18]; //get self pointer from TEB
            mov eax, fs:[0x30]; // get pointer to PEB / database
            mov ebx, [eax + 0A8h]; //get OSMinorVersion
            mov eax, [eax + 0A4h]; //get OSMajorVersion
            mov j, ebx
            mov i, eax
            popad
        }

        if ((i == 5) && (j == 0))
        {
            osName = ("2000");
        }
        else if ((i == 5) && (j == 1))
        {
            osName = ("XP");
        }
        else if ((i == 5) && (j == 2))
        {
            osName = ("2003");
        }
        else if ((i == 6) && (j == 0))
        {
            osName = ("Vista");
        }
        else if ((i == 6) && (j == 1))
        {
            osName = ("7");
        }
        else if ((i == 6) && (j == 2))
        {
            osName = ("8");
        }
        else if ((i == 6) && (j == 3))
        {
            osName = ("8.1");
        }
        else if ((i == 10) && (j == 0))
        {
            osName = ("10");
        }
        else
        {
            osName = ("unknow");
        }
        return osName;
    }

    static void setGlobalException()
    {
        ::SetUnhandledExceptionFilter(ExpFilter);
        if ("10" != getOSName())
        {
            DisableSetUnhandledExceptionFilter();
        }
    }
};

DumpUnhandleException::DumpUnhandleException()
{
    MiniDumpUtls::setGlobalException();
}
