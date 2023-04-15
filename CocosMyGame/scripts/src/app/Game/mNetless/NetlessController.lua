
if nil == cc or nil == cc.exports then
    return
end
local MyGameController                          = import("src.app.Game.mMyGame.MyGameController")

cc.exports.NetlessController                     = {}
local NetlessController                          = cc.exports.NetlessController

local NetlessUtilsInfoManager                    = import("src.app.Game.mNetless.NetlessUtilsInfoManager")
local NetlessNotify                              = import("src.app.Game.mNetless.NetlessNotify")

local MyGameDef                                 = import("src.app.Game.mMyGame.MyGameDef")
local MyGameReq                                 = import("src.app.Game.mMyGame.MyGameReq")
local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")
local SKGameReq                             = import("src.app.Game.mSKGame.SKGameReq")

local player=mymodel('hallext.PlayerModel'):getInstance()
require("src.app.GameHall.PublicInterface")
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()

NetlessController.super = MyGameController
setmetatable(NetlessController, {__index = NetlessController.super})

NetlessController._nChairOfflineCards = {}
NetlessController._nWinPlayceOffline = 0
NetlessController._nWinPlace = {-1,-1,-1,-1}
NetlessController._nCurrentRank = 1
NetlessController._nBoutCount = 0
NetlessController._nRank = {1,1,1,1}
NetlessController._nTributeChairNo1 = -1
NetlessController._nTributeChairNo2 = -1

local config = cc.exports.GetRoomConfig()

function NetlessController:setSelfInfo()
    if not self._baseGamePlayerInfoManager then return end

    local playerInfo = nil
    local playerTableInfo = nil
    local selfInfo = {}
    playerInfo = PublicInterface.GetPlayerInfo()
    if playerInfo == nil then
        selfInfo = my.readCache("selfInfo.xml")
    else
        selfInfo.nUserID = playerInfo.nUserID
        selfInfo.nUserType = playerInfo.nUserType
        selfInfo.nStatus = playerInfo.nStatus
        selfInfo.nTableNO = 0
        selfInfo.nChairNO = 0
        selfInfo.nNickSex = playerInfo.nNickSex
        selfInfo.nPortrait = playerInfo.nPortrait
        selfInfo.nNetSpeed = playerInfo.nNetSpeed
        selfInfo.nClothingID = playerInfo.nClothingID
        selfInfo.szUserName = playerInfo.szUsername
        selfInfo.szNickName = playerInfo.szNickName
        selfInfo.nDeposit = playerInfo.nDeposit
        selfInfo.nPlayerLevel = playerInfo.nPlayerLevel
        selfInfo.nScore = playerInfo.nScore
        selfInfo.nBreakOff = playerInfo.nBreakOff
        selfInfo.nWin = playerInfo.nWin
        selfInfo.nLoss = playerInfo.nLoss
        selfInfo.nStandOff = playerInfo.nStandOff
        selfInfo.nBout = playerInfo.nBout
        selfInfo.nTimeCost = playerInfo.nTimeCost
        selfInfo.nGrowthLevel = playerInfo.nGrowthLevel
    end

    selfInfo.szUserName = ''--playerInfo.szUsername
    selfInfo.szNickName = ''--playerInfo.szNickName
    my.saveCache("selfInfo.xml", selfInfo)
	if playerInfo then
		selfInfo.szUserName 	= playerInfo.szUsername
		selfInfo.szNickName 	= playerInfo.szNickName
	end
    dump(selfInfo)
    self._baseGamePlayerInfoManager:setSelfInfo(selfInfo)
end

function NetlessController:setUtilsInfo()
    if not self._baseGameUtilsInfoManager then return end

    local playerInfo = nil
    local playerEnterGameOK = nil
    local roomInfo = nil
    local utilsInfo = {}
    playerInfo = PublicInterface.GetPlayerInfo()
    utilsInfo.szHardID = playerInfo.szHardID
    utilsInfo.nRoomTokenID = 0
    utilsInfo.nMbNetType = 5
    utilsInfo.bLookOn = 0
    utilsInfo.nGameID = playerInfo.nGameID
    utilsInfo.nRoomID = playerInfo.nRoomID
    utilsInfo.nRoomInfo = nil

    --[[utilsInfo.nRoomID = config["OffLineRoom"]["RoomId"] -- 先进经典场任意房，退出再进单机场，由于PlayerInfo.nRoomID未更新，这里强制写死成单机房ID
	cc.exports.OfflineRoomID = tonumber(config["OffLineRoom"]["RoomId"])]]--
    utilsInfo.nRoomID = RoomListModel.OFFLINE_ROOMINFO["nRoomID"]

    printf("~~~~~~~~~~~~~~~~setUtilsInfo~~~~~~~~~~~~~~~~~~~~~~")
    --dump(cc.exports.GetExtraConfigInfo().GameID)
    dump(utilsInfo)
    self._baseGameUtilsInfoManager:setUtilsInfo(utilsInfo)
end

function NetlessController:getMyGameDataXml()
    local playerInfoManager = self:getPlayerInfoManager()
    local nUserID         = playerInfoManager:getSelfUserID()
    if nUserID == nil then
        nUserID = 1000
    end
    return my.readCache("MyGameData"..nUserID..".xml")
end

function MyGameController:saveMyGameDataXml(gameData)
    local playerInfoManager = self:getPlayerInfoManager()
    local nUserID         = playerInfoManager:getSelfUserID()
    if nUserID == nil then
        nUserID = 1000
    end
    my.saveCache("MyGameData"..nUserID..".xml", gameData)
end

function NetlessController:createNetwork()

end

function NetlessController:onGameClockZero()
    
end

function NetlessController:IsHaveTaskFinish()
    return false
end

function NetlessController:onResume()
    
end

function NetlessController:setNotify()
    self._baseGameNotify = NetlessNotify:create(self)
end

function NetlessController:onRemoveLoadingLayer()
    NetlessController.super.onRemoveLoadingLayer(self)
    self:onEnterOfflineGameOK()
end

function NetlessController:createUtilsInfoManager()
    self._baseGameUtilsInfoManager = NetlessUtilsInfoManager:create()
    self:setUtilsInfo()
end

function NetlessController:OnUpInfo(soloPlayer)
    
end

