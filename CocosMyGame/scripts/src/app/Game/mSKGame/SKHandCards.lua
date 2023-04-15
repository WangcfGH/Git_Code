
local SKHandCards = class("SKHandCards")

local SKCardHand                = import("src.app.Game.mSKGame.SKCardHand")
local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

--local SKCalculator              = import("src.app.Game.mSKGame.SKCalculator")  --惯蛋修改
local SKCalculator              = import("src.app.Game.mMyGame.MyCalculator")

local GamePublicInterface       = import("src.app.Game.mMyGame.GamePublicInterface")

function SKHandCards:create(drawIndex, gameController)
    return SKHandCards.new(drawIndex, gameController)
end

function SKHandCards:ctor(drawIndex, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._drawIndex             = drawIndex
    self._cards                 = {}
    self._cardsCount            = 0

    self._touchBeganIndex       = 0
    self._touchMovedIndex       = 0

    self._nEndIndexEx           = -1
    self._nArrageUnite          = {}
    for i = 1, self._gameController:getChairCardsCount() do
        self._nArrageUnite[i] = {}
    end
    self.nArrageCount = 1

    self:XygInitArrageUnite()

    self:init()
end

function SKHandCards:init()
    --惯蛋添加begin
    self._FriendCardsCount = 0
    self._FriendCards            = {}
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    --惯蛋添加end
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = SKCardHand:create(self._drawIndex, self, i)
    end

    self:resetSKHandCards()
end

function SKHandCards:getMyDrawIndex()
    return self._gameController:getMyDrawIndex()
end

function SKHandCards:resetSKHandCards()
    --惯蛋添加begin
    self.bNeedResetArrageNo = true
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        self._cardsCount = 0
        self._gameController:setCardsCount(self._drawIndex, self._cardsCount, false)
        return
    end
    --惯蛋添加end
    if not self._cards then return end

    self._nEndIndexEx           = -1
    self:XygInitArrageUnite()

    for i = 1, self._gameController:getChairCardsCount() do
        local card = self._cards[i]
        if card then
            card:resetCard()
        end
    end

    self._cardsCount = 0
    self._gameController:setCardsCount(self._drawIndex, self._cardsCount, false)
end

function SKHandCards:getSKCardHand(index)
    return self._cards[index]
end

function SKHandCards:setVisible(visible)
    if not self._cards then return end

    for i = 1, self._gameController:getChairCardsCount() do
        local card = self._cards[i]
        if card then
            card:setVisible(visible)
        end
    end
end

function SKHandCards:onDealCard(dealCounts)
    if not self._cards then return end

    self._gameController:setCardsCount(self._drawIndex, dealCounts, false)

    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end

    local card = self._cards[dealCounts]
    if card then
        card:dealCard()
    end

    self._cards[dealCounts]:setPositionNoAciton(self:getHandCardsPosition(dealCounts))        

    --[[for i = 1, dealCounts do
        if self._cards[i] then
            --self._cards[i]:setPosition(self:getHandCardsPosition(i))
            --惯蛋添加
            self._cards[i]:setPositionNoAciton(self:getHandCardsPosition(i))        
        end
    end--]]
end

function SKHandCards:setEnableTouch(enableTouch)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and self._cards[i]:isVisible() then
            self._cards[i]:setEnableTouch(enableTouch)
        end
    end
end

function SKHandCards:sortHandCards()
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    
    self.bNeedResetArrageNo = true

    self.nArrageCount = 1
    self:XygInitArrageUnite()
    for k = 1 , self._gameController:getChairCardsCount() do     
        self._cards[k]._ArrageNo = 0
        self._cards[k]._bArraged = false
        self._cards[k]._bBomb = false
    end

    local nArrageCard = {}
    SKCalculator:xygInitChairCards(nArrageCard, self._gameController:getChairCardsCount())
    local count1 = self:RUL_GetInHandArrageCards(nArrageCard)
    local CardID = {}
    local count2 = self:RUL_GetInHandNoArrageCards(CardID)

    local nBestUnite = nil

	local sortFlag = self._gameController:GetSortCardFlag()
    if sortFlag == SKGameDef.SORT_CARD_BY_ORDER then
        --self:sortHandCardsByOrder(CardID)
        self:RUL_SortCard(CardID)
    elseif sortFlag == SKGameDef.SORT_CARD_BY_NUM then
        --self:sortHandCardsByOrder()
        --self:sortHandCardsByNum()
        self:RUL_SortCardByCardsNum(CardID)
    elseif sortFlag == SKGameDef.SORT_CARD_BY_SHPAE then
        self:sortHandCardsByShape(CardID)
    elseif sortFlag == SKGameDef.SORT_CARD_BY_BOME then
        nBestUnite = self:sortHandCardsByBome(CardID, count2)
    end

    
    self:XygAddCardIDs(nArrageCard, CardID, self._gameController:getChairCardsCount())

    local cardPoint = {}
    for i = 1, self._gameController:getChairCardsCount() do
        if nArrageCard[i] ~= -1 then
            for j=1, self._gameController:getChairCardsCount() do
                if nArrageCard[i] == self._cards[j]:getSKID() then               
                    table.insert(cardPoint, i, self._cards[j]._pPoint)
                    break
                end
            end
        else
            table.insert(cardPoint, i, self._cards[i]._pPoint)
        end
    end

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(nArrageCard[i])
            self._cards[i]:setPositionNoAciton(cardPoint[i])
            self:resetOneCardPos(i)
            count = count + 1
        end
    end

    if sortFlag == SKGameDef.SORT_CARD_BY_BOME and nBestUnite then
        self:OPE_SetBombUnite(nBestUnite)
        self:OPE_MaskCardForArrage()      
    end

    self._gameController:ResetArrageButton()

    self._gameController:ope_CheckSelect()
end

function SKHandCards:sortHandCardsByNum()
    local bPicked = {}
    for k = 1, self._cardsCount do
        bPicked[k] = false
    end
    local j = 1
    local outCardIDs = {}
    for i = 12, 1, -1 do  --4 players 3 packs cards
        for k = 1, self._cardsCount do
            if self._cards[k]._SKID < 0 or bPicked[k] then
            else
                local nTempSameCount = self:GetSameCount(self._cards[k]._SKID)
                if i == nTempSameCount then
                    for m=1, nTempSameCount do
                        bPicked[k] = true
                        outCardIDs[j] = self._cards[k]._SKID
                        j = j + 1
                        k = k + 1
                    end
                    k = k - 1
                end
            end
    end
    end

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(outCardIDs[i])
            self:resetOneCardPos(i)
            count = count + 1
        end
    end
end

function SKHandCards:GetSameCount(nCardID)
    local nSameCount = 0
    if nCardID < 0 then
        return
    end

    local maxCardValue = 13
    local temp = maxCardValue * 3
    local nValue = (nCardID % temp) % maxCardValue
    local nShape = nCardID / temp
    for i = 1, self._cardsCount do
        if self._cards[i]._SKID > -1 then
            local nTempValue = (self._cards[i]._SKID % temp) % maxCardValue
            local nTempShape = self._cards[i]._SKID / temp

            if nTempShape >= 4 then
                if nShape >= 4 then
                    nSameCount = nSameCount + 1
                end
            else
                if nShape < 4 then
                    if nValue == nTempValue then
                        nSameCount = nSameCount + 1
                    end
                end
            end
        end
    end

    return nSameCount
end

function SKHandCards:sortHandCardsByOrder(CardID)
    if not self:isCardsFaceShow() then return end

    local tableCards = {}
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCards, i, self._cards[i])
    end

    local function comps(a, b)
        --惯蛋添加
        if a:getPriIndex()  == b:getPriIndex()  then
            return a:getSKID() > b:getSKID()
        end
        return a:getPriIndex() > b:getPriIndex() 
    end
    table.sort(tableCards, comps)

    local tableCardIDs = {}

    local cardPoint = {}
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCardIDs, i, tableCards[i]:getSKID())
        table.insert(cardPoint, i, tableCards[i]._pPoint)
    end

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(tableCardIDs[i])
            self._cards[i]:setPositionNoAciton(cardPoint[i])
            self:resetOneCardPos(i)
            count = count + 1
        end
    end
end

function SKHandCards:getHandCardsPosition(index)
    if self._drawIndex == self:getMyDrawIndex() then
        return self:getSelfHandCardsPosition(index)
    else
        return self:getOtherHandCardsPosition(index)
    end
