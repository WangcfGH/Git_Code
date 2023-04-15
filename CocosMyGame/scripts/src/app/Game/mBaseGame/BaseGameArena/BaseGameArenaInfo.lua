
local BaseGameArenaInfo = class("BaseGameArenaInfo")

BaseGameArenaInfo.RESOURCE_PATH         = "res/GameCocosStudio/csb/arena_game.csb"
BaseGameArenaInfo.HP_RESOURCE_PATH      = "res/GameCocosStudio/csb/playerhp_unit.csb"
BaseGameArenaInfo.WIN_RESOURCE_PATH     = 'res/GameCocosStudio/csb/result_win.csb'
BaseGameArenaInfo.LOSE_RESOURCE_PATH    = 'res/GameCocosStudio/csb/result_lose.csb'
BaseGameArenaInfo.SCORE_RESOURCE_PATH   = 'res/GameCocosStudio/csb/result_score.csb'
BaseGameArenaInfo.START_RESOURCE_PATH   = 'res/GameCocosStudio/csb/ani_start2.csb'

BaseGameArenaInfo.MALE_RESOURCE_PATH    = "res/Game/GamePic/GameContents/touxiang_boy.png"
BaseGameArenaInfo.FEMALE_RESOURCE_PATH  = "res/Game/GamePic/GameContents/touxiang_girl.png"

BaseGameArenaInfo.WIN_EFFECT_PATH       = "Arena/win.mp3"
BaseGameArenaInfo.LOSE_EFFECT_PATH      = "Arena/lose.mp3"


function BaseGameArenaInfo:ctor(arenaInfoLayer, gameController)
    self._arenaInfoLayer         = arenaInfoLayer
    self._gameController         = gameController

    self._arenaInfoBar              = nil
    self._arenaInfoSwitch           = nil
    self._arenaInfoDeposit          = nil
    self._arenaInfoDepositIcon      = nil
    self._arenaInfoHPPanel          = nil
    self._arenaInfoArenaScore       = nil
    self._arenaInfoArenaScore_total = nil
    self._arenaInfoPortrait         = nil

    self._winNode                   = nil
    self._loseNode                  = nil

    self._position                  = 'down'

    self._initHP                    = 0
    self._leftHP                    = 0
    self._HPNodes                   = {} 
    self._result                    = {}

    self:init()
end

function BaseGameArenaInfo:init()
    if not self._arenaInfoLayer then return end

    self._arenaInfoBar              = self._arenaInfoLayer:getChildByName("Panel_ArenaBar")
    self._arenaInfoSwitch_show      = self._arenaInfoBar:getChildByName("Btn_Switch")

    local animationPanel            = self._arenaInfoBar:getChildByName("Panel_Ani")
    self._arenaInfoSwitch_hide      = animationPanel:getChildByName("Btn_Switch")

    local depositPanel              = animationPanel:getChildByName("Panel_Deposit")
    self._arenaInfoDeposit          = depositPanel:getChildByName("Text_Num")
    self._arenaInfoDepositIcon      = depositPanel:getChildByName("Img_Icon")

    self._arenaInfoHPPanel          = animationPanel:getChildByName("Panel_PlayerHP")
    self._arenaInfoHPIcon           = self._arenaInfoHPPanel:getChildByName("Img_Icon")

    local scorePanel                = animationPanel:getChildByName("Panel_Score")
    self._arenaInfoArenaScore       = scorePanel:getChildByName("Text_Num")

    local totalScorePanel           = animationPanel:getChildByName("Panel_TotalScore")
    self._arenaInfoArenaScore_total = totalScorePanel:getChildByName("Text_Num")

    self._arenaInfoPortrait         = ccui.Helper:seekWidgetByName(animationPanel, "Img_HeadPic")

    self:runEnterAction() 
    self:registEvents()
end

