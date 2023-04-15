local MyJiSuHandCards = class("MyJiSuHandCards", import("src.app.Game.mMyGame.MyHandCards"))
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")
local MyJiSuCardHand = import("src.app.Game.mMyJiSuGame.MyJiSuCardHand")

function MyJiSuHandCards:getSelfHandCardsPosition(index)
    local XStartPos = MyJiSuGameDef.SK_CARD_START_POS_X
    local startX, startY = XStartPos, MyJiSuGameDef.SK_CARD_START_POS_Y       --左下起点坐标

    if MyJiSuGameDef.SK_CARD_PER_LINE >= self._cardsCount then          --一列
        local biggsetWidth = (MyJiSuGameDef.SK_CARD_PER_LINE - 1) * MyJiSuGameDef.SK_CARD_COLUMN_INTERVAL
        local interval = 0
        if 1 < self._cardsCount then
            interval = --[[math.floor--]](biggsetWidth / (self._cardsCount - 1))
        end
        if MyJiSuGameDef.SK_CARD_COLUMN_INTERVAL_MAX < interval then    --间隔足够大后两端缩进
            interval = MyJiSuGameDef.SK_CARD_COLUMN_INTERVAL_MAX
        end
        local width = interval * (self._cardsCount - 1)

        local xEx = 0
        if biggsetWidth > width then
            xEx = (biggsetWidth + self._cards[1]:getContentSize().width)/2 + startX - self._gameController:getCenterXOfOperatePanel()
        end

        startX = startX + --[[math.floor--]]((biggsetWidth - width) / 2)

        startX = startX - xEx

        if startX < XStartPos then
            startX = XStartPos
        end

        startX = startX + (index - 1) * interval
    else
        local localIndex = MyJiSuGameDef.SK_CARD_PER_LINE - (self._cardsCount - index) % MyJiSuGameDef.SK_CARD_PER_LINE - 1 --多列
        local lines = math.floor((self._cardsCount - index) / MyJiSuGameDef.SK_CARD_PER_LINE)
        if lines ~= 0 then
            localIndex = index - 1
        end
        startX = startX + localIndex * MyJiSuGameDef.SK_CARD_COLUMN_INTERVAL
        startY = startY + lines * MyJiSuGameDef.SK_CARD_LINE_INTERVAL
    end

    return cc.p(startX, startY)
end

function MyJiSuHandCards:init()
    --惯蛋添加begin
    self._FriendCardsCount = 0
    self._FriendCards            = {}
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    --惯蛋添加end

    self:_adaptCardStartPositionForHorizontal()
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = MyJiSuCardHand:create(self._drawIndex, self, i)
    end

    self:resetSKHandCards()
end

function MyJiSuHandCards:addDunCards(cardIDs)
    for _, cardID in pairs(cardIDs) do
        self:addHandCard(cardID)
    end
    self:sortHandCards()
    --self:updateHandCards()
end

function MyJiSuHandCards:removeHandCards(cardIDs, cardsCount)
    local count = 0
    for i = 1, cardsCount do
        local cardID = cardIDs[i]

        local card = self:getCardByID(cardID)
        if card then
            card:clearSKID()
            card:resetCardPos()
            count = count + 1
        end
    end

    self:cardsCountDecrease(count)
end

return MyJiSuHandCards