function NetlessController:onEnterOfflineGameOK()
    self:setDXXW(false)
    self:setResume(false)
    local soloPlayers = {}
    soloPlayers[1] = my.readCache("selfInfo.xml")
    local playerInfo = nil
    playerInfo = PublicInterface.GetPlayerInfo()
    if playerInfo == nil then
    else
        soloPlayers[1].szUserName = playerInfo.szUsername
        soloPlayers[1].szNickName = playerInfo.szNickName
    end
    if soloPlayers[1].nUserID == nil then
        soloPlayers[1].nUserID = 1000
    end
    if soloPlayers[1].nUserType == nil then
        soloPlayers[1].nUserType = 0
    end
    soloPlayers[2] = my.readCache("selfInfo.xml")
    if soloPlayers[2].nUserID == nil then
        soloPlayers[2].nUserID = 1000
    end
    if soloPlayers[2].nUserType == nil then
        soloPlayers[2].nUserType = 0
    end
    soloPlayers[2].szUserName = self:getGameStringByKey("G_GAME_NETLESS_PLAYER_NAME_1")
    soloPlayers[2].szNickName = self:getGameStringByKey("G_GAME_NETLESS_PLAYER_NAME_1")
    soloPlayers[2].nChairNO = (soloPlayers[2].nChairNO + 1)%4
    soloPlayers[2].nNickSex = 0
    soloPlayers[3] = my.readCache("selfInfo.xml")
    if soloPlayers[3].nUserID == nil then
        soloPlayers[3].nUserID = 1000
    end
    if soloPlayers[3].nUserType == nil then
        soloPlayers[3].nUserType = 0
    end
    soloPlayers[3].szUserName = self:getGameStringByKey("G_GAME_NETLESS_PLAYER_NAME_2")
    soloPlayers[3].szNickName = self:getGameStringByKey("G_GAME_NETLESS_PLAYER_NAME_2")
    soloPlayers[3].nChairNO = (soloPlayers[3].nChairNO + 2)%4
    soloPlayers[3].nNickSex = 1
    soloPlayers[4] = my.readCache("selfInfo.xml")
    if soloPlayers[4].nUserID == nil then
        soloPlayers[4].nUserID = 1000
    end
    if soloPlayers[4].nUserType == nil then
        soloPlayers[4].nUserType = 0
    end
    soloPlayers[4].szUserName = self:getGameStringByKey("G_GAME_NETLESS_PLAYER_NAME_3")
    soloPlayers[4].szNickName = self:getGameStringByKey("G_GAME_NETLESS_PLAYER_NAME_3")
    soloPlayers[4].nChairNO = (soloPlayers[4].nChairNO + 3)%4
    soloPlayers[4].nNickSex = 1
    if soloPlayers then
        for i = 1, #soloPlayers do
            self:setSoloPlayer(soloPlayers[i])
        end
    end
    self:ope_ShowStart(true)


    --界面初始化begin
    local MyGameUtilsInfoManager    = self._baseGameUtilsInfoManager
    if not MyGameUtilsInfoManager then
        return
    end
    MyGameUtilsInfoManager._utilsStartInfo.nRank = {1,1,1,1}
    self:ope_GameInfoShow(false)

    local SceneNode = self._baseGameScene._gameNode
    local PlayerSilver = SceneNode:getChildByName("Panel_BoutInfo"):getChildByName("PlayerSilver_lab")
    local PlayerScore = SceneNode:getChildByName("Panel_BoutInfo"):getChildByName("PlayerScore_lab")
    PlayerScore:setVisible(true)
    PlayerSilver:setVisible(false)

    local utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_FUN")..self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_OFFLINE")    --"娱乐场"
    SceneNode:getChildByName("Panel_BoutInfo"):getChildByName("room_info"):setString(utf8Name) 
    --界面初始化end

    self:InitGameUtilsInfo()
end

function NetlessController:InitGameUtilsInfo()
    self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit = 100
    self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore = 100
    self._baseGameUtilsInfoManager._utilsStartInfo.bnResetGame = 1
    self._nCurrentRank = 1
    self._nBoutCount = 0  
    self._nRank = {1,1,1,1}
    self._nWinPlayceOffline = 0
    self._nWinPlace = {-1,-1,-1,-1}
    self._nTributeChairNo1 = -1
    self._nTributeChairNo2 = -1 
    
    self._roundCount = 1
    self._sortFlag = SKGameDef.SORT_CARD_BY_ORDER
    
    self._baseGameScene:setTHSBtnsEnabled(false)
end

function NetlessController:onStartGame()
    self:clearGameTable()
    self:stopAutoQuitTimer()
      
    self:FillStartGame()
    
    self:onStartGameOffline()
end

