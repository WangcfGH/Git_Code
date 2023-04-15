
if nil == cc or nil == cc.exports then
    return
end

local TRUNOFF_BACKGROUND_MSG = false

local ignoreGetTableFailed = false

require("src.cocos.cocos2d.bitExtend")
require("src.app.GameHall.PublicInterface")
local PublicInterface                           = cc.exports.PUBLIC_INTERFACE

local BaseGameDef                               = import("src.app.Game.mBaseGame.BaseGameDef")

cc.exports.GameController                       = {}
local BaseGameController                        = cc.exports.GameController

local BaseGameData                              = import("src.app.Game.mBaseGame.BaseGameData")
local BaseGamePlayerInfoManager                 = import("src.app.Game.mBaseGame.BaseGamePlayerInfoManager")
local BaseGameUtilsInfoManager                  = import("src.app.Game.mBaseGame.BaseGameUtilsInfoManager")
local BaseGameArenaInfoManager                  = import("src.app.Game.mBaseGame.BaseGameArena.BaseGameArenaInfoManager")
local BaseGameConnect                           = import("src.app.Game.mBaseGame.BaseGameConnect")
local BaseGameNotify                            = import("src.app.Game.mBaseGame.BaseGameNotify")

local GamePublicInterface                       = import("src.app.Game.mMyGame.GamePublicInterface")
local ArenaModel = require("src.app.plugins.arena.ArenaModel"):getInstance()

function BaseGameController:initGameController(baseGameScene)
    if not baseGameScene then printError("baseGameScene is nil!!!") return end

    self:resetController()

    self._baseGameScene = baseGameScene

    self:createGameData()
    self:createPlayerInfoManager()
    self:createUtilsInfoManager()
    self:createArenaInfoManager()

    self:preloadBGM()

    self:initManagerAboveBaseGame()

    self:initGamePublicInterface()
end

function BaseGameController:resetController()
    self._baseGameScene                 = nil

    self._baseGameData                  = nil
    self._baseGamePlayerInfoManager     = nil
    self._baseGameUtilsInfoManager      = nil
    self._baseGameNetworkClient         = nil
    self._baseGameConnect               = nil
    self._baseGameNotify                = nil
    
    self._isResume                      = false
    self._isGameRunning                 = false
    self._isConnected                   = false
    self._isDXXW                        = false
    
    self._session                       = -1
    self._response                      = BaseGameDef.BASEGAME_WAITING_NOTHING
    self._connectTimes                  = 0
    
    self._bAutoPlay                     = false
    self._autoWaitTimes                 = 0
    self._minWaitTimes                  = 2

    self._dispatch                      = nil
    self._showCharteredBtn              = nil
    self._playerLbs                     = {}
    self._playerHead                    = {}

    self._isHallEntery                  =  PublicInterface.isEnterRoomByTeamEntry()

    -- common proxy begin
    self._proxyConnect = false
    self._connectSvrStr = ""
    -- common proxy end

    if GamePublicInterface then
        GamePublicInterface:setGameController(nil)
    end
end

function BaseGameController:createGameData()
    self._baseGameData = BaseGameData:create()
end

function BaseGameController:getGameData()
    return self._baseGameData
end

function BaseGameController:createPlayerInfoManager()
    self._baseGamePlayerInfoManager = BaseGamePlayerInfoManager:create(self)
    self:setSelfInfo()
end

function BaseGameController:getPlayerInfoManager()
    return self._baseGamePlayerInfoManager
end

function BaseGameController:createUtilsInfoManager()
    self._baseGameUtilsInfoManager = BaseGameUtilsInfoManager:create()
    self:setUtilsInfo()
end

function BaseGameController:getUtilsInfoManager()
    return self._baseGameUtilsInfoManager
end

function BaseGameController:createArenaInfoManager()
    self._baseGameArenaInfoManager = BaseGameArenaInfoManager:create(self)
    self:setArenaInfo()
end

function BaseGameController:getArenaInfoManager()
    return self._baseGameArenaInfoManager
end

function BaseGameController:getBGMPath()
    return "res/Game/GameSound/BGMusic/BG.mp3"
end

function BaseGameController:preloadBGM()
    audio.preloadMusic(self:getBGMPath())
end

function BaseGameController:playBGM()
    audio.playMusic(self:getBGMPath())
end

function BaseGameController:stopBGM()
    audio.stopMusic(DEBUG == 0)
end

function BaseGameController:initManagerAboveBaseGame() end

function BaseGameController:initGamePublicInterface()
    if GamePublicInterface then
        GamePublicInterface:setGameController(self)
    end
end

function BaseGameController:setSelfInfo()
    if not self._baseGamePlayerInfoManager then return end

    local playerInfo = PublicInterface.GetPlayerInfo()
    --local playerTableInfo = PublicInterface.GetEnterGameInfo().tableInfo
    local playerTableInfo = PublicInterface.GetTableInfo()

    local selfInfo = {}
    selfInfo.nUserID        = playerInfo.nUserID
    selfInfo.nUserType      = playerInfo.nUserType
    selfInfo.nStatus        = playerInfo.nStatus
    selfInfo.nTableNO       = playerTableInfo.nTableNO
    selfInfo.nChairNO       = playerTableInfo.nChairNO
    selfInfo.nNickSex       = playerInfo.nNickSex
    selfInfo.nPortrait      = playerInfo.nPortrait
    selfInfo.nNetSpeed      = playerInfo.nNetSpeed
    selfInfo.nClothingID    = playerInfo.nClothingID
    selfInfo.szUserName     = playerInfo.szUsername
    selfInfo.szNickName     = playerInfo.szNickName
    selfInfo.nDeposit       = playerInfo.nDeposit
    selfInfo.nPlayerLevel   = playerInfo.nPlayerLevel
    selfInfo.nScore         = playerInfo.nScore
    selfInfo.nBreakOff      = playerInfo.nBreakOff
    selfInfo.nWin           = playerInfo.nWin
    selfInfo.nLoss          = playerInfo.nLoss
    selfInfo.nStandOff      = playerInfo.nStandOff
    selfInfo.nBout          = playerInfo.nBout
    selfInfo.nTimeCost      = playerInfo.nTimeCost
    selfInfo.nGrowthLevel   = playerInfo.nGrowthLevel

    dump(selfInfo)
    self._baseGamePlayerInfoManager:setSelfInfo(selfInfo)
end

function BaseGameController:setUtilsInfo()
    if not self._baseGameUtilsInfoManager then return end

    local playerInfo = PublicInterface.GetPlayerInfo()
    --local playerEnterGameOK = PublicInterface.GetEnterGameInfo().enterRoomOkInfo
    --local RoomInfo = PublicInterface.GetCurrentRoomInfo().original
    local playerEnterRoomOK = PublicInterface.GetEnterRoomOk()
    local RoomInfo = PublicInterface.GetCurrentRoomInfo()

    local utilsInfo = {}
    utilsInfo.szHardID          = playerInfo.szHardID
    utilsInfo.nRoomTokenID      = playerEnterRoomOK.nRoomTokenID
    utilsInfo.nMbNetType        = DeviceUtils:getInstance():getNetworkType()
    utilsInfo.bLookOn           = 0
    utilsInfo.nGameID           = playerInfo.nGameID
    utilsInfo.nRoomID           = playerInfo.nRoomID
    utilsInfo.nRoomInfo         = RoomInfo

    printf("~~~~~~~~~~~~~~~~setUtilsInfo~~~~~~~~~~~~~~~~~~~~~~")
    --dump(cc.exports.GetExtraConfigInfo().GameID)
    dump(utilsInfo)
    self._baseGameUtilsInfoManager:setUtilsInfo(utilsInfo)
end


function BaseGameController:setArenaInfo(onGetArenaInfo)
    if not self._baseGameArenaInfoManager then return end

    
    if PUBLIC_INTERFACE.IsStartAsArenaPlayer() then

        ArenaModel:getCurrentArenaDetail(function(dataMap, respondType)
            if      respondType == 'userArena' then
                local arenaInfo = {
                    nMatchID        = dataMap.nMatchID,
                    nHP             = dataMap.nHP,
                    nAddition       = dataMap.nAddition,
                    nBout           = dataMap.nBout,
                    nStreaking      = dataMap.nStreaking,
                    nTopStreaking   = dataMap.nTopStreaking,
                    nWinBout        = dataMap.nWinBout,
                    nMatchScore     = dataMap.nMatchScore,
                    nLevel          = dataMap.nLevel
                }
                self._baseGameArenaInfoManager:setArenaInfo(arenaInfo)
            elseif  respondType == 'arenaInfo' then
                local arenaInfo = {
                    nInitHP             = dataMap.nInitHP,
                    nAwardInfoNumber    = dataMap.nAwardInfoNumber,
                    szMatchName         = dataMap.szMatchName,
                    awardInfo           = dataMap.awardInfo,
                    IsForceQuit         = dataMap.IsForceQuit,
                }
                self._baseGameArenaInfoManager:setArenaInfo(arenaInfo)
                if type(onGetArenaInfo) == 'function' then onGetArenaInfo() end
            end
        end, false)
        self._baseGameArenaInfoManager:setIsArenaPlayer(true)

    else

        self._baseGameArenaInfoManager:setIsArenaPlayer(false)

    end

end

function BaseGameController:createNetwork()
    UIHelper:recordRuntime("EnterGameScene", "BaseGameController:createNetwork")

    local ip = PUBLIC_INTERFACE.GetGameServerIp()
    local port = PUBLIC_INTERFACE.GetGameServerPort()
    print("ip:"..ip..", port:"..port)
    
    self._proxyConnect, self._baseGameNetworkClient, self._connectSvrStr = my.commonMPConnect(ip, port, 4)

    -- self._baseGameNetworkClient = MCAgent:getInstance():createClient(PublicInterface.GetGameServerIp(), PublicInterface.GetGameServerPort())

    local function onDataReceived(clientid, msgtype, session, request, data)
        self:onDataReceived(clientid, msgtype, session, request, data)
    end
    if self._baseGameNetworkClient then
        self._baseGameNetworkClient:setCallback(onDataReceived)
        self:setConnect()
        self:setNotify()

        -- Connect socket after setting connecttion and setting notification
        self._baseGameNetworkClient:connect()
    end
end

function BaseGameController:onDataReceived(clientid, msgtype, session, request, data)
    if self._baseGameNotify then
        self._baseGameNotify:onDataReceived(clientid, msgtype, session, request, data)
    end
end

function BaseGameController:setConnect()
    self._baseGameConnect = BaseGameConnect:create(self)
end

function BaseGameController:getConnect()
    return self._baseGameConnect
end

function BaseGameController:setNotify()
    self._baseGameNotify = BaseGameNotify:create(self)
end

function BaseGameController:getNetworkClient()
    return self._baseGameNetworkClient
end

function BaseGameController:setBackgroundCallback()
    local callback = function()
        self:onPause()
    end
    AppUtils:getInstance():removePauseCallback("Game_BaseGameController_setBackgroundCallback")
    AppUtils:getInstance():addPauseCallback(callback, "Game_BaseGameController_setBackgroundCallback")
end

function BaseGameController:setForegroundCallback()
    local callback = function()
        self:onResume()
    end
    AppUtils:getInstance():removeResumeCallback("Game_BaseGameController_setForegroundCallback")
    AppUtils:getInstance():addResumeCallback(callback, "Game_BaseGameController_setForegroundCallback")
end

function BaseGameController:onPause()
    self:pause() 

    self:stopShieldVoiceTimer()

    if not self:isGameRunning() then
        if self._baseGameConnect then
            self._baseGameConnect:gc_AppEnterBackground()
        end
    end
end

function BaseGameController:onResume()
    self:resume()
    self:setResume(true)

    self:setResponse(self:getResWaitingNothing())

    if device.platform ~= "windows" then
        self:startShieldVoiceTimer() --屏蔽声音标识
    end

    if not self:isGameRunning() then
        if self._baseGameConnect then
            self._baseGameConnect:gc_AppEnterForeground()
        end
    end

    if self._baseGameConnect then
        self._baseGameConnect:gc_GetTableInfo()
    end
end

function BaseGameController:pause()
    if self._baseGameConnect then
        self._baseGameConnect:pause()
    end
end

function BaseGameController:resume()
    if self._baseGameConnect then
        self._baseGameConnect:resume()
    end
end

function BaseGameController:disconnect()
    if self._baseGameConnect then
        self._baseGameConnect:disconnect()
        self._baseGameConnect = nil
    end
end

function BaseGameController:setResume(isResume)
    self._isResume = ("boolean" == type(isResume)) and isResume or false
end

