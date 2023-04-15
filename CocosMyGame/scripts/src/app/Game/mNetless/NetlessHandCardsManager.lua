
local MyHandCardsManager = import("src.app.Game.mMyGame.MyHandCardsManager")
local NetlessHandCardsManager = class("NetlessHandCardsManager", MyHandCardsManager)

local NetlessCalculator = import("src.app.Game.mNetless.NetlessCalculator")

function NetlessHandCardsManager:getSelectCardIDs(drawIndex)
    if self._SKHandCards[drawIndex] then
        return self._SKHandCards[drawIndex]:getSelectCardIDs()
    end
end

function NetlessHandCardsManager:getHandCardsCount(drawIndex)
    return self._SKHandCards[drawIndex]:getHandCardsCount()
end

function NetlessHandCardsManager:ope_AddTributeAndReturnCard(drawIndex, cardID)
    self:ope_UnselectSelfCardsRoot(drawIndex)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:ope_AddTributeAndReturnCard(cardID)
    end
    if drawIndex == self._gameController:getMyDrawIndex() then
        -- 进还贡后，重新计算同花顺选择器
        self._allTHSCardsArr = self:buildAllTonghuaShun()
        self:setShapeButtonsStatus()
    end
end

function NetlessHandCardsManager:onHintRoot(drawIndex)
    self:ope_UnselectSelfCardsRoot(drawIndex)

    local myHandCards = self:getSKHandCards(drawIndex)
    if not myHandCards then return end

    local currentChairNo = self._gameController:rul_GetChairNOByDrawIndex(drawIndex)

    local EnemyHandCards1 = self:getSKHandCards(self._gameController:rul_GetDrawIndexByChairNO((currentChairNo+1)%4))
    local EnemyHandCards2 = self:getSKHandCards(self._gameController:rul_GetDrawIndexByChairNO((currentChairNo+3)%4))
    local EnemyinhandCards1, EnemycardsCount1 = EnemyHandCards1:getHandCardIDs()
    local EnemyinhandCards2, EnemycardsCount2 = EnemyHandCards2:getHandCardIDs()

    local FriendHandCards = self:getSKHandCards(self._gameController:rul_GetDrawIndexByChairNO((currentChairNo+2)%4))
    local FriendinhandCards, FriendcardsCount = FriendHandCards:getHandCardIDs()

    local waitChair = self._gameController._baseGameUtilsInfoManager:getWaitChair()
    local waitDrawIndex = self._gameController:rul_GetDrawIndexByChairNO(waitChair)


    local inhandCards, cardsCount = myHandCards:getHandCardIDs()
    local allUnite, uniteCount = NetlessCalculator:PreAnalyseCards(inhandCards, cardsCount)

    local rank = self._gameController._baseGameUtilsInfoManager:getCurrentRank()
    
    --[[local dwCheckTypeS = {SKGameDef.SK_CARD_UNITE_TYPE_SINGLE,SKGameDef.SK_CARD_UNITE_TYPE_COUPLE,SKGameDef.SK_CARD_UNITE_TYPE_THREE,
                        SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE,SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE,SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE,
                        SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE,SKGameDef.SK_CARD_UNITE_TYPE_BOMB,SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN, SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB }]]
    local dwCheckTypeS = {SKGameDef.SK_CARD_UNITE_TYPE_BOMB,SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN, SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB }

    
    --比较是否有大的牌型
    --[[if self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, waitCardUnite, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true) then
        return remindCards
    end]]
    --自己出牌
    if not waitChair or waitChair == -1 then
        inhandCards, cardsCount = myHandCards:getHandCardIDs()
        
        self:selectCardsByIDs(drawIndex, inhandCards, cardsCount)

        if self._gameController:ope_CheckSelectRoot(drawIndex) then
            return
        end
        self:ope_UnselectSelfCardsRoot(drawIndex)

        --判断下几手牌
        local EnemyAllUnite1, EnemyUniteCount1 = nil, 0
        local EnemyAllUnite2, EnemyUniteCount2 = nil, 0
        if EnemycardsCount1 > 0 then
            EnemyAllUnite1, EnemyUniteCount1 = NetlessCalculator:PreAnalyseCards(EnemyinhandCards1, EnemycardsCount1)
            EnemyinhandCards1, EnemycardsCount1 = EnemyHandCards1:getHandCardIDs()
        end
        if EnemycardsCount2 > 0 then
            EnemyAllUnite2, EnemyUniteCount2 = NetlessCalculator:PreAnalyseCards(EnemyinhandCards2, EnemycardsCount2)
            EnemyinhandCards2, EnemycardsCount2 = EnemyHandCards2:getHandCardIDs()
        end
        if uniteCount == 2 then
            local remindCards   = {}
            SKCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
            local outType = {}
            for j = uniteCount, 1, -1 do 
                if self:ope_BuildCard(EnemyinhandCards1, EnemycardsCount1, remindCards, EnemycardsCount1, allUnite[j], outType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true)
                        or self:ope_BuildCard(EnemyinhandCards2, EnemycardsCount2, remindCards, EnemycardsCount2, allUnite[j], outType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true) then
                   
                else
                    self:selectCardsByIDs(drawIndex, allUnite[j].nCardIDs, allUnite[j].nCardsCount)
                    return
                end
            end
        end

        
        if (EnemyUniteCount1 <= 2 or EnemyUniteCount2 <= 2) then   --敌方剩一手牌的时候   
            local tempUniteNoBome = {}
            for j = 1, uniteCount do
                if allUnite[j].dwCardType < SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
                    table.insert(tempUniteNoBome, table.maxn(tempUniteNoBome) + 1, allUnite[j])
                end
            end
            local function comps(a, b)
                local aMainValue = a.nMainValue
                if a.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
                    aMainValue = a.nMainValue - 100
                elseif a.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
                    aMainValue = a.nMainValue - 3000
                elseif a.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
                    aMainValue = a.nMainValue - 2000
                end
                local bMainValue = b.nMainValue
                if b.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
                    bMainValue = b.nMainValue - 100
                elseif b.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
                    bMainValue = b.nMainValue - 3000
                elseif b.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
                    bMainValue = b.nMainValue - 2000
                end
                return aMainValue < bMainValue
            end
            table.sort(tempUniteNoBome, comps)
            --敌方3带2牌型
            local enemyThreeIndex1 = 0
            local enemyThreeIndex2 = 0
            if EnemyUniteCount1 == 2 and EnemyAllUnite1[1].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE and EnemyAllUnite1[2].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                enemyThreeIndex1 = 2
            elseif EnemyUniteCount1 == 2 and  EnemyAllUnite1[2].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE and EnemyAllUnite1[1].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                enemyThreeIndex1 = 1
            end
            if EnemyUniteCount2 == 2 and EnemyAllUnite2[1].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE and EnemyAllUnite2[2].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                enemyThreeIndex2 = 2
            elseif EnemyUniteCount2 == 2 and EnemyAllUnite2[2].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE and EnemyAllUnite2[1].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                enemyThreeIndex2 = 1
            end
            if enemyThreeIndex1 > 0 and enemyThreeIndex2 > 0 then
                for j = 1, table.maxn(tempUniteNoBome) do
                    local bigEnemy = 0
                    if tempUniteNoBome[j].dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
                        bigEnemy = bigEnemy + 1
                    else
                        if tempUniteNoBome[j].nMainValue >= EnemyAllUnite1[enemyThreeIndex1].nMainValue * 10000 then
                            bigEnemy = bigEnemy + 1
                        end
                    end
                    if tempUniteNoBome[j].dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
                        bigEnemy = bigEnemy + 1
                    else
                        if tempUniteNoBome[j].nMainValue >= EnemyAllUnite2[enemyThreeIndex2].nMainValue * 10000 then
                            bigEnemy = bigEnemy + 1
                        end
                    end
                    if bigEnemy >= 2 then
                        self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                        return
                    end
                end
            end
            if enemyThreeIndex1 > 0 then
                for j = 1, table.maxn(tempUniteNoBome) do
                    if tempUniteNoBome[j].dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
                        self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                        return
                    else
                        if tempUniteNoBome[j].nMainValue >= EnemyAllUnite1[enemyThreeIndex1].nMainValue * 10000 then
                            self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                            return
                        end
                    end
                end
            end
            if enemyThreeIndex2 > 0 then
                for j = 1, table.maxn(tempUniteNoBome) do
                    if tempUniteNoBome[j].dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
                        self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                        return
                    else
                        if tempUniteNoBome[j].nMainValue >= EnemyAllUnite2[enemyThreeIndex2].nMainValue * 10000 then
                            self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                            return
                        end
                    end
                end
            end

            --敌方其他牌型
            local selectFirstType = {}
            if ( (EnemyUniteCount1 == 1 and EnemyAllUnite1[1].dwCardType < SKGameDef.SK_CARD_UNITE_TYPE_BOMB) and (EnemyUniteCount2 == 1 and (EnemyAllUnite2[1].dwCardType < SKGameDef.SK_CARD_UNITE_TYPE_BOMB)) )  then
                for j = 1, table.maxn(tempUniteNoBome) do
                    local bigEnemy = 0
                    if tempUniteNoBome[j].dwCardType ~= EnemyAllUnite1[1].dwCardType then
                        bigEnemy = bigEnemy + 1
                    else
                        if tempUniteNoBome[j].nMainValue >= EnemyAllUnite1[1].nMainValue then
                            bigEnemy = bigEnemy + 1
                        end
                    end
                    if tempUniteNoBome[j].dwCardType ~= EnemyAllUnite2[1].dwCardType then
                        bigEnemy = bigEnemy + 1
                    else
                        if tempUniteNoBome[j].nMainValue >= EnemyAllUnite2[1].nMainValue then
                            bigEnemy = bigEnemy + 1
                        end
                    end
                    if bigEnemy >= 2 then
                        NetlessCalculator:copyTable(selectFirstType, tempUniteNoBome[j])
                        break
                        --self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                        --return
                    end
                end
            end
            if (EnemyUniteCount1 == 1 and EnemyAllUnite1[1].dwCardType < SKGameDef.SK_CARD_UNITE_TYPE_BOMB) then
                for j = 1, table.maxn(tempUniteNoBome) do
                    if tempUniteNoBome[j].dwCardType ~= EnemyAllUnite1[1].dwCardType then
                        NetlessCalculator:copyTable(selectFirstType, tempUniteNoBome[j])
                        break
                        --self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                        --return
                    else
                        if tempUniteNoBome[j].nMainValue >= EnemyAllUnite1[1].nMainValue then
                            NetlessCalculator:copyTable(selectFirstType, tempUniteNoBome[j])
                            break
                            --self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                            --return
                        end
                    end
                end
            elseif (EnemyUniteCount2 == 1 and EnemyAllUnite2[1].dwCardType < SKGameDef.SK_CARD_UNITE_TYPE_BOMB) then
                for j = 1, table.maxn(tempUniteNoBome) do
                    if tempUniteNoBome[j].dwCardType ~= EnemyAllUnite2[1].dwCardType then
                        NetlessCalculator:copyTable(selectFirstType, tempUniteNoBome[j])
                        break
                        --self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                        --return
                    else
                        if tempUniteNoBome[j].nMainValue >= EnemyAllUnite2[1].nMainValue then
                            NetlessCalculator:copyTable(selectFirstType, tempUniteNoBome[j])
                            break
                            --self:selectCardsByIDs(drawIndex, tempUniteNoBome[j].nCardIDs, tempUniteNoBome[j].nCardsCount)
                            --return
                        end
                    end
                end
            end

            
            if selectFirstType.dwCardType and selectFirstType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                for k = 1, table.maxn(tempUniteNoBome) do
                    if tempUniteNoBome[k].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then 
                        local cardIndex = NetlessCalculator:getCardIndex(tempUniteNoBome[k].nCardIDs[1], 0)
                        if cardIndex ~= rank and cardIndex < 13 then
                            self:selectCardsByIDs(drawIndex, selectFirstType.nCardIDs, selectFirstType.nCardsCount)
                            self:selectCardsByIDs(drawIndex, tempUniteNoBome[k].nCardIDs, tempUniteNoBome[k].nCardsCount)
                            return
                        end
                    end
                end
            end
            if selectFirstType.dwCardType then
                self:selectCardsByIDs(drawIndex, selectFirstType.nCardIDs, selectFirstType.nCardsCount)
                return
            end
        end

        local threeType = {}
        local doubleType = {}

        local IndexPri = 999999
        local selectType = {}
        --先找顺子
        for j = 1, uniteCount do 
            if allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
                if allUnite[j].nMainValue - 100 <= IndexPri then
                    IndexPri = allUnite[j].nMainValue - 100
                    NetlessCalculator:copyTable(selectType, allUnite[j])
                end
            end
            if allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
                if allUnite[j].nMainValue - 3000 <= IndexPri then
                    if allUnite[j].nMainValue - 3000 == IndexPri then
                        if not selectType.dwCardType or (selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE)  then    
                            IndexPri = allUnite[j].nMainValue - 3000
                            NetlessCalculator:copyTable(selectType, allUnite[j])
                        end
                    else
                        IndexPri = allUnite[j].nMainValue - 3000
                        NetlessCalculator:copyTable(selectType, allUnite[j])
                    end
                end
            end
            if allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
                if allUnite[j].nMainValue - 2000 <= IndexPri then
                    if allUnite[j].nMainValue - 2000 == IndexPri then
                        if not selectType.dwCardType or (selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE and selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE) then    
                            IndexPri = allUnite[j].nMainValue - 2000
                            NetlessCalculator:copyTable(selectType, allUnite[j])
                        end
                    else
                        IndexPri = allUnite[j].nMainValue - 2000
                        NetlessCalculator:copyTable(selectType, allUnite[j])
                    end
                end
            end
            if allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SINGLE then
                if allUnite[j].nMainValue <= IndexPri then
                    if allUnite[j].nMainValue == IndexPri then
                        if not selectType.dwCardType or (selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE and selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE and selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE) then    
                            IndexPri = allUnite[j].nMainValue
                            NetlessCalculator:copyTable(selectType, allUnite[j])
                        end
                    else
                        IndexPri = allUnite[j].nMainValue
                        NetlessCalculator:copyTable(selectType, allUnite[j])
                    end
                end
            end

            --顺便先把3张和2张理出来
            if allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                table.insert(threeType, table.maxn(threeType) + 1, allUnite[j])
                if allUnite[j].nMainValue <= IndexPri then
                    if allUnite[j].nMainValue == IndexPri then
                        if not selectType.dwCardType or (selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE and selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE and selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE) then    
                            IndexPri = allUnite[j].nMainValue
                            NetlessCalculator:copyTable(selectType, allUnite[j])
                        end
                    else
                        IndexPri = allUnite[j].nMainValue
                        NetlessCalculator:copyTable(selectType, allUnite[j])
                    end
                end
            elseif allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
                table.insert(doubleType, table.maxn(doubleType) + 1, allUnite[j])
                if allUnite[j].nMainValue <= IndexPri then
                    if allUnite[j].nMainValue == IndexPri then
                        if not selectType.dwCardType or (selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE and selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE and selectType.dwCardType ~= SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE) then    
                            IndexPri = allUnite[j].nMainValue
                            NetlessCalculator:copyTable(selectType, allUnite[j])
                        end
                    else
                        IndexPri = allUnite[j].nMainValue
                        NetlessCalculator:copyTable(selectType, allUnite[j])
                    end
                end
            end
        end

        if selectType.dwCardType and selectType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
            for j = 1, table.maxn(doubleType) do
                local cardIndex = NetlessCalculator:getCardIndex(doubleType[j].nCardIDs[1], 0)
                if cardIndex ~= rank and cardIndex < 13 then
                    self:selectCardsByIDs(drawIndex, selectType.nCardIDs, selectType.nCardsCount)
                    self:selectCardsByIDs(drawIndex, doubleType[j].nCardIDs, doubleType[j].nCardsCount)
                    return
                end
            end
        end

        if selectType.dwCardType then
           self:selectCardsByIDs(drawIndex, selectType.nCardIDs, selectType.nCardsCount)
           return
        end

        for i= 1, table.maxn(dwCheckTypeS) do
            local isFind = false
            for j = uniteCount, 1, -1 do
                if allUnite[j].dwCardType == dwCheckTypeS[i] then
                    self:selectCardsByIDs(drawIndex, allUnite[j].nCardIDs, allUnite[j].nCardsCount)
                    isFind = true
                    break
                end
            end
            if isFind then
                break
            end
        end

        return
    end

    --压别人牌
    --看手牌能否全出
    inhandCards, cardsCount = myHandCards:getHandCardIDs()
    self:selectCardsByIDs(drawIndex, inhandCards, cardsCount)
    if self._gameController:ope_CheckSelectRoot(drawIndex) then
        return
    end
    self:ope_UnselectSelfCardsRoot(drawIndex)


    local waitCardUnite = {}
    SKCalculator:copyTable(waitCardUnite, self._gameController._baseGameUtilsInfoManager:getWaitUniteInfo())
    --队友
    if waitChair == (currentChairNo + 2)%4 then
        if FriendcardsCount < 10 then  --队友牌数小于多少不压
            return
        end
        if waitCardUnite.dwCardType < SKGameDef.SK_CARD_UNITE_TYPE_BOMB then    
            local threeType = {}
            local doubleType = {}
            for j = 1, uniteCount do
                if allUnite[j].dwCardType == waitCardUnite.dwCardType then
                    --顺子 三顺 二顺 只管压
                    if waitCardUnite.dwCardType >= SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE and waitCardUnite.dwCardType <= SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
                        if waitCardUnite.nMainValue < allUnite[j].nMainValue then
                            self:selectCardsByIDs(drawIndex, allUnite[j].nCardIDs, allUnite[j].nCardsCount)
                            return
                        end
                    end
                    --单张 小于K
                    if waitCardUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SINGLE then
                        if waitCardUnite.nMainValue < allUnite[j].nMainValue and allUnite[j].nMainValue < 12 then
                            self:selectCardsByIDs(drawIndex, allUnite[j].nCardIDs, allUnite[j].nCardsCount)
                            return
                        end
                    end
                    --对子 小于Q
                    if waitCardUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
                        if waitCardUnite.nMainValue < allUnite[j].nMainValue and allUnite[j].nMainValue < 11 then
                            self:selectCardsByIDs(drawIndex, allUnite[j].nCardIDs, allUnite[j].nCardsCount)
                            return
                        end
                    end
                    --三张 小于Q
                    if waitCardUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                        if waitCardUnite.nMainValue < allUnite[j].nMainValue and allUnite[j].nMainValue < 11 then
                            self:selectCardsByIDs(drawIndex, allUnite[j].nCardIDs, allUnite[j].nCardsCount)
                            return
                        end
                    end
                end

                --把三张和对子拿一下
                if allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                    table.insert(threeType, table.maxn(threeType) + 1, allUnite[j])
                elseif allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
                    table.insert(doubleType, table.maxn(doubleType) + 1, allUnite[j])
                end
            end
            --三带二判断下 小于11
            if waitCardUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE and table.maxn(threeType) > 0 and table.maxn(doubleType) > 0 then
                for m = 1, table.maxn(threeType) do
                    if waitCardUnite.nMainValue < threeType[m].nMainValue * 10000 and threeType[m].nMainValue < 11 then
                        for n = 1, table.maxn(doubleType) do
                            if doubleType[n].nMainValue < 11  then
                                self:selectCardsByIDs(drawIndex, threeType[m].nCardIDs, threeType[m].nCardsCount)
                                self:selectCardsByIDs(drawIndex, doubleType[n].nCardIDs, doubleType[n].nCardsCount)
                                return
                            end
                        end
                    end
                end
            end
        end
        return
    else --敌人
        local BomeType = {}
        local threeType = {}
        local doubleType = {}
        for j = 1, uniteCount do
            --把三张和对子炸弹拿一下
            if allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
                table.insert(threeType, table.maxn(threeType) + 1, allUnite[j])
            elseif allUnite[j].dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
                table.insert(doubleType, table.maxn(doubleType) + 1, allUnite[j])
            end
            if allUnite[j].dwCardType >= SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
                table.insert(BomeType, table.maxn(BomeType) + 1, allUnite[j])
            end
        end

        if waitCardUnite.dwCardType < SKGameDef.SK_CARD_UNITE_TYPE_BOMB then    
            for j = 1, uniteCount do
                if allUnite[j].dwCardType == waitCardUnite.dwCardType then
                    --顺子 三顺 二顺 只管压
                    if waitCardUnite.dwCardType >= SKGameDef.SK_CARD_UNITE_TYPE_SINGLE and waitCardUnite.dwCardType <= SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
                        if waitCardUnite.nMainValue < allUnite[j].nMainValue then
                            self:selectCardsByIDs(drawIndex, allUnite[j].nCardIDs, allUnite[j].nCardsCount)
                            return
                        end
                    end
                end
            end
            --三带二判断下 小于11
            if waitCardUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE and table.maxn(threeType) > 0 and table.maxn(doubleType) > 0 then
                for m = 1, table.maxn(threeType) do
                    if waitCardUnite.nMainValue < threeType[m].nMainValue * 10000 then
                        for n = 1, table.maxn(doubleType) do
                            if doubleType[n].nMainValue < 11  then
                                self:selectCardsByIDs(drawIndex, threeType[m].nCardIDs, threeType[m].nCardsCount)
                                self:selectCardsByIDs(drawIndex, doubleType[n].nCardIDs, doubleType[n].nCardsCount)
                                return
                            end
                        end
                    end
                end
            end

            --单张
            if waitCardUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SINGLE then
                for m = 1, table.maxn(doubleType) do
                    -- 大于A的可以拆
                    if doubleType[m].nMainValue > 13 then
                        self:selectCardsByIDs(drawIndex, {doubleType[m].nCardIDs[1]}, 1)
                        return
                    end
                end
                for m = 1, table.maxn(threeType) do
                    -- 大于A的可以拆
                    if threeType[m].nMainValue > 13 then
                        self:selectCardsByIDs(drawIndex, {threeType[m].nCardIDs[1]}, 1)
                        return
                    end
                end
            end
            --对子
            if waitCardUnite.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
                for m = 1, table.maxn(threeType) do
                    -- 大于A的可以拆
                    if threeType[m].nMainValue > 13 then
                        self:selectCardsByIDs(drawIndex, {threeType[m].nCardIDs[1], threeType[m].nCardIDs[2]}, 2)
                        return
                    end
                end
            end
        end
        local enemyCout = EnemycardsCount2
        if waitChair == (currentChairNo+1)%4 then
            enemyCout = EnemycardsCount1
        end
        local isBomeEnemy = false
        if self._gameController._roundCount == 2 and table.maxn(BomeType) >= 3 then
            isBomeEnemy = true
        end
        if table.maxn(BomeType) >= 4 then
            isBomeEnemy = true
        end
        if enemyCout <= 15 and table.maxn(BomeType) >= 3 then
            isBomeEnemy = true
        elseif enemyCout <= 10 and table.maxn(BomeType) >= 2 then
            isBomeEnemy = true
        elseif enemyCout <= 6 and table.maxn(BomeType) >= 1 then
            isBomeEnemy = true
        end
        if isBomeEnemy then
            for j = table.maxn(BomeType), 1, -1 do
                if self:IS_BIT_SET(BomeType[j].dwComPareType, waitCardUnite.dwCardType) then
                    local isBig = false
                    if waitCardUnite.dwCardType == BomeType[j].dwCardType then
                        if waitCardUnite.nMainValue < BomeType[j].nMainValue then
                            isBig = true
                        end
                    else
                        isBig = true
                    end
                    if isBig then
                        self:selectCardsByIDs(drawIndex, BomeType[j].nCardIDs, BomeType[j].nCardsCount)
                        return
                    end
                end
            end
        end
        if enemyCout <= 6 then
            local remindCards = self:onRemindRoot(drawIndex, waitCardUnite)
            if remindCards then
                self:selectCardsByIDs(drawIndex, remindCards, SKGameDef.SK_CHAIR_CARDS)
                return
            end
        end
    end