function NetlessController:FillStartGame()
    self._baseGameUtilsInfoManager._utilsPublicInfo = {}
    for i = 0 , 3 do
        for j = 1, 4 do
            self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[j] = 0
        end
    end
    -- 随机牌列
    local card = { }
    local value = { }
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    for i = 1, MyGameDef.MY_TOTAL_CARDS do
        card[i] = i-1
        value[i] = math.random()
    end
    local temp
    for i = 1, MyGameDef.MY_TOTAL_CARDS - 1 do
        for j = i + 1, MyGameDef.MY_TOTAL_CARDS do
            if value[i] < value[j] then
                temp = card[i]
                card[i] = card[j]
                card[j] = temp
                temp = value[i]
                value[i] = value[j]
                value[j] = temp
            end
        end
    end
    -- 抓牌
    local nFirstCatch = 0
    self._nChairOfflineCards[1] = { }
    self._nChairOfflineCards[2] = { }
    self._nChairOfflineCards[3] = { }
    self._nChairOfflineCards[4] = { }
    for i = 1, MyGameDef.MY_TOTAL_CARDS do
        local round, roundX = math.modf((i - 1) / MyGameDef.MY_TOTAL_PLAYERS)
        local chairno =(nFirstCatch + i - 1) % MyGameDef.MY_TOTAL_PLAYERS
        self._nChairOfflineCards[chairno + 1][round + 1] = card[i]
    end
    --随机牌列

    self._nBoutCount = self._nBoutCount + 1
    if self._nBoutCount == 1 then
        for i = 1, 4 do
            self._nRank[i] = 1
        end
        self._nCurrentRank = 1
        self._baseGameUtilsInfoManager._utilsStartInfo.nCurrentRank = 1
    end
    local bnRestet = true
    for i = 1, 4 do
        if self._nRank[i] ~= 1 then
            bnRestet = false
            break
        end
    end
    if bnRestet then    
        self._baseGameUtilsInfoManager._utilsStartInfo.nBanker = math.random(0,3)
    end
    self._baseGameUtilsInfoManager._utilsStartInfo.nRanker = self._baseGameUtilsInfoManager._utilsStartInfo.nBanker
  
    self._baseGameUtilsInfoManager._utilsStartInfo.Tribute = {}
    for i = 1, 4 do
        self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i]={}
        self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute = 0
        self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID = -1
        self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner = -1
        self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nFightID = {}
    end
    self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum = 0
    
    --进贡
    if self._nBoutCount ~= 1 and not bnRestet then       
        self._nTributeChairNo1 = -1
        self._nTributeChairNo2 = -1
        local nFirst = -1
        local nFriend = -1
        local enemy1= -1
        local enemy2= -1
        for i = 1, 4 do
            if self._nWinPlace[i] == 1 then
                nFirst = i-1
                nFriend = self:getNextChair(self:getNextChair(nFirst))
            elseif self._nWinPlace[i] == 4 then
                if enemy1 == -1 then
                    enemy1 = i-1
                else
                    enemy2 = i-1
                end
            end
        end
        self._baseGameUtilsInfoManager._utilsStartInfo.nCurrentRank = self._nRank[nFirst+1]
        self._baseGameUtilsInfoManager._utilsStartInfo.nRanker = nFirst

        local enemy1Lay     = {}
        local enemy2Lay     = {}
        SKCalculator:xygZeroLays(enemy1Lay, SKGameDef.SK_LAYOUT_NUM)
        SKCalculator:xygZeroLays(enemy2Lay, SKGameDef.SK_LAYOUT_NUM)
        local gameFlags = GamePublicInterface:getGameFlags()
        SKCalculator:skLayCards(self._nChairOfflineCards[enemy1+1], 27, enemy1Lay, gameFlags)
        
        if enemy2 == -1 then --只有一个末游的时候
            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].bnTribute = 1
            if enemy1Lay[15] == 2 then
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].bnFight = 1
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].nFightID[1] = 53
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].nFightID[2] = 107

                self._baseGameUtilsInfoManager._utilsStartInfo.nBanker = nFirst
            else
                self._nTributeChairNo1 = enemy1
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].bnFight = 0
            end
        else
            SKCalculator:skLayCards(self._nChairOfflineCards[enemy2+1], 27, enemy2Lay, gameFlags)

            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].bnTribute = 1
            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].bnTribute = 1
            if enemy1Lay[15] + enemy2Lay[15] == 2 then             
                self._baseGameUtilsInfoManager._utilsStartInfo.nBanker = nFirst
                
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].bnFight = 1
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].nFightID[1] = -1
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].nFightID[2] = -1
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].bnFight = 1
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].nFightID[1] = -1
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].nFightID[2] = -1

                for i = 1, 27 do
                     if MyCalculator:getCardIndex(self._nChairOfflineCards[enemy1+1][i], 0) == 15 then
                        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].nFightID[1] == -1 then
                            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].nFightID[1] = self._nChairOfflineCards[enemy1+1][i]
                        else
                            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].nFightID[2] = self._nChairOfflineCards[enemy1+1][i]
                        end
                     end
                     if MyCalculator:getCardIndex(self._nChairOfflineCards[enemy2+1][i], 0) == 15 then
                        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].nFightID[1] == -1 then
                            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].nFightID[1] = self._nChairOfflineCards[enemy2+1][i]
                        else
                            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].nFightID[2] = self._nChairOfflineCards[enemy2+1][i]
                        end
                     end
                end
            else
                self._nTributeChairNo1 = enemy1
                self._nTributeChairNo2 = enemy2
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].bnFight = 0
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].bnFight = 0
            end
        end
    else
        self._baseGameUtilsInfoManager._utilsStartInfo.nCurrentRank = 1
    end

    self._baseGameUtilsInfoManager._utilsStartInfo.nCurrentChair = self._baseGameUtilsInfoManager._utilsStartInfo.nBanker
    self._baseGameUtilsInfoManager._utilsStartInfo.nBoutCount = self._nBoutCount
    self._baseGameUtilsInfoManager._utilsStartInfo.nRank = self._nRank
    
    self._nWinPlayceOffline = 0
    self._TributePlace = clone(self._nWinPlace)
    self._nWinPlace = {-1,-1,-1,-1}
end

function NetlessController:onStartGameOffline()
    self:gameRun()
    local nBaseScore = self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onGameStart()
    end
    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools._nBaseScore = nBaseScore
        gameTools:onGameStart()
    end

    self:playGamePublicSound("Snd_ArrageTable.mp3")

    self:dealCardsOffline()
    
    self:ope_GameInfoShow(true)
    self:ope_GameStart()

    self._baseGameScene:showRankCard(self._baseGameUtilsInfoManager._utilsStartInfo.nRank[self._baseGameUtilsInfoManager._utilsStartInfo.nRanker+1])
    self._baseGameScene:setMyRuleBtnVisible(false)
end

function NetlessController:dealCardsOffline()
    if self._baseGameUtilsInfoManager then
        self._baseGameUtilsInfoManager:clearTableInfo()
    end
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        local cardsCounts = {27,27,27,27}
        for i = 1, self:getTableChairCount() do
            local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
            if 0 < drawIndex then
                SKHandCardsManager:setHandCardsCount(drawIndex, cardsCounts[i])
                SKHandCardsManager:setHandCards(drawIndex,self._nChairOfflineCards[i])
                if drawIndex == self:getMyDrawIndex() then
                    SKHandCardsManager:setSelfHandCards(self._nChairOfflineCards[i], true)
                    SKHandCardsManager:hideSelfHandCards()-- 暂时隐藏
                end
            end
        end
    end
end

function NetlessController:getCurrentChair()
    if not self._baseGameUtilsInfoManager then return 0 end
    return self._baseGameUtilsInfoManager:getCurrentChair()
end

function NetlessController:getCurrentIndex()
    return self:rul_GetDrawIndexByChairNO(self:getCurrentChair())
end

function NetlessController:onThrow()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end

    self:onThrowCard(SKHandCardsManager:getSelectCardIDs(self:getCurrentIndex()))
end

function NetlessController:onThrowCard(cardIDs, cardsLen)
    if not cardIDs or not cardsLen or cardsLen == 0 then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end

    self:hideOperationBtns()

    local unitDetails = MyCalculator:initCardUnite()
    if not MyCalculator:getUniteDetails(cardIDs, cardsLen, unitDetails, MyGameDef.MY_CARD_UNITE_TYPE_TOTAL) then
        return
    end
    if SKHandCardsManager:isFirstHand() then
        MyCalculator:getBestUnitType1(unitDetails)
    else
        MyCalculator:getBestUnitType2(self._baseGameUtilsInfoManager:getWaitUniteInfo(), unitDetails)
    end

    self:throwCardsOffline(unitDetails.uniteType[1])
end

