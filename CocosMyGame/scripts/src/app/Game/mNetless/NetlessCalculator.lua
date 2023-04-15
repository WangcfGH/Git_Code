
if nil == cc or nil == cc.exports then
    return
end

local MyCalculator                              = import("src.app.Game.mMyGame.MyCalculator")

cc.exports.NetlessCalculator                         = {}
local NetlessCalculator                              = cc.exports.NetlessCalculator

local GamePublicInterface                       = import("src.app.Game.mMyGame.GamePublicInterface")

NetlessCalculator.super = MyCalculator
setmetatable(NetlessCalculator, {__index = NetlessCalculator.super})

local MyGameUtilsInfoManager = {}

function NetlessCalculator:CreateGameUtilsInfoManager()
    MyGameUtilsInfoManager = GamePublicInterface._gameController._baseGameUtilsInfoManager
end

NetlessCalculator.m_vBestDivideUnite = {}
--AI部分

function NetlessCalculator:PreAnalyseCards(nCardIDs, nCardLen)
    local divideCards = {}
    local divideCnt = 0
    self.m_MaxDivideCount = 27
    self.m_nMaxBombCnt  = 0
    self.m_nMaxValue = 0

    local nCardLay     = {}
    self:xygZeroLays(nCardLay, SKGameDef.SK_LAYOUT_NUM)
    local nJokerCount, NotUsecardsCount, nJokerCardID = self:preDealCards(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)
    
    local nTemp = {}
    local nIterationCount=1
    local allUnite = {}
    local tempType = self:initUniteType()
    for i = 1 , MyGameDef.MY_CHAIR_CARDS do
        allUnite[i] = {}
        self:copyTable(allUnite[i], tempType)
    end
    --先找王炸
    if self:getCardType_4King(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, nJokerCount, tempType) then
        self:copyTable(allUnite[nIterationCount], tempType)
        nIterationCount = nIterationCount+1
        self:copyCardIDs(nTemp, tempType.nCardIDs)
        self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
        tempType = self:initUniteType()
        nCardLay[14] = 0
        nCardLay[15] = 0
    end

    --超级炸弹
    for i = 8, 6, -1 do
        while self:getCardType_SuperBomb(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM ,0 , tempType, i) do
            self:copyTable(allUnite[nIterationCount], tempType)
            nIterationCount = nIterationCount+1
            self:copyCardIDs(nTemp, tempType.nCardIDs)
            self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
            tempType = self:initUniteType()
            nCardLay[self:getCardIndex(nTemp[1])] = 0
        end
    end
    --同花顺
    for n = 0, 1 do
        if nJokerCount < n then
            break
        end
        local TongHuaShun = {}
        local THSCount = 0
        while self:getCardType_TongHuaShun(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM ,n , tempType, 5) do
        
            local UseJokerNum = 0
            local bombNum = 0
            for j=1 , tempType.nCardsCount do
                if tempType.nCardIDs[j] == -1 then
                    break
                else
                    if self:isJoker(tempType.nCardIDs[j]) then    
                        UseJokerNum = UseJokerNum+1
                    end
                end

                local cardIndex = self:getCardIndex(tempType.nCardIDs[j], 0)
                if not self:isJoker(tempType.nCardIDs[j]) and nCardLay[cardIndex] >= 4 then
                    bombNum = bombNum+1
                end
            end

            if bombNum < 2 then
                self:copyTable(allUnite[nIterationCount], tempType)
                nIterationCount = nIterationCount+1
                self:copyCardIDs(nTemp, tempType.nCardIDs)

                self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
                
                for k = 1, tempType.nCardsCount do
                    if nTemp[k] ~= -1 and not self:isJoker(nTemp[k]) then
                        nCardLay[self:getCardIndex(nTemp[k])] = nCardLay[self:getCardIndex(nTemp[k])] - 1
                    end
                end    
                tempType = self:initUniteType()

                nJokerCount = nJokerCount - UseJokerNum

                if n > 0 and nJokerCount == 0 then
                    break
                end
            end
        end    
    end

    --炸弹 
    while self:getCardType_Bomb(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM ,0 , tempType, 5) do -- 先找5个头的（不用百搭）     
        self:copyTable(allUnite[nIterationCount], tempType)
        nIterationCount = nIterationCount+1
        self:copyCardIDs(nTemp, tempType.nCardIDs)
        self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
        tempType = self:initUniteType()
            
        nCardLay[self:getCardIndex(nTemp[1])] = 0
    end

    for n = 0, 1 do
        if nJokerCount < n then
            break
        end
        while self:getCardType_Bomb(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM ,n , tempType, 4) do -- 先找4个头的（用百搭）
            local UseJokerNum = 0
            local deleteIndex = -1
            for j=1 , tempType.nCardsCount do
                if tempType.nCardIDs[j] == -1 then
                    break
                else
                    if self:isJoker(tempType.nCardIDs[j]) then    
                        UseJokerNum = UseJokerNum+1
                    else
                        deleteIndex = j
                    end
                end
            end
            
            self:copyTable(allUnite[nIterationCount], tempType)
            nIterationCount = nIterationCount+1
            self:copyCardIDs(nTemp, tempType.nCardIDs)

            self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
            tempType = self:initUniteType()
                 
            nCardLay[self:getCardIndex(nTemp[deleteIndex])] = 0

            nJokerCount = nJokerCount - UseJokerNum

            if n > 0 and nJokerCount == 0 then
                break
            end
        end
    end   
    
    --顺子
    for n = 0, 1 do
        if nJokerCount < n then
            break
        end
        while self:getCardType_ABT_Single(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, n, tempType, 5) do
            local UseJokerNum = 0
            local singleCount = 0
            for j=1 , tempType.nCardsCount do
                if tempType.nCardIDs[j] == -1 then
                    break
                else
                    if self:isJoker(tempType.nCardIDs[j]) then    
                        UseJokerNum = UseJokerNum+1
                    end
                end

                local cardIndex = self:getCardIndex(tempType.nCardIDs[j], 0)
                if self:isJoker(tempType.nCardIDs[j]) or nCardLay[cardIndex] == 1 then
                    singleCount = singleCount+1
                end
            end
            if singleCount >= 3 then
                self:copyTable(allUnite[nIterationCount], tempType)
                nIterationCount = nIterationCount+1
                self:copyCardIDs(nTemp, tempType.nCardIDs)
                self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
            
                for k = 1, tempType.nCardsCount do
                    if nTemp[k] ~= -1 and not self:isJoker(nTemp[k]) then
                        nCardLay[self:getCardIndex(nTemp[k])] = nCardLay[self:getCardIndex(nTemp[k])] - 1
                    end
                end 
                tempType = self:initUniteType()

                nJokerCount = nJokerCount - UseJokerNum
                if n > 0 and nJokerCount == 0 then
                    break
                end  
            end
        end
    end
    --三连队
    tempType = self:initUniteType()
    for n = 0, 1 do
        if nJokerCount < n then
            break
        end
        while self:getCardType_ABT_Three(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, n, tempType, 2) do
            local UseJokerNum = 0
            local notUse = true
            for j=1 , tempType.nCardsCount do
                if tempType.nCardIDs[j] == -1 then
                    break
                else
                    if self:isJoker(tempType.nCardIDs[j]) then    
                        UseJokerNum = UseJokerNum+1
                    end
                end

                local cardIndex = self:getCardIndex(tempType.nCardIDs[j], 0)
                if not self:isJoker(tempType.nCardIDs[j]) and cardIndex > 9 then
                    notUse = false
                end
            end
            if notUse then
                self:copyTable(allUnite[nIterationCount], tempType)
                nIterationCount = nIterationCount+1
                self:copyCardIDs(nTemp, tempType.nCardIDs)
                self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
            
                for k = 1, tempType.nCardsCount do
                    if nTemp[k] ~= -1 and not self:isJoker(nTemp[k]) then
                        nCardLay[self:getCardIndex(nTemp[k])] = nCardLay[self:getCardIndex(nTemp[k])] - 1
                    end
                end
                tempType = self:initUniteType()

                nJokerCount = nJokerCount - UseJokerNum
                if n > 0 and nJokerCount == 0 then
                    break
                end
            else
                break
            end
        end
    end
    --两连队
    tempType = self:initUniteType()
    for n = 0, 1 do
        if nJokerCount < n then
            break
        end
        while self:getCardType_ABT_Couple(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, n, tempType, 3) do
            local UseJokerNum = 0
            local notUse = true
            for j=1 , tempType.nCardsCount do
                if tempType.nCardIDs[j] == -1 then
                    break
                else
                    if self:isJoker(tempType.nCardIDs[j]) then    
                        UseJokerNum = UseJokerNum+1
                    end
                end

                local cardIndex = self:getCardIndex(tempType.nCardIDs[j], 0)
                if not self:isJoker(tempType.nCardIDs[j]) and nCardLay[cardIndex] >= 3 then
                    notUse = false
                end
            end
            if notUse then
                self:copyTable(allUnite[nIterationCount], tempType)
                nIterationCount = nIterationCount+1
                self:copyCardIDs(nTemp, tempType.nCardIDs)
                self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
            
                for k = 1, tempType.nCardsCount do
                    if nTemp[k] ~= -1 and not self:isJoker(nTemp[k]) then
                        nCardLay[self:getCardIndex(nTemp[k])] = nCardLay[self:getCardIndex(nTemp[k])] - 1
                    end
                end
                tempType = self:initUniteType()

                nJokerCount = nJokerCount - UseJokerNum
                if n > 0 and nJokerCount == 0 then
                    break
                end  
            end
        end
    end
      
    tempType = self:initUniteType()
    while self:getCardType_Three(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, 0, tempType) do
        self:copyTable(allUnite[nIterationCount], tempType)
        nIterationCount = nIterationCount+1
        self:copyCardIDs(nTemp, tempType.nCardIDs)
        self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
        tempType = self:initUniteType()
            
        nCardLay[self:getCardIndex(nTemp[1])] = 0
    end
    
    while self:getCardType_Couple(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, 0, tempType) do
        self:copyTable(allUnite[nIterationCount], tempType)
        nIterationCount = nIterationCount+1
        self:copyCardIDs(nTemp, tempType.nCardIDs)
        self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
        tempType = self:initUniteType()
            
        nCardLay[self:getCardIndex(nTemp[1])] = 0
    end
    
    while self:getCardType_Single(nCardIDs, nCardLen, tempType) do
        self:copyTable(allUnite[nIterationCount], tempType)
        nIterationCount = nIterationCount+1
        self:copyCardIDs(nTemp, tempType.nCardIDs)
        self:XygRemoveCardIDs(nCardIDs, nTemp, MyGameDef.MY_CHAIR_CARDS)
        tempType = self:initUniteType()
            
        nCardLay[self:getCardIndex(nTemp[1])] = 0
    end

    self._nIterationCount = nIterationCount-1
    return allUnite, self._nIterationCount
