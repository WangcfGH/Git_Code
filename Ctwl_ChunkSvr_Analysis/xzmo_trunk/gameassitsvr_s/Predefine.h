#pragma once
#include <string>

#define		PRODUCT_LICENSE	 		_T("license.dat")
#define		PRODUCT_NAME			_T(GAME_CLIENT"AssitSvr")
#define		PRODUCT_VERSION			_T("1.00")
#define     STR_SERVICE_NAME		_T(GAME_CLIENT"AssitSvr")
#define     STR_DISPLAY_NAME		_T("同城游"GAME_APPNAME"辅助服务")
#define     STR_DISPLAY_NAME_ENU	_T("TCY"GAME_CLIENT "Assit Service") 

#define     ASSITSVR_CLSNAME_EX     _T("TCY_ASSITSVR_CLSNAME")
#define     ASSITSVR_WNDNAME_EX     _T("TCY_ASSITSVR_WNDNAME")

class CPredefine
{
public:
    const std::string getGameClient(){ return GAME_CLIENT; }
    const std::string getGameAppname(){ return GAME_APPNAME; }
    int getGameID(){ return GAME_ID; }
    int getGamesvrPort(){ return PORT_OF_GAMESVR; }
    int getGamempsvrPort(){ return PORT_OF_GAMEMPSVR; }
    int getChunksvrPort(){ return PORT_OF_CHUNKSVR; }
    int getAssistsvrPort(){ return PORT_OF_ASSITSVR; }
    int getAssistmpsvrPort(){ return PORT_OF_ASSITMPSVR; }
    int getChunklogPort(){ return PORT_OF_CHUNKLOG; }

    
    void init();

    std::string getIniFile() {
        return iniFile;
    }
    void evGetGameID(int& gameid) {
        gameid = getGameID();
    }
	void evGetProductName(std::string& productName) {
		productName = PRODUCT_NAME;
	}
	void getInitDataInt(const char* areaname, const char* key, int &result);
	void getInitDataString(const char* areaname, const char* key, std::string& result);
    BOOL InitClientID();

    void evGetClientID(int &nClientID);
private:
    std::string iniFile;
    
    int m_nClientID;
};