function NetlessController:throwCardsOffline(cardUnite)
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    local playerInfoManager = self:getPlayerInfoManager()
    local uitleInfoManager  = self:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end
    local cardsWaiting = self._baseGameUtilsInfoManager:getWaitUniteInfo()
    local chairNO = self:getCurrentChair()

    --理牌埋点begin
    if chairNO == self:getMyChairNO() then
        self:LogSortCard()
    end
    --理牌埋点end

    local nextChair,nextFirst = self:getNextThrowChair(chairNO)
    local remainCount = SKHandCardsManager:getHandCardsCount(self:getCurrentIndex()) - cardUnite.nCardsCount
    local winPlayce = 0

    -----两轮炸-----
    local waitChair = self._baseGameUtilsInfoManager:getWaitChair()
    if not waitChair or waitChair == -1 then
    else 
        self._roundCount = 1
    end
    -----两轮炸-----

    if remainCount <= 0 then
        self._nWinPlayceOffline = self._nWinPlayceOffline + 1
        self._nWinPlace[chairNO+1] = self._nWinPlayceOffline
        winPlayce = self._nWinPlayceOffline
    end
    if catchCards == 1 then
        remainCount = SKHandCardsManager:getHandCardsCount(self:getCurrentIndex()) + 1
    end
    local cardsThrow = SKGameReq["CARDS_THROW"]
    cardsThrow.nUserID         = playerInfoManager:getSelfUserID()
    cardsThrow.nRoomID         = uitleInfoManager:getRoomID()
    cardsThrow.nTableNO        = playerInfoManager:getSelfTableNO()
    cardsThrow.nChairNO        = chairNO
    cardsThrow.bPassive        = 0
	cardsThrow.nNextChair      = nextChair
	cardsThrow.nWinPlayce      = winPlayce
	cardsThrow.nWaitTime       = 15
    cardsThrow.dwCardType      = cardUnite.dwCardType
    cardsThrow.dwComPareType   = cardUnite.dwComPareType
    cardsThrow.nMainValue      = cardUnite.nMainValue
    cardsThrow.nCardsCount     = cardUnite.nCardsCount
    cardsThrow.nCardIDs        = cardUnite.nCardIDs
    cardsThrow.bCatchCards     = catchCards

	cardsThrow.nCatchCards         = cardsWaiting.nCardIDs
	cardsThrow.nCatchCardsCount    = cardsWaiting.nCardsCount
	cardsThrow.bThrowWin           = 0

    local currentIndex = self:getCurrentIndex()
    self:ope_ThrowCards(cardsThrow)

    --是否结束
    if self:calcWinOnThrow(cardsThrow) then
        self:onGameWinOffline()
    else
        --获取队友手牌
        if currentIndex == self:getMyDrawIndex() and remainCount <= 0 then
            local friendInhandCards, friednCardsCount = SKHandCardsManager:getSKHandCards(self:rul_GetDrawIndexByChairNO(self:getMyChairNO()+2)%4):getHandCardIDs()
            local cardsInfo = {}
            cardsInfo.nUserID = 0
            cardsInfo.nChairNO = (self:getMyChairNO()+2)%4
            cardsInfo.nCardIDs = friendInhandCards
            cardsInfo.nCardsCount = friednCardsCount
            self:onCardsInfoEx(cardsInfo)
        end
    end
end

function NetlessController:onCardsInfoEx(data)
    local cardsInfo = data

    if not cardsInfo or 0 == cardsInfo.nCardsCount then return end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end

    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsInfo.nChairNO)
    if drawIndex == self:getOppositeIndex() then       
        self:onCancelRobot()
      
        local gameTools = self._baseGameScene:getTools()
        if gameTools then
            gameTools:onHideOtherButton()
        end
        SKHandCardsManager:showFriendCards(cardsInfo.nCardIDs, cardsInfo.nCardsCount)

        local selfInfo = self._baseGameScene:getSelfInfo()
        if selfInfo then
            selfInfo:showDuiJiaShouPai(true)
        end
    end
end

function NetlessController:getNextThrowChair(nChairNO)
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    local nextFirst = 0
    local drawIndex0 = 1
    local remainCount0 = 22
    local nWaitChair = self._baseGameUtilsInfoManager:getWaitChair()
    if nWaitChair and nWaitChair >= 0 then
        drawIndex0 = self:rul_GetDrawIndexByChairNO(nWaitChair)
        remainCount0 = SKHandCardsManager:getHandCardsCount(drawIndex0)
    end
    local nNext = (nChairNO+MyGameDef.MY_TOTAL_PLAYERS-1)%MyGameDef.MY_TOTAL_PLAYERS
    for i=1,MyGameDef.MY_TOTAL_PLAYERS-1 do
        local drawIndex = self:rul_GetDrawIndexByChairNO(nNext)
        local remainCount = SKHandCardsManager:getHandCardsCount(drawIndex)
        if nNext == self._baseGameUtilsInfoManager:getWaitChair() then
            nextFirst = 1
        end
        if remainCount > 0 then 
            break
        else
            if nNext == self._baseGameUtilsInfoManager:getWaitChair() then
                nNext = self:getNextChair(self:getNextChair(nNext))
                break
            else
                nNext = (nNext+MyGameDef.MY_TOTAL_PLAYERS-1)%MyGameDef.MY_TOTAL_PLAYERS
            end
        end
    end
    return nNext,nextFirst
end

function NetlessController:onPassCard(drawindex)
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        if drawindex == nil then
            SKHandCardsManager:ope_UnselectSelfCards()
        else
            SKHandCardsManager:ope_UnselectSelfCardsRoot(drawindex)
        end
    end

    self:hideOperationBtns()

    self:passCardsOffline()
end

function SKGameController:passCardsOffline()
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    local playerInfoManager = self:getPlayerInfoManager()
    local uitleInfoManager  = self:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end
    local chairNO = self:getCurrentChair()
    local nextChair,nextFirst = self:getNextThrowChair(chairNO)
    local cardsPass = SKGameReq["CARDS_PASS"]
    cardsPass.nUserID         = playerInfoManager:getSelfUserID()
    cardsPass.nRoomID         = uitleInfoManager:getRoomID()
    cardsPass.nTableNO        = playerInfoManager:getSelfTableNO()
    cardsPass.nChairNO        = chairNO
    cardsPass.nNextChair      = nextChair
    cardsPass.bNextFirst      = nextFirst
    cardsPass.nWinChair       = 0
    cardsPass.nWinScore       = 0
    cardsPass.nWaitTime       = 15

    if nextFirst == 1 then
        self._roundCount = 2   --已经是两轮以上了 考虑炸
    end
    --过牌记录理牌日志
    if chairNO == self:getMyChairNO() then
        self:LogSortCard()
    end

    self:ope_PassCards(cardsPass)
end

function NetlessController:clockStep(dt)
    NetlessController.super.clockStep(self, dt)

    self:offlinePlay()
end

