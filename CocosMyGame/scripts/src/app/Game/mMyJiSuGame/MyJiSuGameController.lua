
local MyJiSuGameController = class("MyJiSuGameController", import("src.app.Game.mMyGame.MyGameController"))
local MyJiSuGameUtilsInfoManager = import("src.app.Game.mMyJiSuGame.MyJiSuGameUtilsInfoManager")
local MyJiSuGameData = import("src.app.Game.mMyJiSuGame.MyJiSuGameData")
local MyJiSuGameConnect = import("src.app.Game.mMyJiSuGame.MyJiSuGameConnect")
local MyJiSuGameNotify = import("src.app.Game.mMyJiSuGame.MyJiSuGameNotify")
local MyJiSuCalculator = import("src.app.Game.mMyJiSuGame.MyJiSuCalculator")
local MyJiSuDaQiangAni = import("src.app.Game.mMyJiSuGame.MyJiSuDaQiangAni")

local AdvertModel          = import('src.app.plugins.advert.AdvertModel'):getInstance()
local AdvertDefine         = import('src.app.plugins.advert.AdvertDefine')

local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()

function MyJiSuGameController:ope_GameInfoShow(showFocus)

    local MyGameUtilsInfoManager    = self._baseGameUtilsInfoManager
    if not MyGameUtilsInfoManager then
        return
    end
    if not self._baseGameScene then return end

    local SceneNode = self._baseGameScene._gameNode
    if not SceneNode then 
        print("error SceneNode is nil")
        return 
    end

    local value = SceneNode:getChildByName("Panel_BoutInfo"):getChildByName("Value_ScoreSilver")
    
    if self:isNeedDeposit() then
        if MyGameUtilsInfoManager._utilsStartInfo.nBaseDeposit == nil then
            MyGameUtilsInfoManager._utilsStartInfo.nBaseDeposit = 0
        end
        value:setString(tostring(MyGameUtilsInfoManager._utilsStartInfo.nBaseDeposit))

        local PlayerSilver = SceneNode:getChildByName("Panel_BoutInfo"):getChildByName("PlayerScore_lab")
        PlayerSilver:setVisible(true)

        local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
        local utf8Name = roomInfo.szRoomName     -- 房间名称
        if string.find(utf8Name, "2") then
            utf8Name = string.gsub(utf8Name,"2","");
        end

        if PUBLIC_INTERFACE.IsStartAsArenaPlayer() then--竞技场
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_COMPETITION")..utf8Name
        elseif PUBLIC_INTERFACE.IsStartAsNoShuffle() then --"不洗牌"
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_NOSHUFFLE")..utf8Name
        elseif PUBLIC_INTERFACE.IsStartAsFriendRoom() then --"好友场"
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_FRIEND")..utf8Name
        elseif PUBLIC_INTERFACE.IsStartAsJiSu() then --"极速掼蛋"
            local index = RoomListModel.roomGradeNameToIndex[roomInfo.gradeName]
            utf8Name = "血战" .. RoomListModel.roomGradeConfig[index].nameZh .. "场"
        else
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_CLASS")..utf8Name    --"经典场"
        end
        SceneNode:getChildByName("Panel_BoutInfo"):getChildByName("room_info"):setString(utf8Name)
    else
        if MyGameUtilsInfoManager._utilsStartInfo.nBaseScore == nil then
            MyGameUtilsInfoManager._utilsStartInfo.nBaseScore = 0
        end
        value:setString(tostring(MyGameUtilsInfoManager._utilsStartInfo.nBaseScore))

        local SceneNode = self._baseGameScene._gameNode
        local PlayerScore = SceneNode:getChildByName("Panel_BoutInfo"):getChildByName("PlayerScore_lab")
        PlayerScore:setVisible(true)

        local nRoomID       =  self._baseGameUtilsInfoManager:getRoomID()
        if nRoomID ~= RoomListModel.OFFLINE_ROOMINFO["nRoomID"]  then
            local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
            local utf8Name = ""
            if roomInfo then
                utf8Name = roomInfo.szRoomName     -- 房间名称
            end
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_FUN")..utf8Name    --"娱乐场"
            SceneNode:getChildByName("Panel_BoutInfo"):getChildByName("room_info"):setString(utf8Name) 

            --玩家当前积分
            if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
                if cc.exports.nScoreInfo.nScore and cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports._gameJsonConfig.WeakenScoreRoom.Score > 0 
		            and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports.nScoreInfo.nReward == 0 then
                    local str = "（" .. cc.exports.nScoreInfo.nScore .. "/" .. cc.exports._gameJsonConfig.WeakenScoreRoom.Score .. "）"
                    SceneNode:getChildByName("Panel__Score"):getChildByName("Score"):setString(str)
                    SceneNode:getChildByName("Panel__Score"):setVisible(true)
                end
            end
        end
    end

    --TODO 设置左上角界面
end

function MyJiSuGameController:ResetGameGuide()
end

function MyJiSuGameController:createGameData()
    self._baseGameData = MyJiSuGameData:create()
    cc.exports.oneRoundGameWinData={}
end

function MyJiSuGameController:createUtilsInfoManager()
    self._baseGameUtilsInfoManager = MyJiSuGameUtilsInfoManager:create()
    self:setUtilsInfo()
end

function MyJiSuGameController:setConnect()
    self._baseGameConnect = MyJiSuGameConnect:create(self)
end

function MyJiSuGameController:setNotify()
    self._baseGameNotify = MyJiSuGameNotify:create(self)
end

