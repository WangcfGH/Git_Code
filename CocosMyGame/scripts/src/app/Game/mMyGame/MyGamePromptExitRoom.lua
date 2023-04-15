
local MyGamePromptExitRoom = class("MyGamePromptExitRoom", ccui.Layout)

function MyGamePromptExitRoom:ctor(gameController, punishmentMoney, HallOrGame)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController
    self._HallOrGame        = HallOrGame        --大厅还是游戏中，true 是大厅
    self._PromptPanel           = nil
    self._punishmentMoney            = punishmentMoney

    if self.onCreate then self:onCreate() end
end

function MyGamePromptExitRoom:onCreate()
    self:init()
end

function MyGamePromptExitRoom:init()
    local csbPath = "res/GameCocosStudio/csb/Node_Prompt_Quit.csb"
    
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

            local word = panelPrompt:getChildByName("Text_PromptWord_2")
            local wordString = word:getString()
            word:setString(string.format(wordString, self._punishmentMoney))
        end
    end

    --[[local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        self._PromptPanel:runAction(action)
        action:gotoFrameAndPlay(1,10 , false)
    end--]]
end

function MyGamePromptExitRoom:_playPopupAni(panelAnimation)
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

function MyGamePromptExitRoom:onClose()
    if self._HallOrGame then
        self._gameController:playEffectOnPress()
    else
        self._gameController:playBtnPressedEffect()
    end
    self._gameController.isExitRoomPlaneSure = false
    self:removeFromParentAndCleanup()
end

function MyGamePromptExitRoom:onSuer()
    if self._HallOrGame then
        self._gameController:playEffectOnPress()
    else
        self._gameController:playBtnPressedEffect()
        self._gameController.super.onQuit(self._gameController)
    end
    self._gameController.isExitRoomPlaneSure = false
    self:removeFromParentAndCleanup()
end

return MyGamePromptExitRoom
