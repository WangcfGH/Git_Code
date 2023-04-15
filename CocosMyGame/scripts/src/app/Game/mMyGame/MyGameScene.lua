
local SKGameScene = import("src.app.Game.mSKGame.SKGameScene")
local MyGameScene = class("MyGameScene", SKGameScene)

local SKGameDef                     = import("src.app.Game.mSKGame.SKGameDef")
local MyGameDef                     = import("src.app.Game.mMyGame.MyGameDef")
local CanvasLayer                   = import("src.app.Game.mCommon.CanvasLayer")

local MyGameController              = import("src.app.Game.mMyGame.MyGameController")

local MyGameLoadingPanel            = import("src.app.Game.mMyGame.MyGameLoadingPanel")

local SKHandCards                   = import("src.app.Game.mSKGame.SKHandCards")
local MyHandCards                   = import("src.app.Game.mMyGame.MyHandCards")
-- 竖向理牌
local MyHandCardsCustom                   = import("src.app.Game.mMyGame.MyHandCardsCustom")

local SKShownCards                  = import("src.app.Game.mSKGame.SKShownCards")
local MyShownCards                  = import("src.app.Game.mMyGame.MyShownCards")
local MyHandCardsManager            = import("src.app.Game.mMyGame.MyHandCardsManager")
local MyThrownCards                 = import("src.app.Game.mMyGame.MyThrownCards")
local MyThrownCardsManager          = import("src.app.Game.mMyGame.MyThrownCardsManager")
local MyGameInfo                    = import("src.app.Game.mMyGame.MyGameInfo")
local MyGameSelfInfo                = import("src.app.Game.mMyGame.MyGameSelfInfo")
local MyOpeBtnManager               = import("src.app.Game.mMyGame.MyOpeBtnManager")
local MyGameClock                   = import("src.app.Game.mMyGame.MyGameClock")
local MyResultPanel                 = import("src.app.Game.mMyGame.MyResultPanelEx")
local MyGameUtilsInfoManager                    = import("src.app.Game.mMyGame.MyGameUtilsInfoManager")
local MyCalculator                              = import("src.app.Game.mMyGame.MyCalculator")
local MyGamePlayerManager                  = import("src.app.Game.mMyGame.MyGamePlayer.MyGamePlayerManager")
local MyGamePlayer                  = import("src.app.Game.mMyGame.MyGamePlayer.MyGamePlayer")
local MyGameSelfPlayer                  = import("src.app.Game.mMyGame.MyGamePlayer.MyGameSelfPlayer")
local MyGameChat                    = import("src.app.Game.mMyGame.MyGameChat.MyGameChat")

local MyGamePromptAllowances        = import("src.app.Game.mMyGame.MyGamePromptAllowances")
local MyGamePromptTakeSilver        = import("src.app.Game.mMyGame.MyGamePromptTakeSilver")
local MyGamePromptRecharge        = import("src.app.Game.mMyGame.MyGamePromptRecharge")
local MyGamePromptMoreMoney        = import("src.app.Game.mMyGame.MyGamePromptMoreMoney")
local MyGamePromptExitRoom        = import("src.app.Game.mMyGame.MyGamePromptExitRoom")
local MyGamePromptGoBackRoom        = import("src.app.Game.mMyGame.MyGamePromptGoBackRoom")
local MyGamePromptExitTipExchange  = import("src.app.Game.mMyGame.MyGamePromptExitTipExchange")

local MyGameArenaInfo         = import("src.app.Game.mMyGame.MyGameArena.MyGameArenaInfo")
local MyGameArenaStatement         = import("src.app.Game.mMyGame.MyGameArena.MyGameArenaStatement")
local MyGameArenaOverStatement         = import("src.app.Game.mMyGame.MyGameArena.MyGameArenaOverStatement")
local MyGameArenaGameResult         = import("src.app.Game.mMyGame.MyGameArena.MyGameArenaGameResult")

local MyCalculator                  = import("src.app.Game.mMyGame.MyCalculator")

local MyGameStart        = import("src.app.Game.mMyGame.MyGameStart")
local MyHandCardsCache   = import("src.app.Game.mMyGame.MyHandCardsCache"):getInstance()

local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local KickedOffCtrl = require('src.app.plugins.kickedout.KickedOutCtrl')

local windowSize = cc.Director:getInstance():getWinSize()

local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()

local player=mymodel('hallext.PlayerModel'):getInstance()
local user=mymodel('UserModel'):getInstance()

local relief=mymodel('hallext.ReliefActivity'):getInstance()
local ArenaModel = import("src.app.plugins.arena.ArenaModel"):getInstance()
local TaskModel = import("src.app.plugins.MyTaskPlugin.TaskModel"):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()
local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local UserLevelModel = import("src.app.plugins.personalinfo.UserLevelModel"):getInstance()

local WinningStreakDef        = import('src.app.plugins.WinningStreak.WinningStreakDef')
local WinningStreakModel      = import("src.app.plugins.WinningStreak.WinningStreakModel"):getInstance()
local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local NobilityPrivilegeDef        = import('src.app.plugins.NobilityPrivilege.NobilityPrivilegeDef')

local BankruptcyModel = import('src.app.plugins.Bankruptcy.BankruptcyModel'):getInstance()
local BankruptcyDef = require('src.app.plugins.Bankruptcy.BankruptcyDef')

local WeekCardModel = import('src.app.plugins.WeekCard.WeekCardModel'):getInstance()
local WeekCardDef = require('src.app.plugins.WeekCard.WeekCardDef')

local MyGameCardMakerTool = import("src.app.Game.mMyGame.MyGameCardMaker.MyGameCardMakerTool")

local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local TimingGameDef = require('src.app.plugins.TimingGame.TimingGameDef')

local SKGameTools = import('src.app.Game.mSKGame.SKGameTools')

local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(MyGameScene,PropertyBinder)

function MyGameScene:OnJumpedRoom()
    cc.exports.EnterGameFromGame = true
    self:initGameController()
    self:createNetwork()
    --self:playXiaJiangAni()
end

function MyGameScene:ctor(app, name)
    print("Hello Game!")
    self._MyOrderSortBtn            = nil
    self._MyColorSortBtn              = nil
    self._MyBoomBtn                = nil
    self._MyNumSortBtnEx           = nil
    self._MyArrageBtn              = nil
    self._MyRecoverBtn              = nil
    self._MyResetBtn                = nil
    self._MyNodeExpression          = nil

    self._MyFinishTaskNode           = nil
    self._MyFinishTaskNodePos       =cc.p(0,0)

    self._MyPanel_Odds              = nil
    self._OtherBtn                  = {}

    self._myHandCards               = {}
    self._myHandCardsCustom         = {}
    self._throwHandCards            = {}

    self.cardBg = nil
    self.cardft = nil

    self._ExpressionOpened          = false

    SKGameDef.SK_CARD_START_POS_Y = 25
    MyGameScene.super.ctor(self, app, name)

    self:listenTo(player, player.PLAYER_DATA_UPDATED, handler(self,self.onUpdatePlayerData))

    self:listenTo(ShopModel, ShopModel.EVENT_UPDATE_RICH,handler(self, self.onUpdateRich))
    self:listenTo(relief,relief.RELIEF_TAKE_FAILED,handler(self,self.onTakeReliefFailed))
    self:listenTo(relief,relief.RELIEF_DATA_UPDATED,handler(self,self.onTakeReliefSuccess))

    --监听等级的
    self:listenTo(UserLevelModel, UserLevelModel.UPDATE_SELF_LEVEL_DATA,handler(self,self.onUpdateSelfLevel))
    self:listenTo(UserLevelModel, UserLevelModel.UPDATE_OTHER_LEVEL_DATA,handler(self,self.onUpdateOtherLevel))
    --兑换券
    self:listenTo(ExchangeCenterModel,ExchangeCenterModel.TICKET_LEFT_NUM_UPDATED,handler(self,self.onUpdateExchangeNum))

    self:listenTo(KickedOffCtrl,KickedOffCtrl.KICKED_OFF_CLOSE,handler(self,self.onKickedOffClose))
    
    self:listenTo(HallContext, HallContext.EVENT_MAP["roomManager_enterRoomOk"], handler(self, self.onEnterRoomOKForGameScene))
    --self:listenTo(enterGameInfo, enterGameInfo.ENTER_ROOM_OK, handler(self,self.onEnterRoomOKForGameScene))

    --大厅保险箱操作回调
    --self:listenTo(player,player.PLAYER_SAFEBOX_GAME_SAFE_SUCCEED,handler(self,self.onSafeDepositSucceedForHall)) 
    --self:listenTo(player,player.PLAYER_SAFEBOX_GAME_TAKE_SUCCEED,handler(self,self.onTakeDepositSucceedForHall)) 
    --排名上升监听
    self:listenTo(ArenaModel, ArenaModel.EVENT_MAP["ARENA_USER_RANKUP"],handler(self,self.onArenaUserRankUp)) 
    if cc.exports.isBankruptcySupported() then
        self:listenTo(BankruptcyModel, BankruptcyDef.BANKRUPTCY_APPLY_BAG_RSP, handler(self,self.showBankruptcyGiftResult))
        self:listenTo(BankruptcyModel, BankruptcyDef.BANKRUPTCY_STATUS_RSP, handler(self,self.onGetBankruptcyRspStauts))
        self:listenTo(BankruptcyModel, BankruptcyDef.BANKRUPTCY_TIME_UPDATE, handler(self, self.onBankruptcyTimeUpdate))
        self:listenTo(WeekCardModel, WeekCardDef.WEEK_CARD_STATUS_RSP, handler(self,self.onGetWeekCardRspStauts))
    end

    --连胜挑战
    if cc.exports.isWinningStreakSupported() then
        self:listenTo(WinningStreakModel, WinningStreakDef.WinningStreakInfoRet, handler(self,self.refreshWinningStreakBtn))
        self:listenTo(WinningStreakModel, WinningStreakDef.WinningStreakAwardRet, handler(self,self.refreshAwardRetDeposit))
    end

    --记牌器购买
    self:listenTo(ShopModel, ShopModel.EVENT_UPDATE_CARD_MAKER, handler(self, self.setCardMakerInfo))
    self:listenTo(CardRecorderModel, CardRecorderModel.CARD_MAKER_UPDATE,handler(self, self.updateCardMakerCountInGame))

    --self:listenTo(TaskModel, TaskModel.UPDATE_TASK_RED_DOT,handler(self,self.updateTaskRedDot))
    self:listenTo(TaskModel, TaskModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))

    self:listenTo(NobilityPrivilegeModel, NobilityPrivilegeDef.NobilityPrivilegeInfoRet, handler(self,self.freshNobilityPrivilege))
    
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getApplySucceedFromSvr"], handler(self, self.freshTimingGameScore))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getRobotInfoDataFromSvr"], handler(self, self.freshRobotTimingGameScore))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_restartGame"], handler(self, self.restartGameByTimingGame))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_addGameBout"], handler(self, self.refreshTimingGameTicketTaskBtn))

    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_YQYL_RED_DOT, handler(self, self.setInviteGiftIcon))

    local cache = MyHandCardsCache:readFromCacheData()
    if not cache then
        -- 如果cache是nil 则强制默认竖牌  2019年5月23日 需求
        MyHandCardsCache:setHandCardsModeCache(true)
    end

    if not CCH_PLATFORM_WINDOWS then
        self:setBackAndFrontGroundEvent()
    end
end

function MyGameScene:setBackAndFrontGroundEvent()
    local function enterBackGround()
        --17期客户端埋点
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_ENTER_BACK_GROUND)
    end

    local function enterForeGround()
        --17期客户端埋点
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_ENTER_FORE_GROUND)
    end

    -- add back ground event
    local backGroundEvent = "SceneGame_EnterBackGround"
    AppUtils:getInstance():removePauseCallback(backGroundEvent)
    AppUtils:getInstance():addPauseCallback(enterBackGround, backGroundEvent)
    -- add front ground event
    local foreGroundEvent = "SceneGame_EnterForeGround"
    AppUtils:getInstance():removeResumeCallback(foreGroundEvent)
    AppUtils:getInstance():addResumeCallback(enterForeGround, foreGroundEvent)
end

function MyGameScene:cancelBackAndFrontGroundEvent()
    -- add back ground event
    local backGroundEvent = "SceneGame_EnterBackGround"
    AppUtils:getInstance():removePauseCallback(backGroundEvent)
    -- add front ground event
    local foreGroundEvent = "SceneGame_EnterForeGround"
    AppUtils:getInstance():removeResumeCallback(foreGroundEvent)
end

function MyGameScene:setBankruptcyBtn()
    if not self._gameNode then return end

    self._bankruptBtn = self._gameNode:getChildByName("Btn_LimitTimeGift")
    self._bankruptBtn:setVisible(false)

    self:onBankruptcyTimeUpdate()
end

function MyGameScene:onBankruptcyTimeUpdate()
    if not self._bankruptBtn then return end

    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() or PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        self._bankruptBtn:setVisible(false)
        return
    end

    local timeStr = BankruptcyModel:getLeftTimeStr()
    if timeStr == "" then
        self:hideBankruptcyBtn()
        return 
    end

    self._bankruptBtn:getChildByName("time"):setString(timeStr)
    self._bankruptBtn:setVisible(true)

    self:refreshTopRightBtns()
end

function MyGameScene:hideBankruptcyBtn()
    print("MyGameScene:hideBankruptcyBtn")
    if self._bankruptBtn then
        self._bankruptBtn:setVisible(false)
        self:refreshTopRightBtns()
    end
end

function MyGameScene:setStart()
    if not self._gameNode then return end

    local NodeStart = self._gameNode:getChildByName("Panel_Start")
    NodeStart:setVisible(true)
    local startPanel = NodeStart:getChildByName("Node_Start"):getChildByName("Panel_OperationBtn")
    if startPanel then
        self._start = MyGameStart:create(startPanel, self._gameController)
    end

    self:setBankruptcyBtn()
end

function MyGameScene:onTakeReliefFailed(data)
    if self._gameController then
        self._gameController:onTakeReliefFailed(data)
    end
end

function MyGameScene:onTakeReliefSuccess(data)
    if self._gameController then   
        self._gameController:onTakeReliefSuccess(data)
    end
end

function MyGameScene:onUpdateRich()
    if self._gameController then   
        self._gameController:onUpdateRich()
    end
end

function MyGameScene:onUpdateSelfLevel()
    if self._gameController then   
        self._gameController:onUpdateSelfLevel()
    end
end

function MyGameScene:onUpdateOtherLevel(data)
    if self._gameController then   
        self._gameController:ShowOtherUserLevel(data.value)
    end
end

function MyGameScene:onUpdateExchangeNum()
    if self._gameController then   
        self._gameController:onUpdateExchangeNum()
    end
end

function MyGameScene:onKickedOffClose()
    if self._gameController then
        self._gameController:onKickedOffClose()
    end
end

function MyGameScene:onEnterRoomOKForGameScene()
    if self._gameController then
        self._gameController:onEnterRoomOKForGameScene()
    end
end

function MyGameScene:onSafeDepositSucceedForHall(data)
    if self._gameController then
        self._gameController:onSaveSafeDeposit(data.value)
    end
end

function MyGameScene:onTakeDepositSucceedForHall(data)
    if self._gameController then
        self._gameController:onTakeSafeDeposit(data.value)
    end
end

function MyGameScene:onArenaUserRankUp(data)
    if self._gameController ~= nil then
        self._gameController:onArenaUserRankUp(data)
    end
end

function MyGameScene:setControllerDelegate()
    self._gameController = MyGameController
end

function MyGameScene:addLoadingNode()
    MyCalculator:CreateGameUtilsInfoManager()
    if not self._loadingLayer then return end

    self._loadingNode = MyGameLoadingPanel:create(self._gameController)
    if self._loadingNode then
        self._loadingLayer:addChild(self._loadingNode)
        self._loadingNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

local ThrowAnimationIndex = {
    1000000,
    SKGameDef.SK_CT_JOKER_BOMB,
    SKGameDef.SK_CT_BOMB,
    SKGameDef.SK_CT_BUTTERFLY,
    SKGameDef.SK_CT_ABT_COUPLE,
    SKGameDef.SK_CT_THREE2,
    SKGameDef.SK_CT_ABT_THREE,
}

local ThrowAnimationCsbPath = {
    "res/GameCocosStudio/csb/card_animation/Node_ShunZi.csb",
    "res/GameCocosStudio/csb/card_animation/Node_FourBombs.csb",
    "res/GameCocosStudio/csb/card_animation/Node_SuperBomb.csb",
    "res/GameCocosStudio/csb/card_animation/Node_Rocket.csb",
    "res/GameCocosStudio/csb/card_animation/Node_RoyalFlush.csb",
    "res/GameCocosStudio/csb/card_animation/Node_CardType.csb"
}

function MyGameScene:setThrowAnimation()
    if not self._gameNode then return end

    for i,v in pairs(ThrowAnimationCsbPath) do
        local csbPath = ThrowAnimationCsbPath[i]
        local animationNode = cc.CSLoader:createNode(csbPath)
        if animationNode then
            --[[animationNode:setPosition(cc.p(-500, -200))
            local index = ThrowAnimationIndex[i]
            self._SKThrownAnimation[index]          = animationNode
            self._SKThrownAnimationCsbPath[index]   = csbPath
            self._gameNode:addChild(self._SKThrownAnimation[index])
            self._SKThrownAnimation[index]:setLocalZOrder(SKGameDef.SK_ZORDER_THROWN_ANIMATION)--]]
        end
    end
end

function MyGameScene:getThrowCardTypeAnimation(dwType, cardsCount, drawIndex)
    local csbPath = ThrowAnimationCsbPath[6]
    local cardType = nil
    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        cardType = "animation_ShunZi"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then 
        cardType = "animation_LianSanZhang"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then 
        cardType = "animation_ThreeBandTwo"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then 
        cardType = "animation_LianDui"
    end
    if cardType == nil then
        return
    end
    local animationNode = cc.CSLoader:createNode(csbPath)
    local action = cc.CSLoader:createTimeline(csbPath)
    action:play(cardType, false)
    
    animationNode:setPosition(self:getAnimtionPos(cardsCount, drawIndex))
    self._gameNode:addChild(animationNode)  
    
    animationNode:setLocalZOrder(SKGameDef.SK_ZORDER_THROWN_ANIMATION)

    local callback = cc.CallFunc:create( function(sender)  
        animationNode:setVisible(false)
        animationNode:removeFromParentAndCleanup()
    end )  
 
    self:animationCallback(animationNode, action, callback)
end