function BaseGameController:isResume()
    return self._isResume
end

function BaseGameController:resetResume()
    self:setResume(false)
end

function BaseGameController:isGameRunning()
    return self._isGameRunning
end

function BaseGameController:gameRun()
    self._isGameRunning = true
end

function BaseGameController:gameStop()
    self._isGameRunning = false
end

function BaseGameController:isConnected()
    return self._isConnected
end

function BaseGameController:setDXXW(bDXXW)
    self._isDXXW = bDXXW
end

function BaseGameController:isDXXW()
    return self._isDXXW
end

function BaseGameController:setSession(session)
    self._session = session
end

function BaseGameController:getSession()
    return self._session
end

function BaseGameController:setResponse(response)
    self._response = response
end

function BaseGameController:getResponse()
    return self._response
end

function BaseGameController:getResWaitingNothing()
    return BaseGameDef.BASEGAME_WAITING_NOTHING
end

function BaseGameController:waitForResponse()
    local function onResponseFinished(dt)
        self:onResponseFinished(dt)
    end
    self:stopResponseTimer()
    self.resposeTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onResponseFinished, 10.0, false)
end

function BaseGameController:onResponseFinished(dt)
    self:stopResponseTimer()
    self:onTimeOut()
end

function BaseGameController:stopResponseTimer()
    if self.resposeTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.resposeTimerID)
        self.resposeTimerID = nil
    end
end

function BaseGameController:onResponse()
    self:stopResponseTimer()
end

function BaseGameController:ope_ShowStart(bShow)
    local gameStart = self._baseGameScene:getStart()
    if gameStart then
        gameStart:ope_ShowStart(bShow)
    end
end

function BaseGameController:showWaitArrangeTable(bShow)
    local gameStart = self._baseGameScene:getStart()
    if gameStart then
        gameStart:showWaitArrangeTable(bShow)
    end
end

function BaseGameController:isWaitArrangeTableShow()
    --[[local gameStart = self._baseGameScene:getStart()
    if gameStart then
        return gameStart:isWaitArrangeTableShow()
    end]]
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        return selfInfo:isWaitArrangeTableShow()
    end
    return false
end

function BaseGameController:onGameEnter()
end

function BaseGameController:onGameExit()
    self:disconnect()

    self:stopResponseTimer()
    self:stopGamePluse()

    AppUtils:getInstance():removePauseCallback("Game_BaseGameController_setBackgroundCallback")
    AppUtils:getInstance():removeResumeCallback("Game_BaseGameController_setForegroundCallback")

    local clock = self._baseGameScene:getClock()
    if clock then
        clock:onGameExit()
    end

    local sysInfoNode = self._baseGameScene:getSysInfoNode()
    if sysInfoNode then
        sysInfoNode:onGameExit()
    end

    local gameStart = self._baseGameScene:getStart()
    if gameStart then
        gameStart:onGameExit()
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:onGameExit()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onGameExit()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onGameExit()
    end

    local loadingNode = self._baseGameScene:getLoadingNode()
    if loadingNode then
        loadingNode:onGameExit()
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:onGameExit()
    end

    local arenaInfo = self._baseGameScene:getArenaInfo()
    if arenaInfo then
        arenaInfo:onGameExit()
    end

    self:stopBGM()

    self:resetController()
end

function BaseGameController:isDarkRoom()
    local isDarkRoom = false
    if self._baseGameUtilsInfoManager then
        isDarkRoom = self:IS_BIT_SET(self._baseGameUtilsInfoManager:getRoomConfigs(), BaseGameDef.RC_DARK_ROOM)
    end
    return isDarkRoom
end

function BaseGameController:isRandomRoom()
    local isRandomRoom = false
    if self._baseGameUtilsInfoManager then
        isRandomRoom = self:IS_BIT_SET(self._baseGameUtilsInfoManager:getRoomConfigs(), BaseGameDef.BASEGAME_RC_RANDOM_ROOM)
    end
    return isRandomRoom
end

function BaseGameController:isSoloRoom()
    local isSoloRoom = false
    if self._baseGameUtilsInfoManager then
        isSoloRoom = self:IS_BIT_SET(self._baseGameUtilsInfoManager:getRoomConfigs(), BaseGameDef.BASEGAME_RC_SOLO_ROOM)
    end
    return isSoloRoom
end

function BaseGameController:isLeaveAloneRoom()
    local isLeaveAloneRoom = false
    if self._baseGameUtilsInfoManager then
        isLeaveAloneRoom = self:IS_BIT_SET(self._baseGameUtilsInfoManager:getRoomConfigs(), BaseGameDef.BASEGAME_RC_LEAVEALONE)
    end
    return isLeaveAloneRoom
end

function BaseGameController:isCharteredRoom()
    local isCharteredRoom = false
    if self._baseGameUtilsInfoManager then
        isCharteredRoom = self:IS_BIT_SET(self._baseGameUtilsInfoManager:getRoomConfigs(), BaseGameDef.BASEGAME_RC_PRIVATE_ROOM)
    end
    return isCharteredRoom
end

function BaseGameController:isTeamGameRoom()
    return self:isCharteredRoom() and self:isRandomRoom()
end

function BaseGameController:isHallEntery()
    return self._isHallEntery
end

function BaseGameController:setHallEntery(isHallEntery)
    self._isHallEntery = isHallEntery
end

function BaseGameController:isValidateChairNO(chairNO)
    return chairNO and -1 < chairNO and chairNO < self:getTableChairCount()
end

function BaseGameController:getMyDrawIndex()
    return BaseGameDef.BASEGAME_MYDRAWINDEX
end

function BaseGameController:getMyChairNO()
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        return playerInfoManager:getSelfChairNO()
    end
    return 0
end

function BaseGameController:getTableChairCount()
    return BaseGameDef.BASEGAME_MAX_PLAYERS
end

function BaseGameController:getChairCardsCount()
    return BaseGameDef.BASEGAME_MAX_CARDS
end

function BaseGameController:rul_GetDrawIndexByChairNO(chairNO)
    if not self:isValidateChairNO(chairNO) then return 0 end

    local index = 0

    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        local selfChairNO = playerInfoManager:getSelfChairNO()
        local tableChairCount = self:getTableChairCount()
        index = self:getMyDrawIndex()

        for i = 1, tableChairCount do
            if selfChairNO == chairNO then
                return index
            else
                index = index + 1
                selfChairNO = (selfChairNO + 1) % tableChairCount
            end
        end
    end

    return index
end

function BaseGameController:rul_GetChairNOByDrawIndex(drawIndex)
    local index = 0

    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        local selfChairNO = playerInfoManager:getSelfChairNO()
        local tableChairCount = self:getTableChairCount()
        index = self:getMyDrawIndex()

        for i = 1, tableChairCount do
            if index == drawIndex then
                return selfChairNO
            else
                index = index + 1
                selfChairNO = (selfChairNO + 1) % tableChairCount
            end
        end
    end

    return index
end

function BaseGameController:getPlayerUserNameByDrawIndex(drawIndex)
    if self._baseGamePlayerInfoManager then
        return self._baseGamePlayerInfoManager:getPlayerUserNameByDrawIndex(drawIndex)
    end
end

function BaseGameController:getPlayerUserNameByUserID(userID)
    if self._baseGamePlayerInfoManager then
        return self._baseGamePlayerInfoManager:getPlayerUserNameByUserID(userID)
    end
end

function BaseGameController:IS_BIT_SET(flag, mybit) return (mybit == bit._and(mybit, flag)) end

function BaseGameController:setSelfUserName(szUserName)
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:setSelfUserName(szUserName)
    end
end

function BaseGameController:setSelfMoney(nDeposit)
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:setSelfMoney(nDeposit)
    end
end

function BaseGameController:showSelfReady()
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showSelfReady(true)
    end
end

function BaseGameController:hideSelfReady()
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showSelfReady(false)
    end
end

function BaseGameController:clearPlayerReady()
    local playerManager = self._baseGameScene:getPlayerManager()
    for i = 1, self:getTableChairCount() do
        if self:getMyDrawIndex() == i then
            self:hideSelfReady()
        end

        if playerManager then
            playerManager:clearPlayerReady()
        end
    end
end

function BaseGameController:addPlayerBoutInfo(drawIndex, score)
    if self._baseGamePlayerInfoManager then
        if 0 < score then
            self._baseGamePlayerInfoManager:addPlayerWinBout(drawIndex)
        elseif 0 > score then
            self._baseGamePlayerInfoManager:addPlayerLossBout(drawIndex)
        else
            self._baseGamePlayerInfoManager:addPlayerStandOffBout(drawIndex)
        end

        if drawIndex == self:getMyDrawIndex() then
            self:syncPlayerBoutInfo()
        end
    end
end

function BaseGameController:syncPlayerBoutInfo()
    if self._baseGamePlayerInfoManager then
        local playerInfo = mymodel("hallext.PlayerModel"):getInstance()
        if playerInfo then
            local dataMap = {
                nWin = self._baseGamePlayerInfoManager:getSelfWin(),
                nLoss = self._baseGamePlayerInfoManager:getSelfLoss(),
                nStandOff = self._baseGamePlayerInfoManager:getSelfStandOff()
            }
            playerInfo:mergeUserData(dataMap)
        end
    end
end

function BaseGameController:addPlayerDeposit(drawIndex, deposit)
    local currentDeposit = 0
    if self._baseGamePlayerInfoManager then
        print("-------------------------function BaseGameController:addPlayerDeposit(drawIndex, deposit)------------------------",drawIndex, deposit,self._baseGamePlayerInfoManager:getPlayerDeposit(drawIndex))
        currentDeposit = self._baseGamePlayerInfoManager:getPlayerDeposit(drawIndex)
        if currentDeposit then
            currentDeposit = currentDeposit + deposit
            self:setPlayerDeposit(drawIndex, currentDeposit)
        end                
    end
end

function BaseGameController:setPlayerDeposit(drawIndex, deposit)
    if self._baseGamePlayerInfoManager then
        self._baseGamePlayerInfoManager:setPlayerDeposit(drawIndex, deposit)
    end

    if self:getMyDrawIndex() == drawIndex then
        self:setSelfMoney(deposit)
        self:setArenaDeposit(deposit)

        self:syncPlayerDeposit(deposit)
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:setMoney(drawIndex, deposit)
    end
end

function BaseGameController:syncPlayerDeposit(deposit)
    local playerInfo = mymodel("hallext.PlayerModel"):getInstance()
    if playerInfo then
        local dataMap = {
            nDeposit = deposit
        }
        playerInfo:mergeUserData(dataMap)
    end
end

function BaseGameController:addPlayerScore(drawIndex, score)
    local currentScore = 0
    if self._baseGamePlayerInfoManager then
        currentScore = self._baseGamePlayerInfoManager:getPlayerScore(drawIndex)
        if(currentScore==nil)then
            return
        end
        currentScore = currentScore + score
        self:setPlayerScore(drawIndex, currentScore)
    end
end

function BaseGameController:setPlayerScore(drawIndex, score)
    if self._baseGamePlayerInfoManager then
        self._baseGamePlayerInfoManager:setPlayerScore(drawIndex, score)
    end

    if self:getMyDrawIndex() == drawIndex then
        self:syncPlayerScore(score)
    end
end

function BaseGameController:syncPlayerScore(score)
    local playerInfo = mymodel("hallext.PlayerModel"):getInstance()
    if playerInfo then
        local dataMap = {
            nScore = score
        }
        playerInfo:mergeUserData(dataMap)
    end
end

function BaseGameController:showPlayerReady(drawIndex)
    if self:getMyDrawIndex() == drawIndex then
        self:showSelfReady()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:setReady(drawIndex, true)
    end
end

function BaseGameController:tipChatContent(drawIndex, content)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:tipChatContent(drawIndex, content)
    end
end

function BaseGameController:onRemoveLoadingLayer()
    local loadingNode = self._baseGameScene:getLoadingNode()
    if loadingNode then
        loadingNode:finishLoading()
        self._baseGameScene:cleanLoadingNode()
    end

    local loadingLayer = self._baseGameScene:getLoadingLayer()
    if loadingLayer then
        loadingLayer:removeSelf()
        self._baseGameScene:cleanLoadingLayer()
    end

    if not TRUNOFF_BACKGROUND_MSG then
        self:setBackgroundCallback()
        self:setForegroundCallback()
    end

    self:playBGM()
    --cc.exports.isShowLoadingPanel=false

    --self:showUserConvertBtn()
end