end

function SKHandCards:getSelfHandCardsPosition(index)
    local XStartPos = SKGameDef.SK_CARD_START_POS_X
    local startX, startY = XStartPos, SKGameDef.SK_CARD_START_POS_Y       --左下起点坐标

    if SKGameDef.SK_CARD_PER_LINE >= self._cardsCount then          --一列
        local biggsetWidth = (SKGameDef.SK_CARD_PER_LINE - 1) * SKGameDef.SK_CARD_COLUMN_INTERVAL
        local interval = 0
        if 1 < self._cardsCount then
            interval = --[[math.floor--]](biggsetWidth / (self._cardsCount - 1))
        end
        if SKGameDef.SK_CARD_COLUMN_INTERVAL_MAX < interval then    --间隔足够大后两端缩进
            interval = SKGameDef.SK_CARD_COLUMN_INTERVAL_MAX
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
        local localIndex = SKGameDef.SK_CARD_PER_LINE - (self._cardsCount - index) % SKGameDef.SK_CARD_PER_LINE - 1 --多列
        local lines = math.floor((self._cardsCount - index) / SKGameDef.SK_CARD_PER_LINE)
        if lines ~= 0 then
            localIndex = index - 1
        end
        startX = startX + localIndex * SKGameDef.SK_CARD_COLUMN_INTERVAL
        startY = startY + lines * SKGameDef.SK_CARD_LINE_INTERVAL
    end

    return cc.p(startX, startY)
end

function SKHandCards:getOtherHandCardsPosition(index)
    return cc.p(0, 0)
end

function SKHandCards:setHandCardsCount(cardsCount)
    self._cardsCount = cardsCount
end

function SKHandCards:setHandCards(handCards)
    for i = 1, self._cardsCount do
        if not self._cards[i] or not handCards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setSKID(handCards[i])
        self._cards[i]:setPosition(self:getHandCardsPosition(i))
    end
end

function SKHandCards:hideHandCards()
    for i = 1, self._cardsCount do
        if not self._cards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setVisible(false)
    end
end

function SKHandCards:getSelectCardIDs()
    local selectCardIDs = {}
    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i]
        and self._cards[i]:isVisible()
        and self._cards[i]:isValidateID(self._cards[i]:getSKID())
                and self._cards[i]:isValidateID(self._cards[i]:getSKID()) then
            if self._cards[i]:isSelectCard() then
                --self:resetOneCardPos(i) --惯蛋为了能散牌 需要注释
                --self._cards[i]:selectCard() --惯蛋为了能散牌 需要注释
                count = count + 1
                selectCardIDs[count] = self._cards[i]:getSKID()
            else
                --self:resetOneCardPos(i) --惯蛋为了能散牌 需要注释
            end
        end
    end
    return selectCardIDs, count
end

function SKHandCards:getHandCardIDs()
    local handCardIDs = {}
    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and self._cards[i]:isVisible() and self._cards[i]:isValidateID(self._cards[i]:getSKID()) then
            count = count + 1
            handCardIDs[count] = self._cards[i]:getSKID()
        end
    end
    return handCardIDs, count
end

function SKHandCards:getHandCardsCount()
    return self._cardsCount
end

function SKHandCards:ope_ThrowCards(cardIDs, cardsCount)
    self._nEndIndexEx           = -1
    self._ThrowCards            = true
    self:removeHandCards(cardIDs, cardsCount)
    if self._drawIndex ~= self:getMyDrawIndex() then
        self._ThrowCards            = false
        return
    end
    self:OPE_SetUniteWhenThrow(cardIDs, cardsCount)
    --self:sortHandCards()
    --self:updateHandCards()
    if self._cardsCount <= 0 and self._FriendCardsCount > 0 then
        self._ThrowCards            = false
        return
    end
    self:ThrowEndSort()
    self._ThrowCards            = false
end

function SKHandCards:getCardByID(id)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and self._cards[i]:getSKID() == id then
            return self._cards[i]
        end
    end

    return nil
end

function SKHandCards:removeHandCards(cardIDs, cardsCount)
    for i = 1, cardsCount do
        local cardID = cardIDs[i]

        local card = self:getCardByID(cardID)
        if card then
            card:clearSKID()
            card:resetCardPos()
        end
    end

    self:cardsCountDecrease(cardsCount)
end

function SKHandCards:moveHandCards(bMoveOut)
end

function SKHandCards:isCardsFaceShow()
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and self._cards[i]:isVisible() then
            return true
        end
    end

    return false
end

function SKHandCards:cardsCountIncrease(cardsCount)
    self._cardsCount = math.min(self._cardsCount + cardsCount, self._gameController:getChairCardsCount())

    self._gameController:setCardsCount(self._drawIndex, self._cardsCount, false)
end

function SKHandCards:cardsCountDecrease(cardsCount)
    self._cardsCount = math.max(self._cardsCount - cardsCount, 0)

    self._gameController:setCardsCount(self._drawIndex, self._cardsCount, true)
end

function SKHandCards:updateHandCards()
    if self:isCardsFaceShow() then
        for i = 1, self._gameController:getChairCardsCount() do
            local card = self._cards[i]
            if card and -1 == card:getSKID() then
                card:resetCard()
            end
        end
    else
        for i = 1, self._gameController:getChairCardsCount() do
            local card = self._cards[i]
            if card then
                card:resetCard()
            end
        end
    end

    for i = 1, self._cardsCount do
        local card = self._cards[i]
        if card then
            card:setVisible(true)
        end
    end
end

function SKHandCards:unSelectCards()
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            self._cards[i]:unSelectCard()
            self._cards[i]:initSelState()
        end
    end
end

function SKHandCards:selectCardsByIDs(cardsID, cardsCount)
    if not cardsCount or not cardsID then return end

    for i = 1, cardsCount do
        if cardsID[i] and cardsID[i] ~= SKGameDef.SK_INVALID_OBJECT_ID then
            for j = 1, self._gameController:getChairCardsCount() do
                if self._cards[j] and self._cards[j]:getSKID() == cardsID[i] then
                    self._cards[j]:selectCard()
                end
            end
        end
    end
end

function SKHandCards:selectCardsByIndex(index)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and SKCalculator:isValidCard(self._cards[i]:getSKID()) then
            local gameFlags = GamePublicInterface:getGameFlags()
            local cardIndex = SKCalculator:getCardIndex(self._cards[i]:getSKID(), gameFlags)
            if cardIndex == index then
                self._cards[i]:selectCard()
            end
        end
    end
end

function SKHandCards:resetCardsPos()
    self._nEndIndexEx           = -1
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            self._cards[i]:setPosition(self:getHandCardsPosition(i))
            --惯蛋添加
            --[[self._cards[i]._SKCardSprite:stopAllActions()
            local ActionMove = cc.MoveTo:create(0.2,self:getHandCardsPosition(i))
            self._cards[i]._SKCardSprite:runAction(ActionMove)--]]
        end
    end
end

function SKHandCards:resetOneCardPos(index)
    if self._cards[index] then
        --惯蛋添加begin
        local point = self:getHandCardsPosition(index)
        self._cards[index]:setPositionNoAciton(cc.p(self._cards[index]._pPoint.x, point.y))
        --惯蛋添加end
        self._cards[index]:setPosition(point)
    end
end

function SKHandCards:resetCardsState()
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            self._cards[i]:initSelState()
        end
    end
end

function SKHandCards:containsTouchLocation(x, y)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            if self._cards[i]:containsTouchLocation(x, y) then
                return true
            end
        end
    end

    return false
end

function SKHandCards:touchBegan(x, y)
    if self._cardsCount <= 0 then return end

    for i = self._gameController:getChairCardsCount(), 1, -1 do
        if self._cards[i] and self._cards[i]:isVisible() and self._cards[i]._bEnableTouch and self._cards[i]:containsTouchLocation(x, y) then
            self._cards[i]:setMask(true)
            self._touchBeganIndex = i
            break
        end
    end
end

function SKHandCards:touchMove(x, y)
    if self._cardsCount <= 0 then return end

    for i = self._gameController:getChairCardsCount(), 1, -1 do
        if self._cards[i] and self._cards[i]:isVisible() and self._cards[i]._bEnableTouch and self._cards[i]:containsTouchLocation(x, y) then
            self._cards[i]:setMask(true)

            if self._touchBeganIndex == 0 then
                self._touchBeganIndex = i
            else
                self._touchMovedIndex = i
            end
            self:maskSomeCards()
            break
        end
    end