function MyGameScene:getThrowAnimation(dwType, cardsCount, drawIndex)
    if not dwType or dwType <= 0 then return end

    self:getThrowCardTypeAnimation(dwType, cardsCount, drawIndex)
   
    local csbPath = nil
    local action = nil
    local animationNode = nil
    local pos = nil
    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        csbPath = ThrowAnimationCsbPath[1]
        animationNode = cc.CSLoader:createNode(csbPath)
        local animation = animationNode:getChildByName("Panel_ShunZi"):getChildByName("Animation_ShunZi")
        animation:getAnimation():playWithIndex(0)       
        action = cc.CSLoader:createTimeline(csbPath)
        if drawIndex == 1 or drawIndex == 4 then
            action:play("animation_ShunZi_R", false)
        else
            action:play("animation_ShunZi_L", false)
        end
        pos = display.center
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then      
        csbPath = ThrowAnimationCsbPath[1]
        animationNode = cc.CSLoader:createNode(csbPath)
        local animation = animationNode:getChildByName("Panel_ShunZi"):getChildByName("Animation_ShunZi")
        animation:getAnimation():playWithIndex(1)
        action = cc.CSLoader:createTimeline(csbPath)
        if drawIndex == 1 or drawIndex == 4 then
            action:play("animation_ShunZi_R", false)
        else
            action:play("animation_ShunZi_L", false)
        end      
        pos = display.center
    end


    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
        csbPath = ThrowAnimationCsbPath[2]
        action = cc.CSLoader:createTimeline(csbPath)
        action:play("animation_FourBombs", false)
        pos = self:getAnimtionPos(cardsCount, drawIndex)
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then
        csbPath = ThrowAnimationCsbPath[5]
        action = cc.CSLoader:createTimeline(csbPath)
        action:play("animation_RoyalFlush", false)
        pos = self:getAnimtionPos(cardsCount, drawIndex)
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        csbPath = ThrowAnimationCsbPath[3]
        action = cc.CSLoader:createTimeline(csbPath)
        action:play("animation_SuperBomb", false)
        pos = display.center
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then
        csbPath = ThrowAnimationCsbPath[4]
        action = cc.CSLoader:createTimeline(csbPath)
        action:play("animation_Rocket", false)
        pos = display.center
    end
    if not csbPath then
        return 
    end
    if animationNode == nil then    
        animationNode = cc.CSLoader:createNode(csbPath)
    end    
    animationNode:setPosition(pos)
    self._gameNode:addChild(animationNode)  

    animationNode:setLocalZOrder(SKGameDef.SK_ZORDER_THROWN_ANIMATION)

    local callback = cc.CallFunc:create( function(sender)  
        animationNode:setVisible(false)
        animationNode:removeFromParentAndCleanup()
    end )  
 
    self:animationCallback(animationNode, action, callback)
end

function MyGameScene:getAnimtionPos(cardsCount, drawIndex)
    if cardsCount > 9 then
        cardsCount = 9
    end

    local beginPos = self:getThrowCardsPosition(1, drawIndex, cardsCount)
    local endPos  = self:getThrowCardsPosition(cardsCount, drawIndex, cardsCount)
    local newX = (endPos.x + beginPos.x + self:getCardSize().width) / 2 
    local newY = (endPos.y + beginPos.y + self:getCardSize().height) / 2

    local offsetX = self:getOffsetXofOperatePanel()
    newX = newX + offsetX

    return cc.p(newX, newY)
end

function MyGameScene:getThrowCardsPosition(index, drawIndex, cardsCount)
    local startX, startY = self:getStartPoint(drawIndex)

    if self:isMiddlePlayer(drawIndex) then       --居中
        startX = startX - (self:getCardSize().width + (cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
    elseif self:isRightPlayer(drawIndex) then    --右对齐
        startX = startX - self:getCardSize().width - (cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL
    end
    startX = startX + (index - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL

    return cc.p(startX, startY)
end

function MyGameScene:getCardSize()
    return cc.size(94, 127)
end

function MyGameScene:getStartPoint(drawIndex)
    local node = self._gameNode
    if node then
        local thrownPosition = node:getChildByName("Panel_Card_thrown"..tostring(drawIndex))
        if thrownPosition then
            local startX, startY = thrownPosition:getPosition()
            if self:isRightPlayer(drawIndex) then
                startX = startX + thrownPosition:getContentSize().width
            end
            return startX, startY
        end
    end
    return 0, 0
end

function MyGameScene:isMiddlePlayer(drawIndex)
    return self._gameController:isMiddlePlayer(drawIndex)
end

function MyGameScene:isRightPlayer(drawIndex)
    return self._gameController:isRightPlayer(drawIndex)
end


function MyGameScene:animationCallback(node, action, callback, durationEx)
    local speed = action:getTimeSpeed()  
    local startFrame = action:getStartFrame()  
    local endFrame = action:getEndFrame()  
    local frameNum = endFrame - startFrame 
    local duration = 1.0 /(speed * 60.0) * frameNum
    if not durationEx then
        durationEx = 0
    end
    node:runAction(action)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(duration+durationEx), callback))  
end

function MyGameScene:setAutoPlay()
    if not self._gameNode then return end

    self._autoPlayPanel = self._gameNode:getChildByName("Panel_AutoPlay")
end

function MyGameScene:setUpInfo()
    if not self._gameNode then return end
    
    local upInfo = self._gameNode:getChildByName("Node_AttentionWords")
    if upInfo then
        self._upInfo = upInfo
        self._upInfoPosition = cc.p(self._upInfo:getPosition())
    end
end

function MyGameScene:getUpInfoPanel()
    return self._upInfo
end

function MyGameScene:setGameInfo()
    if not self._gameNode then return end

    local gameInfo = self._gameNode:getChildByName("panel_gameinfo")
    if gameInfo then
        self._gameInfo = MyGameInfo:create(gameInfo, self._gameController)
    end
end

function MyGameScene:setOpeBtns()
    if not self._gameNode then return end

    local opeBtns = self._gameNode:getChildByName("Node_OperationBtn"):getChildByName("Panel_OperationBtn")
    if opeBtns then
        self._SKOpeBtnManager = MyOpeBtnManager:create(opeBtns, self._gameController)
    end
end

function MyGameScene:setClock()
    if not self._gameNode then return end

    for i=1, 5 do
        local clockPanel = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock"..tostring(i))
        if clockPanel then
            clockPanel:setVisible(false)
        end
    end

    --设置自身倒计时Clock位置，刚好在两个按钮之间
    self:_adaptMyClockPosBetweenTwoOpeBtn()
    
    local clockPanel = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock1")
    self._gameNode:getChildByName("Panel_Clock"):setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
    if clockPanel then
        self._clock = MyGameClock:create(clockPanel, self._gameController)
    end
end

function MyGameScene:_adaptMyClockPosBetweenTwoOpeBtn()
    if self._gameNode == nil then return end

    local nodeOpeBtns = self._gameNode:getChildByName("Node_OperationBtn")
    local nodeMyClock = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock1")
    local panelClock = self._gameNode:getChildByName("Panel_Clock")
    local panelOpeBtns = nodeOpeBtns:getChildByName("Panel_OperationBtn")
    local btnOpeSkip = panelOpeBtns:getChildByName("Btn_Skip")
    local worldPosOfBtnOpeSkip = btnOpeSkip:getParent():convertToWorldSpace(cc.p(btnOpeSkip:getPosition()))
    local localPosOfBtnOpeSkip = nodeMyClock:getParent():convertToNodeSpace(worldPosOfBtnOpeSkip)
    nodeMyClock:setPositionX(localPosOfBtnOpeSkip.x + 168)
end

function MyGameScene:setHandCards()
    local handCards = {}
    for i = 1, self._gameController:getTableChairCount() do
        if (i == self._gameController:getMyDrawIndex()) then
--            handCards[i] = SKHandCards:create(i, self._gameController)
            if self._gameController:isSupportVerticalCardMode() and  self:isVerticalCardsMode() then    -- 竖排开关使能且 当前模式是竖排模式
                if not self._myHandCardsCustom[i] then
                    self._myHandCardsCustom[i] = MyHandCardsCustom:create(i, self._gameController)
                end
                handCards[i] = self._myHandCardsCustom[i]
            else
                if not self._myHandCards[i] then
                    self._myHandCards[i] = MyHandCards:create(i, self._gameController)
                end
                handCards[i] = self._myHandCards[i]
            end

        else
            if not self._throwHandCards[i] then
                self._throwHandCards[i] = MyShownCards:create(i, self._gameController)
            end
            handCards[i] = self._throwHandCards[i]
        end
    end

    self._SKHandCardsManager = MyHandCardsManager:create(handCards, self._gameController)
end

function MyGameScene:setGameCtrlsAboveSKGame()
end

function MyGameScene:addResultNode(gameWin)
    if not self._resultLayer then return end

    if PUBLIC_INTERFACE.IsStartAsTimingGame() then
        local TimingGameResult = import("src.app.plugins.TimingGame.TimingGameResult.TimingGameResultPanel")
        self._resultNode = TimingGameResult:create(gameWin, self._gameController)
        if self._resultNode then
            self._resultLayer:addChild(self._resultNode)
            self._resultNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
        end
    else
        self._resultNode = MyResultPanel:create(gameWin, self._gameController)
        if self._resultNode then
            self._resultLayer:addChild(self._resultNode)
            self._resultNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    
            local playerInfoManager = self._gameController:getPlayerInfoManager()
            local playerInfo = playerInfoManager:getPlayerInfo(self._gameController:getMyDrawIndex())
            local userDeposit = playerInfo.nDeposit
    
            local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
            local nDeposit = roomInfo.nMinDeposit
    
            local nSafeBoxDeposit = 0
            if cc.exports.isSafeBoxSupported() then
                nSafeBoxDeposit = user.nSafeboxDeposit or 0
            end

            local isEnough = true
            if userDeposit then
                if userDeposit + nSafeBoxDeposit < nDeposit then
                    isEnough = false
                end
            end
    
            local relief = mymodel('hallext.ReliefActivity'):getInstance()
            
            if self._resultNode:isLose() and not isEnough then  --触发限时礼包
                local bShow = BankruptcyModel:isBankruptcyBagShow()
                if not bShow then
                    print("req BankruptcyModel:reqApplyBag in game")
                    BankruptcyModel:reqApplyBag(roomInfo.nRoomID)
                else
                    self:showBankruptcyGiftResult(function ()
                        local limit = ((relief.config or {}).Limit or {}).LowerLimit or 0
                        if relief.state == 'SATISFIED' 
                        and nDeposit < limit then
                            my.informPluginByName({pluginName='ReliefCtrl',params={
                                fromSence = ReliefDef.FROM_SCENE_GAMESCENE, 
                                promptParentNode = self, 
                                leftTime = user.reliefData.timesLeft, 
                                limit = relief.config.Limit}
                            })
                        elseif relief:isVideoAdReliefValid() then
                            -- 视频低保
                            my.informPluginByName({pluginName='ReliefCtrl',params={
                                fromSence = ReliefDef.FROM_SCENE_GAMESCENE, 
                                promptParentNode = self._gameController._baseGameScene, 
                                VideoAdRelief = true}
                            })
                        end
                    end)
                end
            end
        end
    end
end

function MyGameScene:onGetWeekCardRspStauts(value)
    print("MyGameScene:onGetWeekCardRspStauts")

    if not value or not value.value or not value.value.awards then return end
    local awards = value.value.awards

    self:UpdateExpressionBtnStatus()

    local drawIndex = self._gameController:getMyDrawIndex()
    self._gameController:addPlayerDeposit(drawIndex, awards[2].rewardcount)
    self._gameController._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
end

function MyGameScene:onGetBankruptcyRspStauts(value)
    print("MyGameScene:onGetBankruptcyRspStauts")
    self:onBankruptcyTimeUpdate()

    if not value or not value.value or not value.value.awards then return end
    local awards = value.value.awards

    local drawIndex = self._gameController:getMyDrawIndex()
    self._gameController:addPlayerDeposit(drawIndex, awards[2].rewardcount)
    self._gameController._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
end

function MyGameScene:showBankruptcyGiftResult(callback)
    print("MyGameScene:showBankruptcyGiftResult")
    local tag = 0     --如果可以购买，等于Product_Price
    if BankruptcyModel:isBankruptcyBagShow() then
        tag = 1
        my.informPluginByName({pluginName = 'BankruptcyCtrl', params={callback=callback}})
    end
    print("tag: ", tag)
    return tag
end
function MyGameScene:getResultPanel()           return self._resutPanel         end

function MyGameScene:setSortTypeBtnEnabled(status)
    self._MYSortTypeBtn:setVisible(status) 
    if false == status then
        self:setTHSBtnsEnabled(status)
    end
end

function MyGameScene:setTHSBtnsEnabled(status)
    local shapeStatus = {[SKGameDef.SK_CS_SPADE] = status, [SKGameDef.SK_CS_HEART]=status, [SKGameDef.SK_CS_CLUB]=status, [SKGameDef.SK_CS_DIAMOND]=status}
    self:disableShapeButtons(shapeStatus)
end

function MyGameScene:setSortBtnsVisible(status)
    local needHideBtns = {self._MyOrderSortBtn, self._MyNumSortBtnEx, self._MyColorSortBtn,self._MyBoomBtn}
    for k,v in pairs(needHideBtns) do
        if v then
            v:setVisible(false)
        end
    end
end

function MyGameScene:setOtherBtns()
    --self.super:setOtherBtns()
    if not self._gameNode then return end

    self._MyPanel_Odds = self._gameNode:getChildByName("Panel_Player1"):getChildByName("Panel_Odds")
    self._MyPanel_Odds:setVisible(false)

    local ResetNetlessBtn = self._gameNode:getChildByName("Btn_Reopen")
    if ResetNetlessBtn then
        local function onClickResetBtn()
            self:onClickResetBtn()
        end
        ResetNetlessBtn:addClickEventListener(onClickResetBtn)
        ResetNetlessBtn:setVisible(false)
    end

    local NetworkBtn = self._gameNode:getChildByName("Btn_Network")
    if NetworkBtn then
        local function onClickResetBtn()
            self:onClickResetBtn()
        end
        NetworkBtn:addClickEventListener(onClickResetBtn)
        NetworkBtn:setVisible(false)
    end

    self._MyFinishTaskNode = self._gameNode:getChildByName("Node_Perform")
    self._MyFinishTaskNodePos = cc.p(self._MyFinishTaskNode:getPosition())
    local FinishTaskBtn = self._MyFinishTaskNode:getChildByName("Panel_Perform"):getChildByName("Btn_Perform")
    if FinishTaskBtn then
        local function onClickMissionBtn()
            self._MyFinishTaskNode:setVisible(false)
            self:onClickMissionBtn()
        end
        FinishTaskBtn:addClickEventListener(onClickMissionBtn)
    end
    self._MyFinishTaskNode:setVisible(false)

    --[[local FinishTaskBtn = self._MyFinishTaskNode:getChildByName("Panel_Perform"):getChildByName("Node_ResultLightLoop_Win")
    local csbPath = "res/GameCocosStudio/csb/Node_ResultLightLoop_Win.csb"
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        FinishTaskBtn:runAction(action)
        action:play("animation_LightLoop", true)
    end]]

    local csbPath = "res/GameCocosStudio/csb/Node_Perform.csb"
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        self._MyFinishTaskNode:runAction(action)
        action:gotoFrameAndPause(18)
    end

    --开发第十一期新按钮
    ------begin----
    self._gameNode:getChildByName("Panel_ArenaBar"):setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)--底框
    self._gameNode:getChildByName("Node_Player1"):setZOrder(MyGameDef.MY_ZORDER_MYSELF)--自己
    self._gameNode:getChildByName("Node_OperationBtn"):setZOrder(MyGameDef.MY_ZORDER_ARENAINFO) --出牌按钮  低于炸弹动画SK_ZORDER_THROWN_ANIMATION
    self._gameNode:getChildByName("Node_Chat"):setZOrder(MyGameDef.MY_ZORDER_MYSELF+4) --聊天
    self._gameNode:getChildByName("Node_GameTip"):setZOrder(MyGameDef.MY_ZORDER_MYSELF) --提示
    for i=1,4 do
        self._gameNode:getChildByName("Panel_Player"..i):setZOrder(MyGameDef.MY_ZORDER_MYSELF+3)
    end

    SKGameDef.SK_CARD_START_POS_Y = SKGameDef.SK_CARD_START_POS_Y + 33

    --商城按钮
    local shopBtn = self._gameNode:getChildByName("Btn_AddMoney")
    if shopBtn then
        self._MYShopBtn = shopBtn
        shopBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickShopBtn()
            self._gameController:playBtnPressedEffect()
            my.informPluginByName({pluginName='ShopCtrl',params = {defaultPage = "silver", NoBoutCardRecorder = true}})
        end
        self._MYShopBtn:addClickEventListener(onClickShopBtn)
    end
    shopBtn:setVisible(cc.exports.isShopSupported() and not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame())

    --竖牌横排按钮
    local SortTypeBtn = self._gameNode:getChildByName("Btn_SortType")
    if SortTypeBtn then
        local imgPath =  ""
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/Game_img.plist")
        local imgPath =  ""
        if self:isVerticalCardsMode() then
            imgPath =  "GameCocosStudio/plist/Game_img/hengxiang.png"
        else
            imgPath =  "GameCocosStudio/plist/Game_img/shuxiang.png"
        end
        SortTypeBtn:loadTextureNormal(imgPath, 1)

        self._MYSortTypeBtn = SortTypeBtn
        SortTypeBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickSortTypeBtn()
            if self._ClickVerticalEnable == false then
                 if self._tipPluginShow == nil then
                     local msg = string.format(self._gameController:getGameStringByKey("G_GAME_CLICK_TOO_QUICK"))
                     local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
                     my.informPluginByName({pluginName='TipPlugin',params={tipString=utf8Msg, removeTime = 0.5}})
                     self._tipPluginShow = true
                 end
                return
            end

            self._ClickVerticalEnable = false
            my.scheduleOnce(function()
                if self:isInGameScene() == false then return end
                self._ClickVerticalEnable = true
                self._tipPluginShow = nil  -- 防止 tipPlugin出现 Blocked阻塞问题，阻塞在真机中会引起 横竖切换流程中止
            end, 1)

            self:onClickSortTypeBtn()
        end

        self._MYSortTypeBtn:addClickEventListener(onClickSortTypeBtn)
    end

    --同花顺按钮
    --黑
    local SpadeBtn = self._gameNode:getChildByName("Button_Shape1")
    if SpadeBtn then
        self._MYSpadeBtn = SpadeBtn
        SpadeBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickSpadeBtn()
            if DEBUG and DEBUG > 0 then
                print('--THS-- onClickSpadeBtn..')
            end
            self:onClickSpadeBtn()

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_SORT_BY_THS_BTN)
        end
        self._MYSpadeBtn:addClickEventListener(onClickSpadeBtn)
    end
    --红
    local HeartBtn = self._gameNode:getChildByName("Button_Shape2")
    if HeartBtn then
        self._MYHeartBtn = HeartBtn
        HeartBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickHeartBtn()
            if DEBUG and DEBUG > 0 then
                print('--THS-- onClickHeartBtn..')
            end
            self:onClickHeartBtn()

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_SORT_BY_THS_BTN)
        end
        self._MYHeartBtn:addClickEventListener(onClickHeartBtn)
    end
    --梅
    local ClubBtn = self._gameNode:getChildByName("Button_Shape3")
    if ClubBtn then
        self._MYClubBtn = ClubBtn
        ClubBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickClubBtn()
            if DEBUG and DEBUG > 0 then
                print('--THS-- onClickHeartBtn..')
            end
            self:onClickClubBtn()

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_SORT_BY_THS_BTN)
        end
        self._MYClubBtn:addClickEventListener(onClickClubBtn)
    end
    --方
    local DiamondBtn = self._gameNode:getChildByName("Button_Shape4")
    if DiamondBtn then
        self._MYDiamondBtn = DiamondBtn
        DiamondBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickDiamondBtn()
            if DEBUG and DEBUG > 0 then
                print('--THS-- onClickDiamondBtn..')
            end
            self:onClickDiamondBtn()

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_SORT_BY_THS_BTN)
        end
        self._MYDiamondBtn:addClickEventListener(onClickDiamondBtn)
    end
    
    self:setSortTypeBtnEnabled(false)   -- 开局 没有发牌结束前禁止点击
    -----end-------

    local chatBtn = self._gameNode:getChildByName("Btn_Chat")
    if chatBtn then
        self._SKChatBtn = chatBtn
        chatBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickChatBtn()
            self:onClickChatBtn()
            end
        self._SKChatBtn:addClickEventListener(onClickChatBtn)
    end

    local missionBtn = self._gameNode:getChildByName("Btn_Mission")
    if missionBtn then
        self._SKMissionBtn = missionBtn
        missionBtn:getChildByName("Img_Dot"):setVisible(false)
        local function onClickMissionBtn()
            self._MyFinishTaskNode:setVisible(false)
            self:onClickMissionBtn()
        end
        self._SKMissionBtn:addClickEventListener(onClickMissionBtn)
    end
    local bShow = (cc.exports.isTaskSupported() and not PUBLIC_INTERFACE.IsStartAsTimingGame() and not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() and not PUBLIC_INTERFACE.IsStartAsTeam2V2())
    missionBtn:setVisible(bShow)

    local btnLimitTimeGift = self._gameNode:getChildByName("Btn_LimitTimeGift")
    if btnLimitTimeGift then
        self._bankruptBtn = btnLimitTimeGift
        cc.exports.inGame = false
        self:onBankruptcyTimeUpdate()

        local function onClickLimitTimeGiftBtn()
            self:showBankruptcyGiftResult()
        end
        
        self._bankruptBtn:addClickEventListener(onClickLimitTimeGiftBtn)
    end

    local btnTimingGameTicketTask = self._gameNode:getChildByName("Btn_TimingGameTicketTask")
    if btnTimingGameTicketTask then
        self._timingGameTicketTaskBtn = btnTimingGameTicketTask
        self._timingGameTicketTaskBtn:addClickEventListener(function ()
            my.playClickBtnSound()
            if cc.exports.isTimingGameSupported() and TimingGameModel:isEnable() then
                my.informPluginByName({pluginName = 'TimingGameTicketTask'})
            else
                local msgstr = "获取数据中，请稍后再试~"
                my.informPluginByName({pluginName='TipPlugin',params={tipString=msgstr, removeTime = 0.5}})
			end
        end)
        local bShow = (not PUBLIC_INTERFACE.IsStartAsTimingGame() and not PUBLIC_INTERFACE.IsStartAsJiSu()
        and self._gameController:isNeedDeposit() and not PUBLIC_INTERFACE.IsStartAsFriendRoom()
        and TimingGameModel:isTicketTaskEntryShow() and not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame()
        and not PUBLIC_INTERFACE.IsStartAsTeam2V2())
        self._timingGameTicketTaskBtn:setVisible(bShow)
        if bShow then
            self:refreshTimingGameTicketTaskBtn()
        end
    end

    --游戏内连胜按钮
    local btnWinningStreak = self._gameNode:getChildByName("Btn_WinningStreak")
    if btnWinningStreak then
        self._btnWinningStreak = btnWinningStreak
        self._btnWinningStreak:setVisible(false)
        self._btnWinningStreakPositionX = self._btnWinningStreak:getPositionX()
        self._btnWinningStreakPositionY = self._btnWinningStreak:getPositionY()
        self._btnWinningStreak:addClickEventListener(handler(self,self.onClickWinningStreakBtn))
    end

    local goldeEggBtn = self._gameNode:getChildByName("Btn_Goldegg")
    if goldeEggBtn then
        self._SKGoldeEggBtn = goldeEggBtn
        self._SKGoldeEggBtn:setVisible(false)
    end   

    -- 这里保留调用，主要是断线重连\异地登陆等情况确保选桌按钮状态正常
    self:initSelectTableBtn() 

    local quickBoomBtn = self._gameNode:getChildByName("Btn_QuickBoom")  -- 快速理出炸弹
    if quickBoomBtn then
        self._MyQuickBoomBtn = quickBoomBtn
        quickBoomBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickQuickBoomBtn()
            self:dealQuickBoomBtnsEvent()
        end
        self._MyQuickBoomBtn:addClickEventListener(onClickQuickBoomBtn)

        self._MyQuickBoomBtn:setVisible(false)
    end

    local orderSortBtn = self._gameNode:getChildByName("Btn_Sort")  -- 大小排序
    if orderSortBtn then
        self._MyOrderSortBtn = orderSortBtn
        --[[orderSortBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickOrderSortBtn()
            local sortFlag = SKGameDef.SORT_CARD_BY_ORDER
            self:dealSortTypeBtnsEvent_New(sortFlag)
        end
        self._MyOrderSortBtn:addClickEventListener(onClickOrderSortBtn)
        ]]
        self._MyOrderSortBtn:setVisible(false)
    end


    local numSortBtn = self._gameNode:getChildByName("Btn_Color") --花色排序
    if numSortBtn then
        self._MyColorSortBtn = numSortBtn
        numSortBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        --[[
        local function onClickColorSortBtn()
            local sortFlag = SKGameDef.SORT_CARD_BY_SHPAE
            self:dealSortTypeBtnsEvent(sortFlag)
        end
        self._MyColorSortBtn:addClickEventListener(onClickColorSortBtn)
        ]]
        self._MyColorSortBtn:setVisible(false)
    end


    local BoomSortBtn = self._gameNode:getChildByName("Btn_Boom")   -- 炸弹排序
    if BoomSortBtn then
        self._MyBoomBtn = BoomSortBtn
        --[[BoomSortBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickBoomSortBtn()
            local sortFlag = SKGameDef.SORT_CARD_BY_BOME
            self:dealSortTypeBtnsEvent_New(sortFlag)
        end
        self._MyBoomBtn:addClickEventListener(onClickBoomSortBtn)
        ]]
        self._MyBoomBtn:setVisible(false)
    end

    local BoomSortBtn = self._gameNode:getChildByName("Btn_NumSort")    -- 张数排序
    if BoomSortBtn then
        self._MyNumSortBtnEx = BoomSortBtn
        BoomSortBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        --[[
        local function onClickCardNumSortBtn()
            local sortFlag = SKGameDef.SORT_CARD_BY_NUM
            self:dealSortTypeBtnsEvent(sortFlag)
        end
        self._MyNumSortBtnEx:addClickEventListener(onClickCardNumSortBtn)
        ]]
        self._MyNumSortBtnEx:setVisible(false)
    end

    local arrangeBtn = self._gameNode:getChildByName("Btn_Tird")
    if arrangeBtn then
        self._MyArrageBtn = arrangeBtn
        arrangeBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickArrageBtn()
            self:onClickArrageBtn()

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_CARD_COLLECT_BTN)
        end
        self._MyArrageBtn:addClickEventListener(onClickArrageBtn)
        self._MyArrageBtn:setVisible(false)
    end

    local ResetBtn = self._gameNode:getChildByName("Btn_Reset")
    if ResetBtn then
        self._MyResetBtn = ResetBtn
        ResetBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickResetBtn()
            self:onClickResetBtn()

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_CARD_CANCEL_COLLECT_BTN)
        end
        self._MyResetBtn:addClickEventListener(onClickResetBtn)
        self._MyResetBtn:setVisible(false)
    end

    -- 表情
    local NodeExpression = self._gameNode:getChildByName("Node_Expression")
    if NodeExpression then
        -- 调整表情按钮位置
        local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        local ratio = framesize.width / framesize.height
        if ratio >= 2 then
            local offsetWidth = display.size.width * (80 / 2) / 1280
            NodeExpression:setPositionX(NodeExpression:getPositionX() + offsetWidth)
        end
        
        if self._gameController:isArenaPlayer() then
            --NodeExpression:setLocalZOrder(SKGameDef.SK_ZORDER_PLAYERINFO + 1000)
            NodeExpression:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
            NodeExpression:removeAllChildren()
            local layerNode = cc.CSLoader:createNode("res/GameCocosStudio/csb/Node_Expression.csb")
            NodeExpression:addChild(layerNode)
            self._MyNodeExpression = layerNode
        else
            NodeExpression:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
            self._MyNodeExpression = NodeExpression
        end        

        local function onClickExpression()
            if WeekCardModel:canUseSpecialEmoji() then
                self:ClickBtnExpression()
            else
                my.informPluginByName({pluginName = 'WeekCard', params={isInGame=true}})
                self._gameController:tipMessageByKey("G_GAME_OPEN_EXPRESSION_TIP")
            end
        end
        local btnExpression = self._MyNodeExpression:getChildByName("Image_bg"):getChildByName("Btn_Expression")        
        btnExpression:addClickEventListener(onClickExpression)
        self:UpdateExpressionBtnStatus()

        local btnExpression1 = self._MyNodeExpression:getChildByName("Image_bg"):getChildByName("BtnExpression_1")
        btnExpression1:addClickEventListener(function() self:UseExpression(1) end)
        local btnExpression2 = self._MyNodeExpression:getChildByName("Image_bg"):getChildByName("BtnExpression_2")
        btnExpression2:addClickEventListener(function() self:UseExpression(2) end)
        local btnExpression3 = self._MyNodeExpression:getChildByName("Image_bg"):getChildByName("BtnExpression_3")
        btnExpression3:addClickEventListener(function() self:UseExpression(3) end)
        local btnExpression4 = self._MyNodeExpression:getChildByName("Image_bg"):getChildByName("BtnExpression_4")
        btnExpression4:addClickEventListener(function() self:UseExpression(4) end)
        local btnExpression5 = self._MyNodeExpression:getChildByName("Image_bg"):getChildByName("BtnExpression_5")
        btnExpression5:addClickEventListener(function() self:UseExpression(5) end)        
    end
    local NodeExpressionAni = self._gameNode:getChildByName("Node_ExpressionAni")
    if NodeExpressionAni then
        NodeExpressionAni:setZOrder(MyGameDef.MY_ZORDER_MYSELF)
    end

    self._OtherBtn = {self._MyQuickBoomBtn, self._MyArrageBtn, self._MyResetBtn, self._SKChatBtn, self._MYShopBtn, self._MYSortTypeBtn, self._MYSpadeBtn, self._MYHeartBtn, self._MYClubBtn, self._MYDiamondBtn }

    --新手提示
    self._newPlayerTips = self._gameNode:getChildByName("Node_Playingcards1")
    if self._newPlayerTips then
        self._newPlayerTips:setVisible(false)
    end
    local newPlayerTipsPos = self._gameNode:getChildByName("Node_Playingcards2")
    self._newPlayerTipsPos = cc.p(newPlayerTipsPos:getPosition())

    self._newPlayerTips:getChildByName("PlayingcardsTipBG"):getChildByName("Btn_Touch"):addClickEventListener(function()
        self._newPlayerTips:setVisible(false)
    end)

    --规则按钮
    local RuleBtn = self._gameNode:getChildByName("Btn_Rule")
    if RuleBtn then
        RuleBtn:setLocalZOrder(SKGameDef.SK_ZORDER_SELFINFO)
        self._MyRuleBtn = RuleBtn
        local function onClickRuleBtn()
            if self._gameController:isArenaPlayer() then
		        my.informPluginByName({pluginName='ArenaPlayerCourseCtrl'})
            else
                my.informPluginByName({pluginName='GameRulePlugin'})
            end
            --self:showRobScorePanel(isWin)
            --self:setArenaGameResult()
            --self._gameController:showArenaResult()
            --self:ShowLevelUpgrade(10,20,20)
        end
        self._MyRuleBtn:addClickEventListener(onClickRuleBtn)
        --self._MyRuleBtn:setVisible(true)
    end

    self:refreshTopRightBtns() --调整按钮位置
