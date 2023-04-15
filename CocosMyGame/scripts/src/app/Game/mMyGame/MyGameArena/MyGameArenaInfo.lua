local BaseGameArenaInfo = import("src.app.Game.mBaseGame.BaseGameArena.BaseGameArenaInfo")
local MyGameArenaInfo   = class("MyGameArenaInfo", BaseGameArenaInfo)

local MyGameDef         = import("src.app.Game.mMyGame.MyGameDef")
local SKGameDef         = import("src.app.Game.mSKGame.SKGameDef")

function MyGameArenaInfo:ctor(arenaInfoLayer, gameController)
    MyGameArenaInfo.super.ctor(self, arenaInfoLayer, gameController)

    arenaInfoLayer:setLocalZOrder(SKGameDef.SK_ZORDER_ARENA_INFO)
end

function MyGameArenaInfo:init()
    MyGameArenaInfo.super.init(self)

    self._defaultString = {}

    self._arenaTypeAddScoreNode = self._arenaInfoLayer:getChildByName("Node_ArenaCardTypeScore")
    self._arenaTypeAddScore = self._arenaTypeAddScoreNode:getChildByName("Panel_CardType")
    self._arenaTypeAddScore:setVisible(false)
end

function MyGameArenaInfo:registEvents()
end 

function MyGameArenaInfo:runEnterAction()
end

function MyGameArenaInfo:runExitAction()
end 

function MyGameArenaInfo:setHP(initHP, leftHP)
    self._initHP = initHP
    self._leftHP = leftHP
    if self._arenaInfoHPPanel then
        for count = 1, initHP do 
            local HPNode = nil
            if count > leftHP then
                HPNode = self._arenaInfoHPPanel:getChildByName("Img_Love"..count):setVisible(false)
            else
                HPNode = self._arenaInfoHPPanel:getChildByName("Img_Love"..count):setVisible(true)
            end
            table.insert(self._HPNodes, HPNode)
        end
    end
end

function MyGameArenaInfo:loseHP(num)
    if self._leftHP == 0 or type(num) ~= 'number' then return end--or num < 1 then return end
    for count = self._leftHP-num+1, self._leftHP do
        local HPNode = self._HPNodes[count] 
        if HPNode then
            HPNode:setVisible(false)
        end
    end
    self._leftHP = self._leftHP-num
end

function MyGameArenaInfo:addArenaScore(addScore, nType)
    if self._arenaInfoArenaScore then
        local newScore = tonumber(self._arenaInfoArenaScore:getString()) + addScore
        self._arenaInfoArenaScore:setString(tostring(newScore))
    end
    self:showArenaScoreTypeAni(nType, addScore)
end

function MyGameArenaInfo:showArenaScoreTypeAni(nType, addScore)
    self._arenaTypeAddScore:setVisible(true)

    local itemChildren = self._arenaTypeAddScore:getChildren()
    for i = 1, self._arenaTypeAddScore:getChildrenCount() do
        local child = itemChildren[i]
        if child then
            child:setVisible(false)
        end
    end

    local showNodeName = nil
    if nType == MyGameDef.kArenaScoreTypeTongHua then
        showNodeName = "Img_Tonghuashun"
    elseif nType == MyGameDef.kArenaScoreTypeSuperBomb then
        showNodeName = "Img_SuperBomb"
    elseif nType == MyGameDef.kArenaScoreType4Kin then
        showNodeName = "Img_Rocket"
    elseif nType == MyGameDef.kArenaScoreTypeAbtSingle then
        showNodeName = "Img_ShunZi"
    elseif nType == MyGameDef.kArenaScoreTypeAbtCouple then
        showNodeName = "Img_LianDui"
    elseif nType == MyGameDef.kArenaScoreTypeAbtThree then
        showNodeName = "Img_LianSanZhang"
    elseif nType == MyGameDef.kArenaScoreTypeSuppress then
        showNodeName = "Img_Suppress"
    elseif nType == MyGameDef.kArenaScoreTypeBomb then
        showNodeName = "Img_Bomb"
    end
    if showNodeName == nil then
        return
    end

    local showNode = self._arenaTypeAddScore:getChildByName(showNodeName)

    if  self._defaultString[showNodeName] == nil then
        self._defaultString[showNodeName] = showNode:getString()
    end

    showNode:setVisible(true)
    showNode:setString( string.format(self._defaultString[showNodeName], addScore))
    
    local csbPath = "res/GameCocosStudio/csb/card_animation/Node_ArenaCardTypeScore.csb"
    local action = cc.CSLoader:createTimeline(csbPath)
    self._arenaTypeAddScoreNode:runAction(action)
    local function onFrameEvent(frame)
        if frame then 
            local event = frame:getEvent()
            if "Play_Over" == event then
                self._arenaTypeAddScore:setVisible(false)
            end
        end
    end
    action:play("animation0", false)
    action:setFrameEventCallFunc(onFrameEvent)
end

return MyGameArenaInfo
