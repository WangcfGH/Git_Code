#pragma once
// TODO: gamesvr���ܲ���redis��δ����Ҫ���洢������chunksvr

class COnLineDelegate : public CModuleDelegate
{
public:
	COnLineDelegate(CCommonBaseServer* pServer);
	virtual ~COnLineDelegate();

	//���߽��ݸ���;
	virtual BOOL OnUpdateOnLineData(int userID, int value = 1);
	virtual void OnUpdateOnLineDataWhenGameWin(CTable* pTable);
protected:
};