end

function SKHandCards:maskSomeCards()
    if self._touchMovedIndex == 0 then return end

    local beganIndex    = self._touchBeganIndex
    local endIndex      = self._touchMovedIndex
    if self._touchMovedIndex < self._touchBeganIndex then
        beganIndex    = self._touchMovedIndex
        endIndex      = self._touchBeganIndex
    end

    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and self._cards[i]:isVisible() and self._cards[i]._bEnableTouch then
            if self._cards[i]:setMask(false) then
                return true
            end
        end
    end

    for i = beganIndex, endIndex do
        if self._cards[i] and self._cards[i]:isVisible() and self._cards[i]._bEnableTouch then
            self._cards[i]:setMask(true)
        end
    end
end

function SKHandCards:touchEnd(x, y)
    if self._cardsCount <= 0 then return end
    
    self._touchBeganIndex = 0
    self._touchMovedIndex = 0

	local count = 0
    local onlyOneSelect = 0
    local touchIndex = -1
    local selectCardIDs={}
    local selectCount = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and self._cards[i]:isVisible() and self._cards[i]._bEnableTouch and self._cards[i]:isMask() then
            self._cards[i]:setMask(false)
			count = 1
            if self._cards[i]:isSelectCard() then
                self._cards[i]:unSelectCard()
                onlyOneSelect = onlyOneSelect + 1
                touchIndex = i
            else
                self._cards[i]:selectCard()
                onlyOneSelect = onlyOneSelect + 1
                touchIndex = i
            end            
            selectCount=selectCount+1
            selectCardIDs[selectCount]=i
        end
    end

    
    local bAssitSelectSuccess = false
    if self._gameController._baseGameUtilsInfoManager:getWaitChair() == -1 then
        local SKOpeBtnManager = self._gameController._baseGameScene:getSKOpeBtnManager()
        if SKOpeBtnManager:isThrowVisible() then
        else
            if selectCount > 0  then           
                bAssitSelectSuccess = self:OPE_AssitSelect(selectCardIDs)  
            end
        end
    else
        if selectCount > 0  then           
            bAssitSelectSuccess = self:OPE_AssitSelect(selectCardIDs)  
        end
    end
    
    if not bAssitSelectSuccess and onlyOneSelect == 1 then      
        self:adjustPostionWhenTouch(touchIndex)
    end

	if count == 1 then
		self._gameController:playGamePublicSound("Snd_HitCard.mp3")
	end

    self._gameController:ope_CheckSelect()
end

function SKHandCards:maskAllHandCards(bMask)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            self._cards[i]:setMask(bMask)
        end
    end
end

--惯蛋添加BEGIN
function SKHandCards:ope_AddTributeAndReturnCard(cardID)
    self:addHandCard(cardID)
    self:sortHandCards()
    --self:updateHandCards()
end

function SKHandCards:addHandCard(cardID)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and self._cards[i]:getSKID() == -1 then
            self._cards[i]:setSKID(cardID)
            self._cards[i]:setPosition(self:getHandCardsPosition(i))
            self._cards[i]:setEnableTouch(true)
            break
        end
    end
end

function SKHandCards:OPE_MaskCardForTributeAndReturn()
    self:unSelectCards()
    local SKOpeBtnManager = self._gameController._baseGameScene:getSKOpeBtnManager()
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            self._cards[i]:setMask(false)
            self._cards[i]:setEnableTouch(true)
        end
    end
    if SKOpeBtnManager:isReturnVisible() then
        for i = 1, self._gameController:getChairCardsCount() do
            if self._cards[i] and self._cards[i]:getSKID() ~= -1 then
                if SKCalculator:getCardPriEx(self._cards[i]:getSKID(), self._gameController._baseGameUtilsInfoManager:getCurrentRank(),0) > 9 then               
                    self._cards[i]:setMask(true)
                    self._cards[i]:setEnableTouch(false)
                end
            end
        end
    end
    if SKOpeBtnManager:isTributeVisible() then
        for i = 1, self._gameController:getChairCardsCount() do
            if self._cards[i] and self._cards[i]:getSKID() ~= -1 then
                local bCanTribute = true
                if SKCalculator:isJoker(self._cards[i]:getSKID()) then
                    bCanTribute = false
                end
                local m = SKCalculator:getCardPriEx(self._cards[i]:getSKID(), self._gameController._baseGameUtilsInfoManager:getCurrentRank(),0)
                for j = 1, self._gameController:getChairCardsCount() do
                    if self._cards[j]:getSKID() ~= -1 and not SKCalculator:isJoker(self._cards[j]:getSKID())
                        and SKCalculator:getCardPriEx(self._cards[j]:getSKID(), self._gameController._baseGameUtilsInfoManager:getCurrentRank(),0) > m then
                        bCanTribute = false
                    end
                end
                if not bCanTribute then               
                    self._cards[i]:setMask(true)
                    self._cards[i]:setEnableTouch(false)
                end
            end
        end
    end
    
end

function SKHandCards:sortHandCardsByShape(CardID)
    if not self:isCardsFaceShow() then return end
    
    --[[local tableCards = {}
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCards, i, self._cards[i])
    end--]]

    local function comps(a, b) 
        if a ~= -1 and b~=-1 then        
            local aPriShape = SKCalculator:getCardShape(a)*1000+SKCalculator:getCardPriEx(a, self._gameController._baseGameUtilsInfoManager:getCurrentRank())
            local bPriShape = SKCalculator:getCardShape(b)*1000+SKCalculator:getCardPriEx(b, self._gameController._baseGameUtilsInfoManager:getCurrentRank())
            if aPriShape == bPriShape then
                return a > b
            end
            return  aPriShape > bPriShape
        else 
            return a > b
        end
    end
    table.sort(CardID, comps)
    --table.sort(tableCards, comps)

    --[[local tableCardIDs = {}
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCardIDs, i, tableCards[i]:getSKID())
    end

    local count = 0
    for i = 1, self._gameController:getChairCardsCount()  do
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(tableCardIDs[i])
            self:resetOneCardPos(i)
            count = count + 1
        end
    end--]]
end

function SKHandCards:sortHandCardsByBome(CardID, CardCount)
    if not self:isCardsFaceShow() then return end
    
    local tableCardIDs = {}
    local nBestID={}
    local nCardID={}
    local nSortCardID ={}
    for i = 1, self._gameController:getChairCardsCount() do
        tableCardIDs[i] = SKGameDef.SK_INVALID_OBJECT_ID
        nBestID[i] = SKGameDef.SK_INVALID_OBJECT_ID
        nCardID[i] = SKGameDef.SK_INVALID_OBJECT_ID
        nSortCardID[i] = SKGameDef.SK_INVALID_OBJECT_ID
    end

    for i = 1, CardCount do
        tableCardIDs[i] = CardID[i]
    end
    local nTempUnite = {}
    local nBestUnite = {}
    for i = 1 , self._gameController:getChairCardsCount() do
        nTempUnite[i] = SKCalculator:initUniteType()
        nBestUnite[i] = SKCalculator:initUniteType()
    end

    local nMaxCountCount, nMaxSocre = {0}, {0}
    self:OPE_GetMaxBomb(tableCardIDs, nTempUnite, nBestUnite, SKGameDef.SK_CARD_UNITE_TYPE_4KING, 0, nMaxCountCount, 0, nMaxSocre)
    self:OPE_SortBombUnite(nBestUnite)
   
    for i = 1, CardCount do
        nCardID[i] = CardID[i]
    end
    local nCount2=1
    for i = 1, self._gameController:getChairCardsCount() do
        for j = 1, nBestUnite[i].nCardsCount  do
            nBestID[nCount2] = nBestUnite[i].nCardIDs[j]
            nCount2 = nCount2 + 1
        end
    end
    self:XygRemoveCardIDs(nCardID, nBestID, self._gameController:getChairCardsCount())

    self:RUL_SortCard(nCardID)

    self:XygAddCardIDs(nSortCardID, nBestID, self._gameController:getChairCardsCount())
    self:XygAddCardIDs(nSortCardID, nCardID, self._gameController:getChairCardsCount())

    for i = 1, self._gameController:getChairCardsCount()  do
        CardID[i] = nSortCardID[i]
    end


    return nBestUnite
    --[[local count = 0
    for i = 1, self._gameController:getChairCardsCount()  do
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(nSortCardID[i])
            self:resetOneCardPos(i)
            count = count + 1
        end
    end--]]