end

--function NetlessCalculator:PreAnalyseCards(nCardIDs, nCardLen)
--    local divideCards = {}
--    local divideCnt = 0
--    self.m_MaxDivideCount = 27
--    self.m_nMaxBombCnt  = 0
--    self.m_nMaxValue = 0

--    local nCardLay     = {}
--    self:xygZeroLays(nCardLay, SKGameDef.SK_LAYOUT_NUM)

--    local nJokerCount = self:preDealCards(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

--    --对王预先处理
--    local tempUniteDivide = {}
--    tempUniteDivide.nTypeValue = 0
--    tempUniteDivide.uniteType = self:initUniteType()
--    if self:getCardType_4King(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, nJokerCount, tempUniteDivide.uniteType) then
--        tempUniteDivide.nTypeValue = 100
--        self:XygRemoveCardIDs(nCardIDs, tempUniteDivide.uniteType.nCardIDs, MyGameDef.MY_CHAIR_CARDS)
--        table.insert(divideCards, tempUniteDivide)
--    else
--        for nCardIndex = 14, 15 do
--            if nCardLay[nCardIndex]==1 then              
--                self:xygInitChairCards(tempUniteDivide.uniteType.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
--                tempUniteDivide.uniteType.dwCardType = SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
--				tempUniteDivide.uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
--				tempUniteDivide.uniteType.nCardCount=1
--				tempUniteDivide.uniteType.nMainValue=self:getCardIndexPri(nCardIndex,MyGameUtilsInfoManager:getCurrentRank(), 0)
--				tempUniteDivide.nTypeValue = nCardIndex

--                local temp = {}
--                self:copyTable(temp, nCardIDs)
--                self:putCardToArray(tempUniteDivide.uniteType.nCardIDs, nCardLen, temp, nCardLen, nCardIndex, 1, -1)

--                self:XygRemoveCardIDs(nCardIDs, tempUniteDivide.uniteType.nCardIDs, MyGameDef.MY_CHAIR_CARDS)
--                table.insert(divideCards, tempUniteDivide)
--                divideCnt = divideCnt + 1
--                nCardLen = nCardLen - 1
--            end
--            if nCardLay[nCardIndex]==2  then
--                tempUniteDivide.uniteType.dwCardType = SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
--				tempUniteDivide.uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
--				tempUniteDivide.uniteType.nCardCount=2
--				tempUniteDivide.uniteType.nMainValue=self:getCardIndexPri(nCardIndex,MyGameUtilsInfoManager:getCurrentRank(), 0)
--				tempUniteDivide.nTypeValue = nCardIndex

--                self:xygInitChairCards(tempUniteDivide.uniteType.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)

--                local temp = {}
--                self:copyTable(temp, nCardIDs)
--                self:putCardToArray(tempUniteDivide.uniteType.nCardIDs, nCardLen, temp, nCardLen, nCardIndex, 2, -1)

--                self:XygRemoveCardIDs(nCardIDs, tempUniteDivide.uniteType.nCardIDs, MyGameDef.MY_CHAIR_CARDS)
--                table.insert(divideCards, tempUniteDivide)
--                divideCnt = divideCnt + 1
--                nCardLen = nCardLen - 2
--            end
--        end       
--    end
--    self.m_count = 0
--    self:analyseCards(nCardIDs, nCardLen, divideCards, self.m_vBestDivideUnite,
--		divideCnt,self.m_MaxDivideCount,self.m_nMaxBombCnt,self.m_nMaxValue)
--end

function NetlessCalculator:analyseCards(nCardIDs, nCardLen, divideCards, vBestDivideUnite,
		                                    divideCnt,MaxDivideCount,nMaxBombCnt,nMaxValue)
    self.m_count =  self.m_count + 1
    if self.m_count > 10000 then
        return
    end
    if nCardLen <= 0 then
        local a = 10
        local nCurBombCnt = 0
        local nTypeValue = 0
        for i = 1, table.maxn(divideCards) do
            local ct = divideCards[i].uniteType
            if ct.dwCardType>=SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
                nCurBombCnt = nCurBombCnt + 1
            end
            nTypeValue = nTypeValue + divideCards[i].nTypeValue
        end

        if divideCnt-2*nCurBombCnt < MaxDivideCount-2*nMaxBombCnt then
            MaxDivideCount = divideCnt
			vBestDivideUnite = divideCards
			nMaxBombCnt = nCurBombCnt
			nMaxValue= nTypeValue
        end

        if (divideCnt-2*nCurBombCnt == MaxDivideCount-2*nMaxBombCnt)
			and (nCurBombCnt > nMaxBombCnt) then
            MaxDivideCount = divideCnt
			vBestDivideUnite = divideCards
			nMaxBombCnt = nCurBombCnt
			nMaxValue= nTypeValue
        end
        if (divideCnt-2*nCurBombCnt == MaxDivideCount-2*nMaxBombCnt)
			and(nCurBombCnt == nMaxBombCnt)
			and(nTypeValue>nMaxValue) then

            MaxDivideCount = divideCnt;
			vBestDivideUnite = divideCards;
			nMaxBombCnt = nCurBombCnt;
			nMaxValue= nTypeValue;
        end

        self.m_MaxDivideCount = MaxDivideCount
        self.m_nMaxBombCnt = nMaxBombCnt
        self.m_nMaxValue = m_nMaxValue
        return
    end

    --如果牌还没分完，手牌数已经比当前最优分牌多
    if divideCnt > MaxDivideCount then     
        self.m_MaxDivideCount = MaxDivideCount
        self.m_nMaxBombCnt = nMaxBombCnt
        self.m_nMaxValue = m_nMaxValue
        return
    end

    local nCardLay     = {}
    self:xygZeroLays(nCardLay, SKGameDef.SK_LAYOUT_NUM)
    local nJokerCount = self:preDealCards(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local tempUniteDivide = {}
    tempUniteDivide.nTypeValue = 0
    tempUniteDivide.uniteType = self:initUniteType()

    local nTempHand = {}
    self:xygInitChairCards(nTempHand,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    self:copyTable(nTempHand, nCardIDs)

    while self:getCardType_TongHuaShun(nCardIDs, nCardLen, nCardLay, SKGameDef.SK_LAYOUT_NUM, nJokerCount, tempUniteDivide.uniteType, 5) do
        local nLeftCount = self:XygRemoveCardIDs(nCardIDs, tempUniteDivide.uniteType.nCardIDs, MyGameDef.MY_CHAIR_CARDS)
        tempUniteDivide.nTypeValue = tempUniteDivide.uniteType.nMainValue%100+40
        table.insert(divideCards, tempUniteDivide)
        self:analyseCards(nCardIDs, nLeftCount, divideCards, vBestDivideUnite,
		    divideCnt+1,MaxDivideCount,nMaxBombCnt,nMaxValue)
        table.remove(divideCards, table.maxn(divideCards))
        self:copyTable(nCardIDs, nTempHand)
    end
    tempUniteDivide.nTypeValue = 0
    tempUniteDivide.uniteType = self:initUniteType()

    local m = 0
    for i = 1, SKGameDef.SK_LAYOUT_NUM do
        if nCardLay[i] > 0 then
            m = i
            break
        else
            m = m + 1
        end
    end
    local OutLay     = {}
--    self:xygZeroLays(OutLay, SKGameDef.SK_LAYOUT_NUM)

    local dwCheckTypeS = {SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB, SKGameDef.SK_CARD_UNITE_TYPE_BOMB,SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE,
                            SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE,
                                SKGameDef.SK_CARD_UNITE_TYPE_THREE,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE,SKGameDef.SK_CARD_UNITE_TYPE_SINGLE}

    for i = 1, 9 do
        while self:ope_BulidCardEx(m,nCardIDs,nCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteDivide,dwCheckTypeS[i]) do  
            self:xygZeroLays(OutLay, SKGameDef.SK_LAYOUT_NUM)
            self:skLayCards(tempUniteDivide.uniteType.nCardIDs, MyGameDef.MY_CHAIR_CARDS, OutLay, 0)

            if nCardLay[m] >= OutLay[m] and OutLay[m] > 0 then
                local nLeftCount = self:XygRemoveCardIDs(nCardIDs, tempUniteDivide.uniteType.nCardIDs, MyGameDef.MY_CHAIR_CARDS)
                table.insert(divideCards, tempUniteDivide)
                self:analyseCards(nCardIDs, nLeftCount, divideCards, vBestDivideUnite,
		            divideCnt+1,MaxDivideCount,nMaxBombCnt,nMaxValue)
                table.remove(divideCards, table.maxn(divideCards))
                self:copyTable(nCardIDs, nTempHand)
            end
        end
        tempUniteDivide.nTypeValue = 0
        tempUniteDivide.uniteType = self:initUniteType()
        self:xygInitChairCards(tempUniteDivide.uniteType.nCardIDs,MyGameDef.MY_CHAIR_CARDS)
    end
    
    
end

function NetlessCalculator:ope_BulidCardEx(nNeedIndex, nInCards, nInCardLen, nCardLay, nOutCardLen, nJokerCount, tempUniteType, dwUniteSupport)
    
    if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_SINGLE then
        if self:GetCardType_SingleExEx(nNeedIndex,nInCards,nInCardLen,nCardLay,tempUniteType.uniteType) then
            tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
            return true
        end
    end

    if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
		if self:GetCardType_CoupleExEx(nNeedIndex,nInCards,nInCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteType.uniteType) then
			tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
			return true
		end
	end

	if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_THREE then
		if self:GetCardType_ThreeExEx(nNeedIndex,nInCards,nInCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteType.uniteType) then
			tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
			return true
		end
	end

	if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
		if self:GetCardType_Three_CoupleExEx(nNeedIndex,nInCards,nInCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteType.uniteType) then
			tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
			return true
		end
	end

	if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
		if self:GetCardType_ABT_ThreeExEx(nNeedIndex,nInCards,nInCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteType.uniteType, 2) then
			tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
			return true
		end
	end

	if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
		if self:GetCardType_ABT_CoupleExEx(nNeedIndex,nInCards,nInCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteType.uniteType, 3) then
			tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
			return true
		end
	end

	if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
		if self:GetCardType_ABT_SingleExEx(nNeedIndex,nInCards,nInCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteType.uniteType, 5) then
			tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
			return true
		end
	end

	if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
		if self:GetCardType_SuperBombExEx(nNeedIndex,nInCards,nInCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteType.uniteType, 0) then
			tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
			return true
		end
	end

	if dwUniteSupport ==SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
		if self:GetCardType_BombExEx(nNeedIndex,nInCards,nInCardLen,nCardLay, SKGameDef.SK_LAYOUT_NUM,nJokerCount,tempUniteType.uniteType, 0) then
			tempUniteType.nTypeValue = self:GetUniteTypeValue(tempUniteType.uniteType)
			return true
		end
	end
    

    return false
end

function NetlessCalculator:GetUniteTypeValue(unite)
	local nValue = 0;
	if unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SINGLE then
        nValue =  unite.nMainValue
    elseif unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
        nValue =  unite.nMainValue
    elseif unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
        nValue =  unite.nMainValue
    elseif unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
        nValue =  unite.nMainValue/10000
    elseif unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        nValue =  unite.nMainValue%1000
    elseif unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
        nValue =  unite.nMainValue%1000
    elseif unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        nValue =  unite.nMainValue-100
    elseif unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        nValue =  unite.nMainValue%10000+40
    elseif unite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
        nValue =  unite.nMainValue%10000+40
    end

	return nValue
end

function NetlessCalculator:GetCardType_SingleExEx(nNeedIndex,nCardIDs,nCardLen,nCardLay, type)
	if nCardLen<=0 then
		return false
    end

	if nCardLay[nNeedIndex]>1 then--大于1张的不拆成单牌,（顺子会拆的）
		return false
    end

	local nMinCardID=-1
	local nValue=type.nMainValue
	local nMinValue=-1
	for i = 1, nCardLen do
		if nCardIDs[i]==-1 then break end
		if (self:getCardPriEx(nCardIDs[i],MyGameUtilsInfoManager:getCurrentRank(), 0)>nValue
			and self:getCardIndex(nCardIDs[i],0)==nNeedIndex) then
			if (nMinCardID==-1 or self:getCardPriEx(nCardIDs[i],MyGameUtilsInfoManager:getCurrentRank(), 0)<nMinValue) then
				nMinValue=self:getCardPriEx(nCardIDs[i],MyGameUtilsInfoManager:getCurrentRank(), 0)
				nMinCardID=nCardIDs[i]
			end
		end
	end

	if (nMinValue==-1) then return false end

    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
	type.dwCardType=SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
	type.dwComPareType=SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
	type.nCardCount=1
	type.nMainValue=nMinValue
	type.nCardIDs[1]=nMinCardID

	return true
end

function NetlessCalculator:GetCardType_CoupleExEx(nNeedIndex,nCardIDs,nCardLen,nCardLay,nLayLen, nJokerCount, type)
    if nCardLen<=0 or nLayLen<=0 then
        return false
    end
    if nCardLay[nNeedIndex]+nJokerCount<2 or self:getCardIndexPri(nNeedIndex,MyGameUtilsInfoManager:getCurrentRank(), 0)<=type.nMainValue then
        return false
    end
    if nCardLay[nNeedIndex]>2 then --大于2张的不拆,（顺子会拆的）
        return false
    end
    if (nNeedIndex==14 or nNeedIndex==15) and nCardLay[nNeedIndex]<=1 then
        return false
    end

    type.dwCardType=SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
	type.dwComPareType=SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
	type.nCardCount=2
	type.nMainValue=self:getCardIndexPri(nNeedIndex,MyGameUtilsInfoManager:getCurrentRank(), 0)
    
    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)

    local temp = {}
    self:copyTable(temp, nCardIDs)
    self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, nNeedIndex, 2, -1)
    
	return true
end

function NetlessCalculator:GetCardType_ThreeExEx(nNeedIndex,nCardIDs,nCardLen,nCardLay,nLayLen, nJokerCount, type)
    if nCardLen<=0 or nLayLen<=0 then
        return false
    end
    if nCardLay[nNeedIndex]+nJokerCount<3 or self:getCardIndexPri(nNeedIndex,MyGameUtilsInfoManager:getCurrentRank(), 0)<=type.nMainValue then
        return false
    end
    if nCardLay[nNeedIndex]<2 then --最多用一张百搭牌
        return false
    end
    if nCardLay[nNeedIndex]>3 then --大于3张的不拆,（顺子会拆的）
        return false
    end
    if (nNeedIndex==14 or nNeedIndex==15) and nCardLay[nNeedIndex]<=2 then
        return false
    end

    type.dwCardType=SKGameDef.SK_CARD_UNITE_TYPE_THREE
	type.dwComPareType=SKGameDef.SK_CARD_UNITE_TYPE_THREE
	type.nCardCount=3
	type.nMainValue=self:getCardIndexPri(nNeedIndex,MyGameUtilsInfoManager:getCurrentRank(), 0)
    
    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)

    local temp = {}
    self:copyTable(temp, nCardIDs)
    self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, nNeedIndex, 3, -1)
    
	return true
