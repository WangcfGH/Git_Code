
local MyJiSuBottomBarCtrl = class("MyJiSuBottomBarCtrl")
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")
local MyJiSuCalculator = import("src.app.Game.mMyJiSuGame.MyJiSuCalculator")

local CardTypes = {
    MyJiSuGameDef.SK_CARD_UNITE_TYPE_4KING,
    MyJiSuGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB,
    MyJiSuGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN,
    MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB, --这两个单独处理下 5炸
    MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB, --这两个单独处理下 4炸
    MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE,
    MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_THREE,
    MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE,
}

function MyJiSuBottomBarCtrl:create(panelBottomBar, gameController)
    return MyJiSuBottomBarCtrl.new(panelBottomBar, gameController)
end

function MyJiSuBottomBarCtrl:ctor(panelBottomBar, gameController)
    self._gameController        = gameController
    self._panelBottomBar          = panelBottomBar

    self._nUsingQuickOpe = 0
    self:init()
end

function MyJiSuBottomBarCtrl:init()
    if not self._panelBottomBar then return end
    
    local panel = self._panelBottomBar

    self._btnList = {}
    self._txtList = {}

    local btnNameList = {
        "四大天王",
        "超级炸弹",
        "同花顺",
        "五 炸",
        "四 炸",
        "三连对",
        "钢 板",
        "顺 子",
    }
    for i = 1,8 do
        self._btnList[i] = panel:getChildByName("Btn_Bottom" .. i)
        if self._btnList[i] then
            self._txtList[i] = self._btnList[i]:getChildByName("Text_Desc")
            self._txtList[i]:setString(btnNameList[i])
            self._btnList[i]:addClickEventListener(function ()
                self._gameController:playBtnPressedEffect()
                self._nUsingQuickOpe = 1
                local funcName = btnNameList[i]
                if funcName then
                    print("click ", funcName)
                    self:pickCards(i)
                end
            end)
        end
    end
    self:setAllBtnDisable()
    --self:setVisible(false)
end


function MyJiSuBottomBarCtrl:setVisible(visible)
    if self._panelBottomBar then
        self._panelBottomBar:setVisible(visible)
    end
end

--每次手牌更新后，刷新按钮状态
function MyJiSuBottomBarCtrl:refreshBtnStatus()
    local handCardManager = self._gameController._baseGameScene:getSKHandCardsManager()
    if not handCardManager then return end

    local myHandCards = handCardManager:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return nil end

    local inhandCards, cardsCount = myHandCards:getHandCardIDs()

    for i = 1, #CardTypes do
        local remindUniteType = MyJiSuCalculator:initUniteType()
        local remindCards = {}
        local bEnable = false
        if CardTypes[i] == MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB then
            local nBombCount = 4
            if i == 4 then
                nBombCount = 5
            else
                nBombCount = 4
            end
            bEnable = handCardManager:ope_BuildCardBomb(inhandCards, cardsCount, remindCards, cardsCount, remindUniteType, remindUniteType, CardTypes[i], true, nBombCount)
        else
            bEnable = handCardManager:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, remindUniteType, remindUniteType, CardTypes[i], true)
        end
        self:setBtnEnable(i, bEnable)
    end
end

