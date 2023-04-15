// stdafx.cpp : source file that includes just the standard includes
//   limkSvr.pch will be the pre-compiled header
//  stdafx.obj will contain the pre-compiled type information

#include "stdafx.h"

// TODO: reference any additional headers you need in STDAFX.H
// and not in this file

CString GetINIFilePath()
{
    static std::string sIniFilePath;
    if (sIniFilePath.size() == 0)
    {
        sIniFilePath = GetINIFileName();
    }
    return sIniFilePath.c_str();
}