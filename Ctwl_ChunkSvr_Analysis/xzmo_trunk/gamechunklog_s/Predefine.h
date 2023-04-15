#pragma once
#include <string>

#define		PRODUCT_LICENSE	 		_T("license.dat")
#define     PRODUCT_NAME            _T(GAME_CLIENT"Chunklog")
#define		PRODUCT_VERSION			_T("1.00")
#define     PORT_ONLINESVR			61420
#define     APPLICATION_TITLE	    _T(GAME_CLIENT"ChunkLog")
#define     STR_SERVICE_NAME        _T(GAME_CLIENT"ChunkLog")
#define     STR_DISPLAY_NAME        _T("同城游"GAME_APPNAME GAME_CLIENT"ChunkLog日志服务")
#define     STR_DISPLAY_NAME_ENU    _T("TCY "GAME_CLIENT"ChunkLog Service")

enum SOCKCILENT_INDEX
{
    SOCKCILENT_ONLINESVR = 10,
    SOCKCILENT_TRANKGAME,
    SOCKCILENT_MAX
};
class CPredefine
{
public:
    virtual const std::string getGameClient(){ return GAME_CLIENT; }
    virtual const std::string getGameAppname(){ return GAME_APPNAME; }
    virtual int getGameID(){ return GAME_ID; }
    virtual int getGamesvrPort(){ return PORT_OF_GAMESVR; }
    virtual int getGamempsvrPort(){ return PORT_OF_GAMEMPSVR; }
    virtual int getChunksvrPort(){ return PORT_OF_CHUNKSVR; }
    virtual int getAssistsvrPort(){ return PORT_OF_ASSITSVR; }
    virtual int getAssistmpsvrPort(){ return PORT_OF_ASSITMPSVR; }
    virtual int getChunklogPort(){ return PORT_OF_CHUNKLOG; }

    void init();

    void evGetIniFile(std::string& sFile) {
        sFile = iniFile;
    }
    void evGetGameID(int& gameid) {
        gameid = getGameID();
    }

	void getInitDataInt(const char* areaname, const char* key, int &result);
	void getInitDataString(const char* areaname, const char* key, std::string& result);

	BOOL InitClientID();
	void evGetClientID(int &nClientID);
private:
    std::string iniFile;
	int m_nClientID;
};