function MyJiSuBottomBarCtrl:test( )
    local handCardManager = self._gameController._baseGameScene:getSKHandCardsManager()
    if not handCardManager then return end

    local myHandCards = handCardManager:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return nil end

    local inhandCards, inHandCardsCount = myHandCards:getHandCardIDs()

    local remindUniteType = MyJiSuCalculator:initUniteType()
    local remindCards = {}
    local lastRemindUniteType = nil
    MyJiSuCalculator:ope_BuildMaxCard(inhandCards, inHandCardsCount, remindCards, inHandCardsCount, remindUniteType, remindUniteType, MyJiSuGameDef.SK_CARD_UNITE_TYPE_TOTAL, true)
    handCardManager:ope_UnselectSelfCards() --注意上面的until中需要条件为false才继续执行循环
    myHandCards:selectCardsByIDs(remindCards, #remindCards)
    self._gameController:ope_CheckSelect()
end

function MyJiSuBottomBarCtrl:isSameCardUnite(leftUnite, rightUnite)
    if leftUnite.nCardsCount ~= rightUnite.nCardsCount then
        return false
    end
    for i = 1, leftUnite.nCardsCount do
        local bFind = false
        for j = 1, rightUnite.nCardsCount do
            if leftUnite.nCardIDs[i] == rightUnite.nCardIDs[j] then
                bFind = true
                break
            end
        end
        if not bFind then
            return false
        end
    end
    return true
end

function MyJiSuBottomBarCtrl:pickCards(index)
    --do self:test() return end
    local handCardManager = self._gameController._baseGameScene:getSKHandCardsManager()
    if not handCardManager then return end

    local myHandCards = handCardManager:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return nil end

    local inhandCards, inHandCardsCount = myHandCards:getHandCardIDs()
    local cardsSelect, selectCardsCount = handCardManager:getMySelectCardIDs()
    if not cardsSelect or inHandCardsCount <= 0 then return end

    local remindUniteType = MyJiSuCalculator:initUniteType()
    local remindCards = {}
    local lastRemindUniteType = nil
    --判断是重复点击还是第一次点击，找到最大的类型
    repeat
        local bReClick = handCardManager:ope_BuildCard(cardsSelect, selectCardsCount, remindCards, selectCardsCount, remindUniteType, remindUniteType, CardTypes[index], true)
        if not bReClick then
            if lastRemindUniteType then
                remindUniteType = lastRemindUniteType
            else
                remindUniteType = MyJiSuCalculator:initUniteType()
            end
            break
        else
            lastRemindUniteType = remindUniteType
        end
    until (false)

    local lastRemindUniteTypeList, lastOutCardsList = MyJiSuCalculator:getBiggestUniteTypeList(inhandCards, inHandCardsCount, CardTypes[index], true)
    if CardTypes[index] == MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB then
        local limitCount = nil
        if index == 4 then
            limitCount = 5
        else
            limitCount = 4
        end
        for i = #lastRemindUniteTypeList, 1, -1 do
            if lastRemindUniteTypeList[i].nCardsCount ~= limitCount then
                table.remove(lastRemindUniteTypeList, i)
                table.remove(lastOutCardsList, i)
            end
        end
    end
    if #lastRemindUniteTypeList > 0 then --存在该类型的牌
        local index = 1
        for i = #lastRemindUniteTypeList, 1, -1 do
            if self:isSameCardUnite(remindUniteType, lastRemindUniteTypeList[i]) then
                index = i
            end
        end
        local remindIndex = index - 1
        if index == 1 then
            remindIndex = #lastRemindUniteTypeList
        end
        MyJiSuCalculator:copyCardIDs(remindCards, lastOutCardsList[remindIndex])
    end

    handCardManager:ope_UnselectSelfCards() --注意上面的until中需要条件为false才继续执行循环
    myHandCards:selectCardsByIDs(remindCards, #remindCards)
    self._gameController:ope_CheckSelect()
end

--判断是否点击了按钮
function MyJiSuBottomBarCtrl:isClickBottomBtn(x, y)
    for i = 1,8 do
        local panel = (self._btnList or {})[i]
        if panel then
            local pos = cc.p(panel:getPosition())
            local ppos = panel:getParent():convertToWorldSpace(pos)
            local node = self._gameController._baseGameScene._gameNode:getChildByName("Operate_Panel")
            local position = node:convertToNodeSpace(ppos)
            local s = panel:getBoundingBox()
            local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
            local bResult = cc.rectContainsPoint(touchRect, cc.p(x, y))
            
            if bResult then
                return true
            end
        end
    end
    return false
end

function MyJiSuBottomBarCtrl:setBtnEnable(index, bEnable)
    if self._btnList and self._btnList[index] then
        self._btnList[index]:setTouchEnabled(bEnable)
        self._btnList[index]:setBright(bEnable)
    end

    if self._txtList and self._txtList[index] then
        local color = cc.c3b(255,255,255)
        local transparent = 255
        if not bEnable then
            color = cc.c3b(0,0,0)
            transparent = 120
        end
        self._txtList[index]:setColor(color)
        self._txtList[index]:setOpacity(transparent)
    end
end

function MyJiSuBottomBarCtrl:setAllBtnDisable()
    for i=1,8 do
        self:setBtnEnable(i, false)
    end
end

function MyJiSuBottomBarCtrl:resetUsingQuickOpe()
    self._nUsingQuickOpe = 0
end

function MyJiSuBottomBarCtrl:getUsingQuickOpe()
    return self._nUsingQuickOpe
end

return MyJiSuBottomBarCtrl
