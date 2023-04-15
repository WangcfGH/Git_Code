local MyJiSuGameScene = class("MyJiSuGameScene", import("src.app.Game.mMyGame.MyGameScene"))
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")
local MyGameStart = import("src.app.Game.mMyGame.MyGameStart")
local MyJiSuGameSelfInfo = import("src.app.Game.mMyJiSuGame.MyJiSuGameSelfInfo")
local MyJiSuGameClock = import("src.app.Game.mMyJiSuGame.MyJiSuGameClock")
local MyJiSuGameSelfPlayer = import("src.app.Game.mMyJiSuGame.MyJiSuGamePlayer.MyJiSuGameSelfPlayer")
local MyJiSuGamePlayer = import("src.app.Game.mMyJiSuGame.MyJiSuGamePlayer.MyJiSuGamePlayer")
local MyJiSuGamePlayerManager = import("src.app.Game.mMyJiSuGame.MyJiSuGamePlayer.MyJiSuGamePlayerManager")
local MyJiSuSetCardCtrl = import("src.app.Game.mMyJiSuGame.MyJiSuSetCardCtrl")
local MyJiSuGameScoreCtrl = import("src.app.Game.mMyJiSuGame.MyJiSuGameScoreCtrl")
local MyJiSuBottomBarCtrl = import("src.app.Game.mMyJiSuGame.MyJiSuBottomBarCtrl")
local MyJiSuOpeBtnManager = import("src.app.Game.mMyJiSuGame.MyJiSuOpeBtnManager")
local MyJiSuHandCardsCustom = import("src.app.Game.mMyJiSuGame.MyJiSuHandCardsCustom")
local MyJiSuHandCards = import("src.app.Game.mMyJiSuGame.MyJiSuHandCards")
local MyJiSuShownCards = import("src.app.Game.mMyJiSuGame.MyJiSuShownCards")
local MyJiSuHandCardsManager = import("src.app.Game.mMyJiSuGame.MyJiSuHandCardsManager")
local MyJiSuThrownCards = import("src.app.Game.mMyJiSuGame.MyJiSuThrownCards")
local MyJiSuThrownCardsManager = import("src.app.Game.mMyJiSuGame.MyJiSuThrownCardsManager")
local MyJiSuResultPanel = import("src.app.Game.mMyJiSuGame.MyJiSuResultPanel")
local MyJiSuCalculator = import("src.app.Game.mMyJiSuGame.MyJiSuCalculator")
local MyJiSuGameTools = import("src.app.Game.mMyJiSuGame.MyJiSuGameTools")
local MyGameLoadingPanel = import("src.app.Game.mMyGame.MyGameLoadingPanel")

local BankruptcyModel = import('src.app.plugins.Bankruptcy.BankruptcyModel'):getInstance()
local user=mymodel('UserModel'):getInstance()

local windowSize = cc.Director:getInstance():getWinSize()

--设置游戏场景节点
function MyJiSuGameScene:addGameNode()
    print("MyJiSuGameScene:addGameNode")
    if not self._baseLayer then return end

    local gameLayer = self._baseLayer:getChildByTag(self.GameTags.GAMETAGS_GAMELAYER)
    if gameLayer then
        local csbPath = "res/GameCocosStudio/csb/GameSceneNewMode.csb"
        UIHelper:recordRuntime("EnterGameScene", "MyJiSuGameScene loadGameSceneNode begin")
        self._gameNode = cc.CSLoader:createNode(csbPath)

        UIHelper:recordRuntime("EnterGameScene", "MyJiSuGameScene loadGameSceneNode end")
        if self._gameNode then
            self._gameNode:setContentSize(cc.Director:getInstance():getVisibleSize())
            ccui.Helper:doLayout(self._gameNode)
            gameLayer:addChild(self._gameNode)

            my.presetAllButton(self._gameNode)
            cc.exports.zeroBezelNodeAutoAdapt(self._gameNode:getChildByName("Operate_Panel"))
            self:_decorateGameSceneNodeFunc_getChildByName(self._gameNode)
            print("MyJiSuGameScene:addGameNode gamenode created and added to scene")
        end
        UIHelper:recordRuntime("EnterGameScene", "MyJiSuGameScene doLayout gameSceneNode end")
    end

    UIHelper:recordRuntime("EnterGameScene", "MyJiSuGameScene deal other node of gameScene begin")
    self:refreshGameSceneNodesOnCardScaleOnFixedHeight()

    self:setClock()
    self:setPlayers()
    self:setTools()
    self:setStart()
    self:setSelfInfo()
    self:setChat()
    self:setSetting()
    --self:setUpInfo()
    self:setPanelSetCard() --设置理牌界面
    self:setBottomBar() --设置四大天王、炸弹等按钮
    self:setGameScore() --设置玩家积分
        
    UIHelper:recordRuntime("EnterGameScene", "MyJiSuGameScene:setGameCtrlsAboveBaseGame begin")
    self:setGameCtrlsAboveBaseGame()

    self:refreshGameSceneNodesWithButtonScaleOnFixedHeight()
    UIHelper:recordRuntime("EnterGameScene", "MyJiSuGameScene deal other node of gameScene end")