end

function MyGameScene:dealQuickBoomBtnsEvent()
    if self._waitingclick == true then 
        print("dealQuickBoomBtnsEvent return , press btn too quick!!!") 
        local msg = string.format(self._gameController:getGameStringByKey("G_GAME_CLICK_TOO_QUICK"))
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        my.informPluginByName({pluginName='TipPlugin',params={tipString=utf8Msg, removeTime = 0.5}})
        return 
    end
    self._waitingclick = true
    self._CDTimer = my.scheduleOnce(function()
        if self then
            self._CDTimer = nil
            self._waitingclick = false
        end
    end, 2)
    -- 对家手牌return
    local myHandCards = self._SKHandCardsManager:getSKHandCards(self._gameController:getMyDrawIndex())
    if myHandCards and  myHandCards.getMySelfHandCardsCount then
        if myHandCards:getMySelfHandCardsCount() <= 0 then
            print("can not switch the sortTypeBtns mode when show FriendCards !!!")
            return
        end
    end
    -- 2019年11月8日 在大小模式下增加快速理出炸弹功能
    self._gameController:playGamePublicSound("snd_sort.mp3")
    local drawIndex = self._gameController:getMyDrawIndex()
    self._gameController:SetSortCardFlag(SKGameDef.SORT_CARD_BY_ORDER) 
    self._SKHandCardsManager:quickSortBoomHandCards(drawIndex)

    self._gameController:ope_CheckSelect()  -- 理出炸弹后需要检测是出牌按钮状态
    --播放理牌特效
    self:playSortEffect()

    self._gameController:checkNewUserGuide()
    --17期客户端埋点
    my.dataLink(cc.exports.DataLinkCodeDef.GAME_QUICK_BOOM_BTN)
end

function MyGameScene:dealSortTypeBtnsEvent_New(sortFlag)
    -- 对家手牌不给切换（针对玩家1倒计时0s出牌头游时切换做的优化）
    local myHandCards = self._SKHandCardsManager:getSKHandCards(self._gameController:getMyDrawIndex())
    if myHandCards and  myHandCards.getMySelfHandCardsCount then
        if myHandCards:getMySelfHandCardsCount() <= 0 then
            print("can not switch the sortTypeBtns mode when show FriendCards !!!")
            return
        end
    end
     -- 2019年10月9日， 二十期需求改成，炸弹理牌 --》 大小排序（默认的）
    self._gameController:playGamePublicSound("snd_sort.mp3")
    local drawIndex = self._gameController:getMyDrawIndex()
    if sortFlag == SKGameDef.SORT_CARD_BY_BOME then
        self._gameController:SetSortCardFlag(SKGameDef.SORT_CARD_BY_BOME) 
        -- 直接切换到大小排序
        self:onShowOrderBtn(SKGameDef.SORT_CARD_BY_ORDER)
        self:StartSortTipsTime("Img_Bomb")
    elseif sortFlag  == SKGameDef.SORT_CARD_BY_ORDER then
        self._gameController:SetSortCardFlag(SKGameDef.SORT_CARD_BY_ORDER) 
        -- 直接切换到炸弹排序
        self:onShowOrderBtn(SKGameDef.SORT_CARD_BY_BOME)
        self:StartSortTipsTime("Img_Size")
    end
    self._SKHandCardsManager:sortHandCards(drawIndex)
      
    --播放理牌特效
    self:playSortEffect()
    --17期客户端埋点
    my.dataLink(cc.exports.DataLinkCodeDef.GAME_SORT_BY_BOMB_BTN)

end

function MyGameScene:dealSortTypeBtnsEvent(sortFlag)
    -- 同时点击切换和  炸弹理牌，则此处需要挡住竖排模式下的排序
    if self._VerticalMode == true then return  end
    -- 对家手牌不给切换（针对玩家1倒计时0s出牌头游时切换做的优化）
    local myHandCards = self._SKHandCardsManager:getSKHandCards(self._gameController:getMyDrawIndex())
    if myHandCards and  myHandCards.getMySelfHandCardsCount then
        if myHandCards:getMySelfHandCardsCount() <= 0 then
            print("can not switch the sortTypeBtns mode when show FriendCards !!!")
            return
        end
    end

    if sortFlag  == SKGameDef.SORT_CARD_BY_ORDER then
        -- 按大小排序
        self:onClickOrderSortBtn()
    elseif sortFlag  == SKGameDef.SORT_CARD_BY_NUM then
        -- 按张数排序
        self:onClickCardNumSortBtn()
    elseif sortFlag  == SKGameDef.SORT_CARD_BY_SHPAE then
        -- 按花色排序
        self:onClickColorSortBtn()
    elseif sortFlag  == SKGameDef.SORT_CARD_BY_BOME then
        -- 按炸弹排序
        self:onClickBoomSortBtn()
    end

end

-- 封装为一个函数, 解决没有选桌配置时, return导致后面代码不执行bug
function MyGameScene:initSelectTableBtn()
    local selectTableBtn = self._gameNode:getChildByName("Btn_SelectTable")
    if selectTableBtn then
        local selectTableConfig = cc.exports._gameJsonConfig.RoomSectionConfig
        if not selectTableConfig then
            selectTableBtn:setVisible(false)
            return
        end
        -- 判断是否高级房, 是则显示按钮, 否则不显示
        self._SelectTableBtn = selectTableBtn
        local isShow = true
        local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
        if not roomInfo then
            isShow = false
        else
            if roomInfo.nRoomID ~= selectTableConfig.nRoomID then isShow = false end
        end
        if not selectTableConfig.bEnabled then isShow = false end
        if isShow then
            self._SelectTableBtn:setVisible(true)
            local function onClickSelectTableBtn()
                -- 弹出选桌界面
                self:onClickSelectTableBtn()
            end
            self._SelectTableBtn:addClickEventListener(onClickSelectTableBtn)
        else
            self._SelectTableBtn:setVisible(false)
        end
    end
