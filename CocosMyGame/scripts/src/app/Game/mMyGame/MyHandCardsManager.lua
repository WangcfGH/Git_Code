
local SKHandCardsManager = import("src.app.Game.mSKGame.SKHandCardsManager")
local MyHandCardsManager = class("MyHandCardsManager", SKHandCardsManager)

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")
local MyGameDef                                 = import("src.app.Game.mMyGame.MyGameDef")

local MyCalculator                              = import("src.app.Game.mMyGame.MyCalculator")

local GamePublicInterface                       = import("src.app.Game.mMyGame.GamePublicInterface")

local SKCardThrown                                 = import("src.app.Game.mSKGame.SKCardThrown")

function MyHandCardsManager:ctor(SKHandCards, gameController)
    
    self._tributeCard = {}
    self._tributeCard[1] = nil
    self._tributeCard[2] = nil

    self._returnCard = {}
    self._returnCard[1] = nil
    self._returnCard[2] = nil

    self._FightCard = {}
    self._FightCard[1] = nil
    self._FightCard[2] = nil

    self.bNeedFindOldCard = true
    
    MyHandCardsManager.super.ctor(self, SKHandCards, gameController)
   
    for i=1,2 do        
        local card = SKCardThrown:create(1, self._gameController._baseGameScene, 10)
        self._tributeCard[i] = card
        card:setVisible(false)
        card = SKCardThrown:create(1, self._gameController._baseGameScene, 10)
        self._returnCard[i] = card
        card:setVisible(false)
        card = SKCardThrown:create(1, self._gameController._baseGameScene, 10+i)
        self._FightCard[i] = card
        card:setVisible(false)
    end
end

function MyHandCardsManager:resetHandCardsManager()
    MyHandCardsManager.super.resetHandCardsManager(self)
    
    for i=1,2 do
		if self._tributeCard[i] ~= nil then
			self._tributeCard[i]:resetCard()
        end
		if self._returnCard[i] ~= nil then
			self._returnCard[i]:resetCard()
        end
		if self._FightCard[i] ~= nil then
			self._FightCard[i]:resetCard()
        end
    end
end

--出牌提示
function MyHandCardsManager:onHint()
    --self:ope_UnselectSelfCards()

    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end

    local waitChair = self._gameController._baseGameUtilsInfoManager:getWaitChair()
    if not waitChair or waitChair == -1 then
        local inhandCards, cardsCount = myHandCards:getHandCardIDs()
        self:selectMyCardsByIDs(inhandCards, cardsCount)
        if self._gameController:ope_CheckSelect() then
            return
        end

        self:ope_UnselectSelfCards()
        --self:selectMinUnite()
        self:OnReMindFristThrow()
        if self._gameController:ope_CheckSelect() then
            return
        end

        return
    end
    
    self:ope_UnselectSelfCards()

    local waitCardUnite = {}
    MyCalculator:copyTable(waitCardUnite, self._gameController._baseGameUtilsInfoManager:getWaitUniteInfo()) -- 1.0这里只是简单的出牌消息
    --[[if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        local waitDetails   = MyCalculator:initCardUnite()
        if not MyCalculator:getUniteDetails(waitCardUnite.nCardIDs, waitCardUnite.nCardsCount, waitDetails, MyGameDef.MY_CARD_UNITE_TYPE_TOTAL) then
            return
        end
        MyCalculator:getBestUnitType1(waitDetails)
        if not waitDetails or not waitDetails.uniteType[1] then return end
        MyCalculator:copyTable(waitCardUnite, waitDetails.uniteType[1])
    end--]]

    local remindCards = self:onRemind(waitCardUnite)
    if self._lastRemindCards then --判断与之前的一次提示是否相同，相同的话再找一遍
        local bSame = MyCalculator:isSameCardIDs(remindCards, self._lastRemindCards)
        if bSame then
            remindCards = self:onRemind(waitCardUnite)
        end
    end
    self._lastRemindCards = clone(remindCards)
    if not remindCards then
        self._gameController:onPassCard()
        return
    end

    self:selectMyCardsByIDs(remindCards, SKGameDef.SK_CHAIR_CARDS)

    --[[local SKOpeBtnManager           = self._gameController._baseGameScene:getSKOpeBtnManager()
    if not SKHandCardsManager or not SKOpeBtnManager then return false end
    SKOpeBtnManager:setThrowEnable(true)--]]
    if not self._gameController:ope_CheckSelect() then
        --self._gameController:onPassCard()
		return
    end
end

function MyHandCardsManager:OnReMindFristThrow()
    if self:opeSeclectUniteNormal() then return true end
    if self:opeSeclectUniteArrage() then return true end
    self:selectMinUnite() --预防没有找到  按原来的对所有牌找一遍
end

function MyHandCardsManager:opeSeclectUniteNormal()
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end
    local inhandLay     = {}
    MyCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:RUL_GetInHandNormalCards()
    if cardsCount == 0 then return false end
    MyCalculator:skLayCards(inhandCards, cardsCount, inhandLay, gameFlags)

    local SelectIndex, bFinded, handLay, startIndex = -1, false, -1, -1
    for i = cardsCount, 1, -1 do
        local index = MyCalculator:getCardIndex(inhandCards[i], gameFlags)
        if inhandLay[index] <= 3 then
            SelectIndex = index
            bFinded = true
            handLay = inhandLay[index]
            startIndex = i
            break
        end
    end

    if not bFinded then
        for i = 4, 8 do
            local bHave = false
            for j = 1, SKGameDef.SK_LAYOUT_NUM do
                if inhandLay[j]==i then
                    SelectIndex = j
                    bHave = true
                    startIndex = cardsCount
                    break
                end
            end
            if bHave then break end
        end
    end

    local selectCardIDs, selectCount = {}, 0
    if SelectIndex ~= -1 then
        for i = startIndex, 1, -1 do
            local index = MyCalculator:getCardIndex(inhandCards[i], gameFlags)
            if SelectIndex == index then
                selectCount = selectCount+1
                selectCardIDs[selectCount] = inhandCards[i]
                if handLay == selectCount then
                    break
                end
            end
        end
        
        myHandCards:selectCardsByIDs(selectCardIDs, selectCount)
        return true
    end
    
    return false
end

function MyHandCardsManager:opeSeclectUniteArrage()
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end

    for i = 1, myHandCards.nArrageCount do
        local inhandCards, cardsCount = myHandCards:getCardIDsByArrageGroupNum(i)
        if cardsCount ~= 0 then
            local unitDetails = MyCalculator:initCardUnite()
            if MyCalculator:getUniteDetails(inhandCards, cardsCount, unitDetails, MyGameDef.MY_CARD_UNITE_TYPE_TOTAL) then                
                myHandCards:selectCardsByIDs(inhandCards, cardsCount)
                return true
            end
        end
    end
    return false
