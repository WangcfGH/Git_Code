
local MyJiSuSetCardCtrl = class("MyJiSuSetCardCtrl")
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")
local MyJiSuSetCard = import("src.app.Game.mMyJiSuGame.MyJiSuSetCard")
local MyJiSuCalculator = import("src.app.Game.mMyJiSuGame.MyJiSuCalculator")

local DunCardCounts = {
    MyJiSuGameDef.FIRST_DUN_CARD_COUNT,
    MyJiSuGameDef.SECOND_DUN_CARD_COUNT,
    MyJiSuGameDef.THIRD_DUN_CARD_COUNT,
}

function MyJiSuSetCardCtrl:create(panelSetCard, gameController)
    return MyJiSuSetCardCtrl.new(panelSetCard, gameController)
end

function MyJiSuSetCardCtrl:ctor(panelSetCard, gameController)
    self._gameController        = gameController
    self._panelSetCard          = panelSetCard

    self._DunUniteTypes         = {} --用于存储每一墩牌的牌型，每次reset、setcard时设置
    self._bClickConfirm         = false

    self:init()
end

function MyJiSuSetCardCtrl:init()
    print("MyJiSuSetCardCtrl:init")
    if not self._panelSetCard then return end
    
    local panel = self._panelSetCard
    self._txtTip = nil
    if self._gameController and self._gameController._baseGameScene and self._gameController._baseGameScene._gameNode then
        self._txtTip = self._gameController._baseGameScene._gameNode:getChildByName("Panel_BoutInfo"):getChildByName("Text_Tip")   
    end
    self._panelOpe = panel:getChildByName("Panel_Operate")
    if self._panelOpe then
        self._btnResetAll = self._panelOpe:getChildByName("Btn_Reset")
        self._btnConfirm = self._panelOpe:getChildByName("Btn_Confirm")
    end
    self._panelDuns = {}
    self._txtDunDescs = {}
    self._imgHighlights = {}
    self._btnResets = {} --每一墩中的重置按钮
    self._dunCards = {}

    for i = 1, 3 do
        self._panelDuns[i] = panel:getChildByName("Panel_Dun" .. i)
        if self._panelDuns[i] then
            self._txtDunDescs[i] = self._panelDuns[i]:getChildByName("Text_DunDesc")
            self._imgHighlights[i] = self._panelDuns[i]:getChildByName("Img_Highlight")
            self._btnResets[i] = self._panelDuns[i]:getChildByName("Btn_Reset")
        end
        self._dunCards[i] = {}
        for j = 1, DunCardCounts[i] do
            local nodeCard = self._panelDuns[i]:getChildByName("Node_Card" .. j)
            self._dunCards[i][j] = MyJiSuSetCard:create(nodeCard, self, j)
        end
        assert(DunCardCounts[i] == #self._dunCards[i])
    end

    self:initBtn()
    self:resetAllDun()

    self:setVisible(false)
    if self._txtTip then        
        self._txtTip:setVisible(false)
    end
end

function MyJiSuSetCardCtrl:initBtn(visible)
    print("MyJiSuSetCardCtrl:initBtn")
    if self._btnResetAll then
        self._btnResetAll:addClickEventListener(function ()
            self._gameController:playBtnPressedEffect()
            self:resetAllDun()
        end)
    end
    if self._btnConfirm then
        self._btnConfirm:addClickEventListener(function ()
            self._gameController:playBtnPressedEffect()
            self:clickConfirm()
        end)
    end
    for i = 1, 3 do
        if self._btnResets[i] then
            self._btnResets[i]:addClickEventListener(function ()
                self._gameController:playBtnPressedEffect()
                self:resetDun(i)
            end)
        end
        if self._panelDuns[i] then
            self._panelDuns[i]:addClickEventListener(function ()
                self._gameController:playBtnPressedEffect()
                self:selectDun(i)
            end)
        end
    end
end

function MyJiSuSetCardCtrl:setVisible(visible)
    if self._panelSetCard then
        self._panelSetCard:setVisible(visible)
    end
    if self._txtTip then
        self._txtTip:setVisible(visible)
    end
end

--是否已经点击过确认，用于托管
function MyJiSuSetCardCtrl:isClickedConfirm()
    return self._bClickConfirm
end

function MyJiSuSetCardCtrl:setStatusReady()
    print("setStatusReady")
    self._bClickConfirm = true

    --各墩状态设置
    for i = 1, 3 do
        self:showDunBright(index, false)
        self:setDunEnable(index, false)
        self:setResetEnable(i, false)
    end
    --全部重置、确认按钮置灰不可点
    if self._btnResetAll then
        self._btnResetAll:setTouchEnabled(false)
        self._btnResetAll:setBright(false)
    end
    if self._btnConfirm then
        self._btnConfirm:setTouchEnabled(false)
        self._btnConfirm:setBright(false)
    end
    --设置理牌中文字
    if self._txtTip then
        self._txtTip:setString("准备...")
    end
end

function MyJiSuSetCardCtrl:clickConfirm()
    self:setStatusReady()
    --发送确认理牌消息
    self._gameController:clickSetCardConfirm(self._DunUniteTypes)
end

function MyJiSuSetCardCtrl:resetAllDunCards()
    for i = 1, 3 do
        self:resetDunCards(i)
    end
end

function MyJiSuSetCardCtrl:resetDunCards(index)
    --牌重置
    for i = 1, DunCardCounts[index] do
        if self._dunCards and self._dunCards[index] then
            self._dunCards[index][i]:resetCard()
        end
    end
    self._DunUniteTypes[index] = nil
end

function MyJiSuSetCardCtrl:resetDun(index)
    local cardIDs = self:getCardIDs(index)
    self._gameController:resetDunCards(cardIDs)
    self:resetDunCards(index)

    --背景取消高亮
    self:showDunBright(index, false)

    --panel不可点击
    self:setDunEnable(index, false)
    
    --确定和全部重置按钮隐藏
    self:showPanelOpe(false)

    self._DunUniteTypes[index] = nil
end

--设置墩背景是否高亮
function MyJiSuSetCardCtrl:showDunBright(index, bShow)
    if self._imgHighlights and self._imgHighlights[index] then
        self._imgHighlights[index]:setVisible(bShow)
    end
end

--设置墩panel是否可点击
function MyJiSuSetCardCtrl:setDunEnable(index, bEnable)
    if self._panelDuns and self._panelDuns[index] then
        self._panelDuns[index]:setTouchEnabled(bEnable)
    end
end 

--设置×是否可点击
function MyJiSuSetCardCtrl:setResetEnable(index, bEnable)
    if self._btnResets and self._btnResets[index] then
        self._btnResets[index]:setTouchEnabled(bEnable)
        self._btnResets[index]:setBright(bEnable)
    end
end

--设置确认和全部重置按钮显隐
function MyJiSuSetCardCtrl:showPanelOpe(bShow)
    if self._panelOpe then
        self._panelOpe:setVisible(bShow)
    end
end

function MyJiSuSetCardCtrl:resetAllDun()
    for i = 1, 3 do
        self:resetDun(i)
    end
end

function MyJiSuSetCardCtrl:onGameStart()
    print("MyJiSuSetCardCtrl:onGameStart")
    self:setVisible(true)
    if self._txtTip then
        self._txtTip:setVisible(true)
    end
    self:resetAllDun() --重置墩上的牌张

    --设置理牌中文字
    if self._txtTip then
        self._txtTip:setString("理牌中...")
    end
    
    if self._btnResetAll then
        self._btnResetAll:setTouchEnabled(true)
        self._btnResetAll:setBright(true)
    end
    if self._btnConfirm then
        self._btnConfirm:setTouchEnabled(true)
        self._btnConfirm:setBright(true)
    end

    self._bClickConfirm = false
end

--断线续玩，理了一半的牌不再重置
function MyJiSuSetCardCtrl:onDXXWnotReset()
    self:setVisible(true)
    if self._txtTip then
        self._txtTip:setVisible(true)
    end
    --设置理牌中文字
    if self._txtTip then
        self._txtTip:setString("理牌中...")
    end
    
    if self._btnResetAll then
        self._btnResetAll:setTouchEnabled(true)
        self._btnResetAll:setBright(true)
    end
    if self._btnConfirm then
        self._btnConfirm:setTouchEnabled(true)
        self._btnConfirm:setBright(true)
    end

    self._bClickConfirm = false
end


function MyJiSuSetCardCtrl:getCardIDs(index)
    local tab = {}
    for i = 1, DunCardCounts[index] do
        if self._dunCards and self._dunCards[index] then
            local id = self._dunCards[index][i]:getSKID()
            if type(id) == 'number' and id ~= -1 then
                table.insert(tab, id)
            end
        end
    end
    return tab
end

--获取所有牌id，{{},{},{}}
function MyJiSuSetCardCtrl:getAllCardIDs()
    local tab = {}
    for i = 1,3 do 
        table.insert(tab, self:getCardIDs(i))
    end
    return tab
end

--点击手牌后，setcardctrl做相应的处理
function MyJiSuSetCardCtrl:onSelectHandCard(result)
    if self._bClickConfirm then return end
    for index, bShow in pairs(result) do
        self:showDunBright(index, bShow)
        self:setDunEnable(index, bShow)
        self:setResetEnable(index, not bShow)
    end
end

--点击高亮的panel的处理函数
function MyJiSuSetCardCtrl:selectDun(index)
    self._gameController:onClickDun(index)
end

--判断是否点击了高亮的panel
function MyJiSuSetCardCtrl:isClickPanel(x, y)
    for i = 1, 3 do
        local panel = (self._panelDuns or {})[i]
        if panel then
            local pos = cc.p(panel:getPosition())
            local ppos = panel:getParent():convertToWorldSpace(pos)
            local node = self._gameController._baseGameScene._gameNode:getChildByName("Operate_Panel")
            local position = node:convertToNodeSpace(ppos)
            local s = panel:getBoundingBox()
            local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
            local bResult = cc.rectContainsPoint(touchRect, cc.p(x, y))
            
            if bResult then
                return true, i
            end
        end
    end
    return false
end

function MyJiSuSetCardCtrl:isPanelEnable(index)
    local panel = (self._panelDuns or {})[index]
    if panel then
        return panel:isTouchEnabled()
    end
    return false
end

function MyJiSuSetCardCtrl:RUL_SortCard(nCardID)
    local function comps(a,b)
        if a ~= -1 and b~=-1 then
            local aSortValue = MyJiSuCalculator:getSortValue(a, self._gameController._baseGameUtilsInfoManager:getCurrentRank())
            local bSortValue = MyJiSuCalculator:getSortValue(b, self._gameController._baseGameUtilsInfoManager:getCurrentRank())
            return aSortValue > bSortValue
        else
            return a > b
        end
    end

    table.sort(nCardID, comps)
end

function MyJiSuSetCardCtrl:getDunUniteTypes()
    return self._DunUniteTypes
end

--设置某墩的牌
function MyJiSuSetCardCtrl:setDunCardIDs(index, cardIDs, cardsCount)
    local cardIDsOrigin = self:getCardIDs(index)
    local countOrigin = #cardIDsOrigin
    local cardDest = clone(cardIDs)
    table.insertto(cardIDsOrigin, cardDest)
    
    if #cardIDsOrigin > DunCardCounts[index] then return end
    if #cardIDsOrigin == DunCardCounts[index] then --该墩已经设置好了，检验是否可行
        local uniteTypes = MyJiSuCalculator:getDunUniteType(cardIDsOrigin)
        self._DunUniteTypes[index] = uniteTypes 
        --检验是否所有牌墩按照 首<中<尾这样
        local bValid = MyJiSuCalculator:checkDunCardsValueValid(self._DunUniteTypes)
        if not bValid then 
            dump(self._DunUniteTypes, "checkDunCardsValueValid not valid")
            --弹出提示文字
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = "首中尾要从小到大排列哦~", removeTime=2}})
            self._gameController:resetDunCards(cardIDs)
            self:resetAllDun()
            self._DunUniteTypes[index] = nil
            return
        end
    end

    --排序下
    if countOrigin == 0 then
        self:RUL_SortCard(cardIDsOrigin)
    end

    for i = 1, #cardIDsOrigin do
        local card = ((self._dunCards or {})[index] or {})[i]
        if card and cardIDsOrigin[i] ~= -1 then
            card:setSKID(cardIDsOrigin[i])
        end
    end

    for i = 1, 3 do
        self:showDunBright(index, false)
        self:setDunEnable(index, false)
        self:setResetEnable(i, true)
    end
    
    self:checkAllCardSet()
end

--检测是否所有卡牌都已经设置
function MyJiSuSetCardCtrl:checkAllCardSet()
    local cardIDs = self:getAllCardIDs()

    local bFinish = true
    for i = 1, 3 do
        if #cardIDs[i] < DunCardCounts[i] then
            bFinish = false
        end
    end
    if self._panelOpe then
        self._panelOpe:setVisible(bFinish)
    end
end

return MyJiSuSetCardCtrl