function NetlessController:offlinePlay()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end

    local clock = self._baseGameScene:getClock()
    if clock then
        if gameWin == 1 then
            clock:stop()
            clock:hideClock()
        end
        if clock:getDrawIndex() == 1 or clock:getDrawIndex() > MyGameDef.MY_TOTAL_PLAYERS then
            return
        end
        if clock:getDigit() > 14 then
            return
        end
    end
    local status        = self._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
        self:onHintRoot(self:getCurrentIndex())
        if self:ope_CheckSelectRoot(self:getCurrentIndex()) then
            self:onThrow()
            return
        end
        if SKHandCardsManager:isFirstHand() then
            self:onThrowCard(self:getAutoThrowCardIDs(self:getCurrentIndex()))
        else
            self:onPassCard(self:getCurrentIndex())
        end
    elseif self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        self:OPE_GETTributeCardRoot()
        self:onTributeRoot()
    elseif self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
        self:OPE_GETReturnCardRoot()
    end
end

function NetlessController:OPE_GETReturnCardRoot()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end

    for i = 1, 4 do
        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner ~= -1 and self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner~= self:getMyChairNO() then   
            local drawIndex = self:rul_GetDrawIndexByChairNO(self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner)
            SKHandCardsManager._SKHandCards[drawIndex]:unSelectCards()
            local nInhandCard, nInHandCardCount = SKHandCardsManager:getHandCardIDs(drawIndex)
            local temp, m = 9, 9
            for i=1, nInHandCardCount do
                if nInhandCard[i]~=-1 and not MyCalculator:isJoker(nInhandCard[i]) 
                    and MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0) < m then
                    m = MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0)
                    temp = nInhandCard[i]
                end
            end
            SKHandCardsManager:selectCardsByIDs(drawIndex,{temp}, 1)        
            self:onReturnRoot(self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner)

            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner = -1
        end
    end
end

function NetlessController:onReturnRoot(chairNo)
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end
    local drawIndex = self:rul_GetDrawIndexByChairNO(chairNo)
    local cardsThrow, cardsCount    = SKHandCardsManager:getSelectCardIDs(drawIndex)
    local status        = self._baseGameUtilsInfoManager:getStatus()
    if cardsCount ~= 1 or not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
        return
    end

    local ReturnCard = {}
    ReturnCard.chairno = chairNo
    ReturnCard.nCardID = cardsThrow[1]
    ReturnCard.nTributeChair = -1
    ReturnCard.nThrowChair = -1

    self:ReturnOffline(ReturnCard)
end

function NetlessController:onReturn()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end
    local cardsThrow, cardsCount    = SKHandCardsManager:getMySelectCardIDs()

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if cardsCount ~= 1 or not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
        return
    end

    local ReturnCard = {}
    ReturnCard.chairno = self:getMyChairNO()
    ReturnCard.nCardID = cardsThrow[1]
    ReturnCard.nTributeChair = -1
    ReturnCard.nThrowChair = -1

    self:ReturnOffline(ReturnCard)
end

function NetlessController:ReturnOffline(ReturnCard)
    for i = 1, 4 do
        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner == ReturnCard.chairno then
            ReturnCard.nTributeChair = i-1
            break
        end
    end
    ReturnCard.nThrowChair = self._baseGameUtilsInfoManager._utilsStartInfo.nBanker
    self:ope_CardsReturn(ReturnCard)
end

function NetlessController:OPE_GETTributeCardRoot()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end
    for i = 1, 2 do
        local chairNo = -1
        if i == 1 then
            chairNo = self._nTributeChairNo1
        else
            chairNo = self._nTributeChairNo2
        end

        if chairNo > 0 and chairNo ~= self:getMyChairNO() then      
            local drawIndex = self:rul_GetDrawIndexByChairNO(chairNo)
            SKHandCardsManager._SKHandCards[drawIndex]:unSelectCards()
            local nInhandCard, nInHandCardCount = SKHandCardsManager:getHandCardIDs(drawIndex)
            local temp, m = 0, -1
            for i=1, nInHandCardCount do
                if nInhandCard[i]~=-1 and not MyCalculator:isJoker(nInhandCard[i]) 
                    and MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0) > m then
                    m = MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0)
                    temp = nInhandCard[i]
                end
            end
            SKHandCardsManager:selectCardsByIDs(drawIndex, {temp}, 1)
        end
    end
end

function NetlessController:onTributeRoot()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end
    local status        = self._baseGameUtilsInfoManager:getStatus()

    for i = 1, 2 do
        local chairNo = -1
        if i == 1 then
            chairNo = self._nTributeChairNo1
        else
            chairNo = self._nTributeChairNo2
        end
        if chairNo > 0 and chairNo ~= self:getMyChairNO() then     
            local drawIndex = self:rul_GetDrawIndexByChairNO(chairNo)
            local cardsThrow, cardsCount    = SKHandCardsManager:getSelectCardIDs(drawIndex)
            if cardsCount ~= 1 or not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
            else       
                local TributeCard = {}
                TributeCard.chairno = chairNo
                TributeCard.nCardID = cardsThrow[1]

                self:TributeOffline(TributeCard)  
            end   
        end
    end
end

function NetlessController:onTribute()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end
    local cardsThrow, cardsCount    = SKHandCardsManager:getMySelectCardIDs()

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if cardsCount ~= 1 or not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        return
    end   
    local TributeCard = {}
    TributeCard.chairno = self:getMyChairNO()
    TributeCard.nCardID = cardsThrow[1]
    self:TributeOffline(TributeCard)  
    SKHandCardsManager:maskAllHandCardsEX(true)
end

