
if nil == cc or nil == cc.exports then
    return
end

local SKCalculator                              = import("src.app.Game.mSKGame.SKCalculator")

cc.exports.MyCalculator                         = {}
local MyCalculator                              = cc.exports.MyCalculator

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")
local MyGameDef                                 = import("src.app.Game.mMyGame.MyGameDef")

--local SKGameUtilsInfoManager                    = import("src.app.Game.mSKGame.SKGameUtilsInfoManager")
--local MyGameUtilsInfoManager                    = import("src.app.Game.mMyGame.MyGameUtilsInfoManager")

local GamePublicInterface                       = import("src.app.Game.mMyGame.GamePublicInterface")


MyCalculator.super = SKCalculator
setmetatable(MyCalculator, {__index = MyCalculator.super})

local MyGameUtilsInfoManager = {}

function MyCalculator:CreateGameUtilsInfoManager()
    MyGameUtilsInfoManager = GamePublicInterface._gameController._baseGameUtilsInfoManager
end

--扩大了牌级
function MyCalculator:getCardIndexPri(cardIndex, rank, gameFlags)
    if self:isFrame_1() then
        return cardIndex
    end

    if 14 == cardIndex then
        return 41
    elseif 15 == cardIndex then
        return 42
    elseif rank == cardIndex then
        return 40
    else
        return cardIndex
    end
end

function MyCalculator:isCardValid(cardId)
    if cardId and 0 <= cardId and MyGameDef.MY_TOTAL_CARDS > cardId then
        return true
    else
        return false
    end
end

--牌的索引  1 - 13  对应 2 - A  14是小王 15 是大王
function MyCalculator:getCardIndex(cardId)
    if not self:isCardValid(cardId) then return -1 end

    if self:isFrame_1() then
        return self:getCardIndex_1(cardID)
    else
        cardId = cardId % 54
        if 52 == cardId then
            return 14           --小王
        elseif 53 == cardId then
            return 15           --大王
        else
            return cardId % SKGameDef.SK_LAYOUT_MOD + 1
        end
    end
end

function MyCalculator:getCardPriEx(cardID, rank, gameFlags)
    local cardIndex = self:getCardIndex(cardID, gameFlags)
    return self:getCardIndexPri(cardIndex, rank, gameFlags)
end

-- 解决牌值大小排序，红黑梅方 花色顺序问题
function MyCalculator:getSortValue(nCardID, rank)
    local pri = self:getCardPriEx(nCardID, rank)
    local shape = self:getCardShape(nCardID,0) 
    local sortValue = pri * 10 + shape
    return sortValue
end

function MyCalculator:getSameCount(cardsLay, layLen, sameCount, jokerCount)
    local bigestIndex, rank = -1, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()
    for i = 1, layLen do
        if 0 < cardsLay[i] and cardsLay[i] + jokerCount >= sameCount then
            if -1 == bigestIndex or self:getCardIndexPri(i, rank, 0) > self:getCardIndexPri(bigestIndex, rank, 0) then
                bigestIndex = i
            end
        end
    end

    return bigestIndex
end

function MyCalculator:getSameCountEx(cardsLay, layLen, sameCount, jokerCount, destValue)
    local bigestIndex, smallValue, rank = -1, 0, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()
    for i = 1, layLen do
        if 0 < cardsLay[i] then
            local priPlus = 0
            if 4 < sameCount then
                priPlus = (sameCount - 4) * 10000
            end
            if i >= 14 and cardsLay[i] >= sameCount and (self:getCardIndexPri(i, rank, 0) + priPlus) > destValue then
                if -1 == bigestIndex or (self:getCardIndexPri(i, rank, 0) + priPlus) < smallValue then
                    bigestIndex = i
                    smallValue  = self:getCardIndexPri(i, rank, 0) + priPlus
                end
            end
            if i < 14 and cardsLay[i] + jokerCount >= sameCount and (self:getCardIndexPri(i, rank, 0) + priPlus) > destValue then
                if -1 == bigestIndex or (self:getCardIndexPri(i, rank, 0) + priPlus) < smallValue then
                    bigestIndex = i
                    smallValue  = self:getCardIndexPri(i, rank, 0) + priPlus
                end
            end
            --[[if cardsLay[i] + jokerCount >= sameCount and (self:getCardIndexPri(i, rank, 0) + priPlus) > destValue then
                if -1 == bigestIndex or (self:getCardIndexPri(i, rank, 0) + priPlus) < smallValue then
                    bigestIndex = i
                    smallValue  = self:getCardIndexPri(i, rank, 0) + priPlus
                end
            end]]
        end
    end

    return bigestIndex
end

function MyCalculator:isJoker(cardID)
    if self:getCardIndex(cardID, 0) == GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank() 
            and self:getCardShape(cardID,0) == SKGameDef.SK_CS_HEART then
        return true
    end
    return false
end

function MyCalculator:preDealCards(cardIDs, cardsLen, cardsLay, layLen, gameFlags)
    local cardsCount, jokerCount = 0, 0
    local jokerCardID = {}
    for i = 1, cardsLen do
        if self:isValidCard(cardIDs[i]) then
            cardsCount = cardsCount + 1

            if self:isJoker(cardIDs[i]) and self:IS_BIT_SET(gameFlags, SKGameDef.SK_GF_USE_JOKER) then
                jokerCount = jokerCount + 1
                jokerCardID[jokerCount] = cardIDs[i]
            else
                local cardIndex = self:getCardIndex(cardIDs[i])
                cardsLay[cardIndex] = cardsLay[cardIndex] + 1
            end
        end
    end

    if cardsCount == jokerCount then
        for i = 1, cardsLen do
            jokerCount = 0
            jokerCardID = {}
            if self:isValidCard(cardIDs[i]) then
                local cardIndex = self:getCardIndex(cardIDs[i])
                cardsLay[cardIndex] = cardsLay[cardIndex] + 1
            end
        end
    end

    return jokerCount, cardsCount, jokerCardID
end