function BaseGameController:setSoloPlayer(soloPlayer)
    if self:getMyDrawIndex() == self:rul_GetDrawIndexByChairNO(soloPlayer.nChairNO) then
        -- self name of game must be same with hall's
        local userName = plugin.AgentManager:getInstance():getUserPlugin():getUserName()
        soloPlayer.szUserName = MCCharset:getInstance():utf82GbString(userName, string.len(userName))
        self:setSelfUserName(soloPlayer.szUserName)
        self:setSelfMoney(soloPlayer.nDeposit)
        --[[
        考虑到修改性别之后，玩家进入游戏时从服务器获取的性别信息并不是最新的，所以此时以selfInfo中的信息为准。
        ]]
        soloPlayer.nNickSex = self._baseGamePlayerInfoManager:getSelfInfo().nNickSex
        self:setArenaDeposit(soloPlayer.nDeposit)
        --self:setArenaNickSex(soloPlayer.nNickSex)

        --如果是自己的性别，确保与大厅保持一致
        local UserModel = mymodel('UserModel'):getInstance()
        local sexChecked = UserModel:getNickSexWithCheckSelf(soloPlayer.nUserID, soloPlayer.nNickSex)
        self:setArenaNickSex(sexChecked)
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        local drawIndex = self:rul_GetDrawIndexByChairNO(soloPlayer.nChairNO)
        if 0 < drawIndex then
            playerManager:setSoloPlayer(drawIndex, soloPlayer)
        end
    end

    if self._baseGamePlayerInfoManager then
        local drawIndex = self:rul_GetDrawIndexByChairNO(soloPlayer.nChairNO)
        if 0 < drawIndex then
            self._baseGamePlayerInfoManager:setPlayerInfo(drawIndex, soloPlayer)
        end
    end
end

function BaseGameController:playerAbort(drawIndex)
    if self:getMyDrawIndex() ~= drawIndex then
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:playerAbort(drawIndex)
        end
    end
end

function BaseGameController:onStartGame()
    print("BaseGameController:onStartGame")
    if self._baseGameConnect then       
        self._isShieldVoice = false  --发协议了 重置下标识
        if self:isTeamGameRoom() and self:isHallEntery() and self:isVisibleCharteredRoom() then
            print("gc_StartTeamReady")
            self._baseGameConnect:gc_StartTeamReady()
        elseif self:isTeamGameRoom() and PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            if self.gameWinBnResetGame and self.gameWinBnResetGame == 1 then
                print("BaseGameController:onStartGame() self.gameWinBnResetGame is 1")
            else
                local boutCount = self._baseGameUtilsInfoManager:getBoutCount()
                if boutCount and boutCount > 0 then
                    print("gc_StartGame")
                    self._baseGameConnect:gc_StartGame()
                else
                    print("gc_StartTeamReady")
                    self._baseGameConnect:gc_StartTeamReady()
                end
            end
        else
            print("gc_StartGame")
            self._baseGameConnect:gc_StartGame()
        end
    end
end

function BaseGameController:onCancelTeamMatch()
    if self._baseGameConnect then
        if self:isTeamGameRoom() then
            self._baseGameConnect:gc_CancelTeamMatch()
        end
    end
end

function BaseGameController:onChangeTable()
    if not self:isGameRunning() then
        if self._baseGameConnect then
            self._baseGameConnect:gc_AskNewTableChair()
        end
    end
end

function BaseGameController:onRandomTable()
    if not self:isGameRunning() then
        if self._baseGameConnect then
            self._baseGameConnect:gc_AskRandomTable()
        end
    end
end

function BaseGameController:onTouchBegan(x, y)
    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() then
        if not chat:containsTouchLocation(x, y) then
            chat:showChat(false)
        end
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onTouchBegin(x,y)
    end
end

function BaseGameController:onKeyBack()
    local loadingLayer = self._baseGameScene:getLoadingLayer()
    if loadingLayer and loadingLayer:isVisible() then
        return
    end
    if self._arenaStatement and self._arenaStatement.isAlive and self._arenaStatement:isAlive() then
        self._arenaStatement:onKeyBack()
        return
    end
    self:onQuit()
end

function BaseGameController:onQuit()
    print(debug.traceback("onQuit"))
    if (cc.exports.inTickoff == true) then
        print("ret 1")
        cc.exports.inTickoff = false
        self:gotoHallScene()
        return
    end

    --[[if self:isUserConvertSupported() then
        local userConvert = self:getUserConvertCtrl()
        if userConvert:isDlgShow() then
            return
        end
    end]]--


    if self._dispatch and ((self:isCharteredRoom() and not self:isRandomRoom()) or (self:isTeamGameRoom() and self:isHallEntery())) then
        if self._dispatch:isStartMatch() then
            print("ret 2")
            return
        end

        if self._dispatch:isNeedShow() then
             if cc.exports.hasStartGame then
                self._dispatch:show(false)
             else
                self._dispatch:show(true)
             end
             print("ret 3")
             return
        end
    end

    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox and safeBox:isVisible() then
        safeBox:showSafeBox(false)
        print("ret 4")
        return
    end

    local setting = self._baseGameScene:getSetting()
    if setting and setting:isVisible() then
        setting:showSetting(false)
        print("ret 5")
        return
    end

    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() then
        chat:showChat(false)
        print("ret 6")
        return
    end

    if self:isConnected() and self._baseGameConnect then
        local gameTools = self._baseGameScene:getTools()
        if gameTools and gameTools:isQuitBtnEnabled() then
            print("req 7")
            self._baseGameConnect:gc_LeaveGame()
        end
    else
        print("step 8")
        if(self._dispatch)then
            self._dispatch:quit()
        end

        if (self:isTeamGameRoom() and self:isHallEntery()) or
        (self:isCharteredRoom() and not self:isRandomRoom()) then
            cc.exports.isAutogotoCharteredRoom = true
        end

        self:gotoHallScene()
    end
end

function BaseGameController:quitDirect()
    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox and safeBox:isVisible() then
        safeBox:showSafeBox(false)
        --return
    end

    local setting = self._baseGameScene:getSetting()
    if setting and setting:isVisible() then
        setting:showSetting(false)
        --return
    end

    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() then
        chat:showChat(false)
        --return
    end

    if self:isConnected() and self._baseGameConnect then
        local gameTools = self._baseGameScene:getTools()
        if gameTools and gameTools:isQuitBtnEnabled() then
            self:setResponse(self:getResWaitingNothing())
            self._baseGameConnect:gc_LeaveGame()
        end
    else
        if(self._dispatch)then
            self._dispatch:quit()
        end
        self:gotoHallScene()
    end
end

function BaseGameController:onSetting()
    local setting = self._baseGameScene:getSetting()
    if setting then
        setting:showSetting(true)
    end

    --测试代码
    --[[local tcyFriendPluginWrapper = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()
    tcyFriendPluginWrapper:testInvitation()]]--
end

function BaseGameController:onAutoPlay()
    local autoPlayPanel = self._baseGameScene:getAutoPlayPanel()
    if autoPlayPanel then
        if self:isGameRunning() then
            self._bAutoPlay = not self._bAutoPlay
        end
        autoPlayPanel:setVisible(self._bAutoPlay)
    end
end

function BaseGameController:ope_AutoPlay(bAutoPlay)
    self._bAutoPlay = bAutoPlay
    local autoPlayPanel = self._baseGameScene:getAutoPlayPanel()
    if autoPlayPanel then
        autoPlayPanel:setVisible(self._bAutoPlay)
    end
end

function BaseGameController:isAutoPlay()
    return self._bAutoPlay
end

function BaseGameController:clockStep(dt)
--    if self:isAutoPlay() then
--        self:autoPlay()
--    end
end

function BaseGameController:autoPlay()
end

function BaseGameController:onSafeBox()
    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox then
        safeBox:showSafeBox(true)
        if self._baseGamePlayerInfoManager then
            local gameDeposit = self._baseGamePlayerInfoManager:getSelfDeposit()
            if gameDeposit then
                safeBox:setGameDeposit(gameDeposit)
            end
        end
        self:onUpdateSafeBox()
    end
end

function BaseGameController:onChat()
    local chat = self._baseGameScene:getChat()
    if chat then
        chat:showChat(true)
    end
end

function BaseGameController:onChatSend(content)
    if 0 < string.len(content) and 250 > string.len(content) then
        if self._baseGameConnect then
            self._baseGameConnect:gc_ChatToTable(content)
        end
        --self:tipChatContent(self:getMyDrawIndex(), content)
    end
end

function BaseGameController:onSocketClose()
    self:onSocketError()
end

function BaseGameController:onSocketGracefullyError()
    self:onSocketError()
end

function BaseGameController:onSocketError()
    self._isConnected = false

    if self:isTeamGameRoom() and self:isHallEntery() then
        self:setGameOffline()
    end

    if self:isGameRunning() then
        self:reconnect()
    else
        local okCallback = function()
            self:gotoHallScene()
        end
        local msg = self:getGameStringByKey("G_DISCONNECTION_NOPLAYING")
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        self:popSureDialog(utf8Msg, "", "", okCallback, false)
    end
end

function BaseGameController:onTimeOut()
    if self:isTeamGameRoom() and self:isHallEntery() then
        self:setGameOffline()
    end

    local okCallback = function()
        self:gotoHallScene()
    end
    local content = self:getGameStringByKey("G_NETWORKSPEED_SLOW")
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    if(cc.exports.inTickoff==true)then
        return
    end
    self:popSureDialog(utf8Content, "", "", okCallback, false)
end

function BaseGameController:reconnect()
    --[[if self._connectTimes >= 2 then
        self:reconnectionFailed()
    else
        --self:onSocketError()
        self:reconnection(self._connectTimes)

        self._connectTimes = self._connectTimes + 1
    end]]
    cc.exports.inTickoff=false
    self:onTimeOut() --不走重连了  直接踢人
end

function BaseGameController:onSocketConnect()
    -- common proxy begin
    if self._proxyConnect then
        local UR_CONNECT_SERVER = 0 + 110
        self._baseGameConnect:sendRequest(UR_CONNECT_SERVER, self._connectSvrStr, self._connectSvrStr:len(), false)
    end
    -- common proxy end
    
    self._isResume = false
    self._session = -1
    self._connectTimes = 0
    self:setResponse(self:getResWaitingNothing())
    self._isConnected = true

    self:sendGamePulse()

    if self:isRandomRoom() then
        my.scheduleOnce(function()
            if self._baseGameConnect then
                self._baseGameConnect:gc_CheckVersion()
            end
        end,3.0)
    else
        if self._baseGameConnect then
            self._baseGameConnect:gc_CheckVersion()
        end    
    end
end

function BaseGameController:reconnection(connectTimes)
    if 0 == connectTimes then
        local loadingLayer = self._baseGameScene:getLoadingLayer()
        if loadingLayer and loadingLayer:isVisible() then
            
        else
            --self:tipMessageByKey("G_RECONNECTING")
        end
    end

    if self._baseGameNetworkClient then
        self._baseGameNetworkClient:reconnection()
    end
end

function BaseGameController:reconnectionFailed()
    if self:isTeamGameRoom() and self:isHallEntery() then
        self:setGameOffline()
    end

    local loadingLayer = self._baseGameScene:getLoadingLayer()
    if loadingLayer and loadingLayer:isVisible() then
        self:tipMessageByKey("G_CANNOTCONNECT")
    else
        local okCallback = function()
            self:gotoHallScene()
        end
        local msg = self:getGameStringByKey("G_DISCONNECTION")
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        self:popSureDialog(utf8Msg, "", "", okCallback, false)
    end
end

function BaseGameController:sendGamePulse()
    local function onPulseInterval(dt)
        if self._baseGameConnect then
            self._baseGameConnect:gc_SendGamePulse()
        end
    end
    self:stopGamePluse()
    self.pulseTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onPulseInterval, 60.0, false)
end

function BaseGameController:stopGamePluse()
    if self.pulseTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.pulseTimerID)
        self.pulseTimerID = nil
    end
end

--function BaseGameController:onCheckVersion(data)
--    local versionInfo = nil
--    if self._baseGameData then
--        versionInfo = self._baseGameData:getCheckVersionInfo(data)
--    end
--
--    if versionInfo then
--        local gameVersion = PublicInterface.GetGameVersion()
--        local splitArray = self:split(gameVersion, ".")
--
--        local bEnterGame = false
--        if #splitArray == 3 then
--            if tonumber(splitArray[1]) == versionInfo.nMajorVer and tonumber(splitArray[2]) == versionInfo.nMinorVer then
--                if self._baseGameConnect then
--                    self._baseGameConnect:gc_EnterGame()
--                    bEnterGame = true
--                end
--            end
--        end
--
--        if not bEnterGame then
--            PublicInterface.GoBackToMainSceneWithVersion()
--        end
--    end
--end