function MyJiSuGameController:onGameStart(data)
    print("MyJiSuGameController:onGameStart")
    self:hideBannerAdvert()
    
    self._canReturnChartered = false

    self._playerInfo = {}
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        for i= 1,self:getTableChairCount() do
            local info = playerInfoManager:getPlayerInfo(i)
            self._playerInfo[i] = clone(info)
        end
    end

    self._selfChairNO = self:getMyChairNO()

    self._havemovedcard = 0
    self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum = 0
    self._baseGameUtilsInfoManager._utilsStartInfo.GameStarCards = true
       
    self._baseGameUtilsInfoManager:setWaitChair(-1)

    for i = 0 , 3 do
        for j = 1, 4 do
            self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[j] = 0
        end
    end

    for i = 1, 4 do
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:FreshPlace(drawIndex, 0)
        end
    end  
    
    self:gameRun()

    if self._dispatch then
        self._dispatch:setStartMatch(false)
    end
    self:onGameStartForCharteredRoom(data)

    self:playGamePublicSound("Snd_ArrageTable.mp3")

    self:showWaitArrangeTable(false)

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onGameStart()
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:onGameStart()
    end

    local gameStart = nil
    if self._baseGameData then
        gameStart = self._baseGameData:getGameStartInfo(data)
    end

    if gameStart then
        if self._baseGameUtilsInfoManager then
            self._baseGameUtilsInfoManager:setStartInfo(gameStart)
            self._baseGameUtilsInfoManager:clearTableInfo()
        end
    end

    local gameInfo = self._baseGameScene:getGameInfo()
    if gameInfo then
        gameInfo:setBaseScore(tostring(self:getBaseScore()))
    end

    local setCardCtrl = self._baseGameScene:getSetCardCtrl() --急速掼蛋理牌界面
    if setCardCtrl then
        setCardCtrl:onGameStart()
    end

    if self._baseGameUtilsInfoManager then
        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
        if SKHandCardsManager then
            local cardsCounts = self._baseGameUtilsInfoManager:getCardsCount()

            for i = 1, self:getTableChairCount() do
                local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
                if 0 < drawIndex then
                    SKHandCardsManager:setHandCardsCount(drawIndex, cardsCounts[i])
                    if drawIndex == self:getMyDrawIndex() then
                        local chairCards = self._baseGameUtilsInfoManager:getSelfStartCards()
                        SKHandCardsManager:setSelfHandCards(chairCards) 
                        SKHandCardsManager:hideSelfHandCards()      --暂时隐藏
                    end
                end
            end
        end
    end

    if gameStart then
        self:ope_GameInfoShow(true)
        self:ope_GameStart()
    end

    --去掉本局打2的动画
    --self._baseGameScene:showRankCard(self._baseGameUtilsInfoManager._utilsStartInfo.nRank[self._baseGameUtilsInfoManager._utilsStartInfo.nRanker+1])
    self._baseGameScene:setMyRuleBtnVisible(false)
    if gameStart.nBoutCount == 1 then --只在打第一局时显示
        self._baseGameScene:GameStartTip()
    end
    self:stopCheckOffline()

    self:stopJumpOtherRoomSchedule()

    if self._baseGameScene._JumpRoomPrompt then
        self._baseGameScene._JumpRoomPrompt:removePrompt()
        self._baseGameScene._JumpRoomPrompt = nil
    end

    if self._ExchangeQuitPrompt then    -- 开局的时候，如果有兑换券弹窗，关闭它
        self._ExchangeQuitPrompt:onClose() -- 释放定时器，关闭窗口等
        self._ExchangeQuitPrompt = nil
    end

    if self._baseGameConnect then
        --self._baseGameConnect:sendSDKInfo()
    end
end

