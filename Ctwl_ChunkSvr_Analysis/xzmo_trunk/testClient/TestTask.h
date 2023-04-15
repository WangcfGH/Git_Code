#pragma once
class TestTask
{
public:
    EventNoMutex<int , int, const void *, int, int > evDoSendMsg;
    EventNoMutex<int, const void *, int, int > evSendMsgRandom;

    void OnTest(const std::string& cmd);
    void OnServerStart(int index, TcyMsgCenter* msgCenter);
};