end

function SKHandCards:OPE_GetMaxBomb(nCardID, nTempUnite, nBestUnite, dwCardType, nCurrentBombCount, nMaxBombCount, nCurrentScore, nMaxScore)
    local nTemp, tempType, nCount = {}, {}, self._cardsCount
    local dwCheckType = {SKGameDef.SK_CARD_UNITE_TYPE_4KING, SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB, SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN, SKGameDef.SK_CARD_UNITE_TYPE_BOMB}
    local lay = {}
    MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local nIterationCount=1    
    tempType = SKCalculator:initUniteType()
    if MyCalculator:getCardType_4King(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM ,jokerCount , tempType, 4) then
        SKCalculator:copyTable(nBestUnite[nIterationCount], tempType)
        nIterationCount = nIterationCount+1
        MyCalculator:copyCardIDs(nTemp, tempType.nCardIDs)
        self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
        tempType = SKCalculator:initUniteType()
    end
    MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
    jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    for i = 10, 6, -1 do
        while MyCalculator:getCardType_SuperBomb(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM ,0 , tempType, i) do
            SKCalculator:copyTable(nBestUnite[nIterationCount], tempType)
            nIterationCount = nIterationCount+1
            MyCalculator:copyCardIDs(nTemp, tempType.nCardIDs)
            self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
            tempType = SKCalculator:initUniteType()
          
            MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
            jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
        end
    end

    local TongHuaShun = {}
    local THSCount = 0
    while MyCalculator:getCardType_TongHuaShun(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM ,0 , tempType, 5) do
        --THSCount = THSCount+1
        --TongHuaShun[THSCount] = SKCalculator:initUniteType()
        --SKCalculator:copyTable(TongHuaShun[THSCount], tempType)

        local bombNum = 0
        for j = 1, tempType.nCardsCount do
            local cardIndex = MyCalculator:getCardIndex(tempType.nCardIDs[j], 0)
            if lay[cardIndex] == 4 then
                bombNum = bombNum+1
            end
        end
        if bombNum < 2 then
            SKCalculator:copyTable(nBestUnite[nIterationCount], tempType)
            nIterationCount = nIterationCount+1
            MyCalculator:copyCardIDs(nTemp, tempType.nCardIDs)
            self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
            tempType = SKCalculator:initUniteType()
                
            MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
            jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
        end
    end
   
    --nIterationCount, jokerCount = self:TongHuaShunScreening(TongHuaShun, THSCount, nCardID, nBestUnite, nIterationCount, lay, SKGameDef.SK_LAYOUT_NUM, nCount, jokerCount)
    if jokerCount >= 1 then
        TongHuaShun = {}
        THSCount = 0
        while MyCalculator:getCardType_TongHuaShun(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM ,1 , tempType, 5) do
        
            local UseJokerNum = 0
            for j=1 , self._gameController:getChairCardsCount() do
                if tempType.nCardIDs[j] == -1 then
                    break
                else
                    UseJokerNum = UseJokerNum+1
                end
            end
            UseJokerNum = tempType.nCardsCount - UseJokerNum

            local bombNum = 0
            for j = 1, tempType.nCardsCount do
                local cardIndex = MyCalculator:getCardIndex(tempType.nCardIDs[j], 0)
                if lay[cardIndex] == 4 then
                    bombNum = bombNum+1
                end
            end
            if bombNum < 2 then
                SKCalculator:copyTable(nBestUnite[nIterationCount], tempType)
                nIterationCount = nIterationCount+1
                MyCalculator:copyCardIDs(nTemp, tempType.nCardIDs)
                if UseJokerNum > 0 then
                    nTemp[self._gameController:getChairCardsCount()] = nJokerCardID[1]
                end
                self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
                tempType = SKCalculator:initUniteType()
                
                MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
                jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
                if jokerCount==0 then
                    break
                end
            end
        end    
    end

    if jokerCount >= 2 then
        TongHuaShun = {}
        THSCount = 0
        while MyCalculator:getCardType_TongHuaShun(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM ,2 , tempType, 5) do
        
            local UseJokerNum = 0
            for j=1 , self._gameController:getChairCardsCount() do
                if tempType.nCardIDs[j] == -1 then
                    break
                else
                    UseJokerNum = UseJokerNum+1
                end
            end
            UseJokerNum = tempType.nCardsCount - UseJokerNum

            local bombNum = 0
            for j = 1, tempType.nCardsCount do
                local cardIndex = MyCalculator:getCardIndex(tempType.nCardIDs[j], 0)
                if lay[cardIndex] == 4 then
                    bombNum = bombNum+1
                end
            end
            if bombNum < 2 then
                SKCalculator:copyTable(nBestUnite[nIterationCount], tempType)
                nIterationCount = nIterationCount+1
                MyCalculator:copyCardIDs(nTemp, tempType.nCardIDs)
                if UseJokerNum > 0 then
                    nTemp[self._gameController:getChairCardsCount()] = nJokerCardID[1]
                end
                if UseJokerNum > 1 then
                    nTemp[self._gameController:getChairCardsCount()-1] = nJokerCardID[2]
                end
                    
                self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
                tempType = SKCalculator:initUniteType()
                
                MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
                jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
                if jokerCount==0 then
                    break
                end
            end
        end    
    end            
    
    for i = 5, 4, -1 do   
        while MyCalculator:getCardType_Bomb(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM ,0 , tempType, i) do                     
            SKCalculator:copyTable(nBestUnite[nIterationCount], tempType)
            nIterationCount = nIterationCount+1
            MyCalculator:copyCardIDs(nTemp, tempType.nCardIDs)
            self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
            tempType = SKCalculator:initUniteType()
            
            MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
            jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
        end
    end

    if jokerCount >= 1 then
        for i = 5, 4, -1 do   
            while MyCalculator:getCardType_Bomb(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM ,1 , tempType, i) do
                local UseJokerNum = 0
                for j=1 , self._gameController:getChairCardsCount() do
                    if tempType.nCardIDs[j] == -1 then
                        break
                    else
                        UseJokerNum = UseJokerNum+1
                    end
                end
                UseJokerNum = tempType.nCardsCount - UseJokerNum
            
                SKCalculator:copyTable(nBestUnite[nIterationCount], tempType)
                nIterationCount = nIterationCount+1
                MyCalculator:copyCardIDs(nTemp, tempType.nCardIDs)
                if UseJokerNum > 0 then
                    nTemp[self._gameController:getChairCardsCount()] = nJokerCardID[1]
                end
                self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
                tempType = SKCalculator:initUniteType()
            
                MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
                jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

                if jokerCount==0 then
                    break
                end
            end
        end
    end
    if jokerCount >= 2 then
        for i = 5, 4, -1 do   
            while MyCalculator:getCardType_Bomb(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM ,2 , tempType, i) do
                local UseJokerNum = 0
                for j=1 , self._gameController:getChairCardsCount() do
                    if tempType.nCardIDs[j] == -1 then
                        break
                    else
                        UseJokerNum = UseJokerNum+1
                    end
                end
                UseJokerNum = tempType.nCardsCount - UseJokerNum

                SKCalculator:copyTable(nBestUnite[nIterationCount], tempType)
                nIterationCount = nIterationCount+1
                MyCalculator:copyCardIDs(nTemp, tempType.nCardIDs)
                if UseJokerNum > 0 then
                    nTemp[self._gameController:getChairCardsCount()] = nJokerCardID[1]
                end
                if UseJokerNum > 1 then
                    nTemp[self._gameController:getChairCardsCount()-1] = nJokerCardID[2]
                end
                self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
                tempType = SKCalculator:initUniteType()
            
                MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
                jokerCount, NotUsecardsCount, nJokerCardID = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
                if jokerCount==0 then
                    break
                end
            end
        end
    end
   
    return true
end

