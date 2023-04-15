
local BaseGameScene = import("src.app.Game.mBaseGame.BaseGameScene")
local SKGameScene = class("SKGameScene", BaseGameScene)

local SKGameController              = import("src.app.Game.mSKGame.SKGameController")

local CanvasLayer                   = import("src.app.Game.mCommon.CanvasLayer")
local SKGameTools                   = import("src.app.Game.mSKGame.SKGameTools")
local SKGameClock                   = import("src.app.Game.mSKGame.SKGameClock")
local SKGameInfo                    = import("src.app.Game.mSKGame.SKGameInfo")
local SKGamePlayerManager           = import("src.app.Game.mSKGame.SKGamePlayerManager")
local SKGamePlayer                  = import("src.app.Game.mSKGame.SKGamePlayer")
local SKGameSelfPlayer                  = import("src.app.Game.mSKGame.SKGameSelfPlayer")
local SKHandCards                   = import("src.app.Game.mSKGame.SKHandCards")
local SKHandCardsManager            = import("src.app.Game.mSKGame.SKHandCardsManager")
local SKThrownCards                 = import("src.app.Game.mSKGame.SKThrownCards")
local SKThrownCardsManager          = import("src.app.Game.mSKGame.SKThrownCardsManager")
local SKShownCards                  = import("src.app.Game.mSKGame.SKShownCards")
local SKGameSelfInfo                = import("src.app.Game.mSKGame.SKGameSelfInfo")
local SKOpeBtnManager               = import("src.app.Game.mSKGame.SKOpeBtnManager")
local SKGameResultPanel             = import("src.app.Game.mSKGame.SKGameResultPanel")

local SKGameSetting                 = import("src.app.Game.mSKGame.SKGameSetting")
local SKGameTask                    = import("src.app.Game.mSKGame.SKGameTask")
local SKGameChat                    = import("src.app.Game.mSKGame.SKGameChat")
local SKGameRule                    = import("src.app.Game.mSKGame.SKGameRule")

local windowSize = cc.Director:getInstance():getWinSize()

function SKGameScene:ctor(app, name)   
    
    self._SKOpeBtnManager           = nil

    self._SKChatBtn                 = nil
    self._SKMissionBtn              = nil
    
    self._SKHandCardsManager        = nil
    self._SKThrownCardsManager      = nil
    
    self._resultLayer               = nil

    self._SKThrownAnimation         = {}
    self._SKThrownAnimationCsbPath  = {}

    self._SKGameTask                = nil
    self._SKGameShare               = nil
    self._SKGameRule                = nil
    
    SKGameScene.super.ctor(self, app, name)
end

function SKGameScene:init()
    SKGameScene.super.init(self)
end

function SKGameScene:onEnter()
    SKGameScene.super.onEnter(self)

    audio.stopMusic("res/Hall/Sounds/HallBG.ogg")
end

function SKGameScene:onExit()
    SKGameScene.super.onExit(self)
end

function SKGameScene:setControllerDelegate()
    if not SKGameController then printError("SKGameController is nil!!!") return end
    self._gameController = SKGameController
end

function SKGameScene:setTouched()
    if self._baseLayer then
        self._baseLayer:setTouchEnabled(true)

        local listener = function(eventType, x, y)
            if eventType == "began" then
                self:onTouchBegan(x, y)
                return true
            elseif eventType == "moved" then
                self:onTouchMoved(x, y)
                return false
            elseif eventType == "ended" then
                self:onTouchEnded(x, y)
                return false
            end
        end
        self._baseLayer:registerScriptTouchHandler(listener, false, -1, false)
    end
end

function SKGameScene:onTouchBegan(x, y)
    if self._gameController and self._gameController:isTouchEnable() then
        self._gameController:onTouchBegan(x, y)
    end
end

function SKGameScene:onTouchMoved(x, y)
    if self._gameController and self._gameController:isTouchEnable() then
        self._gameController:onTouchMoved(x, y)
    end
end

