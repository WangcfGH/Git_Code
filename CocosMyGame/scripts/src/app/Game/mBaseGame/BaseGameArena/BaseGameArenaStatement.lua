local BaseGameArenaStatement = class("BaseGameArenaStatement", cc.Layer)

BaseGameArenaStatement.RESOURCE_PATH            = 'res/GameCocosStudio/csb/result_arenascore.csb'
BaseGameArenaStatement.LEVEL_RESOURCE_PATH      = 'res/GameCocosStudio/csb/result_levelunit.csb'
BaseGameArenaStatement.HP_RESOURCE_PATH         = 'res/GameCocosStudio/csb/playerhp_unit.csb'
BaseGameArenaStatement.ADDITION_RESOURCE_PATH   = 'res/GameCocosStudio/csb/result_extraunit.csb'
BaseGameArenaStatement.LEVELUP_RESOURCE_PATH    = 'res/GameCocosStudio/csb/tips_levelup.csb'
BaseGameArenaStatement.LEVELMAX_RESOURCE_PATH   = 'res/GameCocosStudio/csb/tips_levelmax.csb'
--BaseGameArenaStatement.REWARDTIP_RESOURCE_PATH  = "res/GameCocosStudio/csb/itemsreward_bg.csb"
BaseGameArenaStatement.REWARDITEM_RESOURCE_PATH = "res/GameCocosStudio/csb/itemsunit.csb"

BaseGameArenaStatement.LEVELICON_TEXTURE_PATH   = 'res/hall/hallpic/arena/arenalevel/Arena_IconLevel%d.png'
BaseGameArenaStatement.LEVELICON_S_TEXTURE_PATH = 'res/hall/hallpic/arena/arenalevel/Arena_IconLevel_S%d.png'

BaseGameArenaStatement.TOP_EFFECT_PATH          = 'Arena/top.mp3'
BaseGameArenaStatement.DEAD_EFFECT_PATH         = 'Arena/dead.mp3'
BaseGameArenaStatement.AWARD_EFFECT_PATH        = 'Arena/award.mp3'
BaseGameArenaStatement.AWARDCLICK_EFFECT_PATH   = 'Arena/award_click.mp3'

function BaseGameArenaStatement:ctor(gameController, params)
    self._gameController = gameController
    self._awardAchieved  = {}
    self:_createViewNode()
    self:_registEvents()
    self:_setNodeInfo(params)
end

function BaseGameArenaStatement:onEnter()
    self._alive = true
    self:_runEnterAction()
end

function BaseGameArenaStatement:onExit()
    self._alive = false
end

function BaseGameArenaStatement:_createViewNode()
    local rootNode          = cc.CSLoader:createNode(self.RESOURCE_PATH)
    local panelMain         = rootNode:getChildByName("Panel_Main")
    local panelProgress     = rootNode:getChildByName("Panel_Progress") 
    local panel_playerHP    = ccui.Helper:seekWidgetByName(panelMain, "Panel_PlayerHP")
    local panel_nextExtra   = ccui.Helper:seekWidgetByName(panelMain, "Panel_NextExtra")
    local panel_extra       = ccui.Helper:seekWidgetByName(panelMain, "Panel_Extra")

    self._viewNode = {
        rootNode            = rootNode,
        panelMain           = panelMain,
        text_totalScore     = ccui.Helper:seekWidgetByName(panelMain, "Text_TotalScore"),
        text_currentScore   = ccui.Helper:seekWidgetByName(panelMain, "Text_CurrentScore"),
        img_level           = ccui.Helper:seekWidgetByName(panelMain, "Img_Level"),
        img_textLevel       = ccui.Helper:seekWidgetByName(panelMain, "Img_TextLevel"),
        panel_extra    = panel_extra,
        text_extra          = panel_extra:getChildByName("Text_Extra"),
        panel_playerHP      = panel_playerHP,
        HPtitle             = panel_playerHP:getChildByName("Img_Title"),
        panel_nextExtra     = panel_nextExtra,
        additionTitle       = panel_nextExtra:getChildByName("Img_Title"), 
        btn_continue        = ccui.Helper:seekWidgetByName(panelMain, "Btn_Continue"), 
        btn_checkDetail     = ccui.Helper:seekWidgetByName(panelMain, "Btn_CheckDetail"), 
        btn_close           = ccui.Helper:seekWidgetByName(panelMain, "Btn_Close"),
        panel_progress      = panelProgress:getChildByName("Panel_Ani"),

        additionItems       = {},
        level               = {},
        HP                  = {},
        HPLost              = {}
    }

