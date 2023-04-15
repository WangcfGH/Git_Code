
local MyGamePromptExitTipExchange = class("MyGamePromptExitTipExchange", ccui.Layout)

function MyGamePromptExitTipExchange:ctor(gameController, nContinueBout, nRewardVochers, HallOrGame)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController
    self._HallOrGame            = HallOrGame        --大厅还是游戏中，true 是大厅
    self._PromptPanel           = nil
    self.nContinueBout          = nContinueBout         -- 再打 x 局
    self.nRewardVochers         = nRewardVochers        -- 奖励 数量

    if self.onCreate then self:onCreate() end
end

function MyGamePromptExitTipExchange:onCreate()
    self:init()
end

function MyGamePromptExitTipExchange:init()
    local csbPath = "res/GameCocosStudio/csb/Node_Prompt_Exchange_Quit.csb"
    
    self._PromptPanel = cc.CSLoader:createNode(csbPath)
    if self._PromptPanel then
        self:addChild(self._PromptPanel)
        SubViewHelper:adaptNodePluginToScreen(self._PromptPanel, self._PromptPanel:getChildByName("Panel"))
        my.presetAllButton(self._PromptPanel)

        local panelPrompt = self._PromptPanel:getChildByName("Panel_Prompt_Quit")
        if panelPrompt then
            self:_playPopupAni(panelPrompt)
            local suerBtn = panelPrompt:getChildByName("Btn_Reopen")
            local function onSuer()
                self:onSuer()
            end
            suerBtn:addClickEventListener(onSuer)

            local function onClose()
                self:onClose()
            end
            local closeBtn = panelPrompt:getChildByName("Btn_Continue")
            closeBtn:addClickEventListener(onClose)
            closeBtn = panelPrompt:getChildByName("Btn_Close")
            closeBtn:addClickEventListener(onClose)
           
            local content = string.format(self._gameController:getGameStringByKey("G_GAME_PROMPT_CONTINUE_EXCHANGE_ROOM"), self.nContinueBout, self.nRewardVochers)
            local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
            local word = panelPrompt:getChildByName("Text_PromptWord")
            word:setString(utf8Content)
        end
    end
end

function MyGamePromptExitTipExchange:_playPopupAni(panelAnimation)
    -- local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_Prompt_Exchange_Quit.csb")
    -- panelAnimation:runAction(action)
    -- action:play('animation_Quit', false)
    if not tolua.isnull(panelAnimation) then
        panelAnimation:setVisible(true)
        panelAnimation:setScale(0.6)
        panelAnimation:setOpacity(255)
        local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
        local scaleTo2 = cc.ScaleTo:create(0.09, 1)

        local ani = cc.Sequence:create(scaleTo1, scaleTo2)
        panelAnimation:runAction(ani)
    end
end

function MyGamePromptExitTipExchange:onClose()
    if self._HallOrGame then
        self._gameController:playEffectOnPress()
    else
        self._gameController:playBtnPressedEffect()
    end
    self._gameController.isExitRoomPlaneSure = false
    self._gameController:stopExchangeQuitTimer()
    self._gameController._ExchangeQuitPrompt = nil
    self:removeFromParentAndCleanup()

end

function MyGamePromptExitTipExchange:onSuer()
    if self._HallOrGame then
        self._gameController:playEffectOnPress()
    else
        self._gameController:playBtnPressedEffect()
        self._gameController.super.onQuit(self._gameController)
    end
    self._gameController.isExitRoomPlaneSure = false
    self._gameController:stopExchangeQuitTimer()
    self._gameController._ExchangeQuitPrompt = nil
    self:removeFromParentAndCleanup()
end

return MyGamePromptExitTipExchange