function BaseGameController:onCheckVersion()
    if self._baseGameConnect then
        self._baseGameConnect:gc_EnterGame()
    end
end

function BaseGameController:onCheckVersionOld()
    PublicInterface.GoBackToMainSceneWithVersion()
end

function BaseGameController:onCheckVersionNew()
    local loadingLayer = self._baseGameScene:getLoadingLayer()
    if loadingLayer and loadingLayer:isVisible() then
        self:tipMessageByKey("G_CHECKVERSION_NEW")
    else
        local okCallback = function()
            self:gotoHallScene()
        end
        local msg = self:getGameStringByKey("G_CHECKVERSION_NEW")
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        self:popSureDialog(utf8Msg, "", "", okCallback, false)
    end
end

function BaseGameController:split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

function BaseGameController:onEnterGameOK(data)
    self:setDXXW(false)
    self:setResume(false)

    local loadingNode = self._baseGameScene:getLoadingNode()
    if loadingNode then
        loadingNode:onEnterGameOK()
    end

    local gameEnterInfo = nil
    local soloPlayers = nil
    if self._baseGameData then
        gameEnterInfo, soloPlayers = self._baseGameData:getEnterGameOKInfo(data)
    end

    if soloPlayers then
        for i = 1, #soloPlayers do
            self:setSoloPlayer(soloPlayers[i])
        end
    end

    self:getSelfPortrait()
    self:sendSyncInfo()
    if(self._dispatch)then
        self._dispatch:onEnterGameOK(gameEnterInfo, soloPlayers)
    else
        local charteredRoom = require("src.app.Game.mBaseGame.BaseGameCharteredRoom.CharteredRoom")
        charteredRoom:getSelfHeadImage()
    end

    if gameEnterInfo then
        for i = 1, self:getTableChairCount() do
            if self:IS_BIT_SET(gameEnterInfo.dwUserStatus[i], BaseGameDef.BASEGAME_US_GAME_STARTED) then
                local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
                if 0 < drawIndex then
                    self:showPlayerReady(drawIndex)
                end
            end
        end
    end

    self:ope_ShowStart(true)
    if self:isRandomRoom() then
        self:showWaitArrangeTable(true)

        local gameTools = self._baseGameScene:getTools()
        if gameTools then
            gameTools:onEnterRandomGame()
        end
    end

    if self:isArenaPlayer() then 
        self:setArenaInfoView()
        self:showArenaInfo()
    end

    return gameEnterInfo, soloPlayers
end

function BaseGameController:onGameStart(data)
    self:gameRun()

    if self:isArenaPlayer() then 
        local arenaInfoManager = self:getArenaInfoManager()
        arenaInfoManager:addBout()
        local bout = arenaInfoManager:getBout()
        local arenaInfo = self._baseGameScene:getArenaInfo()
        arenaInfo:runStartAction(bout)
        self:showArenaInfo()
    end

    if self._dispatch then
        self._dispatch:setStartMatch(false)
    end
    self:onGameStartForCharteredRoom(data)
end

function BaseGameController:onEnterGameDXXW(data)
    self:setDXXW(true)
    self:setResume(false)
    self:gameRun()

    self:onDXXW()

    self:sendSyncInfo()
    local loadingNode = self._baseGameScene:getLoadingNode()
    if loadingNode then
        loadingNode:onEnterGameOK()
    end

    if self:isArenaPlayer() then 
        self:setArenaInfoView()
        self:showArenaInfo()
    end
end

function BaseGameController:onEnterGameIDLE(data)
    self:setDXXW(false)
    self:setResume(false)
    self:gameRun()

    local loadingNode = self._baseGameScene:getLoadingNode()
    if loadingNode then
        loadingNode:onEnterGameOK()
    end
end

function BaseGameController:onDXXW()
    if(self._dispatch)then      
        local data = {}
        local no = self:getTableChairCount()
        for i=1,no do
            local info = self._baseGamePlayerInfoManager:getPlayerInfo(i)
            if(info==nil)then
                break
            else
                table.insert(data,info)
            end
        end
        self._dispatch:onDXXW(data)
    end
end

function BaseGameController:onLeaveGameOK()
    local charteredRoom = self._baseGameScene:getCharteredRoom()
    if charteredRoom then
        charteredRoom:quit()
    end

    if (self:isTeamGameRoom() and self:isHallEntery()) or
        (self:isCharteredRoom() and not self:isRandomRoom()) then
            cc.exports.isAutogotoCharteredRoom = true
        end

    self:gotoHallScene()

    if self._gotoHighRoom then
        self._gotoHighRoom = false
        --[[local MainCtrl          = require('src.app.plugins.mainpanel.MainCtrl')
        MainCtrl:quickStartBtClicked(nil)]]--
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end
end

function BaseGameController:onRoomTableChairMismatch()
    self:getFinished()
    self:hardIDMismatch()
end

function BaseGameController:onHardIDMismatch()
    self:hardIDMismatch()
end

function BaseGameController:onTeamRoomMatched()
    if self:isTeamGameRoom() and self:isHallEntery() then
        self:setGameOffline()
        self:sendUpSeat()
    end

    self:disconnect()

    local content = self:getGameStringByKey("G_ENTERGAME_TEAMROOMMATCHED")
    local okCallback = function()
        self:gotoHallScene()
        cc.exports.isAutogotoCharteredRoom = true
    end
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    local function pop()
        if self:isInGameScene() == false then return end
        self:popSureDialog(utf8Content, "", "", okCallback, false)
    end
    my.scheduleOnce(pop, 1)
end

function BaseGameController:hardIDMismatch()
    if self:isTeamGameRoom() and self:isHallEntery() then
        self:setGameOffline()
    end

    self:disconnect()

    local content = self:getGameStringByKey("G_ENTERGAME_HARDIDMISMATCH")
    local okCallback = function()
        self:gotoHallScene()
    end
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    local function pop()
        if self:isInGameScene() == false then return end
        self:popSureDialog(utf8Content, "", "", okCallback, false)
    end
    my.scheduleOnce(pop, 1)
end

function BaseGameController:onAllStandBy(data)
end

function BaseGameController:onGameAbort(data)
    local gameAbortInfo = nil
    if self._baseGameData then
        gameAbortInfo = self._baseGameData:getGameAbortInfo(data)
    end
    if gameAbortInfo then
        if self:getMyDrawIndex() ~= self:rul_GetDrawIndexByChairNO(gameAbortInfo.nChairNO) then
            self:gameStop()
            self:disconnect()

            local content = ""
            local userName = self:getPlayerUserNameByUserID(gameAbortInfo.nUserID)
            if gameAbortInfo.bForce then
                content = string.format(self:getGameStringByKey("G_GAMEABORT_FORCE_DEPOSIT"), userName, gameAbortInfo.nDepositDfif)
            else
                content = string.format(self:getGameStringByKey("G_GAMEABORT"), userName)
            end
            local okCallback = function()
                if(self._dispatch)then
                    cc.exports.hasStartGame=false
                    if self:isTeamGameRoom() then
                        self:gotoHallScene()
                    else
                        self._dispatch:ResetInterfaceAfterGameEnd()
                    end
                else
                    self:gotoHallScene()
                end
            end
            local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
            self:popSureDialog(utf8Content, "", "", okCallback, false)
        end
    end
end

function BaseGameController:onLeaveGamePlaying()
    self:onLeaveGameFailed()
end

function BaseGameController:onGameTooFast(data)
    self:onLeaveGameFailed()

    local leaveGameTooFast = nil
    if self._baseGameData then
        leaveGameTooFast = self._baseGameData:getLeaveGameTooFastInfo(data)
    end
    if leaveGameTooFast then
        local msg = string.format(self:getGameStringByKey("G_NEED_WAIT_FOR_RANDOM"), leaveGameTooFast.nSecond)
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        self:popSureDialog(utf8Msg, "", "", function()end, false)
    end
end

function BaseGameController:onChatToTable(data)
    local chatToTable = nil
    if self._baseGameData then
        chatToTable = self._baseGameData:getChatToTableInfo(data)
    end
    if chatToTable then
    end
end

function BaseGameController:onChatFromTable(data)
    local chatFromTable = nil
    local chatMsg = nil
    if self._baseGameData then
        chatFromTable, chatMsg = self._baseGameData:getChatFromTableInfo(data)
    end
    if chatFromTable then
        local tableChatContent = chatMsg
        local contentBegin = string.find(chatMsg, ">")
        if contentBegin then
            tableChatContent = string.sub(chatMsg, contentBegin + 1, 128)
        end

        local contentEnd = string.find(tableChatContent, "\r")
        if contentEnd then
            tableChatContent = string.sub(tableChatContent, 1, contentEnd - 1)
        end

        if chatFromTable.dwFlags == BaseGameDef.BASEGAME_FLAG_CHAT_SYSNOTIFY then
            self:tipMessageByGBStr(tableChatContent)
        elseif chatFromTable.dwFlags == BaseGameDef.BASEGAME_FLAG_CHAT_PLAYERMSG then
            local chatPlayerInfo = self._baseGamePlayerInfoManager:getPlayerInfoByUserID(chatFromTable.nUserID)
            if chatPlayerInfo then
                local drawIndex = self:rul_GetDrawIndexByChairNO(chatPlayerInfo.nChairNO)
                if 0 < drawIndex then
                    self:tipChatContent(drawIndex, tableChatContent)
                end
            end
            if(self._dispatch)then
                local utf8Content = MCCharset:getInstance():gb2Utf8String(tableChatContent, string.len(tableChatContent))
                self._dispatch:onSomeOneTalked(chatFromTable,utf8Content)
            end
        end
    end

end

function BaseGameController:onPlayerAbort(data)
    print("onPlayerAbort")
    if self:isGameRunning() then
        return
    end

    if self._isShieldVoice then
        self:startPlayerAbortTimer()
    else
        self:resetResume()
    end

    local gameAbort = nil
    if self._baseGameData then
        gameAbort = self._baseGameData:getPlayerAbortInfo(data)
    end
    dump(gameAbort, "gameAbort")
    if(self._dispatch)then
        self._dispatch:onPlayerAbort(gameAbort)
    end

    if gameAbort and self._baseGamePlayerInfoManager then
        if gameAbort.nUserID == self._baseGamePlayerInfoManager:getSelfUserID() then
            print("abort 1")
            return
        end

        local abortPlayerInfo = self._baseGamePlayerInfoManager:getPlayerInfoByUserID(gameAbort.nUserID)
        if abortPlayerInfo then
            if abortPlayerInfo.nTableNO ~= gameAbort.nTableNO then
                print("abort 2")
                return
            end

            if abortPlayerInfo.nChairNO ~= gameAbort.nChairNO then
                print("abort 3")
                return
            end

            if abortPlayerInfo.bLookOn then
                print("abort 4")
                return
            end
        end

        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            local drawIndex = self:rul_GetDrawIndexByChairNO(gameAbort.nChairNO)
            if 0 < drawIndex then
                if playerManager:isPlayerEnter(drawIndex) then
                    self:playerAbort(drawIndex)
                end
            end
        end

        if self._baseGameUtilsInfoManager then
            local currentTablePlayerCount = math.max(self._baseGameUtilsInfoManager:getTablePlayerCount() - 1, 0)
            self._baseGameUtilsInfoManager:setTablePlayerCount(currentTablePlayerCount)
        end

        if self._baseGamePlayerInfoManager then
            local drawIndex = self:rul_GetDrawIndexByChairNO(gameAbort.nChairNO)
            if 0 < drawIndex then
                self._baseGamePlayerInfoManager:playerAbort(drawIndex)
            end
        end
    end
end

function BaseGameController:onPlayerEnter(data)
    if self:isGameRunning() then
        return
    end

    local soloPlayer = nil
    if self._baseGameData then
        soloPlayer = self._baseGameData:getPlayerEnterInfo(data)
    end

    if not soloPlayer or soloPlayer.nUserID <= 0 then
        return
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        local drawIndex = self:rul_GetDrawIndexByChairNO(soloPlayer.nChairNO)
        if not playerManager:isPlayerEnter(drawIndex) then
            if self._baseGameUtilsInfoManager then
                local currentTablePlayerCount = math.min(self._baseGameUtilsInfoManager:getTablePlayerCount() + 1, self:getTableChairCount())
                self._baseGameUtilsInfoManager:setTablePlayerCount(currentTablePlayerCount)
            end
        end
    end

    self:setSoloPlayer(soloPlayer)

    if(self._dispatch)then
        self._dispatch:onPlayerEnter(soloPlayer)
    end