end

function NetlessHandCardsManager:BuildThrowCard(nChairNo, nCardIDs)
    local details = NetlessCalculator:initCardUnite()
end

function NetlessHandCardsManager:ope_UnselectSelfCardsRoot(drawIndex)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:resetCardsPos()
        self._SKHandCards[drawIndex]:resetCardsState()
    end
end

function NetlessHandCardsManager:selectMinUniteRoot(drawIndex)
    local myHandCards = self:getSKHandCards(drawIndex)
    if not myHandCards then return end

    local inhandLay     = {}
    SKCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()
    SKCalculator:skLayCards(inhandCards, cardsCount, inhandLay, gameFlags)

    local index = SKCalculator:getCardIndex(inhandCards[cardsCount], gameFlags)
    if inhandLay[index] <= 3 then
        myHandCards:selectCardsByIndex(index)
    else
        local pri = 10000
        for i = 1, 3 do
            for j = 1, SKGameDef.SK_LAYOUT_NUM do
                local rank = self._gameController._baseGameUtilsInfoManager:getCurrentRank()
                if inhandLay[j] == i and SKCalculator:getCardIndexPri(j, rank, gameFlags) < pri then
                    index   = j
                    pri     = SKCalculator:getCardIndexPri(j, rank, gameFlags)
                end
            end
        end

        myHandCards:selectCardsByIndex(index)
    end
