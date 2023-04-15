local MyJiSuHandCardsCustom = class("MyJiSuHandCardsCustom", import("src.app.Game.mMyGame.MyHandCardsCustom"))
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")
local MyJiSuCalculator = import("src.app.Game.mMyJiSuGame.MyJiSuCalculator")

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

function MyJiSuHandCardsCustom:ctor(drawIndex, dunIndex, gameController)
    self._dunIndex = dunIndex
    self._zorder = {2000,5000,10000}
    MyJiSuHandCardsCustom.super.ctor(self, drawIndex, gameController)
end

-- 计算每张手牌坐标
function MyJiSuHandCardsCustom:getSelfHandCardsPosition(index)
    local startX, startY = VerticalCard.CARD_NOMAL_START_X, VerticalCard.CARD_NOMAL_START_Y    --左下起点坐标
    local startPosList = {{132.62,22},{347.51,22},{716.35,22}} --每张牌间隔38
    startPosList = {{132.62,22},{374.51,22},{743.35,22}} --每张牌间隔35
    startPosList = {{132.62,22},{401.51,22},{770.35,22}} --每张牌间隔32
    startX, startY = startPosList[self._dunIndex][1],startPosList[self._dunIndex][2]
    if not self:IsIndexVaild(index) then
        if index == (MyJiSuGameDef.SK_CHAIR_CARDS+1) then
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

    local nNumsPerLine =18
    local nRealCountPerLine = nNumsPerLine    
    if self._ColCounts  > 0 then
        nRealCountPerLine = self._ColCounts 
    end

    local biggsetWidth = (MyJiSuGameDef.SK_CARD_PER_LINE - 1) * VerticalCard.CARD_COLUMN_INTERVAL
    local panelWidth = {281.42,434.88,558.32}
    panelWidth = {268,338,408} --每张牌间隔35
    panelWidth = {256,320,384} --每张牌间隔32
    biggsetWidth= panelWidth[self._dunIndex]
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

-- 重载改变zoder
function MyJiSuHandCardsCustom:getSelfHandCardsLocationCustom(index)
    if not self:IsIndexVaild(index) then
        if index == (MyJiSuGameDef.SK_CHAIR_CARDS+1) then
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
            local zlayer = col*8-lines + self._zorder[self._dunIndex]
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

        local zlayer = colEx*8-lines + self._linesLimit + self._zorder[self._dunIndex]
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

    local zlayer = col*8-lines + self._zorder[self._dunIndex]
    self._cards[index]:setCardZOrder(zlayer)

    return lines, col
end

function MyJiSuHandCardsCustom:sortHandCardsByBombAndArrange(inCardIDs)
    local cardIDs = inCardIDs
    local nBestUnite = MyJiSuCalculator:getDunUniteType(cardIDs)

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
        if v.nMainValue <= 0 
        or v.dwCardType == MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_SINGLE then
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

function MyJiSuHandCardsCustom:touchBegan(x, y)
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
    if not next(touchcardIDArr) then
        return
    end
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
function MyJiSuHandCardsCustom:touchMove(x, y)
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
        if not next(touchcardIDArr) then
            return
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

function MyJiSuHandCardsCustom:OnArrageHandCardBase(bBombTypeIn)
    local nSelectCardID, nCount =  self:getSelectCardIDsWithOrder()
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

--用于对急速掼蛋出牌过程的手牌排序
function MyJiSuHandCardsCustom:getSelectCardIDsWithOrder()
    local nSelectCardID, nCount =  self:getSelectCardIDs()
    local uniteTypes = MyJiSuCalculator:getDunUniteType(nSelectCardID)
    local tmpCardIDs = {}
    for i = 1, #uniteTypes do
        for j = 1, uniteTypes[i].nCardsCount do
            table.insert(tmpCardIDs, uniteTypes[i].nCardIDs[j])
        end
    end
    return tmpCardIDs, #tmpCardIDs
end


return MyJiSuHandCardsCustom