function MyJiSuGameController:onDXXW(IsReturnBack)
    --第一局屏蔽跑马灯
    local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
    local user = mymodel("UserModel"):getInstance()
    if user.nBout and user.nBout == 0 then
        BroadcastModel:stopInsertMessage()
    end

    self:readLogCache()
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

    if self._baseGameConnect then
        self._baseGameConnect:sendMsgToServer(SKGameDef.SK_SYSMSG_PLAYER_ONLINE)
    end
    
    self:onCancelRobot()
    self:OPE_HideNoBiggerTip()

    cc.exports.isQuickStart = false

    if not self._baseGameUtilsInfoManager then
        return
    end

    if self._roundOverTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._roundOverTimerID)
        self._roundOverTimerID = nil
    end

    if IsReturnBack then
        self:gameStop()
        self:clearGameTable()
    end
    
    self._baseGameScene:setMyRuleBtnVisible(false)

    self:showAutoCombBtn(false)
    
    local status = self._baseGameUtilsInfoManager:getStatus()
    if not status or 0 == status then
        self:gameStop()
        self:clearGameTable()
    else
        if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_PLAYING_GAME) then
            self:gameRun()
        end
        --清理桌面信息
        self._canReturnChartered = false
      
        if self._dispatch then
            self._dispatch:setStartMatch(false)
        end

        self:showWaitArrangeTable(false)
        
        self:ope_ShowStart(false)

        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:onGameStart()
        end    
        --清理桌面信息

        local gameTools = self._baseGameScene:getTools()
        if gameTools then
            gameTools:onGameStart()
        end

        local gameInfo = self._baseGameScene:getGameInfo()
        if gameInfo then
            gameInfo:setBaseScore(tostring(self:getBaseScore()))
        end

        --重置计分板
        local scoreCtrl = self._baseGameScene:getGameScoreCtrl()
        if scoreCtrl then
            scoreCtrl:resetValues()
        end

        --隐藏理牌界面
        local setCardCtrl = self._baseGameScene:getSetCardCtrl() --急速掼蛋理牌界面
        if setCardCtrl then
            setCardCtrl:setVisible(false)
        end

        --禁用bottombar的按钮状态
        local bottomBarCtrl = self._baseGameScene:getBottomBarCtrl()
        if bottomBarCtrl then
            bottomBarCtrl:setAllBtnDisable()
        end

        if self:isGameRunning() and self._baseGameUtilsInfoManager then
            local waitChair = self._baseGameUtilsInfoManager:getWaitChair()

            local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
            if SKHandCardsManager then

                SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):setVisible(true)

                SKHandCardsManager:resetHandCardsManager()

                local cardsCounts = self._baseGameUtilsInfoManager:getCardsCount()
                
                local gameInfoJS = self._baseGameUtilsInfoManager:getGameInfoJS() --获取急速掼蛋断线续玩信息
                for i = 1, self:getTableChairCount() do
                    local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
                    if 0 < drawIndex then
                        SKHandCardsManager:setHandCardsCount(drawIndex, cardsCounts[drawIndex])

                        if drawIndex == self:getMyDrawIndex() then
                            local myChairNO = self:getMyChairNO()
                            
                            if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then 
                                setCardCtrl:setVisible(true)
                                if gameInfoJS.adjustOver[myChairNO+1] > 0 then
                                    local dunCards = self._baseGameUtilsInfoManager:getJSDunCardIDs(myChairNO)
                                    for i = 1,3 do
                                        setCardCtrl:setDunCardIDs(i, dunCards[i], #dunCards[i])
                                    end
                                    setCardCtrl:setStatusReady() --设置理牌panel状态禁用
                                else
                                    local chairCards = clone(self._baseGameUtilsInfoManager:getSelfDXXWCards())
                                    local dunCards = setCardCtrl:getAllCardIDs()
                                    local removeCount = 0
                                    for k = 1,3 do
                                        for n = 1, #dunCards[k] do
                                            table.removebyvalue(chairCards, dunCards[k][n])
                                        end
                                        removeCount = removeCount +  #dunCards[k]
                                    end
                                    
                                    SKHandCardsManager:setHandCardsCount(drawIndex, cardsCounts[drawIndex] - removeCount)

                                    SKHandCardsManager:setSelfHandCards(chairCards, true)
                                    SKHandCardsManager:ope_SortSelfHandCards()

                                    setCardCtrl:onDXXWnotReset() --重新显示理牌panel
                                    bottomBarCtrl:refreshBtnStatus() --刷新底部按钮状态

                                    self:showAutoCombBtn(true)
                                end
                            elseif self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
                                local nRound = gameInfoJS.currentDunIndex
                                if type(nRound) ~= 'number' or nRound < 0 or gameInfoJS.currentDunIndex > 3 then
                                    return
                                end
                                self._baseGameUtilsInfoManager:setRoundInfo(nRound)
                                for i = 1,3 do
                                    scoreCtrl:setRoundValue(i, gameInfoJS.dunResult[myChairNO+1][i])
                                end
                                local dunCards = self._baseGameUtilsInfoManager:getJSDunCardIDs(myChairNO)
                                SKHandCardsManager:setHandCardsWhenThrow(dunCards, nRound)
                            end
                        end
                        self:setCardsCount(drawIndex, cardsCounts[drawIndex], false)
                    end
                end

                SKHandCardsManager:setEnableTouch(true)
                if waitChair == -1 then
                    SKHandCardsManager:setFirstHand(1)
                else
                    SKHandCardsManager:setFirstHand(0)
                end
            end

            --断线重连设置报警状态
            self:setPlayerAlarm()

            local SKThownCardsManager = self._baseGameScene:getSKThrownCardsManager()
            if SKThownCardsManager then
                local bankerIndex = self:getBankerDrawIndex()
                local throwCards = self._baseGameUtilsInfoManager:getJSThrowedCardIDs()
                local currentIndex = self:rul_GetDrawIndexByChairNO(self._baseGameUtilsInfoManager:getCurrentChair())
                local preIndex = self:getPreIndex(currentIndex)
                local bankerChairNO = self:rul_GetChairNOByDrawIndex(bankerIndex)
                local currentCount = #throwCards[bankerChairNO+1]
                for i = 1, self:getTableChairCount() do
                    local chairNO = self:rul_GetChairNOByDrawIndex(preIndex)
                    if #throwCards[chairNO+1] > 0 and currentCount == #throwCards[chairNO+1] then
                        local uniteTypes = MyJiSuCalculator:getDunUniteType(throwCards[chairNO+1])
                        SKThownCardsManager:ope_ThrowCards(preIndex, throwCards[chairNO+1], #throwCards[chairNO+1], uniteTypes[1].dwCardType)
                    end
                    
                    preIndex = self:getPreIndex(preIndex)
                end
            end

            local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()

            local clock = self._baseGameScene:getClock()
            local currentIndex = self:rul_GetDrawIndexByChairNO(self._baseGameUtilsInfoManager:getCurrentChair())

            local hideToolsBut = false
            
            if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then      
                local WaitTime = self._baseGameUtilsInfoManager:getSetCardWait() - self._baseGameUtilsInfoManager._utilsStartInfo.nReserved[1]
                if WaitTime <= 0 then
                    WaitTime = 3
                end
                if clock then
                    clock:moveClockToSetCard()
                    if WaitTime then
                        clock:start(WaitTime)
                    end
                end
            elseif self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
                local nTime = self._baseGameUtilsInfoManager:getThrowWait() - self._baseGameUtilsInfoManager._utilsStartInfo.nReserved[1]

                if nTime <= 0 then
                    nTime = 3
                end

                if clock then
                    clock:start(nTime)
                    clock:moveClockHandTo(currentIndex)
                end
                
                if currentIndex == self:getMyDrawIndex() then
                    self:showOperationBtns()
                end
            end

            self:ope_ShowGameInfo(true)
            local gameTools = self._baseGameScene:getTools()
            if gameTools then
                gameTools:ope_StartPlay()
            end

            if hideToolsBut then
                if gameTools then
                    gameTools:onHideOtherButton()
                end
            end

            self:OPE_FreshBomgRecord()
            self:ope_GameInfoShow(true)

            self._baseGameScene:doSomethingForVerticalCard()    -- 短线重连后的竖排相关的处理
        end
    end
end

function MyJiSuGameController:OPE_FreshBomgRecord()
end

function MyJiSuGameController:ResetArrageButton()
end

function MyJiSuGameController:ope_ThrowCards(cardsThrow)
    if not cardsThrow then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    local MyPlayerManager           = self._baseGameScene:getMyPlayerManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsThrow.nChairNO)
    if drawIndex == self:getMyDrawIndex() then
        SKHandCardsManager:ope_UnselectSelfCards()
    end

    --倒计时结束关闭新手引导
    if self._guideStatus ~= MyGameDef.NEWUSERGUIDE_NOT_OPEN then
        local nGuideBout = self._baseGameUtilsInfoManager._utilsStartInfo.nGuideBout
        if nGuideBout == 1 and self._guideStatus ~= MyGameDef.NEWUSERGUIDE_BOUTONE_FINISHED then
            self:playNewUserGuideBoutOneFinished()
        elseif nGuideBout == 2 and SELF._guideSatus ~= MyGameDef.NEWUSERGUIDE_BOUTTWO_FINISHED then
            self:playNewUserGuideBoutTwoFinished()
        end
    end

    self:OPE_HideNoBiggerTip()

    self._baseGameUtilsInfoManager:setWaitUniteInfo(cardsThrow)
    self._baseGameUtilsInfoManager:setWaitChair(cardsThrow.nChairNO)

    self:playCardsEffect(cardsThrow)
    self:ope_showThrowAnimation(cardsThrow)

    if cardsThrow.nWinPlayce ~= 0 then
        self:RobScoreStart(cardsThrow.nWinPlayce, cardsThrow.nChairNO)
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:FreshPlace(drawIndex, cardsThrow.nWinPlayce)
        end
    end

    local nRound = self._baseGameUtilsInfoManager:getRoundInfo()
    SKHandCardsManager:ope_ThrowCards(drawIndex, cardsThrow.nCardIDs, cardsThrow.nCardsCount, nRound)
--    SKHandCardsManager:sortHandCards(drawIndex) --ope_ThrowCards已经有排序。。  
    SKHandCardsManager:setFirstHand(0)
    if drawIndex ~= self:getMyDrawIndex() then
        SKHandCardsManager:moveHandCards(drawIndex, false)

        --自己牌已出完，更新玩家手牌
        if SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):getHandCardsCount() <= 0 then
            if drawIndex == self:getOppositeIndex() then
                SKHandCardsManager:updataFriendCards(cardsThrow.nCardIDs, cardsThrow.nCardsCount)                
            end
        end
    else  --自己手上没牌了
        if SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):getHandCardsCount() <= 0 then
            self._baseGameScene:setMyRuleBtnVisible(true)
        end
    end

    SKThownCardsManager:ope_ThrowCards(drawIndex, cardsThrow.nCardIDs, cardsThrow.nCardsCount, cardsThrow.dwCardType)

    local nextIndex = self:rul_GetDrawIndexByChairNO(cardsThrow.nNextChair)

    if cardsThrow.nChairNO ~= cardsThrow.nNextChair then   --PS:惯蛋最后手牌下一个玩家会是自己 不移除牌
        --SKThownCardsManager:moveThrow(nextIndex)
    end   

    local clock = self._baseGameScene:getClock()
    local throwWait =  cardsThrow.nWaitTime--self._baseGameUtilsInfoManager:getThrowWait()

    if clock then
        clock:setVisible(true)
        clock:start(throwWait)
        clock:moveClockHandTo(nextIndex)
    end

    --一轮结束
    local chairNO = self:rul_GetChairNOByDrawIndex(self:getMyDrawIndex())
    local bRoundOver = false
    for i = 1, 4 do
        local score = (cardsThrow.nReserved or {})[i + 1]
        if score and score ~= -1 then
            bRoundOver = true
        end
    end
    if bRoundOver then
        local score = (cardsThrow.nReserved or {})[chairNO + 1]
        local scoreCtrl = self._baseGameScene:getGameScoreCtrl()
        if scoreCtrl and nRound then
            scoreCtrl:setRoundValue(nRound, score)
        end
        for i = 1, 4 do
            local winPoint = (cardsThrow.nReserved or {})[i] or 0
            self:OPE_ShowBombBonu(i-1, winPoint)
        end
        if nRound and type(nRound) ~= 'number'then
           self._baseGameUtilsInfoManager:setRoundInfo(nRound + 1)
        end
    end

    local bankerDrawIndex = self:getBankerDrawIndex()
    if drawIndex == bankerDrawIndex then
        local nextIndexTemp = nextIndex
        for i = 1, self:getTableChairCount() - 1 do
            SKThownCardsManager:moveThrow(nextIndexTemp)
            nextIndexTemp = self:getNextIndex(nextIndexTemp)
        end
    end

    local roundOverScheduler = function ()
        self._roundOverTimerID = nil
        if not self._baseGameUtilsInfoManager or self._baseGameScene == nil or tolua.isnull(self._baseGameScene) then
            return false
        end
        local status = self._baseGameUtilsInfoManager:getStatus()
        if status and 0 ~= status then 
            if self:isGameRunning() then
                self:showOperationBtns()
            end
        end
    end
    if nextIndex == self:getMyDrawIndex() and self:isGameRunning() then 
        if bRoundOver and nRound ~= 3 then
            self._roundOverTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(roundOverScheduler, 3.0, false)
        else
            roundOverScheduler()
        end
    else
        self:hideOperationBtns()        
    end
  
    self:ResetArrageButton()

    self:onRefreshTableInfoWhenGameStartLost()

    -- 广告模块 start
    print("AdvertModel:MyJiSuGameController:ope_ThrowCards")
    print("self._hasShowBanner: ", self._hasShowBanner)
    if self:isShowBanner() and not self._hasShowBanner then
        AdvertModel:showBannerAdvert()
        self._hasShowBanner = true
    end
    -- 广告模块 end