end

function MyGameScene:onClickSelectTableBtn()
    my.informPluginByName({pluginName='SelectTableCtrl', params={gameController=self._gameController}})
end

function MyGameScene:setMyRuleBtnVisible(isVisible)
    --self._MyRuleBtn:setVisible(isVisible)
end

function MyGameScene:StartSortTipsTime(nodeName)
    local node = nil
    local tipsPanel = self._gameNode:getChildByName("Panel_PlayingCards")
    if tipsPanel then
        tipsPanel:setVisible(true)
        tipsPanel:setZOrder(SKGameDef.SK_ZORDER_SELFINFO)
        for i, v in pairs(tipsPanel:getChildren()) do
            v:setVisible(false)
        end
        node = tipsPanel:getChildByName(nodeName)
    end
    if node then
        node:setVisible(true)
        local function stopSortTipsTime()
            if self.SortTipsTimerID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.SortTipsTimerID)
                self.SortTipsTimerID = nil
            end
        end
        stopSortTipsTime()
        self.SortTipsTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
                                stopSortTipsTime()
                                node:setVisible(false)
                                end, 1.0, false)  
    end
end

function MyGameScene:onShowOrderBtn(index)
    -- 大小理牌:1   张数理牌：2  花色理牌：3   炸弹理牌：4
    local needHideBtns = {self._MyOrderSortBtn, self._MyNumSortBtnEx, self._MyColorSortBtn,self._MyBoomBtn}
    for k,v in pairs(needHideBtns) do
        if v then
            v:setVisible(false)
        end
    end

    if index and index > 0 and index <= #needHideBtns then
        needHideBtns[index]:setVisible(true)
    else
        needHideBtns[#needHideBtn]:setVisible(true)
    end
end

function MyGameScene:onClickOrderSortBtn()  -- 大小排序
    self._gameController:playGamePublicSound("snd_sort.mp3")
    local drawIndex = self._gameController:getMyDrawIndex()
    self._gameController:SetSortCardFlag(SKGameDef.SORT_CARD_BY_ORDER)
    self._SKHandCardsManager:sortHandCards(drawIndex)
        
    self._MyOrderSortBtn:setVisible(false)
    self._MyBoomBtn:setVisible(true)
    self._MyColorSortBtn:setVisible(false)
    self._MyNumSortBtnEx:setVisible(false)

    self:StartSortTipsTime("Img_Size") 
    --播放理牌特效
    self:playSortEffect()
end

function MyGameScene:onClickBoomSortBtn() -- 炸弹理牌
    self._gameController:playGamePublicSound("snd_sort.mp3")
    local drawIndex = self._gameController:getMyDrawIndex()
    self._gameController:SetSortCardFlag(SKGameDef.SORT_CARD_BY_BOME) 
    self._SKHandCardsManager:sortHandCards(drawIndex)

    self._MyOrderSortBtn:setVisible(false)
    self._MyBoomBtn:setVisible(false)
    self._MyColorSortBtn:setVisible(false)
    self._MyNumSortBtnEx:setVisible(true)

    self:StartSortTipsTime("Img_Bomb")  
    --播放理牌特效
    self:playSortEffect()
    
    --17期客户端埋点
    my.dataLink(cc.exports.DataLinkCodeDef.GAME_SORT_BY_BOMB_BTN)
end

function MyGameScene:onClickCardNumSortBtn()  -- 张数理牌
    self._gameController:playGamePublicSound("snd_sort.mp3")
    local drawIndex = self._gameController:getMyDrawIndex()
    self._gameController:SetSortCardFlag(SKGameDef.SORT_CARD_BY_NUM) 
    self._SKHandCardsManager:sortHandCards(drawIndex)

    self._MyOrderSortBtn:setVisible(false)
    self._MyBoomBtn:setVisible(false)
    self._MyColorSortBtn:setVisible(true)
    self._MyNumSortBtnEx:setVisible(false)

    self:StartSortTipsTime("Img_Num")
    --播放理牌特效
    self:playSortEffect() 
end

function MyGameScene:onClickColorSortBtn()  --花色理牌
    self._gameController:playGamePublicSound("snd_sort.mp3")
    local drawIndex = self._gameController:getMyDrawIndex()
    self._gameController:SetSortCardFlag(SKGameDef.SORT_CARD_BY_SHPAE) 
    self._SKHandCardsManager:sortHandCards(drawIndex)

    self._MyOrderSortBtn:setVisible(true)
    self._MyBoomBtn:setVisible(false)
    self._MyColorSortBtn:setVisible(false)
    self._MyNumSortBtnEx:setVisible(false)
 
    self:StartSortTipsTime("Img_Color")  
    --播放理牌特效
    self:playSortEffect()
end

function MyGameScene:onClickArrageBtn()
    self._gameController:playGamePublicSound("snd_sort.mp3")

    self._SKHandCardsManager:OnArrageHandCard()

    self._gameController:checkNewUserGuide()
end

function MyGameScene:onClickResetBtn()
    self._gameController:playGamePublicSound("snd_sort.mp3")
    --self._MyResetBtn:setVisible(false)
    --self._MyArrageBtn:setVisible(true)
    --self._MyArrageBtn:setBright(false)
    --self._MyArrageBtn:setEnabled(false)
    self._SKHandCardsManager:OnResetArrageHandCard()
end

function MyGameScene:containsTouchLocation(x, y)
    if not self._OtherBtn then return false end
    
    --[[local opePanel = self._gameNode:getChildByName("Operate_Panel")
    local worldPos = opePanel:convertToWorldSpace(cc.p(x, y))
    x = worldPos.x
    y = worldPos.y
    ]]
    for i = 1, #self._OtherBtn do
        local child = self._OtherBtn[i]
        if child and child:isVisible() and child:isTouchEnabled() then
            --local position = child:getParent():convertToWorldSpace(cc.p(child:getPosition()))
            local position = (cc.p(child:getPosition()))
            local s = child:getContentSize()
            local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
            local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
            if b then
                return b
            end
        end
    end

    if not self._gameNode then return false end
    -- 判断底部ArenaBar是否被点击（避免被当作空白区域），优化同花顺选择点击体验
    local bottom_ArenaBar = self._gameNode:getChildByName("Panel_ArenaBar")
    if bottom_ArenaBar then
        local position = bottom_ArenaBar:getParent():convertToWorldSpace(cc.p(bottom_ArenaBar:getPosition()))
        local s = bottom_ArenaBar:getContentSize()
        local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
        local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
        if b then
            return b
        end
    end

    return false
end

function MyGameScene:showFinishTaskNode()
    if self._MyFinishTaskNode:isVisible() then
        return
    end
    self._MyFinishTaskNode:setVisible(true)
    local oldPos = self._MyFinishTaskNodePos
    self._MyFinishTaskNode:setPosition(cc.p(oldPos.x, oldPos.y * 2))
    local moveTo = cc.MoveTo:create(2.0,oldPos)
    self._MyFinishTaskNode:runAction(moveTo)

    self._MyFinishTaskNode:setLocalZOrder(SKGameDef.SK_ZORDER_FINISH_TASK + 10)

end

function MyGameScene:showFightEffect()
    self._gameController:playGamePublicSound("Snd_Tribute.mp3")
    local fightEffect = self._gameNode:getChildByName("Node_KangGong")
    fightEffect:setVisible(true)
    
    fightEffect:setLocalZOrder(SKGameDef.SK_ZORDER_FINISH_TASK + 8)
    if fightEffect then
        local csbPath = "res/GameCocosStudio/csb/Node_KangGong.csb"
        local action = cc.CSLoader:createTimeline(csbPath)
        if action then
            fightEffect:runAction(action)
            action:play("animation_KangGong", false)

            local speed = action:getTimeSpeed()  
            local startFrame = action:getStartFrame()  
            local endFrame = action:getEndFrame()  
            local frameNum = endFrame - startFrame 
            local duration = 1.0 /(speed * 60.0) * frameNum

            local block = cc.CallFunc:create( function(sender)  
                fightEffect:setVisible(false)
            end )  
 
            fightEffect:runAction(cc.Sequence:create(cc.DelayTime:create(duration+1), block))  

        end 
    end
end

function MyGameScene:addAllowancesPrompt(timesLeft,limit)
    local prompt = MyGamePromptAllowances:create(self._gameController,timesLeft,nil,limit)
    if prompt then
        self:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
        prompt:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

function MyGameScene:addTakeSilverPrompt(takeDepositNum)
    local prompt = MyGamePromptTakeSilver:create(self._gameController, takeDepositNum)
    if prompt then
        self:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
        prompt:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

function MyGameScene:addSaveSilverPrompt(saveDepositNum)
    local safeboxBtnShow = false
    local isHall = false
    if true == PUBLIC_INTERFACE.IsStartAsFriendRoom() then
        safeboxBtnShow = true
    elseif true == PUBLIC_INTERFACE.IsStartAsArenaPlayer() then
        safeboxBtnShow = true
    end

    local prompt = MyGamePromptMoreMoney:create(self._gameController, saveDepositNum, isHall, safeboxBtnShow)
    if prompt then
        self:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
        if self._gameController:isArenaPlayer() then
            prompt:setGotoRoomBtnState(false)
        end
        prompt:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

function MyGameScene:addRechargePrompt(bFirst, RechargeData, bLimitTimeGift, showJumpBtn)
    local prompt = nil

    
    if bLimitTimeGift then
        RechargeData["itemData"] = require("src.app.plugins.limitTimeGift.limitTimeGiftModel"):getInstance():normalizeGiftItemData(RechargeData)
    end

    if showJumpBtn then
        prompt = MyGamePromptRecharge:create(self._gameController, bFirst, RechargeData, nil, bLimitTimeGift, showJumpBtn)
    else
        prompt = MyGamePromptRecharge:create(self._gameController, bFirst, RechargeData, nil, bLimitTimeGift)
    end

    if prompt then
        self:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
        prompt:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

--创建充值界面时增加关闭按钮弹出低保的事件
function MyGameScene:addRechargePromptEx(timesLeft, limit, bFirst, RechargeData, bLimitTimeGift)
    local prompt = MyGamePromptRecharge:create(self._gameController, bFirst, RechargeData, nil, bLimitTimeGift)
    if prompt then
        self:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
        prompt:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))

        -- 给充值界面添加关闭事件，打开低保界面
        local rootNode = prompt._PromptPanel
        if rootNode then
            local panelMain = rootNode:getChildByName("Panel_main") or rootNode:getChildByName("Panel_Recharge") or rootNode:getChildByName("Panel_FirstRecharge")
            if panelMain then
                local btnClose = panelMain:getChildByName("Btn_Close")
                if btnClose then
                    btnClose:addClickEventListener( function()
                        if prompt.onClose then prompt:onClose() end
                        local relief = mymodel('hallext.ReliefActivity'):getInstance()
                        if relief:isVideoAdReliefValid() then
                            my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_GAMESCENE, promptParentNode = self, VideoAdRelief = true}})
                        else
                            my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_GAMESCENE, promptParentNode = self, leftTime = timesLeft, limit = limit}})
                        end
                    end )
                end
            end
        end
    end
end

function MyGameScene:addExitRoomPrompt(punishmentMoney)
    self._gameController.isExitRoomPlaneSure = true
    local prompt = MyGamePromptExitRoom:create(self._gameController, punishmentMoney)
    if prompt then
        self:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
        prompt:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

-- 退出弹窗，提示再打几局可得礼券
function MyGameScene:addExitRoomExchangePrompt(nContinueBout, nVochersNum)
    self._gameController.isExitRoomPlaneSure = true
    local prompt = MyGamePromptExitTipExchange:create(self._gameController, nContinueBout, nVochersNum )
    if prompt then
        self:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
        prompt:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
    return prompt
end

function MyGameScene:addGoBackRoomPrompt(needReturnRoomID, takeDepositNum)
    local prompt = MyGamePromptGoBackRoom:create(self._gameController, needReturnRoomID, takeDepositNum)
    if prompt then
        self:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
        prompt:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
        self._GoBackRoomPrompt = prompt
    end
end

function MyGameScene:showRankCard(cardId)
    self.cardBg = cc.Sprite:create("res/Game/GamePic/card/card_thrown_BG.png")
    self.cardBg:setPosition(display.center)
    self._gameNode:addChild(self.cardBg, SKGameDef.SK_ZORDER_RANK_CARD)

    local orbitBg = cc.OrbitCamera:create(0.5, 1, 0, 0, 90, 0, 0)
    --cardBg:runAction(orbit)

    self.cardft = cc.Sprite:create("res/Game/GamePic/card/card_Overturn.png")
    self.cardft:setPosition(display.center)
    self._gameNode:addChild(self.cardft, SKGameDef.SK_ZORDER_RANK_CARD)
    self.cardft:setVisible(false)
       
    local function callback()
        self.cardft:setVisible(true)
        local orbitFt = cc.OrbitCamera:create(0.5, 1, 0, 270, 90, 0, 0)
        self.cardft:runAction(orbitFt)
    end
    local sequence = cc.Sequence:create(orbitBg, cc.CallFunc:create(callback))
    self.cardBg:runAction(sequence)


    if cardId == 13 then
        cardId = 0
    end

    local idPath = nil
    if self._gameController._baseGameUtilsInfoManager._utilsStartInfo.nRanker == self._gameController:getMyChairNO()
            or self._gameController._baseGameUtilsInfoManager._utilsStartInfo.nRanker == MyGameUtilsInfoManager:RUL_GetNextChairNO(MyGameUtilsInfoManager:RUL_GetNextChairNO(self._gameController:getMyChairNO())) then
        idPath = "res/Game/GamePic/Num/num_black_"..tostring(cardId+1)..".png"
    else
        idPath = "res/Game/GamePic/Num/num_red_"..tostring(cardId+1)..".png"
    end

    self.cardNum = cc.Sprite:create(idPath)
    self.cardNum:setPosition(cc.p(self.cardft:getContentSize().width / 2, 53))
    self.cardNum:setScale(1.3)
    self.cardft:addChild(self.cardNum, 50)
end

function MyGameScene:GameStartTip()
    if not self._gameNode then return end

    local pathNewRand = "res/Game/GamePic/GameTips/NewUser/NewUserGameTip_"
    local pathCondition = "res/Game/GamePic/GameTips/Condition/ConditionGameTip_"

    --  [1] = {3,"Img_Tip4"} 任务1 完成3局，则选用名称为 Img_Tip4 的节点显示 Img_Tip1新玩家必须显示
    local conditionTipNode = {[1]={3,"2.png"},[2]={5,"3.png"},[3]={7,"4.png"},["NewPlayer"]="10.png"}
   
    --获去提示语句图片的根节点
    local Node_GameTip = self._gameNode:getChildByName("Node_GameTip")
    if Node_GameTip == nil then return end

    --隐藏所有图片
    --[[for key,node in pairs(Node_GameTip:getChildren()) do
        if node then 
            node:setVisible(false)
        end
    end]]

    --条件判断显示某个节点
    self._GameStartTipNode = nil 
    
    local function setTextureImage(path)
        Node_GameTip:loadTexture(path)
        local TempImage = cc.Sprite:create(path)
        Node_GameTip:setContentSize(TempImage:getContentSize() )
        self._GameStartTipNode = true
    end

    --新玩家判断
    local playerInfo = self._gameController._baseGamePlayerInfoManager:getPlayerInfo(self._gameController:getMyDrawIndex())
    if playerInfo and (playerInfo.nBout + playerInfo.nStandOff + playerInfo.nLoss + playerInfo.nWin) == 0 then
        setTextureImage(pathNewRand..conditionTipNode["NewPlayer"])
    end

    --寻找满足条件的节点
    if self._GameStartTipNode == nil  and cc.exports._GameTaskList~=nil then     
        for i=1,3,1
        do
            if cc.exports._GameTaskList[i]._Amount == conditionTipNode[i][1] then 
                setTextureImage(pathCondition..conditionTipNode[i][2])
                break
            end   
        end
    end  

    --获取随机节点显示
    if playerInfo and (playerInfo.nStandOff + playerInfo.nLoss + playerInfo.nWin) < 50 then
        if self._GameStartTipNode == nil then 
            local newPlayerTipsCount = 10
            local randNodeIndex = math.random(1,newPlayerTipsCount)
            if cc.exports._GameTipsIndex == nil then
                cc.exports._GameTipsIndex = randNodeIndex
            else
                for i = 1, newPlayerTipsCount do
                    if cc.exports._GameTipsIndex ~= randNodeIndex then
                        cc.exports._GameTipsIndex = randNodeIndex
                        break
                    end
                    randNodeIndex = math.random(1,newPlayerTipsCount)
                end
            end
        
            setTextureImage(pathNewRand..tostring(randNodeIndex)..".png")
        end
    end

    if self._GameStartTipNode == nil then 
        return 
    end

    Node_GameTip:setVisible(true)

    self._TipTimerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(
            function()
                if self._TipTimerId then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TipTimerId)
                    self._TipTimerId=nil
                    Node_GameTip:setVisible(false)
                    self._GameStartTipNode = false
                end 
            end,6,false 
            )                                                                       
end

function MyGameScene:hideRankCard()
    local function callback()
        if self.cardBg then
            self.cardBg:removeFromParentAndCleanup()
            self.cardBg = nil
        end
        if self.cardft then
            self.cardft:removeFromParentAndCleanup()
            self.cardft = nil
        end
    end

    local fadeOut = cc.FadeOut:create(0.5)
    local sequence = cc.Sequence:create(fadeOut, cc.CallFunc:create(callback))
    self.cardft:runAction(sequence)

    local fadeOut1 = cc.FadeOut:create(0.5)
    self.cardNum:runAction(fadeOut1)
end