end

function MyHandCardsManager:selectMinUnite()
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end

    local inhandLay     = {}
    MyCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()
    MyCalculator:skLayCards(inhandCards, cardsCount, inhandLay, gameFlags)

    local index = MyCalculator:getCardIndex(inhandCards[cardsCount], gameFlags)
    if inhandLay[index] <= 3 then
        myHandCards:selectCardsByIndex(index)
    else
        local pri = 10000
        for i = 1, 3 do
            for j = 1, SKGameDef.SK_LAYOUT_NUM do
                local rank = self._gameController._baseGameUtilsInfoManager:getCurrentRank()
                if inhandLay[j] == i and MyCalculator:getCardIndexPri(j, rank, gameFlags) < pri then
                    index   = j
                    pri     = MyCalculator:getCardIndexPri(j, rank, gameFlags)
                end
            end
        end

        myHandCards:selectCardsByIndex(index)
    end
end

function MyHandCardsManager:resetRemind()
    self._remindUniteType       = MyCalculator:initUniteType()
    self._bestRemindUniteType   = MyCalculator:initUniteType()
    self._remindArrageUnite     = MyCalculator:initUniteType()
    self._lastRemindCards = nil
    self.bNeedFindOldCard = true
end

--从理牌堆里找出压牌P1，从非理牌堆里找出压牌P2，从P1、P2中选择较小的牌型
function MyHandCardsManager:getRemindUnite(waitCardUnite)
    local remindCardIDsNoArraged = self:OnReMindNoArraged(waitCardUnite)
    if remindCardIDsNoArraged then self.bNeedFindOldCard = false end
    local remindCardIDsArraged = self:OnReMindArrageCard(waitCardUnite)
    if remindCardIDsArraged then self.bNeedFindOldCard = false end

    local remindNoArragedUnite
    if remindCardIDsNoArraged then
        remindNoArragedUnite = clone(self._remindUniteType)
        if remindNoArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then remindNoArragedUnite.nMainValue = 100000 end --四王炸
        if remindNoArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then remindNoArragedUnite.nMainValue = remindNoArragedUnite.nMainValue + 2000 end --普通炸弹,4张为牌的pri值，5张为10000
        if remindNoArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then remindNoArragedUnite.nMainValue = remindNoArragedUnite.nMainValue + 15000 end --同花顺,应该比5炸大
    end               
    local remindArragedUnite 
    if remindCardIDsArraged then
        remindArragedUnite = clone(self._remindArrageUnite)
        if remindArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then remindArragedUnite.nMainValue = 100000 end --四王炸
        if remindArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then remindArragedUnite.nMainValue = remindArragedUnite.nMainValue + 2000 end --普通炸弹,4张为牌的pri值，5张为10000
        if remindArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then remindArragedUnite.nMainValue = remindArragedUnite.nMainValue + 15000 end --同花顺,应该比5炸大
    end
    if remindNoArragedUnite and remindArragedUnite then
        if remindNoArragedUnite.nMainValue > remindArragedUnite.nMainValue then
            if remindArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then remindArragedUnite.nMainValue = remindArragedUnite.nMainValue - 2000 end --普通炸弹,4张为牌的pri值，5张为10000
            if remindArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then remindArragedUnite.nMainValue = remindArragedUnite.nMainValue - 15000 end --同花顺,应该比5炸大
            
            self._remindUniteType = clone(remindArragedUnite)
            self._remindArrageUnite = clone(remindArragedUnite)
            return remindCardIDsArraged
        else
            if remindNoArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then remindNoArragedUnite.nMainValue = remindNoArragedUnite.nMainValue - 2000 end --普通炸弹,4张为牌的pri值，5张为10000
            if remindNoArragedUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then remindNoArragedUnite.nMainValue = remindNoArragedUnite.nMainValue - 15000 end --同花顺,应该比5炸大
            
            self._remindUniteType = clone(remindNoArragedUnite)
            self._remindArrageUnite = clone(remindNoArragedUnite)
            return remindCardIDsNoArraged
        end
    end

    return remindCardIDsNoArraged or remindCardIDsArraged
end

function MyHandCardsManager:onRemind(waitCardUnite)
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return nil end

    local bestRemindCards = self:onBestRemind(waitCardUnite)
    if bestRemindCards 
    and self._bestRemindUniteType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_BOMB 
    and self._bestRemindUniteType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB 
    and self._bestRemindUniteType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_4KING then --如果是超级炸弹或者4王炸，先不提示，可能有同花顺
        return bestRemindCards
    end

    local remindCardIDs = self:getRemindUnite(waitCardUnite)
    if remindCardIDs then
        return remindCardIDs
    end

    if not self.bNeedFindOldCard then --已经遍历一遍了，重新开始
        self:resetRemind()
        bestRemindCards = self:onBestRemind(waitCardUnite)
        if bestRemindCards 
        and self._bestRemindUniteType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_BOMB 
        and self._bestRemindUniteType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB 
        and self._bestRemindUniteType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_4KING then --如果是超级炸弹或者4王炸，先不提示，可能有同花顺then
            return bestRemindCards
        end

        local remindCardIDs = self:getRemindUnite(waitCardUnite)
        if remindCardIDs then
            return remindCardIDs
        end
    end
    --最后检查一下全部手牌，保底机制
    local remindCards   = {}
    MyCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()

    if self._remindUniteType.dwCardType and self._remindUniteType.dwCardType ~= 0 then
        if self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, self._remindUniteType, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true) then
            return remindCards
        else
            self._bestRemindUniteType = MyCalculator:initUniteType()
            bestRemindCards = self:onBestRemind(waitCardUnite)
            if bestRemindCards then
                self._remindUniteType = MyCalculator:initUniteType()
                return bestRemindCards
            end

            if self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, waitCardUnite, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true) then
                return remindCards
            end
        end
    else
        if self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, waitCardUnite, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true) then
            return remindCards
        end
    end
end