end

function NetlessCalculator:GetCardType_ABT_ThreeExEx(nNeedIndex,nCardIDs,nCardLen,nCardLay,nLayLen, nJokerCount, type, nMaxPair)
    if nCardLen<=0 or nLayLen<=0 then
        return false
    end
    if nMaxPair < 2 then
        return false
    end
    local bUseRank = true
    if MyGameUtilsInfoManager:getWaitChair() == -1 then
        bUseRank = false
    end
    local nStartIndex = -1
    local nValue=0
    if type.dwCardType==SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        if type.nCardCount~=nMaxPair*3 then
            return false
        end
        nValue=type.nMainValue
    end
    local nMinValue=-1
	local nBaseValue=1000*nMaxPair
    
    for i = 2, (14 - nMaxPair)  do
        if i > nNeedIndex or i < (nNeedIndex-1) then
        else
            if nCardLay[i]>3 then
            else
                local Joker_Need = 0
                local bContainRank = false
                for j = 0, nMaxPair-1 do
                    if nCardLay[i+j]<3 then
                        Joker_Need = Joker_Need + 3-nCardLay[i+j]
                    end
                    if j == MyGameUtilsInfoManager:getCurrentRank() then
                        bContainRank = true
                    end
                end
                if not bUseRank and bContainRank then
                else
                    if Joker_Need >= 1 then
                    else
                        if Joker_Need <= nJokerCount and self:getCardIndexPri(i,-1, 0)+nBaseValue > nValue then
                            if nMinValue==-1 or self:getCardIndexPri(i,-1, 0) + nBaseValue < nMinValue then
                                nStartIndex=i
                                nMinValue=self:getCardIndexPri(i,-1, 0)+nBaseValue
                            end
                        end
                    end
                end
            end
        end
    end

    if nStartIndex== -1 then
        return false
    end
    type.dwCardType=SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
	type.dwComPareType= SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
	type.nMainValue=nMinValue --顺子中级牌还原
	type.nCardCount=nMaxPair*3
    
    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local temp = {}
    self:copyTable(temp, nCardIDs)
    if nStartIndex== 0 then
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 13, 3, -1)
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 1, 3, -1)
    else
        for i = 0, nMaxPair-1  do
            self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, nStartIndex+i, 3, -1)
        end
    end

	return true