--    self._viewNode.panel_extra:addChild(self._viewNode.additionItem.rootNode)
--    self._viewNode.additionItem.rootNode:setPosition(cc.p(150, 50))

    rootNode:setContentSize(display.size)
    ccui.Helper:doLayout(rootNode)
    self:addChild(rootNode)


    local setVisible = rootNode.setVisible
    rootNode.setVisible = function(visible)
        selfVisible(rootNode, visible)
    end

    local progress_level= ccui.Helper:seekWidgetByName(panelProgress, "Progress_Level")
    self._levelProgress = require('src.app.Game.mBaseGame.BaseGameArena.BaseGameArenaProgress'):create(progress_level)
end

--function BaseGameArenaStatement:_createLevelNode()
--    local rootNode = cc.CSLoader:createNode(self.LEVEL_RESOURCE_PATH)
--    local panelMain = rootNode:getChildByName("Panel_Main")
--    local viewNode = {
--        rootNode  = rootNode,
--        panelMain = panelMain,
--        btn_rank1 = panelMain:getChildByName("Btn_Rank1"),
--        btn_rank2 = panelMain:getChildByName("Btn_Rank2"),
--    }
--    return viewNode
--end

function BaseGameArenaStatement:_createHPNode()
    local rootNode      = cc.CSLoader:createNode(self.HP_RESOURCE_PATH)
    local panelPlayerHP = rootNode:getChildByName("Panel_PlayerHP")
    local viewNode = {
        rootNode        = rootNode,
        panelPlayerHP   = panelPlayerHP,
        HPBG            = panelPlayerHP:getChildByName("Img_PlayerHPBG")
    }
    return viewNode
end

function BaseGameArenaStatement:_createAdditionNode()
    local rootNode  = cc.CSLoader:createNode(self.ADDITION_RESOURCE_PATH)
    local panelMain = rootNode:getChildByName("Panel_Main")
    local viewNode = {
        rootNode    = rootNode,
        panelMain   = panelMain,
        percent     = panelMain:getChildByName("Text_Extra"),
        name        = panelMain:getChildByName("Text_Name")
    }
    return viewNode
end

function BaseGameArenaStatement:_createRewardItem()
    local realNode   = cc.CSLoader:createNode(self.REWARDITEM_RESOURCE_PATH)
    local panelMain = realNode:getChildByName("Panel_Main")
    local viewNode = {
        realNode        = realNode,
        panelMain       = panelMain,
        img_itemsIcon   = panelMain:getChildByName("Img_ItemsIcon"),
        text_num        = panelMain:getChildByName("Text_Num")
    }
    return viewNode
end

function BaseGameArenaStatement:_registEvents()
    self:enableNodeEvents()

    local eventMap = {
        btn_close       = function()
            self:_runExitAction(function()
                self._gameController:showGameResult()
                self:removeSelf()
            end)
        end,
        btn_checkDetail = function()
            self:_runExitAction(function()
                self._gameController:showGameResult()
                self:removeSelf()
            end)
        end,
        btn_continue    = function()
            self:_runExitAction(function()
                self._gameController:onStartGame()
                self:removeSelf()
            end)
        end,
    }

    for widgetName, handler in pairs(eventMap) do 
        self._viewNode[widgetName]:addClickEventListener(function()
            self._gameController:playBtnPressedEffect()
            handler()
        end)
    end