end

function MyJiSuGameScene:_adaptMyClockPosBetweenTwoOpeBtn()
    if self._gameNode == nil then return end

    --TODO operatebtn 适配
end

--额外设置理牌时钟
function MyJiSuGameScene:setClock()
    if not self._gameNode then return end

    for i=1, 5 do
        local clockPanel = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock"..tostring(i))
        if clockPanel then
            clockPanel:setVisible(false)
        end
    end

    local clockPanel = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock_SetCard")
    if clockPanel then
        clockPanel:setVisible(false)
    end

    --设置自身倒计时Clock位置，刚好在两个按钮之间
    self:_adaptMyClockPosBetweenTwoOpeBtn()
    
    local clockPanel = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock1")
    self._gameNode:getChildByName("Panel_Clock"):setZOrder(MyJiSuGameDef.MY_ZORDER_ARENAINFO)
    if clockPanel then
        self._clock = MyJiSuGameClock:create(clockPanel, self._gameController)
    end
end

function MyJiSuGameScene:setPlayers()
    if not self._gameNode then return end
    if not self._gameController then return end

    local players = {}
    for i = 1, self._gameController:getTableChairCount() do
        if i == 1 then
            local playerPanel = self._gameNode:getChildByName("Panel_Player" .. tostring(i))
            local playerNode = self._gameNode:getChildByName("Node_Player" .. tostring(i))
            if playerPanel then
                players[i] = MyJiSuGameSelfPlayer:create(playerPanel, playerNode, i, self._gameController)
                playerPanel:setZOrder(MyJiSuGameDef.MYJISU_ZORDER_PANEL_PLAYER)
            end
        else
            local playerPanel = self._gameNode:getChildByName("Panel_Player" .. tostring(i))
            local playerNode = self._gameNode:getChildByName("Node_Player" .. tostring(i))
            if playerPanel then
                players[i] = MyJiSuGamePlayer:create(playerPanel, playerNode, i, self._gameController)
                playerPanel:setZOrder(MyJiSuGameDef.MYJISU_ZORDER_PANEL_PLAYER)
            end
        end
    end

    self._playerManager = MyJiSuGamePlayerManager:create(players, self._gameController)
end

function MyJiSuGameScene:setStart()
    if not self._gameNode then return end

    local NodeStart = self._gameNode:getChildByName("Panel_Start")
    NodeStart:setVisible(true)
    local startPanel = NodeStart:getChildByName("Node_Start"):getChildByName("Panel_OperationBtn")
    if startPanel then
        self._start = MyGameStart:create(startPanel, self._gameController)
    end

    self:setBankruptcyBtn()
end

--需要重载，避免报错
function MyJiSuGameScene:setSelfInfo()
    if not self._gameNode then return end
    
    local NodeMatching = self._gameNode:getChildByName("Panel_Start"):getChildByName("Node_Matching")
    local NodeMatching2 = self._gameNode:getChildByName("Panel_Start"):getChildByName("Node_Matching2")
    self._gameNode:getChildByName("Node_AttentionWords"):setVisible(true)
    local selfInfoPanel = self._gameNode:getChildByName("Node_AttentionWords"):getChildByName("Panel_AttentionWords")
    local NodeCancelRobot = self._gameNode:getChildByName("Panel_Player1"):getChildByName("Node_CancelRobot")

    local NoBigger = self._gameNode:getChildByName("Panel_Player1"):getChildByName("Panel_AttentionWords")

    if selfInfoPanel then
        self._selfInfo = MyJiSuGameSelfInfo:create(selfInfoPanel, NodeMatching, NodeCancelRobot, NoBigger,nil, NodeMatching2)
    end
end

--获取银子显示控件
function MyJiSuGameScene:getSelfDepositText()
    if not self._gameNode then return false end
    local nodePlayer = self._gameNode:getChildByName("Panel_Player1"):getChildByName("Node_PlayerName")
    local playerName = nodePlayer:getChildByName("Panel_PlayerName")
    local playerUserDeposit = playerName:getChildByName("Value_sliver")
    return playerUserDeposit
end

--设置gamecontroller，同时设为全局变量
function MyJiSuGameScene:setControllerDelegate()
    self._gameController = import("src.app.Game.mMyJiSuGame.MyJiSuGameController")
    cc.exports.MyJiSuGameController = self._gameController
end

--重载自gamecontroller
function MyJiSuGameScene:updateGoldeEggData(data)
end