function MyGameScene:setGameBGForTime(gametableNode, gameBgIndex)
    local mainBgS = gametableNode:getChildByName("Img_MainBG")
    local mainBgN = gametableNode:getChildByName("Img_MainBG_Night")
    mainBgS:setVisible(false)
    mainBgN:setVisible(false)

    local tmHour=tonumber(os.date('%H',os.time()))
    if (tmHour>=18 and tmHour<= 23) or (tmHour>=0 and tmHour< 6) then 
        local bgListWithoutMark = {
            "Game/MainBG/Game_MainBG_Night.jpg",        --正常背景图
        }
        local bgListWithMark = {
            "Game/MainBG/Game_MainBG_Night_Mark.jpg",   --带同城游水印背景图
        }
        local bgListWithIcon = {
            "Game/MainBG/Game_MainBG_Night_Icon.jpg",   --带金鼎水印背景图
        }
        local bgList = bgListWithMark
        if cc.exports.isUseMarkWithoutSupported() then
            bgList = bgListWithoutMark
        end
        if cc.exports.isUseMarkJdSupported() then
            bgList = bgListWithIcon
        end
        mainBgN:loadTexture(bgList[1])      
        mainBgN:setVisible(true)
    else
        mainBgS:setVisible(true)
    end
    if gameBgIndex ~= 1 then --选中第一张有白天黑夜效果
        mainBgN:setVisible(false)
        mainBgS:setVisible(true)
    end
    
end

function MyGameScene:onExit()
    self:cancelBackAndFrontGroundEvent()

    self:removeEventHosts()
    MyGameScene.super.onExit(self)

    if self.SortTipsTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.SortTipsTimerID)
        self.SortTipsTimerID = nil
    end

    if self._TipTimerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TipTimerId)
        self._TipTimerId = nil
    end

    if self.goldeeggTipsTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.goldeeggTipsTimerID)
        self.goldeeggTipsTimerID = nil
    end

    if self._GoBackRoomPrompt then
        self._GoBackRoomPrompt:removeEventHosts()
        self._GoBackRoomPrompt = nil
    end

    if self._arenaOverStatement then
        self._arenaOverStatement:onExit()
        self._arenaOverStatement = nil
    end

    if self._arenaNewStatement then
        self._arenaNewStatement:onExit()
        self._arenaNewStatement = nil
    end
    
    if self._cardMakerTool then
        self._cardMakerTool:onExit()
    end

    if self._tools then
        self._tools:onExit()
    end
end

-- 解决Operate_Panel全面屏适配引起 选牌坐标偏移问题
function MyGameScene:setTouched()
    if self._baseLayer then
        self._baseLayer:setTouchEnabled(true)

        local listener = function(eventType, x, y)
            if not self._gameNode then return end
            if self._gameController._forbidTouchCard then
                return
            end
            local node = self._gameNode:getChildByName("Operate_Panel")
            local locationInNode = node:convertToNodeSpace(cc.p(x,y))
            if eventType == "began" then
                self:onTouchBegan(locationInNode.x, locationInNode.y)
                return true
            elseif eventType == "moved" then
                self:onTouchMoved(locationInNode.x, locationInNode.y)
                return false
            elseif eventType == "ended" then
                self:onTouchEnded(locationInNode.x, locationInNode.y)
                return false
            end
        end
        self._baseLayer:registerScriptTouchHandler(listener, false, -1, false)
    end
end

function MyGameScene:SwitchGameBgImage(node, gameBgIndex)
    self._gameController:playBtnPressedEffect()
    
    local gameTableNoe = self._gameNode:getChildByName("Panel_MainBG")
    local mainBgImage = gameTableNoe:getChildByName("Img_MainBG")
    if mainBgImage and node then
        local spriteFrame = node:getVirtualRenderer():getSprite():getSpriteFrame()
        mainBgImage:getVirtualRenderer():getSprite():setSpriteFrame(spriteFrame)
    end
    --设置图片背景
    self:setGameBGForTime(gameTableNoe, gameBgIndex)
end

function MyGameScene:setBoutInfoLabelColor(gameBgIndex)
    local color = cc.c3b(152, 119, 83)
    if gameBgIndex == 5 or gameBgIndex == 6 or gameBgIndex == 7  then
        color = cc.c3b(244,144,168)
    elseif gameBgIndex == 4 then
        color = cc.c3b(61,186,176)
    end
    local panelBoutInfo = self._gameNode:getChildByName('Panel_BoutInfo')
    local children = panelBoutInfo:getChildren()
    for __, child in pairs(children)  do
        if child and child.setTextColor then
            child:setTextColor(color)
        end
    end
end

function MyGameScene:updateGoldeEggData(data)
    if not cc.exports.isGoldEggSupported() then return end
    if PUBLIC_INTERFACE.IsStartAsTimingGame() then return end --定时赛隐藏
    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then return end -- 主播房隐藏
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then return end -- 组队2V2隐藏

    self._SKGoldeEggBtn:setVisible(true)
    local goldeeggNum = self._SKGoldeEggBtn:getChildByName("Text_GoldeggsNum")
    local goldeeggLight = self._SKGoldeEggBtn:getChildByName("Node_Ani_Light")
    local goldeeggTips = self._SKGoldeEggBtn:getChildByName("Img_Tip")
    goldeeggNum:setString(data.nExchangeRoundNum.."/"..data.nMaxRoundNum)
    
    goldeeggLight:setVisible(false)
    goldeeggTips:setVisible(false)
    if data.nExchangeRoundNum >= data.nMaxRoundNum then
        local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_Ani_GoldEggLight.csb")
        action:play("animation0", true)
        goldeeggLight:setVisible(true)
        goldeeggLight:runAction(action)

        local function onClickGoldeEggBtn()
            self:onClickGoldeEggBtn()
            data.nExchangeRoundNum = 0
            self:updateGoldeEggData(data)
        end
        self._SKGoldeEggBtn:addClickEventListener(onClickGoldeEggBtn)
    else
        local function onClickGoldeEggBtn()
            goldeeggTips:setVisible(true)
            local function stopGoldeeggTipsTime()
                if self.goldeeggTipsTimerID then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.goldeeggTipsTimerID)
                    self.goldeeggTipsTimerID = nil
                end
            end
            stopGoldeeggTipsTime()
            self.goldeeggTipsTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
                                stopGoldeeggTipsTime()
                                goldeeggTips:setVisible(false)
                                end, 3.0, false)  
        end
        self._SKGoldeEggBtn:addClickEventListener(onClickGoldeEggBtn)
    end
    self:refreshTopRightBtns()
end

function MyGameScene:onClickGoldeEggBtn()
    self._gameController:reqFinishExchangeRoundTask()
end

function MyGameScene:showBreakEggsAnimation(ntype, nNum)
    if self._breakEggsAnimation == nil then
        local animationNode = cc.CSLoader:createNode("res/GameCocosStudio/csb/Node_ani_BreakEggs.csb")
        animationNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
        self._gameNode:addChild(animationNode)  
        animationNode:setLocalZOrder(SKGameDef.SK_ZORDER_BREAK_EGGS)
        self._breakEggsAnimation = animationNode
    end
    local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_ani_BreakEggs.csb")
    action:play("animation0", false)
    
    local rewardText = self._breakEggsAnimation:getChildByName("Panel_3"):getChildByName("Img_Reward"):getChildByName("Text_RewardNum")
    rewardText:setString("+"..nNum)
    local rewardImage1 = self._breakEggsAnimation:getChildByName("Panel_3"):getChildByName("Img_RewardIcon")
    local rewardImage2 = self._breakEggsAnimation:getChildByName("Panel_3"):getChildByName("Img_RewardIcon2")
    rewardImage1:setVisible(true)
    rewardImage2:setVisible(true)
    if ntype == 8 then  --兑换券
        rewardImage2:setVisible(false)
    else
        rewardImage1:setVisible(false)
    end
    self._breakEggsAnimation:runAction(action)
end

function MyGameScene:setArenaInfo()
    if not self._gameNode or self._arenaInfo then return end
    
    local csbPath = "res/GameCocosStudio/csb/arena_game.csb"
    local arenaInfoPanel = cc.CSLoader:createNode(csbPath)

    --self._gameNode:addChild(arenaInfoPanel,MyGameDef.MY_ZORDER_ARENAINFO)
    self._gameNode:getChildByName("Operate_Panel"):addChild(arenaInfoPanel, MyGameDef.MY_ZORDER_ARENAINFO)
    if arenaInfoPanel then
        arenaInfoPanel:setContentSize(self._gameNode:getChildByName("Operate_Panel"):getContentSize())
        ccui.Helper:doLayout(arenaInfoPanel)
        my.presetAllButton(arenaInfoPanel)

        self._arenaInfo = MyGameArenaInfo:create(arenaInfoPanel, self._gameController)
    end

    self:setArenaLayout()

    self:refreshGameSceneNodesWithButtonScaleOnFixedHeight()
end

function MyGameScene:setArenaStatement(data, isWin)
    if not self._gameNode or self._arenaNewStatement then return end
    
    self._arenaNewStatement = MyGameArenaStatement:create(self._gameNode, self._gameController, isWin)
    self._arenaNewStatement:show(data)
end

function MyGameScene:setArenaOverStatement(data)
    if not self._gameNode or self._arenaOverStatement then return end
    
    self._arenaOverStatement = MyGameArenaOverStatement:create(self._gameNode, self._gameController)
    self._arenaOverStatement:show(data)
end

function MyGameScene:ShowLevelUpgrade(level, exchangeNum, depositNum)
    local csbPath = "res/GameCocosStudio/csb/Node_Upgrade.csb"
    local node = cc.CSLoader:createNode(csbPath)
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        node:runAction(action)
        action:play("animation0", false)

        local function onFrameEvent( frame)
            if frame then 
                local event = frame:getEvent()
                if "Play_Over" == event then
                    action:play("animation1", true)
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
    end

    local BGResName, ColorResName, levelString = cc.exports.LevelResAndTextForData(level)
    local UpgradePanel = node:getChildByName("Panel_Upgrade")
    local GameLevelImg = UpgradePanel:getChildByName("Img_GameLevel")
    local GameLevelColor = GameLevelImg:getChildByName("Img_LevelColor")
    local GameLevelNum = GameLevelImg:getChildByName("Text_LevelNum")
    GameLevelImg:loadTexture(BGResName)
    GameLevelColor:loadTexture(ColorResName)
    GameLevelNum:setString(levelString)

    local exchangePanle = UpgradePanel:getChildByName("Img_Exchange")
    local silverPanle = UpgradePanel:getChildByName("Img_Silver")
    exchangePanle:setVisible(false)
    silverPanle:setVisible(false)
    if exchangeNum > 0 then
        local exchangeTxt = exchangePanle:getChildByName("Text_ExchangeNum")
        exchangeTxt:setString("+"..exchangeNum)
        exchangePanle:setVisible(true)
    end
    if depositNum > 0 then
        local depositTxt = silverPanle:getChildByName("Text_SilverNum")
        depositTxt:setString("+"..depositNum)
        silverPanle:setVisible(true)
    end
    local sureBtn = UpgradePanel:getChildByName("Btn_Sure")
    sureBtn:addClickEventListener(function ()
        node:removeFromParent()
    end)
    if exchangeNum > 0 and depositNum > 0 then
    elseif exchangeNum > 0 then
        exchangePanle:setPositionX((exchangePanle:getPositionX() + silverPanle:getPositionX()) / 2 )
    elseif depositNum > 0 then
        silverPanle:setPositionX((exchangePanle:getPositionX() + silverPanle:getPositionX()) / 2 )
    else
        local imgCongratulations = UpgradePanel:getChildByName("Img_Congratulations")
        if imgCongratulations then
            imgCongratulations:setVisible(false)
        end
        sureBtn:setPositionY(sureBtn:getPositionY() + 100)
    end

    local levelText = UpgradePanel:getChildByName("Text_Level")
    levelText:setString(self._gameController:getGameStringToUTF8ByKey("G_GAME_LEVEL_STRING")..level)

    node:setPosition(display.center)
    node:setLocalZOrder(SKGameDef.SK_ZORDER_UPGRADE_PANLE)
    SubViewHelper:adaptNodePluginToScreen(node, node:getChildByName("Panel_1"))
    self._gameNode:addChild(node)
end

function MyGameScene:setArenaLayout()
    --屏蔽经典场里面的底框
    self._gameNode:getChildByName("Panel_ArenaBar"):setVisible(false)
    self._gameNode:getChildByName("Node_Player1"):setZOrder(MyGameDef.MY_ZORDER_MYSELF)--自己
    self._gameNode:getChildByName("Node_OperationBtn"):setZOrder(MyGameDef.MY_ZORDER_ARENAINFO) --出牌按钮
    self._gameNode:getChildByName("Node_Chat"):setZOrder(MyGameDef.MY_ZORDER_MYSELF+4) --聊天
    self._gameNode:getChildByName("Node_GameTip"):setZOrder(MyGameDef.MY_ZORDER_MYSELF) --提示
    for i=1,4 do
        self._gameNode:getChildByName("Panel_Player"..i):setZOrder(MyGameDef.MY_ZORDER_MYSELF+3)--自己
    end
    

    --设置竞技场相关按钮
    local function tempArenaBtn(newbtn, oldbtn)
        newbtn:setVisible(oldbtn:isVisible())
        newbtn:setTouchEnabled(oldbtn:isTouchEnabled())
        newbtn:setBright(oldbtn:isBright())
        oldbtn:setVisible(false)
    end
    
    local arenaInfoLayer = self._arenaInfo._arenaInfoBar
    local arenaPanel = arenaInfoLayer:getChildByName("Panel_Ani")
    local orderSortBtn = arenaPanel:getChildByName("Btn_Sort")
    if orderSortBtn then
        local function onClickOrderSortBtn()    -- 竞技场大小排序
            local sortFlag = SKGameDef.SORT_CARD_BY_ORDER
            self:dealSortTypeBtnsEvent_New(sortFlag)
        end
        tempArenaBtn(orderSortBtn, self._MyOrderSortBtn)
        self._MyOrderSortBtn = orderSortBtn
        self._MyOrderSortBtn:addClickEventListener(onClickOrderSortBtn)
    end

    local colorSortBtn = arenaPanel:getChildByName("Btn_Color") --花色排序
    if colorSortBtn then
        local function onClickColorSortBtn()    -- 竞技场花色排序
            local sortFlag = SKGameDef.SORT_CARD_BY_SHPAE
            self:dealSortTypeBtnsEvent(sortFlag)
        end
        tempArenaBtn(colorSortBtn, self._MyColorSortBtn)
        self._MyColorSortBtn = colorSortBtn
        self._MyColorSortBtn:addClickEventListener(onClickColorSortBtn)
    end

    local BoomSortBtn = arenaPanel:getChildByName("Btn_Boom")
    if BoomSortBtn then
        local function onClickBoomSortBtn()     -- 竞技场炸弹排序
            local sortFlag = SKGameDef.SORT_CARD_BY_BOME
            self:dealSortTypeBtnsEvent_New(sortFlag)
        end
        tempArenaBtn(BoomSortBtn, self._MyBoomBtn)
        self._MyBoomBtn = BoomSortBtn
        self._MyBoomBtn:addClickEventListener(onClickBoomSortBtn)
    end

    local NumSortBtn = arenaPanel:getChildByName("Btn_NumSort")
    if NumSortBtn then
        local function onClickCardNumSortBtn()  -- 竞技场张数排序
            local sortFlag = SKGameDef.SORT_CARD_BY_NUM
            self:dealSortTypeBtnsEvent(sortFlag)
        end
        tempArenaBtn(NumSortBtn, self._MyNumSortBtnEx)
        self._MyNumSortBtnEx = NumSortBtn
        self._MyNumSortBtnEx:addClickEventListener(onClickCardNumSortBtn)
    end

    local arrangeBtn = arenaPanel:getChildByName("Btn_Tird")
    if arrangeBtn then
        local function onClickArrageBtn()
            self:onClickArrageBtn()
        end
        tempArenaBtn(arrangeBtn, self._MyArrageBtn)
        self._MyArrageBtn = arrangeBtn
        self._MyArrageBtn:addClickEventListener(onClickArrageBtn)
    end

    local ResetBtn = arenaPanel:getChildByName("Btn_Reset")
    if ResetBtn then
        local function onClickResetBtn()
            self:onClickResetBtn()
        end
        tempArenaBtn(ResetBtn, self._MyResetBtn)
        self._MyResetBtn = ResetBtn
        self._MyResetBtn:addClickEventListener(onClickResetBtn)
    end

    local chatBtn = arenaPanel:getChildByName("Btn_Chat")
    if chatBtn then
        local function onClickChatBtn()
            self:onClickChatBtn()
        end
        tempArenaBtn(chatBtn, self._SKChatBtn)
        self._SKChatBtn = chatBtn
        self._SKChatBtn:addClickEventListener(onClickChatBtn)
    end

     --商城按钮
    local shopBtn = arenaPanel:getChildByName("Btn_AddMoney")
    if shopBtn then
        self._MYShopBtn = shopBtn
        shopBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickShopBtn()
            self._gameController:playBtnPressedEffect()
            my.informPluginByName({pluginName='ShopCtrl',params = {defaultPage = "silver", NoBoutCardRecorder = true}})
        end
        self._MYShopBtn:addClickEventListener(onClickShopBtn)
    end

    --//竞技场竖排按钮、同属顺选择器begin
    local SortTypeBtn = arenaPanel:getChildByName("Btn_SortType")
    if SortTypeBtn then
        local imgPath =  ""
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/Game_img.plist")
        local imgPath =  ""
        if self:isVerticalCardsMode() then
            imgPath =  "GameCocosStudio/plist/Game_img/hengxiang.png"
        else
            imgPath =  "GameCocosStudio/plist/Game_img/shuxiang.png"
        end
        SortTypeBtn:loadTextureNormal(imgPath, 1)

        self._MYSortTypeBtn = SortTypeBtn
        SortTypeBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickSortTypeBtn()
            self:onClickSortTypeBtn()
        end
        self._MYSortTypeBtn:addClickEventListener(onClickSortTypeBtn)
    end

    --同花顺选择
    --黑
    local SpadeBtn = arenaPanel:getChildByName("Button_Shape1")
    if SpadeBtn then
        self._MYSpadeBtn = SpadeBtn
        SpadeBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickSpadeBtn()
            self:onClickSpadeBtn()
        end
        self._MYSpadeBtn:addClickEventListener(onClickSpadeBtn)
    end
    --红
    local HeartBtn = arenaPanel:getChildByName("Button_Shape2")
    if HeartBtn then
        self._MYHeartBtn = HeartBtn
        HeartBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickHeartBtn()
            self:onClickHeartBtn()
        end
        self._MYHeartBtn:addClickEventListener(onClickHeartBtn)
    end
    --梅
    local ClubBtn = arenaPanel:getChildByName("Button_Shape3")
    if ClubBtn then
        self._MYClubBtn = ClubBtn
        ClubBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickClubBtn()
            self:onClickClubBtn()
        end
        self._MYClubBtn:addClickEventListener(onClickClubBtn)
    end
    --方
    local DiamondBtn = arenaPanel:getChildByName("Button_Shape4")
    if DiamondBtn then
        self._MYDiamondBtn = DiamondBtn
        DiamondBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickDiamondBtn()
            self:onClickDiamondBtn()
        end
        self._MYDiamondBtn:addClickEventListener(onClickDiamondBtn)
    end

    self:setSortTypeBtnEnabled(false)   -- 开局 没有发牌结束前禁止点击
   
    --//竞技场竖排、同属顺选择器end

    --self._OtherBtn = {self._MyOrderSortBtn,self._MyBoomBtn, self._MyColorSortBtn, self._MyNumSortBtnEx, self._MyArrageBtn, self._MyResetBtn, self._SKChatBtn, 
    --                self._MYShopBtn, self._MYSortTypeBtn, self._MYSpadeBtn, self._MYHeartBtn, self._MYClubBtn, self._MYDiamondBtn, self._MyQuickBoomBtn }
    self._OtherBtn = {self._MyQuickBoomBtn, self._MyArrageBtn, self._MyResetBtn, self._SKChatBtn, self._MYShopBtn, self._MYSortTypeBtn, self._MYSpadeBtn, self._MYHeartBtn, self._MYClubBtn, self._MYDiamondBtn }

    --调整游戏界面
    local posY = 40

    local moveYTable = {Node_OperationBtn="Node_OperationBtn", Panel_Card_Hand="Panel_Card_Hand", Panel_Card_thrown1="Panel_Card_thrown1"
                            , Node_Player1="Node_Player1", Node_Clock1="Panel_Clock.Node_Clock1", Panel_Player1="Panel_Player1", Btn_Rule="Btn_Rule"}
	local needHideView = my.NodeIndexer(self._gameNode, moveYTable)
    for key, value in pairs(needHideView._exchange) do 
        if key ~= "Node_Player1" then
            needHideView[key]:setPositionY(needHideView[key]:getPositionY() + posY)
        end
    end

    --Panel_Player1上移，但是部分元素不能上移（它们是靠近并对其自身头像的元素）

    local fixedChildOfPanelPlayer1 = {"Node_PlayerName", "Node_ChatPapo", "Node_Emotion", "Node_SilverValue"}
    for _, childName in pairs(fixedChildOfPanelPlayer1) do
        local nodeChild = needHideView["Panel_Player1"]:getChildByName(childName)
        if nodeChild then
            nodeChild:setPositionY(nodeChild:getPositionY() - posY)
        end
    end

    --SKGameDef.SK_CARD_START_POS_Y = SKGameDef.SK_CARD_START_POS_Y + 30
    local oddsPanel = needHideView["Panel_Player1"]:getChildByName("Panel_Odds")
    oddsPanel:setPosition(cc.p(oddsPanel:getPositionX() - 90,oddsPanel:getPositionY() - 40))
    --oddsPanel:setVisible(self._gameController.haveBombDouble)

    if self._clock then
        self._clock:updateClockPositionForArena()
    end