end

function NetlessHandCardsManager:onRemindRoot(drawIndex, waitCardUnite)
    local myHandCards = self:getSKHandCards(drawIndex)
    if not myHandCards then return nil end

    local bestRemindCards = self:onBestRemindRoot(drawIndex, waitCardUnite)
    if bestRemindCards then
        return bestRemindCards
    end
    
    --最后检查一下全部手牌
    local remindCards   = {}
    SKCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()

    if self._remindUniteType.dwCardType and self._remindUniteType.dwCardType ~= 0 then
        if self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, self._remindUniteType, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, true) then
            return remindCards
        else
            self._bestRemindUniteType = SKCalculator:initUniteType()
            bestRemindCards = self:onBestRemindRoot(drawIndex, waitCardUnite)
            if bestRemindCards then
                self._remindUniteType = SKCalculator:initUniteType()
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

function NetlessHandCardsManager:onBestRemindRoot(drawIndex, waitCardUnite)
    local myHandCards = self:getSKHandCards(drawIndex)
    if not myHandCards then return nil end

    local remindCards   = {}
    local inhandLay     = {}
    SKCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    SKCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)

    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()
    SKCalculator:skLayCards(inhandCards, cardsCount, inhandLay, 0)

    local perfectUnite  = SKCalculator:initUniteType()
    if self._bestRemindUniteType.dwCardType and self._bestRemindUniteType.dwCardType ~= 0 then
        SKCalculator:copyTable(perfectUnite, self._bestRemindUniteType)
    else
        SKCalculator:copyTable(perfectUnite, waitCardUnite)
    end

    local remindLay     = {}
    while self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, perfectUnite, perfectUnite, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL, false) do
        SKCalculator:xygZeroLays(remindLay, SKGameDef.SK_LAYOUT_NUM)
        SKCalculator:skLayCards(remindCards, cardsCount, remindLay, 0)

        local bMatch = true
        for i = 1, SKGameDef.SK_LAYOUT_NUM do
            if remindLay[i] ~= 0 and remindLay[i] ~= inhandLay[i] then
                bMatch = false
                break
            end
        end

        if bMatch then
            SKCalculator:copyTable(self._bestRemindUniteType, perfectUnite)
            return remindCards
        else
            SKCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
        end
    end

    return nil
end

function NetlessHandCardsManager:selectCardsByIDs(drawIndex, cardIDs, cardsCount)
    local myHandCards = self:getSKHandCards(drawIndex)
    if myHandCards then
        myHandCards:selectCardsByIDs(cardIDs, cardsCount)
    end
end

function NetlessHandCardsManager:ope_SortCards() --开局第一次排序 回调正式开始游戏
    for i = 1, 4 do
        if self._SKHandCards[i] then
            self._SKHandCards[i]:sortHandCards()
        end
    end
    self._gameController:ope_StartPlay()
    -- 单机房发牌结束后，不显示横竖切换
    self._gameController._baseGameScene:setSortTypeBtnEnabled(false)
end

return NetlessHandCardsManager