end

function NetlessCalculator:GetCardType_ABT_CoupleExEx(nNeedIndex,nCardIDs,nCardLen,nCardLay,nLayLen, nJokerCount, type, nMaxPair)
    if nCardLen<=0 or nLayLen<=0 then
        return false
    end
    if nMaxPair < 2 then
        return false
    end
    local bUse2 = true  --顺子是否可以带2
    if MyGameUtilsInfoManager:getWaitChair() == -1 and MyGameUtilsInfoManager:getCurrentRank()==1 then
        bUse2 = false
    end
    local nStartIndex = -1
    local nValue=0
    if type.dwCardType==SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
        if type.nCardCount~=nMaxPair*2 then
            return false
        end
        nValue=type.nMainValue
    end
    local nMinValue=-1
	local nBaseValue=1000*nMaxPair
    for i = 1, (14 - nMaxPair)  do
        if i > nNeedIndex or i < (nNeedIndex-2) then
        else
            local Joker_Need = 0
            for j = 0, nMaxPair-1  do
                if nCardLay[i+j]<2 then
                    Joker_Need=Joker_Need + 2-nCardLay[i+j]
                end
            end
            if Joker_Need>=1 then
            else
                if Joker_Need<=nJokerCount and self:getCardIndexPri(i,-1, 0)+nBaseValue > nValue then
                    if nMinValue==-1 or self:getCardIndexPri(i,-1, 0) + nBaseValue < nMinValue then
                        nStartIndex=i
                        nMinValue=self:getCardIndexPri(i,-1, 0)+nBaseValue
                    end
                end
            end
        end
    end

    if bUse2 then
        local Joker_Need=0
        if nCardLay[13]<2 then
            Joker_Need=Joker_Need + 2-nCardLay[13]
        end
        if nCardLay[1]<2 then
            Joker_Need=Joker_Need + 2-nCardLay[1]
        end
        if nCardLay[2]<2 then
            Joker_Need=Joker_Need + 2-nCardLay[1]
        end
        if Joker_Need <= 1 and Joker_Need <= nJokerCount and nValue==0 then
            if nMinValue==-1 or self:getCardIndexPri(0,-1, 0) + 1000 < nMinValue then
                nStartIndex=0
                nMinValue=self:getCardIndexPri(0,-1, 0)+nBaseValue
            end
        end
    end

    if nStartIndex== -1 then
        return false
    end
    type.dwCardType=SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE;
	type.dwComPareType= SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE; 
	type.nMainValue=nMinValue --顺子中级牌还原
	type.nCardCount=nMaxPair*2
    
    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local temp = {}
    self:copyTable(temp, nCardIDs)
    if nStartIndex== 0 then
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 13, 2, -1)
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 1, 2, -1)
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 2, 2, -1)
    else
        for i = 0, nMaxPair-1  do
            self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, nStartIndex+i, 2, -1)
        end
    end

	return true