end

function MyGameScene:showRobScorePanel(isWin)
    if not self._gameNode then return end
    
    local csbPath = "res/GameCocosStudio/csb/Layer_LoseSeizeScore.csb"
    if isWin then
        csbPath = "res/GameCocosStudio/csb/Layer_WinSeizeScore.csb"
    end
    local robScorePanel = cc.CSLoader:createNode(csbPath)
    robScorePanel:setLocalZOrder(SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
	local origin = cc.Director:getInstance():getVisibleOrigin()
	robScorePanel:setContentSize(visibleSize)
    ccui.Helper:doLayout(robScorePanel)
    self._gameNode:addChild(robScorePanel)
    
    local lastHeart = nil
    if not isWin then
        local leftHP            = self._gameController._baseGameArenaInfoManager:getHP()
        local initHP            = self._gameController._baseGameArenaInfoManager:getInitHP()

        local AnimationPanel = robScorePanel:getChildByName("Panel_Basics")
        if AnimationPanel then
            for count = 1, initHP do 
                local HPNode = AnimationPanel:getChildByName("ProjectNode_Heart"..count)
                if count > leftHP then
                    HPNode:setVisible(false)
                else
                    HPNode:setVisible(true)
                end
                if count == leftHP then
                    lastHeart = HPNode
                end
            end
        end
    end

    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        robScorePanel:runAction(action)
        action:play("animation_seizescore", false)

        local function onFrameEvent(frame)
            if frame then 
                local event = frame:getEvent()
                if "Play_Over" == event then
                    if lastHeart then
                        local HeartAction = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_SubtractHeart.csb")
                        lastHeart:runAction(HeartAction)
                        local function onHeartFrameEvent(frame)
                            if frame then 
                                local event = frame:getEvent()
                                if "Play_Over" == event then
                                    robScorePanel:removeFromParent()
                                end
                            end
                        end
                        HeartAction:play("animation_SubtractHeart", false)
                        HeartAction:setFrameEventCallFunc(onHeartFrameEvent)
                    else
                        robScorePanel:removeFromParent()
                    end
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
    end
end

function MyGameScene:setArenaGameResult(data)
    if not self._gameNode or self._arenaGameResult then return end
    --[[data = {} --测试数据
    data.nDepositDiffs = {1000,-1000,1000,-1000}
    data.nPlace={1,2,3,4}]]
    self._arenaGameResult = MyGameArenaGameResult:create(self._gameNode, self._gameController, data)
end

function MyGameScene:setPlayers()
    if not self._gameNode then return end
    if not self._gameController then return end

    local players = {}
    for i = 1, self._gameController:getTableChairCount() do
        if i == 1 then
            local playerPanel = self._gameNode:getChildByName("Panel_Player" .. tostring(i))
            local playerNode = self._gameNode:getChildByName("Node_Player" .. tostring(i))
            if playerPanel then
                players[i] = MyGameSelfPlayer:create(playerPanel, playerNode, i, self._gameController)
            end
        else
            local playerPanel = self._gameNode:getChildByName("Panel_Player" .. tostring(i))
            local playerNode = self._gameNode:getChildByName("Node_Player" .. tostring(i))
            if playerPanel then
                players[i] = MyGamePlayer:create(playerPanel, playerNode, i, self._gameController)
            end
        end
    end

    self._playerManager = MyGamePlayerManager:create(players, self._gameController)
end

function MyGameScene:getMyPlayerManager()
    if self._playerManager then
        return self._playerManager
    end
end

function MyGameScene:setChat()
    if not self._gameNode then return end

    local chatPanel = self._gameNode:getChildByName("Node_Chat")
    if chatPanel then
        self._chat = MyGameChat:create(chatPanel, self._gameController)
        SubViewHelper:adaptNodePluginToScreen(chatPanel, chatPanel:getChildByName("Panel_Shade"))
        self._chat:setVisible(false)
    end
end

function MyGameScene:onClickSortTypeBtn()
    local SKHandCardsManager        = self:getSKHandCardsManager()
    SKHandCardsManager:resetRemind()

    local resetRemind
    -- 切换竖向理牌时关闭切牌特效
    local nodeEffect = self._gameNode:getChildByTag(MyGameDef.MY_TAG_EFFECT_SORT)
    if nodeEffect then
        nodeEffect:removeFromParent()
        nodeEffect = nil
    end
    -- 切换竖向理牌临时用
    if false == self._gameController:isSupportVerticalCardMode() then
        return
    end
    
    self._gameController:playGamePublicSound("snd_sort.mp3")
    -- 对家手牌不给切换
    local nFriendCardsCount = self._gameController._baseGameUtilsInfoManager._utilsTableInfo._nFriendCardCount
    if nFriendCardsCount and nFriendCardsCount > 0 then
        return
    end
    -- 对家手牌不给切换（针对玩家1倒计时0s出牌头游时切换做的优化）
    local myHandCards = self._SKHandCardsManager:getSKHandCards(self._gameController:getMyDrawIndex())
    if myHandCards and  myHandCards.getMySelfHandCardsCount then
        if myHandCards:getMySelfHandCardsCount() <= 0 then
            print("can not switch the vertical mode when show FriendCards !!!")
            return
        end
    end

   if self:isVerticalCardsMode() == true then
        self._VerticalMode = false
    else
        self._VerticalMode = true
    end

    -- step1： 切换前 记录原来的手牌 以及其他玩家手牌数量
    local chairCards = {}
    local chairCardCounts = {}
    local myDrawIndex = self._gameController:getMyDrawIndex()
    for i = 1, self._gameController:getTableChairCount() do
        local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(i - 1)
        if drawIndex == myDrawIndex then
            local inhandCards, cardsCount= self._SKHandCardsManager:getHandCardIDs(drawIndex)
            chairCards[drawIndex] = inhandCards
            chairCardCounts[drawIndex] = cardsCount
        else
            chairCards[drawIndex] = {}
            chairCardCounts[drawIndex] = self._SKHandCardsManager._SKHandCards[drawIndex]:getHandCardsCount()
        end
    end


    -- step2： 清空手牌相关 并切换 myHandCards <---> myHandCardsCustom
    self._SKHandCardsManager:OnResetArrageHandCard() -- 理牌超过两列，没有撤销理牌直接切换会出问题。因此这里强制撤销
    self._SKHandCardsManager.super.resetHandCardsManager(self._SKHandCardsManager)
    self:changeSomeBtnPosition()
    self._SKHandCardsManager = nil
    self:setHandCards()


    -- step3: 把数据恢复
    --local cardsCounts = self._gameController._baseGameUtilsInfoManager:getCardsCount()  -- 从这里获取各玩家的手牌数量会滞后，引起出牌后立即切换显示不正确
    for i = 1, self._gameController:getTableChairCount() do
        local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(i - 1)
        if 0 < drawIndex then
            self._SKHandCardsManager:setHandCardsCount(drawIndex, chairCardCounts[drawIndex])

            if drawIndex == myDrawIndex then
                self._SKHandCardsManager:setSelfHandCards(chairCards[myDrawIndex], true)
                self._SKHandCardsManager:ope_SortSelfHandCards()
            end

            self._gameController:setCardsCount(drawIndex, chairCardCounts[drawIndex], false)
        end
    end
    
    self._SKHandCardsManager:setEnableTouch(true)
    local status        = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) or self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then     
        self._SKHandCardsManager:OPE_MaskCardForTributeAndReturn()
    end

    local waitChair = self._gameController._baseGameUtilsInfoManager:getWaitChair()
    if waitChair == -1 then
        self._SKHandCardsManager:setFirstHand(1)
    else
        self._SKHandCardsManager:setFirstHand(0)
        --此处用waitChair有问题，waitChair在自己出牌或不出后不会变，导致轮到下家出牌还是可以触发提示
        local currentIndex = self._clock:getDrawIndex()
        if currentIndex == self._gameController:getMyDrawIndex() then
            self._gameController:OPE_ShowNoBiggerTip()
        end
    end

    -- sekf_VerticalMode状态和 按钮图片相关
    local imgPath =  ""
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/Game_img.plist")
    if self:isVerticalCardsMode() == true then
        imgPath =  "GameCocosStudio/plist/Game_img/hengxiang.png"
    else
        imgPath =  "GameCocosStudio/plist/Game_img/shuxiang.png"
    end

    -- 做个异步，切换快一点
    my.scheduleOnce(function()
       --if self:isInGameScene() == false then return end
       MyHandCardsCache:setHandCardsModeCache(self._VerticalMode)
    end, 0.5)
    self._MYSortTypeBtn:loadTextureNormal(imgPath, 1)
    print("  +++++++++++++++onClickSortTypeBtn Success!!!")

    --17期客户端埋点
    if self:isVerticalCardsMode() == true then
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_SORT_TYPE_VERTICAL_BTN)
    else
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_SORT_TYPE_HORIZONTAL_BTN)
    end
end

function MyGameScene:dealTHSClickEvent(cardShape)
    self._SKHandCardsManager:ope_UnselectSelfCards()
    local remindCards = self._SKHandCardsManager:getTHSCardsUnitesByCardShape(cardShape, true)
    if not next(remindCards) then
        self._gameController:ope_CheckSelect()
        return
    end
    self._SKHandCardsManager:selectMyCardsByIDs(remindCards, SKGameDef.SK_CHAIR_CARDS)
    self._gameController:ope_CheckSelect()
end

-- 黑桃
function MyGameScene:onClickSpadeBtn()
    self:dealTHSClickEvent(SKGameDef.SK_CS_SPADE)
    self:onClickFlush()
end

--红心
function MyGameScene:onClickHeartBtn()
    self:dealTHSClickEvent(SKGameDef.SK_CS_HEART)
    self:onClickFlush()
end

--梅花
function MyGameScene:onClickClubBtn()
    self:dealTHSClickEvent(SKGameDef.SK_CS_CLUB)
    self:onClickFlush()
end

--方片
function MyGameScene:onClickDiamondBtn()
    self:dealTHSClickEvent(SKGameDef.SK_CS_DIAMOND)
    self:onClickFlush()
end

function MyGameScene:disableShapeButtons(disableIDs)
    local shapeButtons = {}
    shapeButtons[SKGameDef.SK_CS_SPADE]     = self._MYSpadeBtn  -- 黑桃 3
    shapeButtons[SKGameDef.SK_CS_HEART]     = self._MYHeartBtn  -- 红桃 2
    shapeButtons[SKGameDef.SK_CS_CLUB]      = self._MYClubBtn   -- 梅花 1 
    shapeButtons[SKGameDef.SK_CS_DIAMOND]   = self._MYDiamondBtn -- 方片 0

    if(type(disableIDs)=='table')then
        for k,v in pairs(disableIDs) do 
            local status = v
            if shapeButtons[k] then
                shapeButtons[k]:setBright(status)
                shapeButtons[k]:setTouchEnabled(status)
                --shapeButtons[k]:setVisible(status)
                local a = shapeButtons[k]:isBright()
                local b = shapeButtons[k]:isTouchEnabled()
            end
        end
    end
end

function MyGameScene:changeSomeBtnPosition()
    if not self._gameNode then return end

    if false ==  self._gameController:isSupportVerticalCardMode() then     
        return
    end
    
    ----local needHideBtns = {self._MyOrderSortBtn, self._MyNumSortBtnEx, self._MyColorSortBtn,self._MyBoomBtn}
    -- 大小、炸弹、张数、花色, 显示用
    ----local btnsOrder = {self._MyBoomBtn, self._MyColorSortBtn, self._MyOrderSortBtn, self._MyNumSortBtnEx} -- 该数据是根据needHideBtns对应好的下一个按钮
    
    local OFFSET = {
        opeBtnsOffset = 120,
        otherOffset   = 50
    }

    --[[if self._gameController:isArenaPlayer() then
        -- 因为竞技场Node_Player1 参考点上移了40，故这里throw移20 即可
        OFFSET.opeBtnsOffset = 20
    end]]--


    local winSize = cc.Director:getInstance():getWinSize()
    local ratio = winSize.width /winSize.height
    if DEBUG and DEBUG > 0 then
        print('changeSomeBtnPosition ratio '..ratio..' width '..winSize.width..' height '..winSize.height)
    end
    if ratio >= 1.9 and ratio < UIHelper.WHRATIO_OF_ADAPT_SEPERATE then
        OFFSET.opeBtnsOffset = 80
    elseif ratio >= UIHelper.WHRATIO_OF_ADAPT_SEPERATE then
        OFFSET.opeBtnsOffset = 40
    end

    if self._gameController:isArenaPlayer() then
        OFFSET.opeBtnsOffset = OFFSET.opeBtnsOffset - 40
    end

    local status        = self._gameController._baseGameUtilsInfoManager:getStatus()

    local myDrawIndex = self._gameController:getMyDrawIndex()
    local playerPanel = self._gameNode:getChildByName("Panel_Player1")
    local standPosition = cc.p(playerPanel:getPosition())
    local opeBtnsNode = self._gameNode:getChildByName("Node_OperationBtn")
    local clockNode1 = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock1")
    local thrownPosition1 = self._gameNode:getChildByName("Panel_Card_thrown1")
    local clockNode5 = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock5")

    --FixedHeight模式下牌被放大，则适当上移这些元素位置
    local cardScaleVal = UIHelper:getProperScaleOnFixedHeight()
    if cardScaleVal > 1.0 then
        local scaleOffset = cardScaleVal - 1.0
        local posYOffset = 350 * 0.25

        if self:isVerticalCardsMode() then
            OFFSET.opeBtnsOffset = OFFSET.opeBtnsOffset + posYOffset
            OFFSET.otherOffset = OFFSET.otherOffset + posYOffset
        else
            if self._gameController:isArenaPlayer() then
                OFFSET.opeBtnsOffset = -40 + posYOffset
                OFFSET.otherOffset = -40 + posYOffset
            else
                OFFSET.opeBtnsOffset = 0 + posYOffset
                OFFSET.otherOffset = 0 + posYOffset
            end
        end
    else
        if self:isVerticalCardsMode() then
        else
            OFFSET.opeBtnsOffset = 20
            OFFSET.otherOffset = 20
        end
    end

     --- 竖向排列调整
    if self:isVerticalCardsMode() then
        -- standPosition.y = 0, 不知道啥原因opeBtns偏移50就够了，但csb中opeBtns的y坐标有290
        if opeBtnsNode then opeBtnsNode:setPositionY(standPosition.y + 290 + OFFSET.opeBtnsOffset) end
        if myDrawIndex == self._clock:getDrawIndex() then
         -- 操作clock坐标时候需要判断两个drawIndex是否一致，不然不是自己出牌的时候切换就影响其他位置的clock的显示
            if clockNode1 then clockNode1:setPositionY(standPosition.y +303 +  OFFSET.opeBtnsOffset) end
        end
            
        --thrownPosition1:setPositionY(standPosition.y + 205 +  OFFSET.opeBtnsOffset)
        thrownPosition1:setPositionY(standPosition.y + 195 +  OFFSET.opeBtnsOffset)
        self._SKThrownCardsManager:sortThrownCards(myDrawIndex)

        if self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) or self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
            --[[for k,v in pairs(needHideBtns) do
                if v then
                    v:setVisible(false)
                end
            end]]

        end

        if self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) or self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then  
            clockNode5:setPositionX(self:getCenterXOfOperatePanel() + 160) -- 先设置节点位置
            if ratio >= 1.9 then
                opeBtnsNode:setPositionY(standPosition.y + 290+ 100)
                clockNode5:setPositionY(standPosition.y + 290+ 115) 
                if self._upInfo and self._upInfoPosition then    -- 全面屏适配 一下“等待玩家进贡。。”提示
                    self._upInfo:setPositionY(self._upInfoPosition.y + 130) 
                end
            else
                opeBtnsNode:setPositionY(standPosition.y + 290+ 130)
                clockNode5:setPositionY(standPosition.y + 290+ 130)   -- 先设置节点位置
            end
            self:getClock():moveClockHandTo(-1)                 -- 在更新clock位置， 试了我好久！！！ - - 
        end
    else
    --- 横向排列调整
        if opeBtnsNode then opeBtnsNode:setPositionY(standPosition.y + 290 + OFFSET.opeBtnsOffset) end
        if myDrawIndex == self._clock:getDrawIndex() then
            if clockNode1 then clockNode1:setPositionY(standPosition.y + 303 + OFFSET.opeBtnsOffset) end
        end

        thrownPosition1:setPositionY(standPosition.y + 205 + OFFSET.opeBtnsOffset + 20)

        self._SKThrownCardsManager:sortThrownCards(myDrawIndex)

        if self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) or self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
            --[[for k,v in pairs(needHideBtns) do
                if v then
                    v:setVisible(false)
                end
            end]]
        end

        if self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) or self._gameController:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
            clockNode5:setPositionX( self:getCenterXOfOperatePanel()+ 160)
            if ratio >= 1.9 then
                opeBtnsNode:setPositionY(standPosition.y + 290+ 40)
                clockNode5:setPositionY(standPosition.y + 290+ 55)   -- 先设置节点位置
                self:getClock():moveClockHandTo(-1)                 -- 在更新clock位置， 试了我好久！！！ - - 
                if self._upInfo and self._upInfoPosition then    -- 全面屏适配 一下“等待玩家进贡。。”提示
                    self._upInfo:setPositionY(self._upInfoPosition.y + 130 )
                end
            else
                opeBtnsNode:setPositionY(standPosition.y + 290+ 130)
                clockNode5:setPositionY(standPosition.y + 290+ 130)   -- 先设置节点位置
            end
            self:getClock():moveClockHandTo(-1)
        end

    end

    if self._gameController:getMyDrawIndex() == self._clock:getDrawIndex() then
        if self._clock then self._clock:updateClockPositionForArena() end
    end