function SKHandCards:OPE_SortBombUnite(nBestUnite)
    local nMaxUnite = {}
    nMaxUnite = SKCalculator:initUniteType()
    local nSortValue = {}
    for i= 1, self._gameController:getChairCardsCount() do
        nSortValue[i] = SKCalculator:initUniteType()
    end
    local nCount = 1
    local dwCheckType = {SKGameDef.SK_CARD_UNITE_TYPE_4KING, SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB, SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN, SKGameDef.SK_CARD_UNITE_TYPE_BOMB}
    for i = 1, 4 do
        local nTypeCount = 0
        for j = 1, self._gameController:getChairCardsCount() do
            if nBestUnite[j].dwCardType == dwCheckType[i] then
                nTypeCount = nTypeCount+1
            end
        end
        while nTypeCount > 0 do
            local nFindIndex = -1          
            nMaxUnite = SKCalculator:initUniteType()
            for j = 1, self._gameController:getChairCardsCount() do
                if nBestUnite[j].dwCardType == dwCheckType[i] 
                    and nBestUnite[j].nMainValue > nMaxUnite.nMainValue then
                    nFindIndex = j
                    SKCalculator:copyTable(nMaxUnite, nBestUnite[j])
                end
            end
            if nFindIndex~=-1 then
                SKCalculator:copyTable(nSortValue[nCount], nMaxUnite)
                nBestUnite[nFindIndex] = SKCalculator:initUniteType()
                nTypeCount = nTypeCount-1
                nCount=nCount+1
            end
        end
    end
    SKCalculator:copyTable(nBestUnite, nSortValue)
end

function SKHandCards:RUL_SortCard(nCardID)
    local function comps(a, b)
        if a ~= -1 and b~=-1 then
            local aPri = SKCalculator:getCardPriEx(a, self._gameController._baseGameUtilsInfoManager:getCurrentRank())*1000+a
            local bPri = SKCalculator:getCardPriEx(b, self._gameController._baseGameUtilsInfoManager:getCurrentRank())*1000+b
            return aPri > bPri
        else
            return a > b
        end
    end
    table.sort(nCardID, comps)
end

function SKHandCards:XygRemoveCardIDs(nCardID, nRemoveCard, nCardsLen)
    local count = 0
    for i = 1 , nCardsLen do
        for j = 1 , nCardsLen do
            if nCardID[i]~=-1 and nCardID[i] == nRemoveCard[j] then
                nCardID[i] = -1
                break
            end
        end
    end   
    return self:PM_Zip(nCardID, nCardsLen, -1)
end

function SKHandCards:PM_Zip(sin, sinNum, LowNum)
    local temp ={};
    local num = 1
    for i=1, sinNum do
        temp[i]=LowNum
        if sin[i]>LowNum then
            temp[num] = sin[i]
            num = num+1
        end
    end
    SKCalculator:copyTable(sin, temp)
    return num
end

function SKHandCards:XygAddCardIDs(nCardID, nAddCard, nCardsLen)
    local count = 0
    for i = 1 , nCardsLen do
        if nAddCard[i] and nAddCard[i]~=-1 then
            for j = 1 , nCardsLen do
                if nCardID[j]==-1 then
                    nCardID[j] = nAddCard[i]
                    break
                end
            end
        end       
    end   
end

function SKHandCards:OnArrageHandCard()
    local nSelectCardID, nCount =  self:getSelectCardIDs()
    if nCount == 0 then
        local msg = string.format(self._gameController:getGameStringByKey("G_GAME_ARRAGE_SELECT_FIRST"))
        local utf8Message = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        if utf8Message then 
            my.informPluginByName({pluginName='TipPlugin',params={tipString = utf8Message, removeTime = 1}})
        end
        return
    end
    local nCountSelect = nCount

    local nArrageCardID = {}
    SKCalculator:xygInitChairCards(nArrageCardID, self._gameController:getChairCardsCount())
    self:XygAddCardIDs(nArrageCardID, nSelectCardID, self._gameController:getChairCardsCount())

    local nCardID={}
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(nCardID, i, self._cards[i]:getSKID())
    end
    self:XygRemoveCardIDs(nCardID, nArrageCardID, self._gameController:getChairCardsCount())
    self:XygAddCardIDs(nArrageCardID, nCardID, self._gameController:getChairCardsCount())
    
    local cardPoint = {}
    for i = 1, self._gameController:getChairCardsCount() do
        if nArrageCardID[i] ~= -1 then
            for j=1, self._gameController:getChairCardsCount() do
                if nArrageCardID[i] == self._cards[j]:getSKID() then               
                    table.insert(cardPoint, i, self._cards[j]._pPoint)
                    break
                end
            end
        else
            table.insert(cardPoint, i, self._cards[i]._pPoint)
        end
    end

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(nArrageCardID[i])
            self._cards[i]:setPositionNoAciton(cardPoint[i])
            self:resetOneCardPos(i)
            count = count + 1
        end
    end
    
    self:OPE_SetArrageUnite(nSelectCardID, nCount)
    self:OPE_MaskCardForArrage()
  
    self._gameController:ope_CheckSelect()
end

function SKHandCards:OPE_SetArrageUnite(nCardID, nCardCount)
    if nCardCount == 0  then
        return
    end
    
    self.bNeedResetArrageNo = true

    local ArragenCardCount = {}
    for i = 1, self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
        ArragenCardCount[i] = self._nArrageUnite[i].nCardCount
        for j = 1, self._nArrageUnite[i].nCardCount--[[self._gameController:getChairCardsCount()--]] do
            for k = 1, nCardCount--[[self._gameController:getChairCardsCount()--]] do
                if self._nArrageUnite[i].nCards[j]==nCardID[k]
                    and nCardID[k]~=-1 then
                    self._nArrageUnite[i].nCards[j]=-1
                    self._nArrageUnite[i].nCardCount = self._nArrageUnite[i].nCardCount-1
                    if self._nArrageUnite[i].nCardCount == 0 then
                        self._nArrageUnite[i].bBomb = false
                        self._nArrageUnite[i].bArrage = false   
                    end
                end
            end
        end
    end

    for i = 1, self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
        for j = 1, (ArragenCardCount[i]--[[self._gameController:getChairCardsCount()--]]-1) do
            if self._nArrageUnite[i].nCards[j]==-1 then
                local bFind=false
                for k = j+1, ArragenCardCount[i]--[[self._gameController:getChairCardsCount()--]] do
                    if self._nArrageUnite[i].nCards[k]~=-1 then
                        self._nArrageUnite[i].nCards[j] = self._nArrageUnite[i].nCards[k]
                        self._nArrageUnite[i].nCards[k] = -1
                        bFind=true
                        break
                    end
                end
                if not bFind then
                    break
                end
            end
        end
    end

    for i = 1, (self.nArrageCount--[[self._gameController:getChairCardsCount()--]]-1) do
        if self._nArrageUnite[i].nCardCount==0 then
            for j = i+1, self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
                if self._nArrageUnite[j].nCardCount~=0 then
                    SKCalculator:copyTable(self._nArrageUnite[i], self._nArrageUnite[j])
                    self:XygInitArrageUniteByIndex(j)
                    break
                end
            end
        end
    end
    
    self.nArrageCount = 1
    local temp = {}
    SKCalculator:copyTable(temp, self._nArrageUnite)
    self:XygInitArrageUnite()
    for i = 2 , self._gameController:getChairCardsCount() do
        SKCalculator:copyTable(self._nArrageUnite[i], temp[i-1])

        if temp[i-1].nCardCount ~= 0 then
            self.nArrageCount = self.nArrageCount+1
        end
    end
    
    for i = 1, self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
        if self._nArrageUnite[i].nCardCount==0 then
            if nCardCount > 0 then
                SKCalculator:copyTable(self._nArrageUnite[i].nCards, nCardID)
                self._nArrageUnite[i].nCardCount = nCardCount
                self._nArrageUnite[i].bBomb = false
                self._nArrageUnite[i].bArrage = true

                self.nArrageCount = self.nArrageCount+1
            end
            break
        end
    end

    for k = 1 , self._gameController:getChairCardsCount() do     
        self._cards[k]._ArrageNo = 0
        self._cards[k]._bArraged = false
        self._cards[k]._bBomb = false
        if self._cards[k]:getSKID()~=-1 then
            for i = 1 , self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
                for j = 1 , self._nArrageUnite[i].nCardCount do
                    if self._nArrageUnite[i].nCards[j]==self._cards[k]:getSKID() then
                        self._cards[k]._ArrageNo = i
                        self._cards[k]._bArraged = self._nArrageUnite[i].bArrage
                        self._cards[k]._bBomb = self._nArrageUnite[i].bBomb
                    end
                end
            end     
        end           
    end
    
end