end

function NetlessCalculator:GetCardType_ABT_SingleExEx(nNeedIndex,nCardIDs,nCardLen,nCardLay,nLayLen, nJokerCount, type, nMaxCount)
    if nCardLen<=0 or nLayLen<=0 then
        return false
    end
    if nMaxCount ~= 5 then
        return false
    end
    
    local SKHandCardsManager = GamePublicInterface._gameController._baseGameScene:getSKHandCardsManager()
    local currentDrawIndex = GamePublicInterface._gameController:getCurrentIndex()
    
    local bUse2 = true  --顺子是否可以带2
    if MyGameUtilsInfoManager:getWaitChair() == -1 and MyGameUtilsInfoManager:getCurrentRank()==1 then
        local myHandCards = SKHandCardsManager:getSKHandCards(currentDrawIndex)       
        local nInHand, nCardCount = myHandCards:getHandCardIDs()

        local nCardLayEx     = {}
        self:xygZeroLays(nCardLayEx, SKGameDef.SK_LAYOUT_NUM)
        local nJokerCount = self:preDealCards(nInHand, nCardCount, nCardLayEx, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

        local singlCount = 0
        for i = 2, 5 do
            if nCardLayEx[i]==1 then
                singlCount = singlCount + 1
            end
        end
        if singlCount < 3 then       
            bUse2 = false
        end
    end

    local nStartIndex = -1
    local nValue=0
    if type.dwCardType==SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        if type.nCardCount~=nMaxCount then
            return false
        end
        nValue=type.nMainValue
    end
    local nMinValue=-1

    local m = 2
    if bUse2 then
        m = 1
    end
    for i = m, (14 - nMaxCount)  do
        if i > nNeedIndex or i < (nNeedIndex-4) then
        else
            local abt_count = 0
            for j = 0, nMaxCount-1  do
                if nCardLay[i+j]~=0 then
                    abt_count = abt_count+1
                end
            end
            if abt_count + nJokerCount >= nMaxCount and self:getCardIndexPri(i,-1, 0)+100 > nValue then
                if nMinValue==-1 or self:getCardIndexPri(i,-1, 0) + 100 < nMinValue then
                    nStartIndex=i
                    nMinValue=self:getCardIndexPri(i,-1, 0)+100
                end
            end
        end
    end

    if bUse2 then
        local abt_count=0
        if nCardLay[13] > 0 then
            abt_count=abt_count + 1
        end
        if nCardLay[1] > 0 then
            abt_count=abt_count + 1
        end
        if nCardLay[2] > 0 then
            abt_count=abt_count + 1
        end
        if nCardLay[3] > 0 then
            abt_count=abt_count + 1
        end
        if nCardLay[4] > 0 then
            abt_count=abt_count + 1
        end
        if abt_count + nJokerCount >= nMaxCount and nValue == 0 then
            if nMinValue==-1 or self:getCardIndexPri(0,-1, 0) + 100 < nMinValue then
                nStartIndex=0
                nMinValue=self:getCardIndexPri(0,-1, 0)+100
            end
        end
    end

    if nStartIndex== -1 then
        return false
    end
    type.dwCardType=SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE;
	type.dwComPareType= SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE; 
	type.nMainValue=nMinValue --顺子中级牌还原
	type.nCardCount=nMaxCount
    
    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local temp = {}
    self:copyTable(temp, nCardIDs)
    if nStartIndex== 0 then
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 13, 1, -1)
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 1, 1, -1)
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 2, 1, -1)
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 3, 1, -1)
        self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, 4, 1, -1)
    else
        for i = nStartIndex, nStartIndex + nMaxCount - 1  do
            self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, i, 1, -1)
        end
    end

	return true