function BaseGameArenaInfo:registEvents()
    self._arenaInfoSwitch_hide:addClickEventListener(function()
         self._gameController:playBtnPressedEffect()
         self._gameController:hideArenaInfo()
    end)
    self._arenaInfoSwitch_show:addClickEventListener(function()
         self._gameController:playBtnPressedEffect()
         self._gameController:showArenaInfo()
    end)
end

function BaseGameArenaInfo:hide()
    if self._position ~= 'down' then
        self:runExitAction()
        self._position = 'down'
    end
end

function BaseGameArenaInfo:show()
    if self._position ~= 'up' then
        self:runEnterAction()
        self._position = 'up'
    end
end

function BaseGameArenaInfo:setPortrait(resPath)
    if "string" ~= type(resPath) then return end

    if self._arenaInfoPortrait then
        self._arenaInfoPortrait:loadTexture(resPath)
    end
end

function BaseGameArenaInfo:setNickSex(nNickSex)
    if self._arenaInfoPortrait then
        self._arenaInfoPortrait:setVisible(true)
        if 1 == nNickSex then
            self._arenaInfoPortrait:loadTexture(self.FEMALE_RESOURCE_PATH)
        else
            self._arenaInfoPortrait:loadTexture(self.MALE_RESOURCE_PATH)
        end
    end
end

function BaseGameArenaInfo:setSelfDeposit(nDeposit)
    if "number" ~= type(nDeposit) then return end

    if self._arenaInfoDeposit then
        self._arenaInfoDeposit:setString(nDeposit)
    end
end

function BaseGameArenaInfo:setTotalScore(totalScore)
    if self._arenaInfoArenaScore_total then
        self._arenaInfoArenaScore_total:setString(tostring(totalScore))
    end
end

function BaseGameArenaInfo:setArenaScore(arenaScore)
    if self._arenaInfoArenaScore then
        self._arenaInfoArenaScore:setString(tostring(arenaScore))
    end
end

function BaseGameArenaInfo:addArenaScore(addScore)
    if self._arenaInfoArenaScore then
        local newScore = tonumber(self._arenaInfoArenaScore:getString()) + addScore
        self._arenaInfoArenaScore:setString(tostring(newScore))
    end
end

function BaseGameArenaInfo:setHP(initHP, leftHP)
    self._initHP = initHP
    self._leftHP = leftHP
    if self._arenaInfoHPPanel then
        local panelSize = self._arenaInfoHPPanel:getContentSize()
        local iconSize = self._arenaInfoHPIcon:getContentSize()
        local itemWidth = 32.5
        local gap = (panelSize.width-iconSize.width-itemWidth*initHP)/(initHP+1)
        for count = 1, initHP do 
            local HPNode = cc.CSLoader:createNode(self.HP_RESOURCE_PATH)
            HPNode:setScale(0.65, 0.65)
            HPNode:setPosition(cc.p(iconSize.width+gap*count+itemWidth*(count-0.5), panelSize.height/2))
            self._arenaInfoHPPanel:addChild(HPNode)
            if leftHP < count then 
                local timeline = cc.CSLoader:createTimeline(self.HP_RESOURCE_PATH)
                HPNode:runAction(timeline)
                timeline:gotoFrameAndPlay(25, 27, false)
            end
            table.insert(self._HPNodes, HPNode)
        end
    end
end

function BaseGameArenaInfo:loseHP(num)
    if self._leftHP == 0 or type(num) ~= 'number' then return end--or num < 1 then return end
    for count = self._leftHP-num+1, self._leftHP do
        local HPNode = self._HPNodes[count] 
        local timeline = cc.CSLoader:createTimeline(self.HP_RESOURCE_PATH)
        HPNode:runAction(timeline)
        timeline:gotoFrameAndPlay(25, 27, false)
    end
    self._leftHP = self._leftHP-num
end

--function BaseGamePlayerManager:onGameWin(resultList)
--    for drawIndex, diff in pairs(resultList) do 
--        self._players[drawIndex]:showStateMentInArena(diff)
--    end
--end

