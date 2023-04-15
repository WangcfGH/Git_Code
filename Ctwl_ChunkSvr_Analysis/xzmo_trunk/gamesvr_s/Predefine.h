#pragma once
// 需要修改
#define     PRODUCT_VERSION      "7.1"

// 禁止修改
#define     PRODUCT_LICENSE      ""
#define     PRODUCT_NAME         GAME_CLIENT"Svr"
#define     STR_SERVICE_NAME     PRODUCT_NAME
#define     STR_DISPLAY_NAME     "同城游"GAME_APPNAME GAME_CLIENT"服务"
#define     STR_DISPLAY_NAME_ENU "TCY "STR_SERVICE_NAME" Service"

class CPredefine
{
public:
    const std::string getGameClient() { return GAME_CLIENT; }
    const std::string getGameAppname() { return GAME_APPNAME; }
    int getGameID() { return GAME_ID; }
    int getGamesvrPort() { return PORT_OF_GAMESVR; }
    int getGamempsvrPort() { return PORT_OF_GAMEMPSVR; }
    int getChunksvrPort() { return PORT_OF_CHUNKSVR; }
    int getAssistsvrPort() { return PORT_OF_ASSITSVR; }
    int getAssistmpsvrPort() { return PORT_OF_ASSITMPSVR; }
    int getChunklogPort() { return PORT_OF_CHUNKLOG; }

    void evGetIniFile(std::string& sFile)
    {
        sFile = iniFile;
    }
    void evGetGameID(int& gameid)
    {
        gameid = getGameID();
    }
    void getInitDataInt(const char* areaname, const char* key, int& result);
    void getInitDataString(const char* areaname, const char* key, std::string& result);

    void init();
private:
    std::string iniFile;
    int m_nClientID;
};

