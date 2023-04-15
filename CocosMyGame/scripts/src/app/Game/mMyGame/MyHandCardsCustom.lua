--/*************** MyHandCardsCustom **************************/
--  继承自 MyHandCards, 用来实现手牌 竖直方向排列
--  用 game_controller 里面的verticalArrangement = 1 来控制是否开启 （game_controller.lua）
local MyHandCardsCustom          = class("MyHandCardsCustom", import("src.app.Game.mMyGame.MyHandCards"))
local MyCardHandVertical                = import("src.app.Game.mMyGame.MyCardHandVertical")
local MyCardHand                = import("src.app.Game.mMyGame.MyCardHand")

local MyCalculator              = import("src.app.Game.mMyGame.MyCalculator")
local VerticalCard      =   {
    CARD_NOMAL_HEIGHT_DISTANCE = 47,
    CARD_NOMAL_HEIGHT_DISTANCE_RAW = 47,
    CARD_DRAG_HEIGHT_DISTANCE = 55,
    CARD_DRAG_HEIGHT_DISTANCE_RAW = 55,
    CARD_NOMAL_WIDTH_DISTANCE = 110,
    CARD_NOMAL_START_X        = 80,
    CARD_NOMAL_START_X_RAW    = 50,
    CARD_NOMAL_START_Y        = 15,
    CARD_NOMAL_START_Y_RAW    = 15,
    CARD_COLUMN_INTERVAL      = 45,
}

-- rewrite init
function MyHandCardsCustom:init()
    self._cardCounts = {}      -- 保存普通牌数组（非整理牌， 非炸弹牌）
    self._cardArranges = {}    -- 保存理牌区炸弹数组
    self._cardArrangesNotBomb = {}       -- 保存理牌非炸弹数组
    self._nCardRowCols = {}     -- 根据手牌索引保存行列信息。目前仅用于带理牌属性的牌


    self._ColCounts  = 0       -- 统计竖向有几列
    self._linesLimit = 8
    self._isSupportLinesLimit = true   -- 是否开启竖向排列张数限制

    self._moveIndexTotalArr = {}    -- 移动选牌记录，记录全部 。 array {touchIndex，，，}
    self._moveUniqueTable = {}  -- 移动选牌记录map[touchIndex] = true 
    self._moveSelectCounts = 0
    --MyHandCardsCustom.super.init(self)

    self._FriendCardsCount = 0
    self._FriendCards            = {}
    self._friendCardObjs = {}
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    --惯蛋添加end

    
    self:_adaptCardStartPosition() --自适应位置
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = MyCardHandVertical:create(self._drawIndex, self, i)
        self._friendCardObjs[i] = MyCardHand:create(self._drawIndex, self, i)
    end

    self:resetSKHandCards()

    for i = 1, self._gameController:getChairCardsCount() do
        local card = self._friendCardObjs[i]
        if card then
            card:resetCard()
        end
    end
end

--让手牌位置处于水平居中
function MyHandCardsCustom:_adaptCardStartPosition()
    local offsetX = 0
    if self._gameController then
        offsetX = (self._gameController:getWidthOfOperatePanel() - 1280) / 2
    end
    local newCardStartPosXVertical = VerticalCard.CARD_NOMAL_START_X_RAW + offsetX
    local newCardStartPosX = SKGameDef.SK_CARD_START_POS_X_RAW + offsetX

    --FixedHeight模式下，牌放大了，间隔也需要调整
    local cardScaleVal = UIHelper:getProperScaleOnFixedHeight()
    if cardScaleVal > 1.0 then
        local scaleOffset = cardScaleVal - 1.0

        --手牌竖向间隔调整
        VerticalCard.CARD_NOMAL_START_Y = VerticalCard.CARD_NOMAL_START_Y_RAW + 5
        VerticalCard.CARD_NOMAL_HEIGHT_DISTANCE = VerticalCard.CARD_NOMAL_HEIGHT_DISTANCE_RAW + 7
        VerticalCard.CARD_DRAG_HEIGHT_DISTANCE = VerticalCard.CARD_DRAG_HEIGHT_DISTANCE_RAW + 5

        --手牌横向间隔调整
        local widthIncreasedPerCard = 10 * scaleOffset
        SKGameDef.SK_CARD_COLUMN_INTERVAL = SKGameDef.SK_CARD_COLUMN_INTERVAL_RAW + widthIncreasedPerCard
        newCardStartPosXVertical = newCardStartPosXVertical - 27 * (widthIncreasedPerCard + 1.5) / 2
        newCardStartPosX = newCardStartPosX - 27 * (widthIncreasedPerCard + 1.5) / 2

        --出牌横向间隔调整
        SKGameDef.SK_CARD_THROWN_INTERVAL = SKGameDef.SK_CARD_THROWN_INTERVAL_RAW + 20 * scaleOffset

        --摊牌横向间隔调整
        SKGameDef.SK_CARD_SHOWN_COLUMN_INTERVAL = SKGameDef.SK_CARD_SHOWN_COLUMN_INTERVAL_RAW + 10 * scaleOffset
        --摊牌竖向间隔调整
        SKGameDef.SK_CARD_SHOWN_LINE_INTERVAL = SKGameDef.SK_CARD_SHOWN_LINE_INTERVAL_RAW + 20 * 0.2
    end

    VerticalCard.CARD_NOMAL_START_X = newCardStartPosXVertical
    SKGameDef.SK_CARD_START_POS_X = newCardStartPosX
end

function MyHandCardsCustom:setHandCards(handCards)
    if self._cardsBak ~= nil then
        -- 用于对家手牌显示后，新开局竖排模式下恢复_cards资源对象
        self._cards = self._cardsBak
        self._cardsBak = nil
    end
    self:RUL_SortCard(handCards)
    
    for i = 1, self._cardsCount do
        if not self._cards[i] or not handCards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end
        self._cards[i]:setSKID(handCards[i])
        --self._cards[i]:setHandCardsSmallShapePosition()
    end
    
    self:resetCardsPos()
end

function MyHandCardsCustom:sortHandCardsByPri()
    self.bNeedResetArrageNo = true

    self.nArrageCount = 1
    self:XygInitArrageUnite()
    for k = 1 , self._gameController:getChairCardsCount() do     
        self._cards[k]._ArrageNo = 0
        self._cards[k]._bArraged = false
        self._cards[k]._bBomb = false
    end

    local nArrageCard = {}
    MyCalculator:xygInitChairCards(nArrageCard, self._gameController:getChairCardsCount())
    local count1 = self:RUL_GetInHandArrageCards(nArrageCard)
    local CardID = {}
    local count2 = self:RUL_GetInHandNoArrageCards(CardID)

    self:RUL_SortCard(CardID)
    self:XygAddCardIDs(nArrageCard, CardID, self._gameController:getChairCardsCount())

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(nArrageCard[i])
            count = count + 1
        end
    end

    -- 刷新所有手牌位置
    self:resetCardsPos()
    self._gameController:ope_CheckSelect()
end

-- 重载出来，区别是选出的炸弹牌ID，反转跟 原来按大小排序的ID保持一致
function MyHandCardsCustom:sortHandCardsByBome(CardID, CardCount)
   return MyHandCardsCustom.super.sortHandCardsByBome(self, CardID, CardCount)
end