end

function MyJiSuGameController:clearGameTable()
    print("MyJiSuGameController:clearGameTable")
    self:OPE_HideNoBiggerTip()
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showTribute(false)
        selfInfo:showReturn(false)
    end
    local gameScene = self._baseGameScene
    if gameScene.cardBg then
        gameScene.cardBg:stopAllActions()
        gameScene.cardBg:removeFromParentAndCleanup()
        gameScene.cardBg = nil
    end
    if gameScene.cardft then
        gameScene.cardft:stopAllActions()
        gameScene.cardft:removeFromParentAndCleanup()
        gameScene.cardft = nil
    end

    local scoreCtrl = self._baseGameScene:getGameScoreCtrl()
    if scoreCtrl then
        scoreCtrl:resetValues()
    end

    self:showAutoCombBtn(false)

    MyJiSuGameController.super.super.clearGameTable(self)
end

function MyJiSuGameController:ope_CheckSelect()

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKOpeBtnManager           = self._baseGameScene:getSKOpeBtnManager()
    if not SKHandCardsManager or not SKOpeBtnManager then return false end

    local cardsThrow, cardsCount    = SKHandCardsManager:getMySelectCardIDs()
    local bFirstHand                = SKHandCardsManager:isFirstHand()

    if not cardsThrow or not cardsCount then return false end
    
    local status        = self._baseGameUtilsInfoManager:getStatus()

    --是理牌阶段
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        --获取每墩的现存的牌信息
        local setCardCtrl = self._baseGameScene:getSetCardCtrl()
        if not setCardCtrl then return end
        local cardIDs = setCardCtrl:getAllCardIDs()
        --判断哪几墩能够接收
        local result = MyJiSuCalculator:calcWhichDunCanAccept(cardIDs, cardsThrow, cardsCount)
        --通知setcardctrl，让对应墩显示高亮
        setCardCtrl:onSelectHandCard(result)
    end

    if not self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then return false end

    self:ResetArrageButton()
    
    if not SKOpeBtnManager:isThrowVisible()  then return false end    
    local nRound = self._baseGameUtilsInfoManager:getRoundInfo()
    if not nRound then return false end
    local bEnableThrow = self:isEnableThrow(nRound, cardsThrow, cardsCount)
    SKOpeBtnManager:setThrowEnable(true)

    return bEnableThrow
end

function MyJiSuGameController:onThrow()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end
    SKHandCardsManager:onHint()
    self:onThrowCard(SKHandCardsManager:getMySelectCardIDs())
end

function MyJiSuGameController:isEnableThrow(nRound, cardsThrow, cardsCount)
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end

    local roundCardsCount = {
        MyJiSuGameDef.FIRST_DUN_CARD_COUNT,
        MyJiSuGameDef.SECOND_DUN_CARD_COUNT,
        MyJiSuGameDef.THIRD_DUN_CARD_COUNT,
    }
    if nRound <= 0 and nRound > 3 then return false end
    if roundCardsCount[nRound] ~= cardsCount then return false end
    local inhandCards, inhandCardsCount = SKHandCardsManager:getHandCardIDs(self:getMyDrawIndex(), nRound)
    if inhandCardsCount ~= cardsCount then return false end
    for i = 1, inhandCardsCount do
        local bFind = false
        for j = 1, cardsCount do
            if inhandCards[i] == cardsThrow[j] then
                bFind = true
            end
        end
        if not bFind then
            return false
        end
    end
    return true
end

function MyJiSuGameController:onThrowCard(cardIDs, cardsLen)
    --在出牌时记录理牌的情况
    self:LogSortCard()
    --理牌埋点end
    if not cardIDs or not cardsLen or cardsLen == 0 then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not self._baseGameConnect then
        return
    end

    self:hideOperationBtns()

    local unitDetails = MyJiSuCalculator:getDunUniteType(cardIDs)
    unitDetails[1].nCardIDs = cardIDs
    unitDetails[1].nCardsCount = cardsLen
