#include "StdAfx.h"
#include "TcyInputTest.h"
#include <string>

void TcyInputTest::WatchInput(const std::string& stopCmd /*= "quit"*/)
{
    while (true)
    {
        bool next = true;
        std::string cmd;
        std::getline(std::cin, cmd);
        if (stopCmd == cmd)
        {
            break;
        }
        evInput(next, cmd);
    }
}