end

function BaseGameArenaStatement:_runEnterAction()
    local timeline = cc.CSLoader:createTimeline(self.RESOURCE_PATH)
    self._viewNode.rootNode:runAction(timeline)
    timeline:gotoFrameAndPlay(1, 17, false)
end

function BaseGameArenaStatement:_runExitAction(callback) 
    local timeline = cc.CSLoader:createTimeline(self.RESOURCE_PATH)
    self._viewNode.rootNode:runAction(timeline)
    timeline:gotoFrameAndPlay(18, 29, false)
    if callback then 
        timeline:setFrameEventCallFunc(function(frame)
            if frame and frame:getEvent() == "Play_Over" then
                callback()
            end
        end)
    end
end

function BaseGameArenaStatement:_runLevelUpAction(awardInfo, callback, runningScene)

    local timeline      = cc.CSLoader:createTimeline(self.LEVELUP_RESOURCE_PATH)
    local levelUpNode   = cc.CSLoader:createNode(self.LEVELUP_RESOURCE_PATH)
    local parent = runningScene or self
    parent:addChild(levelUpNode)
    levelUpNode:runAction(timeline)
    levelUpNode:setPosition(display.center)
    timeline:gotoFrameAndPlay(1, 48, false)

    local panelMain  = levelUpNode:getChildByName("Panel_Main")
    local btn_reward = ccui.Helper:seekWidgetByName(panelMain, 'Btn_Reward')
    btn_reward:addClickEventListener(function()
        self._gameController:playEffect(self.AWARDCLICK_EFFECT_PATH)
        for _, awardType in pairs(awardInfo.awardType) do
        --奖励的类型 nType 1 银子，2比赛券，3兑换券， 6积分
            if awardType.nType == 1 then
                self._gameController:addPlayerDeposit(self._gameController:getMyDrawIndex(), awardType.nCount)
            end
        end
        levelUpNode:removeSelf()
        if type(callback) == "function" then callback() end
    end)

    local rewardContainer = ccui.Helper:seekWidgetByName(panelMain, 'Panel_ItemContainer')
    self:_showRewardOnPanel(rewardContainer, awardInfo)
end

function BaseGameArenaStatement:_runLevelMaxAction(awardInfo, onResume, onFinish)
    local timeline      = cc.CSLoader:createTimeline(self.LEVELMAX_RESOURCE_PATH)
    local levelMaxNode  = cc.CSLoader:createNode(self.LEVELMAX_RESOURCE_PATH)
    local parent = runningScene or self
    parent:addChild(levelMaxNode)
    levelMaxNode:runAction(timeline)
    levelMaxNode:setPosition(display.center)
    timeline:gotoFrameAndPlay(1, 89, false)

    local panelMain  = levelMaxNode:getChildByName("Panel_Main")
    local btn_reward    = ccui.Helper:seekWidgetByName(panelMain, 'Btn_Reward')
    local btn_exit      = ccui.Helper:seekWidgetByName(panelMain, 'Btn_Exit')
    local btn_continue  = ccui.Helper:seekWidgetByName(panelMain, 'Btn_Continue')
    local eventMap = {
        [btn_reward] = function()
            self._gameController:playEffect(self.AWARDCLICK_EFFECT_PATH)
            for _, awardType in pairs(awardInfo.awardType) do
            --奖励的类型 nType 1 银子，2比赛券，3兑换券， 6积分
                if awardType.nType == 1 then
                    self._gameController:addPlayerDeposit(self._gameController:getMyDrawIndex(), awardType.nCount)
                end
            end
            if self._params.isForceQuit then
                levelMaxNode:removeSelf()
            else
                timeline:gotoFrameAndPlay(90, 100, false)
            end
        end,
        [btn_exit] = function()
            self._gameController:playBtnPressedEffect()
            levelMaxNode:removeSelf()
            if type(onResume) == "function" then
                onFinish()
            end
        end,
        [btn_continue] = function()
            self._gameController:playBtnPressedEffect()
            levelMaxNode:removeSelf()
            if type(onFinish) == "function" then
                onResume()
            end
        end
    }
    for widget, handler in pairs(eventMap) do 
        widget:addClickEventListener(function()
            self._gameController:playBtnPressedEffect()
            handler()
        end)
    end

    local rewardContainer = ccui.Helper:seekWidgetByName(panelMain, 'Panel_ItemContainer')
    self:_showRewardOnPanel(rewardContainer, awardInfo)