function SKHandCards:OPE_SetUniteWhenThrow(nCardID, nCardCount)
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    
    self.bNeedResetArrageNo = true

    local ArragenCardCount = {}

    for i = 1, self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
        ArragenCardCount[i] = self._nArrageUnite[i].nCardCount
        for j = 1, self._nArrageUnite[i].nCardCount--[[self._gameController:getChairCardsCount()--]] do
            for k = 1, nCardCount--[[self._gameController:getChairCardsCount()--]] do
                if self._nArrageUnite[i].nCards[j]==nCardID[k]
                    and nCardID[k]~=-1 then
                    self._nArrageUnite[i].nCards[j]=-1
                    self._nArrageUnite[i].nCardCount = self._nArrageUnite[i].nCardCount-1
                    if self._nArrageUnite[i].nCardCount == 0 then
                        self._nArrageUnite[i].bBomb = false
                        self._nArrageUnite[i].bArrage = false   
                    end
                end
            end
        end
    end

    for i = 1, self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
        for j = 1, (ArragenCardCount[i]--[[self._gameController:getChairCardsCount()--]]-1) do
            if self._nArrageUnite[i].nCards[j]==-1 then
                local bFind=false
                for k = j+1, ArragenCardCount[i]--[[self._gameController:getChairCardsCount()--]] do
                    if self._nArrageUnite[i].nCards[k]~=-1 then
                        self._nArrageUnite[i].nCards[j] = self._nArrageUnite[i].nCards[k]
                        self._nArrageUnite[i].nCards[k] = -1
                        bFind=true
                        break
                    end
                end
                if not bFind then
                    break
                end
            end
        end
    end

     for i = 1, (self.nArrageCount--[[self._gameController:getChairCardsCount()--]]-1) do
        if self._nArrageUnite[i].nCardCount==0 then
            for j = i+1, self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
                if self._nArrageUnite[j].nCardCount~=0 then
                    SKCalculator:copyTable(self._nArrageUnite[i], self._nArrageUnite[j])
                    self:XygInitArrageUniteByIndex(j)
                    break
                end
            end
        end
    end
    for k = 1 , self._gameController:getChairCardsCount() do     
        self._cards[k]._ArrageNo = 0
        self._cards[k]._bArraged = false
        self._cards[k]._bBomb = false
    end
    local nCount = 1
    self._WhenThrowEndArrageCard = {}
    SKCalculator:xygInitChairCards(self._WhenThrowEndArrageCard, self._gameController:getChairCardsCount())
    for i = 1 , self.nArrageCount do
        for j = 1 , self._nArrageUnite[i].nCardCount do
            self._WhenThrowEndArrageCard[nCount] = self._nArrageUnite[i].nCards[j]
            self._cards[nCount]._ArrageNo = i
            self._cards[nCount]._bArraged = self._nArrageUnite[i].bArrage
            self._cards[nCount]._bBomb = self._nArrageUnite[i].bBomb
            nCount = nCount+1
        end
    end 
    self._WhenThrowEndArrageCardCount = nCount
    --[[for k = 1 , self._gameController:getChairCardsCount() do     
        self._cards[k]._ArrageNo = 0
        self._cards[k]._bArraged = false
        self._cards[k]._bBomb = false
        for i = 1 , self.nArrageCount do
            for j = 1 , self._nArrageUnite[i].nCardCount do
                self._cards[k]._ArrageNo = i
                self._cards[k]._bArraged = self._nArrageUnite[i].bArrage
                self._cards[k]._bBomb = self._nArrageUnite[i].bBomb
            end
        end        
    end--]]

    --self:OPE_MaskCardForArrage()
end

function SKHandCards:OPE_SetBombUnite(nBestUnite)
    self.bNeedResetArrageNo = true
    --每次排序 理牌数组都是清空的, 除了点排序按钮外 其他时候不排序
    self.nArrageCount = 1
    local nCount = 1
    for i = 1 , self._gameController:getChairCardsCount() do
        if nBestUnite[i].nCardsCount <= 0 then
            break
        end
        
        self._nArrageUnite[nCount].nCardCount = nBestUnite[i].nCardsCount
        self._nArrageUnite[nCount].bArray = false
        self._nArrageUnite[nCount].bBomb = true
        for j = 1, nBestUnite[i].nCardsCount do
            self._nArrageUnite[nCount].nCards[j] =  nBestUnite[i].nCardIDs[j]
        end
        nCount = nCount+1
        self.nArrageCount = self.nArrageCount+1
    end

    for k = 1 , self._gameController:getChairCardsCount() do     
        self._cards[k]._ArrageNo = 0
        self._cards[k]._bArraged = false
        self._cards[k]._bBomb = false
        if self._cards[k]:getSKID()~=-1 then
            for i = 1 , self.nArrageCount--[[self._gameController:getChairCardsCount()--]] do
                for j = 1 , self._nArrageUnite[i].nCardCount do
                    if self._nArrageUnite[i].nCards[j]==self._cards[k]:getSKID() then
                        self._cards[k]._ArrageNo = i
                        self._cards[k]._bArraged = self._nArrageUnite[i].bArrage
                        self._cards[k]._bBomb = self._nArrageUnite[i].bBomb
                    end
                end
            end     
        end           
    end
end

function SKHandCards:OnResetArrageHandCard()    
    self:sortHandCards()
end

function SKHandCards:XygInitArrageUniteByIndex(index)
    self._nArrageUnite[index].nArrageNO = 0
    self._nArrageUnite[index].nCardCount = 0
    self._nArrageUnite[index].bBomb = false
    self._nArrageUnite[index].bArrage = false
    self._nArrageUnite[index].nCards = {}
    SKCalculator:xygInitChairCards(self._nArrageUnite[index].nCards, self._gameController:getChairCardsCount())
end

function SKHandCards:XygInitArrageUnite()
    if not self._nArrageUnite then
        return
    end
    for i = 1, self._gameController:getChairCardsCount() do
        self._nArrageUnite[i].nArrageNO = 0
        self._nArrageUnite[i].nCardCount = 0
        self._nArrageUnite[i].bBomb = false
        self._nArrageUnite[i].bArrage = false
        self._nArrageUnite[i].nCards = {}
        SKCalculator:xygInitChairCards(self._nArrageUnite[i].nCards, self._gameController:getChairCardsCount())
    end
end

function SKHandCards:adjustPostionWhenTouch(touchIndex)
    local starposition=0
    local endPosition=0
    if touchIndex-2 > 1 then
        starposition = touchIndex-2
    else
        starposition = 1
    end
    if touchIndex+3 < self._cardsCount then
        endPosition = touchIndex+3
    else
        endPosition = self._cardsCount
    end
    if touchIndex >= self._nEndIndexEx-2 and touchIndex < self._nEndIndexEx+3 and self._nEndIndexEx~=-1 then
        return
    end
    self._nEndIndexEx = touchIndex

    local fStartX=100
    local fInterval=0
    local fInterval2=0
    fStartX, fInterval, fInterval2 = self:computeCardintervalWhenTouch(self._cardsCount, endPosition - starposition)

    local startX, startY = fStartX, SKGameDef.SK_CARD_START_POS_Y       --左下起点坐标
    
    self._cards[1]:setPosition(cc.p(startX, self._cards[1]._pPoint.y))
    for i = 2, self._cardsCount do
        if i > starposition and i <= endPosition then         
            startX = startX + fInterval2
        else           
            startX = startX + fInterval
        end
        --[[self._cards[i]._SKCardSprite:stopActionByTag(SKGameDef.CardKTagActionX)
        local ActionMove = cc.MoveTo:create(0.2,cc.p(startX, self._cards[i]._SKCardSprite:getPositionY()))
        ActionMove:setTag(SKGameDef.CardKTagActionX)
        self._cards[i]._SKCardSprite:runAction(ActionMove)--]]
        self._cards[i]:setPosition(cc.p(startX, self._cards[i]._pPoint.y))
    end
end