function MyCalculator:getUniteDetails(cardIDs, cardsLen, unitDetail, dwFlags)
    local cardsCount = self:getCardsCount(cardIDs, cardsLen)

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_SINGLE) then
        self:calcCardType_Single(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_COUPLE) then
        self:calcCardType_Couple(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_THREE) then
        self:calcCardType_Three(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE) then
        self:calcCardType_Three_Couple(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE) then
        self:calcCardType_ABT_Single(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE) then
        self:calcCardType_ABT_Couple(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE) then
        self:calcCardType_ABT_Three(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_BOMB) then
        self:calcCardType_Bomb(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN) then
        self:calcCardType_TongHuaShun(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB) then
        self:calcCardType_SuperBomb(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_4KING) then
        self:calcCardType_4King(cardIDs, cardsLen, cardsCount, unitDetail)
    end

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_BUG) then
        self:calcCardType_Bug(cardIDs, cardsLen, cardsCount, unitDetail)
    end
    if 0 < unitDetail.nTypeCount then
        return true
    else
        return false
    end
end

function MyCalculator:getBestUnitType1(fightCards)
    if 1 >= fightCards.nTypeCount then
        return
    end

    local dwDestType, dwDestMain, dwDestCompareType = fightCards.uniteType[1].dwCardType, fightCards.uniteType[1].nMainValue, fightCards.uniteType[1].dwComPareType
    local cardIDs = {}
    self:xygInitChairCards(cardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)

    local bnFindBig = false
    for i = 1, fightCards.nTypeCount do
        if self:IS_BIT_SET(fightCards.uniteType[i].dwComPareType, dwDestType) then
            if fightCards.uniteType[i].dwCardType == dwDestType then
                if fightCards.uniteType[i].nMainValue > dwDestMain then
                    bnFindBig           = true
                    dwDestType          = fightCards.uniteType[i].dwCardType
                    dwDestMain          = fightCards.uniteType[i].nMainValue
                    dwDestCompareType   = fightCards.uniteType[i].dwComPareType
                    self:copyTable(cardIDs, fightCards.uniteType[i].nCardIDs)
                end
            else
                bnFindBig           = true
                dwDestType          = fightCards.uniteType[i].dwCardType
                dwDestMain          = fightCards.uniteType[i].nMainValue
                dwDestCompareType   = fightCards.uniteType[i].dwComPareType
                self:copyTable(cardIDs, fightCards.uniteType[i].nCardIDs)
            end          
        end
    end

    if bnFindBig then
        fightCards.uniteType[1].dwCardType      = dwDestType
        fightCards.uniteType[1].nMainValue      = dwDestMain
        fightCards.uniteType[1].dwComPareType   = dwDestCompareType
        self:copyTable(fightCards.uniteType[1].nCardIDs, cardIDs)
        fightCards.nTypeCount                   = 1
    end
end

function MyCalculator:getBestUnitType2(firstCards, fightCards)
    --local dwDestType, dwDestMain, dwDestCompareType = firstCards.uniteType[1].dwCardType, firstCards.uniteType[1].nMainValue, fightCards.uniteType[1].dwComPareType
    local dwDestType, dwDestMain, dwDestCompareType = firstCards.dwCardType, firstCards.nMainValue, fightCards.dwComPareType
    local cardIDs = {}
    self:xygInitChairCards(cardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)

    local bnFindBig = false
    for i = 1, fightCards.nTypeCount do
        if self:IS_BIT_SET(fightCards.uniteType[i].dwComPareType, dwDestType) then
            if fightCards.uniteType[i].dwCardType == dwDestType then
                if fightCards.uniteType[i].nMainValue > dwDestMain then
                    if (dwDestType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE 
                        or dwDestType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
                        or dwDestType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
                        or dwDestType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_1
                        or dwDestType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE)
                        and fightCards.uniteType[i].nCardsCount~=firstCards.nCardsCount then 
                    
                    else
                        bnFindBig           = true
                        dwDestType          = fightCards.uniteType[i].dwCardType
                        dwDestMain          = fightCards.uniteType[i].nMainValue
                        dwDestCompareType   = fightCards.uniteType[i].dwComPareType
                        self:copyTable(cardIDs, fightCards.uniteType[i].nCardIDs)
                    end
                end
            else
                bnFindBig           = true
                dwDestType          = fightCards.uniteType[i].dwCardType
                dwDestMain          = fightCards.uniteType[i].nMainValue
                dwDestCompareType   = fightCards.uniteType[i].dwComPareType
                self:copyTable(cardIDs, fightCards.uniteType[i].nCardIDs)
            end     
        end
    end

    if bnFindBig then
        fightCards.uniteType[1].dwCardType      = dwDestType
        fightCards.uniteType[1].nMainValue      = dwDestMain
        fightCards.uniteType[1].dwComPareType   = dwDestCompareType
        self:copyTable(fightCards.uniteType[1].nCardIDs, cardIDs)
        fightCards.nTypeCount                   = 1

        return true
    else
        return false
    end
end

function MyCalculator:calcFriendCard(cardIDs, cardsCount)
    if not self:xygHaveCard(cardIDs, cardsCount, MyGameDef.GAME_CARDID_HELPER) then
        return MyGameDef.GAME_CARDID_HELPER
    end

    local friendIndex = 0
    local cardsLay = {}
    local gameFlags = GamePublicInterface:getGameFlags()
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM_1)
    self:skLayCards_1(cardIDs, cardsCount, cardsLay, gameFlags)

    for i = SKGameDef.SK_LAYOUT_MOD_1 - 2, 0, -1 do
        for j = 1, SKGameDef.SK_CS_KING do
            if 0 == i then
                friendIndex = (j - 1) * (SKGameDef.SK_LAYOUT_MOD_1 - 1) + i
            else
                friendIndex = (j - 1) * SKGameDef.SK_LAYOUT_MOD_1 + i
            end

            if 0 ~= friendIndex and 2 == cardsLay[friendIndex] then
                break
            else
                friendIndex = 0
            end
        end

        if 0 ~= friendIndex then
            break
        end
    end

    if 0 == friendIndex then
        return SKGameDef.SK_INVALID_OBJECT_ID
    end

    for i = 0, SKGameDef.SK_TOTAL_CARDS do
        local shape         = self:getCardShape_1(i)
        local value         = self:getCardValue_1(i)
        local cardIndex     = shape * SKGameDef.SK_LAYOUT_MOD_1 + value
        if cardIndex == friendIndex then
            if not self:xygHaveCard(cardIDs, cardsCount, i) then
                return i
            end
        end
    end

    return SKGameDef.SK_INVALID_OBJECT_ID
