#pragma once
// TODO: gamesvr不能操作redis；未来需要将存储改造至chunksvr

class COnLineDelegate : public CModuleDelegate
{
public:
	COnLineDelegate(CCommonBaseServer* pServer);
	virtual ~COnLineDelegate();

	//在线阶梯更新;
	virtual BOOL OnUpdateOnLineData(int userID, int value = 1);
	virtual void OnUpdateOnLineDataWhenGameWin(CTable* pTable);
protected:
};