--    --出牌时让理牌中提示可以从头开始找
    SKHandCardsManager:resetRemind()
    self._baseGameConnect:reqThrowCards(unitDetails[1], self._bAutoPlay)
end

function MyJiSuGameController:containsTouchLocation_GameRule(gameRule, x, y)
    local bResult = false
    if gameRule then
        local panel = gameRule:getChildByName("Panel_Rule")
        if panel then
            local pos = cc.p(panel:getPosition())
            local ppos = panel:getParent():convertToWorldSpace(pos)
            local node = self._baseGameScene._gameNode:getChildByName("Operate_Panel")
            local position = node:convertToNodeSpace(ppos)
            local s = panel:getBoundingBox()
            local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
            bResult = cc.rectContainsPoint(touchRect, cc.p(x, y))
        end
    end
    return bResult
end

function MyJiSuGameController:onTouchBegan(x, y)
    local SKGameTools = self._baseGameScene:getTools()
    if SKGameTools then
        if SKGameTools:containsTouchLocation(x, y) then
            return
        else
            self:onCancelRobot()
        end
    end

    local curScene = cc.Director:getInstance():getRunningScene()
    local gameRule = curScene:getChildByName("JiSuGameRulePlugin")
    if gameRule and gameRule:isVisible() then
        if self:containsTouchLocation_GameRule(gameRule, x,y) then
            return
        end
    end

    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        if SKOpeBtnManager:containsTouchLocation(x, y) then
            self._touchBeginInOpeBtn = true
            return
        end
    end

    local SKGameScene = self._baseGameScene
    if SKGameScene then
        if SKGameScene:containsTouchLocation(x, y) then
            return
        end
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        if playerManager:containsTouchInfoLocation(x, y) then
            return
        end
        if not playerManager:containsTouchLocation(x, y) then
            playerManager:onHidePlayerInfo()
        else
            return
        end
    end

    --临时调整卡牌和操作按钮触摸层级
    self:_adjustTouchPriBetweenCardAndOperateBtn()

    local status = self._baseGameUtilsInfoManager:getStatus()

    --是理牌阶段
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        local setCardCtrl = self._baseGameScene:getSetCardCtrl()
        if not setCardCtrl then return end

        -- 点击的是理牌panel或者panel中的控件
        local bClick, panelIndex = setCardCtrl:isClickPanel(x, y)
        if bClick then
            if setCardCtrl:isPanelEnable(panelIndex) then
                setCardCtrl:selectDun(panelIndex)
            else
                --判断点击的是否是牌
            end
            return
        end

        local bottomBarCtrl = self._baseGameScene:getBottomBarCtrl()
        --判断是否是点击了底部按钮
        local bClickBottom = bottomBarCtrl:isClickBottomBtn(x, y)
        if bClickBottom then
            return
        end
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        if not SKHandCardsManager:containsTouchLocation(x, y) then
            SKHandCardsManager:ope_UnselectSelfCards()
            --要不起时点击空白区域直接pass
            if self._cardStatus == MyGameController._CARD_STATUS.NO_BIGGER then 
                self:onPassCard()
                self._cardStatus = MyGameController._CARD_STATUS.NORMAL
            end
            SKHandCardsManager:resetSelectShapeIndex()
        else
            SKHandCardsManager:touchBegan(x, y)
        end
    end
end

function MyJiSuGameController:onTouchMoved(x, y)

    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        if SKOpeBtnManager:containsTouchLocation(x, y) then
            if self._touchBeginInOpeBtn ==  true then
                return
            end
        end
    end
    
    local curScene = cc.Director:getInstance():getRunningScene()
    local gameRule = curScene:getChildByName("JiSuGameRulePlugin")
    if gameRule and gameRule:isVisible() then
        if self:containsTouchLocation_GameRule(gameRule, x,y) then
            return
        end
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        if playerManager:containsTouchInfoLocation(x, y) then
            return
        end
        if not playerManager:containsTouchLocation(x, y) then
            playerManager:onHidePlayerInfo()
        else
            return
        end
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        if SKHandCardsManager:containsTouchLocation(x, y) then
            SKHandCardsManager:touchMove(x, y)
        end
    end
end

--设置牌到墩上
function MyJiSuGameController:setDunCards(index, cardIDs, cardsCount)
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager  then return false end
    local setCardCtrl = self._baseGameScene:getSetCardCtrl()
    if not setCardCtrl then return end

    --手牌中对应的牌移除
    SKHandCardsManager:ope_ThrowCards(self:getMyDrawIndex(), cardIDs, cardsCount)
    --对应墩增加牌
    setCardCtrl:setDunCardIDs(index, cardIDs, cardsCount)
    --刷新bottombar的按钮状态
    local bottomBarCtrl = self._baseGameScene:getBottomBarCtrl()
    if bottomBarCtrl then
        bottomBarCtrl:refreshBtnStatus()
    end
end

--玩家点击墩panel
function MyJiSuGameController:onClickDun(index)
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager  then return false end

    local cardsThrow, cardsCount    = SKHandCardsManager:getMySelectCardIDs()
    self:setDunCards(index, cardsThrow, cardsCount)
end

function MyJiSuGameController:resetDunCards(cardIDs)
    print("MyJiSuGameController:resetDunCards")
    if #cardIDs <= 0 then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager  then return false end

    --还原墩中的牌
    SKHandCardsManager:resetDunCards(cardIDs)

    --刷新bottombar的按钮状态
    local bottomBarCtrl = self._baseGameScene:getBottomBarCtrl()
    if bottomBarCtrl then
        bottomBarCtrl:refreshBtnStatus()
    end
end

function MyJiSuGameController:ope_StartPlay()    
    self:OPE_FreshBomgRecord()

    --self._baseGameScene:hideRankCard()

    local drawIndex = self:getMyDrawIndex()
    local WaitTime = 0
    if self._baseGameUtilsInfoManager then
        drawIndex = self:getBankerDrawIndex()
        WaitTime = self._baseGameUtilsInfoManager:getSetCardWait()

        self._baseGameUtilsInfoManager:setStatus(MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST)
    end
   
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    
    local clock = self._baseGameScene:getClock()

    if SKHandCardsManager then
        SKHandCardsManager:setEnableTouch(true)
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onStartPlayToShrinkAnimation()
        playerManager:onStartPlayToShowLevelAnimation()
    end

    if self._baseGameUtilsInfoManager then
        if clock then
            clock:moveClockToSetCard()
            if WaitTime then
                clock:start(WaitTime)
            end
        end

        self:ope_ShowGameInfo(true)

        local gameTools = self._baseGameScene:getTools()
        if gameTools then
            gameTools:ope_StartPlay()
        end
        --self:showBanker(drawIndex)
    end

    self._baseGameUtilsInfoManager._utilsStartInfo.GameStarCards = false

    self._baseGameScene:doSomethingForVerticalCard()    -- 发完牌开局

    --刷新bottombar的按钮状态
    local bottomBarCtrl = self._baseGameScene:getBottomBarCtrl()
    if bottomBarCtrl then
        bottomBarCtrl:resetUsingQuickOpe()
        bottomBarCtrl:refreshBtnStatus()
    end