end

--显示理牌特效
function MyGameScene:playSortEffect()
    --去掉理牌特效
    --[[if self._gameController:getArrageCardMode() == MyGameDef.SORT_CARD_BY_VERTICAL then
        return
    end
    local drawIndex     = self._gameController:getMyDrawIndex()
    local SKHandCard    = self._SKHandCardsManager:getSKHandCards(drawIndex)
    local cardsCount    = SKHandCard:getHandCardsCount()--当前手牌数量
    local cardSize      = SKHandCard._cards[1]:getContentSize()
    local startP        = SKHandCard:getSelfHandCardsPosition(1) --第一张牌左下角坐标
    local startX        = startP.x
    local startY        = startP.y
    local endX          = SKHandCard:getSelfHandCardsPosition(cardsCount).x + cardSize.width --最后一张牌右下角坐标

    local path = 'res/GameCocosStudio/csb/Node_Animation_sort.csb'

    if self._gameNode then
        local nodeEffect = self._gameNode:getChildByTag(MyGameDef.MY_TAG_EFFECT_SORT)
        if nodeEffect then
            nodeEffect:removeFromParent()
            nodeEffect = nil
        end
        local aniNode   = cc.CSLoader:createNode(path)
        local action    = cc.CSLoader:createTimeline(path)
        local img = aniNode:getChildByName("Image_1")
        --[[if cc.exports.isFullScreen() then
            img:setContentSize(cc.size(720 - (startX - 0.5),150)) --因为特效本身是两倍缩放
        else
            img:setContentSize(cc.size(700 - (startX - 0.5),150)) --因为特效本身是两倍缩放
        end]]--

        --[[local offsetX = (self._gameController:getWidthOfOperatePanel() - 1280) / 2
        img:setContentSize(cc.size(700 - (startX - 0.5) + offsetX,150)) --因为特效本身是两倍缩放
        self._gameNode:addChild(aniNode,MyGameDef.MY_ZORDER_SORTEFFECT,MyGameDef.MY_TAG_EFFECT_SORT)

        local winSize = cc.Director:getInstance():getWinSize()
        aniNode:setPosition(cc.p(winSize.width/2 - 5,cardSize.height/2 + startY))

        if action then
            aniNode:runAction(action)
            action:play("animation0", false)

            local function callBack(frame)
                if frame and frame:getEvent() == "Play_Over" then
                    action:clearFrameEventCallFunc()
                    aniNode:removeFromParent()
                end
            end
            action:setFrameEventCallFunc(callBack)
        end
    end]]--
end

--获取银子显示控件
function MyGameScene:getSelfDepositText()
    if not self._gameNode then return false end
    return self._gameNode:getChildByName("Panel_ArenaBar"):getChildByName("Panel_Deposit"):getChildByName("Text_Num")
end

--获取定时赛积分显示控件
function MyGameScene:getSelfTimingScoreText()
    if not self._gameNode then return false end
    return self._gameNode:getChildByName("Panel_ArenaBar"):getChildByName("Panel_TimingScore"):getChildByName("Text_Num")
end

--玩家点击同花顺
function MyGameScene:onClickFlush()
    local nodeEffect = self._gameNode:getChildByTag(MyGameDef.MY_TAG_EFFECT_SORT)
    if nodeEffect then
        nodeEffect:removeFromParent()
        nodeEffect = nil
    end
    local data = cc.exports.LogSortCardData
    data.nClickFlush = data.nClickFlush and data.nClickFlush + 1 or 1
    -- self._gameController:checkGameGuide()
    self._gameController:checkNewUserGuide()
end

function MyGameScene:setThrownCards()
    local thrownCards = {}
    for i = 1, self._gameController:getTableChairCount() do
        thrownCards[i] = MyThrownCards:create(i, self._gameController)
    end

    self._SKThrownCardsManager = MyThrownCardsManager:create(thrownCards, self._gameController)
end

function MyGameScene:isVerticalCardsMode()
    if self._VerticalMode == nil then
        local cache = MyHandCardsCache:readFromCacheData()
        if cache then
            self._VerticalMode = cache.HandCardsMode
        end
    end

    if nil  == self._VerticalMode then return false end

    return self._VerticalMode
end


function MyGameScene:doSomethingForVerticalCard()
    if next(self._gameController._baseGameUtilsInfoManager._utilsTableInfo) ~= nil and self._gameController._baseGameUtilsInfoManager._utilsTableInfo._nFriendCardCount > 0 then
        self:setSortTypeBtnEnabled(false)   -- 断线重连，对家手牌隐藏切换按钮
    else
        self:setSortTypeBtnEnabled(true) -- 断线重连，也要恢复一下切换按钮的 可点击状态
    end
    
    self:changeSomeBtnPosition() -- 断线重连，刷新按钮位置
end

function MyGameScene:addGameNode()
    print("MyGameScene:addGameNode")
    if not self._baseLayer then return end

    local gameLayer = self._baseLayer:getChildByTag(self.GameTags.GAMETAGS_GAMELAYER)
    if gameLayer then
        local csbPath = "res/GameCocosStudio/csb/GameScene.csb"
        UIHelper:recordRuntime("EnterGameScene", "MyGameScene loadGameSceneNode begin")
        self._gameNode = cc.CSLoader:createNode(csbPath)

        UIHelper:recordRuntime("EnterGameScene", "MyGameScene loadGameSceneNode end")
        if self._gameNode then
            self._gameNode:setContentSize(cc.Director:getInstance():getVisibleSize())
            ccui.Helper:doLayout(self._gameNode)
            gameLayer:addChild(self._gameNode)

            my.presetAllButton(self._gameNode)
            cc.exports.zeroBezelNodeAutoAdapt(self._gameNode:getChildByName("Operate_Panel"))
            self:_decorateGameSceneNodeFunc_getChildByName(self._gameNode)
            print("MyGameScene:addGameNode gamenode created and added to scene")
        end
        UIHelper:recordRuntime("EnterGameScene", "MyGameScene doLayout gameSceneNode end")
    end

    UIHelper:recordRuntime("EnterGameScene", "MyGameScene deal other node of gameScene begin")
    self:refreshGameSceneNodesOnCardScaleOnFixedHeight()

    self:setClock()
    self:setPlayers()
    self:setGameInfo()
    self:setTools()
    self:setChatBtn()
    self:setStart()
    self:setSelfInfo()
    self:setAutoPlay()
    self:setChat()
    self:setSafeBox()
    self:setSetting()
    self:setThrowAnimation()

    self:setUpInfo()
    
    self:setRuleBtn()
    self:setRule()

    UIHelper:recordRuntime("EnterGameScene", "MyGameScene:createChartredRoom begin")
    self:createChartredRoom()
        
    UIHelper:recordRuntime("EnterGameScene", "MyGameScene:setGameCtrlsAboveBaseGame begin")
    self:setGameCtrlsAboveBaseGame()

    if self._gameController:isArenaPlayer() then
        self:setArenaInfo()
    end

    self:setCardMakerTool()

    self:setRuleInfoNode()

    self:refreshGameSceneNodesWithButtonScaleOnFixedHeight()

    WinningStreakModel:gc_GetWinningStreakInfo()  --请求连胜挑战数据

    UIHelper:recordRuntime("EnterGameScene", "MyGameScene deal other node of gameScene end")
end

--记牌器
function MyGameScene:setCardMakerTool()
    if not self._gameNode then return end

    local cardMakerNode = self._gameNode:getChildByName("Node_CardMaker")
    cardMakerNode:setZOrder(MyGameDef.MY_ZORDER_MYSELF+2)
    if cardMakerNode then
        self._cardMakerTool = MyGameCardMakerTool:create(cardMakerNode, self._gameController)
        cardMakerNode:setVisible(true)
        self._cardMakerTool:setCardMakerInfo()
        self._cardMakerTool:OnShowCardMakerInfo(false)
    end
end

function MyGameScene:setCardMakerInfo()
    if self._cardMakerTool == nil then
        return
    end
    self._cardMakerTool:setCardMakerInfo()
end
function MyGameScene:updateCardMakerCountInGame()
    if self._cardMakerTool == nil then
        return
    end
    self._cardMakerTool:updateCardMakerCountInGame()
end
--[[
function MyGameScene:onShowClickCardMaker()
    self._gameController:playBtnPressedEffect()
    local cardMaker_bg = self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg")
    if cardMaker_bg:isVisible() then
        --cardMaker_bg:setVisible(false)
        self:OnShowCardMakerInfo(false, true)
    else
        if self._gameNode:getChildByName("Node_CardMaker"):getChildByName("Time_text"):isVisible() or self._gameNode:getChildByName("Node_CardMaker"):getChildByName("red_point"):isVisible() then  --倒计时结束显示00:00，记牌器还是能使用
            --cardMaker_bg:setVisible(true)
            self:onRefreshCardMaker()
            self:OnShowCardMakerInfo(true, true)
        else
            if cc.exports.CardMakerInfo.nCardMakerNum and (cc.exports.CardMakerInfo.nCardMakerNum > 0 or cc.exports.CardMakerInfo.nCardMakerCountdown > 0) then
                --cardMaker_bg:setVisible(true)
                self:onRefreshCardMaker()
                self:OnShowCardMakerInfo(true, true)
            else
                --shopEx:OnPayToolClickByRmb(2) --快速购买一天的记牌器
                --ShopModel:tryBuyCardRecorder(ShopModel:getShopItemData("prop", 1, "prop_cardrecorder_day"))
                --my.informPluginByName({pluginName='ShopCtrl'})
                my.informPluginByName({pluginName='ShopCtrl',params = {defaultPage = "prop", NoBoutCardRecorder = true}})
            end
        end
    end
end

function MyGameScene:onRefreshCardMaker()
    for i=1,15 do
        local text = self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg"):getChildByName("Text_" .. i)
        local str = self._gameController._MyGameCardMaker.ThrowCardByIndex[i]
        text:setString(str)
        if str > 0 then
            text:setColor(cc.c3b(208, 64, 8))
        else
            text:setColor(cc.c3b(140, 140, 140))
        end
    end
end

function MyGameScene:setCardMakerInfo()
    local Buy_pic        = self._gameNode:getChildByName("Node_CardMaker"):getChildByName("Buy_pic")
    local Time_text      = self._gameNode:getChildByName("Node_CardMaker"):getChildByName("Time_text")
    local CardMaker_bg   = self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg")
    local Red_point      = self._gameNode:getChildByName("Node_CardMaker"):getChildByName("red_point")

    if cc.exports.CardMakerInfo.nCardMakerNum and cc.exports.CardMakerInfo.nCardMakerNum > 0 then
        Buy_pic:setVisible(false)
        Time_text:setVisible(false)
        CardMaker_bg:setVisible(true)
        Red_point:setVisible(true)

        if cc.exports.CardMakerInfo.nCardMakerNum > 99 then
            Red_point:getChildByName("num"):setString("99+")
        else
            Red_point:getChildByName("num"):setString(cc.exports.CardMakerInfo.nCardMakerNum)
        end
        
        self:onRefreshCardMaker()
    elseif cc.exports.CardMakerInfo.nCardMakerCountdown and cc.exports.CardMakerInfo.nCardMakerCountdown > 0 then
        Buy_pic:setVisible(false)
        Time_text:setVisible(true)
        CardMaker_bg:setVisible(true)
        Red_point:setVisible(false)

        self:onRefreshCardMaker()

        self._CardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown
        Time_text:setString(self:getCardMakerTime(self._CardMakerCountdown))
        if not self._CardMakerTimer then
            self._CardMakerTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateCardMakerTime),1,false)
        end
    else
        Buy_pic:setVisible(true)
        Time_text:setVisible(false)
        CardMaker_bg:setVisible(false)
        Red_point:setVisible(false)
    end
    self:onShowCardMakerRank()
end

function MyGameScene:updateCardMakerTime(delta)
    if self._CardMakerCountdown and self._CardMakerCountdown > 0 then
        self._CardMakerCountdown = self._CardMakerCountdown - 1
        self._gameNode:getChildByName("Node_CardMaker"):getChildByName("Time_text"):setString(self:getCardMakerTime(self._CardMakerCountdown))
    else
        if self._CardMakerTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CardMakerTimer)
            self._CardMakerTimer = nil
        end
    end
end

function MyGameScene:onShowCardMakerRank()
    local rank = self._gameController._baseGameUtilsInfoManager:getCurrentRank()
    if rank < 1 then
        rank = 1
    end
    local pos = {463.50, 432, 401, 370, 339, 308, 277, 246, 215, 184, 153, 122, 91}
    self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg"):getChildByName("rank_tag" ):setPositionX(pos[rank])
end

function MyGameScene:updateCardMakerCount()
    if cc.exports.CardMakerInfo.nCardMakerNum and cc.exports.CardMakerInfo.nCardMakerNum > 0 then
        cc.exports.CardMakerInfo.nCardMakerNum = cc.exports.CardMakerInfo.nCardMakerNum -1
        if cc.exports.CardMakerInfo.nCardMakerNum > 99 then
            self._gameNode:getChildByName("Node_CardMaker"):getChildByName("red_point"):getChildByName("num"):setString("99+")
        else
            self._gameNode:getChildByName("Node_CardMaker"):getChildByName("red_point"):getChildByName("num"):setString(cc.exports.CardMakerInfo.nCardMakerNum)
        end
    end
end

function MyGameScene:OnShowCardMakerInfo(visible, isTouch)
    local isVisible = visible or false
    local tag = false
    if isVisible and cc.exports.CardMakerInfo.nCardMakerNum and (not self._gameNode:getChildByName("Node_CardMaker"):getChildByName("Buy_pic"):isVisible()) then
        self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg"):setScale(0.4)
        self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg"):runAction(cc.ScaleTo:create(0.2, 1, 1))
        self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg"):setVisible(isVisible)
        tag = true
    else
        self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg"):setVisible(false)
    end

    if isTouch then
        local data = {}
        data.isVisible = tag
        local cacheFile = "CardMaker.xml"
        my.saveCache(cacheFile,data)
    end
end

function MyGameScene:getCardMakerTime(countdown)
    local timeStr = self:getTime(countdown)
    local dateTab = string.split(timeStr, ":")
    if dateTab[1] and tonumber(dateTab[1]) > 24 then
        local day = math.ceil(tonumber(dateTab[1])/24)
        local str = ""
        if day > 99 then
            str = "剩余天数:99+"
        else
            str = "剩余天数:" .. day
        end
        return str
    else
        return timeStr
    end
end
--]]

function MyGameScene:ShowTakeRedDot(isShow)
    if self._SKMissionBtn then
        local redDot = self._SKMissionBtn:getChildByName("Img_Dot")
        if redDot then
            redDot:setVisible(isShow)
        end
    end
end

function MyGameScene:onModuleStatusChanged(data)
    local eventData = data.value
    local moduleName = eventData["moduleName"]
    local eventName = eventData["eventName"]
    local dataModel = eventData["dataModel"]

    if eventName == TaskModel.EVENT_MAP["taskModel_rewardAvailChanged"] then
        self._gameController:IsHaveTaskFinish()
    end
end

--[[function MyGameScene:updateTaskRedDot()
    self._gameController:IsHaveTaskFinish()
end]]--
--[[
function MyGameScene:updateCardMakerCountInGame()
    if self._gameController and self._gameController:isGameRunning() then
        if cc.exports.CardMakerInfo.nCardMakerNum and cc.exports.CardMakerInfo.nCardMakerNum > 0 then
            local function setInfo(  )
                self._gameNode:getChildByName("Node_CardMaker"):getChildByName("red_point"):setVisible(true)
                self._gameNode:getChildByName("Node_CardMaker"):getChildByName("Buy_pic"):setVisible(false)

                if my.isCacheExist("CardMaker.xml") then
                    local dateInfo = my.readCache("CardMaker.xml")
                    dateInfo=checktable(dateInfo)
                    self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg"):setVisible(dateInfo.isVisible)
                else
                    self._gameNode:getChildByName("Node_CardMaker"):getChildByName("cardMaker_bg"):setVisible(true)
                end
                
                self:updateCardMakerCount()
            end
           my.scheduleOnce(setInfo, 0.3)
        end
    end
end
--]]

--获取刘海屏大小
function MyGameScene:getOffsetXofOperatePanel()
    local offsetX = display.width - self:getCenterXOfOperatePanel()*2
    return offsetX/2
end

