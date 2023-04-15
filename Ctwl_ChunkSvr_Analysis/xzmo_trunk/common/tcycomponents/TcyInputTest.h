#pragma once
#include "plana/plana.h"


struct TcyInputTest
{
public:
    EventNoMutex<bool&, std::string&> evInput;

    void WatchInput(const std::string& stopCmd = "quit");
};