#pragma once
#include <string>

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

    void evGetIniFile(std::string& sFile) {
        sFile = iniFile;
    }
    void evGetGameID(int& gameid) {
        gameid = getGameID();
    }

	void getInitDataInt(const char* areaname, const char* key, int &result);
	void getInitDataString(const char* areaname, const char* key, std::string& result);

private:
    std::string iniFile;
};