function NetlessController:TributeOffline(TributeCard)
    local bTributeOver = true 
    if self._nTributeChairNo1 == TributeCard.chairno then  
        self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum = self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum+1
        self._nTributeChairNo1 = -1
    end
    if self._nTributeChairNo2 == TributeCard.chairno then
        self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum = self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum+1
        self._nTributeChairNo2 = -1
    end   
    if self._nTributeChairNo1 ~= -1 or self._nTributeChairNo2 ~= -1 then
        bTributeOver = false 
    end

    self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[TributeCard.chairno + 1].nCardID = TributeCard.nCardID
    
    if bTributeOver then
        local nFirst = -1
        local nFriend = -1
        local enemy1= -1
        local enemy2= -1
        local nCardID1 = -1
        local nCardID2 = -1
        for i = 1, 4 do
            if self._TributePlace[i] == 1 then
                nFirst = i-1
                nFriend = self:getNextChair(self:getNextChair(nFirst))
            end
            if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID ~= -1 then
                if enemy1 == -1 then
                    enemy1 = i-1
                    nCardID1 = self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID
                else
                    enemy2 = i-1
                    nCardID2 = self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID
                end
            end
        end
        if enemy2 == -1 then
            self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].winner = nFirst
            self._baseGameUtilsInfoManager._utilsStartInfo.nBanker = enemy1
        else
            if MyCalculator:getCardPriEx(nCardID1, self._baseGameUtilsInfoManager:getCurrentRank(), 0) 
                >= MyCalculator:getCardPriEx(nCardID2, self._baseGameUtilsInfoManager:getCurrentRank(), 0)  then
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].winner = nFirst
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].winner = nFriend
                self._baseGameUtilsInfoManager._utilsStartInfo.nBanker = enemy1
            else
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy1+1].winner = nFriend
                self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[enemy2+1].winner = nFirst
                self._baseGameUtilsInfoManager._utilsStartInfo.nBanker = enemy2
            end
        end
        self._baseGameUtilsInfoManager._utilsStartInfo.nCurrentChair = self._baseGameUtilsInfoManager._utilsStartInfo.nBanker
        
        local TributeCardOver = clone(self._baseGameUtilsInfoManager._utilsStartInfo.Tribute)
        self:ope_CardsTributeOver(TributeCardOver)
    else
        self:ope_CardsTribute(TributeCard)
    end

end

function NetlessController:onHintRoot(drawIndex)
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end
    SKHandCardsManager:onHintRoot(drawIndex)
end

function NetlessController:ope_CheckSelectRoot(drawIndex)
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKOpeBtnManager           = self._baseGameScene:getSKOpeBtnManager()
    if not SKHandCardsManager or not SKOpeBtnManager then return false end

    local cardsWaiting              = self._baseGameUtilsInfoManager:getWaitUniteInfo()
    local cardsThrow, cardsCount    = SKHandCardsManager:getSelectCardIDs(drawIndex)
    local bFirstHand                = SKHandCardsManager:isFirstHand()
    if not cardsThrow or not cardsCount then return false end
    if not bFirstHand and not cardsWaiting then return false end

    local bEnableThrow = self:isEnableThrow(bFirstHand, cardsThrow, cardsCount, cardsWaiting)

    return bEnableThrow
end

function NetlessController:getAutoThrowCardIDs(drawindex)
    local autoThrowCardIDs = {}
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        local myHandCards = SKHandCardsManager:getSKHandCards(drawindex)
        if myHandCards then
            local card = myHandCards:getRightCard()
            if card then
                autoThrowCardIDs[1] = card:getSKID()
            end
        end
    end
    return autoThrowCardIDs, 1
end

function NetlessController:calcWinOnThrow(cardsThrow)
    local nMyChair = cardsThrow.nChairNO
    if self:HaveCards(nMyChair) or self:HaveCards(self:getNextChair(self:getNextChair(nMyChair))) then
        
        --self._nWinPlace = {4,2,4,1}
        return false
    else
        for i = 1, MyGameDef.MY_TOTAL_PLAYERS do
            if self._nWinPlace[i] < 0 then
                self._nWinPlace[i] = 4
            end
        end
        return true
    end
    return false
end

function NetlessController:HaveCards(chairNo)
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    local Count = 0
    if chairNo and chairNo >= 0 then
        local drawIndex = self:rul_GetDrawIndexByChairNO(chairNo)
        Count = SKHandCardsManager:getHandCardsCount(drawIndex)
    end
    if Count == 0 then
        return false
    end
    
    return true
end


function NetlessController:ope_PassCards(cardsPass)
    NetlessController.super.ope_PassCards(self, cardsPass)
    self._baseGameUtilsInfoManager._utilsStartInfo.nCurrentChair = cardsPass.nNextChair
end

function NetlessController:ope_ThrowCards(cardsThrow)
    NetlessController.super.ope_ThrowCards(self, cardsThrow)
    self._baseGameUtilsInfoManager._utilsStartInfo.nCurrentChair = cardsThrow.nNextChair
end

function NetlessController:onGameWinOffline()
    print("NetlessController:onGameWinOffline")
    self:hideBannerAdvert()

    self._havemovedcard = 0
    self:setResume(false)
    self:gameStop()

    local clock = self._baseGameScene:getClock()
    if clock then
        clock:resetClock()
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:onGameWin()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onHidePlayerInfo()
    end

    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox then
        safeBox:showSafeBox(false)
    end

    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() then
        chat:showChat(false)
    end

    local setting = self._baseGameScene:getSetting()
    if setting and setting:isVisible() then
        setting:showSetting(false)
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showDuiJiaShouPai(false)
    end

    self:onCancelRobot()
   
    self._sortFlag = SKGameDef.SORT_CARD_BY_ORDER

    local gameWin = MyGameReq["GAME_WIN_RESULT"]
    self:FillupGamewin(gameWin)

    self._playerInfo = {}
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        for i= 1,self:getTableChairCount() do
            local info = playerInfoManager:getPlayerInfo(i)
            self._playerInfo[i] = clone(info)
        end
    end

    self._selfChairNO = self:getMyChairNO()
    if gameWin then
        local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
		local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
		if not SKHandCardsManager or not SKThownCardsManager then return end

		for i = 1, self:getTableChairCount() do
			local score = gameWin.nScoreDiffs[i]
            local deposit = gameWin.nDepositDiffs[i]
			local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)

		    if self:getMyDrawIndex() == drawIndex then
                self:hideOperationBtns()
                local myHandCards = SKHandCardsManager:getSKHandCards(drawIndex)
                if myHandCards and  myHandCards.getFriendCardsCount then
                    -- 结算时，如果显示的是对家手牌， 如果不清理 引起了单机场有时候同花顺计算中途return false
                    if myHandCards:getFriendCardsCount() > 0 then
                        myHandCards:zeroFriendCardsCount()
                    end
                end
            end

			if 0 < drawIndex and 0 < gameWin.nCardCount[i] and drawIndex ~= self:getMyDrawIndex() then
				SKHandCardsManager:setHandCardsCount(drawIndex, gameWin.nCardCount[i])
				SKHandCardsManager:setHandCardsWin(drawIndex, gameWin.nCardID[i])
				SKHandCardsManager:sortHandCards(drawIndex)
			end

            playerManager:FreshPlace(drawIndex, gameWin.nPlace[i])

            SKThownCardsManager:hidePassTip(drawIndex)
		end

        local BomeCount = gameWin.nBombCount[1] + gameWin.nBombCount[2]

        local nFan = 1
        nFan = nFan * (2 ^ BomeCount)
        if gameWin.nBombCount[3] > 0 then
            nFan = nFan * 3
        end
        gameWin.BomeRate = nFan

        gameWin.upRankEx = 1
        if gameWin.nUpRank[self:getMyChairNO()+1] == 4 or gameWin.nUpRank[self:getNextChair(self:getMyChairNO())+1] == 4 then
            gameWin.upRankEx = 4
        elseif gameWin.nUpRank[self:getMyChairNO()+1] == 3 or gameWin.nUpRank[self:getNextChair(self:getMyChairNO())+1] == 3 then
            gameWin.upRankEx = 4
        elseif gameWin.nUpRank[self:getMyChairNO()+1] == 2 or gameWin.nUpRank[self:getNextChair(self:getMyChairNO())+1] == 2 then
            gameWin.upRankEx = 2
        end
        
		my.scheduleOnce(function()
			self:showGameResultInfo(gameWin)
		end, 2)

        for i = 0 ,3 do
            self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[4] = 0
        end
        
        self._baseGameUtilsInfoManager:setStatus(0)
        
        self._baseGameScene:setMyRuleBtnVisible(true)
    end
        --发送理牌日志
    self:sendSortCardLog()
