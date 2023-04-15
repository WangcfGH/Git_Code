#include "stdafx.h"
#include "TestTask.h"
#include "TaskReq.h"

void TestTask::OnTest(const std::string& cmd)
{
    if (cmd == "task_query") {
        LPTASKQUERY taskquery = new TASKQUERY;
        ZeroMemory(taskquery, sizeof(TASKQUERY));
        taskquery->nDate = 20190718;
        taskquery->nType = 0;
        taskquery->nUserID = 123456;
		evDoSendMsg(1, GR_TASK_QUERY_DATA, taskquery, sizeof(TASKQUERY), 500);
        evDoSendMsg(1, GR_TASK_QUERY_PARAM, taskquery, sizeof(TASKQUERY), 500);
        SAFE_DELETE(taskquery);
    } 
}

void TestTask::OnServerStart(int index, TcyMsgCenter* msgCenter)
{
    msgCenter->setMsgOper(GR_TASK_QUERY_DATA, [this, index](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        if (index == 1) {
            int a = 1;
        }
    });
    msgCenter->setMsgOper(GR_TASK_QUERY_PARAM, [this, index](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        int a = 1;
    });
}