function SKGameScene:onTouchEnded(x, y)
    if self._gameController and self._gameController:isTouchEnable() then
        self._gameController:onTouchEnded(x, y)
    end
end

function SKGameScene:addGameNode()
    if not self._baseLayer then return end

    local gameLayer = self._baseLayer:getChildByTag(self.GameTags.GAMETAGS_GAMELAYER)
    if gameLayer then
        local csbPath = "res/GameCocosStudio/csb/GameScene.csb"
        self._gameNode = cc.CSLoader:createNode(csbPath)
        if self._gameNode then
            self._gameNode:setContentSize(cc.Director:getInstance():getVisibleSize())
            ccui.Helper:doLayout(self._gameNode)
            gameLayer:addChild(self._gameNode)

            my.presetAllButton(self._gameNode)
            cc.exports.zeroBezelNodeAutoAdapt(self._gameNode:getChildByName("Operate_Panel"))
            self:_decorateGameSceneNodeFunc_getChildByName(self._gameNode)
        end
    end

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

    self:createChartredRoom()
        
    self:setGameCtrlsAboveBaseGame()

    if self._gameController:isArenaPlayer() then
        self:setArenaInfo()
    end
end

function SKGameScene:setThrowAnimation()
    --TODO
end

function SKGameScene:setUpInfo()
--TODO
end

function SKGameScene:getThrowAnimation(dwType, cardsCount)
    if not dwType or dwType <= 0 then return end

    if self._SKThrownAnimation[dwType] and self._SKThrownAnimationCsbPath[dwType] then
        return self._SKThrownAnimation[dwType], self._SKThrownAnimationCsbPath[dwType]
    end
end

function SKGameScene:addSysInfoNode()
end

function SKGameScene:setClock()
    if not self._gameNode then return end

    local clockPanel = self._gameNode:getChildByName("Panel_clock_1")
    if clockPanel then
        self._clock = SKGameClock:create(clockPanel, self._gameController)
    end
end

function SKGameScene:setPlayers()
    if not self._gameNode then return end
    if not self._gameController then return end

    local players = {}
    for i = 1, self._gameController:getTableChairCount() do
        if i == 1 then
            local playerPanel = self._gameNode:getChildByName("Panel_Player" .. tostring(i))
            local playerNode = self._gameNode:getChildByName("Node_Player" .. tostring(i))
            if playerPanel then
                players[i] = SKGameSelfPlayer:create(playerPanel, playerNode, i, self._gameController)
            end
        else
            local playerPanel = self._gameNode:getChildByName("Panel_Player" .. tostring(i))
            local playerNode = self._gameNode:getChildByName("Node_Player" .. tostring(i))
            if playerPanel then
                players[i] = SKGamePlayer:create(playerPanel, playerNode, i, self._gameController)
            end
        end
    end

    self._playerManager = SKGamePlayerManager:create(players, self._gameController)
end

function SKGameScene:setChat()
    if not self._gameNode then return end

    local chatPanel = self._gameNode:getChildByName("Node_Chat")
    if chatPanel then
        self._chat = SKGameChat:create(chatPanel, self._gameController)
        self._chat:setVisible(false)
    end
end

function SKGameScene:setRuleBtn()
    if not self._gameNode then return end

    --[[local function onRule()
        print("onRule")
        self._gameController:playBtnPressedEffect()    
        self._gameController:onRule()
    end
    local buttonRight = self._gameNode:getChildByName("panel_btn_right")
    if buttonRight then
        local buttonRule = buttonRight:getChildByName("btn_rule")
        if buttonRule then
            buttonRule:addClickEventListener(onRule)
        end
    end--]]
    
end

function SKGameScene:setRule()
    if not self._gameNode then return end

    --[[local rulePanel = self._gameNode:getChildByName("Node_rule")
    if rulePanel then
        self._SKGameRule = SKGameRule:create(rulePanel, self._gameController)
    end--]]
end

function SKGameScene:setGameInfo()
    if not self._gameNode then return end

    local gameInfo = self._gameNode:getChildByName("panel_gameinfo")
    if gameInfo then
        self._gameInfo = SKGameInfo:create(gameInfo, self._gameController)
    end