end

function NetlessController:FillupGamewin(gameWin)
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    gameWin.nCardCount = {}
    gameWin.nCardID = {}
    for i = 1, 4 do
        local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
        local myHandCards = SKHandCardsManager:getSKHandCards(drawIndex)       
        local inhandCards, cardsCount = myHandCards:getHandCardIDs()
        
        gameWin.nCardCount[i] = cardsCount
        gameWin.nCardID[i] = inhandCards
    end  
    gameWin.nPlace = self._nWinPlace

    gameWin.nUpRank = {0,0,0,0}
    local nWinChair = -1
    for i = 1, 4 do
        if self._nWinPlace[i] == 1 then
            nWinChair = i-1
            break
        end
    end
    local nFriend = self:getNextChair(self:getNextChair(nWinChair))
    if self._nWinPlace[nFriend+1] == 2 then
        gameWin.nUpRank[nWinChair+1] = 4
        gameWin.nUpRank[nFriend+1] = 4
    elseif self._nWinPlace[nFriend+1] == 3 then      
        gameWin.nUpRank[nWinChair+1] = 2
        gameWin.nUpRank[nFriend+1] = 2
    else
        gameWin.nUpRank[nWinChair+1] = 1
        gameWin.nUpRank[nFriend+1] = 1
    end

    local bnReset = false
    for i = 1, 4 do
        self._nRank[i] = self._nRank[i] + gameWin.nUpRank[i]
        if self._nRank[i] > 13 then
            bnReset = true
            self._nRank[i] = 1
        end
    end
    
    if bnReset then
        for i = 1, 4 do
            self._nRank[i] = 1
        end
    end   
    gameWin.nNextRank = self._nRank

    local nWinPoints = {0,0,0,0}
    local nAddScore = gameWin.nUpRank[nWinChair+1]

    local BomeCount = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nWinChair).nBombCount[1] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nWinChair).nBombCount[2]
                        + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nFriend).nBombCount[1] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nFriend).nBombCount[2]
    local nFan = 1
    nFan = nFan * (2 ^ BomeCount)
    if self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nWinChair).nBombCount[3] > 0 then
        nFan = nFan * 3
    elseif self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nFriend).nBombCount[3] > 0 then
        nFan = nFan * 3
    end
    
    for i = 1, 4 do
        if i == (nWinChair+1) or i == (nFriend+1) then
            nWinPoints[i]=nAddScore*nFan
        else
            nWinPoints[i]=-nAddScore*nFan
        end
    end
    for i = 0, 3 do
        for j = 0, 3 do
            if i == j then
                nWinPoints[j+1]=nWinPoints[j+1]+self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[2]*3+self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[3]*6
            elseif j == self:getNextChair(self:getNextChair(i)) then
                nWinPoints[j+1]=nWinPoints[j+1]+self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[2]+self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[3]*2
            else
                nWinPoints[j+1]=nWinPoints[j+1]-self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[2]*2+self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[3]*4
            end
        end     
    end
    
    local nScoreDiffs = {0,0,0,0}
    for i = 1, 4 do
        if bnReset then
            nWinPoints[i] = nWinPoints[i]+3
        end

        nScoreDiffs[i] = nWinPoints[i]*self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore
    end
    gameWin.nScoreDiffs = nScoreDiffs
    gameWin.nDepositDiffs = {0,0,0,0}

    gameWin.nBombCount = {0,0,0,0}
    gameWin.nBombCount[1] = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nWinChair).nBombCount[1] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nFriend).nBombCount[1]
    gameWin.nBombCount[2] = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nWinChair).nBombCount[2] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nFriend).nBombCount[2]
    gameWin.nBombCount[3] = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nWinChair).nBombCount[3] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nFriend).nBombCount[3]
    gameWin.nReserved1 = {0,0,0,0}
    gameWin.nBoutCount = self._nBoutCount

    
    self._baseGameUtilsInfoManager._utilsStartInfo.bnResetGame = 0
    if bnReset then
        self._baseGameUtilsInfoManager._utilsStartInfo.bnResetGame = 1
    end
    self._baseGameUtilsInfoManager._utilsStartInfo.nBanker = nWinChair
end

function NetlessController:callbackMoveReturn(card, table)
    local cardInfo = table.cardInfo
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end
    cardInfo:setVisible(false)
 
    local nDestChair = cardInfo.nDestChair
    local nindex = self:rul_GetDrawIndexByChairNO(nDestChair)

    SKHandCardsManager:getSKHandCards(nindex):cardsCountIncrease(1)
    SKHandCardsManager:ope_AddTributeAndReturnCard(nindex, cardInfo:getSKID())

    if nDestChair == self:getMyChairNO() then
        SKHandCardsManager:maskAllHandCardsEX(true)
        --移动完显示界面按钮
    end

    self._havemovedcard = self._havemovedcard + 1
    
    if self._havemovedcard == self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum then
        --移除提示      
        self:NTF_MoveOver()
        self._baseGameScene:setSortTypeBtnEnabled(false) -- 单机场还贡后 不显示 横竖切换按钮
    end

end