function MyHandCardsManager:onBestRemind(waitCardUnite)
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return nil end

    local remindCards   = {}
    local inhandLay     = {}
    MyCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    MyCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)

    local gameFlags = GamePublicInterface:getGameFlags()
    --local inhandCards, cardsCount = myHandCards:getHandCardIDs()
    local inhandCards, cardsCount = myHandCards:RUL_GetInHandNormalCards()  --最好的提示是在没有理的牌里找
    MyCalculator:skLayCards(inhandCards, cardsCount, inhandLay, 0)

    local perfectUnite  = MyCalculator:initUniteType()
    if self._bestRemindUniteType.dwCardType and self._bestRemindUniteType.dwCardType ~= 0 then
        MyCalculator:copyTable(perfectUnite, self._bestRemindUniteType)
    else
        MyCalculator:copyTable(perfectUnite, waitCardUnite)
    end

    local remindLay     = {}
    while self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, perfectUnite, perfectUnite, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, false) do
        MyCalculator:xygZeroLays(remindLay, SKGameDef.SK_LAYOUT_NUM)
        MyCalculator:skLayCards(remindCards, cardsCount, remindLay, 0)

        local bMatch = true
        for i = 1, SKGameDef.SK_LAYOUT_NUM do
            if remindLay[i] ~= 0 and remindLay[i] ~= inhandLay[i] then
                bMatch = false
                break
            end
        end

        if bMatch then
            MyCalculator:copyTable(self._bestRemindUniteType, perfectUnite)
            return remindCards
        else
            MyCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
        end
    end

    return nil
end

function MyHandCardsManager:OnReMindNoArraged(waitCardUnite)
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return nil end

    local remindCards   = {}
    MyCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:RUL_GetInHandNormalCards()

    local inhandLay     = {}
    MyCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)
    MyCalculator:skLayCards(inhandCards, cardsCount, inhandLay, 0)

    local remindLay     = {}
    if self._remindUniteType.dwCardType and self._remindUniteType.dwCardType ~= 0 then
        while(self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, self._remindUniteType, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true))  do
            local bMatch = true
            --是炸弹或者超级炸弹，判断有没有拆牌
            MyCalculator:xygZeroLays(remindLay, SKGameDef.SK_LAYOUT_NUM)
            MyCalculator:skLayCards(remindCards, cardsCount, remindLay, 0)

            for i = 1, SKGameDef.SK_LAYOUT_NUM do
                if remindLay[i] ~= 0 and remindLay[i] ~= inhandLay[i] and inhandLay[i] >= 4  then
                    bMatch = false
                    break
                end
            end
            if bMatch then
                return remindCards
            end
        end
    else
        self._remindUniteType = clone(waitCardUnite)
        return self:OnReMindNoArraged(waitCardUnite)
    end

    return nil
end

--获取理牌堆遍历顺序，从小到大
--返回value为GroupNum的数组
function MyHandCardsManager:getArragedCardVisitList( )
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return {} end
    
    local visitList = {}
    local length = myHandCards.nArrageCount
    for i = 1, length do
        local inhandCards, cardsCount = myHandCards:getCardIDsByArrageGroupNum(i)
        local seqID = i
        local value = 0 --权重，越大的排在越后面
        if cardsCount ~= 0 then
            local unitDetails = MyCalculator:initCardUnite()
            if MyCalculator:getUniteDetails(inhandCards, cardsCount, unitDetails, MyGameDef.MY_CARD_UNITE_TYPE_TOTAL) then
                local maxValue = 0
                for j = 1, unitDetails.nTypeCount do
                    if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then unitDetails.uniteType[j].nMainValue = 100000 end --四王炸
                    if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then unitDetails.uniteType[j].nMainValue = unitDetails.uniteType[j].nMainValue + 2000 end --普通炸弹,4张为牌的pri值，5张为10000
                    if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then unitDetails.uniteType[j].nMainValue = unitDetails.uniteType[j].nMainValue + 15000 end --同花顺,应该比5炸大
                    if maxValue < unitDetails.uniteType[j].nMainValue then
                        maxValue = unitDetails.uniteType[j].nMainValue
                    end
                end
                value = maxValue
            end
        end
        visitList[i] = { 
            seqID = seqID,
            value = value
        }
    end
    table.sort(visitList, function (l, r)
        return l.value < r.value
    end)

    return visitList
end