--function BaseGamePlayer:showStateMentInArena(amount, onAnimationFinished)
--    if self._stateMentNode then 
--        self._stateMentNode:setVisible(true)
--    else
--        local csbPath = amount>0 and 'res/GameCocosStudio/csb/result_score_win.csb' or 'res/GameCocosStudio/csb/result_score_lose.csb'
--        local stateMentNode = cc.CSLoader:createNode(csbPath)
--        local text_num = stateMentNode:getChildByName('Panel_Score'):getChildByName('Text_Score')
--        text_num:setString(amount)
--        self._stateMentNode = stateMentNode
--        self._playerPanel:setPosition(cc.p(self._playerChatFrame:getPositionX(), self._playerChatFrame:getPositionY()))
--        self._playerPanel:addChild(stateMentNode)
--    end

--    local timeline = cc.CSLoader:createTimeline(csbPath)
--    stateMentNode:runAction(timeline)
--    timeline:gotoFrameAndPlay(1, 11, false)
--    if not onAnimationFinished then return end
--    timeline:setFrameEventCallFunc(function(frame)
--        if frame and frame:getEvent() == "Play_Over" then 
--            onAnimationFinished()
--        end
--    end)

--end

function BaseGameArenaInfo:runEnterAction()
    local timeline = cc.CSLoader:createTimeline(self.RESOURCE_PATH)

    self._arenaInfoLayer:runAction(timeline)
    timeline:gotoFrameAndPlay(13, 24, false)
end

function BaseGameArenaInfo:runExitAction()
    local timeline = cc.CSLoader:createTimeline(self.RESOURCE_PATH)

    self._arenaInfoLayer:runAction(timeline)
    timeline:gotoFrameAndPlay(1, 12, false)
end 

function BaseGameArenaInfo:runLoseAction(leftHP, diffNum, diffs, runningScene)
    printLog('BaseGameArenaInfo', 'runLoseAction')
    print(leftHP, diffNum, diffs, runningScene)
    local timeline      = cc.CSLoader:createTimeline(self.LOSE_RESOURCE_PATH)
    local loseNode      = cc.CSLoader:createNode(self.LOSE_RESOURCE_PATH)
    loseNode:setContentSize(display.size)
    ccui.Helper:doLayout(loseNode)

    local panelResult   = loseNode:getChildByName("Panel_ResultMain")
    local panelPlayerHP = panelResult:getChildByName("Panel_PlayerHP")

    local parent = runningScene or self._arenaInfoLayer
    parent:addChild(loseNode)
    loseNode:runAction(timeline)
    timeline:gotoFrameAndPlay(1, 50, false) 
    timeline:setFrameEventCallFunc(function(frame)
        for count = 1, leftHP-diffNum do
            local HPNode = cc.CSLoader:createNode(self.HP_RESOURCE_PATH)
            HPNode:setPosition(cc.p(count*50-25, 25))
            HPNode:addTo(panelPlayerHP)
            if count > leftHP then
                local timeline = cc.CSLoader:createTimeline(self.HP_RESOURCE_PATH)
                HPNode:runAction(timeline)
                timeline:gotoFrameAndPlay(1, 25, false)
            end
        end
    end)

    self._loseNode = loseNode 
    my.scheduleOnce(function()
        if self._loseNode then
            self._loseNode:removeSelf()
            self._loseNode = nil
        end
    end, 2)

    self:runScoreAction(loseNode, diffs)
end

function BaseGameArenaInfo:runWinAction(diffs, runningScene)
    local timeline  = cc.CSLoader:createTimeline(self.WIN_RESOURCE_PATH)
    local winNode   = cc.CSLoader:createNode(self.WIN_RESOURCE_PATH)
    winNode:setContentSize(display.size)
    ccui.Helper:doLayout(winNode)
    local parent = runningScene or self._arenaInfoLayer
    parent:addChild(winNode)
    winNode:runAction(timeline)
    timeline:gotoFrameAndPlay(1, 41, false)

    self._winNode = winNode 
    my.scheduleOnce(function()
        if self._winNode then
            self._winNode:removeSelf()
            self._winNode = nil
        end
    end, 2)

    self:runScoreAction(winNode, diffs)