function SKHandCards:computeCardintervalWhenTouch(nNmuber, nNmuber2)
    local fStartX=100
    local fInterval=0
    local fInterval2=0

    local index = 0
    local XStartPos = SKGameDef.SK_CARD_START_POS_X
    local startX, startY = XStartPos, SKGameDef.SK_CARD_START_POS_Y       --左下起点坐标
   
    local biggsetWidth = (SKGameDef.SK_CARD_PER_LINE - 1) * SKGameDef.SK_CARD_COLUMN_INTERVAL

    if self._cardsCount == 1 then
        fInterval = SKGameDef.SK_CARD_COLUMN_INTERVAL_MAX
        fInterval2 = fInterval
            
        local width = fInterval * (self._cardsCount - 1)

        startX = startX + --[[math.floor--]]((biggsetWidth - width) / 2)

        local xEx = 0
        if biggsetWidth > width then
            xEx = (biggsetWidth + self._cards[1]:getContentSize().width)/2 + XStartPos - self._gameController:getCenterXOfOperatePanel()
        end
        startX = startX - xEx

        if startX < XStartPos then
            startX = XStartPos
        end

        return startX, fInterval, fInterval2
    end

    local width = 0
    if SKGameDef.SK_CARD_PER_LINE >= self._cardsCount then          --一列
        --local interval = 0
        if 1 < self._cardsCount then
            fInterval = --[[math.floor--]](biggsetWidth / (self._cardsCount - 1))
        end
        if SKGameDef.SK_CARD_COLUMN_INTERVAL_MAX < fInterval then    --间隔足够大后两端缩进
            fInterval = SKGameDef.SK_CARD_COLUMN_INTERVAL_MAX
            fInterval2 = fInterval
            
            width = fInterval * (self._cardsCount - 1)

            startX = startX + --[[math.floor--]]((biggsetWidth - width) / 2)
        else
            fInterval2 = SKGameDef.SK_CARD_COLUMN_INTERVAL_MAX
            fInterval = ((biggsetWidth - fInterval2*(nNmuber2))/(self._cardsCount - nNmuber2 - 1))

            width = fInterval * (self._cardsCount- nNmuber2 - 1) + fInterval2 * (nNmuber2)
            startX = startX + --[[math.floor--]]((biggsetWidth - width) / 2)
        end
        --startX = startX + (index - 1) * fInterval
    end

    local xEx = 0
    if biggsetWidth > width then
        xEx = (biggsetWidth + self._cards[1]:getContentSize().width)/2 + XStartPos - self._gameController:getCenterXOfOperatePanel()
    end
    startX = startX - xEx

    if startX < XStartPos then
        startX = XStartPos
    end

    return startX, fInterval, fInterval2
end

function SKHandCards:RUL_GetInHandArrageCards(nCardID)
    if self._ThrowCards then
        local nCount = 0
        for i = 1, self._WhenThrowEndArrageCardCount do
            nCardID[nCount+1]=self._WhenThrowEndArrageCard[i]
            nCount = nCount + 1
        end
        return nCount
    end
    local nCount = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i]:getSKID() ~= -1 and self._cards[i]._bArraged then
            nCardID[nCount+1]=self._cards[i]:getSKID()
            nCount = nCount + 1
        end
    end
    return nCount
end

function SKHandCards:RUL_GetInHandNoArrageCards(nCardID)
    if self._ThrowCards then
        local nCount = 0
        for i = 1, self._gameController:getChairCardsCount() do
            local have = false
            for j = 1, self._WhenThrowEndArrageCardCount do
                if self._cards[i]:getSKID() ~= -1 and self._cards[i]:getSKID() == self._WhenThrowEndArrageCard[j] then     
                    have = true
                end
            end
            if not have then    
                nCardID[nCount+1]=self._cards[i]:getSKID()
                nCount = nCount + 1
            end
        end
        return nCount
    end
    local nCount = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i]:getSKID() ~= -1 and not self._cards[i]._bArraged then
            nCardID[nCount+1]=self._cards[i]:getSKID()
            nCount = nCount + 1
        end
    end
    return nCount
end

function SKHandCards:RUL_GetInHandNormalCards(nCardID)   
    local nCount = 0
    local nCardID = {}
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i]:getSKID() ~= -1 and not self._cards[i]._bArraged and not self._cards[i]._bBomb then
            nCardID[nCount+1]=self._cards[i]:getSKID()
            nCount = nCount + 1
        end
    end
    return nCardID, nCount
end

function SKHandCards:XygReversalMoreByValue(nCardID)
    local function comps(a, b)
        --惯蛋添加
        if a:getPriIndex()  == b:getPriIndex()  then
            return a:getSKID() > b:getSKID()
        end
        return a:getPriIndex() > b:getPriIndex() 
    end
    table.sort(nCardID, comps)
end

function SKHandCards:ThrowEndSort()
    local oldCardPoint
    for i = 1, (self._gameController:getChairCardsCount() - 1) do
        oldCardPoint = self._cards[i]._pPoint
        if self._cards[i]:getSKID() == -1 then
            for j = i+1  , self._gameController:getChairCardsCount() do
                if self._cards[j]:getSKID() ~= -1 then
                    self._cards[i]:setSKID(self._cards[j]:getSKID())
                    self._cards[j]:clearSKID()
                    oldCardPoint = self._cards[j]._pPoint
                    break
                end
            end           
        end
        if self._cards[i]:getSKID() ~= -1 then
            self._cards[i]:setPositionNoAciton(oldCardPoint)
            self:resetOneCardPos(i)
        end
        self._cards[i]:MaskCardForArrage()
    end
end

function SKHandCards:OPE_MaskCardForArrage()
    for i = 1, self._cardsCount do
        self._cards[i]:MaskCardForArrage()
    end
end