end

function NetlessCalculator:GetCardType_Three_CoupleExEx(NeedIndex,nCardIDs,nCardLen,nCardLay,nLayLen, nJokerCount, type)
    if nCardLen<=0 or nLayLen<=0 then
        return false
    end
    local bnFind, nMainIndex,nSecondIndex =  self:GetDoubleCountExEx(NeedIndex,nCardIDs,nLayLen,3,2,nJokerCount,type.nMainValue)
    if not bnFind then
        return false
    end
    local rank = MyGameUtilsInfoManager:getCurrentRank()

    type.dwCardType=SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
	type.dwComPareType=SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
	type.nMainValue=self:getCardIndexPri(nMainIndex,rank, 0)*10000+self:getCardIndexPri(nSecondIndex,rank, 0)
	--type.nMainValue=SK_GetIndexPRIEx(nMainIndex,GetCurrentRank(), 0)*10000;
	type.nCardCount=5

    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local temp = {}
    self:copyTable(temp, nCardIDs)
    self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, nMainIndex, 3, -1)
    self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, nSecondIndex, 2, -1)

	return true
end

function NetlessCalculator:GetDoubleCountExEx(NeedIndex, nCardLay, nLayLen, nCount1, nCount2, nJokerCount, nDestValue)
	local nMainIndex=-1;
	local nSecondeIndex=-1;
	local nValue=0;

	local bUseRank = true  --顺子是否可以带2
    if MyGameUtilsInfoManager:getWaitChair() == -1 then
        bUseRank = false
    end

    local currentRank = MyGameUtilsInfoManager:getCurrentRank()

    for i = 1, nLayLen do
        if 0 < nCardLay[i] then
            local nRest=nJokerCount
            if nRest + nCardLay[i] >= nCount1 then
                if (nCount1>nCardLay[i])and(i>=14) then
                else
                    if nCardLay[i]>nCount1 then
                    else
                        local temp=nCardLay[i]
                        if nCount1>nCardLay[i] then
                            nRest=nRest-(nCount1-nCardLay[i]) --去掉财神
				            nCardLay[i]=0
                        else
                            nCardLay[i]=nCardLay[i] - nCount1
                        end
                        for j = 1, nLayLen do
                            if i ~= j and 0 < nCardLay[i] then
                                if not bUseRank and j==currentRank then
                                else
                                    if (nCount2>nCardLay[j])and(j>=14) or nCardLay[j]>nCount2 then
                                    else
                                        if nRest+nCardLay[j]>=nCount2 then
                                            if (nJokerCount-nRest)>1  then
                                            else
                                                local nThisValue = self:getCardIndexPri(i,currentRank, 0)*10000+self:getCardIndexPri(j,currentRank, 0)
                                                local index = self:getCardIndexPri(i,currentRank, 0)
                                                if nThisValue>nDestValue and (NeedIndex==i or NeedIndex==j) then
                                                    if nMainIndex==-1 or nThisValue<nValue then
                                                        nMainIndex=i
							                            nSecondeIndex=j
							                            nValue=nThisValue
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        nCardLay[i]=temp
                    end
                end
            end
        end
    end
    if nMainIndex == -1 then
        return false
    else
        return true, nMainIndex, nSecondeIndex
    end