function MyJiSuGameScene:showAutoCombBtn(isVisible)
    if self._SKAutoCombBtn then
        local quickAdjust = self._gameController._baseGameUtilsInfoManager._utilsStartInfo.nQuickAdjust

        if quickAdjust and quickAdjust == 1 then
            self._SKAutoCombBtn:setVisible(isVisible)
        else
            self._SKAutoCombBtn:setVisible(false)
        end
    end
end
-- 一键理牌
function MyJiSuGameScene:onClickAutoCombBtn()
    self._gameController:playBtnPressedEffect()
    
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._autoCombLastTime = self._autoCombLastTime or 0
    if nowTime - self._autoCombLastTime > GAP_SCHEDULE then
        self._autoCombLastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 2}})
        return
    end

    self._gameController:AutoComb()
end

--设置游戏界面按钮
function MyJiSuGameScene:setOtherBtns()
    if not self._gameNode then return end

    local chatBtn = self._gameNode:getChildByName("Btn_Chat")
    if chatBtn then
        self._SKChatBtn = chatBtn
        chatBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickChatBtn()
            self:onClickChatBtn()
            end
        self._SKChatBtn:addClickEventListener(onClickChatBtn)
    end

    local autoCombBtn = self._gameNode:getChildByName("Btn_AutoComb")
    if autoCombBtn then
        self._SKAutoCombBtn = autoCombBtn
        chatBtn:setZOrder(MyGameDef.MY_ZORDER_ARENAINFO)
        local function onClickAutoCombBtn()
            self:onClickAutoCombBtn()
            end
        self._SKAutoCombBtn:addClickEventListener(onClickAutoCombBtn)
    end

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

    --计分规则按钮
    local RuleBtn = self._gameNode:getChildByName("Btn_RuleScore")
    if RuleBtn then
        RuleBtn:setLocalZOrder(SKGameDef.SK_ZORDER_SELFINFO)
        self._MyRuleJiSuBtn = RuleBtn
        local function onClickRuleBtn()
            my.informPluginByName({pluginName='GameRuleScoreJiSuPlugin'})
        end
        self._MyRuleJiSuBtn:addClickEventListener(onClickRuleBtn)
    end

    self._gameNode:getChildByName("Node_OperationBtn"):setZOrder(MyGameDef.MY_ZORDER_ARENAINFO) --出牌按钮  低于炸弹动画SK_ZORDER_THROWN_ANIMATION
end

function MyJiSuGameScene:refreshGameSceneNodesWithButtonScaleOnFixedHeight()
    if not self._gameNode then return end

    local curWHRatio = display.width / display.height
    if curWHRatio < 2.05 then
        return --较小的长宽比，则不放大和移位，因为水平宽度不够，会超出屏幕
    end

    local cardScaleVal = UIHelper:getProperScaleOnFixedHeight()
    if cardScaleVal > 1.0 then
        local btnNamesToScale = {
            "Btn_Chat"
        }
        local scaleVal = 1.1
        for _, btnName in pairs(btnNamesToScale) do
            local btnNode = self._gameNode:getChildByName(btnName)
            if btnNode then btnNode:setScale(scaleVal) end
        end
    end
end

--设置理牌界面
function MyJiSuGameScene:setPanelSetCard()
    if not self._gameNode then return end

    local panelSetCard = self._gameNode:getChildByName("Panel_SetCard")
    if panelSetCard then
        self._setCardCtrl = MyJiSuSetCardCtrl:create(panelSetCard, self._gameController)
    end
end

--设置四大天王、炸弹等按钮
function MyJiSuGameScene:setBottomBar()
    if not self._gameNode then return end

    local panelBottomBar = self._gameNode:getChildByName("Panel_BottomBar")
    if panelBottomBar then
        self._bottomBarCtrl = MyJiSuBottomBarCtrl:create(panelBottomBar, self._gameController)
    end
end

--设置玩家积分
function MyJiSuGameScene:setGameScore()
    if not self._gameNode then return end

    local panelGameScore = self._gameNode:getChildByName("Panel_GameScore")
    if panelGameScore then
        self._gameScoreCtrl = MyJiSuGameScoreCtrl:create(panelGameScore, self._gameController)
    end
end

function MyJiSuGameScene:setOpeBtns()
    if not self._gameNode then return end

    local nodeOpeBtns = self._gameNode:getChildByName("Node_OperationBtn")
    if nodeOpeBtns then
        self._SKOpeBtnManager = MyJiSuOpeBtnManager:create(nodeOpeBtns, self._gameController)
    end
end