end

-- nCardIDs1: 自己出的牌    nCardIDs2: 上家出的牌
function MyCalculator:compareCardsEx(nCardsLen, nCardIDs1, pCardsDetails1, nCardIDs2, pCardsDetails2)
    local dwType1 = pCardsDetails1.dwType
    local dwType2 = pCardsDetails2.dwType

    if dwType1 ~= SKGameDef.SK_CT_BOMB and dwType1 ~= SKGameDef.SK_CT_JOKER_BOMB then
        if dwType2 ~= SKGameDef.SK_CT_BOMB and dwType2 ~= SKGameDef.SK_CT_JOKER_BOMB then
            if dwType1 ~= dwType2 then  --类型不匹配
                return SKGameDef.SK_INVALID_RELATIONSHIP
            end
        end
    end

    local lay1 = {}
    self:xygZeroLays(lay1, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    local lay2 = {}
    self:xygZeroLays(lay2, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    local gameFlags = GamePublicInterface:getGameFlags()
    self:skLayCards_1(nCardIDs1, nCardsLen, lay1, gameFlags)
    self:skLayCards_1(nCardIDs2, nCardsLen, lay2, gameFlags)

    local layex1 = {}
    self:xygZeroLays(layex1, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    local layex2 = {}
    self:xygZeroLays(layex2, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(lay1, layex1)
    self:convertCardsLayToEx(lay2, layex2)

    local sum1      = self:xygCardRemains(layex1)
    local sum2      = self:xygCardRemains(layex2)
    local start1    = pCardsDetails1.nStart
    local start2    = pCardsDetails2.nStart

    if SKGameDef.SK_CT_JOKER_BOMB == dwType1 then
        if SKGameDef.SK_CT_JOKER_BOMB == dwType2 then
            if sum1 > sum2 then
                return 1
            elseif sum1 < sum2 then
                return -1
            else
                return self:compareStartCard(start1, start2)
            end
        elseif SKGameDef.SK_CT_BOMB == dwType2 then
            if sum1 == 6 then
                return 1
            elseif sum1 == 5 then
                if sum2 > 8 then
                    return -1
                else
                    return 1
                end
            elseif sum1 == 4 then
                if sum2 > 7 then
                    return -1
                else
                    return 1
                end
            elseif sum1 == 3 and start1 == 18 then
                if sum2 > 6 then
                    return -1
                else
                    return 1
                end
            elseif sum1 == 3 and start1 == 17 then
                if sum2 > 5 then
                    return -1
                else
                    return 1
                end
            end
        else
            return 1
        end
    elseif SKGameDef.SK_CT_BOMB == dwType1 then
        if SKGameDef.SK_CT_JOKER_BOMB == dwType2 then
            if sum2 == 6 then
                return -1
            elseif sum2 == 5 then
                if sum1 > 8 then
                    return 1
                else
                    return -1
                end
            elseif sum2 == 4 then
                if sum1 > 7 then
                    return 1
                else
                    return -1
                end
            elseif sum2 == 3 and start2 == 18 then
                if sum1 > 6 then
                    return 1
                else
                    return -1
                end
            elseif sum2 == 3 and start2 == 17 then
                if sum1 > 5 then
                    return 1
                else
                    return -1
                end
            end
        elseif SKGameDef.SK_CT_BOMB == dwType2 then
            if sum1 > sum2 then
                return 1
            elseif sum1 < sum2 then
                return -1
            else
                return self:compareStartCard(start1, start2)
            end
        else
            return 1
        end
    else
        if SKGameDef.SK_CT_BOMB == dwType2 then
            return -1
        elseif SKGameDef.SK_CT_JOKER_BOMB == dwType2 then
            return -1
        elseif dwType1 ~= dwType2 or sum1 ~= sum2 then
            return SKGameDef.SK_INVALID_RELATIONSHIP
        else
            return self:compareStartCard(start1, start2)
        end
    end

    return SKGameDef.SK_INVALID_RELATIONSHIP
end

function MyCalculator:isValidCardsEx(nCardLen, nCardIDs, cardsDetails)
    self:zeroTable(cardsDetails)
    local lay = {}
    self:xygZeroLays(lay, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    local gameFlag = GamePublicInterface:getGameFlags()

    self:skLayCards_1(nCardIDs, nCardLen, lay, gameFlag)

    local not_allowed_indexes = {}
    self:xygZeroLays(not_allowed_indexes, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    local dwType = self:isJokerBomb(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isBomb(lay, cardsDetails, 4)
    if dwType ~= 0  then
        return dwType
    end

    dwType = self:isSingle(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isCouple(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isThree(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isAbtCouple(lay, cardsDetails, 3)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isAbtThree(lay, cardsDetails, 2)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isThree2(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isButterFly(lay, cardsDetails, 2)
    if dwType ~= 0 then
        return dwType
    end

    return 0
end

function MyCalculator:isJokerBombEx(nCardsLayEx)
    local sum = self:xygCardRemains(nCardsLayEx)
    if 3 > sum then
        return 0
    end

    if 3 == sum then
        if sum == nCardsLayEx[SKGameDef.SK_LAYOUT_NUM_EX_1 - 2] or sum == nCardsLayEx[SKGameDef.SK_LAYOUT_NUM_EX_1 - 1] then
            return SKGameDef.SK_CT_JOKER_BOMB
        end
    else
        if sum == nCardsLayEx[SKGameDef.SK_LAYOUT_NUM_EX_1 - 2] + nCardsLayEx[SKGameDef.SK_LAYOUT_NUM_EX_1 - 1] then
            return SKGameDef.SK_CT_JOKER_BOMB
        end
    end

    return 0
end

--三带二
function MyCalculator:isButterFlyEx(nCardsLayEx, pair)
    local sum = self:xygCardRemains(nCardsLayEx)
    if pair*5 > sum or 0 ~= sum%5 then
        return 0
    end

    local layex2 = {}
    local layex3 = {}
    local layex4 = {}
    local layex5 = {}
    self:xygZeroLays(layex2, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:xygZeroLays(layex3, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:xygZeroLays(layex4, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:xygZeroLays(layex5, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        if 0 ~= nCardsLayEx[i] then
            if 2 == nCardsLayEx[i] then
                layex2[i] = nCardsLayEx[i]
            elseif 3 == nCardsLayEx[i] then
                layex3[i] = nCardsLayEx[i]
            elseif 4 == nCardsLayEx[i] then
                layex4[i] = nCardsLayEx[i]
            elseif 5 == nCardsLayEx[i] then
                layex5[i] = nCardsLayEx[i]
            else
                return 0
            end
        end
    end

    if self:xygCardRemains(layex5) then
        for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
            if layex5[i] > 0 then
                layex2[i] = 2
                layex3[i] = 3
            end
        end
    end

    if self:xygCardRemains(layex4) then
        for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
            if layex4[i] > 0 then
                layex2[i] = 4
            end
        end
    end

    if self:isAbtThreeEx(layex3, pair) ~= 0 then
        if self:isAbtCoupleEx(layex2, pair) ~= 0 then
            return SKGameDef.SK_CT_BUTTERFLY
        end

        if sum/5 > 2 and self:xygCardRemains(layex2) == sum/5 * 2 then
            return SKGameDef.SK_CT_BUTTERFLY
        end
    end

    return 0
end

-- 借用2.0的托管逻辑
function MyCalculator:getDoubleCount(cardsLay, layLen, count1, count2, jokerCount, destValue)
    local mainIndex, secondIndex, value, rank = -1, -1, 0, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()
    for i = 1, layLen do
        if 0 < cardsLay[i] then
            local restJokerCount = jokerCount
            if restJokerCount + cardsLay[i] >= count1 then
                local temp = cardsLay[i]
                if count1 > cardsLay[i] and i >=14 then

                else
                    if cardsLay[i] < count1 then
                        restJokerCount = restJokerCount - (count1 - cardsLay[i])         --去掉百搭
                        cardsLay[i]     = 0
                    else
                        cardsLay[i]     = cardsLay[i] - count1
                    end

                    for j = 1, layLen do
                        if i ~= j and 0 < cardsLay[j] then
                            if count2 > cardsLay[j] and j >=14 then

                            else
                                if restJokerCount + cardsLay[j] == count2 then
                                    local thisValue = self:getCardIndexPri(i, rank, 0) * 10000
                                    if thisValue > destValue then
                                        if -1 == mainIndex or thisValue < value then
                                            mainIndex   = i
                                            secondIndex = j
                                            value       = thisValue
                                        end
                                    end
                                end
                            end
                        end
                    end
                       
                    cardsLay[i] = temp           --还原
                end          
            end
        end
    end

    if -1 == mainIndex then
        return false
    else
        return true, mainIndex, secondIndex
    end
end

function MyCalculator:calcCardType_Single(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 1 ~= cardsCount then
        return false
    end
    if not self:isValidCard(cardIDs[1]) then
        return false
    end

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_Single(cardIDs, cardsLen, cardsDetail.uniteType[index]) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_Single(cardIDs, cardsLen, uniteType)
    if 0 >= cardsLen then
        return false
    end

    local minCardID, minValue, value, rank = -1, -1, uniteType.nMainValue, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    for i = 1, cardsLen do
		local cardIndex = self:getCardIndex(cardIDs[i], 0)
        if -1 ~= cardIDs[i] and self:getCardIndexPri(cardIndex, rank, 0) > value
            and (-1 == minCardID or self:getCardIndexPri(cardIndex, rank, 0) < minValue) then
            minValue    = self:getCardIndexPri(cardIndex, rank, 0)
            minCardID   = cardIDs[i]
        end
    end

    if -1 == minValue then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_SINGLE
    uniteType.nCardsCount    = 1
    uniteType.nMainValue    = minValue
    uniteType.nCardIDs[1]   = minCardID

    return true
end

function MyCalculator:calcCardType_Couple(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 2 ~= cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    local bnFind = false
    while self:getCardType_Couple(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index]) do
        bnFind = true
    end
    if not bnFind then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_Couple(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    local cardIndex = self:getSameCountEx(cardsLay, layLen, 2, jokerCount, uniteType.nMainValue)
    if -1 == cardIndex then
        return false
    end

    if (cardIndex == 14 or cardIndex == 15) and cardsLay[cardIndex]<=1 then
        return false
    end

    local rank = GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_COUPLE
    uniteType.nMainValue    = self:getCardIndexPri(cardIndex, rank, 0)
    uniteType.nCardsCount    = 2

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, cardIndex, 2, -1)

    return true
end

function SKCalculator:calcCardType_Three(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 3 ~= cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_Three(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index]) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_Three(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    local cardIndex = self:getSameCountEx(cardsLay, layLen, 3, jokerCount, uniteType.nMainValue)
    if -1 == cardIndex then
        return false
    end

    if (cardIndex == 14 or cardIndex == 15) and cardsLay[cardIndex]<=2 then
        return false
    end

    local rank = GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_THREE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_THREE
    uniteType.nMainValue    = self:getCardIndexPri(cardIndex, rank, 0)
    uniteType.nCardsCount    = 3

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, cardIndex, 3, -1)

    return true
end

function MyCalculator:calcCardType_Three_Couple(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 5 ~= cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    local bnFind = false
    while self:getCardType_Three_Couple(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index]) do
        bnFind = true
    end
    if not bnFind then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_Three_Couple(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end

    local bnFind, mainIndex, secondIndex = self:getDoubleCount(cardsLay, layLen, 3, 2, jokerCount, uniteType.nMainValue)
    if not bnFind then
        return false
    end

    local rank = GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
    uniteType.nMainValue    = self:getCardIndexPri(mainIndex, rank, 0) * 10000
    uniteType.nCardsCount    = 5

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, mainIndex, 3, -1)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, secondIndex, 2, -1)

    return true
end

function MyCalculator:getDoubleCountEx(cardsLay, layLen, count1, count2, jokerCount, destValue, WaitType)
    local lay = {}
    self:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
    local nJokerCountEx = 0
    nJokerCountEx = self:preDealCards(WaitType.nCardIDs, SKGameDef.SK_LAYOUT_NUM, lay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    for i = 1, SKGameDef.SK_LAYOUT_NUM do
        if lay[i] == 3 then
            break
        end
    end

    local nWaitMainIndex = WaitType.nMainValue/10000
    local mainIndex, secondIndex, value, rank = -1, -1, 0, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()
    for i = 1, layLen do
        if 0 < cardsLay[i] then
            local restJokerCount = jokerCount
            if restJokerCount + cardsLay[i] >= count1 then
                if (count1>cardsLay[i])and(i>=14) then
                    -- do nothing
                else
                    local temp = cardsLay[i]
                    if cardsLay[i] < count1 then
                        restJokerCount = restJokerCount - (count1 - cardsLay[i])         --去掉百搭
                        cardsLay[i]     = 0
                    else
                        cardsLay[i]     = cardsLay[i] - count1
                    end

                    for j = 1, layLen do
                        if i ~= j and 0 < cardsLay[j] then
                            if restJokerCount + cardsLay[j] >= count2 then
                                local thisValue = self:getCardIndexPri(i, rank, 0) * 10000 + self:getCardIndexPri(j, rank, 0)
                                local index = self:getCardIndexPri(i, rank, 0)
                                if thisValue > destValue and (index ~= nWaitMainIndex)then
                                    if -1 == mainIndex or thisValue < value then
                                        mainIndex   = i
                                        secondIndex = j
                                        value       = thisValue
                                    end
                                end
                            end
                        end
                    end
                       
                    cardsLay[i] = temp           --还原       
                end                  
            end
        end
    end

    if -1 == mainIndex then
        return false
    else
        return true, mainIndex, secondIndex
    end
end

function MyCalculator:getCardType_Three_CoupleEx(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, WaitType)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end

    local bnFind, mainIndex, secondIndex = self:getDoubleCountEx(cardsLay, layLen, 3, 2, jokerCount, uniteType.nMainValue, WaitType)
    if not bnFind then
        return false
    end

    local rank = GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE
    uniteType.nMainValue    = self:getCardIndexPri(mainIndex, rank, 0) * 10000 + self:getCardIndexPri(secondIndex, rank, 0)
    uniteType.nCardsCount    = 5

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, mainIndex, 3, -1)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, secondIndex, 2, -1)

    return true
end

function MyCalculator:calcCardType_ABT_Single(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 5 ~= cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    local bnFind = false
    while self:getCardType_ABT_Single(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) do
        bnFind = true
    end
    if not bnFind then
        return false
    end
    if cardsDetail.uniteType[index].nCardsCount ~= cardsCount then --此时牌数需要吻合，才能是此类型
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_ABT_Single(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxCount)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    if 5 ~= maxCount then
        return false
    end

    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        if uniteType.nCardsCount ~= maxCount then
            return false
        end
        value = uniteType.nMainValue
    end

    local startIndex, minValue, rank = -1, -1, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    for i = 1, 14 - maxCount do
        local abtCount = 0
        for j = 0, 4 do --最多5张连牌
            if 0 ~= cardsLay[i + j] then
                abtCount = abtCount + 1
            end
        end

        if abtCount + jokerCount >= maxCount and self:getCardIndexPri(i, -1, 0) + 100 > value then
            if minValue == -1 or self:getCardIndexPri(i, -1, 0) + 100 < minValue then
                startIndex  = i
                minValue    = self:getCardIndexPri(i, -1, 0) + 100
            end
        end
    end

    local abtCount=0
	if (cardsLay[13]>0)then
		abtCount = abtCount + 1
    end
	if (cardsLay[1]>0) then
		abtCount = abtCount + 1
    end
	if (cardsLay[2]>0) then
		abtCount = abtCount + 1
    end
	if (cardsLay[3]>0) then
		abtCount = abtCount + 1
    end
	if (cardsLay[4]>0) then
		abtCount = abtCount + 1
    end

    if abtCount+jokerCount>=maxCount and value==0 then
        if minValue == -1 or self:getCardIndexPri(0, -1, 0) + 100 < minValue then
            startIndex  = 0
            minValue    = self:getCardIndexPri(0, -1, 0) + 100
        end
    end


    if -1 == startIndex then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
    uniteType.nMainValue    = minValue
    uniteType.nCardsCount   = maxCount

    local temp = {}
    self:copyTable(temp, cardIDs)
    if startIndex == 0 then
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 13, 1, -1)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 1, 1, -1)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 2, 1, -1)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 3, 1, -1)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 4, 1, -1)
    else     
        for i = startIndex, startIndex + maxCount - 1 do
            self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, i, 1, -1)
        end
    end

    return true
end

function MyCalculator:calcCardType_ABT_Couple(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 6 ~= cardsCount then --必须是三连队
        return false
    end
    if 0 ~= cardsCount % 2 then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_ABT_Couple(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount / 2) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_ABT_Couple(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxPair)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    if 2 > maxPair then
        return false
    end

    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
        if uniteType.nCardsCount ~= maxPair * 2 then
            return false
        end
        value = uniteType.nMainValue
    end

    local startIndex, minValue, rank = -1, -1, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()
    local bFindAbtCouple = false
    local BaseValue=1000*maxPair
    for i = 1, 14 - maxPair do
        local abtCount = 0
        for j = 0, maxPair - 1 do
            if cardsLay[i+j] < 2 then
                abtCount = abtCount+2-cardsLay[i+j]
            end           
        end

        if abtCount <= jokerCount and self:getCardIndexPri(i, -1, 0) + BaseValue > value
                and (-1 == minValue or self:getCardIndexPri(i, -1, 0) + BaseValue < minValue) then
            startIndex  = i
            minValue    = self:getCardIndexPri(i, -1, 0) + BaseValue
            bFindAbtCouple = true
            break
        end
    end

    -- nValue == 0 说明是主动选出来6张牌, c该条件作用于2张级牌且剩余都是两个对子的情况，取较大的组合
    if jokerCount == 2 and true == bFindAbtCouple and nValue == 0 then
        local biggerIndex = startIndex + 1
        local bigestIndex = startIndex + 2
        if cardsLay[biggerIndex - 1] >= 2 and cardsLay[bigestIndex] >= 2 then
            startIndex = biggerIndex
            local biggerValue = self:getCardIndexPri(biggerIndex, -1, 0)
            minValue = biggerValue + BaseValue  -- 比如 22 44 55，让级牌2 充当最大值，变成44 55 66， 则
        end
    end

    local abtCount=0
    if (cardsLay[13] < 2)then
		abtCount = abtCount + 2-cardsLay[13]
    end
	if (cardsLay[1] < 2) then
		abtCount = abtCount + 2-cardsLay[1]
    end
	if (cardsLay[2] < 2) then
		abtCount = abtCount + 2-cardsLay[2]
    end

    if abtCount <= jokerCount and value==0 
            and (-1 == minValue or self:getCardIndexPri(0, -1, 0) + 1000 < minValue) then
        startIndex  = 0
        minValue    = self:getCardIndexPri(0, -1, 0) + 1000
    end


    if -1 == startIndex then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
    uniteType.nMainValue    = minValue
    uniteType.nCardsCount   = maxPair * 2

    local temp = {}
    self:copyTable(temp, cardIDs)
    if startIndex == 0 then
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 13, 2, -1)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 1, 2, -1)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 2, 2, -1)
    else   
        for i = startIndex, startIndex + maxPair - 1 do
            self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, i, 2, -1)
        end
    end

    return true
end

function MyCalculator:calcCardType_ABT_Three(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 6 ~= cardsCount then
        return false
    end
    if 0 ~= cardsCount % 3 then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_ABT_Three(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount / 3) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_ABT_Three(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxPair)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    if 2 > maxPair then
        return false
    end

    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        if uniteType.nCardsCount ~= maxPair * 3 then
            return false
        end
        value = uniteType.nMainValue
    end

    local startIndex, minValue, rank = -1, -1, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()
    
    local BaseValue=1000*maxPair
    for i = 1, 14 - maxPair do
        local abtCount = 0
        for j = 0, maxPair-1 do
            if cardsLay[i + j]<3 then
                abtCount = abtCount + 3 - cardsLay[i + j]
            end          
        end

        if abtCount <= jokerCount and self:getCardIndexPri(i, -1, 0) + BaseValue > value
                and (-1 == minValue or self:getCardIndexPri(i, -1, 0) + BaseValue < minValue) then
            startIndex  = i
            minValue    = self:getCardIndexPri(i, -1, 0) + BaseValue
            break
        end
    end

    if -1 == startIndex then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE
    uniteType.nMainValue    = minValue
    uniteType.nCardsCount    = maxPair * 3

    local temp = {}
    self:copyTable(temp, cardIDs)
    for i = startIndex, startIndex + maxPair - 1 do
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, i, 3, -1)
    end

    return true
end

function MyCalculator:calcCardType_ABT_Three_Couple(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 10 > cardsCount then
        return false
    end
    if 0 ~= cardsCount % 5 then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_ABT_Three_Couple(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount / 5) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_ABT_Three_Couple(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxPair)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    if 2 > maxPair then
        return false
    end

    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE then
        if uniteType.nCardsCount ~= maxPair * 5 then
            return false
        end
        value = uniteType.nMainValue
    end

    local startIndex, secondIndex, minValue, tempLay, rank = -1, -1, -1, {}, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    for i = 2, 14 - maxPair do
        self:copyTable(tempLay, cardsLay)
        local jokerNeed = 0
        for j = 0, maxPair - 1 do
            if 3 <= tempLay[i + j] then
                tempLay[i + j]  = tempLay[i + j] - 3
            else
                jokerNeed       = jokerNeed + (3 - tempLay[i + j])
                tempLay[i + j]  = 0
            end
        end

        if jokerNeed <= jokerCount then
            for m = 2, 14 - maxPair do
                local jokerNeedEx = jokerNeed
                for n = 0, maxPair - 1 do
                    if 2 > tempLay[m + n] then
                        jokerNeedEx = jokerNeedEx + (2 - tempLay[m + n])
                    end
                end

                if jokerNeedEx <= jokerCount and self:getCardIndexPri(i, rank, 0) * 100 + self:getCardIndexPri(m, rank, 0) > value
                    and (-1 == minValue or self:getCardIndexPri(i, rank, 0) * 100 + self:getCardIndexPri(m, rank, 0) < minValue) then
                    startIndex  = i
                    secondIndex = m
                    minValue    = self:getCardIndexPri(i, rank, 0) * 100 + self:getCardIndexPri(m, rank, 0)
                end
            end
        end
    end

    if -1 == startIndex or -1 == secondIndex then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE
    uniteType.nMainValue    = minValue
    uniteType.nCardsCount    = maxPair * 5

    local temp = {}
    self:copyTable(temp, cardIDs)
    for i = 0, maxPair - 1 do
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, startIndex + i, 3, -1)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, secondIndex + i, 2, -1)
    end

    return true
end

function MyCalculator:calcCardType_TongHuaShun(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 5 ~= cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    local bnFind = false
    while self:getCardType_TongHuaShun(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount, true) do
        bnFind = true
    end
    if not bnFind then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_TongHuaShun(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxCount, bGetMax)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then
        value = uniteType.nMainValue
    end
    local minValue=-1
    
    local startIndex, shape, rank = -1, -1, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    local lay = {}
    --[[for i=1,6 do
        lay[i] = {}
        for j = 1, SKGameDef.SK_LAYOUT_NUM do
            lay[i][j] = 0
        end     
    end--]]
    
    local shapeCount = {}
    for i=1,4 do
        lay[i] = {}
        shapeCount[i] = 0
    end
    
    for i=1, cardsLen do
        if cardIDs[i] ==-1 then
            break
        end
        if self:isJoker(cardIDs[i]) then
        else
            local shape=self:getCardShape(cardIDs[i], 0)
			local index=self:getCardIndex(cardIDs[i], 0)
            shape = shape + 1
            if shape < 5 then
                if lay[shape][index] == nil then
                    lay[shape][index] = 0
                end
                lay[shape][index] = lay[shape][index] + 1
                shapeCount[shape] = shapeCount[shape] + 1
            end
        end
    end

    for i=1, 4 do
        if shapeCount[i] + jokerCount >= 5 then
            for j=1 , 14-maxCount do
                if not lay[i][j] and j~=9 then
                else
                    local abtCount = 0
                    for k=0, maxCount-1 do
                        if lay[i][j+k]~=nil then
                            abtCount = abtCount + 1
                        end
                    end               

                    local bTempBool = self:getCardIndexPri(j, -1, 0) + 100 < minValue
                    if bGetMax then
                        bTempBool = self:getCardIndexPri(j, -1, 0) + 100 > minValue
                    end
                    if abtCount+jokerCount >= maxCount and self:getCardIndexPri(j, -1, 0) + 100 > value 
                            and (minValue == -1 or bTempBool)then
                        startIndex=j
                        minValue=self:getCardIndexPri(j, -1, 0) + 100
                        shape=i
                    end
                end      
            end 
        
            if lay[i][13]~=nil then
                local abtCount=0
                if lay[i][13]~=nil then
                    abtCount = abtCount + 1
                end
                if lay[i][1]~=nil then
                    abtCount = abtCount + 1
                end
                if lay[i][2]~=nil then
                    abtCount = abtCount + 1
                end
                if lay[i][3]~=nil then
                    abtCount = abtCount + 1
                end
                if lay[i][4]~=nil then
                    abtCount = abtCount + 1
                end

                local bTempBool = self:getCardIndexPri(0, -1, 0) + 100 < minValue
                if bGetMax then
                    bTempBool = self:getCardIndexPri(0, -1, 0) + 100 > minValue
                end

                if abtCount+jokerCount >= maxCount and value==0 
                            and (minValue == -1 or bTempBool) then
                    startIndex=0
                    minValue=self:getCardIndexPri(0, -1, 0) + 100
                    shape=i
                end
            end    
        end        
    end
    
    if startIndex==-1 then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN
    uniteType.dwComPareType = MyGameDef.MY_COMPARE_UNITE_TYPE_TONGHUASHUN
    uniteType.nMainValue    = minValue
    uniteType.nCardsCount    = maxCount

    local temp = {}
    self:copyTable(temp, cardIDs)

    shape = shape - 1
    if startIndex==0 then
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 13, 1, shape)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 1, 1, shape)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 2, 1, shape)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 3, 1, shape)
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 4, 1, shape)
    else
        for i = startIndex, startIndex + maxCount - 1 do
            self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, i, 1, shape)
        end
    end

    return true --有同花顺的请自行处理