end

function BaseGameController:onDepositNotEnough(data)
    local depositNotEnough = nil
    if self._baseGameData then
        depositNotEnough = self._baseGameData:getDepositNotEnoughInfo(data)
    end

    if not depositNotEnough or depositNotEnough.nUserID <= 0 then
        return
    end

    local userName = self:getPlayerUserNameByUserID(depositNotEnough.nUserID)
    local msg = string.format(self:getGameStringByKey("G_DEPOSIT_NOTENOUGH"), userName)
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", function()end, false)
end

function BaseGameController:onScoreNotEnough(data)
    local scoreNotEnough = nil
    if self._baseGameData then
        scoreNotEnough = self._baseGameData:getScoreNotEnoughInfo(data)
    end

    if not scoreNotEnough or scoreNotEnough.nUserID <= 0 then
        return
    end

    local userName = self:getPlayerUserNameByUserID(scoreNotEnough.nUserID)
    local msg = string.format(self:getGameStringByKey("G_SCORE_NOTENOUGH"), userName)
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", function()end, false)
end

function BaseGameController:onScoreTooHigh(data)
    local scoreTooHigh = nil
    if self._baseGameData then
        scoreTooHigh = self._baseGameData:getScoreTooHighInfo(data)
    end

    if not scoreTooHigh or scoreTooHigh.nUserID <= 0 then
        return
    end

    local userName = self:getPlayerUserNameByUserID(scoreTooHigh.nUserID)
    local msg = string.format(self:getGameStringByKey("G_SCORE_TOOHIGH"), userName)
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", function()end, false)
end

function BaseGameController:onUserBoutTooHigh(data)
    local userBoutTooHigh = nil
    if self._baseGameData then
        userBoutTooHigh = self._baseGameData:getUserBoutTooHighInfo(data)
    end

    if not userBoutTooHigh or userBoutTooHigh.nUserID <= 0 then
        return
    end

    local userName = self:getPlayerUserNameByUserID(userBoutTooHigh.nUserID)
    local msg = string.format(self:getGameStringByKey("G_USERBOUT_TOOHIGH"), userName, userBoutTooHigh.nMaxBout)
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", function()end, false)
end

function BaseGameController:onTableBoutTooHigh(data)
    local tableBoutTooHigh = nil
    if self._baseGameData then
        tableBoutTooHigh = self._baseGameData:getTableBoutTooHighInfo(data)
    end

    if not tableBoutTooHigh then
        return
    end

    local msg = string.format(self:getGameStringByKey("G_TABLEBOUT_TOOHIGH"), tableBoutTooHigh.nMaxBout)
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", function()end, false)
end

function BaseGameController:onStartSoloTable(data)
    local soloTable = nil
    local soloPlayers = nil
    local startInfo = nil
    local chairNO = 0
    if self._baseGameData then
        soloTable, soloPlayers, startInfo = self._baseGameData:getSoloTableInfo(data)
    end

    if soloTable then
        if self._baseGameUtilsInfoManager then
            self._baseGameUtilsInfoManager:setTablePlayerCount(soloTable.nUserCount)
        end

        if self._baseGamePlayerInfoManager then
            self._baseGamePlayerInfoManager:setSelfTableNO(soloTable.nTableNO)
            local selfChairNO = 0
            for i = 1, soloTable.nUserCount do
                if self._baseGamePlayerInfoManager:getSelfUserID() == soloTable.nUserIDs[i] then
                    self._baseGamePlayerInfoManager:setSelfChairNO(i - 1)
                end
            end

            self._baseGamePlayerInfoManager:clearPlayersInfo()
        end

        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:clearPlayers()
        end
        if soloPlayers then
            for i = 1, soloTable.nUserCount do
                soloPlayers[i].lbs = self._playerLbs[soloPlayers[i].nUserID]
                soloPlayers[i].lbs = self._playerHead[soloPlayers[i].nUserID]
                self:setSoloPlayer(soloPlayers[i])
            end
        end
    end

    if startInfo then
        --if self:isResume() then --修改切后台返回的问题
        if self._isShieldVoice then
            self:GameStartDataOut(startInfo)
        else
            self:onGameStartSolo(startInfo)
        end
    end

    if self._dispatch then
        self._dispatch:onStartSoloTable(soloPlayers)
    end

    self:sendSyncInfo()
    cc.exports.hasStartGame=true
end

function BaseGameController:onGameStartSolo(data)end

function BaseGameController:onUserDepositEvent(data)
    local userDepositEvent = nil
    if self._baseGameData then
        userDepositEvent = self._baseGameData:getUserDepositEventInfo(data)
    end

    if userDepositEvent then
        if userDepositEvent.nChairNO ~= self:getMyChairNO() and userDepositEvent.nEvent ~= BaseGameDef.BASEGAME_USER_LOOK_SAFE_DEPOSIT then
            local drawIndex = self:rul_GetDrawIndexByChairNO(userDepositEvent.nChairNO)
            if 0 < drawIndex then
                self:setPlayerDeposit(drawIndex, userDepositEvent.nDeposit)
            end
        end
    end
end

function BaseGameController:onUserPosition(data)
    local userPos = nil
    local soloPlayers = nil
    if self._baseGameData then
        userPos, soloPlayers = self._baseGameData:getUserPosInfo(data)
    end

    if userPos then
        self:clearGameTable()

        if self._baseGameUtilsInfoManager then
            self._baseGameUtilsInfoManager:setTablePlayerCount(userPos.nPlayerCount)
        end

        if self._baseGamePlayerInfoManager then
            self._baseGamePlayerInfoManager:setSelfTableNO(userPos.nTableNO)
            self._baseGamePlayerInfoManager:setSelfChairNO(userPos.nChairNO)

            self._baseGamePlayerInfoManager:clearPlayersInfo()
        end

        if not self:isCharteredRoom() then
            local msg = string.format(self:getGameStringByKey("G_CHANGETABLE_OK"), userPos.nTableNO + 1)
            self:tipMessageByGBStr(msg)
        end

        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:clearPlayers()
        end
        if soloPlayers then
            for i = 1, userPos.nPlayerCount do
                self:setSoloPlayer(soloPlayers[i])
            end
        end
        if self:isTeamGameRoom() and self._dispatch then
            self:sendSyncInfo()
            self._dispatch:onUserPosition(soloPlayers)
        end

        for i = 1, self:getTableChairCount() do
            if self:IS_BIT_SET(userPos.dwUserStatus[i], BaseGameDef.BASEGAME_US_GAME_STARTED) then
                local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
                if 0 < drawIndex then
                    self:showPlayerReady(drawIndex)
                end
            end
        end

        local gameStart = self._baseGameScene:getStart()
        if gameStart then
            gameStart:onUserPosition()
        end
        local selfInfo = self._baseGameScene:getSelfInfo()
        if selfInfo then
            selfInfo:showSelfReady(false)
        end
    end
end

function BaseGameController:rspStartGame()
    if self:isGameRunning() then
        return
    end
    if(self._dispatch and self:isVisibleCharteredRoom() )then
       self._dispatch:rspStartGame()
    end

    local gameStart = self._baseGameScene:getStart()
    if gameStart then
        gameStart:rspStartGame()
    end

    self:clearGameTable()

    if not self:isWaitArrangeTableShow() then
        self:showPlayerReady(self:getMyDrawIndex())
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        if(gameTools.disableSafeBox)then
            gameTools:disableSafeBox()
        end
    end
end

function BaseGameController:onCancelTeamMatchOK(data)
    local hostID = nil
    if self._baseGameData then
        hostID = self._baseGameData:onGetCancelTeamMatchOKInfo(data)
    end

    if(self._dispatch)then
       self._dispatch:onCancelTeamMatchOK(hostID)
    end
end

function BaseGameController:ope_GameStart()
    self:ope_ShowStart(false)
end

function BaseGameController:clearGameTable()
--    local selfInfo = self._baseGameScene:getSelfInfo()
--    if selfInfo then
--        selfInfo:showSelfReady(false)
--    end
end

function BaseGameController:onLookSafeDeposit(data)
    local safeBoxDeposit = nil
    if self._baseGameData then
        safeBoxDeposit = self._baseGameData:getSafeBoxDepositInfo(data)
    end

    if safeBoxDeposit then
        local safeBox = self._baseGameScene:getSafeBox()
        if safeBox then
            safeBox:onLookSafeDeposit(safeBoxDeposit.nDeposit, 0 < safeBoxDeposit.bHaveSecurePwd)
        end
    end
end

function BaseGameController:onTakeSafeDeposit()
    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox then
        local takeDeposit = safeBox:getTransferDeposit()
        self:addPlayerDeposit(self:getMyDrawIndex(), takeDeposit)

        safeBox:onTakeSafeDepositSucceed()

        self:tipMessageByKey("G_SAFEBOX_TAKESUCCEED")
    end
end

function BaseGameController:onSaveSafeDeposit()
    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox then
        local saveDeposit = safeBox:getTransferDeposit()
        self:addPlayerDeposit(self:getMyDrawIndex(), -saveDeposit)

        safeBox:onSaveSafeDepositSucceed()

        self:tipMessageByKey("G_SAFEBOX_SAVESUCCEED")
    end
end

function BaseGameController:onTakeSafeRndkey(data)
    local safeRndKey = nil
    if self._baseGameData then
        safeRndKey = self._baseGameData:getRndKeyInfo(data)
    end

    if safeRndKey then
        local safeBox = self._baseGameScene:getSafeBox()
        if safeBox then
            safeBox:onTakeSafeRndkey(safeRndKey.nRndKey)
        end
    end
end

function BaseGameController:onSafeBoxFailed(request, response, data)
    local msg = self:getGameStringByKey("G_SAFEBOX_OPERATE_FAILD")

    local switchAction = {
        [BaseGameDef.BASEGAME_GR_SERVICE_BUSY]          = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_SERVICE_BUSY")
        end,
        [BaseGameDef.BASEGAME_GR_DEPOSIT_NOTENOUGH]     = function(msg)
            if BaseGameDef.BASEGAME_WAITING_SAVE_SAFE_DEPOSIT == response then
                return self:getGameStringByKey("G_SAFEBOX_SAVE_NOTENOUGH")
            elseif BaseGameDef.BASEGAME_WAITING_TAKE_SAFE_DEPOSIT == response then
                return self:getGameStringByKey("G_SAFEBOX_TAKE_NOTENOUGH")
            end
            return msg
        end,
        [BaseGameDef.BASEGAME_GR_NO_THIS_FUNCTION]      = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_NO_THIS_FUNCTION")
        end,
        [BaseGameDef.BASEGAME_GR_SYSTEM_LOCKED]         = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_SYSTEM_LOCKED")
        end,
        [BaseGameDef.BASEGAME_GR_TOKENID_MISMATCH]      = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_TOKENID_MISMATCH")
        end,
        [BaseGameDef.BASEGAME_GR_HARDID_MISMATCHEX]     = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_HARDID_MISMATCHEX")
        end,
        [BaseGameDef.BASEGAME_GR_CONTINUE_PWDWRONG]     = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_CONTINUE_SECUREPWDERROR_TAKEDEPOSIT")
        end,
        [BaseGameDef.BASEGAME_GR_ERROR_INFOMATION] = function(msg)
            return msg
        end,
        [BaseGameDef.BASEGAME_GR_PWDLEN_INVALID]        = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_PWDLEN_INVALID")
        end,
        [BaseGameDef.BASEGAME_GR_NEED_LOGON]            = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_NEED_LOGON")
        end,
        [BaseGameDef.BASEGAME_GR_ROOM_NOT_EXIST]        = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_ROOM_NOT_EXIST")
        end,
        [BaseGameDef.BASEGAME_GR_NODEPOSIT_GAME]        = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_NODEPOSIT_GAME")
        end,
        [BaseGameDef.BASEGAME_GR_ROOM_CLOSED]           = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_ROOM_CLOSED")
        end,
        [BaseGameDef.BASEGAME_GR_BOUT_NOTENOUGH]        = function(msg)
            local _, bout = string.unpack(data, '<i')
            return string.format(self:getGameStringByKey("G_SAFEBOX_OUTPUT_BOUT_NOTENOUGH"), bout)
        end,
        [BaseGameDef.BASEGAME_GR_TIMECOST_NOTENOUGH]    = function(msg)
            local _, minute = string.unpack(data, '<i')
            return string.format(self:getGameStringByKey("G_SAFEBOX_OUTPUT_TIMECOST_NOTENOUGH"), minute)
        end,
        [BaseGameDef.BASEGAME_GR_ROOM_NOT_OPENED]       = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_ROOM_NOT_OPENED")
        end,
        [BaseGameDef.BASEGAME_GR_NEED_PLAYING]          = function(msg)
            return msg
        end,
        [BaseGameDef.BASEGAME_GR_NO_MOBILEUSER]         = function(msg)
            return msg
        end,
        [BaseGameDef.BASEGAME_GR_INPUTLIMIT_DAILY]      = function(msg)
            local _, nTransferTotal, nTransferLimit = string.unpack(data, '<ii')
            if 0 < nTransferTotal - nTransferLimit then
                return string.format(self:getGameStringByKey("G_SAFEBOX_INPUTLIMIT_DAILY"), nTransferLimit, nTransferTotal - nTransferLimit)
            else
                return string.format(self:getGameStringByKey("G_SAFEBOX_INPUTLIMIT_TOMORROW"), nTransferLimit)
            end
        end,
        [BaseGameDef.BASEGAME_GR_KEEPDEPOSIT_LIMIT]     = function(msg)
            local _, nGameDeposit, nKeepDeposit = string.unpack(data, '<ii')
        end,
        [BaseGameDef.BASEGAME_GR_INPUTLIMIT_MONTHLY]    = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_INPUTLIMIT_MONTHLY")
        end,
        [BaseGameDef.BASEGAME_GR_USER_FORBIDDEN]        = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_USER_FORBIDDEN")
        end,
        [BaseGameDef.BASEGAME_GR_SAFEBOX_GAME_READY]    = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_GAME_USER_START")
        end,
        [BaseGameDef.BASEGAME_GR_SAFEBOX_GAME_PLAYING]  = function(msg)
            return self:getGameStringByKey("G_SAFEBOX_PLAYING_GAME_NOTTRANS")
        end,
        [BaseGameDef.BASEGAME_GR_SAFEBOX_DEPOSIT_MIN]   = function(msg)
            if self._baseGameUtilsInfoManager then
                return string.format(self:getGameStringByKey("G_SAFEBOX_MIN_DEPOSIT"), self._baseGameUtilsInfoManager:getRoomMinDeposit())
            else
                return msg
            end
        end,
        [BaseGameDef.BASEGAME_GR_SAFEBOX_DEPOSIT_MAX]   = function(msg)
            if self._baseGameUtilsInfoManager then
                return string.format(self:getGameStringByKey("G_SAFEBOX_MAX_DEPOSIT"), self._baseGameUtilsInfoManager:getRoomMaxDeposit())
            else
                return msg
            end
        end,
    }

    if switchAction[request] then
        msg = switchAction[request](msg)
    end
    self:tipMessageByGBStr(msg)