end

function SKGameScene:setTools()         
        
    if not self._gameNode then return end
    local nodeTools = self._gameNode:getChildByName("Node_GameTools")
    local SKGameDef = import("src.app.Game.mSKGame.SKGameDef")
    nodeTools:setLocalZOrder(SKGameDef.SK_ZORDER_PLAYERINFO + 1000)

    --如果有补银用另外一个csb
    if self._gameController:isSupportAutoSupply() then
        nodeTools:removeAllChildren()
        local layerNode = cc.CSLoader:createNode("res/GameCocosStudio/csb/Node_GameTools_AutoSupply.csb")
        nodeTools:addChild(layerNode)
        local toolsPanel = layerNode:getChildByName("Panel_GameTools")
        if toolsPanel then
            self._tools = SKGameTools:create(toolsPanel, false, self._gameController)
        end
        return
    end

    local toolsPanel = nodeTools:getChildByName("Panel_GameTools")
    if toolsPanel then
        self._tools = SKGameTools:create(toolsPanel, false, self._gameController)
    end
end

function SKGameScene:setSelfInfo()
    if not self._gameNode then return end
    
    local NodeMatching = self._gameNode:getChildByName("Panel_Start"):getChildByName("Node_Matching")
    local NodeMatching2 = self._gameNode:getChildByName("Panel_Start"):getChildByName("Node_Matching2")
    self._gameNode:getChildByName("Node_AttentionWords"):setVisible(true)
    local selfInfoPanel = self._gameNode:getChildByName("Node_AttentionWords"):getChildByName("Panel_AttentionWords")
    local NodeCancelRobot = self._gameNode:getChildByName("Panel_Player1"):getChildByName("Node_CancelRobot")

    local NoBigger = self._gameNode:getChildByName("Panel_Player1"):getChildByName("Panel_AttentionWords")

    local DuiJiaShouPai = self._gameNode:getChildByName("Panel_Player1"):getChildByName("Node_Duijiashoupai")
    if selfInfoPanel then
        self._selfInfo = SKGameSelfInfo:create(selfInfoPanel, NodeMatching, NodeCancelRobot, NoBigger, DuiJiaShouPai, NodeMatching2)
    end
end

function SKGameScene:setSetting()
    if not self._gameNode then return end

    local settingPanel = self._gameNode:getChildByName("Node_Setting")
    if settingPanel then
        self._setting = SKGameSetting:create(settingPanel, self._gameController)
        SubViewHelper:adaptNodePluginToScreen(settingPanel, settingPanel:getChildByName("Panel_Shade"))
        self._setting:setVisible(false)
    end
end

function SKGameScene:setGameCtrlsAboveBaseGame()
    self:setSKCards()
    self:setOpeBtns()
    self:setOtherBtns()

    self:setGameCtrlsAboveSKGame()
end

function SKGameScene:setOtherBtns()
    if not self._gameNode then return end

    local panelChatBtn = self._gameNode:getChildByName("panel_btn_left")
    local chatBtn = panelChatBtn:getChildByName("btn_chat")
    if chatBtn then
        self._SKChatBtn = chatBtn
        local function onClickChatBtn()
            self:onClickChatBtn()
        end
        self._SKChatBtn:addClickEventListener(onClickChatBtn)
    end

    local panelMissionBtn = self._gameNode:getChildByName("panel_btn_right")
    local missionBtn = ccui.Helper:seekWidgetByName(panelMissionBtn, "btn_mission")
    if missionBtn then
        self._SKMissionBtn = missionBtn
        local function onClickMissionBtn()
            self:onClickMissionBtn()
        end
        self._SKMissionBtn:addClickEventListener(onClickMissionBtn)
    end
end

function SKGameScene:onClickChatBtn()
    
    --self._gameController:playDirectionAni(nil)
    self._gameController:playBtnPressedEffect()
    if self._chat then
        self._chat:showChat(true)
    end
end