end

function MyJiSuGameController:clickSetCardConfirm(dunUniteTypes)
    print("MyJiSuGameController:clickSetCardConfirm")
    dump(dunUniteTypes, "dunUniteTypes")
    local bottomBarCtrl = self._baseGameScene:getBottomBarCtrl()
    local nUsingQuickOpe = 0
    if bottomBarCtrl then
        nUsingQuickOpe = bottomBarCtrl:getUsingQuickOpe()
    end
    self._baseGameConnect:reqAdjustCardOver(dunUniteTypes, nUsingQuickOpe)
end

function MyJiSuGameController:onAdjustFailed()
    local status = self._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        local setCardCtrl = self._baseGameScene:getSetCardCtrl()
        if not setCardCtrl then return end

        setCardCtrl:onGameStart()
    end
end

function MyJiSuGameController:onGameClockZero()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end

    local status = self._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
        local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
        if self:isClockPointToSelf() and SKOpeBtnManager:isThrowVisible() then
            local nRound = self._baseGameUtilsInfoManager:getRoundInfo()
            local inhandCards, inhandCardsCount = SKHandCardsManager:getHandCardIDs(self:getMyDrawIndex(), nRound)
            if not inhandCards or inhandCardsCount <= 0 then return end
            local bEnableThrow = self:isEnableThrow(nRound, inhandCards, inhandCardsCount)
            if bEnableThrow then
                self:onThrowCard(inhandCards, inhandCardsCount)
                self:onAutoPlay(true)
                return
            end
        end
        
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        local setCardCtrl = self._baseGameScene:getSetCardCtrl()
        if not setCardCtrl then return end
        if not setCardCtrl:isClickedConfirm() then
            printError("3333333auto set cards")
            setCardCtrl:resetAllDun() --重置理牌堆的牌
            self:autoSetCards()
            local uniteType = setCardCtrl:getDunUniteTypes()
            if #uniteType == 3 then
                setCardCtrl:clickConfirm()
                self:onAutoPlay(true)
            else
                printError("auto setcard error")
                self:onAutoPlay(false)
            end
        end
    end
end

function MyJiSuGameController:AutoComb()
    local setCardCtrl = self._baseGameScene:getSetCardCtrl()
    if not setCardCtrl then return end

    if not setCardCtrl:isClickedConfirm() then
        printError("4444444 autoComb set cards")
        setCardCtrl:resetAllDun() --重置理牌堆的牌
        self:autoSetCards()
        local uniteType = setCardCtrl:getDunUniteTypes()
        if #uniteType ~= 3 then
            printError("auto setcard error")
        end
    end
end

function MyJiSuGameController:autoPlay()
    self:onGameClockZero()
end

function MyJiSuGameController:onRobot()
    if self:isGameRunning() then
        local status = self._baseGameUtilsInfoManager:getStatus()
        if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) 
        or self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then         
            self:onAutoPlay(not self._bAutoPlay)
        end
    end
end