end

function BaseGameController:onWaitNewTable()
    self:clearGameTable()

    self:clearPlayerReady()

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showSelfReady(false)
    end
    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:disableSafeBox()
    end

    self:showWaitArrangeTable(true)
end

function BaseGameController:onGetTableInfo(data)
    self:parseGameTableInfoData(data)

    self:setResume(false)
    self:onDXXW()
end

function BaseGameController:parseGameTableInfoData(data)end

function BaseGameController:onGetTableInfoFailed()
    self:stopGetTableDataResponseTimer()
    
    self:setResume(false)

    if ignoreGetTableFailed then
        print('get table info failed, but this messgage has been ingore')
        ignoreGetTableFailed = false
        return
    end
    if self:isTeamGameRoom() and self:isHallEntery() then
        self:setGameOffline()
    end

    self:disconnect()

    local okCallback = function()
        self:gotoHallScene()
    end
    local content = self:getGameStringByKey("G_NETWORKSPEED_SLOW")
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    if(cc.exports.inTickoff==true)then
        return
    end
    self:popSureDialog(utf8Content, "", "", okCallback, false)
end

function BaseGameController:onPlayerStartGame(data)
    if not self._baseGameScene then return end
    if self:isGameRunning() then
        return
    end
    local playerStartGame = nil
    if self._baseGameData then
        playerStartGame = self._baseGameData:getPlayerStartGameInfo(data)
    end

    if(self._dispatch and (self:isVisibleCharteredRoom() or self._canReturnChartered) )then
        self._dispatch:onPlayerStartGame(playerStartGame)
    end

 
    if playerStartGame then
        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            -- local Team2V2Model = import('src.app.plugins.Team2V2Model.Team2V2Model'):getInstance()
            -- if Team2V2Model and Team2V2Model:isSelfLeader() then
            --     local teamInfo = Team2V2Model:getTeamInfo()
            --     if teamInfo.mateUserID == playerStartGame.nUserID then
            --         -- 队友已准备 队长发起匹配
                    self:onStartGame()
            --     end
            -- end
            local boutCount = self._baseGameUtilsInfoManager:getBoutCount()
            if boutCount and boutCount > 0 then
                local playerManager = self._baseGameScene:getPlayerManager()
                if playerManager then
                    local drawIndex = self:rul_GetDrawIndexByChairNO(playerStartGame.nChairNO)
                    if 0 < drawIndex and drawIndex ~= self:getMyDrawIndex() then
                        self:showPlayerReady(drawIndex)
                    end
                end
            end
        else
            local playerManager = self._baseGameScene:getPlayerManager()
            if playerManager then
                local drawIndex = self:rul_GetDrawIndexByChairNO(playerStartGame.nChairNO)
                if 0 < drawIndex and drawIndex ~= self:getMyDrawIndex() then
                    self:showPlayerReady(drawIndex)
                end
            end
        end
    end
end

function BaseGameController:onEnterGameFailed()
    if self:isTeamGameRoom() and self:isHallEntery() then
        self:setGameOffline()
    end

    self:disconnect()

    local content = ""
    if self:isGameRunning() then
        content = self:getGameStringByKey("G_ENTERGAME_FAILED_PLAYING")
    else
        content = self:getGameStringByKey("G_ENTERGAME_FAILED")
    end

    local loadingNode = self._baseGameScene:getLoadingNode()
    if loadingNode then
        --loadingNode:stopLoadingTimer()
    end
    local okCallback = function()
        self:gotoHallScene()
    end
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    local function pop()
        if self:isInGameScene() == false then return end
        self:popSureDialog(utf8Content, "", "", okCallback, false)
    end
    my.scheduleOnce(pop, 1)
end

function BaseGameController:onLeaveGameFailed()
    local content = ""
    if self:isGameRunning() then
        content = self:getGameStringByKey("G_LEAVEGAME_FAILED_PLAYING")
        local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
        self:popSureDialog(utf8Content, "", "", function()end, false)
    else
        content = self:getGameStringByKey("G_LEAVEGAME_FAILED")
        self:tipMessageByGBStr(content)
    end
end

function BaseGameController:onStartTeamReadyFailed()
    if self:isTeamGameRoom() and self._dispatch then
        self._dispatch:onStartTeamReadyFailed()
    end
end

function BaseGameController:onStartFailedNotEnough(data)
    if not self._baseGameScene then return end

    local startFailedNotEnough = nil
    if self._baseGameData then
        startFailedNotEnough = self._baseGameData:getStartFailedNotEnoughInfo(data)
    end

    if startFailedNotEnough then
        local msg = string.format(self:getGameStringByKey("G_MOVEDEPOSIT_NOTENOUGH"),
            startFailedNotEnough.nMinDeposit - startFailedNotEnough.nDeposit)
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        local okCallback = function()
            self:onSafeBox()
        end
        self:popSureDialog(utf8Msg, "", "", okCallback, false)
    end
end

function BaseGameController:onStartFailedTooHigh(data)
    if not self._baseGameScene then return end

    local startFailedTooHigh = nil
    if self._baseGameData then
        startFailedTooHigh = self._baseGameData:getStartFailedTooHighInfo(data)
    end

    if startFailedTooHigh then
        local msg = string.format(self:getGameStringByKey("G_MOVEDEPOSIT_TOOHIGHT"),
            startFailedTooHigh.nDeposit - startFailedTooHigh.nMaxDeposit)
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        local okCallback = function()
            self:onSafeBox()
        end
        self:popSureDialog(utf8Msg, "", "", okCallback, false)
    end
end

function BaseGameController:onErrorInfoResponse(data)
    if data == nil then return end

    local msg = MCCharset:getInstance():gb2Utf8String(data, string.len(data))

    if 0 < string.len(msg) then
        self:tipMessageByUTF8Str(msg)
    end
end

function BaseGameController:onErrorInfoNotify(data)
    local msg = ''
    if self._baseGameData then
        local errorInfo = self._baseGameData:getErrorInfo(data)
        if errorInfo then
            msg = MCCharset:getInstance():gb2Utf8String(errorInfo.szMsg, string.len(errorInfo.szMsg))
        end
    end

    if 0 < string.len(msg) then
        self:tipMessageByUTF8Str(msg)
    end
end

function BaseGameController:gotoHallScene()
    --[[if self:isUserConvertSupported() then
        local userConvert = self:getUserConvertCtrl()
        if userConvert:isDlgShow() then
            return
        end
    end]]--

    if(cc.exports.inTickoff==true)then
        return
    end
    print("GoBackToMainScene")
    PublicInterface.GoBackToMainScene()
end

function BaseGameController:getGameStringByKey(key)
    if GamePublicInterface then
        return GamePublicInterface:getGameString(key)
    end
    return "" 
end

function BaseGameController:tipMessageByKey(key)
    local msg = self:getGameStringByKey(key)
    if msg then
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        self:tipMessageByUTF8Str(utf8Msg)
    end
end

function BaseGameController:tipMessageByUTF8Str(msg)
    if self._baseGameScene then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=msg,removeTime=2.5}})
    end
end

function BaseGameController:tipMessageByGBStr(msg)
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:tipMessageByUTF8Str(utf8Msg)
end

function BaseGameController:popChoseDialog(content, title, cancelTitle, cancelCallback, okTitle, okCallback, needCloseBtn)
    if self._baseGameScene then
        my.informPluginByName({
            pluginName="ChooseDialog",
            params={
                tipContent=content,
                tipTitle=title,
                cancelBtTitle=cancelTitle,
                onCancel=cancelCallback,
                okBtTitle=okTitle,
                onOk=okCallback,
                closeBtVisible=needCloseBtn
            }})
    end
end

function BaseGameController:popSureDialog(content, title, okTitle, okCallback, needCloseBtn)
    local isForbidKeyBack = false
    if needCloseBtn == false then
        isForbidKeyBack = true --不需要关闭按钮，则也禁止响应返回键
    end
    if self._baseGameScene then
        my.informPluginByName({
            pluginName="SureDialog",
            params = {
                tipContent=content,
                tipTitle=title,
                okBtTitle=okTitle,
                onOk=okCallback,
                closeBtVisible = needCloseBtn,
                forbidKeyBack = isForbidKeyBack
            }
        })
    end
end

function BaseGameController:onUpdateSafeBox()
    if self._baseGameConnect then
        self._baseGameConnect:gc_LookSafeDeposit()
    end
end

function BaseGameController:onSaveDeposit(deposit)
    print("BaseGameController:onSaveDeposit deposit "..tostring(deposit))
    if self:canTakeDepositInGame() then
        if self._baseGameConnect then
            local gameDeposit = 0
            if self._baseGamePlayerInfoManager then
                if gameDeposit and self._baseGamePlayerInfoManager then
                    gameDeposit = self._baseGamePlayerInfoManager:getSelfDeposit()
                end
            end
            print("gameDeposit "..tostring(gameDeposit))
            self._baseGameConnect:gc_SaveDeposit(deposit, gameDeposit)
        end
    else
        self:onSafeBoxFailed(BaseGameDef.BASEGAME_GR_NO_THIS_FUNCTION)
    end
end

function BaseGameController:onTakeDeposit(deposit, keyResult)
    if self:canTakeDepositInGame() then
        if self._baseGameConnect then
            local gameDeposit = 0
            if self._baseGamePlayerInfoManager then
                if gameDeposit and self._baseGamePlayerInfoManager then
                    gameDeposit = self._baseGamePlayerInfoManager:getSelfDeposit()
                end
            end
            self._baseGameConnect:gc_TakeDeposit(deposit, keyResult, gameDeposit)
        end
    else
        self:onSafeBoxFailed(BaseGameDef.BASEGAME_GR_NO_THIS_FUNCTION)
    end
end

function BaseGameController:onGetRndKey()
    if self._baseGameConnect then
        self._baseGameConnect:gc_TakeRndKey()
    end
end

