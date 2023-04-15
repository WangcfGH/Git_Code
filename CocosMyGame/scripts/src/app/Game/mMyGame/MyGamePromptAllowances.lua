
local MyGamePromptAllowances = class("MyGamePromptAllowances", ccui.Layout)

function MyGamePromptAllowances:ctor(gameController, timesLeft, HallOrGame, limit)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController
    self._HallOrGame        = HallOrGame        --大厅还是游戏中，true 是大厅
    self._PromptPanel           = nil
    self._timesLeft             = timesLeft

    self.lowerLimit           = 300
    self.upperLimit           = 1000
    if limit then
        self.lowerLimit           =  limit.LowerLimit or 300
        self.upperLimit           =  limit.UpperLimit or 1000
    end
   

    if self.onCreate then self:onCreate() end
end

function MyGamePromptAllowances:onCreate()
    self:init()
end

function MyGamePromptAllowances:init()
    local csbPath = "res/GameCocosStudio/csb/Node_Prompt_Allowances.csb"
    
    self._PromptPanel = cc.CSLoader:createNode(csbPath)
    if self._PromptPanel then
        self:addChild(self._PromptPanel)
        SubViewHelper:adaptNodePluginToScreen(self._PromptPanel, self._PromptPanel:getChildByName("Panel"))
        my.presetAllButton(self._PromptPanel)

        local panelPrompt = self._PromptPanel:getChildByName("Panel_Prompt_Quit")
        if panelPrompt then
            if not tolua.isnull(panelPrompt) then
				panelPrompt:setVisible(true)
				panelPrompt:setScale(0.6)
				panelPrompt:setOpacity(255)
				local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
				local scaleTo2 = cc.ScaleTo:create(0.09, 1)

				local ani = cc.Sequence:create(scaleTo1, scaleTo2)
				panelPrompt:runAction(ani)
            end
            
            local suerBtn = panelPrompt:getChildByName("Btn_Suer")
            local function onSuer()
                self:onSuer()
            end
            suerBtn:addClickEventListener(onSuer)

            local closeBtn = panelPrompt:getChildByName("Btn_Close")
            closeBtn:addClickEventListener(onSuer) --点关闭不再自动领取低保,只在点确定的时候领低保

            local word = panelPrompt:getChildByName("Text_PromptWord")
            local word2 = panelPrompt:getChildByName("Text_PromptWord_0")

            local user=mymodel('UserModel'):getInstance()
            local reliefAllNum = 3   --总次数写死
            local dailyLimitNum = 0
            if cc.exports.gameReliefData then
                dailyLimitNum = cc.exports.gameReliefData.config.Limit.DailyLimitNum or reliefAllNum
            end

            --word:setString(string.format(GamePublicInterface:getGameStringToUTF8ByKey("G_GAME_PROMPT_ALLOWANCES_TIP"), self.lowerLimit, dailyLimitNum-self._timesLeft + 1, dailyLimitNum,self.upperLimit))
            word:setString(string.format(GamePublicInterface:getGameStringToUTF8ByKey("G_GAME_PROMPT_ALLOWANCES_TIP"), dailyLimitNum-self._timesLeft + 1, dailyLimitNum,self.upperLimit))
            
            --达到贵族特权的阶段
            local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
            local status,reliefCount,level,levelCount,bVisible = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
            if status then
                dailyLimitNum = reliefCount
                local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief"..user.nUserID..os.date('%Y%m%d',os.time())))
                if not reliefUsedCount then reliefUsedCount = 0 end
                word:setString(string.format(GamePublicInterface:getGameStringToUTF8ByKey("G_GAME_PROMPT_ALLOWANCES_TIP"), reliefUsedCount+1, dailyLimitNum,self.upperLimit))
            end
            word2:setString("贵族"..level.."每天可享有"..levelCount.."次机会")
            word2:setVisible(bVisible)
        end
    end

    -- local action = cc.CSLoader:createTimeline(csbPath)
    -- if action then
    --     self._PromptPanel:runAction(action)
    --     action:gotoFrameAndPlay(1,10 , false)
    -- end

    --17期客户端埋点
    if self._HallOrGame then
        my.dataLink(cc.exports.DataLinkCodeDef.HALL_RELIEF_VIEW)
    else
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_RELIEF_VIEW)
    end
end

function MyGamePromptAllowances:onSuer()
    if self._HallOrGame then
        self._gameController:playEffectOnPress()
    else
        self._gameController:playBtnPressedEffect()
    end


    --17期客户端埋点
    if self._HallOrGame then
        my.dataLink(cc.exports.DataLinkCodeDef.HALL_RELIEF_VIEW_SURE_BTN)
    else
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_RELIEF_VIEW_SURE_BTN)
    end

    self:removeFromParentAndCleanup()
end

return MyGamePromptAllowances