end

function BaseGameArenaStatement:_showRewardOnPanel(panel, rewardList)
    local containerSize = panel:getContentSize()
    local itemSize 
    local gap
    local startX
    local startY = containerSize.height/2
    for i = 1, rewardList.nAwardNumber do 
        local awardItemInfo = rewardList.awardType[i]
        local rewardItem = self:_createRewardItem('large')

        if not itemSize then
            itemSize = rewardItem.panelMain:getContentSize()
            gap = (containerSize.width-itemSize.width*rewardList.nAwardNumber)/(rewardList.nAwardNumber+1)
            startX = gap+itemSize.width/2
        end

        --奖励的类型 nType 1 银子，2比赛券，3兑换券， 6积分
        local iconName = ''
        local rewardInfoString
        if awardItemInfo.nType == 1 then
            iconName = "RewardDeposit.png"
            rewardInfoString = self._gameController:getGameStringByKey("G_DEPOSIT")
        elseif awardItemInfo.nType == 2 then
            iconName = "RewardTicket1.png"
            rewardInfoString = self._gameController:getGameStringByKey("G_ARENA_TICKET")
        elseif awardItemInfo.nType == 3 then
            iconName = "RewardExchange.png"
            rewardInfoString = self._gameController:getGameStringByKey("G_ARENA_EXCHANGE")
        elseif awardItemInfo.nType == 6 then
            iconName = "RewardScore.png"
            rewardInfoString = self._gameController:getGameStringByKey("G_SCORE")
        end
        local texturePath = 'res/hall/hallpic/commonicon/'..iconName
        rewardItem.img_itemsIcon:loadTexture(texturePath)

        local utf8String = MCCharset:getInstance():gb2Utf8String(rewardInfoString, string.len(rewardInfoString))
        utf8String = string.format(utf8String, awardItemInfo.nCount)
        rewardItem.text_num:setString(utf8String)

        rewardItem.realNode:setPosition(cc.p(startX+(gap+itemSize.width)*(i-1), startY))

        rewardItem.realNode:addTo(panel)
    end
end

function BaseGameArenaStatement:_runHPAction(num)
    self:_setHPLose(num, true)
end 

function BaseGameArenaStatement:_setNodeInfo(params)
    self._params = params
    if params.totalScore then
        self:_setTotalScore(params.totalScore)
    end
    if params.roundScore then
        self:_setRoundScore(params.roundScore)
    end
    if params.lastAddition then
        self:_setLastAddition(params.lastAddition)
    end
    if params.nextAddition and params.additionDetail then
        self:_setNextAddition(params.nextAddition, params.additionDetail)
    end
    if params.initHP then
        self:_setInitHP(params.initHP)
    end
    if params.diffHP and params.leftHP then
        if params.diffHP < 0 then
            self:_setLeftHP(params.leftHP-params.diffHP)
            self:_loseHP(-params.diffHP)
        else
            self:_setLeftHP(params.leftHP)
        end
    end
    if params.awardCount and params.awardList then
        self:_findAwardAchieved(params.awardCount, params.awardList)
    end
    if params.awardCount and params.awardList then
        self:_showProgressLevel(params.awardCount, params.awardList)
    end
    if params.awardCount and params.awardList and self._curMatchScore then
        self:_setLevel(params.awardCount, params.awardList)
    end