function BaseGameController:canTakeDepositInGame()
    local needDeposit = false
    local takeDepositInGame = false
    if self._baseGameUtilsInfoManager then
        needDeposit = self:isNeedDeposit()
        takeDepositInGame = self:IS_BIT_SET(self._baseGameUtilsInfoManager:getRoomConfigs() ,BaseGameDef.BASEGAME_RC_TAKEDEPOSITINGAME)
    end
    return needDeposit and takeDepositInGame
end

function BaseGameController:isNeedDeposit()
    local bNeedDeposit = false
    if self._baseGameUtilsInfoManager then
        bNeedDeposit = self:IS_BIT_SET(self._baseGameUtilsInfoManager:getRoomOptions() ,BaseGameDef.BASEGAME_RO_NEED_DEPOSIT)
    end
    return bNeedDeposit
end

function BaseGameController:onNotifyAdminMsgToRoom(msg)
    self:tipMessageByGBStr(msg)
end

function BaseGameController:onNotifyKickedOffByAdmin()
    local okCallback = function()
        self:gotoHallScene()
    end
    local msg = self:getGameStringByKey("G_KICKOFFBYADMIN")
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", okCallback, false)
end

function BaseGameController:onNotifyKickedOffByLogonAgain()
    local okCallback = function()
        self:gotoHallScene()
    end
    local msg = self:getGameStringByKey("G_KICKOFFBYLOGONAGAIN")
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", okCallback, false)
end

function BaseGameController:onQuitFromRoom()
    local okCallback = function()
        if(self._dispatch)then
            self._dispatch:quit()
        end
        self:gotoHallScene()
    end
    local msg = self:getGameStringByKey("G_DISCONNECTION")
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", okCallback, false)
end

function BaseGameController:ope_ShowGameInfo(bShow)
    local gameInfo = self._baseGameScene:getGameInfo()
    if gameInfo then
        gameInfo:ope_ShowGameInfo(bShow)
    end
end

function BaseGameController:getFinished()
    local playerInfoManager = self:getPlayerInfoManager()
    local utilsInfoManager  = self:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local params = {
        nChairNO    = playerInfoManager:getSelfChairNO(),
        nGameID     = utilsInfoManager:getGameID(),
        nRoomID     = utilsInfoManager:getRoomID(),
        nAreaID     = utilsInfoManager:getAreaID(),
        nTableNO    = playerInfoManager:getSelfTableNO(),
        nUserID     = playerInfoManager:getSelfUserID(),
        szHardID    = utilsInfoManager:getHardID()
    }
    PublicInterface.GetFinished(params)
end

function BaseGameController:sendUpSeat()
    local playerInfoManager = self:getPlayerInfoManager()
    local utilsInfoManager  = self:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local params = {
        nChairNO    = playerInfoManager:getSelfChairNO(),
        nTableNO    = playerInfoManager:getSelfTableNO(),
        nUserID     = playerInfoManager:getSelfUserID()
    }
    PublicInterface.SendUpSeat(params)
end

function BaseGameController:playEffect(fileName)
    if self._isShieldVoice then
        return
    end
    local soundPath = "res/Game/GameSound/"
    audio.playSound(soundPath .. fileName)
end

function BaseGameController:playGamePublicSound(fileName)
    local soundPath = "PublicSound/"
    self:playEffect(soundPath .. fileName .. ".ogg")
end

function BaseGameController:playGamePublicEffect(fileName)
    local soundPath = "PublicSound/"
    self:playEffect(soundPath .. fileName .. ".mp3")
end

function BaseGameController:playBtnPressedEffect()
    self:playGamePublicEffect("KeypressStandard")
end

function BaseGameController:onClickPlayerHead(drawIndex)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onClickPlayerHead(drawIndex)
    end
end

function BaseGameController:getDepositLevel(deposit)
    local nlevel = 0
    if deposit >= 26214400 then
        nlevel = 20
    elseif deposit >= 13107200 then
        nlevel = 19
    elseif deposit >= 6553600 then
        nlevel = 18
    elseif deposit >= 3276800 then
        nlevel = 17
    elseif deposit >= 1638400 then
        nlevel = 16
    elseif deposit >= 819200 then
        nlevel = 15
    elseif deposit >= 409600 then
        nlevel = 14
    elseif deposit >= 204800 then
        nlevel = 13
    elseif deposit >= 102400 then
        nlevel = 12
    elseif deposit >= 51200 then
        nlevel = 11
    elseif deposit >= 25600 then
        nlevel = 10
    elseif deposit >= 12800 then
        nlevel = 9
    elseif deposit >= 6400 then
        nlevel = 8
    elseif deposit >= 3200 then
        nlevel = 7
    elseif deposit >= 1600 then
        nlevel = 6
    elseif deposit >= 800 then
        nlevel = 5
    elseif deposit >= 400 then
        nlevel = 4
    elseif deposit >= 200 then
        nlevel = 3
    elseif deposit >= 100 then
        nlevel = 2
    elseif deposit >= 0 then
        nlevel = 1
    end

    return self:getGameStringByKey("G_DEPOSIT_LEVEL_" .. tostring(nlevel))
end

function BaseGameController:isSingleClk()
    local setting = self._baseGameScene:getSetting()
    if setting then
        return setting:isSelCardBySingleClk()
    end
    return true
end

--about chartered room
function BaseGameController:setDispatcher(dispatcher)
    self._dispatch=dispatcher
end

function BaseGameController:LeaveGameForChangeOK()
    if(self._dispatch)then
        if(self._dispatch:isNeedShow())then
            self._dispatch:show(true)
        end
    end
    self._baseGameConnect:gc_LeaveGame_forChangetable()
end

function BaseGameController:onLeaveGameForChangeOK()
    --aaaa cc.exports.PUBLIC_INTERFACE.ApplyEnterCharteredRoom(handler(self,self.startChangeTable))
end

function BaseGameController:startChangeTable(tableNO,chairNO)
        self._baseGamePlayerInfoManager:setSelfTableNO(tableNO)
        self._baseGamePlayerInfoManager:setSelfChairNO(chairNO)
        if(self._baseGameConnect)then
           self._baseGameConnect:gc_EnterGame()
        else
            local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
            if tcyFriendPlugin then
                if(cc.exports.sdkSession)then
                    local con = cc.exports.GetRoomConfig()
                    printf("~~~~~~~~~~~~startChangeTable failed~~~~~~~~~~~~~~~~~~")
                    tcyFriendPlugin:onAgreeToBeInvitedBack(cc.exports.sdkSession, cc.exports.AgreeToBeInvitedType.kAgreeToBeInvitedFailed, con["SDK_BEINVITED_ERR_ENTERFAILED"])
                    cc.exports.sdkSession=nil
                end
            end
        end
end

function BaseGameController:changeChair(toChairNO)
    self._baseGameConnect:gc_ChangeChair(toChairNO)
end

function BaseGameController:onChairChanged(data)
    local chair = self._baseGameData:getChairChanged(data)
    if(self._dispatch)then
        self._dispatch:onChairChanged(chair)
    end

    --data
    local playInfo
    local drawIndex
    local newDrawIndex
    if self._baseGamePlayerInfoManager then
        drawIndex = self:rul_GetDrawIndexByChairNO(chair.nOldChairNO)
        if 0 < drawIndex then
            playInfo = self._baseGamePlayerInfoManager:getPlayerInfo(drawIndex)
            if(playInfo)then
                self._baseGamePlayerInfoManager:playerAbort(drawIndex)
                playInfo.nChairNO=chair.nNewChairNO
                newDrawIndex = self:rul_GetDrawIndexByChairNO(playInfo.nChairNO)
                self._baseGamePlayerInfoManager:setPlayerInfo(newDrawIndex,playInfo)
            else
                return
            end
        else
            return
        end
    end

    if(playInfo==nil)then
        return
    end

    --interface
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
            playerManager:playerAbort(drawIndex)
            playerManager:setSoloPlayer(newDrawIndex,playInfo)
    end


end

function BaseGameController:tickoff(model,targetUserID,targetChairNO)
    self._baseGameConnect:gc_Tickoff(model,targetUserID,targetChairNO)
end

function BaseGameController:onTickoff(data)
    ignoreGetTableFailed = true
    local tick = self._baseGameData:getTickoff(data)
    if(self._dispatch)then
        self._dispatch:onTickoff(tick)
    end
end

function BaseGameController:onGameStartForCharteredRoom(data)
    cc.exports.hasStartGame=true
    if(self._dispatch)then
        local gameStart = self._baseGameData:getGameStartInfo(data)
        self._dispatch:onGameStartForCharteredRoom(gameStart)
    end
end

function BaseGameController:showCharteredRoom(showReady)
    if(self._dispatch)then
        self._dispatch:show(showReady)
    end
end

function BaseGameController:onGameOneSetEnd(data)
    if(self._dispatch)then
        self._dispatch:onGameOneSetEnd(data)
        if self._showCharteredBtn then
            self._showCharteredBtn:setVisible(false)
        end
    end
end

function BaseGameController:onHostChanged(data)
    local change = self._baseGameData:getHostChanged(data)
    if self._dispatch then
        local tableNO = self._baseGamePlayerInfoManager:getSelfTableNO()
        if tableNO == change.nTableNO then
            self._dispatch:onHostChanged(change)
        end
    end
end

function BaseGameController:onGetSyncInfo(data)
    local sync = self._baseGameData:getSyncInfo(data)
    local charteredRoom = require("src.app.Game.mBaseGame.BaseGameCharteredRoom.CharteredRoom")
    charteredRoom:onGetSyncInfo(sync)
end

function BaseGameController:startGotoNewTable(respondType,dataMap)
    if(self._dispatch)then
       self._dispatch:startGotoNewTable(respondType,dataMap)
    end
end

function BaseGameController:createNewTableInGame()
    if self:isTeamGameRoom() then
        PublicInterface.CreateNewTeamTableInGame(handler(self,self.startGotoNewTable))
    else
        PublicInterface.CreateNewTableInGame(handler(self,self.startGotoNewTable))
    end
end

function BaseGameController:sendSyncInfo()
    if cc.exports.isSocialSupported() then
        self._baseGameConnect:gc_sendSyncInfo()
    end
end

function BaseGameController:setPlayerLbs(nUserID,lbs)
    if not self._baseGameScene then return end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then   
        printf("setPlayerLbs in playerManager")
        playerManager:setLbs(nUserID, lbs)
        self._playerLbs[nUserID]=lbs
    end
end

function BaseGameController:getSelfPortrait()
    require('src.app.BaseModule.ImageCtrl'):getSelfImage('100-100', function(code, path, imageStatus)
        if type(path) == 'string' and string.len(path) ~= 0 then
            self:setPlayerHead(self._baseGamePlayerInfoManager:getSelfUserID(), path)
            self:setArenaPortrait(path)
        end
    end , 'cache')
end

function BaseGameController:setPlayerHead(nUserID,path)
    if not self._baseGameScene then return end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then   
        printf("setPlayerHead in playerManager")
        playerManager:setPlayerHead(nUserID, path)
        self._playerHead[nUserID]=path
    end
end

function BaseGameController:isFriend(playerUserID)
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin==nil then
        return true
    end
    if(tcyFriendPlugin:isFriend(playerUserID))then
        return true
    else
        return false
    end
end

function BaseGameController:onGetHomeInfoOnDXXW(data)
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onGetHomeInfoOnDXXW(data)
    end

    if self:IS_BIT_SET(info.nEnterFlag, BaseGameDef.BASEGAME_TELLONDXXW_RandomTeam) then
        self:setHallEntery(true)

        if not self._dispatch then
            self._baseGameScene:createChartredRoom()
        end
    else
        self:setHallEntery(false)
    end

    if(self._dispatch)then
        self._dispatch:onGetHomeInfoOnDXXW(info)
    end
end

function BaseGameController:isTableFull()
    if(self._baseGamePlayerInfoManager)then
        local count = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()
        local currentCount = self._baseGamePlayerInfoManager:getCurrentPlayerCount()
        if(count == currentCount)then
            return true
        else
            return false
        end 
    end
    return false
end

function BaseGameController:IsPlayerInTable(userID)
    if(self._baseGamePlayerInfoManager)then
        local info = self._baseGamePlayerInfoManager:getPlayerInfoByUserID(userID)
        if(info)then
            return true
        end
    end
    return false
end

function BaseGameController:GetCurrentTableNO()
    if(self._baseGamePlayerInfoManager)then
        return self._baseGamePlayerInfoManager:getSelfTableNO()
    end
    return ""
end

function BaseGameController:GetCharteredRoomHostName()
    if(self._dispatch)then
        return self._dispatch:GetCharteredRoomHostName()
    end
    return ""
end

function BaseGameController:GetCharteredRoomHostID()
    if(self._dispatch)then
        return self._dispatch:GetCharteredRoomHostID()
    end
    return ""
