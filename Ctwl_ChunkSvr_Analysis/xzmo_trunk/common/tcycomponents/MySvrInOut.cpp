#include "StdAfx.h"
#include "MySvrInOut.h"


CMySvrInOut::CMySvrInOut(std::string iniFile, CIocpServer* mainSvr)
{
    m_iniFile = iniFile;
    m_mainSvr = mainSvr;
}

void CMySvrInOut::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret)
    {
        Init(m_iniFile.c_str(), m_mainSvr, PORT_OF_CHUNKSVR, _T(GAME_CLIENT"ChunkSvr"), ELK_SVR_TYPE_CHUNK);
    }
}