function SKHandCards:TongHuaShunScreening(TongHuaShun, THSCount, nCardID, nBestUnite, nIterationCount, lay, layLen, nCount, jokerCount)
    --[[local oldIndex = {}
    local oldCount = 0
    local nTemp = {}
    for i = 1, THSCount-1 do       
        local findTHS = false
        local nMainValue = TongHuaShun[i].nMainValue
        local indexTHS = i
        for j = 1, TongHuaShun[i].nCardsCount do
            for m = i + 1, THSCount do
                for k = 1, TongHuaShun[m].nCardsCount do               
                    if TongHuaShun[i].nCardIDs[j] == TongHuaShun[m].nCardIDs[k] then
                        findTHS = true
                        if nMainValue  < TongHuaShun[m].nMainValue then
                            nMainValue = TongHuaShun[m].nMainValue
                            indexTHS = m
                        end
                        break
                    end
                end
            end      
        end
        if findTHS then
            local haveOld = false
            for n = 1, oldCount do
                if oldIndex[oldCount] == indexTHS then
                    haveOld = true
                    break
                end
            end
            if not haveOld then
                local bombNum = 0
                for j = 1, TongHuaShun[indexTHS].nCardsCount do
                    local cardIndex = MyCalculator:getCardIndex(TongHuaShun[indexTHS].nCardIDs[j], 0)
                    
                    if lay[cardIndex] == 4 then
                        bombNum = bombNum+1
                    end
                end
                if bombNum < 2 then
                    oldCount = oldCount+1
                    oldIndex[oldCount] = indexTHS
                    SKCalculator:copyTable(nBestUnite[nIterationCount], TongHuaShun[indexTHS])
                    nIterationCount = nIterationCount+1
                    MyCalculator:copyCardIDs(nTemp, TongHuaShun[indexTHS].nCardIDs)
                    self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
                    --tempType = SKCalculator:initUniteType()

                    MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
                    jokerCount = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
                end
            end
        end
    end--]]
    local nTemp = {}
    local bombNum = 0
    for j = 1, TongHuaShun[indexTHS].nCardsCount do
        local cardIndex = MyCalculator:getCardIndex(TongHuaShun[indexTHS].nCardIDs[j], 0)
                    
        if lay[cardIndex] == 4 then
            bombNum = bombNum+1
        end
    end
    if bombNum < 2 then
        oldCount = oldCount+1
        oldIndex[oldCount] = indexTHS
        SKCalculator:copyTable(nBestUnite[nIterationCount], TongHuaShun[indexTHS])
        nIterationCount = nIterationCount+1
        MyCalculator:copyCardIDs(nTemp, TongHuaShun[indexTHS].nCardIDs)
        self:XygRemoveCardIDs(nCardID, nTemp, self._gameController:getChairCardsCount())
        --tempType = SKCalculator:initUniteType()

        MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
        jokerCount = MyCalculator:preDealCards(nCardID, nCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
    end

    return nIterationCount, jokerCount
end

function SKHandCards:OPE_AssitSelect(selectCardIDs)
    local selectCount = #selectCardIDs
    local ballSelect=true
    for i, v in pairs(selectCardIDs) do
        if not self._cards[v]:isSelectCard() then
            ballSelect = false
            break
        end
    end
    if not ballSelect then return false end

    local bSelectArr = {}
    bSelectArr.bNormalSelect = false 
    bSelectArr.bArrageSelect = false 
    bSelectArr.bBombSelect = false 
    if not self:OPE_PreTouchSelect(selectCardIDs, bSelectArr) then return false end

    if bSelectArr.bArrageSelect or bSelectArr.bBombSelect then
        self:OPE_AssitArrageSelect(selectCardIDs)        
        return true
    end
    return false
end

function SKHandCards:OPE_AssitArrageSelect(selectCardIDs)
    local nArrageNO = 0
    local nCardIDs = {}

    for i, v in pairs(selectCardIDs) do
        nArrageNO = self._cards[v]._ArrageNo
    end
    local nCount = 0
    for i = 1, self._cardsCount do       
        if self._cards[i]._ArrageNo == nArrageNO then
            nCount = nCount+1
            nCardIDs[nCount] = self._cards[i]:getSKID()
        end
    end
    
    self:unSelectCards()
    self:selectCardsByIDs(nCardIDs, nCount)
end

function SKHandCards:OPE_PreTouchSelect(selectCardIDs, bSelectArr)
    local selectCount = #selectCardIDs

    for i = 1, self._cardsCount do
        local card = self._cards[i]
        --当级牌被选的时候不快速提示（不管级牌是否被理牌，修改理牌级牌最后无法出的问题）
        if MyCalculator:isJoker(card:getSKID()) and card._bSelected
            --[[and not card._bArraged and not card._bBomb]] then
            return false
        end
        --当理牌区的牌和没有理过的牌都有被选的时候不快速提示
        if card._bArraged and card._bSelected then
            bSelectArr.bArrageSelect = true
        end
        --炸弹
        if card._bBomb and not card._bArraged and card._bSelected then
            bSelectArr.bBombSelect = true
        end
        --普通
        if not card._bArraged and not card._bBomb and card._bSelected then
            bSelectArr.bNormalSelect = true
        end
    end

    for i = 1 , selectCount do
        local card = self._cards[selectCardIDs[i]]
        --当级牌被选的时候不快速提示（不管级牌是否被理牌，修改理牌级牌最后无法出的问题）
        if MyCalculator:isJoker(card:getSKID()) 
            --[[and not card._bArraged and not card._bBomb]] then
            return false
        end
        --当理牌区的牌和没有理过的牌都有被选的时候不快速提示
        if card._bArraged then
            bSelectArr.bArrageSelect = true
        end
        --炸弹
        if card._bBomb and not card._bArraged then
            bSelectArr.bBombSelect = true
        end
        --普通
        if not card._bArraged and not card._bBomb then
            bSelectArr.bNormalSelect = true
        end
    end
    
    if bSelectArr.bNormalSelect and bSelectArr.bArrageSelect then
        return false
    end
    if bSelectArr.bBombSelect and bSelectArr.bArrageSelect then
        return false
    end
    if bSelectArr.bNormalSelect and bSelectArr.bBombSelect then
        return false
    end

    return true
end


function SKHandCards:getCardIDsByArrageGroupNum(GroupNum)   --_nArrageUnite下标
    local cardIds = {}
    local cardCount = 0
    if self._nArrageUnite[GroupNum].nCardCount == 0 then return cardIds, cardCount end
    
    cardIds = self._nArrageUnite[GroupNum].nCards
    cardCount = self._nArrageUnite[GroupNum].nCardCount
    return cardIds, cardCount   
end

function SKHandCards:showFriendCards(cards, len)
    self._FriendCardsCount = len
    self._FriendCards = cards
    for i = 1, self._FriendCardsCount do
        if not self._cards[i] or not cards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setSKID(cards[i])
        self._cards[i]:setPositionNoAciton(self:getFriendHandCardsPosition(i))
        self._cards[i]:setEnableTouch(false)
        self._cards[i]:setMask(true)
    end

    self:sortFriendHandCards()
end

function SKHandCards:sortFriendHandCards()
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    
    if not self:isCardsFaceShow() then return end

    local tableCards = {}
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCards, i, self._cards[i])
    end

    local function comps(a, b)
        --惯蛋添加
        if a:getPriIndex()  == b:getPriIndex()  then
            return a:getSKID() > b:getSKID()
        end
        return a:getPriIndex() > b:getPriIndex() 
    end
    table.sort(tableCards, comps)

    local tableCardIDs = {}

    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCardIDs, i, tableCards[i]:getSKID())
    end

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._FriendCardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(tableCardIDs[i])
            self._cards[i]:setPositionNoAciton(self:getFriendHandCardsPosition(i))           
            self._cards[i]:setEnableTouch(false)
            self._cards[i]:setMask(true)
            count = count + 1
        end
    end
end

function SKHandCards:getFriendHandCardsPosition(index)
    local XStartPos = SKGameDef.SK_CARD_START_POS_X
    local startX, startY = XStartPos, SKGameDef.SK_CARD_START_POS_Y       --左下起点坐标

    if SKGameDef.SK_CARD_PER_LINE >= self._FriendCardsCount then          --一列
        local biggsetWidth = (SKGameDef.SK_CARD_PER_LINE - 1) * SKGameDef.SK_CARD_COLUMN_INTERVAL
        local interval = 0
        if 1 < self._FriendCardsCount then
            interval = --[[math.floor--]](biggsetWidth / (self._FriendCardsCount - 1))
        end
        if SKGameDef.SK_CARD_COLUMN_INTERVAL_MAX < interval then    --间隔足够大后两端缩进
            interval = SKGameDef.SK_CARD_COLUMN_INTERVAL_MAX
        end
        local width = interval * (self._FriendCardsCount - 1)

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
    end

    return cc.p(startX, startY)
end

function SKHandCards:updataFriendCards(cards, count)
    self._FriendCardsCount = self._FriendCardsCount-count
    
    for i = 1, count do
        local cardID = cards[i]

        local card = self:getCardByID(cardID)
        if card then
            card:clearSKID()
            card:setPosition(self:getFriendHandCardsPosition(i))
        end
    end

    local oldCardPoint
    for i = 1, (self._gameController:getChairCardsCount() - 1) do
        oldCardPoint = self._cards[i]._pPoint
        if self._cards[i]:getSKID() == -1 then
            for j = i+1  , self._gameController:getChairCardsCount() do
                if self._cards[j]:getSKID() ~= -1 then
                    self._cards[i]:setSKID(self._cards[j]:getSKID())
                    self._cards[j]:clearSKID()
                    oldCardPoint = self._cards[j]._pPoint
                    break
                end
            end           
        end
        if self._cards[i]:getSKID() ~= -1 then
            self._cards[i]:setPositionNoAciton(oldCardPoint)

            local point = self:getFriendHandCardsPosition(i)
            self._cards[i]:setPositionNoAciton(cc.p(self._cards[i]._pPoint.x, point.y))
            --惯蛋添加end
            self._cards[i]:setPosition(point)
            --掼蛋添加，显示好友牌都添加蒙版
            self._cards[i]:setEnableTouch(false)
            self._cards[i]:setMask(true)
        end
        self._cards[i]:MaskCardForArrage()
    end
end

function SKHandCards:maskAllHandCardsEX(bMask)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            self._cards[i]:setMask(bMask)
            self._cards[i]:setEnableTouch(not bMask)
        end
    end
end

function SKHandCards:RUL_SortCardByCardsNum(nCardID) --张数理牌
    local inhandLay     = {}
    SKCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = nCardID, table.maxn(nCardID)
    SKCalculator:skLayCards(inhandCards, cardsCount, inhandLay, gameFlags)
    
    local function comps(a, b)
        if a ~= -1 and b~=-1 then
            local aIndex = SKCalculator:getCardIndex(a, gameFlags)
            local bIndex = SKCalculator:getCardIndex(b, gameFlags)
            if inhandLay[aIndex] == inhandLay[bIndex] then
                local aPri = SKCalculator:getCardPriEx(a, self._gameController._baseGameUtilsInfoManager:getCurrentRank())*1000+a
                local bPri = SKCalculator:getCardPriEx(b, self._gameController._baseGameUtilsInfoManager:getCurrentRank())*1000+b
                return aPri > bPri
            else
                return inhandLay[aIndex] > inhandLay[bIndex]
            end
        else
            return a > b
        end
    end
    table.sort(nCardID, comps)
end

--惯蛋添加END

return SKHandCards