end

function BaseGameController:addFriend(nUserID,addDes)
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        tcyFriendPlugin:addFriend(nUserID, addDes)
    end
end

function BaseGameController:setGameOffline()
    if self._dispatch then
        self._dispatch:quit()
    end
    self._dispatch = nil
    cc.exports.hasStartGame = false
end


function BaseGameController:onTeamRoomLeaveGameOK()
    if self:isTeamGameRoom() and self:isHallEntery() then
        self:showCharteredRoom(true)
    end
end

function BaseGameController:onTeamRoomLeaveGameFailed()
    local content = ""
    if self:isGameRunning() then
        content = self:getGameStringByKey("G_LEAVEGAME_FAILED_PLAYING")
        local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
        self:popSureDialog(utf8Content, "", "", function()end, false)
    else
        content = self:getGameStringByKey("G_LEAVEGAME_FAILED")
        self:tipMessageByGBStr(content)
    end
end

function BaseGameController:isVisibleCharteredRoom()
    if(self._dispatch)then
        return self._dispatch:isVisible()
    end
end

function BaseGameController:waitForGetTableDataResponse()
    local function onGetTableDataResponseFinished(dt)
        self:onGetTableDataResponseFinished(dt)
    end
    self:stopGetTableDataResponseTimer()
    self.getTableDataResposeTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onGetTableDataResponseFinished, 5.0, false)
end

function BaseGameController:onGetTableDataResponseFinished(dt)
    self:stopGetTableDataResponseTimer()
    self:onTimeOut()
end

function BaseGameController:stopGetTableDataResponseTimer()
    if self.getTableDataResposeTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.getTableDataResposeTimerID)
        self.getTableDataResposeTimerID = nil
    end
end

function BaseGameController:startShieldVoiceTimer()  
    self._isShieldVoice = true 

    local function onShieldVoiceTimeFinished(dt)
        self:onShieldVoiceTimeFinished(dt)
    end
    self:stopShieldVoiceTimer()
    self._ShieldVoiceTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onShieldVoiceTimeFinished, 3.0, false)
end

function BaseGameController:onShieldVoiceTimeFinished(dt)
    self:stopShieldVoiceTimer()
    self._isShieldVoice = false
end

function BaseGameController:stopShieldVoiceTimer()
    if self._ShieldVoiceTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._ShieldVoiceTimerID)
        self._ShieldVoiceTimerID = nil
    end
end

function BaseGameController:startPlayerAbortTimer()
    local function onPlayerAbortTimeFinished(dt)
        self:onPlayerAbortTimeFinished(dt)
    end
    self:stopPlayerAbortTimer()
    self._PlayerAbortTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onPlayerAbortTimeFinished, 2.0, false)
end

function BaseGameController:onPlayerAbortTimeFinished(dt)
    self:stopPlayerAbortTimer()
    self:resetResume()
end

function BaseGameController:stopPlayerAbortTimer()
    if self._PlayerAbortTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._PlayerAbortTimerID)
        self._PlayerAbortTimerID = nil
    end
end


function BaseGameController:isArenaPlayer()
    return self._baseGameArenaInfoManager:isArenaPlayer()
end

function BaseGameController:setArenaPortrait(path)
    local arenaInfo = self._baseGameScene:getArenaInfo()
    if not self._baseGameArenaInfoManager:isArenaPlayer() or not arenaInfo then return end
    arenaInfo:setPortrait(path)
end

function BaseGameController:setArenaDeposit(nDeposit)
    local arenaInfo = self._baseGameScene:getArenaInfo()
    if not self._baseGameArenaInfoManager:isArenaPlayer() or not arenaInfo then return end
    arenaInfo:setSelfDeposit(nDeposit)
end

function BaseGameController:setArenaNickSex(nNickSex)
    local arenaInfo = self._baseGameScene:getArenaInfo()
    if not self._baseGameArenaInfoManager:isArenaPlayer() or not arenaInfo then return end
    arenaInfo:setNickSex(nNickSex)
end

function BaseGameController:setArenaHP(nInitHP, nHP)
    local arenaInfo = self._baseGameScene:getArenaInfo()
    if not self._baseGameArenaInfoManager:isArenaPlayer() or not arenaInfo then return end
    arenaInfo:setHP(nInitHP, nHP)
end

function BaseGameController:setArenaScore(arenaScore)
    local arenaInfo = self._baseGameScene:getArenaInfo()
    if not self._baseGameArenaInfoManager:isArenaPlayer() or not arenaInfo then return end
    arenaInfo:setArenaScore(arenaScore)
end

function BaseGameController:setArenaTotalScore(arenaTotalScore)
    local arenaInfo = self._baseGameScene:getArenaInfo()
    if not self._baseGameArenaInfoManager:isArenaPlayer() or not arenaInfo then return end
    arenaInfo:setTotalScore(arenaTotalScore)
end

function BaseGameController:onRecieveArenaEvents(data) 
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onRecieveArenaEvents(data)
    end
    if not info then return end

    if      info.nEventType == BaseGameDef.BASEGAME_EAET_SCORE_CHANGED      then
        self._baseGameArenaInfoManager:addBoutScore(info.nEventValue)
        local arenaInfo = self._baseGameScene:getArenaInfo()
        if arenaInfo then
            arenaInfo:addArenaScore(info.nEventValue)
        end
    elseif  info.nEventType == BaseGameDef.BASEGAME_EAET_STOPED_HP          then
    elseif  info.nEventType == BaseGameDef.BASEGAME_EAET_STOPED_SCOREMAX    then
    elseif  info.nEventType == BaseGameDef.BASEGAME_EAET_REWARD_NOTIFY      then
    end
end

function BaseGameController:onRecieveArenaResult(data) 
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onRecieveArenaResult(data)
    end
    if not info then return end

    self._baseGameArenaInfoManager:setArenaInfo({
        nHP             = info.nHP,
        nDiffHP         = info.nDiffHP,
        nMatchScore     = info.nMatchScore,
        nBoutScore      = info.nMatchDiffScore,
        nMatchID        = info.nMatchID,
        nStreaking      = info.nStreaking,
        nMaxStreaking   = info.nMaxStreaking,
        nTotalBout      = info.nTotalBout,
        nWinBout        = info.nWinBout,
        nBoutAddition   = info.nBoutAddition,
        nAddition       = info.nAddition,
        nRewardLevelOld = info.nRewardLevelOld,
        nRewardLevelNew = info.nRewardLevelNew,
        nAdditionDetail = info.nAdditionDetail
    })
    
    local arenaInfo = self._baseGameScene:getArenaInfo()
    arenaInfo:onArenaResult(info)

    self:showArenaResult()
end

function BaseGameController:onRecieveArenaReward(data) 
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onRecieveArenaReward(data)
    end
    if not info then return end

    if info.nIsReissue == 1 then
        self:tipMessageByUTF8Str(info.szNotifyContent)
    end
end

function BaseGameController:showArenaResult()
    my.scheduleOnce(function()
        if self:isInGameScene() == false then return end
        if not self._baseGameScene then return end

        local totalScore        = self._baseGameArenaInfoManager:getMatchScore()
        local roundScore        = self._baseGameArenaInfoManager:getBoutScore()
        local lastAddition      = self._baseGameArenaInfoManager:getLastRoundAddition()
        local nextAddition      = self._baseGameArenaInfoManager:getAddition()
        local additionDetail    = self._baseGameArenaInfoManager:getAdditionDetail()
        local initHP            = self._baseGameArenaInfoManager:getInitHP() 
        local diffHP            = self._baseGameArenaInfoManager:getDiffHP()
        local leftHP            = self._baseGameArenaInfoManager:getHP()
        local awardCount, awardList = self._baseGameArenaInfoManager:getAwardInfoNumber(), self._baseGameArenaInfoManager:getAwardInfo()

        self._arenaStatement = self._baseGameScene:getArenaStatement({
            totalScore      = totalScore,
            roundScore      = roundScore,
            lastAddition    = lastAddition,
            nextAddition    = nextAddition,
            additionDetail  = additionDetail,
            initHP          = initHP,
            diffHP          = diffHP,
            leftHP          = leftHP,
            awardCount      = awardCount,
            awardList       = awardList,
            isForceQuit     = self._baseGameArenaInfoManager:isForceQuit()
        })

    end, 2)
end

function BaseGameController:showArenaInfo()
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:hidePlayer1Bottom()
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:hideBottom()
    end

    local arenaInfo = self._baseGameScene:getArenaInfo()
    if arenaInfo then
        arenaInfo:show()
    end
end

function BaseGameController:hideArenaInfo() 
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:showPlayer1Bottom()
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showBottom()
    end

    local arenaInfo = self._baseGameScene:getArenaInfo()
    if arenaInfo then
        arenaInfo:hide()
    end
end

function BaseGameController:showGameResult()
    print("please overwrite showGameResult")
end

function BaseGameController:onArenaFinished()
    --local lastMatchID = self._baseGameArenaInfoManager:getMatchID()
    local arenaStatementInfo = self._baseGameArenaInfoManager:getArenaInfo()
    PublicInterface.OnArenaFinished(arenaStatementInfo)
    self:quitDirect()
end

function BaseGameController:giveUpArenaInGame()
    local arenaStatementInfo = self._baseGameArenaInfoManager:getArenaInfo()
    PublicInterface.GiveUpArena(arenaStatementInfo)
    self:quitDirect()
end

function BaseGameController:onMatchIDInValid(data)
    self:disconnect()

    local content = self:getGameStringByKey("G_ARENA_MATCHIDINVALID")

    local okCallback = function()
        self:gotoHallScene()
    end
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
--    local function pop()
--        self:popSureDialog(utf8Content, "", "", okCallback, false)
--    end
--    my.scheduleOnce(pop, 1)
    self:popSureDialog(utf8Content, "", "", okCallback, false)
end

function BaseGameController:onArenaPlayerDXXW(data)   
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onArenaPlayerDXXW(data)
    end
    if not info then return end

    PublicInterface.OnArenaDXXW()
    local arenaDXXWInfo = {
        nMatchID    = info.nMatchID,
        nHP         = info.nHP,
        nBoutScore  = info.nBoutScore,
    }
    self._baseGameArenaInfoManager:setArenaInfo(arenaDXXWInfo)
    self._baseGameScene:setArenaInfo()
    self:setArenaInfo(handler(self, self.setArenaInfoView))
end

function BaseGameController:setArenaInfoView()
    if self:isArenaPlayer() then 
        local matchScore = self._baseGameArenaInfoManager:getMatchScore()
        local boutScore = self._baseGameArenaInfoManager:getBoutScore()
        self:setArenaScore(boutScore or 0)
        self:setArenaTotalScore(matchScore or 0)
        local initHP    = self._baseGameArenaInfoManager:getInitHP()
        local HP        = self._baseGameArenaInfoManager:getHP()
        if initHP and HP then
            self:setArenaHP(initHP, HP)
        end
    end
end

function BaseGameController:isUserConvertSupported()
    --return true
    return false --用户转化已废弃
end

--[[function BaseGameController:getUserConvertCtrl()
    return require('src.app.userconvert.UserConvertCtrl'):getInstance()
end]]-- 用户转化已废弃

--[[function BaseGameController:showUserConvertBtn()
    if self:isUserConvertSupported() then
        local userConvert = self:getUserConvertCtrl()

        local gameNode = self._baseGameScene._gameNode
        userConvert:showOptionConvertBtn(self:getConvertButtonPosition(), self:getConvertBtnShowNode())
    end
end]]-- 用户转化已废弃

function BaseGameController:getConvertButtonPosition()
    return cc.p(display.width - 420, display.height - 50)
end

function BaseGameController:getConvertBtnShowNode()
    local gameNode = self._baseGameScene._gameNode
    return gameNode:getChildByName('Panel_BG')
end




--自定义功能
function BaseGameController:getCenterXOfOperatePanel()
    if self._baseGameScene and self._baseGameScene._gameNode then
        return self._baseGameScene:getCenterXOfOperatePanel()
    end
    return 640
end

function BaseGameController:getWidthOfOperatePanel()
    return 2 * self:getCenterXOfOperatePanel()
end

function BaseGameController:getCenterXOfScreen()
    return display.center.x
end

--是否还在游戏场景中
function BaseGameController:isInGameScene()
    if my.isInGame() == false then return false end

    if  cc.exports.GamePublicInterface then
        if cc.exports.GamePublicInterface._gameController == nil then
            return false
        end
    end

    if self._baseGameScene == nil or tolua.isnull(self._baseGameScene) then
        return false
    end

    return true
end

return BaseGameController