function SKGameScene:onClickMissionBtn()
    self._gameController:playBtnPressedEffect()
    if SKGameTask then
        self._SKGameTask = SKGameTask:create(self._gameController)
        SubViewHelper:adaptNodePluginToScreen(self._SKGameTask, self._SKGameTask:getChildByName("Panel_Shade"))
    end
    self:showTaskAnimation(false)
end

function SKGameScene:showTaskAnimation(bShow)
    local panelMissionBtn = self._gameNode:getChildByName("panel_btn_right")
    --[[local nodeAnimation = panelMissionBtn:getChildByName("Node_light_mission")
    if nodeAnimation then
        nodeAnimation:setVisible(bShow)
        if bShow then
            local csbPath = "res/GameCocosStudio/csb/game_scene_animation/Node_light.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                nodeAnimation:runAction(action)
                action:gotoFrameAndPlay(1, 20, true)
            end
        end
    end--]]	
end

function SKGameScene:setOpeBtns()
    if not self._gameNode then return end
    
    local opeBtns = self._gameNode:getChildByName("panel_operationbtn")
    if opeBtns then
        self._SKOpeBtnManager = SKOpeBtnManager:create(opeBtns, self._gameController)
    end
end

function SKGameScene:setSKCards()
    UIHelper:recordRuntime("EnterGameScene", "SKGameScene:setSKCards begin")
    self:setHandCards()
    self:setThrownCards()
    UIHelper:recordRuntime("EnterGameScene", "SKGameScene:setSKCards end")
end

function SKGameScene:setHandCards()
    local handCards = {}
    for i = 1, self._gameController:getTableChairCount() do
        if (i == self._gameController:getMyDrawIndex()) then
            handCards[i] = SKHandCards:create(i, self._gameController)
        else
            handCards[i] = SKShownCards:create(i, self._gameController)
        end
    end

    self._SKHandCardsManager = SKHandCardsManager:create(handCards, self._gameController)
end

function SKGameScene:setThrownCards()
    local thrownCards = {}
    for i = 1, self._gameController:getTableChairCount() do
        thrownCards[i] = SKThrownCards:create(i, self._gameController)
    end

    self._SKThrownCardsManager = SKThrownCardsManager:create(thrownCards, self._gameController)
end

function SKGameScene:setGameCtrlsAboveSKGame() end

function SKGameScene:createResultLayer(gameWin)
    self._resultLayer = CanvasLayer:create(cc.c4b(0, 0, 0, 127), windowSize.width, windowSize.height)
    if self._resultLayer then
        self:addChild(self._resultLayer, 100)
        self:addResultNode(gameWin)
    end
end

function SKGameScene:addResultNode(gameWin)
    if not self._resultLayer then return end

    self._resultNode = SKGameResultPanel:create(gameWin, self._gameController)
    if self._resultNode then
        self._resultLayer:addChild(self._resultNode)
        self._resultNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
    end
end

function SKGameScene:addContinualWinInfo(ContinualWinInfo)
    if self._resultNode then
        self._resultNode:createContinualWinEffect(ContinualWinInfo.nContinualWinCount)
    end
end

function SKGameScene:showResultLayer(gameWin)
    self:closeResultLayer()

    local resultLayer = self:getResultLayer()
    if not resultLayer then
        self:createResultLayer(gameWin)
    end
end

function SKGameScene:closeResultLayer()
    if self._resultLayer then
        self._resultLayer:removeSelf()
        self._resultLayer = nil
    end
end

function SKGameScene:getSKOpeBtnManager()           return self._SKOpeBtnManager            end
function SKGameScene:getSKHandCardsManager()        return self._SKHandCardsManager         end
function SKGameScene:getSKThrownCardsManager()      return self._SKThrownCardsManager       end
function SKGameScene:getResultLayer()               return self._resultLayer                end
function SKGameScene:getGameTask()                  return self._SKGameTask                 end
function SKGameScene:getGameShare()                 return self._SKGameShare                end
function SKGameScene:getGameRule()                      return self._SKGameRule                       end

return SKGameScene