--自动理牌
function MyJiSuGameController:autoSetCards()
    local handCardManager = self._baseGameScene:getSKHandCardsManager()
    if not handCardManager then return end

    local myHandCards = handCardManager:getSKHandCards(self:getMyDrawIndex())
    if not myHandCards then return nil end

    local inhandCards, inHandCardsCount = myHandCards:getHandCardIDs()

    local dunCardIDs = MyJiSuCalculator:autoSetCards(inhandCards, inHandCardsCount)
    for i = 1, #dunCardIDs do
        self:setDunCards(i, dunCardIDs[i], #dunCardIDs[i])
    end
end

function MyJiSuGameController:onGameMsg(data)     

    local MsgInfo = nil
    if self._baseGameData then
        MsgInfo = self._baseGameData:getGameMsg(data)
    end

    if MsgInfo.nMsgID == MyJiSuGameDef.HAGD_GAME_MSG_ADJUST_OVER then
        local gameMsgInfo, adjustMsgInfo = nil, nil
        if self._baseGameData then
            gameMsgInfo, adjustMsgInfo = self._baseGameData:getGameMsgAdjustOver(data)
        end
        self:onAdjustOver(adjustMsgInfo[1])
    elseif MsgInfo.nMsgID == MyGameDef.HAGD_GAME_MOVECARD_OVER then
        self:NTF_MoveOver()
    end
end

--收到理牌结束消息
function MyJiSuGameController:onAdjustOver(adjustMsgInfo)     
    print("MyJiSuGameController:opeAdjustOver")
    if not adjustMsgInfo then
        print("error opeAdjustOver adjustMsgInfo is nil")
        return
    end
    local setCardCtrl = self._baseGameScene:getSetCardCtrl()
    if not setCardCtrl then return end
    --判断是不是自己的理牌结束消息，是的话根据结构设置理牌
    if adjustMsgInfo.nChairNO == self:getMyChairNO() then
        local dunCardIDs = {{},{},{}}
        local selfDunCardIDs = setCardCtrl:getAllCardIDs()
        for i = 1, 3 do
            for j = 1, adjustMsgInfo.cardTypeCount[i] do
                local unite = adjustMsgInfo.cardType[i][j]
                for k = 1, #unite.nCardIDs do
                    if unite.nCardIDs[k] ~= -1 then
                        table.insert(dunCardIDs[i], unite.nCardIDs[k])
                    end
                end
            end
        end
        local bNeedReset = false
        for i = 1, 3 do
            if not MyJiSuCalculator:isSameCardIDs(selfDunCardIDs[i], dunCardIDs[i]) then
                bNeedReset = true
                break
            end
        end
        if bNeedReset then
            printError("needReset jisu card")
            setCardCtrl:resetAllDunCards()
            --设置手牌
            local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
            if not SKHandCardsManager  then return end

            local myHandCards = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())
            if not myHandCards then return nil end
            local inhandCards, inHandCardsCount = myHandCards:getHandCardIDs()

            SKHandCardsManager:ope_ThrowCards(self:getMyDrawIndex(), inhandCards, inHandCardsCount)
            for i = 1, 3 do
                setCardCtrl:setDunCardIDs(i, dunCardIDs[i], #dunCardIDs[i])
            end
        end
        setCardCtrl:setStatusReady()
        
        self:showAutoCombBtn(false)
    end

    --所有玩家都理完牌
    if adjustMsgInfo.bAllAdjustOver and adjustMsgInfo.bAllAdjustOver == 1 then
        --隐藏理牌界面
        setCardCtrl:setVisible(false)
        --设置底部状态
        local bottomBarCtrl = self._baseGameScene:getBottomBarCtrl()
        if bottomBarCtrl then
            bottomBarCtrl:setAllBtnDisable()
        end

        local bankerIndex = self:getBankerDrawIndex()
        local throwWait = 0

        if self._baseGameUtilsInfoManager then
            --设置游戏状态
            self._baseGameUtilsInfoManager:setStatus(BaseGameDef.BASEGAME_TS_WAITING_THROW)
            self._baseGameUtilsInfoManager:setRoundInfo(1) --设为第一轮
            throwWait = self._baseGameUtilsInfoManager:getThrowWait()
        end

        --设置时钟
        local clock = self._baseGameScene:getClock()
        if clock then
            clock:start(throwWait)
            clock:moveClockHandTo(bankerIndex)

            if self:getMyDrawIndex() == bankerIndex then
                self:showOperationBtns()
            end
        end
        
        --设置手牌
        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
        if not SKHandCardsManager  then return end
        SKHandCardsManager:setHandCardsWhenThrow(setCardCtrl:getAllCardIDs(), 1)
        SKHandCardsManager:setEnableTouch(true)
    end
end

function MyJiSuGameController:onGameWin(data)
    print("onGameWin:hideBannerAdvert")
    self:hideBannerAdvert()

    self:onGameOneSetEnd(data)
    
    self._havemovedcard = 0
    self._n5BombDouble  = nil

    if self._needReturnRoomID then  --跳转后需要玩一把才能跳回原来房间
        self._canGobackRoom = true
    end

    self:setResume(false)
    self:gameStop()
    self:startAutoQuitTimer()

    if not self:isResume() then
        self:setResponse(self:getResWaitingNothing())
    end

    local clock = self._baseGameScene:getClock()
    if clock then
        clock:resetClock()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onHidePlayerInfo()
        playerManager:onGameWin()
    end

    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox then
        safeBox:showSafeBox(false)
    end

    --隐藏理牌界面
    local setCardCtrl = self._baseGameScene:getSetCardCtrl() --急速掼蛋理牌界面
    if setCardCtrl then
        setCardCtrl:resetAllDunCards()
        setCardCtrl:setVisible(false)
    end

    --禁用bottombar的按钮状态
    local bottomBarCtrl = self._baseGameScene:getBottomBarCtrl()
    if bottomBarCtrl then
        bottomBarCtrl:setAllBtnDisable()
    end

    local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
    CenterCtrl:notifyPluginByName("AutoSupplyCtrl") --隐藏自动存取银界面

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
    self._baseGameScene:setSortTypeBtnEnabled(false)
    self:onCancelRobot()
   
    MyGameController._sortFlag = SKGameDef.SORT_CARD_BY_ORDER

    local gameWin = nil
    if self._baseGameData then
        gameWin = self._baseGameData:getGameWinInfo(data)
    end
    if gameWin then
        print("------------------------------function MyJiSuGameController:onGameWin(data)------------------------------------")
        dump(gameWin)
        self._baseGameUtilsInfoManager.bEndedExit = gameWin.bEnableLeave

        self:onUpdateScoreInfo(gameWin)
      
        self:startTimeResultClose()

        local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
        if not SKHandCardsManager or not SKThownCardsManager then return end

        for i = 1, self:getTableChairCount() do
            local score = gameWin.gamewin.nScoreDiffs[i]
            local deposit = gameWin.gamewin.nDepositDiffs[i]
            local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
            if 0 < drawIndex then
                self:addPlayerScore(drawIndex, score)
                self:addPlayerDeposit(drawIndex, deposit)
                self:addPlayerBoutInfo(drawIndex, score)
            end

            if self:getMyDrawIndex() == drawIndex then
                self:hideOperationBtns()

                local nFriendCardIDs = {}
                local nFriendCardsCount = 0
                local myHandCards = SKHandCardsManager:getSKHandCards(drawIndex)
                if myHandCards and  myHandCards.getFriendCardsCount then
                    if myHandCards:getFriendCardsCount() > 0 then  -- 结算时，如果显示的是对家手牌
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

            self._baseGameUtilsInfoManager._utilsStartInfo.nPlace[i] = 0 --重置下数据看看

            SKThownCardsManager:hidePassTip(drawIndex)
        end

        local callback = function ()
            if self:isArenaPlayer() then --竞技场不跳原来的结算界面
                self._baseGameScene:setArenaGameResult(gameWin)
                TimerManager:scheduleOnceUnique("Timer_GameScene_DelayedNormalGameResultOnGameWin", function()
                    if self:isInGameScene() == false then return end
                    self:UpgradeLevelForArenaPlayer(gameWin)
                end, 2.0)
                --[[my.scheduleOnce(function()
                    if self:isInGameScene() == false then return end
                    self:UpgradeLevelForArenaPlayer(gameWin)
                end, 2)]]--
            else
                -- 延时2s播放结算界面
                TimerManager:scheduleOnceUnique("Timer_GameScene_DelayedNormalGameResultOnGameWin", function()
                    self:showGameResultInfo(gameWin)
                    if gameWin.nExchangeVouNum[self:getMyChairNO() + 1] > 0 then   
                        --播放获得兑换券或银子动画
                        self._baseGameScene:showBreakEggsAnimation(8,  gameWin.nExchangeVouNum[self:getMyChairNO() + 1])
                    end
                end, 2.0)
                --[[my.scheduleOnce(function()
                    if self:isInGameScene() == false then return end
                    -- 延时2s播放结算界面
                    self:showGameResultInfo(gameWin)
                    if gameWin.nExchangeVouNum[self:getMyChairNO() + 1] > 0 then   
                        --播放获得兑换券或银子动画
                        self._baseGameScene:showBreakEggsAnimation(8,  gameWin.nExchangeVouNum[self:getMyChairNO() + 1])
                    end
                end, 2)]]--
            end

            --动画播放完后才能退出
            local gameTools = self._baseGameScene:getTools()
            if gameTools then
                gameTools:onGameWin()
            end
        end
        --播放打枪动画，播放完成后，调用callback
        local daqiangResult = clone(gameWin.nDaQiang)
        MyJiSuDaQiangAni:setGameController(self)
        MyJiSuDaQiangAni:playDaQiangAni(daqiangResult, callback)

        local playerInfoManager = self:getPlayerInfoManager()

        local selfInfo = {}
        selfInfo.nUserID = playerInfoManager:getSelfUserID()
        selfInfo.nChairNO = playerInfoManager:getSelfChairNO()

        --游戏结束不发送请求点赞的消息
        -- my.scheduleOnce(function()
        --     if self:isInGameScene() == false then return end
        --     self:OnUpInfo(selfInfo)
        -- end, 0.5)
             
        for i = 0 ,3 do
            self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[4] = 0
        end   
        
        --是否更新下其他玩家等级数据
        my.scheduleOnce(function()
            if self:isInGameScene() == false then return end
            for i = 0, 3 do
                if i ~= self:getMyChairNO() then
                    local drawIndexLevel = self:rul_GetDrawIndexByChairNO(i)
                    if playerManager:getGamePlayerByIndex(drawIndexLevel) then 
                        local levelData = playerManager:getGamePlayerByIndex(drawIndexLevel)._playerLevelData
                        local playerInfo = playerInfoManager:getPlayerInfo(drawIndexLevel)
                        if levelData and levelData.nLevelExp < levelData.nNextExp and playerInfo then
                            if levelData.nLevelExp + gameWin.nLevelExpUp[i+1] >= levelData.nNextExp then
                                UserLevelModel:sendGetUserLevelReq(playerInfo.nUserID)
                            end
                        end
                    end
                end
            end
        end, 0.5)
        
        self:ChangeParamTask(1,1)
        if gameWin.nPlace[self:getMyChairNO()+1] == 1 then
            self:ChangeParamTask(3,1)
        end
        if gameWin.nPlace[self:getMyChairNO()+1] == 1
            or gameWin.nPlace[(self:getMyChairNO()+3)%MyGameDef.MY_TOTAL_PLAYERS] == 1 then
            self:ChangeParamTask(2,1)
        end

        if self:isNeedDeposit() then
            local GameWinYinzi = gameWin.gamewin.nDepositDiffs[self:getMyChairNO() + 1]
            if cc.exports.oneRoundGameWinData.gameNum == nil then
                cc.exports.oneRoundGameWinData.gameNum = 0      -- 局数
                cc.exports.oneRoundGameWinData.gameWinNum = 0   -- 胜利局数
                cc.exports.oneRoundGameWinData.gameWinMoney = 0 -- 输赢银子数
                cc.exports.oneRoundGameWinData.getUpNum = 0      -- 点赞
            end
            cc.exports.oneRoundGameWinData.gameNum = cc.exports.oneRoundGameWinData.gameNum + 1
            cc.exports.oneRoundGameWinData.gameWinMoney = cc.exports.oneRoundGameWinData.gameWinMoney + GameWinYinzi

            local winChairNo = -1
            for i = 1, 4 do
                if gameWin.nPlace[i] == 1 then
                    winChairNo = i
                    break
                end
            end
            winChairNo = winChairNo - 1
            local MyGameUtilsInfoManager    = self._baseGameUtilsInfoManager  
            if winChairNo == self:getMyChairNO() or winChairNo == MyGameUtilsInfoManager:RUL_GetNextChairNO(MyGameUtilsInfoManager:RUL_GetNextChairNO(self:getMyChairNO())) then
                cc.exports.oneRoundGameWinData.gameWinNum = cc.exports.oneRoundGameWinData.gameWinNum + 1
            end

            --当前局数加1
            -- WeakenScoreRoomModel:onAddBoutInfo()
        end
        if cc.exports.oneRoundGameWinData.getVoucherNum == nil then -- 兑换券数
            cc.exports.oneRoundGameWinData.getVoucherNum = 0
        end
        cc.exports.oneRoundGameWinData.getVoucherNum = cc.exports.oneRoundGameWinData.getVoucherNum + gameWin.nExchangeVouNum[self:getMyChairNO() + 1]

        if self._GoldeEggTaskData then  --更新金蛋的任务数
            if self._GoldeEggTaskData.nExchangeRoundNum >= self._GoldeEggTaskData.nMaxRoundNum then
            else
                self._GoldeEggTaskData.nExchangeRoundNum = self._GoldeEggTaskData.nExchangeRoundNum + 1
                self._baseGameScene:updateGoldeEggData(self._GoldeEggTaskData)
            end
        end

        self._baseGameScene:setMyRuleBtnVisible(true)
    end
    --发送理牌日志
    self:sendSortCardLog()

    local player=mymodel('hallext.PlayerModel'):getInstance()
    player:update({'UserGameInfo'})

    local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
    BroadcastModel:ReStartInsertMessageEx()

    --自动补银
    --刷新银两
    player:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    print("before do autosupply")
    my.scheduleOnce(function()
        if self:isSupportAutoSupply() then
            self:doSupply()
        end
    end, 2)
end

function MyJiSuGameController:playCardsEffect(cardsThrow)
    self:playGamePublicSound("Snd_Throw.mp3")
    --local setData = self._baseGameScene:getSetting()
    --local langauge = setData._selectedLangauge
    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsThrow.nChairNO) 
    local sex = self._baseGamePlayerInfoManager:getPlayerNickSexByIndex(drawIndex)
    
    --local path = self:GetSoundsPath(cardsThrow)
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local bFirstHand = SKHandCardsManager:isFirstHand()
    
    local strPath = ""
    if sex == 1 then
        strPath = "res/Game/GameSound/CardType/Mandarin/Female/female_"
    else
        strPath = "res/Game/GameSound/CardType/Mandarin/Male/"
    end
   
    local fileName = nil
   
    local dwType        = cardsThrow.dwCardType
    
    math.randomseed(os.time())

    local num = math.random(0,5)
    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then          
        fileName = "zhadan"..tostring(num)
        if cardsThrow.nCardsCount < 5 then
            self:playGamePublicSound("Snd_Bomb.mp3")
        else
            self:playGamePublicSound("Snd_Bomb5.mp3")
        end
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then
        fileName = "tonghuashun"
        self:playGamePublicSound("tonghuashun.mp3")
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        fileName = "superbomb"
        self:playGamePublicSound("chaojidazhadan.mp3")
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then
        fileName = "siwangzha"
        self:playGamePublicSound("Snd_4King.mp3")
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        self:playGamePublicSound("Snd_feiji.mp3")
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        --预留
    end

    if fileName ~= nil then
        local pathName = strPath .. fileName.. ".mp3"
        audio.playSound(pathName, false)
        return
    end
   
    local cardindex = MyCalculator:getCardIndex(cardsThrow.nCardIDs[1])+1

    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
        fileName = "sandaier"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        fileName = "Shunzi"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
        fileName = "sanliandui"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        fileName = "gangban"
    end
    if fileName == nil then
        return
    end

    local pathName = strPath .. fileName..".mp3"
    audio.playSound(pathName, false)
end

function  MyJiSuGameController:showAutoCombBtn(isVisible)
    self._baseGameScene:showAutoCombBtn(isVisible)
end

-- 发牌结束后再显示一键理牌
function MyJiSuGameController:onDealCardOver()
    self:showAutoCombBtn(true)
    MyJiSuGameController.super.onDealCardOver(self)
end

-- 切后台恢复执行onResume
function MyJiSuGameController:onResume()
    print("MyJiSuGameController:onResume")
    self:showAutoCombBtn(false)

    MyJiSuGameController.super.onResume(self)
end

function MyJiSuGameController:resetNewUserGuide()
end

return MyJiSuGameController