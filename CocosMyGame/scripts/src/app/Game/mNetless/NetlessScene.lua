
local MyGameScene = import("src.app.Game.mMyGame.MyGameScene")
local NetlessScene = class("NetlessScene", MyGameScene)

local NetlessCalculator                              = import("src.app.Game.mNetless.NetlessCalculator")
local MyCalculator                              = import("src.app.Game.mMyGame.MyCalculator")

local MyHandCards                   = import("src.app.Game.mMyGame.MyHandCards")    --Modify by wuym
local NetlessShownCards                  = import("src.app.Game.mNetless.NetlessShownCards")
local NetlessHandCardsManager            = import("src.app.Game.mNetless.NetlessHandCardsManager")

local NetlessController              = import("src.app.Game.mNetless.NetlessController")
local NetlessGamePlayerManager = import("src.app.Game.mNetless.NetlessGamePlayerManager")
local NetlessGamePlayer = import("src.app.Game.mNetless.NetlessGamePlayer")
local NetlessGameStart              = import("src.app.Game.mNetless.NetlessGameStart")
local NetlessLoadingPanel            = import("src.app.Game.mNetless.NetlessLoadingPanel")
local NetlessGameTools              = import("src.app.Game.mNetless.NetlessGameTools")
local NetlessGameClock              = import("src.app.Game.mNetless.NetlessGameClock")
local NetlessGameSelfPlayer                  = import("src.app.Game.mNetless.NetlessGameSelfPlayer")
local MyResultPanel                 = import("src.app.Game.mMyGame.MyResultPanelEx")

local windowSize = cc.Director:getInstance():getWinSize()

function NetlessScene:setControllerDelegate()
    self._gameController = NetlessController
end

function NetlessScene:addLoadingNode()
    MyCalculator:CreateGameUtilsInfoManager()
    NetlessCalculator:CreateGameUtilsInfoManager()
    if not self._loadingLayer then return end

    self._loadingNode = NetlessLoadingPanel:create(self._gameController)
    if self._loadingNode then
        self._loadingLayer:addChild(self._loadingNode)
        self._loadingNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

function NetlessScene:setHandCards()
    local handCards = {}
    for i = 1, self._gameController:getTableChairCount() do
        if (i == self._gameController:getMyDrawIndex()) then
            handCards[i] = MyHandCards:create(i, self._gameController)
        else
            handCards[i] = NetlessShownCards:create(i, self._gameController)
        end
    end

    self._SKHandCardsManager = NetlessHandCardsManager:create(handCards, self._gameController)
end

function NetlessScene:setTools()         
    if not self._gameNode then return end

    local toolNode = self._gameNode:getChildByName("Node_GameTools")
    if toolNode then
        local SKGameDef = import("src.app.Game.mSKGame.SKGameDef")
        toolNode:setLocalZOrder(SKGameDef.SK_ZORDER_PLAYERINFO + 100)
    end

    local toolsPanel = self._gameNode:getChildByName("Node_GameTools"):getChildByName("Panel_GameTools")    
    if toolsPanel then
        self._tools = NetlessGameTools:create(toolsPanel, false, self._gameController)
    end
end

function NetlessScene:setOtherBtns()
    NetlessScene.super.setOtherBtns(self)

    self._SKChatBtn:setVisible(false)
    self._SKMissionBtn:setVisible(false)
    if self._SelectTableBtn then
        self._SelectTableBtn:setVisible(false)
    end
    self._MYShopBtn:setVisible(false)

    if self._MyNodeExpression then
        self._MyNodeExpression:setVisible(false)
    end

    self._timingGameTicketTaskBtn:setVisible(false)
end

function NetlessScene:setPlayers()
    if not self._gameNode then return end
    if not self._gameController then return end

    local players = {}
    for i = 1, self._gameController:getTableChairCount() do
        if i == 1 then
            local playerPanel = self._gameNode:getChildByName("Panel_Player" .. tostring(i))
            local playerNode = self._gameNode:getChildByName("Node_Player" .. tostring(i))
            if playerPanel then
                players[i] = NetlessGameSelfPlayer:create(playerPanel, playerNode, i, self._gameController)
            end
        else
            local playerPanel = self._gameNode:getChildByName("Panel_Player" .. tostring(i))
            local playerNode = self._gameNode:getChildByName("Node_Player" .. tostring(i))
            if playerPanel then
                players[i] = NetlessGamePlayer:create(playerPanel, playerNode, i, self._gameController)
            end
        end
    end

    self._playerManager = NetlessGamePlayerManager:create(players, self._gameController)
end

function NetlessScene:setClock()
    if not self._gameNode then return end

    for i=1, 5 do
        local clockPanel = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock"..tostring(i))
        if clockPanel then
            clockPanel:setVisible(false)
        end
    end

    self:_adaptMyClockPosBetweenTwoOpeBtn()
    
    local clockPanel = self._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock1")
    if clockPanel then
        self._clock = NetlessGameClock:create(clockPanel, self._gameController)
    end

    --调整一些界面元素的位置
    self:_refreshPositionOfSomeElements()
end

function NetlessScene:_refreshPositionOfSomeElements()
    if not self._gameNode then return end

    local OFFSET = {
        opeBtnsOffset = 0
    }
    local cardScaleVal = UIHelper:getProperScaleOnFixedHeight()
    if cardScaleVal > 1.0 then
        OFFSET.opeBtnsOffset = 40
    end

    local playerPanel = self._gameNode:getChildByName("Panel_Player1")
    local standPosition = cc.p(playerPanel:getPosition())
    local thrownPosition1 = self._gameNode:getChildByName("Panel_Card_thrown1")
    thrownPosition1:setPositionY(standPosition.y + 205 + OFFSET.opeBtnsOffset + 50)
end

function NetlessScene:setStart()
    if not self._gameNode then return end

    local NodeStart = self._gameNode:getChildByName("Panel_Start")
    NodeStart:setVisible(true)
    local startPanel = NodeStart:getChildByName("Node_Start"):getChildByName("Panel_OperationBtn")
    if startPanel then
        self._start = NetlessGameStart:create(startPanel, self._gameController)
    end
end

function NetlessScene:addResultNode(gameWin)
    if not self._resultLayer then return end

    self._resultNode = MyResultPanel:create(gameWin, self._gameController, true)
    if self._resultNode then
        self._resultLayer:addChild(self._resultNode)
        self._resultNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

function NetlessScene:dealSortTypeBtnsEvent(sortFlag)
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

function NetlessScene:doSomethingForVerticalCard()
    self:setSortTypeBtnEnabled(false)  -- 单机房直接隐藏切换按钮
end

function NetlessScene:setSortTypeBtnEnabled(status)
    self._MYSortTypeBtn:setVisible(status) 
end


function NetlessScene:isVerticalCardsMode()
    -- 单机场里面没有竖排，直接返回false
    return false
end

--连胜挑战单机场不显示
function NetlessScene:refreshWinningStreakBtn()
    if not self._btnWinningStreak then return end
    self._btnWinningStreak:setVisible(false)
end

function NetlessScene:onBankruptcyTimeUpdate()
    self:hideBankruptcyBtn()
end

return NetlessScene