end

function BaseGameArenaStatement:_setHPLose(num, runAction)
    if num == 0 then return end
    local lostNum = num or 1
    for count = #self._viewNode.HP-lostNum+1, #self._viewNode.HP do  
        local HPView = self._viewNode.HP[#self._viewNode.HP]
        self._viewNode.HP[#self._viewNode.HP] = nil
        table.insert(self._viewNode.HPLost, HPView)
        local HPNode = HPView.rootNode
        if runAction then
            local timeLine = cc.CSLoader:createTimeline(self.HP_RESOURCE_PATH)
            HPNode:runAction(timeLine) 
            timeLine:gotoFrameAndPlay(1, 27, false)
        else
            HPNode:setVisible(false)
        end
    end
    if #self._viewNode.HP <= 0 then
        self._gameController:playEffect(self.DEAD_EFFECT_PATH)
        self:_onArenaFinished()
    end
end

function BaseGameArenaStatement:_setTotalScore(totalScore)
    if self._viewNode.text_totalScore then
        local number = totalScore and type(totalScore) == 'number' and totalScore or 0
        self._curMatchScore = totalScore
        self._viewNode.text_totalScore:setString(tostring(number))
    end
end

function BaseGameArenaStatement:_setRoundScore(roundScore)
    if self._viewNode.text_currentScore then
        local number = roundScore and type(roundScore) == 'number' and roundScore or 0
        self._roundScore = roundScore
        self._viewNode.text_currentScore:setString(tostring(number))
    end
end

function BaseGameArenaStatement:_setLastAddition(addition)
    if addition > 0 then
        local text_percent = string.format('%d%%', addition)
        self._viewNode.text_extra:setString(text_percent)
    else
        self._viewNode.panel_extra:hide()
    end
end

function BaseGameArenaStatement:_setNextAddition(addition, additionDetail)
    if addition > 0 then
        local vipAddition, streakingAddition = additionDetail[1], additionDetail[2]
        if vipAddition and vipAddition > 0 then
            local vipAdditionNode               = self:_createAdditionNode()
            table.insert(self._viewNode.additionItems, vipAdditionNode)
            local additionName                  = self._gameController:getGameStringByKey("G_ARENA_VIP")
            local utf8Msg                       = MCCharset:getInstance():gb2Utf8String(additionName, string.len(additionName))
            vipAdditionNode.name:setString(utf8Msg)
            vipAdditionNode.percent:setString(string.format('%d%%', vipAddition))
        end
        if streakingAddition and streakingAddition > 0 then
            local streakingAdditionNode         = self:_createAdditionNode()
            table.insert(self._viewNode.additionItems, streakingAdditionNode)
            local additionName                  = self._gameController:getGameStringByKey("G_ARENA_STREAKING")
            local utf8Msg                       = MCCharset:getInstance():gb2Utf8String(additionName, string.len(additionName))
            streakingAdditionNode.name:setString(utf8Msg)
            streakingAdditionNode.percent:setString(string.format('%d%%', streakingAddition))
        end
        for count, node in pairs(self._viewNode.additionItems) do
            node.rootNode:addTo(self._viewNode.panel_nextExtra)
            node.rootNode:setPosition(40+250*(count-1), 30)
        end
    end
end

function BaseGameArenaStatement:_setInitHP(initHP)
    assert(type(initHP) == 'number', 'BaseGameArenaStatement:_setInitHP, unexpected initHP, number expected, got '..type(initHP))
    local titleSize = self._viewNode.HPtitle:getContentSize()
    local panelSize = self._viewNode.panel_playerHP:getContentSize()
    local customGap = 10
    local itemSize
    for count = 1, initHP do 
        local HPView = self:_createHPNode()
        table.insert(self._viewNode.HP, HPView)

        itemSize = itemSize or HPView.HPBG:getContentSize()
        HPView.rootNode:setPosition(cc.p(titleSize.width+40+count*(itemSize.width+customGap)-itemSize.width/2, panelSize.height/2))
        self._viewNode.panel_playerHP:addChild(HPView.rootNode)
    end
end

function BaseGameArenaStatement:_setLeftHP(HP)
    self:_setHPLose(#self._viewNode.HP-HP, false)
end

function BaseGameArenaStatement:_loseHP(count)
    self:_runHPAction(count)
end

function BaseGameArenaStatement:_showProgressLevel(awardCount, awardList)
    self._levelProgress:showLevel(awardCount, awardList, self._curMatchScore)

    if self._curMatchScore and self._roundScore then
        if self._roundScore > 0 then
            self:_onScoreIncreased(awardCount, awardList)
        else
            self._levelProgress:setPercent(self._curMatchScore/awardList[awardCount].nMatchScore*100)
        end
    end
end


function BaseGameArenaStatement:_setLevel(awardCount, awardList)
    for i = 1, awardCount do 
        if awardList[i].nMatchScore > self._curMatchScore then
            if i == 1 then 
                self._viewNode.img_level:setVisible(false)
                self._viewNode.img_textLevel:setVisible(false)
            else
                local texturePath = string.format(self.LEVELICON_TEXTURE_PATH, i-1)
                self._viewNode.img_level:loadTexture(texturePath)
            end
            break
        end
    end
end

function BaseGameArenaStatement:_onScoreIncreased(awardCount, awardList)

    local oldScore = self._lastActionScore or self._curMatchScore-self._roundScore
    local newScore = self._awardAchieved[1] and self._awardAchieved[1].nMatchScore or self._curMatchScore
    self._lastActionScore = newScore
    local topMatchScore = 0
    for _, awardInfo in pairs(awardList) do 
        topMatchScore = topMatchScore >= awardInfo.nMatchScore and topMatchScore or awardInfo.nMatchScore
    end

    self._levelProgress:runProgressAction(oldScore, newScore, topMatchScore, function()
        if #self._awardAchieved == 0 then return end
        local awardInfo = self._awardAchieved[1]
        table.remove(self._awardAchieved, 1)
        if newScore >= topMatchScore then --and not self._params.isForceQuit then
            if self._params.isForceQuit then
                self:_onArenaFinished()
            end
            self._gameController:playEffect(self.TOP_EFFECT_PATH)
            self:_runLevelMaxAction(
                awardInfo,
                function()
                    self._gameController:onStartGame()
                    self:removeSelf()
                end,
                function()
                    self._gameController:giveUpArenaInGame()
                end
            )
        else
            self._gameController:playEffect(self.AWARD_EFFECT_PATH)
            self:_runLevelUpAction(awardInfo, function()
                self:_onScoreIncreased(awardCount, awardList)
            end)
        end
    end)
end

function BaseGameArenaStatement:_findAwardAchieved(awardCount, awardList)
    for count = 1, awardCount do
        local awardInfo = awardList[count]
        if self._curMatchScore < awardInfo.nMatchScore then
            break
        end

        if self._curMatchScore - self._roundScore < awardInfo.nMatchScore then 
            table.insert(self._awardAchieved, awardInfo)
        end
    end
end

function BaseGameArenaStatement:_onArenaFinished()
    self._viewNode.btn_checkDetail:hide()
    local arenaFinished = false
    local function onArenaFinished()
        if arenaFinished then return end
        arenaFinished = true
        self._gameController:playBtnPressedEffect()
        self._gameController:onArenaFinished()
    end
    self.onKeyBack = onArenaFinished
    self._viewNode.btn_close:addClickEventListener(onArenaFinished)
    self._viewNode.btn_continue:addClickEventListener(onArenaFinished)
end

function BaseGameArenaStatement:isAlive()
    return self._alive
end

function BaseGameArenaStatement:onKeyBack()
    self._gameController:showGameResult()
    self:removeSelf()
end

return BaseGameArenaStatement