#pragma once
#include <vector>
class TestSockClient;
class SocketClientManager
{
public:
    SocketClientManager();
    ~SocketClientManager();

    void OnServerStart(BOOL& ret);
    void Initialize();
    void Shutdown();

    std::vector<TestSockClient *> m_clientList;
    EventNoMutex<const char*, const char*, int &> evGetIniInt;
    EventNoMutex<int, TcyMsgCenter*> evSvrStart;


    void SendMsg(int index, int, const void *data, int length, int repeat);
    void SendMsgRandom(int, const void *data, int length, int repeat);

private:
    int m_clientCount;
};

