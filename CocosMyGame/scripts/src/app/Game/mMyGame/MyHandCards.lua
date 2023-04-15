local SKHandCards = import("src.app.Game.mSKGame.SKHandCards")
local MyHandCards = class("MyHandCards", SKHandCards)

local SKCardHand                = import("src.app.Game.mSKGame.SKCardHand")
local MyCardHand                = import("src.app.Game.mMyGame.MyCardHand")
local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

--local SKCalculator              = import("src.app.Game.mSKGame.SKCalculator")  --惯蛋修改
local SKCalculator              = import("src.app.Game.mMyGame.MyCalculator")

local GamePublicInterface       = import("src.app.Game.mMyGame.GamePublicInterface")

function MyHandCards:init()
    --惯蛋添加begin
    self._FriendCardsCount = 0
    self._FriendCards            = {}
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end
    --惯蛋添加end

    self:_adaptCardStartPositionForHorizontal()
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = MyCardHand:create(self._drawIndex, self, i)
    end

    self:resetSKHandCards()
end

--让手牌位置处于水平居中
function MyHandCards:_adaptCardStartPositionForHorizontal()
    local offsetX = 0
    if self._gameController then
        offsetX = (self._gameController:getWidthOfOperatePanel() - 1280) / 2
    end
    local newCardStartPosX = SKGameDef.SK_CARD_START_POS_X_RAW + offsetX

    --FixedHeight模式下，牌放大了，间隔也需要调整
    local cardScaleVal = UIHelper:getProperScaleOnFixedHeight()
    if cardScaleVal > 1.0 then
        local scaleOffset = cardScaleVal - 1.0

        --手牌横向间隔调整
        local widthIncreasedPerCard = 25 * scaleOffset
        SKGameDef.SK_CARD_COLUMN_INTERVAL = SKGameDef.SK_CARD_COLUMN_INTERVAL_RAW + widthIncreasedPerCard
        newCardStartPosX = newCardStartPosX - 27 * (widthIncreasedPerCard + 1.5) / 2

        --出牌横向间隔调整
        SKGameDef.SK_CARD_THROWN_INTERVAL = SKGameDef.SK_CARD_THROWN_INTERVAL_RAW + 20 * scaleOffset

        --摊牌横向间隔调整
        SKGameDef.SK_CARD_SHOWN_COLUMN_INTERVAL = SKGameDef.SK_CARD_SHOWN_COLUMN_INTERVAL_RAW + 10 * scaleOffset
        --摊牌竖向间隔调整
        SKGameDef.SK_CARD_SHOWN_LINE_INTERVAL = SKGameDef.SK_CARD_SHOWN_LINE_INTERVAL_RAW + 20 * 0.2
    end
    SKGameDef.SK_CARD_START_POS_X = newCardStartPosX
end

function MyHandCards:getMinHandCardsPriForReturn()
    local minPri = 100 -- 大于所有CardPri值
    for i = 1, self._gameController:getChairCardsCount() do
        local curPri = SKCalculator:getCardPriEx(self._cards[i]:getSKID(), self._gameController._baseGameUtilsInfoManager:getCurrentRank(),0);
        if curPri < minPri then
            minPri = curPri
            if minPri <= 9 then break end
        end
    end
    if minPri <= 9 then minPri = 9 end
    return minPri
end


function MyHandCards:OPE_MaskCardForTributeAndReturn()
    self:unSelectCards()
    local SKOpeBtnManager = self._gameController._baseGameScene:getSKOpeBtnManager()
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            self._cards[i]:setMask(false)
            self._cards[i]:setEnableTouch(true)
        end
    end
    if SKOpeBtnManager:isReturnVisible() then
        local minPri = self:getMinHandCardsPriForReturn()
        for i = 1, self._gameController:getChairCardsCount() do
            if self._cards[i] and self._cards[i]:getSKID() ~= -1 then
                if SKCalculator:getCardPriEx(self._cards[i]:getSKID(), self._gameController._baseGameUtilsInfoManager:getCurrentRank(),0) > minPri then               
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