function MyHandCardsCustom:resetHandCardsInBombMode()
    self.bNeedResetArrageNo = true

    self.nArrageCount = 1
    self:XygInitArrageUnite()
    for k = 1 , self._gameController:getChairCardsCount() do     
        self._cards[k]._ArrageNo = 0
        self._cards[k]._bArraged = false
        self._cards[k]._bBomb = false
    end

    local cardIDs, counts = self:getHandCardIDs()
    local nBestUnite = self:sortHandCardsByBome(cardIDs, counts)

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(cardIDs[i])
            count = count + 1
        end
    end

    self:resetCardsPos()
end

function MyHandCardsCustom:sortHandCardsByBombAndArrange()
    local cardIDs, counts = self:getHandCardIDs()
    local nBestUnite = self:sortHandCardsByBome(cardIDs, counts)
    local nBombNum = 0
    if nBestUnite and #nBestUnite > 0 then
        for i=1, #nBestUnite do 
            if nBestUnite[i].nMainValue <= 0 then  break end
            nBombNum = nBombNum + 1
        end
    end
    if nBombNum == 0 then
        local msg = string.format(self._gameController:getGameStringByKey("G_GAME_ARRAGE_NO_BOMB"))
        local utf8Message = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        if utf8Message then 
            my.informPluginByName({pluginName='TipPlugin',params={tipString = utf8Message, removeTime = 1}})
        end
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


    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(cardIDs[i])
            count = count + 1
        end
    end
    
    local arryBombCardIDs = {}
    for k, v in pairs(nBestUnite) do
        if v.nMainValue <= 0 then
            break
        end
        arryBombCardIDs[k] = {}
        local nCardIDs = v.nCardIDs
        for i = 1, #nCardIDs do
            if nCardIDs[i] == -1 then break end
            table.insert(arryBombCardIDs[k], v.nCardIDs[i])
        end
    end

    for i=#arryBombCardIDs, 1, -1 do 
        local bombCardId = arryBombCardIDs[i]
        self:selectCardsByIDs(bombCardId,  #bombCardId)
        self:OnArrageHandCard_NotResetCardPos() -- 使用不刷新坐标的理牌，后面统一刷新，提高效率
    end
    
    self:OPE_SetBombUniteEx(nBestUnite)
    self:resetCardsPos()
    --self._gameController:ope_CheckSelect()
end

-- 仅仅竖牌的炸弹模式下，设置bBomb的状态，不改变ArrageNo等，避免坐标错乱
function MyHandCardsCustom:OPE_SetBombUniteEx(nBestUnite)
    if not nBestUnite then  return end

    for i=1, #nBestUnite do 
        if nBestUnite[i].nCardsCount <= 0 then
            break
        end
        
        for j = 1, nBestUnite[i].nCardsCount do
            local cardID = nBestUnite[i].nCardIDs[j]
            for k = 1 , self._gameController:getChairCardsCount() do    
                if self._cards[k]:getSKID() == -1  then
                    break
                end

                if self._cards[k]:getSKID() == cardID then
                    self._cards[k]._bBomb = true
                    break
                end
            end
        end
    end
end

function MyHandCardsCustom:sortHandCards()
    -- 2019年10月9日 竖向理牌要求支持炸弹理牌
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    
    local sortFlag = self._gameController:GetSortCardFlag()
    if sortFlag == SKGameDef.SORT_CARD_BY_ORDER then
        self:sortHandCardsByPri()
    elseif sortFlag == SKGameDef.SORT_CARD_BY_BOME then
        self:sortHandCardsByBombAndArrange()
    else
        self:sortHandCardsByPri()
    end
end

function MyHandCardsCustom:quickSortBoom()
    -- 2019年11月8日 在大小模式下 快速理出炸弹
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    self:sortHandCardsByBombAndArrange()
    self._gameController:ResetArrageButton()
end

function MyHandCardsCustom:resetCardsPos()
    self._cardCounts = {}
    self._cardArranges = {}
    self._cardArrangesNotBomb = {}
    self._nCardRowCols = {}

    self._nEndIndexEx           = -1
    self._ColCounts = self:dealSelfHandCardsByCardPriGroup()
    for i = 1, self._cardsCount do
        if self._cards[i] and self._cards[i]:getSKID() ~= -1 then
            if true == self._cards[i]:isEnableTouch() then
                self._cards[i]:setMask(false)
            end
            self._cards[i]:setPosition(self:getHandCardsPosition(i))
        end
    end
end

function MyHandCardsCustom:resetOneCardPos(index)
    if not self:IsIndexVaild(index) then
        return
    end
    MyHandCardsCustom.super.resetOneCardPos(self, index)
end

function MyHandCardsCustom:OPE_SetUniteWhenThrow(nCardID, nCardCount)
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    
    self.bNeedResetArrageNo = true

    local ArragenCardCount = {}

    for i = 1, self.nArrageCount do
        ArragenCardCount[i] = self._nArrageUnite[i].nCardCount
        for j = 1, self._nArrageUnite[i].nCardCount  do
            for k = 1, nCardCount  do
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

    for i = 1, self.nArrageCount do
        for j = 1, (ArragenCardCount[i]-1) do
            if self._nArrageUnite[i].nCards[j]==-1 then
                local bFind=false
                for k = j+1, ArragenCardCount[i] do
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

     for i = 1, (self.nArrageCount -1) do
        if self._nArrageUnite[i].nCardCount==0 then
            for j = i+1, self.nArrageCount  do
                if self._nArrageUnite[j].nCardCount~=0 then
                    SKCalculator:copyTable(self._nArrageUnite[i], self._nArrageUnite[j])
                    self:XygInitArrageUniteByIndex(j)
                    break
                end
            end
        end
    end

    -- 手牌遇到cardID = -1 就用后面牌的补上,跟横排的区别是，不能把后面牌的左边拿给前面。 坐标需要后面统一处理
    for i = 1, (self._gameController:getChairCardsCount() - 1) do
        if self._cards[i]:getSKID() == -1 then
            for j = i+1  , self._gameController:getChairCardsCount() do
                if self._cards[j]:getSKID() ~= -1 then
                    self._cards[i]:setSKID(self._cards[j]:getSKID())
                    self._cards[i]._ArrageNo = 0
                    self._cards[i]._bArraged = false
                    self._cards[i]._bBomb = false
                    self._cards[j]:clearSKID()
                    break
                end
            end           
        end
    end

    --getMyArrageCardIDsWithBomb
    local nArrageBombCardIDs, nCount1, nArrageNotBombCardIDs, nCount2 = self:DivideMyArrageCardIDsByBombType()
    -- 理牌的炸弹组合要逆向遍历
    --for i = 1, #nArrageBombCardIDs do
    for i=#nArrageBombCardIDs, 1, -1 do 
        local nTempCardIDs = nArrageBombCardIDs[i]
        local nTempCount = #nArrageBombCardIDs[i]
        self:selectCardsByIDs(nTempCardIDs, nTempCount)
        self:OnArrageHandCardBase(true)
    end

    -- 理牌的非炸弹组合要逆向遍历
    for i=#nArrageNotBombCardIDs, 1, -1 do 
        local nTempCardIDs = nArrageNotBombCardIDs[i]
        local nTempCount = #nArrageNotBombCardIDs[i]
        self:selectCardsByIDs(nTempCardIDs, nTempCount)
        self:OnArrageHandCardBase(false)
    end

    self:resetCardsPos()
    self._gameController:ope_CheckSelect()

end

function MyHandCardsCustom:ThrowEndSort()

    -- 与SK层的ThrowEndSort区别
    self._cardCounts = {}
    self._cardArranges = {}
    self._cardArrangesNotBomb = {}
    self._nCardRowCols = {}

    self._ColCounts = self:dealSelfHandCardsByCardPriGroup()
    local posArr = {}
    for i = 1, self._cardsCount do
    -- 先计算出所有手牌坐标位置，下一步刷新的时候快一点
        table.insert(posArr, self:getHandCardsPosition(i))
    end

    for i = 1, self._cardsCount do
        if self._cards[i] and self._cards[i]:getSKID() ~= -1 then
            if not self._gameController._bAutoPlay then 
                self._cards[i]:setMask(false)
             end
            self._cards[i]:setPositionNoAciton(posArr[i])
        end
    end

end

-- 获取整理的所有手牌 
function MyHandCardsCustom:getMyArrageCards()
    local cards = {}
    local count = 0
    for i = 1, self._cardsCount do
        if self._cards[i] then
            local isArrange = self._cards[i]._bArraged
            if isArrange then 
                count = count + 1
                cards[count] = self._cards[i]:getSKID()
            end 
        end
    end
    return cards, count
end

function MyHandCardsCustom:DivideMyArrageCardIDsByBombType()
    local nArrageBombCards = {}
    local nArrageCardCount = 0

    local nArrageNotBombCards = {}
    local nArrageNotBombCardCount = 0
    if self.nArrageCount <= 0 then return nArrageBombCards, nArrageCardCount, nArrageNotBombCards, nArrageNotBombCardCount end

    local whenThrowEndArrageCard = {}

    for i = 1 , self.nArrageCount do
        local nCardIDs = self._nArrageUnite[i].nCards
        local nCardCount = self._nArrageUnite[i].nCardCount

        if true == self:isBombType(nCardIDs, nCardCount) then  
         -- 提取理牌的 炸弹组合
            local tempBombCardArr = {}
            for _,v in pairs(nCardIDs) do 
                if -1 ~= v then
                    table.insert(tempBombCardArr, v)
                    table.insert(whenThrowEndArrageCard, v)

                    nArrageCardCount = nArrageCardCount + 1
                end
            end
            table.insert(nArrageBombCards, tempBombCardArr)
        else
            -- 提取理牌的 非炸弹组合
            local tempNotBombCardArr = {}
            for _,v in pairs(nCardIDs) do 
                if -1 ~= v then
                    table.insert(tempNotBombCardArr, v)
                    table.insert(whenThrowEndArrageCard, v)
                    nArrageNotBombCardCount = nArrageNotBombCardCount + 1
                end
            end
            table.insert(nArrageNotBombCards, tempNotBombCardArr)
        end
    end
    self._WhenThrowEndArrageCard = whenThrowEndArrageCard   -- 这是为了兼容老，sorthandcards的时候有用到
    self._WhenThrowEndArrageCardCount = nArrageCardCount + nArrageNotBombCardCount

    return  nArrageBombCards, nArrageCardCount, nArrageNotBombCards, nArrageNotBombCardCount
end

-- 获取非整理的所有手牌
function MyHandCardsCustom:getMyNotArrageCards()
   local cards = {}
    local count = 0
    for i = 1, self._cardsCount do
        if self._cards[i] then
            local isArrange = self._cards[i]._bArraged
            if not isArrange then 
                count = count + 1
                cards[count] = self._cards[i]:getSKID()
            end 
        end
    end
    return cards, count
end

function MyHandCardsCustom:getMyArrageCardArrageNo(nCardID)
    local nArrageNo = 1
    for i = 1 , self.nArrageCount do
        for j = 1 , self._nArrageUnite[i].nCardCount do
            if self._nArrageUnite[i].nCards[j] == nCardID then
                nArrageNo = i
                return nArrageNo  
            end
        end
    end 
   
    return nArrageNo  
end

function MyHandCardsCustom:getStartEndIndexFromCardsArrages(tblCardsArrages, nCardID)
    if nil == tblCardsArrages or nil == next(tblCardsArrages) then return false end

    local groupID = 0
    local nRow = 0
    for k, v in pairs(tblCardsArrages) do 
        if type(v)== 'table' then
            local cardsArr = v.cardArr
            for i=1, #cardsArr do
                if cardsArr[i].cardId == nCardID then
                    groupID = k
                    nRow = i
                    break
                end
            end
        end
    end

    if groupID > 0 then
        local stIndex = 1
        local EdIndex = #tblCardsArrages[groupID].cardArr
        if nRow > 0 and nRow <= self._linesLimit and EdIndex > self._linesLimit  then
            EdIndex = self._linesLimit
        elseif nRow > 0 and nRow > self._linesLimit then    -- 如果点击牌实际存在于一超出限制的数组中。
            stIndex = self._linesLimit * math.floor(nRow/self._linesLimit) + 1  -- 向下取整
            local aMaxValue = math.ceil(nRow/self._linesLimit) * self._linesLimit --向上取整,并取得该列最顶部的牌
            EdIndex = math.min(EdIndex, aMaxValue)
        end

        local StartIndex = tblCardsArrages[groupID].cardArr[stIndex].index
        local EndIndex = tblCardsArrages[groupID].cardArr[EdIndex].index
        return true, StartIndex, EndIndex
    end
    return false
end

function MyHandCardsCustom:getCardIndex(cardId)
    return MyCalculator:getCardIndex(cardId)
end

function MyHandCardsCustom:maskAllHandCardsEX(bMask)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            local bMaskBefore = self._cards[i]:isMask()
            self._cards[i]:setMask(bMask)
            self._cards[i]:setEnableTouch(not bMask)

            -- 解决先选中牌，其他玩家出牌后，本是选择的牌，结果没有被mask。 横向由于是向上凸出的，所以没有问题。
            if bMaskBefore or self._cards[i]:isSelectCard() then
                self._cards[i]:setMask(true)
            end
        end
    end
end



--/********************************************************************/
--/******               手牌点击事件                           *******/
--/********************************************************************/
-- rewrite touchBegan
function MyHandCardsCustom:touchBegan(x, y)
    -- 竖向排列后，有很多重叠问题，根据_count逆向遍历需要做如下处理
    --self.lastMoveX = x
    --self.lastMoveY = y

    local touchcardIDArr = {}
    local firstIndex = 0
    for i = self._cardsCount, 1, -1 do
        if self._cards[i] and self._cards[i]:containsTouchLocation(x, y) then
            local inHandsGroupId = self._cards[i].inHandsGroupId
            local touchCard = {index=i, groupId = inHandsGroupId}

            if touchcardIDArr[1] and touchcardIDArr[1].groupId ~= inHandsGroupId then
                break
            end
            table.insert(touchcardIDArr, touchCard)
        end
    end -- 统计出被点击到的所有牌，过滤重叠牌并记录DrawIndex到数组 add by wuym

    firstIndex = touchcardIDArr[#touchcardIDArr].index
    self._touchBeganIndex = firstIndex

    if nil == next(self._moveIndexTotalArr) then
        table.insert(self._moveIndexTotalArr, self._touchBeganIndex) -- 给move的情况使用  
    end

    if nil == self._moveUniqueTable[firstIndex] then
        if self._cards[firstIndex] and self._cards[firstIndex]:isMask() and self._cards[firstIndex]:isEnableTouch() then
            self._cards[firstIndex]:setMask(false)
            self._cards[firstIndex]:unSelectCard()
        else
            self._cards[firstIndex]:setMask(true)
        end
        self._moveSelectCounts = self._moveSelectCounts + 1
        self._moveUniqueTable[firstIndex] = self._moveSelectCounts
    end


    --if self._cards[firstIndex]:isEnableTouch() then
    --    self._cards[firstIndex]:setMask(true)
    --end
end

-- rewrite touchMove
function MyHandCardsCustom:touchMove(x, y)
--[[    if math.abs(self.lastMoveX - x) < 10 and math.abs(self.lastMoveY- y) < 10 then
        print("------- move too little distance (x"..math.abs(self.lastMoveX - x)..', '..math.abs(self.lastMoveY- y))
        return
    end

    self.lastMoveX = x
    self.lastMoveY = y
]]--

    local touchcardIDArr = {}
    local touchCardIndex = -1
    local centerPos = display.center
    if true --[[x >= centerPos.x]] then
        for i = self._cardsCount, 1, -1 do
            if self._cards[i] and self._cards[i]:containsTouchLocation(x, y) then
                local inHandsGroupId = self._cards[i].inHandsGroupId
                local touchCard = {index=i, groupId = inHandsGroupId}

                if touchcardIDArr[1] and touchcardIDArr[1].groupId ~= inHandsGroupId then
                    -- 横向移动的时候，检测到列变化就不需要继续遍历
                    break
                end
                table.insert(touchcardIDArr, touchCard)
            
                if #touchcardIDArr >= self._linesLimit then
                    break -- 此条件作用，可以避免同一列移动时，其他列多余的遍历
                end
            else
                if #touchcardIDArr > 0 then
                    break
                end
            end
        end
        touchCardIndex = touchcardIDArr[#touchcardIDArr].index
    --[[else
        for i = 1, self._cardsCount do
            if self._cards[i] and self._cards[i]:containsTouchLocation(x, y) then
                local inHandsGroupId = self._cards[i].inHandsGroupId
                local touchCard = {index=i, groupId = inHandsGroupId}

                if touchcardIDArr[1] and touchcardIDArr[1].groupId ~= inHandsGroupId then
                    -- 横向移动的时候，检测到列变化就不需要继续遍历
                    break
                end
                table.insert(touchcardIDArr, touchCard)
            
                if #touchcardIDArr >= self._linesLimit then
                    break -- 此条件作用，可以避免同一列移动时，其他列多余的遍历
                end
            else
                if #touchcardIDArr > 0 then
                    break
                end
            end
        end
        dump(touchcardIDArr)
        touchCardIndex = tempTouchcardIDArr[1].index
        ]]
    end

    if -1 == touchCardIndex then
        return
    end

    local notFirstMoved = true
    if nil == self._moveUniqueTable[touchCardIndex] then
        if self._cards[touchCardIndex] and self._cards[touchCardIndex]:isMask() and self._cards[touchCardIndex]:isEnableTouch() then
            ------self._cards[touchCardIndex]:setMask(false)
            self._cards[touchCardIndex]:unSelectCard()
        else
            ------self._cards[touchCardIndex]:setMask(true)
            self._cards[touchCardIndex]:selectCard()
        end
        self._moveSelectCounts = self._moveSelectCounts + 1 
        self._moveUniqueTable[touchCardIndex] = self._moveSelectCounts
        notFirstMoved = false
    end

     if next(self._moveIndexTotalArr) ~= nil then
        local lastCardIndex = self._moveIndexTotalArr[#self._moveIndexTotalArr]
        if lastCardIndex ~= touchCardIndex then
            -- 执行到这里，touchIndex下标对应的_moveUniqueTable里面肯定有值
            if notFirstMoved == true then
                local nearestCardIndex = self._moveIndexTotalArr[#self._moveIndexTotalArr]
                for k,v in pairs(self._moveUniqueTable) do
                    if v > self._moveUniqueTable[touchCardIndex] then
                        --self._cards[nearestCardIndex]:setMask(false)
                        self._cards[nearestCardIndex]:unSelectCard()
                        self._moveUniqueTable[k] = nil
                        table.remove(self._moveIndexTotalArr, table.maxn(self._moveIndexTotalArr))
                        return
                    end
                end
            end
            table.insert(self._moveIndexTotalArr, touchCardIndex)
        end
    else
        table.insert(self._moveIndexTotalArr, touchCardIndex)
    end

end

-- rewrite touchEnd
function MyHandCardsCustom:touchEnd(x, y)
    local card              = nil
    local selectCardsIndex       = {}
    local selectCount       = 0
    local unSelectCount     = 0

    --MyCalculator:xygInitChairCards(selectCardsIndex, self._gameController:getChairCardsCount())
    local bHit = false
    for i = 1, self._cardsCount do
        if self._cards[i] and self._cards[i]:isMask() and self._cards[i]:isEnableTouch() then
            bHit = true
            --self._cards[i]:setMask(false)
            if self._cards[i]:isSelectCard() and self._touchBeganIndex == i then
                self._cards[i]:unSelectCard()
                unSelectCount = unSelectCount + 1
            else
                self._cards[i]:selectCard()
                card            = self._cards[i]
                selectCount     = selectCount + 1
                selectCardsIndex[selectCount]  = i
            end
        end
    end

    if self._touchBeganIndex > 0 then
        local beginGroupID = self._cards[self._touchBeganIndex].inHandsGroupId
        local minIndex = self._touchBeganIndex
        local maxIndex = 0
        ----------dump(self._moveIndexTotalArr)
        if next(selectCardsIndex) ~= nil then
            minIndex = selectCardsIndex[1]
            maxIndex = selectCardsIndex[#selectCardsIndex]
            -- 同一列移动的优化
            if self._cards[minIndex].inHandsGroupId == self._cards[maxIndex].inHandsGroupId and #self._moveIndexTotalArr > 1 then
                for i=minIndex, maxIndex do 
                    if not self._cards[i]:isMask() and self._cards[i].inHandsGroupId == beginGroupID then
                        ----------print("mask.."..i)
                        self._cards[i]:selectCard()
                    end
                end
            end
        end
    end
    -- 竖向排列，不需要辅助选牌功能，避免操作麻烦。 这是和MyHandCards的touchEnd的区别
    if bHit then
        for k,v in pairs(self._moveIndexTotalArr) do
           self:adjustPostionWhenTouch(v) 
        end

        --local touchIndex = self._moveIndexTotalArr[1]
        --local onlyOneSelect = table.maxn(self._moveIndexTotalArr)
        --self:onClickEventAssistSelectCard(touchIndex,selectCount, onlyOneSelect, selectCardsIndex)

        self._gameController:playGamePublicSound("Snd_HitCard.mp3")
    end
    self._moveUniqueTable = {}
    self._moveIndexTotalArr = {}
    self._moveSelectCounts = 0

    self._gameController:ope_CheckSelect()
    self._touchBeganIndex = -1  -- 重要：如果这里不清，会引起理牌点击后少选了一张牌
end

function MyHandCardsCustom:OPE_AssitSelect(selectCardIDs)
    -- 增加了压牌功能后，需要屏蔽一下辅助选牌，否则理牌选择有影响。无法取消
    return false
end

-- /**** 点击手牌的动画效果 ******/
function MyHandCardsCustom:adjustPostionWhenTouch(touchIndex)
    if -1 == touchIndex then
        return
    end

    local nRow, nCol = self:getSelfHandCardsLocationCustom(touchIndex)
    local cardId = self._cards[touchIndex]:getSKID()

    local StartCardIndex = 0
    local EndCardIndex = 0
    local bFind = false

    -- 先从理牌区找
    if false == bFind then
        bFind, StartCardIndex, EndCardIndex = self:getStartEndIndexFromCardsArrages(self._cardArranges, cardId)
    end
    --  再从理牌区的非炸弹找
    if false == bFind then
        bFind, StartCardIndex, EndCardIndex = self:getStartEndIndexFromCardsArrages(self._cardArrangesNotBomb, cardId)
    end


    -- 再从普通区找
    if false == bFind then
        local cardIndex = self:getCardIndex(cardId)
        local indexFindInNomal = 0
        if self._cardCounts[cardIndex] and self._cardCounts[cardIndex].cardArr then
            local num = #self._cardCounts[cardIndex].cardArr
            for i=1, num do 
                if self._cardCounts[cardIndex].cardArr[i].cardId == cardId then
                    indexFindInNomal = i
                    break
                end
            end

            if 0 ~= indexFindInNomal then
                if num <= self._linesLimit then
                    StartCardIndex = self._cardCounts[cardIndex].cardArr[1].index
                    EndCardIndex = self._cardCounts[cardIndex].cardArr[num].index
                else
                    if indexFindInNomal <= self._linesLimit then
                        StartCardIndex = self._cardCounts[cardIndex].cardArr[1].index
                        EndCardIndex = self._cardCounts[cardIndex].cardArr[self._linesLimit].index
                    else
                        StartCardIndex = self._cardCounts[cardIndex].cardArr[self._linesLimit + 1].index
                        EndCardIndex = self._cardCounts[cardIndex].cardArr[num].index
                    end
                end

            end
        end 
    end

    if 0 == StartCardIndex or nil == StartCardIndex then return end

    local standX = self._cards[StartCardIndex]._pPoint.x
    local standY = self._cards[StartCardIndex]._pPoint.y
    if not self._cardHeight then
        self._cardHeight = self._cards[1]:getContentSize().height
    end
    for i = StartCardIndex, EndCardIndex do
        self._cards[i]:setPosition(cc.p(standX, standY+(i-StartCardIndex)*VerticalCard.CARD_DRAG_HEIGHT_DISTANCE))
    end
end

-- 混搭理牌
function MyHandCardsCustom:OnArrageHandCardMixture(nCardID, nCardCount)
    if nCardCount == 0  then
        return
    end

    local ArragenCardCount = {}
    for i = 1, self.nArrageCount do
        ArragenCardCount[i] = self._nArrageUnite[i].nCardCount
        for j = 1, self._nArrageUnite[i].nCardCount  do
            for k = 1, nCardCount do
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

    for i = 1, self.nArrageCount  do
        for j = 1, (ArragenCardCount[i] -1) do
            if self._nArrageUnite[i].nCards[j]==-1 then
                local bFind=false
                for k = j+1, ArragenCardCount[i]  do
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

    for i = 1, (self.nArrageCount -1) do
        if self._nArrageUnite[i].nCardCount==0 then
            for j = i+1, self.nArrageCount do
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
    MyCalculator:copyTable(temp, self._nArrageUnite)
    self:XygInitArrageUnite()
    for i = 2 , self._gameController:getChairCardsCount() do
        MyCalculator:copyTable(self._nArrageUnite[i], temp[i-1])

        if temp[i-1].nCardCount ~= 0 then
            self.nArrageCount = self.nArrageCount+1
        end
    end
    
    for i = 1, self.nArrageCount do
        if self._nArrageUnite[i].nCardCount==0 then
            if nCardCount > 0 then
                MyCalculator:copyTable(self._nArrageUnite[i].nCards, nCardID)
                self._nArrageUnite[i].nCardCount = nCardCount
                self._nArrageUnite[i].bBomb = false
                self._nArrageUnite[i].bArrage = true

                self.nArrageCount = self.nArrageCount+1
            end
            break
        end
    end

    -- 到这一步，self_nArrageUnite已经整理出了最新的组合
    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard() 
    end

    local nArrageBombCardIDs, nCount1, nArrageNotBombCardIDs, nCount2 = self:DivideMyArrageCardIDsByBombType()
    -- 理牌的炸弹组合要逆向遍历
    -- 混合理牌：如果炸弹拆开后仍是炸弹，则不需要动它们
    --for i = 1, #nArrageBombCardIDs do
    for i=#nArrageBombCardIDs, 1, -1 do 
        local nTempCardIDs = nArrageBombCardIDs[i]
        local nTempCount = #nArrageBombCardIDs[i]
        self:selectCardsByIDs(nTempCardIDs, nTempCount)
        self:OnArrageHandCardBase(true)
    end

    -- 混合理牌：左边的炸弹拆开变成了非炸弹，这种情况需要挪到右边，否则cardID和位置对应不上就会乱了套
    -- 理牌的非炸弹组合要逆向遍历
    for i=#nArrageNotBombCardIDs, 1, -1 do 
        local nTempCardIDs = nArrageNotBombCardIDs[i]
        local nTempCount = #nArrageNotBombCardIDs[i]
        self:selectCardsByIDs(nTempCardIDs, nTempCount)
        self:OnArrageHandCardBase(false)
    end
end

function MyHandCardsCustom:OnArrageHandCardBase(bBombTypeIn)
    local nSelectCardID, nCount =  self:getSelectCardIDs()
    if nCount == 0 then
        return
    end
    self.bNeedResetArrageNo = true
    
    local nTotalCardIDs = {}
    local nArrageCardID = {}
    MyCalculator:xygInitChairCards(nArrageCardID, self._gameController:getChairCardsCount())
    self:XygAddCardIDs(nArrageCardID, nSelectCardID, self._gameController:getChairCardsCount())

    local nCardID={}
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(nCardID, i, self._cards[i]:getSKID())
    end
    self:XygRemoveCardIDs(nCardID, nArrageCardID, self._gameController:getChairCardsCount())
    
    local bArrageBombType = true
    if nil == bBombTypeIn then
        bArrageBombType = self:isBombType(nSelectCardID, nCount)
    else
        bArrageBombType = bBombTypeIn
    end

    if true == bArrageBombType then
        self:XygAddCardIDs(nArrageCardID, nCardID, self._gameController:getChairCardsCount())
        nTotalCardIDs = nArrageCardID
    else
        self:XygAddCardIDs(nCardID, nArrageCardID, self._gameController:getChairCardsCount())
        nTotalCardIDs = nCardID
    end
    

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(nTotalCardIDs[i])
            count = count + 1
            if self._gameController._bAutoPlay then 
                self._cards[i]:setMask(true)
            end
        end

    end

    self:OPE_SetArrageUnite(nSelectCardID, nCount)
    self:OPE_MaskCardForArrage()
  
    -- 刷新所有手牌位置
    --self:resetCardsPos()
    --self._gameController:ope_CheckSelect()

end

function MyHandCardsCustom:OnArrageHandCard()
    local nSelectCardID, nCount, bAllArrage, nArrageCardIDs =  self:getSelectCardIDsEx()
    if nCount == 0 then
        local msg = string.format(self._gameController:getGameStringByKey("G_GAME_ARRAGE_SELECT_FIRST"))
        local utf8Message = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        if utf8Message then 
            my.informPluginByName({pluginName='TipPlugin',params={tipString = utf8Message, removeTime = 1}})
        end
        return
    end
    self.bNeedResetArrageNo = true
    
    if false and nCount > self._linesLimit then
        -- 一次性选中的牌超过 单次上限，则不处理。 否则还需要考虑很多情况
        local msg = string.format(self._gameController:getGameStringByKey("G_GAME_ARRAGE_CARDS_LIMIT"), self._linesLimit)
        local utf8Message = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        if utf8Message then 
            my.informPluginByName({pluginName='TipPlugin',params={tipString = utf8Message, removeTime = 1}})
        end
        return
    end

    if #nArrageCardIDs > 0 and nCount > #nArrageCardIDs then
        -- 理牌有混选的时候，需要处理
        self:OnArrageHandCardMixture(nSelectCardID, nCount)
    else
        -- 选中的全是普通牌 或者 全是理牌
        self:OnArrageHandCardBase(nil)
    end

    self:resetCardsPos()
    self._gameController:ope_CheckSelect()
end

function MyHandCardsCustom:OnArrageHandCard_NotResetCardPos()
    local nSelectCardID, nCount, bAllArrage, nArrageCardIDs =  self:getSelectCardIDsEx()
    if nCount == 0 then
        return
    end
    self.bNeedResetArrageNo = true

    if #nArrageCardIDs > 0 and nCount > #nArrageCardIDs then
        -- 理牌有混选的时候，需要处理
        self:OnArrageHandCardMixture(nSelectCardID, nCount)
    else
        -- 选中的全是普通牌 或者 全是理牌
        self:OnArrageHandCardBase(nil)
    end
end


--/********************************************************************/
--/******               手牌坐标计算部分                        *******/
--/********************************************************************/

function MyHandCardsCustom:getMyArrageCardsIndexByID()
    local cardsIndex = {}
    local count = 0
    for i = 1, self._cardsCount do
        if self._cards[i] then
            local isArrange = self._cards[i]._bArraged
            if isArrange then 
                count = count + 1
                local cardID = self._cards[i]:getSKID()
                
                cardsIndex[cardID] = i
            end 
        end
    end
    return cardsIndex, count
end

-- 理牌组合中区分是否是炸弹组合，并组装成竖排需要的数据结构
-- param1: 是否炸弹  param2: 以第几张牌为基准  param3: 以第几列为基准
function MyHandCardsCustom:buildCardArragesDivByBomb(isBombUnite, nCardIndex, nExistCols)
    local nArrageBombCards = {}
    if self.nArrageCount <= 1 then
        local count = 0
        return nArrageBombCards, count 
    end

    --local nMyCardsIndex, nMyCardCount = self:getMyArrageCardsIndexByID()


    local nCardRowCol = {}  -- 根据牌的索引index（第几张）存储行列

    local nCardArrageCount = 1 -- 记录理牌拆分出炸弹的组合后，在手牌中的索引
    local nColIndex = 1
    if isBombUnite == true then
        for i = 1 , self.nArrageCount do
            local nCardIDs = self._nArrageUnite[i].nCards
            local nCardCount = self._nArrageUnite[i].nCardCount

            if nCardCount > 0 and isBombUnite == self:isBombType(nCardIDs, nCardCount) then   -- 如果是炸弹组合
                local newCardArr = {}
                newCardArr.cardArr = {}
                local bNeedInsert = false
                for k,v in pairs(nCardIDs) do 
                    if -1 ~= v then
                        --local cardDic = {cardId=v, index=nMyCardsIndex[v]}   -- index 是记录手牌的索引 1 - 27                 
                        local cardDic = {cardId=v, index=nCardIndex + nCardArrageCount}   -- index 是记录手牌的索引 1 - 27                 
                        table.insert(newCardArr.cardArr, cardDic)
                        -- 记下每张理牌的行列
                        local cardRowCol = {row = k, col=nColIndex + nExistCols}
                        nCardRowCol[cardDic.index] = cardRowCol
                    
                        nCardArrageCount = nCardArrageCount + 1
                        bNeedInsert = true
                    else
                        break
                    end
                end

                if bNeedInsert == true then
                    newCardArr.colIndex = nColIndex   -- 第几列
                    nColIndex = nColIndex + 1
                    table.insert(nArrageBombCards, newCardArr)
                end
            end
        end
    else
        for i = self.nArrageCount , 1, -1 do
            local nCardIDs = self._nArrageUnite[i].nCards
            local nCardCount = self._nArrageUnite[i].nCardCount

            -- nCardCount > 0 条件可以减少一次isBombType的执行。提高效率
            if nCardCount > 0 and isBombUnite == self:isBombType(nCardIDs, nCardCount) then   -- 如果是fei炸弹组合
                local newCardArr = {}
                newCardArr.cardArr = {}
                local bNeedInsert = false
                for k,v in pairs(nCardIDs) do 
                    if -1 ~= v then
                        --local cardDic = {cardId=v, index=nMyCardsIndex[v]}   -- index 是记录手牌的索引 1 - 27                 
                        local cardDic = {cardId=v, index=nCardIndex + nCardArrageCount}   -- index 是记录手牌的索引 1 - 27                 
                        table.insert(newCardArr.cardArr, cardDic)
                        -- 记下每张理牌的行列
                        local cardRowCol = {row = k, col=nColIndex + nExistCols}
                        nCardRowCol[cardDic.index] = cardRowCol
                    
                        nCardArrageCount = nCardArrageCount + 1
                        bNeedInsert = true
                    else
                        break
                    end
                end

                if bNeedInsert == true then
                    newCardArr.colIndex = nColIndex   -- 第几列
                    nColIndex = nColIndex + 1
                    table.insert(nArrageBombCards, newCardArr)
                end
            end
        end

    end
    if #nArrageBombCards > 0 then
        nArrageBombCards.iCount = 0
        for i=1, #nArrageBombCards do 
            nArrageBombCards.iCount = nArrageBombCards.iCount + 1
            nArrageBombCards[i].colIndex = nArrageBombCards.iCount
            if nArrageBombCards.iCount > i then
            -- 这里是针对第二组超出limit情况，需要更新limit以内的列，否则会和前一列的超出部分重合
                local rowCount = math.min(#nArrageBombCards[i].cardArr, self._linesLimit) 
                for iRow = 1, rowCount do
                    local nIndex = nArrageBombCards[i].cardArr[iRow].index
                    local cardRowCol = {row = iRow, col=nArrageBombCards[i].colIndex + nExistCols}
                    nCardRowCol[nIndex] = cardRowCol  
                end
            end
            if self._isSupportLinesLimit and #nArrageBombCards[i].cardArr > self._linesLimit then -- 理论上炸弹不会超过8个，如果self._linesLimit=8
                nArrageBombCards.iCount = nArrageBombCards.iCount + 1   -- 总的列数加1
                nArrageBombCards[i].colIndexEx = nArrageBombCards.iCount 

                local tempCount = 0
                for nRow=self._linesLimit + 1, #nArrageBombCards[i].cardArr do
                    local nIndex = nArrageBombCards[i].cardArr[nRow].index
                    local nCalcRow = math.mod(nRow, self._linesLimit)
                    if 0 == nCalcRow then
                        nCalcRow = self._linesLimit
                    end
                    if 1 == nCalcRow then -- 求摸等于1后，表示另起一列
                        if 0 == tempCount then  tempCount = clone(nArrageBombCards.iCount) end

                        local nColOffset = math.floor(nRow/self._linesLimit) - 1
                        nArrageBombCards.iCount = tempCount + nColOffset -- 例：一次性选中16张以上，nColOffset 会大于0
                    end

                    local cardRowCol = {row = nCalcRow, col=nArrageBombCards.iCount + nExistCols}
                    nCardRowCol[nIndex] = cardRowCol    
                end
            end 
        end
    end

    for k,v in pairs(nCardRowCol) do 
        self._nCardRowCols[k] = v
    end
    
    return  nArrageBombCards, nCardArrageCount - 1
end

-- 普通模式下预处理所有手牌，得到分组
function MyHandCardsCustom:dealSelfHandCardsByCardPriGroup()

    --[[
    local arrangeCards, arrangeCounts = self:getMyArrageCards()
    for i = 1, arrangeCounts do
        local index = i
        local cardId = arrangeCards[i]
        local groupId = self:getMyArrageCardArrageNo(cardId)

        if not self._cardArranges[groupId] then
            self._cardArranges[groupId] = {}           
            if not self._cardArranges.iCount then  self._cardArranges.iCount = 0 end
            self._cardArranges.iCount = self._cardArranges.iCount + 1
            self._cardArranges[groupId].colIndex = self._cardArranges.iCount
        end

        if not self._cardArranges[groupId].cardArr then
            self._cardArranges[groupId].cardArr = {}  -- 记录整理的手牌的cardID数组
        end

        local cardDic = {cardId=cardId, index=index}
        table.insert(self._cardArranges[groupId].cardArr, cardDic)

        if self._isSupportLinesLimit and #self._cardArranges[groupId].cardArr > self._linesLimit then -- 超出_linesLimit，另起一列
            if not self._cardArranges[groupId].colIndexEx then
                self._cardArranges.iCount = self._cardArranges.iCount + 1
                self._cardArranges[groupId].colIndexEx = self._cardArranges.iCount
            end
        end
    end
    ]]--
    -- 整理得到炸弹类型的理牌
    local arrangeCards, arrangeCounts = self:buildCardArragesDivByBomb(true, 0, 0)
    self._cardArranges = arrangeCards

    -- 整理得到普通牌
    local noArrageCards, counts = self:getMyNotArrageCards()
    for k = 1, counts  do
        local index = k
        local cardId = noArrageCards[k]
        local cardIndex = self:getCardIndex(cardId)

        if not self._cardCounts[cardIndex] then
            self._cardCounts[cardIndex] = {}
        
            if not self._cardCounts.iCount then  self._cardCounts.iCount = 0 end
            self._cardCounts.iCount = self._cardCounts.iCount + 1   -- 手牌总共由几列
            
            if not self._cardCounts[cardIndex].colIndex then
                self._cardCounts[cardIndex].colIndex = self._cardCounts.iCount -- 记录在第几列
            end
        end
        if not self._cardCounts[cardIndex].cardArr then
            self._cardCounts[cardIndex].cardArr = {}  -- 记录手牌的index数组
        end

        local cardDic = {cardId=cardId, index=index+arrangeCounts}
        table.insert(self._cardCounts[cardIndex].cardArr, cardDic)

        if self._isSupportLinesLimit and #self._cardCounts[cardIndex].cardArr > self._linesLimit then -- 超出_linesLimit，另起一列
            if not self._cardCounts[cardIndex].colIndexEx then
                self._cardCounts.iCount = self._cardCounts.iCount + 1
                self._cardCounts[cardIndex].colIndexEx = self._cardCounts.iCount
            end
        end
    end

    -- 整理得到非炸弹类型的理牌
    local nExistCols = 0
    if self._cardArranges.iCount then  nExistCols = nExistCols + self._cardArranges.iCount end
    if self._cardCounts.iCount then nExistCols = nExistCols + self._cardCounts.iCount end
    local arrangeNotBombCards, arrangeNotBombCounts = self:buildCardArragesDivByBomb(false, arrangeCounts + counts, nExistCols)
    self._cardArrangesNotBomb = arrangeNotBombCards

    local groupCounts = 0
    if self._cardArranges.iCount then
        groupCounts = groupCounts + self._cardArranges.iCount -- 增加理牌后，需要两者的列数相加，否则理牌点击位置偏移
    end

    if self._cardArrangesNotBomb.iCount then
        groupCounts = groupCounts + self._cardArrangesNotBomb.iCount --增加理牌非炸弹区，也需要列数相加
    end

    if not self._cardCounts.iCount then return groupCounts end
    return groupCounts + self._cardCounts.iCount -- 按照牌值分组后，返回总共几列（组）
end

-- 计算普通模式下每张手牌的行列
function MyHandCardsCustom:getSelfHandCardsLocationCustom(index)
    if not self:IsIndexVaild(index) then
        if index == (SKGameDef.SK_CHAIR_CARDS+1) then
            -- 说明此时 开局被进贡，多出了一张牌
            local cardId = self._cards[index]:getSKID()
            local cardIndex = self:getCardIndex(cardId)
            local lines = 1
            local col =  self._ColCounts
            if not self._cardCounts[cardIndex] then
            else
                lines = table.maxn(self._cardCounts[cardIndex].cardArr)
                col  = self._cardCounts[cardIndex].colIndex
            end
            local zlayer = col*8-lines
            self._cards[index]:setCardZOrder(zlayer)
            return lines, col
        else
            return 1,1
        end
    end

    if not next(self._cardCounts) and not next(self._cardArranges)  and not next(self._cardArrangesNotBomb) then
        return 1,1
    end

    local cardId = self._cards[index]:getSKID()
    local cardIndex = self:getCardIndex(cardId)
    --print("index:"..index.."  cardIndex:"..cardIndex)
 
    local lines = 1
    local groupId = 1
    local bFindInArrage = false
--[[
    local groupId = self:getMyArrageCardArrageNo(cardId)
    if self._cardArranges[groupId] then
        -- 保存在_cardArranges里面的是整理过的牌
        for k, v in pairs(self._cardArranges[groupId].cardArr) do
            if v.cardId == cardId then
                lines = k
                bFindInArrage = true
                break
            end
        end
    end
]]-- 
    if self._nCardRowCols  and self._nCardRowCols[index] then
        lines = self._nCardRowCols[index].row
        bFindInArrage = true
    end

    if not bFindInArrage then
        if self._cardCounts[cardIndex] then
            -- 保存在 _cardCounts里面的是没有整理的牌，按照牌索引cardIndex分组
            for k,v in pairs(self._cardCounts[cardIndex].cardArr) do
                if v.cardId == cardId then
                    lines = k
                    break
                end
            end
        else
            local col = self._ColCounts
            return lines, col
        end
    end

    if self._isSupportLinesLimit and lines > self._linesLimit then
        local colEx = 0
        if bFindInArrage then
            colEx = self._nCardRowCols[index].col
        else
            if self._cardArranges.iCount then
                colEx = self._cardArranges.iCount
            end
            colEx = colEx +  self._cardCounts[cardIndex].colIndexEx
        end

        local zlayer = colEx*8-lines + self._linesLimit
        self._cards[index]:setCardZOrder(zlayer)
        return lines-self._linesLimit, colEx
    end

    local col = 0
    if bFindInArrage then
        col = self._nCardRowCols[index].col
    else
        if self._cardArranges.iCount then
            col = self._cardArranges.iCount
        end
        col = col +  self._cardCounts[cardIndex].colIndex
    end

    local zlayer = col*8-lines
    self._cards[index]:setCardZOrder(zlayer)

    return lines, col
end

-- 计算每张手牌坐标
function MyHandCardsCustom:getSelfHandCardsPosition(index)
    local startX, startY = VerticalCard.CARD_NOMAL_START_X, VerticalCard.CARD_NOMAL_START_Y    --左下起点坐标
    if not self:IsIndexVaild(index) then
        if index == (SKGameDef.SK_CHAIR_CARDS+1) then
            -- 说明此时 开局被进贡，多出了一张牌

        else
            return cc.p(startX, startY)
        end
    end

    if not index or index<=0 then return cc.p(startX, startY) end
    if self._ColCounts   < 1 then return cc.p(startX, startY) end
    if not self._cardWidth then
        self._cardWidth =  self._cards[1]:getContentSize().width
    end

    local nNumsPerLine =15
    local nRealCountPerLine = nNumsPerLine    
    if self._ColCounts  > 0 then
        nRealCountPerLine = self._ColCounts 
    end

    local biggsetWidth = (SKGameDef.SK_CARD_PER_LINE - 1) * VerticalCard.CARD_COLUMN_INTERVAL
    local interval = 0
    interval = math.floor((biggsetWidth-self._cardWidth) / (nRealCountPerLine - 1))

    local CUSTOM_INTERVAL_MAX = VerticalCard.CARD_NOMAL_WIDTH_DISTANCE  -- 经验值，调整成50+25
    if CUSTOM_INTERVAL_MAX < interval then    --间隔足够大后两端缩进
        interval = CUSTOM_INTERVAL_MAX
    end

    local width = interval * (nRealCountPerLine - 1)

    startX = startX + math.floor((biggsetWidth - width) / 2)

    local nRow, nCol = 1,1
    nRow, nCol = self:getSelfHandCardsLocationCustom(index)

    self._cards[index].inHandsGroupId = nCol -- 在self.ctrls中记录每张牌在手牌中第几列,在touchBegin中有用
    if not nCol or not nRow then
        return cc.p(startX, startY)
    end

    startX = startX + (nCol-1) * interval-self._cardWidth/2
    startY = startY + nRow* VerticalCard.CARD_NOMAL_HEIGHT_DISTANCE

    --print("index  (nRow, nCol)  (startX: startY:)", index, nRow, nCol, startX, startY)
    return cc.p(startX, startY)
end

function MyHandCardsCustom:IsIndexVaild(index)
    if index > SKGameDef.SK_CHAIR_CARDS then
        return false
    end
    if index > self._cardsCount then
        return false
    end
    if self._cards[index]:getSKID() == -1 then
        return false
    end
    return true
end


function MyHandCardsCustom:sortFriendHandCards()
    -- 竖排模式，显示对家手牌需要 重新设置下Z序， 和小花色图标位置
    MyHandCardsCustom.super.sortFriendHandCards(self)

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if count > self._FriendCardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setCardZOrder(i)
            --self._cards[i]:setHandCardsSmallShapePosition(true)   -- 对家手牌的使用_friendCardObjs后则不需要调整小花色了
            count = count + 1
        end
    end
end

-- 使用的全新的计算排序方式，牌值大小结合花色
function MyHandCardsCustom:RUL_SortCard(nCardID)
    local function comps(a,b)
        if a ~= -1 and b~=-1 then
            local aSortValue = MyCalculator:getSortValue(a, self._gameController._baseGameUtilsInfoManager:getCurrentRank())
            local bSortValue = MyCalculator:getSortValue(b, self._gameController._baseGameUtilsInfoManager:getCurrentRank())
            return aSortValue > bSortValue
        else
            return a > b
        end
    end

    table.sort(nCardID, comps)
end


-- 对家手牌竖排模式下特殊处理
function MyHandCardsCustom:showFriendCards(cards, len)
    self._cardsBak = self._cards
    self._cards = self._friendCardObjs

    self._FriendCardsCount = len
    self._FriendCards = cards
    for i = 1, self._FriendCardsCount do
        if not self._cards[i] or not cards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setSKID(cards[i])
        self._cards[i]:setPositionNoAciton(self:getFriendHandCardsPosition(i))
        --掼蛋添加，显示好友牌都添加蒙版
        self._cards[i]:setEnableTouch(false)
        self._cards[i]:setMask(true)
    end

    self:sortFriendHandCards()
end


-- 该接口用于实现 理牌区的 左炸弹，右非炸弹
-- 建议保留，日后也许有用
function MyHandCardsCustom:AdjustArrageUniteCards()
    if self._nArrageUnite then
        -- clone 一份是为了再调整的过程中，顺序不被打乱
        local tempArrageUnite = clone(self._nArrageUnite)
        for i = self.nArrageCount,1, -1 do
            local nTempCardID = tempArrageUnite[i].nCards
            local nTempCount = tempArrageUnite[i].nCardCount
            
            if nTempCount > 3 then
                local unitDetails = MyCalculator:initCardUnite()
                local cardsCount = MyCalculator:getCardsCount(nTempCardID, nTempCount)
                local bBombType = false
                if true == MyCalculator:calcCardType_Bomb(nTempCardID, nTempCount, cardsCount, unitDetails) then
                    bBombType = true
                elseif true == MyCalculator:calcCardType_TongHuaShun(nTempCardID, nTempCount, cardsCount, unitDetails) then
                    bBombType = true
                elseif true == MyCalculator:calcCardType_SuperBomb(nTempCardID, nTempCount, cardsCount, unitDetails) then
                    bBombType = true
                elseif true == MyCalculator:calcCardType_4King(nTempCardID, nTempCount, cardsCount, unitDetails) then
                    bBombType = true
                end

                if true == bBombType then
                    self:selectCardsByIDs(nTempCardID, nTempCount)
                    self:OnArrageHandCard()
                end
            end
        end
    end
end

function MyHandCardsCustom:isBombType(nCardIDs, nCount)
    local unitDetails = MyCalculator:initCardUnite()
    if not MyCalculator:getUniteDetails(nCardIDs, nCount, unitDetails, MyGameDef.MY_CARD_UNITE_TYPE_TOTAL) then
        return false
    end
    local cardsCount = MyCalculator:getCardsCount(nCardIDs, nCount)
    local bBombType = false
    if true == MyCalculator:calcCardType_Bomb(nCardIDs, nCount, cardsCount, unitDetails) then
        bBombType = true
    elseif true == MyCalculator:calcCardType_TongHuaShun(nCardIDs, nCount, cardsCount, unitDetails) then
        bBombType = true
    elseif true == MyCalculator:calcCardType_SuperBomb(nCardIDs, nCount, cardsCount, unitDetails) then
        bBombType = true
    elseif true == MyCalculator:calcCardType_4King(nCardIDs, nCount, cardsCount, unitDetails) then
        bBombType = true
    end

    return bBombType
end

return MyHandCardsCustom