end

function NetlessCalculator:GetSameCountExEx(NeedIndex, nCardLay, nLayLen, nSameCount, nJokerCount, nDestValue)
    local bigestIndex=-1
    local nSmallValue=0
    if nCardLay[NeedIndex] <= 0 then
        return bigestIndex
    end
    local n = 0 
    if nSameCount>4 then
        n=(nSameCount-4)*10000
    end

    local rank =  MyGameUtilsInfoManager:getCurrentRank()

    if nCardLay[NeedIndex]+nJokerCount>=nSameCount
		and nCardLay[NeedIndex]>=(nSameCount-1)
		and self:getCardIndexPri(NeedIndex,rank, 0)+n>nDestValue then

        if bigestIndex==-1
			or self:getCardIndexPri(NeedIndex,rank, 0)+n<nSmallValue then
            bigestIndex = NeedIndex
            nSmallValue = self:getCardIndexPri(NeedIndex,rank, 0)+n
        end
    end
    return bigestIndex
end

function NetlessCalculator:GetCardType_BombExEx(NeedIndex,nCardIDs,nCardLen,nCardLay,nLayLen, nJokerCount, type, nUseCount)
    if nCardLen<=0 or nLayLen<=0 then
        return false
    end
    if nCardLay[NeedIndex]+nJokerCount<4 then
        return false
    end
    
    local rank =  MyGameUtilsInfoManager:getCurrentRank()

    local nValue=0
    if type.dwCardType==SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
        nValue=type.nMainValue
    end
    local nCardCount=0
    local nCardIndex=-1
    if nUseCount > 0 then
        nCardCount=nUseCount
        nCardIndex=self:GetSameCountExEx(NeedIndex,nCardLay,nLayLen,nUseCount,nJokerCount,nValue)
        if nCardIndex ==-1 then
            return false
        end
    else
        for i = 4, 5 do
            nCardIndex=self:GetSameCountExEx(NeedIndex,nCardLay,nLayLen,i,nJokerCount,nValue)
            if nCardIndex ~=-1 then
                nCardCount = i
                break
            end
        end
        if nCardIndex ==-1 then
            return false
        end
    end

    type.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_BOMB
    type.dwComPareType = MyGameDef.MY_COMPARE_UNITE_TYPE_BOMB
	type.nMainValue=self:getCardIndexPri(nCardIndex,rank, 0)
    
    if nCardCount == 5 then
        type.nMainValue=type.nMainValue+10000
    end
	type.nCardCount=nCardCount

    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local temp = {}
    self:copyTable(temp, nCardIDs)
    self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, nCardIndex, nCardCount, -1)

	return true