-- 单点事件，在需要轮到出牌时自动选出 一对或者三个
function MyHandCards:onClickEventAssistSelectCard(touchIndex, selectCount, onlyOneSelect, selectCardIDs)
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
        if self._cards[touchIndex]:isSelectCard() then
            self:AssistSelectForCouple_Three(touchIndex)
        end
    end

end

function MyHandCards:touchEnd(x, y)
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
    --弹起牌时，关闭切牌特效
    if next(selectCardIDs) ~= nil then
        local nodeEffect = self._gameController._baseGameScene._gameNode:getChildByTag(MyGameDef.MY_TAG_EFFECT_SORT)
        if nodeEffect then
            nodeEffect:removeFromParent()
            nodeEffect = nil
        end
    end
    
    --self:onClickEventAssistSelectCard(touchIndex, selectCount, onlyOneSelect, selectCardIDs)

	if count == 1 then
		self._gameController:playGamePublicSound("Snd_HitCard.mp3")
	end

    self._gameController:ope_CheckSelect()
end

--des: 压牌时的对子和三张自动提示，优先级低于炸弹提示，且仅仅限于相同的牌只有2张或者3张相同，不论能否压过
--parm: 当前点击这张牌的index
--return:none
function MyHandCards:AssistSelectForCouple_Three(touchIndex)
     local SKOpeBtnManager = self._gameController._baseGameScene:getSKOpeBtnManager()
    local SKHandCardsManager        = self._gameController._baseGameScene:getSKHandCardsManager()
    local waitUnite = self._gameController._baseGameUtilsInfoManager:getWaitUniteInfo()
    -- 1.出牌 2.压牌 3.上家的牌型 4.点击的牌是否张数刚好一致
    if SKOpeBtnManager and SKHandCardsManager then
        if SKOpeBtnManager:isThrowVisible() and (not SKHandCardsManager:isFirstHand()) 
            and (waitUnite.dwComPareType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE or waitUnite.dwComPareType == SKGameDef.SK_CARD_UNITE_TYPE_THREE) then
                
            local clickCardValue = SKCalculator:getCardIndex(self._cards[touchIndex]:getSKID())
             
            local sameCount = 0
            local sameCardIDs = {}

            local selectType = 0
            if waitUnite.dwComPareType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
                selectType = 2
            elseif waitUnite.dwComPareType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                selectType = 3
            end

            for i = 1, self._gameController:getChairCardsCount() do
                local value = SKCalculator:getCardIndex(self._cards[i]:getSKID())
                if value == clickCardValue then
                    sameCount = sameCount + 1
                    sameCardIDs[sameCount] = self._cards[i]:getSKID()
                    if sameCount > selectType then
                        break
                    end
                end
            end

            if sameCount == selectType then
                self:unSelectCards()
                self:selectCardsByIDs(sameCardIDs, sameCount)
            end
        end
    end
end

-- 修正同花顺选择结果：优先使用非"理牌/炸弹"成员,但需尽可能选出已理好的同花顺
function MyHandCards:adjustCardIDForTHSSelect(nCardIDs)
    if not nCardIDs then
        print('adjustCardIDForTHSSelect cardIDs can not be nil')
        return  
    end
    if not next(nCardIDs) then return end
    -- 使用未理出的牌或者不是炸弹的牌替换选出的同花顺
    local normalCards, cardsCount = self:RUL_GetInHandNormalCards()
    local lay = {}
    for i = 1,4 do
        lay[i] = {}
    end
    for i=1, cardsCount do
        if normalCards[i] == -1 then
            break
        end
        local shape = MyCalculator:getCardShape(normalCards[i], 0) + 1
        local index = MyCalculator:getCardIndex(normalCards[i], 0)
        if shape > 0 and shape < 5 and index ~= -1 then
            if not lay[shape][index] then
                lay[shape][index] = {}
            end
            table.insert(lay[shape][index], normalCards[i])
        end
    end

    local jokerCount = 0
    for k,v in pairs(nCardIDs) do
        if v < 0 then
            break
        end
        if MyCalculator:isJoker(v) then
            jokerCount = jokerCount + 1
        end
    end

    for k,v in pairs(nCardIDs) do
        if v == -1 then break end
        local cardIndex = MyCalculator:getCardIndex(v, 0)
        local cardShape = MyCalculator:getCardShape(v) + 1 -- 花色是从0开始,适应此处处理而加了1
        local tempArray = lay[cardShape]
        for nomalCardIndex, ids in pairs(tempArray or {}) do 
            if MyCalculator:isJoker(v) and 2 == jokerCount then
                -- 此情况不做替换
            else
                if cardIndex == nomalCardIndex then
                    nCardIDs[k] = ids[1]
                end
            end
        end
    end

    -- 如果选出的同花顺可以由理出的同花顺替换,则优先使用理出的同花顺
    local isSelectedCardsThs, selectedCardShape, selectedCardThsIdx = self:_isTHS(nCardIDs)
    if isSelectedCardsThs then
        local arrageUnites = self:getArrageCardIDsAllGroup()
        for _, cardIds in pairs(arrageUnites or {}) do
            local isTHS, thsShape, thsIdx = self:_isTHS(cardIds)
            if isTHS and thsShape == selectedCardShape and thsIdx == selectedCardThsIdx then
                for i = 1, 5 do 
                    nCardIDs[i] = cardIds[i]
                end
                break
            end
        end
    end
