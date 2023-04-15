#pragma once

class DBConnectEntry;
class PlayerInfoModule
{
public:
    void OnServerStart(BOOL &, TcyMsgCenter *);
    void OnShutDown();

    BOOL OnQueryExPlayerInfoParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnChangeExPlayerInfoParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // 返回消息
    ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
	// DB操作
	ImportFunctional < std::future<int> (const std::string&, std::function<int(DBConnectEntry*)>) > imDBOpera;

	static int GetOnePlayerEx(DBConnectEntry* entry, int nUserID, EXPLAYERINFOPER& playerEx);
	static int UpdateOnePlayerEx(DBConnectEntry* entry, EXPLAYERINFOPER& playerEx);

	void OnInputTest(bool& ret, std::string& cmd);

protected:
	std::string toKey(int nUserID);
};

