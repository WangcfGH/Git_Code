#include <SvrInOut.h>
#include "plana/plana.h"

class TcyMsgCenter;
class MainServer;
class CMySvrInOut : public CSvrInOut
{
public:
    CMySvrInOut(std::string iniFile, CIocpServer* mainSvr);
    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

private:
    CIocpServer* m_mainSvr;
    std::string m_iniFile;
};