--对卡牌放大之后部分界面元素上移一定距离；changeSomeBtnPosition()中还有一处同样的位置移动处理
function MyGameScene:refreshGameSceneNodesOnCardScaleOnFixedHeight()
    if not self._gameNode then return end

    local nodeOpeBtns = self._gameNode:getChildByName("Node_OperationBtn")
    local nodeMyClock = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock1")

    local cardScaleVal = UIHelper:getProperScaleOnFixedHeight()
    if cardScaleVal > 1.0 then
        local scaleOffset = cardScaleVal - 1.0
        local posYOffset = 350 * 0.25

        nodeOpeBtns:setPositionY(nodeOpeBtns:getPositionY() + posYOffset)
        nodeMyClock:setPositionY(nodeMyClock:getPositionY() + posYOffset)
    end
end

--对按钮放大
function MyGameScene:refreshGameSceneNodesWithButtonScaleOnFixedHeight()
    if not self._gameNode then return end    

    local curWHRatio = display.width / display.height
    if curWHRatio < 2.05 then
        return --较小的长宽比，则不放大和移位，因为水平宽度不够，会超出屏幕
    end

    local cardScaleVal = UIHelper:getProperScaleOnFixedHeight()
    if cardScaleVal > 1.0 then
        local btnNamesToScale = {
            "Btn_SortType", "Button_Shape4", "Button_Shape3", "Button_Shape2", "Button_Shape1", 
            "Btn_Color", "Btn_Boom", "Btn_Sort", "Btn_NumSort", "Btn_Tird", "Btn_Reset",
            "Btn_AddMoney", "Btn_Chat"
        }
        local scaleVal = 1.1
        for _, btnName in pairs(btnNamesToScale) do
            local btnNode = self._gameNode:getChildByName(btnName)
            if btnNode then btnNode:setScale(scaleVal) end
            local imgThsBk = self._gameNode:getChildByName("Panel_ArenaBar"):getChildByName("tonghuashun")
            imgThsBk:setScaleY(scaleVal)

            if self._arenaInfo and self._arenaInfo._arenaInfoBar then
                local panelAni = self._arenaInfo._arenaInfoBar:getChildByName("Panel_Ani")
                btnNode = panelAni:getChildByName(btnName)
                if btnNode then btnNode:setScale(scaleVal) end

                imgThsBk = panelAni:getChildByName("Panel_BG"):getChildByName("tonghuashun")
                imgThsBk:setScaleY(scaleVal)
            end
        end

        --按钮放大之后右移一定距离以腾出一些空隙
        local btnNamesToMoveOffsetXColumn1 = {
            "Btn_Color", "Btn_Boom", "Btn_NumSort", "Btn_Sort"
        }
        local offsetX = 7
        for _, btnName in pairs(btnNamesToMoveOffsetXColumn1) do
            local btnNode = self._gameNode:getChildByName(btnName)
            if btnNode then btnNode:setPositionX(btnNode:getPositionX() + offsetX) end

            if self._arenaInfo and self._arenaInfo._arenaInfoBar then
                local panelAni = self._arenaInfo._arenaInfoBar:getChildByName("Panel_Ani")
                btnNode = panelAni:getChildByName(btnName)
                if btnNode then btnNode:setPositionX(btnNode:getPositionX() + offsetX) end
            end
        end

        local btnThird = self._gameNode:getChildByName("Btn_Tird")
        btnThird:setPositionX(btnThird:getPositionX() + 2 * offsetX)
        local btnReset = self._gameNode:getChildByName("Btn_Reset")
        btnReset:setPositionX(btnReset:getPositionX() + 2 * offsetX)
        local btnChat = self._gameNode:getChildByName("Btn_Chat")
        btnChat:setPositionX(btnChat:getPositionX() + 3 * offsetX)
        if self._arenaInfo and self._arenaInfo._arenaInfoBar then
            local panelAni = self._arenaInfo._arenaInfoBar:getChildByName("Panel_Ani")
            local btnThird = panelAni:getChildByName("Btn_Tird")
            btnThird:setPositionX(btnThird:getPositionX() + 2 * offsetX)
            local btnReset = panelAni:getChildByName("Btn_Reset")
            btnReset:setPositionX(btnReset:getPositionX() + 2 * offsetX)
            local btnChat = panelAni:getChildByName("Btn_Chat")
            btnChat:setPositionX(btnChat:getPositionX() + 3 * offsetX)
        end
    end
end

function MyGameScene:onClickWinningStreakBtn()
    my.playClickBtnSound()
    my.informPluginByName({pluginName='WinningStreakCtrl'})
end

function MyGameScene:refreshWinningStreakBtn()
    if not self._btnWinningStreak then return end

    local nodeWinningStreak = self._gameNode:getChildByName("Node_WinningStreak")
    nodeWinningStreak:setVisible(false)
    nodeWinningStreak:stopAllActions()
    nodeWinningStreak:removeAllChildren()

    if PUBLIC_INTERFACE.IsStartAsArenaPlayer() or PUBLIC_INTERFACE.IsStartAsFriendRoom() or PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() or PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        -- 竞技场，好友房，主播房 不用显示
        self._btnWinningStreak:setVisible(false)
        return
    end

    if not self._gameController:isNeedDeposit() or PUBLIC_INTERFACE.IsStartAsTimingGame() then
        --积分场不显示
        self._btnWinningStreak:setVisible(false)
        return
    end

    if not WinningStreakModel:isAlive() then
        self._btnWinningStreak:setVisible(false)
        return
    end
    
    self._btnWinningStreak:setVisible(true)

    nodeWinningStreak:setVisible(true)
    local  node = cc.CSLoader:createNode("res/hallcocosstudio/activitycenter/Ani_WinningStreak.csb")
    if node then
        nodeWinningStreak:addChild(node)
        local action = cc.CSLoader:createTimeline("res/hallcocosstudio/activitycenter/Ani_WinningStreak.csb")
        if action then
            node:runAction(action)
            action:play("animation0",true)
        end
    end

    local fntWinningStrek = self._btnWinningStreak:getChildByName("Fnt_WinningStreak")
    local imgDot          = self._btnWinningStreak:getChildByName("Img_Dot")
    imgDot:setVisible(false)

    local winningStreakInfo = WinningStreakModel:GetWinningStreakInfo()
    if winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNSTARTED then   --未挑战读缓存,也有可能已经挑战完一次了。。。
        fntWinningStrek:setString("连胜挑战")
    elseif winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_STARTING then
        if winningStreakInfo.nBout < 0 then
            fntWinningStrek:setString("已开启")
        else
            fntWinningStrek:setString(winningStreakInfo.nBout.."连胜")
        end
    elseif winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNTAKE then
        imgDot:setVisible(true)
        fntWinningStrek:setString("已结束")
    end

    self:refreshTopRightBtns()
end

function MyGameScene:refreshAwardRetDeposit()
    if self._gameController then   
        self._gameController:refreshAwardRetDeposit()
    end
end

function MyGameScene:freshNobilityPrivilege()
    --显示贵族特权头像框
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end
    local playerManager = self:getPlayerManager()
    if playerManager and playerManager.freshMyNobilityPrivilege then
        playerManager:freshMyNobilityPrivilege(nobilityPrivilegeInfo.level)
    end
    self:setTools()
    if self._gameController:isGameRunning() then self._tools:onGameStart() end
end

function MyGameScene:playShangShengAni()
    if not self._gameNode then return end

    local size = cc.Director:getInstance():getVisibleSize()
    local ani = sp.SkeletonAnimation:create("res/Game/Skeleton/shangsheng/shangsheng.json", "res/Game/Skeleton/shangsheng/shangsheng.atlas")
    ani:setAnimation(0, "shangsheng", false)  
    ani:setDebugBonesEnabled(false)
    ani:setAnchorPoint(0.5, 0.5)
    ani:setPosition(cc.p(size.width/2, size.height/2))
    ani:setVisible(true)
    self._gameNode:addChild(ani)
end

function MyGameScene:playXiaJiangAni()
    if not self._gameNode then return end

    local size = cc.Director:getInstance():getVisibleSize()
    local ani = sp.SkeletonAnimation:create("res/Game/Skeleton/xiajiang/xiajiang.json", "res/Game/Skeleton/xiajiang/xiajiang.atlas")
    ani:setAnimation(0, "xiajiang", false)  
    ani:setDebugBonesEnabled(false)
    ani:setAnchorPoint(0.5, 0.5)
    ani:setPosition(cc.p(size.width/2, size.height/2))
    ani:setVisible(true)
    self._gameNode:addChild(ani)
end

function MyGameScene:ShowExpressionGuide()    
    if not self._ExpressionOpened then
        self:ExpansionExpression()
    end
end

function MyGameScene:ExpansionExpression()
    if self._MyNodeExpression then
        local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_Expression.csb")
        action:play("Ani_Start", false) 
        self._MyNodeExpression:runAction(action)
        self._ExpressionOpened = true
    end
end

function MyGameScene:ShrinkExpression()
    if self._MyNodeExpression then
        local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_Expression.csb")
        action:play("Ani_End", false)
        self._MyNodeExpression:runAction(action)
        self._ExpressionOpened = false
    end
end

function MyGameScene:ClickBtnExpression()
    if self._ExpressionOpened then
        self:ShrinkExpression()
    else
        self:ExpansionExpression()
    end
end

function MyGameScene:UseExpression(BtnIndex)
    self._gameController:ExpressionThrow(BtnIndex)   
    self:ClickBtnExpression()
end

function MyGameScene:PlayExpressionAni(BtnIndex)
    local skJsonFilePath = "res/hallcocosstudio/images/skeleton/biaoqing/biaoqing_"..BtnIndex..".json"
    local skAtlasFilePath = "res/hallcocosstudio/images/skeleton/biaoqing/biaoqing_"..BtnIndex..".atlas"
    if not cc.FileUtils:getInstance():isFileExist(skJsonFilePath) then return end

    self._gameNode:getChildByName("Node_ExpressionAni"):removeAllChildren()
    self._gameNode:getChildByName("Node_ExpressionAni"):setVisible(true)
    local ExpressionSkeletonAni = sp.SkeletonAnimation:create(skJsonFilePath, skAtlasFilePath, 1)
    ExpressionSkeletonAni:setAnimation(0, "animation", false)
    self._gameNode:getChildByName("Node_ExpressionAni"):addChild(ExpressionSkeletonAni)
    ExpressionSkeletonAni:registerSpineEventHandler(function (event)
        -- 播放礼包关闭特效
        self._gameNode:getChildByName("Node_ExpressionAni"):setVisible(false)
    end, sp.EventType.ANIMATION_COMPLETE)
end

function MyGameScene:PlayExpressionSound(BtnIndex)
    self._gameController:playGamePublicSound("Snd_Expression"..BtnIndex..".mp3")
end

function MyGameScene:UpdateExpressionBtnStatus()
    if self._MyNodeExpression then
        local btnExpression = self._MyNodeExpression:getChildByName("Image_bg"):getChildByName("Btn_Expression") 
        if not WeekCardModel:isWeekCardShow() then  
            self._MyNodeExpression:setVisible(false)
        end
        if WeekCardModel:canUseSpecialEmoji() then
            btnExpression:setBright(true)
        else
            btnExpression:setBright(false)
        end
    end
end

function MyGameScene:freshTimingGameScore()
    local infoData = TimingGameModel:getInfoData()
    if infoData then
        self._gameController:setPlayerTimingScore(self._gameController:getMyDrawIndex(), infoData.seasonScore)
        self._gameController._baseGameConnect:TablePlayerForUpdateTimingGameScore(infoData.seasonScore)
    end
end 

function MyGameScene:freshRobotTimingGameScore(data)
    if not data or not data.value then return end
    local pdata = data.value

    local config = TimingGameModel:getConfig()
    if config then
        local score = pdata.currentscore
        if type(score) == "number" 
        and score < config.MinScore then
            pdata.currentscore = config.MinScore
        end
    end
    
    local playerManager = self:getMyPlayerManager()
    if playerManager then
        for i = 1, self._gameController:getTableChairCount() do
            local player = playerManager:getGamePlayerByIndex(i)
            if player and player._playerUserID == pdata.userid 
            and i ~= self._gameController:getMyDrawIndex() then
                self._gameController:setPlayerTimingScore(i, pdata.currentscore)
            end
        end
    end
end  

function MyGameScene:restartGameByTimingGame()
    if self._gameController:canRestart() then
        self._gameController:onRestart()
    end
end 

function MyGameScene:refreshTimingGameTicketTaskBtn()
    local btn = self._timingGameTicketTaskBtn
    local infoData = TimingGameModel:getInfoData()
    local config = TimingGameModel:getConfig()

    if not config or not infoData then return end

    local totalBouts = 0
    local curBouts = 0
    for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
        totalBouts = totalBouts + config.GradeBoutObtainTickets[i].MinBoutNum
        curBouts = curBouts + infoData.gradeBoutNums[i]
    end
    if curBouts > totalBouts then curBouts = totalBouts end
    if btn and btn:isVisible() then
        local txtBout = btn:getChildByName("Text_TimingGameBoutNum")
        if txtBout then
            txtBout:setString(string.format("%d/%d", curBouts, totalBouts))
        end
    end
end

function MyGameScene:getTopRightNodeList( )
    local nodeList = {
        {"Btn_Mission"},
        {"Btn_LimitTimeGift"},
        {"Btn_Goldegg"},
        {"Btn_TimingGameTicketTask"},
        {"Node_WinningStreak", "Btn_WinningStreak"},
        {"Btn_SelectTable"},
    }
    return nodeList
end

--刷新游戏界面右上角按钮位置
function MyGameScene:refreshTopRightBtns()
    if not self._gameNode then return end

    local nodeList = self:getTopRightNodeList()
    local maxWidth, startPosX = 0, -1
    for i, nodeNametbl in ipairs(nodeList) do
        for i, nodeName in ipairs(nodeNametbl) do
            local node = self._gameNode:getChildByName(nodeName)
            local size = node:getContentSize()
            if node:isVisible() and size.width > maxWidth then
                maxWidth = size.width
            end
            if startPosX == -1 then
                startPosX = node:getPositionX()
            end
        end
    end
    maxWidth = math.max(maxWidth, 110)

    if startPosX == -1 then return end
    local index = 0
    for i, nodeNametbl in ipairs(nodeList) do
        local posX = startPosX - index * maxWidth
        local bMove = false
        for i, nodeName in ipairs(nodeNametbl) do
            local node = self._gameNode:getChildByName(nodeName)
            if node:isVisible() then
                node:setPositionX(posX)
                bMove = true
            end
        end
        if bMove then
            index = index + 1 
        end
    end
end

function MyGameScene:setAnchorMatchGameResult(gameWin)
    if not self._gameNode or self._arenaGameResult then return end
    local MyAnchorMatchGameResult = import('src/app/Game/mMyGame/MyAnchorMatchGameResult.lua')
    self._anchorMatchGameResult = MyAnchorMatchGameResult:create(self._gameNode, self._gameController, gameWin)
end

function MyGameScene:setRuleInfoNode()
    if not self._gameNode or self._nodeRuleInfo then
        return
    end
    self._nodeRuleInfo = self._gameNode:getChildByName('Node_RuleInfo')
    if self._nodeRuleInfo then
        self._textRuleInfo = self._nodeRuleInfo:getChildByName('Text_RuleInfo')
    end
end

function MyGameScene:setRuleString(ruleString)
    self._textRuleInfo:setString(ruleString)
    self._nodeRuleInfo:setVisible(true)
end

function MyGameScene:onUpdatePlayerData()
    if self._gameController then
        self._gameController:onUpdatePlayerData()
    end
end

function MyGameScene:getNodeRedbag()
    if not self._gameNode then return nil end

    return self._gameNode:getChildByName("Node_Redbag")
end

function MyGameScene:getNodeRedPacket()
    if not self._gameNode then return nil end
    return self._gameNode:getChildByName("Node_RedPacket")
end

--新用户话费活动icon创建
function MyGameScene:createNewUserRedbag()
    if not self._gameNode then return  end
    local NewUserInviteGiftModel = require('src.app.plugins.invitegift.newusergift.NewUserInviteGiftModel'):getInstance()
    local isShow = NewUserInviteGiftModel:isShowInGameScene()
    if not self._newUserRedbag and isShow then
        local NewUserRedbagLoadCtrl   = import('src.app.plugins.invitegift.newusergift.NewUserRedbagLoadCtrl')
        local redbagNode = self:getNodeRedbag()
        local redbag = NewUserRedbagLoadCtrl:create({isGame=true})
        local node = redbag._viewNode:getRealNode()
        redbagNode:addChild( node )
        redbagNode:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        self._newUserRedbag = redbag
    end
end

--开始游戏播放红包动画（新人话费活动）
function MyGameScene:startEnterRedBagAct()
    if self._newUserRedbag then
        local function reqCallback(requestId)
            self._gameController:reqUpdateReward(requestId)
        end
        self._newUserRedbag:enterGameAction()
        self._newUserRedbag:setCallback(reqCallback)
    end
end

function MyGameScene:removeListen()
    if self._newUserRedbag then        
        self._newUserRedbag:removeListen()
        self._newUserRedbag = nil
    end
end

function MyGameScene:setInviteGiftIcon()
    -- 判断是否显示
    if OldUserInviteGiftModel:getInviteClickTakeRewardStatus()~= 1 or not OldUserInviteGiftModel:isOpenShare() then
        if self._redPacket then
            self._redPacket:hide()
        end
        return
    end
    local redPacketNode = self:getNodeRedPacket()
    if not self._redPacket and redPacketNode then
        local redPacket = cc.CSLoader:createNode("res/hallcocosstudio/invitegiftactive/olduser/yqyl_game_icon.csb")
        redPacketNode:addChild(redPacket)
        self._redPacket = redPacket
        local btn = redPacket:getChildByName('Panel_1'):getChildByName('Button_open')
        local actScale1 = cc.ScaleTo:create(0.5, 1.1)
        local actScale2 = cc.ScaleTo:create(0.5, 1)
        local sequence = cc.Sequence:create(actScale1, actScale2)
        local animation = cc.RepeatForever:create(sequence)
        redPacketNode:runAction(animation)
        btn:addClickEventListener(function()
            --防止连续点击
            if self._isClickRedBtn then
                return 
            end
            OldUserInviteGiftModel:requireGetShareAward( 2 )
            self._isClickRedBtn = true
            my.scheduleOnce(function()
                self._isClickRedBtn = false
            end, 2) 
        end)
    end

    if not self._redPacket then
        return 
    end

    if OldUserInviteGiftModel:getInviteClickTakeRewardStatus()~= 1 then
        self._redPacket:hide()
    else
        self._redPacket:show()
    end
end

return MyGameScene
