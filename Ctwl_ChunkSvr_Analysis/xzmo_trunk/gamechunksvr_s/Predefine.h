#pragma once
#include <string>

#define		PRODUCT_LICENSE	 		_T("license.dat")
#define		PRODUCT_VERSION			_T("1.00")

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

    virtual const std::string getAppLactionTitle() { return (_T(GAME_CLIENT"ChunkSvr")); };
    virtual const std::string getStrServiceName() { return (_T(GAME_CLIENT"ChunkSvr")); };
    virtual const std::string getStrDisplayName() { return (_T("同城游"GAME_APPNAME"数据服务")); };
    virtual const std::string getStrDisplayNameEnu() { return (_T("TCY "GAME_CLIENT"ChunkSvr Service")); };;
    virtual int getOnLineSvrPort() { return PORT_ONLINESVR; };
    virtual int getSockClientOfOnlineSvr() { return SOCKCILENT_ONLINESVR; };
    virtual int getSockClientOfTrankGame() { return SOCKCILENT_TRANKGAME; };
    virtual const std::string getProductName(){ return (_T(GAME_CLIENT"Chunksvr")); };

    void init();

    std::string getIniFile() {
        return iniFile;
    }
	void evGetProductName(std::string& productName) {
		productName = PRODUCT_NAME;
	}
	
	void getInitDataInt(const char* areaname, const char* key, int& result);
	void getInitDataString(const char* areaname, const char* key, std::string& result);

	BOOL InitClientID();
	int getClientID() {
		return m_nClientID;
	}
private:
    std::string iniFile;
	int m_nClientID;
};