end

function NetlessCalculator:GetCardType_SuperBombExEx(NeedIndex,nCardIDs,nCardLen,nCardLay,nLayLen, nJokerCount, type, nUseCount)
    if nCardLen<=0 or nLayLen<=0 then
        return false
    end
    if nCardLay[NeedIndex]+nJokerCount<6 then
        return false
    end
    
    local rank =  MyGameUtilsInfoManager:getCurrentRank()

    local nValue=0
    if type.dwCardType==SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        nValue=type.nMainValue
    end
    local nCardCount=6
    local nCardIndex=-1
    if nUseCount > 0 then
        nCardCount=nUseCount
        nCardIndex=self:GetSameCountExEx(NeedIndex,nCardLay,nLayLen,nUseCount,nJokerCount,nValue)
        if nCardIndex ==-1 then
            return false
        end
    else
        for i = 6, 10 do
            nCardCount = i
            nCardIndex=self:GetSameCountExEx(NeedIndex,nCardLay,nLayLen,nCardCount,nJokerCount,nValue)
            if nCardIndex ~=-1 then
                break
            end
        end
        if nCardIndex ==-1 then
            return false
        end
    end

    type.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB
    type.dwComPareType = MyGameDef.MY_COMPARE_UNITE_TYPE_SUPER_BOMB
	type.nMainValue=self:getCardIndexPri(nCardIndex,rank, 0)
    
    for i = 1, nCardCount-4 do
        type.nMainValue=type.nMainValue+10000
    end
    
	type.nCardCount=nCardCount

    self:xygInitChairCards(type.nCardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local temp = {}
    self:copyTable(temp, nCardIDs)
    self:putCardToArray(type.nCardIDs, nCardLen, temp, nCardLen, nCardIndex, nCardCount, -1)

	return true
end

function NetlessCalculator:XygRemoveCardIDs(nCardID, nRemoveCard, nCardsLen)
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

function NetlessCalculator:PM_Zip(sin, sinNum, LowNum)
    local temp ={};
    local num = 1
    for i=1, sinNum do
        temp[i]=LowNum
        if sin[i] and sin[i]>LowNum then
            temp[num] = sin[i]
            num = num+1
        end
    end
    self:copyTable(sin, temp)
    return num
end


return NetlessCalculator