function MyJiSuGameScene:setHandCards()
    local handCards = {}
    for i = 1, self._gameController:getTableChairCount() do
        if (i == self._gameController:getMyDrawIndex()) then
            if not self._myHandCards[i] then
                self._myHandCards[i] = MyJiSuHandCards:create(i, self._gameController)
            end
            handCards[i] = self._myHandCards[i]
        else
            if not self._throwHandCards[i] then
                self._throwHandCards[i] = MyJiSuShownCards:create(i, self._gameController)
            end
            handCards[i] = self._throwHandCards[i]
        end
    end
    local myDrawIndex = self._gameController:getMyDrawIndex()
    for i = 1, 3 do
        if not self._myHandCardsCustom[i] then
            self._myHandCardsCustom[i] = MyJiSuHandCardsCustom:create(myDrawIndex, i, self._gameController)
        end
    end
    self._SKHandCardsManager = MyJiSuHandCardsManager:create(handCards, self._myHandCardsCustom, self._gameController)
end

function MyJiSuGameScene:setThrownCards()
    local thrownCards = {}
    for i = 1, self._gameController:getTableChairCount() do
        thrownCards[i] = MyJiSuThrownCards:create(i, self._gameController)
        self._gameNode:getChildByName("Panel_Card_thrown"..i):setLocalZOrder(MyJiSuGameDef.MYJISU_ZORDER_PAIXING)
    end

    self._SKThrownCardsManager = MyJiSuThrownCardsManager:create(thrownCards, self._gameController)
end

function MyJiSuGameScene:addResultNode(gameWin)
    if not self._resultLayer then return end

    self._resultNode = MyJiSuResultPanel:create(gameWin, self._gameController)
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
                            promptParentNode = self, 
                            VideoAdRelief = true}
                        })
                    end
                end)
            end
        end
    end
end

function MyJiSuGameScene:setTools()         
    if not self._gameNode then return end
    local nodeTools = self._gameNode:getChildByName("Node_GameTools")
    nodeTools:setLocalZOrder(MyJiSuGameDef.SK_ZORDER_PLAYERINFO + 1000)

    --如果有补银用另外一个csb
    if self._gameController:isSupportAutoSupply() then
        nodeTools:removeAllChildren()
        local layerNode = cc.CSLoader:createNode("res/GameCocosStudio/csb/Node_GameTools_AutoSupply.csb")
        nodeTools:addChild(layerNode)
        local toolsPanel = layerNode:getChildByName("Panel_GameTools")
        if toolsPanel then
            self._tools = MyJiSuGameTools:create(toolsPanel, false, self._gameController)
        end
        return
    end

    local toolsPanel = nodeTools:getChildByName("Panel_GameTools")
    if toolsPanel then
        self._tools = MyJiSuGameTools:create(toolsPanel, false, self._gameController)
    end
end

function MyJiSuGameScene:setSortTypeBtnEnabled(status)
    if false == status then
        self:setTHSBtnsEnabled(status)
    end
end

function MyJiSuGameScene:getSetCardCtrl()
    return self._setCardCtrl
end

function MyJiSuGameScene:getBottomBarCtrl()
    return self._bottomBarCtrl
end 

function MyJiSuGameScene:getGameScoreCtrl()
    return self._gameScoreCtrl
end

function MyJiSuGameScene:addLoadingNode()
    MyJiSuCalculator:CreateGameUtilsInfoManager()
    if not self._loadingLayer then return end

    self._loadingNode = MyGameLoadingPanel:create(self._gameController)
    if self._loadingNode then
        self._loadingLayer:addChild(self._loadingNode)
        self._loadingNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

function MyJiSuGameScene:changeSomeBtnPosition()
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
        if opeBtnsNode then opeBtnsNode:setPositionY(standPosition.y + 290 + 120) end
        if myDrawIndex == self._clock:getDrawIndex() then
         -- 操作clock坐标时候需要判断两个drawIndex是否一致，不然不是自己出牌的时候切换就影响其他位置的clock的显示
            if clockNode1 then clockNode1:setPositionY(standPosition.y +303 +  120) end
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
    else
    --- 横向排列调整
        if opeBtnsNode then opeBtnsNode:setPositionY(standPosition.y + 290 + OFFSET.opeBtnsOffset) end
        if myDrawIndex == self._clock:getDrawIndex() then
            if clockNode1 then clockNode1:setPositionY(standPosition.y + 303 + OFFSET.opeBtnsOffset) end
        end

        thrownPosition1:setPositionY(standPosition.y + 205 + OFFSET.opeBtnsOffset + 20)

        self._SKThrownCardsManager:sortThrownCards(myDrawIndex)
    end

    if self._gameController:getMyDrawIndex() == self._clock:getDrawIndex() then
        if self._clock then self._clock:updateClockPositionForArena() end
    end
end

function MyJiSuGameScene:getTopRightNodeList( )
    local nodeList = {
        {"Btn_RuleScore"},
        {"Btn_LimitTimeGift"},
    }
    return nodeList
end

return MyJiSuGameScene