end

-- 比上面的先进一点，可以选出不同花色同主值的 同花顺
function MyCalculator:getCardType_TongHuaShunMore(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxCount, bGetMax, outUniteTypes)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then
        value = uniteType.nMainValue
    end
    local minValue=-1
    
    --local startIndex, shape, rank = -1, -1, GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    local lay = {}
    --[[for i=1,6 do
        lay[i] = {}
        for j = 1, SKGameDef.SK_LAYOUT_NUM do
            lay[i][j] = 0
        end     
    end--]]
    
    local shapeCount = {}
    for i=1,4 do
        lay[i] = {}
        shapeCount[i] = 0
    end
    
    for i=1, cardsLen do
        if cardIDs[i] ==-1 then
            break
        end
        if self:isJoker(cardIDs[i]) then
        else
            local shape=self:getCardShape(cardIDs[i], 0)
			local index=self:getCardIndex(cardIDs[i], 0)
            shape = shape + 1
            if shape < 5 then
                if lay[shape][index] == nil then
                    lay[shape][index] = 0
                end
                lay[shape][index] = lay[shape][index] + 1
                shapeCount[shape] = shapeCount[shape] + 1
            end
        end
    end

    local resultTHSArray = {}
    local countTHS = 1
    for i=1 , 4 do
        if shapeCount[i] + jokerCount >= 5 then
            local resultInfo = {startIndex=-1, minValue=-1, shape=-1}
            for j=1 , 14-maxCount do
                if not lay[i][j] and j~=9 then
                else
                    local abtCount = 0
                    for k=0, maxCount-1 do
                        if lay[i][j+k]~=nil then
                            abtCount = abtCount + 1
                        end
                    end               

                    local bTempBool = self:getCardIndexPri(j, -1, 0) + 100 <= resultInfo.minValue
                    if bGetMax then
                        bTempBool = self:getCardIndexPri(j, -1, 0) + 100 > resultInfo.minValue
                    end

                    if abtCount+jokerCount >= maxCount and self:getCardIndexPri(j, -1, 0) + 100 > value 
                            and (resultInfo.minValue == -1 or bTempBool)then
                        resultInfo.startIndex=j
                        resultInfo.minValue=self:getCardIndexPri(j, -1, 0) + 100
                        resultInfo.shape=i
                        resultTHSArray[countTHS] = clone(resultInfo)
                        countTHS = countTHS + 1
                    end
                end      
            end 
        
            if lay[i][13]~=nil then
                local abtCount=0
                if lay[i][13]~=nil then
                    abtCount = abtCount + 1
                end
                if lay[i][1]~=nil then
                    abtCount = abtCount + 1
                end
                if lay[i][2]~=nil then
                    abtCount = abtCount + 1
                end
                if lay[i][3]~=nil then
                    abtCount = abtCount + 1
                end
                if lay[i][4]~=nil then
                    abtCount = abtCount + 1
                end

                local bTempBool = self:getCardIndexPri(0, -1, 0) + 100 < resultInfo.minValue

                if abtCount+jokerCount >= maxCount and value==0 
                            and (resultInfo.minValue == -1 or bTempBool) then
                    resultInfo.startIndex=0
                    resultInfo.minValue=self:getCardIndexPri(0, -1, 0) + 100
                    resultInfo.shape=i
                    resultTHSArray[countTHS] = clone(resultInfo)
                    countTHS = countTHS + 1
                end
            end   

        end

    end
    
    if next(resultTHSArray) == nil then
        return false
    end

    for k,v in pairs(resultTHSArray) do
        local startIndex = v.startIndex
        local minValue = v.minValue
        local shape = v.shape

        if startIndex==-1 then
            return false
        end

        local outUniteType = uniteType --self:initUniteType()
        self:xygInitChairCards(outUniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
        outUniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN
        outUniteType.dwComPareType = MyGameDef.MY_COMPARE_UNITE_TYPE_TONGHUASHUN
        outUniteType.nMainValue    = minValue
        outUniteType.nCardsCount    = maxCount
        local temp = {}
        self:copyTable(temp, cardIDs)

        shape = shape - 1
    
        if startIndex==0 then
            self:putCardToArray(outUniteType.nCardIDs, cardsLen, temp, cardsLen, 13, 1, shape)
            self:putCardToArray(outUniteType.nCardIDs, cardsLen, temp, cardsLen, 1, 1, shape)
            self:putCardToArray(outUniteType.nCardIDs, cardsLen, temp, cardsLen, 2, 1, shape)
            self:putCardToArray(outUniteType.nCardIDs, cardsLen, temp, cardsLen, 3, 1, shape)
            self:putCardToArray(outUniteType.nCardIDs, cardsLen, temp, cardsLen, 4, 1, shape)
            table.insert(outUniteTypes, 1, clone(outUniteType))
        else
            for i = startIndex, startIndex + maxCount - 1 do
                self:putCardToArray(outUniteType.nCardIDs, cardsLen, temp, cardsLen, i, 1, shape)
            end
            table.insert(outUniteTypes, clone(outUniteType))
        end

        --table.insert(outUniteTypes, clone(outUniteType))
    end

    return true
end


function MyCalculator:calcCardType_Bomb(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 4~=cardsCount and 5~=cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    cardsDetail.uniteType[index].nCardsCount=cardsCount
    --主值放前，财神放后
    self:zeroTable(cardsDetail.uniteType[index])

    if self:getCardType_Bomb(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) then
        cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
        return true
    end

    return false
end

function MyCalculator:getCardType_Bomb(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, useCount)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end

    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
        value = uniteType.nMainValue
    end

    local cardsCount, cardIndex = 0, -1
    if 0 < useCount then
        cardsCount = useCount
        cardIndex = self:getSameCountEx(cardsLay, layLen, useCount, jokerCount, value)
        if -1 == cardIndex then
            return false
        end
    else
        for i = 4, 5 do
            cardIndex = self:getSameCountEx(cardsLay, layLen, i, jokerCount, value)
            if -1 ~= cardIndex then
                cardsCount = i
                break
            end
        end

        if -1 == cardIndex then
            return false
        end
    end

    local rank = GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_BOMB
    uniteType.dwComPareType = MyGameDef.MY_COMPARE_UNITE_TYPE_BOMB
    uniteType.nMainValue    = self:getCardIndexPri(cardIndex, rank, 0)
    uniteType.nCardsCount    = cardsCount
    for i = 1, cardsCount - 4 do
        uniteType.nMainValue = uniteType.nMainValue + 10000
    end

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, cardIndex, cardsCount, -1)

    return true
end

function MyCalculator:calcCardType_SuperBomb(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 6 ~= cardsCount 
        and 7 ~= cardsCount
        and 8 ~= cardsCount
        and 9 ~= cardsCount
        and 10 ~= cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_SuperBomb(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_SuperBomb(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, useCount)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end

    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        value = uniteType.nMainValue
    end

    local cardsCount, cardIndex = 6, -1
    if 0 < useCount then
        cardsCount = useCount
        cardIndex = self:getSameCountEx(cardsLay, layLen, useCount, jokerCount, value)
        if -1 == cardIndex then
            return false
        end
    else
        for i = 6, 10 do
            cardIndex = self:getSameCountEx(cardsLay, layLen, i, jokerCount, value)
            if -1 ~= cardIndex then
                cardsCount = i
                break
            end
        end

        if -1 == cardIndex then
            return false
        end
    end

    local rank = GamePublicInterface._gameController._baseGameUtilsInfoManager:getCurrentRank()

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB
    uniteType.dwComPareType = MyGameDef.MY_COMPARE_UNITE_TYPE_SUPER_BOMB
    uniteType.nMainValue    = self:getCardIndexPri(cardIndex, rank, 0)
    uniteType.nCardsCount    = cardsCount
    for i = 1, cardsCount - 4 do
        uniteType.nMainValue = uniteType.nMainValue + 10000
    end

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, cardIndex, cardsCount, -1)

    return true
end

function MyCalculator:calcCardType_4King(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 4 ~= cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, SKGameDef.SK_GF_USE_JOKER)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_4King(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function MyCalculator:getCardType_4King(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, useCount)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end

    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING and 0 < uniteType.nMainValue then
        return false
    end
    if 2 ~= cardsLay[14] or 2 ~= cardsLay[15] then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_4KING
    uniteType.dwComPareType = MyGameDef.MY_COMPARE_UNITE_TYPE_4KING
    uniteType.nMainValue    = 1
    uniteType.nCardsCount    = 4

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 14, 2, -1)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 15, 2, -1)

    return true
end

function MyCalculator:isSameCardIDs(leftCardIDs, rightCardIDs)
    if #leftCardIDs ~= #rightCardIDs then
        return false
    end
    for i = 1, #leftCardIDs do
        local bFind = false
        for j = 1, #rightCardIDs do
            if leftCardIDs[i] == rightCardIDs[j] then
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

return MyCalculator