end

function BaseGameArenaInfo:runScoreAction(resultLayer, diffs)
    for drawIndex, diff in pairs(diffs) do 
        local scoreNode = resultLayer:getChildByName(string.format("Node_PlayerScore%d", drawIndex))
        if scoreNode then
            local panelName = diff>=0 and 'Panel_Score_Win' or 'Panel_Score_Lose'
            local scorePanel = scoreNode:getChildByName(panelName)
            scorePanel:setVisible(true)
            local scoreText = scorePanel:getChildByName("Text_Score")
            scoreText:setString(tostring(diff))
            local timeline = cc.CSLoader:createTimeline(self.SCORE_RESOURCE_PATH)
            scoreNode:runAction(timeline)
            timeline:gotoFrameAndPlay(1, 11, false)
        end
    end
end

function BaseGameArenaInfo:runStartAction(bout)
    local startNode = cc.CSLoader:createNode(self.START_RESOURCE_PATH)
    local timeline = cc.CSLoader:createTimeline(self.START_RESOURCE_PATH)
    startNode:setPosition(display.center)
    local parentNode = self._arenaInfoLayer
    if self._gameController and self._gameController._baseGameScene and self._gameController._baseGameScene._gameNode then
        parentNode = self._gameController._baseGameScene._gameNode
    end
    parentNode:addChild(startNode)
    startNode:runAction(timeline)
    timeline:gotoFrameAndPlay(1, 41, false)
    timeline:setFrameEventCallFunc(function(frame)
        if frame and frame:getEvent() == "Play_Over" then 
            startNode:removeSelf()
        end
    end)

    SubViewHelper:adaptNodePluginToScreen(startNode, startNode:getChildByName("Panel_Shade"))
    --[[print("bbbb")
    for _, childNode in pairs(startNode:getChildren()) do
        print(childNode:getName())
        for _, childNode2 in pairs(childNode:getChildren()) do
            print(childNode2:getName())
            for _, childNode3 in pairs(childNode2:getChildren()) do
                print(childNode3:getName())
            end
            print("------------3")
        end
        print("------------2")
    end]]--

    local panelMain = startNode:getChildByName("Panel_Main")
    local imgBg = panelMain:getChildByName("Img_BG")
    imgBg:setContentSize(cc.size(1800, imgBg:getContentSize().height))
    local textTurn = ccui.Helper:seekWidgetByName(panelMain, "Text_Turn")

--    local arenaInfoManager = self._gameController:getArenaInfoManager()
--    local bout = arenaInfoManager:getBout()
    textTurn:setString(bout)
end

function BaseGameArenaInfo:onGameResult(diffs)
    self:checkResult(diffs)
end

function BaseGameArenaInfo:onArenaResult(result)
    self:setTotalScore(result.nMatchScore)
    self:loseHP(-result.nDiffHP)
    self:setArenaScore(0)
    self:checkResult(nil, result)
end 

function BaseGameArenaInfo:checkResult(diffs, arenaResult)
    self._result.diffs          = self._result.diffs or diffs
    self._result.arenaResult    = self._result.arenaResult or arenaResult
    if self._result.diffs and self._result.diffs[1] >= 0 then
        if not self._result.arenaResult then return end
        self._gameController:playEffect(self.WIN_EFFECT_PATH)
        self:runWinAction(self._result.diffs)
        self._result = {}
    else
        if self._result.diffs and self._result.arenaResult then
            self._gameController:playEffect(self.LOSE_EFFECT_PATH)
            self:runLoseAction(self._result.arenaResult.nHP, self._result.arenaResult.nDiffHP, self._result.diffs)
            self._result = {}
        end
    end
end

function BaseGameArenaInfo:onGameStart()
end

function BaseGameArenaInfo:onGameEnter()
end

function BaseGameArenaInfo:onGameExit()
    self._loseNode = nil
    self._winNode  = nil
end

return BaseGameArenaInfo