end

-- 输入牌ID数组,判断是否为同花顺
function MyHandCards:_isTHS(cardIds)
    if type(cardIds) ~= 'table' then
        return false
    end
    local count = 0
    for _, id in pairs(cardIds) do
        if id < 0 then
            break
        end
        count = count + 1
    end
    if count ~= 5 then
        return false
    end

    --
    local jokers = {}
    local not_jokers = {}
    for _, id in pairs(cardIds) do
        if id < 0 then
            break
        end
        if MyCalculator:isJoker(id) then
            table.insert(jokers, id)
        else
            table.insert(not_jokers, id)
        end
    end
    local joker_count = #jokers
    -- 先判断是否是同花色
    local shapes = {[SKGameDef.SK_CS_DIAMOND] = 0, [SKGameDef.SK_CS_CLUB] = 0, [SKGameDef.SK_CS_HEART] = 0, [SKGameDef.SK_CS_SPADE] = 0}
    for _, id in pairs(not_jokers) do
        local shape = MyCalculator:getCardShape(id, 0)
        if type(shapes[shape]) == 'number' then
            shapes[shape] = shapes[shape] + 1
        end
    end
    local theSameShape = nil
    for shape, value in pairs(shapes) do
        if joker_count + value == 5 then
            theSameShape = shape
            break
        end
    end
    if not theSameShape then
        return false
    end
    -- 花色相同时,进一步判断是否是同花顺
    local cardsLay = {}
    MyCalculator:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    for _, id in pairs(not_jokers) do
        local index = MyCalculator:getCardIndex(id, 0)
        if type(cardsLay[index]) == 'number' then
            cardsLay[index] = cardsLay[index] + 1
        end
    end
    --
    local indexed = {13, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 }
    local isTHS = false
    local minIdxOfMaxThs = -1
    for i = 1, 10 do
        local sum = 0
        for j = 0, 4 do
            if cardsLay[indexed[i + j]] == 1 then
                sum = sum + 1
            end
        end
        if sum + joker_count == 5 then
            isTHS = true
            if indexed[i] > minIdxOfMaxThs then
                minIdxOfMaxThs = i
            end
        end
    end
    return isTHS, theSameShape, minIdxOfMaxThs -- 同花顺最小牌的index
end

function MyHandCards:getFriendCardsCount()
    return self._FriendCardsCount
end

function MyHandCards:getMySelfHandCardsCount()
    return self._cardsCount
end

function MyHandCards:zeroFriendCardsCount()
    self._FriendCardsCount = 0
end

function MyHandCards:getArrageCardIDsAllGroup()
    local nGroupCardIDs = {}
    if self.nArrageCount and self.nArrageCount > 0 then
        for i = 1 , self.nArrageCount do
           if self._nArrageUnite[i].nCardCount > 0 then
                table.insert(nGroupCardIDs, clone(self._nArrageUnite[i].nCards))
           end
        end  
    end
    return nGroupCardIDs, table.maxn(nGroupCardIDs)