function MyHandCardsManager:OnReMindArrageCard(waitCardUnite)
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end

    local visitList = self:getArragedCardVisitList()

    local remindCards   = {}
    MyCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local bFind, mainValue = false, -1
    if self._remindArrageUnite.dwCardType and self._remindArrageUnite.dwCardType ~= 0 then
        --获得上一次提示的牌型，这次提示的牌型要大过上次的牌型
        local remindArrageUnite = self._remindArrageUnite
        for i = 1, #visitList do
            local inhandCards, cardsCount = myHandCards:getCardIDsByArrageGroupNum(visitList[i].seqID)
            if cardsCount ~= 0 then
                local temp = MyCalculator:initUniteType()
                MyCalculator:copyTable(temp, remindArrageUnite)
                local unitDetails = MyCalculator:initCardUnite()
                if MyCalculator:getUniteDetails(inhandCards, cardsCount, unitDetails, MyGameDef.MY_CARD_UNITE_TYPE_TOTAL) then
                     --临时改变几种牌型的主值用来比较牌型大小
                    for j = 1, unitDetails.nTypeCount do
                        if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then unitDetails.uniteType[j].nMainValue = 100000 end --四王炸
                        if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then unitDetails.uniteType[j].nMainValue = unitDetails.uniteType[j].nMainValue + 2000 end --普通炸弹,4张为牌的pri值，5张为10000
                        if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then unitDetails.uniteType[j].nMainValue = unitDetails.uniteType[j].nMainValue + 15000 end --同花顺,应该比5炸大
                    end
                    if temp.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then temp.nMainValue = 100000 end --四王炸
                    if temp.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then temp.nMainValue = temp.nMainValue + 2000 end --普通炸弹,4张为牌的pri值，5张为10000
                    if temp.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then temp.nMainValue = temp.nMainValue + 15000 end --同花顺,应该比5炸大
	                if MyCalculator:getBestUnitType2(temp, unitDetails) then
                        
	                    bFind = true
                        if unitDetails.uniteType[1].nMainValue < mainValue or mainValue == -1 then
                            --选出能够理牌区能够压牌切主值较小的牌型
                            if unitDetails.uniteType[1].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then unitDetails.uniteType[1].nMainValue = unitDetails.uniteType[1].nMainValue - 2000 end --普通炸弹,4张为牌的pri值，5张为10000
                            if unitDetails.uniteType[1].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then unitDetails.uniteType[1].nMainValue = unitDetails.uniteType[1].nMainValue - 15000 end --同花顺,应该比5炸大
                            self._remindArrageUnite = unitDetails.uniteType[1]
	                        MyCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
	                        for j = 1, cardsCount do
	                            remindCards[j] = inhandCards[j]
	                        end
	                        mainValue = unitDetails.uniteType[1].nMainValue
	                    end
	                end
			    end
            end
        end
    elseif not bFind then
        for i = 1, #visitList do
            local inhandCards, cardsCount = myHandCards:getCardIDsByArrageGroupNum(visitList[i].seqID)
            if cardsCount ~= 0 then
                local temp = MyCalculator:initUniteType()
                MyCalculator:copyTable(temp, waitCardUnite)
                local unitDetails = MyCalculator:initCardUnite()
                if MyCalculator:getUniteDetails(inhandCards, cardsCount, unitDetails, MyGameDef.MY_CARD_UNITE_TYPE_TOTAL) then
                     --临时改变几种牌型的主值用来比较牌型大小
                    if temp.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then temp.nMainValue = 100000 end -- 四王炸
                    if temp.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then temp.nMainValue = temp.nMainValue + 2000 end -- 普通炸弹,4张为牌的pri值，5张为10000
                    if temp.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then temp.nMainValue = temp.nMainValue + 15000 end -- 同花顺,应该比5炸大
                    for j = 1, unitDetails.nTypeCount do
                        if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then unitDetails.uniteType[j].nMainValue = 100000 end --四王炸
                        if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then unitDetails.uniteType[j].nMainValue = unitDetails.uniteType[j].nMainValue + 2000 end --普通炸弹,4张为牌的pri值，5张为10000
                        if unitDetails.uniteType[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then unitDetails.uniteType[j].nMainValue = unitDetails.uniteType[j].nMainValue + 15000 end --同花顺,应该比5炸大
                    end
                    --改变主值后是否能够压牌,有的话选出最优牌型
                    if MyCalculator:getBestUnitType2(temp, unitDetails) then
                        bFind = true
                        --选出能够理牌区能够压牌切主值较小的牌型
                        if unitDetails.uniteType[1].nMainValue < mainValue or mainValue == -1 then
                            if unitDetails.uniteType[1].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then unitDetails.uniteType[1].nMainValue = unitDetails.uniteType[1].nMainValue - 2000 end --普通炸弹,4张为牌的pri值，5张为10000
                            if unitDetails.uniteType[1].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then unitDetails.uniteType[1].nMainValue = unitDetails.uniteType[1].nMainValue - 15000 end --同花顺,应该比5炸大
                            self._remindArrageUnite = unitDetails.uniteType[1]
                            MyCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
                            for j = 1, cardsCount do
                                remindCards[j] = inhandCards[j]
                            end
	                        mainValue = unitDetails.uniteType[1].nMainValue
                        end
                    end
                end
            end
        end
    end
    if bFind then return remindCards end
    -- self._remindArrageUnite     = MyCalculator:initUniteType()
    return nil      
end

function MyHandCardsManager:ope_BuildCard(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, dwUniteSupport, bnUseJoker)
    local gameFlags = GamePublicInterface:getGameFlags()

    local lay = {}
    MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)

    local jokerCount = MyCalculator:preDealCards(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
    if not bnUseJoker then
        jokerCount = 0
    end

    MyCalculator:copyTable(out_type, in_type)

    local flags = SKGameDef.SK_COMPARE_UNITE_TYPE_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_SINGLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_Single(nInCards, nInCardLen, out_type) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_Couple(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_THREE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_THREE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_Three(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_THREE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_Three_CoupleEx(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, self._gameController._baseGameUtilsInfoManager:getWaitUniteInfo()) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end
    
    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_ABT_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_ABT_Single(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 5) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_ABT_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_ABT_Couple(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 3) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end   

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_ABT_THREE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_ABT_Three(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 2) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyGameDef.MY_COMPARE_UNITE_TYPE_BOMB
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_BOMB)
                and self:IS_BIT_SET(flags, in_type.dwCardType) then
        for i = 4, 5 do        
            if MyCalculator:getCardType_Bomb(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
                MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
                return true
            end
        end
    end
    
    flags = MyGameDef.MY_COMPARE_UNITE_TYPE_TONGHUASHUN
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_TongHuaShun(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 5) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyGameDef.MY_COMPARE_UNITE_TYPE_SUPER_BOMB
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB)
                and self:IS_BIT_SET(flags, in_type.dwCardType) then
        for i = 6, (8+jokerCount)--[[10--]] do       
            if MyCalculator:getCardType_SuperBomb(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
                MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
                return true
            end
        end
    end

    flags = MyGameDef.MY_COMPARE_UNITE_TYPE_4KING
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_4KING)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_4King(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM ,jokerCount , out_type, 4) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    return false
end

function MyHandCardsManager:CreateTributeCard(cardsID, nindex)
    --local card = SKCardThrown:create(nindex, self._gameController._baseGameScene, 10)
    --card:setSKID(cardsID)
    --card:setVisible(true)
    local card
    if self._tributeCard[1]:getSKID() == -1 then    
        self._tributeCard[1]:setSKID(cardsID)
        card = self._tributeCard[1]
    else
        self._tributeCard[2]:setSKID(cardsID)
        card = self._tributeCard[2]
    end
    card:setVisible(true)

    local CardsPosition = self:getThrowCardsPosition(nindex)
    if nindex == 1 then
        
    elseif nindex == 2 then
        
    elseif nindex == 3 then
        
    elseif nindex == 4 then
        
    end
    card:setPosition(CardsPosition)
end

function MyHandCardsManager:CreateReturnCard(cardsID, nindex)
    --local card = SKCardThrown:create(nindex, self._gameController._baseGameScene, 10)
    --card:setSKID(cardsID)
    --card:setVisible(true)
    local card
    if self._returnCard[1]:getSKID() == -1 then    
        self._returnCard[1]:setSKID(cardsID)
        card = self._returnCard[1]
    else
        self._returnCard[2]:setSKID(cardsID)
        card = self._returnCard[2]
    end
    card:setVisible(true)

    local CardsPosition = self:getThrowCardsPosition(nindex)
    card:setPosition(CardsPosition)
end

function MyHandCardsManager:CreateFightCard(cardsID1, cardsID2, nindex)
    --local card1 = SKCardThrown:create(nindex, self._gameController._baseGameScene, 10)
    --card1:setSKID(cardsID1)
    --card1:setVisible(true)
    local card1 = nil
    local card2 = nil

    if cardsID2 >= 0 then
        card1 = self._FightCard[1]
        card1:setSKID(cardsID1)        
        card1:setVisible(true)

        card2 = self._FightCard[2]
        --card2 = SKCardThrown:create(nindex, self._gameController._baseGameScene, 10)
        card2:setSKID(cardsID2)
        card2:setVisible(true)
    else
        if self._FightCard[1]:getSKID() == -1 then       
            card1 = self._FightCard[1]
            card1:setSKID(cardsID1)
            card1:setVisible(true)
        else           
            card1 = self._FightCard[2]
            self._FightCard[2]:setSKID(cardsID1)
            self._FightCard[2]:setVisible(true)
        end
    end

    
  --[[ if card2 ~= nil then
        card1 = self._FightCard[1]
        card1:setSKID(cardsID1)
        --self._FightCard[1] = card1
        --self._FightCard[2] = card2
   else 
        if self._FightCard[1]:getSKID() == -1 then       
            card1 = self._FightCard[1]
            card1:setSKID(cardsID1)
        else           
            card1 = self._FightCard[2]
            card1:setSKID(cardsID2)
        end
   end--]]


    local CardsPosition = self:getThrowCardsPosition(nindex)
    
    if card2 == nil then
        card1:setPosition(CardsPosition)
    else
        if nindex == 1 then
            local pos = cc.p(CardsPosition.x - SKGameDef.SK_CARD_THROWN_INTERVAL/2, CardsPosition.y)
            card1:setPosition(pos)
            pos = cc.p(CardsPosition.x + SKGameDef.SK_CARD_THROWN_INTERVAL/2, CardsPosition.y)
            card2:setPosition(pos)
        elseif nindex == 2 then
            local pos = cc.p(CardsPosition.x - SKGameDef.SK_CARD_THROWN_INTERVAL, CardsPosition.y)           
            card1:setPosition(pos)
            card2:setPosition(CardsPosition)
        elseif nindex == 3 then         
            local pos = cc.p(CardsPosition.x - SKGameDef.SK_CARD_THROWN_INTERVAL/2, CardsPosition.y)
            card1:setPosition(pos)
            pos = cc.p(CardsPosition.x + SKGameDef.SK_CARD_THROWN_INTERVAL/2, CardsPosition.y)
            card2:setPosition(pos)
        elseif nindex == 4 then                   
            card1:setPosition(CardsPosition)
            local pos = cc.p(CardsPosition.x + SKGameDef.SK_CARD_THROWN_INTERVAL, CardsPosition.y)
            card2:setPosition(pos)
        end    
    end
end

function MyHandCardsManager:getThrowCardsPosition(index)
    local startX, startY = self:getStartPoint(index)

    if self:isMiddlePlayer(index) then       --居中
        startX = startX - (self:getCardSize().width ) / 2--(self:getCardSize().width + (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
    elseif self:isRightPlayer(index) then    --右对齐
        startX = startX - self:getCardSize().width --- (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL
    end
    --startX = startX + (index - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL

    return cc.p(startX, startY)
end

function MyHandCardsManager:getStartPoint(index)
    local node = self._gameController._baseGameScene._gameNode
    if node then
        local thrownPosition = node:getChildByName("Panel_Card_thrown"..tostring(index))
        if thrownPosition then
            local startX, startY = thrownPosition:getPosition()
            if self:isRightPlayer(index) then
                startX = startX + thrownPosition:getContentSize().width
            end
            return startX, startY
        end
    end
    return 0, 0
end

function MyHandCardsManager:isMiddlePlayer(index)
    return self._gameController:isMiddlePlayer(index)
end

function MyHandCardsManager:isRightPlayer(index)
    return self._gameController:isRightPlayer(index)
end

function MyHandCardsManager:getCardSize()
    if self._tributeCard[1] then
        return self._tributeCard[1]:getContentSize()
    end
    if self._returnCard[1] then
        return self._returnCard[1]:getContentSize()
    end
    if self._FightCard[1] then
        return self._FightCard[1]:getContentSize()
    end

    return cc.size(0, 0)
end

function MyHandCardsManager:ope_AddTributeAndReturnCard(drawIndex, cardID)
    self:ope_UnselectSelfCards()
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:ope_AddTributeAndReturnCard(cardID)
    end

    if drawIndex == self._gameController:getMyDrawIndex() then
        -- 进还贡后，重新计算同花顺选择器
        self._allTHSCardsArr = self:buildAllTonghuaShun()
        self:setShapeButtonsStatus()
    end
end

function MyHandCardsManager:OPE_MaskCardForTributeAndReturn()   
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:OPE_MaskCardForTributeAndReturn()
    end
end

function MyHandCardsManager:OnArrageHandCard()   
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:OnArrageHandCard()
        --self._SKHandCards[self._gameController:getMyDrawIndex()]:AdjustArrageUniteCards()
    end
end

function MyHandCardsManager:OnResetArrageHandCard()
    self:resetRemind()
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:OnResetArrageHandCard()
    end
end

function MyHandCardsManager:sortHandCards(drawIndex)
    self:resetRemind()
    self._SKHandCards[drawIndex]:sortHandCards()
end

function MyHandCardsManager:quickSortBoomHandCards(drawIndex)
    self._SKHandCards[drawIndex]:quickSortBoom()
end

function MyHandCardsManager:onDealCard()
    if not self._SKHandCards then return end

    for i = 1, self._gameController:getTableChairCount() do
        local nBanker       = self._gameController:getBankerDrawIndex()
        local count         = self._gameController:getStartChairCardsCount()
        if i ~= nBanker then
            count = self._gameController:getStartChairCardsCount() - self._gameController:getTopCardsCount()
        end
        local SKHandCards   = self._SKHandCards[i]
        if SKHandCards and self._dealCounts <= count then
            SKHandCards:onDealCard(self._dealCounts)

            --self._gameController:playDealCardEffect()
        end
    end

    --之前播放音效放到上面for循环中了，导致发一张牌播放了4次音效，在某些手机上呈现卡顿现象
    self._gameController:playDealCardEffect()

    self._dealCounts = self._dealCounts + 1
    if self._dealCounts > self._gameController:getStartChairCardsCount() then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._dealCardTimerID)
        self._dealCardTimerID = nil
        self._dealCounts     = 1

        self._gameController:onDealCardOver()
    end
end

function MyHandCardsManager:showFriendCards(cards, len)
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:showFriendCards(cards, len)
    end
end

function MyHandCardsManager:updataFriendCards(cards, len)
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:updataFriendCards(cards, len)
    end
end

function MyHandCardsManager:ope_UnselectSelfCards()
    if self._SKHandCards[self._gameController:getMyDrawIndex()]:getHandCardsCount() <= 0 then
        return
    end
    self._gameController:playGamePublicSound("SpecSelectCard.mp3")
    MyHandCardsManager.super.ope_UnselectSelfCards(self)
end

function MyHandCardsManager:maskAllHandCardsEX(mask)   
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:maskAllHandCardsEX(mask)
    end
end

function MyHandCardsManager:havenoBigger()
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end

    local remindCards   = {}
    MyCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()
       
    self:resetRemind()
    local waitCardUnite = {}
    MyCalculator:copyTable(waitCardUnite, self._gameController._baseGameUtilsInfoManager:getWaitUniteInfo())
    if cardsCount > 0 and  not self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, waitCardUnite, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true) then
        return true
    else
        self:resetRemind()  
        return false
    end
end

-- 在设置 同花顺选择按钮的状态
function MyHandCardsManager:setShapeButtonsStatus()
    local shapeStatus = {}
    local indexTable = {SKGameDef.SK_CS_SPADE, SKGameDef.SK_CS_HEART, SKGameDef.SK_CS_CLUB, SKGameDef.SK_CS_DIAMOND}
    for i=0, #self._allTHSCardsArr do 
        local shape = indexTable[i+1]
        if next(self._allTHSCardsArr[shape]) then
            shapeStatus[shape] = true
        else
            shapeStatus[shape] = false
        end
    end
    self._gameController._baseGameScene:disableShapeButtons(shapeStatus)
end

-- 在设置自己手牌的时候计算出 有几个同花顺
function MyHandCardsManager:setSelfHandCards(handCards, bSetTHS)
    MyHandCardsManager.super.setSelfHandCards(self, handCards)
    self._allTHSCardsArr = self:buildAllTonghuaShun()

    if true == bSetTHS then
        self:setShapeButtonsStatus()
    end
end

-- 每次出完牌需要重新计算 有几个同花顺
function MyHandCardsManager:ope_ThrowCards(drawIndex, cardIDs, cardsCount)
    MyHandCardsManager.super.ope_ThrowCards(self, drawIndex, cardIDs, cardsCount)
    self._allTHSCardsArr = self:buildAllTonghuaShun()
    self:setShapeButtonsStatus()
end

-- 点击空白区域时候，恢复初始值，便于再次同花顺选择器直接列出最大同花顺
function  MyHandCardsManager:resetSelectShapeIndex()
    for cardShape=SKGameDef.SK_CS_DIAMOND, SKGameDef.SK_CS_SPADE do 
        if self._shapeRefCounts then
            self._shapeRefCounts[cardShape] = table.maxn(self._allTHSCardsArr[cardShape])
        end
        if self._shapeRefCounts1 then
            self._shapeRefCounts1[cardShape] = table.maxn(self._allTHSWithoutJoker[cardShape])
        end
        if self._shapeRefCounts2 then
            self._shapeRefCounts2[cardShape] = table.maxn(self._allTHSWithJoker[cardShape])
        end
    end
end

function MyHandCardsManager:getTHSCardsUnitesByCardShape(cardShape, bigToSmall)
    if not bigToSmall then
        -- 从小到大列举 同花顺
        if cardShape < SKGameDef.SK_CS_DIAMOND  or cardShape >  SKGameDef.SK_CS_SPADE then return  nil end
        if not self._shapeRefCounts then self._shapeRefCounts = {} end
        if not self._shapeRefCounts[cardShape] then self._shapeRefCounts[cardShape] = 1 end

        if not self._shapeRefCounts1 then self._shapeRefCounts1 = {} end
        if not self._shapeRefCounts2 then self._shapeRefCounts2 = {} end

        if not self._shapeRefCounts1[cardShape] then 
            self._shapeRefCounts1[cardShape] = 1
        end
        if not self._shapeRefCounts2[cardShape] then 
            self._shapeRefCounts2[cardShape] = 1
        end

        local isThsUnchanged = self:_calcSortedTHSSetsByCustomRules(cardShape, bigToSmall)
        if isThsUnchanged == false then
            self._shapeRefCounts1[cardShape] = 1
            self._shapeRefCounts2[cardShape] = 1
        end
        if next(self._allTHSWithJoker[cardShape]) and self._shapeRefCounts1[cardShape] >table.maxn(self._allTHSWithoutJoker[cardShape]) 
            and self._shapeRefCounts2[cardShape] <= table.maxn(self._allTHSWithJoker[cardShape]) then
            local oneArray = self._allTHSWithJoker[cardShape]
            if next(oneArray) and self._shapeRefCounts2[cardShape] > 0 then
                local index = #self._allTHSWithoutJoker[cardShape] + self._shapeRefCounts2[cardShape]
                self._shapeRefCounts2[cardShape] = self._shapeRefCounts2[cardShape] + 1
                
                return self._allTHSSetsSorted[cardShape][index]["thsCardIds"]
            end
        elseif next(self._allTHSWithoutJoker[cardShape]) and self._shapeRefCounts1[cardShape]<=table.maxn(self._allTHSWithoutJoker[cardShape]) 
            and self._shapeRefCounts2[cardShape]<=table.maxn(self._allTHSWithJoker[cardShape]) then
            local oneArray = self._allTHSWithoutJoker[cardShape]
            if next(oneArray) and self._shapeRefCounts1[cardShape] > 0 then
                local index = self._shapeRefCounts1[cardShape]
                self._shapeRefCounts1[cardShape] = self._shapeRefCounts1[cardShape] + 1
                
                return self._allTHSSetsSorted[cardShape][index]["thsCardIds"]
            end
        end

        if self._shapeRefCounts1[cardShape]>table.maxn(self._allTHSWithoutJoker[cardShape]) and self._shapeRefCounts2[cardShape]> table.maxn(self._allTHSWithJoker[cardShape]) then
            self._shapeRefCounts1[cardShape] = 1
            self._shapeRefCounts2[cardShape] = 1
        end
    else
        -- 从大到小列举 同花顺
        if cardShape < SKGameDef.SK_CS_DIAMOND  or cardShape >  SKGameDef.SK_CS_SPADE then 
            if DEBUG and DEBUG > 0 then
                print('getTHSCardsUnitesByCardShape cardShape: '..cardShape)
            end
            return  nil 
        end

        --if not self._shapeRefCounts then self._shapeRefCounts = {} end
        if not self._shapeRefCounts1 then self._shapeRefCounts1 = {} end
        if not self._shapeRefCounts2 then self._shapeRefCounts2 = {} end

        if not self._shapeRefCounts1[cardShape] then 
            self._shapeRefCounts1[cardShape] = table.maxn(self._allTHSWithoutJoker[cardShape]) 
        end
        if not self._shapeRefCounts2[cardShape] then 
            self._shapeRefCounts2[cardShape] = table.maxn(self._allTHSWithJoker[cardShape]) 
        end
        
        if self._shapeRefCounts1[cardShape] <= 0 and self._shapeRefCounts2[cardShape] <= 0 then
            self._shapeRefCounts1[cardShape] = table.maxn(self._allTHSWithoutJoker[cardShape])
            self._shapeRefCounts2[cardShape] = table.maxn(self._allTHSWithJoker[cardShape])
        end

        if DEBUG and DEBUG > 0 then
            if self._shapeRefCounts1[cardShape] and self._shapeRefCounts1[cardShape] > 0 and next(self._allTHSWithoutJoker[cardShape]) == nil then
                print('getTHSCardsUnitesByCardShape without joker, _shapeRefCounts1 must clear!!!',cardShape)
                self._shapeRefCounts1[cardShape] = {}
            end
            if self._shapeRefCounts2[cardShape] and self._shapeRefCounts2[cardShape] > 0 and next(self._allTHSWithJoker[cardShape]) == nil then
                print('getTHSCardsUnitesByCardShape with joker, _shapeRefCounts2 must clear!!!',cardShape)
                self._shapeRefCounts2[cardShape]  = {}
            end
        end

        local isThsUnchanged = self:_calcSortedTHSSetsByCustomRules(cardShape, bigToSmall)
        if isThsUnchanged == false then
            self._shapeRefCounts1[cardShape] = table.maxn(self._allTHSWithoutJoker[cardShape]) 
            self._shapeRefCounts2[cardShape] = table.maxn(self._allTHSWithJoker[cardShape]) 
        end
        if next(self._allTHSWithJoker[cardShape]) and self._shapeRefCounts1[cardShape]<=0 and self._shapeRefCounts2[cardShape]>0 then
            local oneArray = self._allTHSWithJoker[cardShape]
            if next(oneArray) and self._shapeRefCounts2[cardShape] > 0 then
                local index = self._shapeRefCounts2[cardShape]
                self._shapeRefCounts2[cardShape] = self._shapeRefCounts2[cardShape] - 1

                return self._allTHSSetsSorted[cardShape][index]["thsCardIds"]
            end
        elseif next(self._allTHSWithoutJoker[cardShape]) and self._shapeRefCounts1[cardShape]>0 then
            local oneArray = self._allTHSWithoutJoker[cardShape]
            if next(oneArray) and self._shapeRefCounts1[cardShape] > 0 then
                local index = #self._allTHSWithJoker[cardShape] + self._shapeRefCounts1[cardShape]
                self._shapeRefCounts1[cardShape] = self._shapeRefCounts1[cardShape] - 1

                return self._allTHSSetsSorted[cardShape][index]["thsCardIds"]
            end
        end

    end
    if DEBUG and DEBUG > 0 then
        print('getTHSCardsUnitesByCardShape return nothing', cardShape)
    end
    return {}
end

--同花顺集合排序，排序规则：优先选择未理出的牌组成的同花顺
function MyHandCardsManager:_calcSortedTHSSetsByCustomRules(cardShape, bigToSmall)
    if self._allTHSWithoutJoker == nil or self._allTHSWithoutJoker[cardShape] == nil then return true end
    if self._allTHSWithJoker == nil or self._allTHSWithJoker[cardShape] == nil then return true end
    
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    local arrageCards = {}
    myHandCards:RUL_GetInHandArrageCards(arrageCards)
    local tempAllTHSSets = {}
    local thsSetOriginal1 = self._allTHSWithJoker[cardShape]
    local thsSetOriginal2 = self._allTHSWithoutJoker[cardShape]
    if bigToSmall == false then
        thsSetOriginal1 = self._allTHSWithoutJoker[cardShape]
        thsSetOriginal2 = self._allTHSWithJoker[cardShape]
    end
    for i = 1, #thsSetOriginal1 do
        local theThsInfo = {
            ["thsCardIds"] = clone(thsSetOriginal1[i]),
            ["originalIndex"] = i,
            ["hasSortedCard"] = false --是否包含理牌
        }
        myHandCards:adjustCardIDForTHSSelect(theThsInfo["thsCardIds"])
        theThsInfo["hasSortedCard"] = self:_hasOneCardInSet(theThsInfo["thsCardIds"], 5, arrageCards)

        tempAllTHSSets[#tempAllTHSSets + 1] = theThsInfo
    end
    for i = 1, #thsSetOriginal2 do
        local theThsInfo = {
            ["thsCardIds"] = clone(thsSetOriginal2[i]),
            ["originalIndex"] = i,
            ["hasSortedCard"] = false --是否包含理牌
        }
        myHandCards:adjustCardIDForTHSSelect(theThsInfo["thsCardIds"])
        theThsInfo["hasSortedCard"] = self:_hasOneCardInSet(theThsInfo["thsCardIds"], 5, arrageCards)

        tempAllTHSSets[#tempAllTHSSets + 1] = theThsInfo
    end
    self:_moveNonArrangedTHSPrior(tempAllTHSSets, bigToSmall) --仅包含非理牌的同花顺，调整到前面

    if self._allTHSSetsSorted == nil then self._allTHSSetsSorted = {} end
    if self._allTHSSetsSorted[cardShape] == nil then self._allTHSSetsSorted[cardShape] = {} end
    if self:_checkThsUnchanged(self._allTHSSetsSorted[cardShape], tempAllTHSSets) == true and
        self:_checkThsUnchanged(self._allTHSSetsSorted[cardShape], tempAllTHSSets) == true then
        return true
    end

    self._allTHSSetsSorted[cardShape] = tempAllTHSSets

    return false
end

function MyHandCardsManager:_moveNonArrangedTHSPrior(rawSet, bigToSmall)
    local tempArr = {}
    for i = 1, #rawSet do
        if rawSet[i]["hasSortedCard"] == false then
            if bigToSmall == false then
                tempArr[#tempArr + 1] = rawSet[i]
            end
        else
            if bigToSmall == true then
                tempArr[#tempArr + 1] = rawSet[i]
            end
        end
    end

    for i = 1, #rawSet do
        if rawSet[i]["hasSortedCard"] == false then
            if bigToSmall == true then
                tempArr[#tempArr + 1] = rawSet[i]
            end
        else
            if bigToSmall == false then
                tempArr[#tempArr + 1] = rawSet[i]
            end
        end
    end

    for i = 1, #rawSet do
        rawSet[i] = tempArr[i]
    end
end

function MyHandCardsManager:_hasOneCardInSet(cardIds, cardIdsLen, cardSet)
    if cardIds == nil or cardSet == nil then return end

    for i = 1, cardIdsLen do
        for j = 1, #cardSet do
            if cardIds[i] == cardSet[j] then
                return true
            end
        end
    end

    return false
end

--确认上次排好序的同花顺内容是否过时
function MyHandCardsManager:_checkThsUnchanged(thsSet1, thsSet2)
    if thsSet1 == nil or #thsSet1 <= 0 or thsSet2 == nil or #thsSet2 <= 0 then
        return false
    end

    if #thsSet1 ~= #thsSet2 then
        return false
    end

    for i = 1, #thsSet1 do
        local thsCardIds1 = thsSet1[i]["thsCardIds"]
        local thsCardIds2 = thsSet2[i]["thsCardIds"]
        if thsCardIds2 == nil then
            return false
        end

        for j = 1, 5 do
            if thsCardIds1[j] ~= thsCardIds2[j] then
                return false
            end
        end
    end

    return true
end

-- 同花顺选择器相关代码
function MyHandCardsManager:ope_BuildCardTHS(nInCards, nInCardLen, nOutCardsArray, nOutCardLen, in_type, out_type, dwUniteSupport, bnUseJoker)
    local gameFlags = GamePublicInterface:getGameFlags()

    local lay = {}
    MyCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)

    local jokerCount = MyCalculator:preDealCards(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
    if not bnUseJoker then
        jokerCount = 0
    end

    MyCalculator:copyTable(out_type, in_type)

    local flags = MyGameDef.MY_COMPARE_UNITE_TYPE_TONGHUASHUN
 --[[   if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_TongHuaShun(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 5) then
        MyCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end
]]--
    local maxCount = 5
    local bGetMax = true
    local outUniteTypes = {}
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyCalculator:getCardType_TongHuaShunMore(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, maxCount,bGetMax, outUniteTypes ) then
        
        -- outUniteTypes 可能返回多组 主值相同的同花顺（如黑桃76543  梅花76543）
        for k,v in pairs(outUniteTypes) do 
            nOutCardsArray[k] = {}
            MyCalculator:xygInitChairCards(nOutCardsArray[k], SKGameDef.SK_MAX_CARDS_PER_CHAIR)
            MyCalculator:copyCardIDs(nOutCardsArray[k], outUniteTypes[k].nCardIDs)
        end
        --MyCalculator:copyCardIDs(nOutCards[k], outUniteTypes[k].nCardIDs)
        return true
    end

    return false
end

function MyHandCardsManager:getTHSRemindCards(remindCardsArrayOut)
    local waitCardUniteType = {}
    waitCardUniteType.nMainValue = 100013   -- 表示AAAAA炸弹。比同花顺最小的炸弹
    waitCardUniteType.dwCompareType =SKGameDef.SK_COMPARE_UNITE_TYPE_BOMB  -- 5991 ???
    waitCardUniteType.nCardIDs = {}
    table.insert(waitCardUniteType.nCardIDs,  12)
    table.insert(waitCardUniteType.nCardIDs,  25)
    table.insert(waitCardUniteType.nCardIDs,  38)
    table.insert(waitCardUniteType.nCardIDs,  51)
    table.insert(waitCardUniteType.nCardIDs,  66)
    waitCardUniteType.dwCardType = SKGameDef.SK_CARD_UNITE_TYPE_BOMB
    waitCardUniteType.nCardsCount = 5
    
    --local remindCards   = {}
    local bnUseJoker = true
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end
    if myHandCards._FriendCardsCount > 0 then  return false end

    local inhandCards, cardsCount = myHandCards:getHandCardIDs()
    if not self._remindTHSUniteType then
        self._remindTHSUniteType = waitCardUniteType
    end
    if self:ope_BuildCardTHS(inhandCards, cardsCount, remindCardsArrayOut, cardsCount, self._remindTHSUniteType, self._remindTHSUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, bnUseJoker) then
        return true
    else
        self._remindTHSUniteType = nil
        return false
    end
    return false
end

function MyHandCardsManager:buildAllTonghuaShun()
    self._shapeRefCounts1 = {}  -- 清空一下防止有影响
    self._shapeRefCounts2 = {}
    
    local allRemindCards= {}    -- while循环获取所有的同花顺
    allRemindCards[SKGameDef.SK_CS_SPADE] = {}      -- 黑
    allRemindCards[SKGameDef.SK_CS_HEART] = {}      -- 红
    allRemindCards[SKGameDef.SK_CS_CLUB] = {}      -- 梅
    allRemindCards[SKGameDef.SK_CS_DIAMOND] = {}      -- 方

    local tempStrAllRemindCards= {}  
    self._allTHSWithJoker = {}
    self._allTHSWithoutJoker = {}
    for i=0,3 do
        self._allTHSWithJoker[i] = {}
        self._allTHSWithoutJoker[i] = {}
    end
    
    local remindCardsArray = {} -- 保存其中一次循环的结果，有可能有两个以上等值不同花色的 同花顺
    while(self:getTHSRemindCards(remindCardsArray)) do
        for k,cardIDs in pairs(remindCardsArray) do
            if next(cardIDs) then
                local bHasJoker = false
                local oneCardID = cardIDs[1]
                for k,v in pairs(cardIDs) do
                    if not MyCalculator:isJoker(v) then
                        oneCardID = v
                        break
                    end
                end
                for k,v in pairs(cardIDs) do
                    if MyCalculator:isJoker(v) then
                        bHasJoker = true
                        break
                    end
                end

                local cardShape = MyCalculator:getCardShape(oneCardID, 0)
                table.insert(allRemindCards[cardShape], clone(cardIDs))
                if bHasJoker then
                    --因为循环可能出现重复的牌数组，需要去重

                    local strCardIDs = string.format("%d_%d_%d_%d_%d", cardIDs[1],cardIDs[2],cardIDs[3],cardIDs[4],cardIDs[5])
                    if tempStrAllRemindCards[strCardIDs] == nil then
                        tempStrAllRemindCards[strCardIDs] = (cardIDs)
                        table.insert(self._allTHSWithJoker[cardShape], clone(cardIDs))
                    end
                else

                    local strCardIDs = string.format("%d_%d_%d_%d_%d", cardIDs[1],cardIDs[2],cardIDs[3],cardIDs[4],cardIDs[5])
                    if tempStrAllRemindCards[strCardIDs] == nil then
                        tempStrAllRemindCards[strCardIDs] = (cardIDs)
                        table.insert(self._allTHSWithoutJoker[cardShape], clone(cardIDs))
                    end
                end
            end
        end
        remindCardsArray = {}
    end
    return allRemindCards
end

function MyHandCardsManager:getMySelectCardIDsEx()
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        return self._SKHandCards[self._gameController:getMyDrawIndex()]:getSelectCardIDsEx()
    end
end

return MyHandCardsManager