function NetlessController:callbackMoveTribute(card, table)
    local status        = self._baseGameUtilsInfoManager:getStatus()
    if not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        return
    end

    local cardInfo = table.cardInfo
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end
    cardInfo:setVisible(false)
 
    local nDestChair = cardInfo.nDestChair
    local nindex = self:rul_GetDrawIndexByChairNO(nDestChair)

    SKHandCardsManager:getSKHandCards(nindex):cardsCountIncrease(1)
    SKHandCardsManager:ope_AddTributeAndReturnCard(nindex, cardInfo:getSKID())

    local playerManager = self._baseGameScene:getPlayerManager()
    if nDestChair == self:getMyChairNO() then
        local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
        if SKOpeBtnManager then
            SKOpeBtnManager:setReturnVisible(true)
            SKOpeBtnManager:setReturnEnable(false)
        end
        
        SKHandCardsManager:OPE_MaskCardForTributeAndReturn()
    end

    self._tributeIndexTime = self._tributeIndexTime + 1

    if self._tributeIndexTime < self._tributeCardnum then
        return
    end

    local WaitTime = self._baseGameUtilsInfoManager:getReturnWait()
    self._baseGameUtilsInfoManager:setStatus(MyGameDef.MYGAME_TS_WAITING_RETURN)
    local clock = self._baseGameScene:getClock()
    if clock then
        if 0 < self:getMyDrawIndex() then
            clock:moveClockHandTo(-1)
        end
        if WaitTime then
            clock:start(WaitTime)
        end
    end
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showReturn(true)
    end
end


function NetlessController:ope_CardsTribute(CardsTribute)

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        return
    end
    local drawIndex = self:rul_GetDrawIndexByChairNO(CardsTribute.chairno)
    
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    SKHandCardsManager:CreateTributeCard(CardsTribute.nCardID, drawIndex)

    local cardIDs = {}
    cardIDs[1] = CardsTribute.nCardID
    SKHandCardsManager:ope_ThrowCards(drawIndex, cardIDs, 1)

    if CardsTribute.chairno == self:getMyChairNO() then
        self:hideOperationBtns()
    end
end

function NetlessController:ope_CardsTributeOver(CardsTributeOver)
    self:hideOperationBtns()

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        return
    end
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end
    self._tributeIndexTime = 0
    
    for i = 1 , self:getTableChairCount() do
        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute > 0 then
            local nindex = self:rul_GetDrawIndexByChairNO(i -1)
            if SKHandCardsManager._tributeCard[1] == nil 
                or SKHandCardsManager._tributeCard[1]:getSKID() ~= self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID then
                SKHandCardsManager:CreateTributeCard(self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID, nindex)
                
                local cardIDs = {}
                cardIDs[1] = self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID

                SKHandCardsManager:ope_ThrowCards(nindex,cardIDs , 1)
                SKHandCardsManager:sortHandCards(nindex)
            end
        end
    end
    
    self._tributeCardnum = 0
    for i = 1 , self:getTableChairCount() do
        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute > 0 then
            local chairno = i
            local nWinChair = self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner
            local nCardID = self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID

            local card
            for j = 1 , 2 do
                if SKHandCardsManager._tributeCard[j] ~= nil 
                    and SKHandCardsManager._tributeCard[j]:getSKID() == self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID then
                    card = SKHandCardsManager._tributeCard[j]
                end
            end
            card.nDestChair = nWinChair
            card:setVisible(true)

            local delay = cc.DelayTime:create(2.0)
            local function callbackMoveTrCard(node, table)
                self:callbackMoveTrCard(node, table)
            end
            self._tributeCardnum = self._tributeCardnum + 1
            local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackMoveTrCard, {nWinChair = nWinChair, cardInfo = card }))
            card._SKCardSprite:runAction(sequence)
        end
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showTribute(false)
    end
end

function NetlessController:ope_CardsReturn(CardsReturn)

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
        return
    end
    local drawIndex = self:rul_GetDrawIndexByChairNO(CardsReturn.chairno)
    
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    SKHandCardsManager:CreateReturnCard(CardsReturn.nCardID, drawIndex)

    local cardIDs = {}
    cardIDs[1] = CardsReturn.nCardID
    SKHandCardsManager:ope_ThrowCards(drawIndex, cardIDs, 1)

    if CardsReturn.chairno == self:getMyChairNO() then
        self:hideOperationBtns()
        --SKHandCardsManager:sortHandCards(drawIndex)
        --SKThownCardsManager:ope_ThrowCards(drawIndex, CardsReturn.nCardID, 1)
    end

    local card
    for j = 1 , 2 do
        if SKHandCardsManager._returnCard[j] ~= nil 
            and SKHandCardsManager._returnCard[j]:getSKID() == CardsReturn.nCardID then
            card = SKHandCardsManager._returnCard[j]
        end
    end
    card.nDestChair = CardsReturn.nTributeChair
    card:setVisible(true)

    local delay = cc.DelayTime:create(2.0)
    local function callbackMoveReCard(node, table)
        self:callbackMoveReCard(node, table)
    end
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackMoveReCard, {nDestChair = CardsReturn.nTributeChair, cardInfo = card}))
    card._SKCardSprite:runAction(sequence)
end

function NetlessController:initGameController(baseGameScene)
    NetlessController.super.initGameController(self, baseGameScene)
    self.haveBombDouble = true
end

function NetlessController:showExchangeExitPrompt()
    -- 单机房不用显示 对局送兑换券的窗口，所以不用干任何事情
end

function NetlessController:getCurrentExchangeBoutInfo()
    -- 单机房结算界面不用显示 对局送兑换券相关
    return nil
end

function NetlessController:onSocketError()
    print("NetlessController:onSocketError and do nothing")
end

function NetlessController:onNotifyKickedOffByAdmin()
    print("NetlessController:onNotifyKickedOffByAdmin and do nothing")
end

function NetlessController:onNotifyKickedOffByLogonAgain()
    print("NetlessController:onNotifyKickedOffByLogonAgain and do nothing")
end

--单机场不显示积分跳转
function NetlessController:onRestart()
    self:onCloseResultLayer()
    self:clearGameTable()
    self:ResetArrageButton()
    self:resetPlayer()
    if self._canReturnChartered then    
        if self:isTeamGameRoom() and self:isHallEntery() then
            if not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                self:tipMessageByKey("G_GAME_RETURN_TEAMROOM_TIP")
                self:showCharteredRoom(true)
            end
            if self:isNeedDeposit() then
                self:LookSafeDeposit()
                self.bGameToRestart = false
            end
            return
        end
    end
    self._canReturnChartered = true
    if self:isNeedDeposit() then
        self:LookSafeDeposit()
        self.bGameToRestart = true
    end
end

function NetlessController:onCloseResultLayerEx()
    self:onCloseResultLayer()
    self:ResetArrageButton()

    if self._canReturnChartered then    
        if self:isTeamGameRoom() and self:isHallEntery() then
            if not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                self:tipMessageByKey("G_GAME_RETURN_TEAMROOM_TIP")
                self:showCharteredRoom(true)
            end
--            return
        end
    end
    self._canReturnChartered = true

    if self:isNeedDeposit() then
        self:LookSafeDeposit()
        self.bGameToRestart = false
        --积分场弱化
        self:onJumpToScoreRoom()
    end
end

return NetlessController