end

-- 对getSelectCardIDs拓展, 选中牌后，判断选中牌是否全部理中的牌
function MyHandCards:getSelectCardIDsEx()
    local selectCardIDs = {}
    local count = 0
    local arrageCardIDs = {}
    local bAllArrageCards = false
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i]
        and self._cards[i]:isVisible()
        and self._cards[i]:isValidateID(self._cards[i]:getSKID()) then
            if self._cards[i]:isSelectCard() then
                count = count + 1
                selectCardIDs[count] = self._cards[i]:getSKID()
                
                if self._cards[i]._bArraged == true then
                    table.insert(arrageCardIDs, self._cards[i]:getSKID())
                end
            end
        end
    end

    local nArrageCount = #arrageCardIDs
    if count == nArrageCount then
        bAllArrageCards = true
    end

    return selectCardIDs, count, bAllArrageCards, arrageCardIDs
end


-- 2019年4月30日，策划需求：没选中牌执行一键撤销
function MyHandCards:OnResetArrageHandCard()
    -- step1: 判断选中的牌是否满足撤销条件
    local nSelectCardID, nCount, bAllArrage =  self:getSelectCardIDsEx()
    if nCount == 0 then
        return MyHandCards.super.OnResetArrageHandCard(self)
    end
    if bAllArrage ~= true then  -- 选中的牌 不全是理过的牌，则不执行撤销
        return
    end

    -- step2: 统计除去选中牌后，剩余多少张理牌
    local nNewArrageCardIDs = {}
    if self._nArrageUnite and self.nArrageCount > 0 then
        for i=1, self.nArrageCount do 
            nNewArrageCardIDs[i] = {}
            for j=1, self._nArrageUnite[i].nCardCount do
                local bContainInArray = false
                
                for n=1, nCount do
                    if self._nArrageUnite[i].nCards[j] == nSelectCardID[n] then
                        bContainInArray = true
                        break
                    end
                end

                if false == bContainInArray then
                    -- 若不再选中的牌数组里，即剩余的理牌放在nNewArrageCardIDs
                    table.insert(nNewArrageCardIDs[i], self._nArrageUnite[i].nCards[j])
                end
            end
        end
    end

    -- step3: 恢复到大小排序模式
    --self:sortHandCardsByPri()
    local sortFlag = self._gameController:GetSortCardFlag()
    if sortFlag == SKGameDef.SORT_CARD_BY_ORDER then
        self:sortHandCardsByPri()
    elseif sortFlag == SKGameDef.SORT_CARD_BY_BOME then
        self:resetHandCardsInBombMode()
    else
        self:sortHandCardsByPri()
    end

    -- step4: 将剩余的理牌，重新理一遍
    local sortFlag = self._gameController:GetSortCardFlag()
    for n=#nNewArrageCardIDs, 1, -1 do -- 从高到低遍历的顺序，可避免多次操作位置变来变去
        local nTempCardIDs = nNewArrageCardIDs[n]
        if #nTempCardIDs > 0 then
            self:selectCardsByIDs(nTempCardIDs, #nTempCardIDs)
            self:OnArrageHandCard()
        end
    end

    --self:AdjustArrageUniteCards()
end


function MyHandCards:AdjustArrageUniteCards()
    -- do nothing
end

function MyHandCards:sortHandCardsByPri()
    self:sortHandCards()
end


-- 重载出来，区别是选出的炸弹牌ID，反转跟 原来按大小排序的ID保持一致
function MyHandCards:sortHandCardsByBome(CardID, CardCount)
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

    --  与Sk层的sortHandCardsByBome 相比较，修改的部分如下 begin
    local nCount2=1
    for i = 1, self._gameController:getChairCardsCount() do
        if nBestUnite[i].nMainValue <= 0 then  break end
        local tempCardIDs = {}
        -- 剔除数组后面id是 -1 
        for j = 1, nBestUnite[i].nCardsCount  do    
            if -1 == nBestUnite[i].nCardIDs[j] then  break end
            tempCardIDs[j] = nBestUnite[i].nCardIDs[j]
        end
         -- 反转数组
        local reverseTempCardIDs = cc.exports.reverseTable(tempCardIDs) 
        -- 放入nBestID
        for index=1, #reverseTempCardIDs do
            nBestID[nCount2] = reverseTempCardIDs[index]
            nCount2 = nCount2 + 1
        end
    end
    --  ----------------------------------------------- end
    self:XygRemoveCardIDs(nCardID, nBestID, self._gameController:getChairCardsCount())

    self:RUL_SortCard(nCardID)

    self:XygAddCardIDs(nSortCardID, nBestID, self._gameController:getChairCardsCount())
    self:XygAddCardIDs(nSortCardID, nCardID, self._gameController:getChairCardsCount())

    for i = 1, self._gameController:getChairCardsCount()  do
        CardID[i] = nSortCardID[i]
    end


    return nBestUnite
end

function MyHandCards:quickSortBoom()
    -- 2019年11月8日 在大小模式下 快速理出炸弹
    if self._drawIndex ~= self._gameController:getMyDrawIndex() then
        return
    end

    local cardIDs, counts = self:getHandCardIDs()
    local nBombNum = 0
    local nBestUnite = nil
    nBestUnite = self:sortHandCardsByBome(cardIDs, counts)
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

    local cardPoint = {}
    for i = 1, self._gameController:getChairCardsCount() do
        if cardIDs[i] ~= -1 then
            for j=1, self._gameController:getChairCardsCount() do
                if cardIDs[i] == self._cards[j]:getSKID() then               
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
            self._cards[i]:setSKID(cardIDs[i])
            self._cards[i]:setPositionNoAciton(cardPoint[i])
            self:resetOneCardPos(i)
            count = count + 1
        end
    end

    if nBestUnite then
        self:OPE_SetBombArrageUnite(nBestUnite) -- 和OPE_SetBombUnite区别： 把炸弹属性牌带上理牌属性
        self:OPE_MaskCardForArrage()      
    end

    self._gameController:ResetArrageButton()
end

-- 横排模式：设置炸弹属性的同时把 理牌属性也带上
function MyHandCards:OPE_SetBombArrageUnite(nBestUnite)
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
        self._nArrageUnite[nCount].bArrage = true
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

function MyHandCards:findFirst4Bomb()
    --self:setAllCardsEnable(false)

    local inhandCards, cardsCount = self:getHandCardIDs()
    local lay = {}
    SKCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = SKCalculator:preDealCards(inhandCards, cardsCount, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local MyGameUtilsInfoManager    = self._gameController._baseGameUtilsInfoManager
    local rank = MyGameUtilsInfoManager:getCurrentRank()
    local minCardPri = 99999
    local bFind = false
    for i = 1, SKGameDef.SK_LAYOUT_NUM do
        local pri = SKCalculator:getCardIndexPri(i, rank, 0)
        if lay[i]>=4 and pri < minCardPri then
            minCardPri =pri
            bFind = true
        end
    end

    local posX = 0
    for j = 1,self._gameController:getChairCardsCount() do
        if self._cards[j] then
            local pri = SKCalculator:getCardPriEx(self._cards[j]:getSKID(), rank)
            if pri == minCardPri and not self._cards[j]._bArraged then
                self._cards[j]:setMask(false)
                self._cards[j]:setEnableTouch(true)
                posX = self._cards[j]._pPoint.x
            else
                self._cards[j]:setMask(true)
                self._cards[j]:setEnableTouch(false)
            end
        end
    end
    return bFind,posX
end

function MyHandCards:setAllCardsEnable(bEnableTouch)
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] then
            self._cards[i]:setMask(not bEnableTouch)
            self._cards[i]:setEnableTouch(bEnableTouch)
        end
    end
end

function MyHandCards:OnArrageHandCard()
    local nSelectCardID, nCount =  self:getSelectCardIDs()
    local function comps(a, b)
        local cardID_a = math.fmod(a, 54)
        local cardID_b = math.fmod(b, 54)
        return cardID_a > cardID_b 
    end
    table.sort(nSelectCardID, comps)

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

return MyHandCards