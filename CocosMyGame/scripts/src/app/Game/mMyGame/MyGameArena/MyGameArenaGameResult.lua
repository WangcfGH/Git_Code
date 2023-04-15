local MyGameArenaGameResult     = class("MyGameArenaGameResult")
local NumberScroller            = import("src.app.Game.mCommon.NumberScroller")
local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")
local BankruptcyModel           = import('src.app.plugins.Bankruptcy.BankruptcyModel'):getInstance()
local BankruptcyDef             = require('src.app.plugins.Bankruptcy.BankruptcyDef')
local user                      = mymodel('UserModel'):getInstance()

MyGameArenaGameResult.RESOURCE_PATH            = 'res/GameCocosStudio/csb/Layer_Arenaresult.csb'


function MyGameArenaGameResult:ctor(baseNode, gameController, data)
    self._gameController = gameController

    self._data = data
    self._ScollEndedCount = 0
    self._resultAniOver = false

    self._selfChairNO   = (gameController._selfChairNO or gameController:getMyChairNO()) + 1

    self._winChairNo = 0
    for i = 1, 4 do
        if data.nPlace[i] == 1 then
            self._winChairNo = i
            break
        end
    end      

    self:_init(baseNode)
end

function MyGameArenaGameResult:showBankruptcy()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local playerInfo = playerInfoManager:getPlayerInfo(self._gameController:getMyDrawIndex())
    local userDeposit = playerInfo.nDeposit

    local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    local nDeposit = roomInfo.nMinDeposit

    local nSafeBoxDeposit = user.nSafeboxDeposit or 0

    local isEnough = true
    if userDeposit then
        if userDeposit + nSafeBoxDeposit < nDeposit then
            isEnough = false
        end
    end

    local relief = mymodel('hallext.ReliefActivity'):getInstance()
    
    if not self:isWin() and not isEnough then  --触发限时礼包
        local bShow = BankruptcyModel:isBankruptcyBagShow()
        if not bShow then
            print("req BankruptcyModel:reqApplyBag in arena game")
            BankruptcyModel:reqApplyBag(roomInfo.nRoomID)
            -- BankruptcyModel:reqApplyBag(11463)
        else
            if not self._gameController or not self._gameController._baseGameScene then return end
            self._gameController._baseGameScene:showBankruptcyGiftResult(function ()
                local limit = ((relief.config or {}).Limit or {}).LowerLimit or 0
                if relief.state == 'SATISFIED' 
                and nDeposit < limit then
                    my.informPluginByName({pluginName='ReliefCtrl',params={
                        fromSence = ReliefDef.FROM_SCENE_GAMESCENE, 
                        promptParentNode = self._gameController._baseGameScene, 
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

function MyGameArenaGameResult:_init(baseNode)
    if baseNode == nil or self._data == nil then return end
    local data = self._data

    local arenaGameResultLayer = cc.CSLoader:createNode(MyGameArenaGameResult.RESOURCE_PATH)
    self._arenaGameResultLayer = arenaGameResultLayer
    local arenaGameResultPanel = arenaGameResultLayer:getChildByName("Panel_ArenaResult")
    self._arenaGameResultPanel = arenaGameResultPanel
    arenaGameResultLayer:setLocalZOrder(SKGameDef.SK_ZORDER_RESULT)
    baseNode:addChild(arenaGameResultLayer)
    arenaGameResultLayer:setContentSize(display.size)
    ccui.Helper:doLayout(arenaGameResultLayer)

    self:showBankruptcy()

    local useFnt = {}
    for i = 1, self._gameController:getTableChairCount() do
        local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(i - 1)
        local silverAdd = arenaGameResultPanel:getChildByName("Fnt_ResultSilverAdd"..drawIndex)
        local silverCut = arenaGameResultPanel:getChildByName("Fnt_ResultSilverReduce"..drawIndex)
        silverAdd:setVisible(false)
        silverCut:setVisible(false)
        if data.nDepositDiffs[i] + data.nWinFees[i] < 0 then
            silverCut:setVisible(true)
            silverCut:setString("0")
            table.insert(useFnt, silverCut)
        else
            silverAdd:setVisible(true)
            silverAdd:setString("0")
            table.insert(useFnt, silverAdd)
        end
    end
    local playerDepositScroller = {}
    for i = 1, #useFnt do
        playerDepositScroller[i] = NumberScroller:create(useFnt[i])
        playerDepositScroller[i]:setScrollEndCallback(self, self.onPlayerDepositScrollEnded)
        playerDepositScroller[i]:setScrollIngCallback(self, self.onPlayerDepositScrolling)
        playerDepositScroller[i]:setValueWithAnim(data.nDepositDiffs[i]+data.nWinFees[i])

    end
    self._playerDepositScroller = playerDepositScroller
    
    local csbPath = "res/GameCocosStudio/csb/Node_Arena_Lose.csb"
    if self:isWin() then
        csbPath = "res/GameCocosStudio/csb/Node_Arena_Win.csb"
    end
    local resultAniPanel = cc.CSLoader:createNode(csbPath)

    local panelSize = arenaGameResultPanel:getContentSize()
    resultAniPanel:setPosition(cc.p(panelSize.width / 2, panelSize.height / 2 ))
    arenaGameResultPanel:addChild(resultAniPanel)
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        resultAniPanel:runAction(action)
        action:play("animation_arena_result", false)
        local function onFrameEvent(frame)
            if frame then 
                local event = frame:getEvent()
                if "Play_Over" == event then
                    self._resultAniOver = true
                    self:onExit()
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
    end
end

function MyGameArenaGameResult:isWin()
    if self._data then
        local MyGameUtilsInfoManager    = self._gameController._baseGameUtilsInfoManager  
        if self._winChairNo == self._selfChairNO or self._winChairNo == MyGameUtilsInfoManager:RUL_GetNextChairNO(MyGameUtilsInfoManager:RUL_GetNextChairNO(self._selfChairNO-1))+1 then
            return true
        else
            return false
        end
    end

    return false
end

function MyGameArenaGameResult:onPlayerDepositScrollEnded()
    self._ScollEndedCount = self._ScollEndedCount + 1

    if self._ScollEndedCount >= self._gameController:getTableChairCount() then  --结算结束
        self:onExit()
    end
end

function MyGameArenaGameResult:onPlayerDepositScrolling(lable, num)
    if num and num > 0 then
        lable:setString("+"..num)
    end
end

function MyGameArenaGameResult:onExit()
    if self._ScollEndedCount < self._gameController:getTableChairCount() or not self._resultAniOver then
        return
    end
    my.scheduleOnce(function()
        if self._gameController and self._gameController:isInGameScene() == false then
            return
        end

        for i = 1, #self._playerDepositScroller do
            self._playerDepositScroller[i]:onExit()
        end
        --移除自己，释放资源
        if self._arenaGameResultLayer ~= nil then
            self._arenaGameResultLayer:removeSelf()
            self._arenaGameResultLayer = nil
        end
        if self._gameController._baseGameScene and self._gameController._baseGameScene._arenaGameResult then
            self._gameController._baseGameScene._arenaGameResult = nil
        end
    end, 2)
end

function MyGameArenaGameResult:onKeyboardReleased()
    if self._arenaGameResultLayer ~= nil then
        self._arenaGameResultLayer:removeSelf()
        self._arenaGameResultLayer = nil
    end
end 

return MyGameArenaGameResult