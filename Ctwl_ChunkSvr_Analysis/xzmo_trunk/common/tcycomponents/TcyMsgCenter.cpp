#include "stdafx.h"
#include "TcyMsgCenter.h"
#include <cassert>
#include <unordered_map>

// ����������ʵ��һЩ������Ϣ�����ͳ�ƵȲ�Ӱ���ⲿ�ĵ��ýӿ�
class TcyMsgCenterImp
{
public:
    std::unordered_multimap<int, std::function<void(LPCONTEXT_HEAD, LPREQUEST)>> m_msg2opers;
};

TcyMsgCenter::TcyMsgCenter()
{
    m_imp.reset(new TcyMsgCenterImp);
}


TcyMsgCenter::~TcyMsgCenter()
{

}

void TcyMsgCenter::setMsgOper(int msgid, std::function<void(LPCONTEXT_HEAD, LPREQUEST)> oper)
{
    auto it = m_imp->m_msg2opers.find(msgid);
    m_imp->m_msg2opers.insert({ msgid, oper });
}

void TcyMsgCenter::setMsgOper(std::vector<MsgOperInfo>& msgopers)
{
    for (auto& it : msgopers)
    {
        setMsgOper(it.msgid, it.oper);
    }
}

bool TcyMsgCenter::notify(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    assert(lpRequest && lpContext);

    auto it = m_imp->m_msg2opers.equal_range(lpRequest->head.nRequest);
    bool done = it.first != it.second;
    while (it.first != it.second)
    {
        it.first->second(lpContext, lpRequest);
        ++it.first;
    }
    return done;
}

void TcyMsgCenter::clear()
{
    m_imp->m_msg2opers.clear();
}


//////////////////////////////////////////////////////////////////////////
TcyMsgHead::~TcyMsgHead()
{
    if (requst.pDataPtr)
    {
        UwlClearRequest(&requst);
    }
}

std::shared_ptr<TcyMsgHead>
CopyTcyMsgHead(LPREQUEST pReqeust, LPCONTEXT_HEAD pContext)
{
    std::shared_ptr<TcyMsgHead> head = std::make_shared<TcyMsgHead>(*pReqeust, *pContext);
    head->requst.pDataPtr = new BYTE[pReqeust->nDataLen];
    head->requst.nDataLen = pReqeust->nDataLen;
    memcpy(head->requst.pDataPtr, pReqeust->pDataPtr, pReqeust->nDataLen);

    return head;
}

std::shared_ptr<TcyMsgHead>
MoveTcyMsgHead(LPREQUEST pRequest, LPCONTEXT_HEAD pContext)
{
    std::shared_ptr<TcyMsgHead> head = std::make_shared<TcyMsgHead>(*pRequest, *pContext);
    head->requst.pDataPtr = pRequest->pDataPtr;
    head->requst.nDataLen = pRequest->nDataLen;

    // ����ֱ�Ӱ�ԭ�������ݸ����ɵ�������
    // ǧ��ҪС�ģ���Ҫ����
    pRequest->pDataPtr = nullptr;
    pRequest->nDataLen = 0;
    return head;
}

