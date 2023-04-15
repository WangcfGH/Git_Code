--[[
            双扣牌型逻辑
    cardsid请用xygInitChairCards
    cardslay请用xygZeroLays
           进行初始化
           避免nil参与运算
]]
if nil == cc or nil == cc.exports then
    return
end


require("src.cocos.cocos2d.bitExtend")

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")
local SKGameUtilsInfoManager                    = import("src.app.Game.mSKGame.SKGameUtilsInfoManager")

local GamePublicInterface                       = import("src.app.Game.mMyGame.GamePublicInterface")

cc.exports.SKCalculator                         = {}
local SKCalculator                              = cc.exports.SKCalculator

SKCalculator.nAbtPairs                          = {0, 0, 3, 2, 0, 0, 0, 0,
                                                    0, 0, 0, 0, 0, 0, 0, 0}

function SKCalculator:IS_BIT_SET(flag, mybit)
    if not flag or not mybit then
        return false
    end
    return (mybit == bit._and(mybit, flag))
end

function SKCalculator:isFrame_1()
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        return true
    else
        return false
    end
end

function SKCalculator:copyTable(new_tab, ori_tab)
    if (type(ori_tab) ~= "table") then
        return nil
    end
    for i,v in pairs(ori_tab) do
        local vtyp = type(v)
        if (vtyp == "table") then
            if not new_tab[i] then
                new_tab[i] = {}
            end
            self:copyTable(new_tab[i], v)
        elseif (vtyp == "thread") then
            -- TODO: dup or just point to?
            new_tab[i] = v
        elseif (vtyp == "userdata") then
            -- TODO: dup or just point to?
            new_tab[i] = v
        else
            new_tab[i] = v
        end
    end
end

function SKCalculator:zeroTable(tab)
    if (type(tab) ~= "table") then
        return
    end

    for i,v in pairs(tab) do
        local vtyp = type(v)
        if (vtyp == "table") then
            self:zeroTable(v)
        elseif (vtyp == "thread") then
            -- TODO: dup or just point to?
            tab[i] = 0
        elseif (vtyp == "userdata") then
            -- TODO: dup or just point to?
            tab[i] = 0
        else
            tab[i] = 0
        end
    end
end

function SKCalculator:copyCardIDs(destCards, thisCards)
    self:xygInitChairCards(destCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)

    for i = 1, SKGameDef.SK_MAX_CARDS_PER_CHAIR do
        if thisCards[i] then
            destCards[i] = thisCards[i]
        else
            break
        end
    end
end

function SKCalculator:initUniteType()
    local uniteType         = {}
    uniteType.dwCardType    = 0
    uniteType.dwComPareType = 0
    uniteType.nMainValue    = 0
    uniteType.nCardsCount    = 0
    uniteType.nCardIDs      = {}
    for i = 1, SKGameDef.SK_MAX_CARDS_PER_CHAIR do
        uniteType.nCardIDs[i] = SKGameDef.SK_INVALID_OBJECT_ID
    end

    return uniteType
end

function SKCalculator:initCardUnite()
    local cardUnite         = {}
    cardUnite.uniteType     = {}
    for i = 1, SKGameDef.SK_MAX_FIT_TYPE do
        cardUnite.uniteType[i] = self:initUniteType()
    end
    cardUnite.nTypeCount    = 0

    return cardUnite
end

function SKCalculator:xygHaveCard(cardIDs, cardsLen, cardID)
    if not self:isValidCard(cardID) then
        return false
    end

    for i = 1, cardsLen do
        if cardIDs[i] and cardID == cardIDs[i] then
            return true
        end
    end

    return false
end

function SKCalculator:xygZeroLays(lay, layLen)
    for i = 1, layLen do
        lay[i] = 0
    end
end

function SKCalculator:xygCardRemains(lay)
    local sum = 0
    for i , v in pairs(lay) do
        sum = sum + lay[i]
    end
    return sum
end

function SKCalculator:haveDiffCards(lay)
    local sum = 0
    for i , v in pairs(lay) do
        if (0 < lay[i]) then
            sum = sum + 1
        end
    end
    return sum
end

function SKCalculator:reversalLessEx(t, start, count)
    local temp = 0
    for i = start, start + count - 2 do
        for j = i + 1, start + count - 1 do
    	   if t[i] > t[j] then
    	       temp = t[i]
    	       t[i] = t[j]
    	       t[j] = temp
    	   end
    	end
    end
end

function SKCalculator:xygInitChairCards(cardIDs, cardsLen)
    for i = 1, cardsLen do
        cardIDs[i] = SKGameDef.SK_INVALID_OBJECT_ID
    end
end

function SKCalculator:getCardIndex(cardID, gameFlags)
    if self:isFrame_1() then
        return self:getCardIndex_1(cardID)
    end

    cardID = cardID % 54
    if 52 == cardID then
        return 14           --小王
    elseif 53 == cardID then
        return 15           --大王
    else
        return cardID % SKGameDef.SK_LAYOUT_MOD + 1
    end
end

function SKCalculator:getCardIndex_1(cardID)
    if not self:isValidCard(cardID) then
        return 0
    end

    local shape = self:getCardShape_1(cardID)
    local value = self:getCardValue_1(cardID)

    if SKGameDef.SK_CS_KING == shape then
        return value + SKGameDef.SK_LAYOUT_MOD_1
    else
        return value
    end
end

function SKCalculator:getCardScore(cardID, gameFlags)
    local cardIndex = self:getCardIndex(cardID, gameFlags)
    if 4 == cardIndex then
        return 5            --5
    elseif 9 == cardIndex then
        return 10           --10
    elseif 12 == cardIndex then
        return 10           --K
    else
        return 0
    end
end

function SKCalculator:getCardShape(cardID, gameFlags)
    if self:isFrame_1() then
        return self:getCardShape_1(cardID)
    end

    cardID = cardID % 54
    if 52 <= cardID then
        return SKGameDef.SK_CS_KING
    else
        return math.floor(cardID / SKGameDef.SK_LAYOUT_MOD)
    end
end

function SKCalculator:getCardShape_1(cardID)
    if self:isValidCard(cardID) then
        return math.floor(cardID / ((SKGameDef.SK_LAYOUT_MOD_1 - 1) * SKGameDef.SK_TOTAL_PACK))
    else
        return SKGameDef.SK_INVALID_OBJECT_ID
    end
end

function SKCalculator:getCardValue(cardID, gameFlags)
    if self:isFrame_1() then
        return self:getCardValue_1(cardID)
    end

    cardID = cardID % 54
    return cardID % SKGameDef.SK_LAYOUT_MOD + 1
end

function SKCalculator:getCardValue_1(cardID)
    if 0 <= cardID and cardID < (SKGameDef.SK_TOTAL_CARDS - SKGameDef.SK_TOTAL_PACK * 2) then
        return cardID % (SKGameDef.SK_LAYOUT_MOD_1 - 1) + 1
    elseif cardID >= (SKGameDef.SK_TOTAL_CARDS - SKGameDef.SK_TOTAL_PACK * 2) and cardID < SKGameDef.SK_TOTAL_CARDS then
        return cardID % 2 + 1
    end

    return 0
end

function SKCalculator:getCardIndexPri(cardIndex, rank, gameFlags)
    if self:isFrame_1() then
        return cardIndex
    end

    if 14 == cardIndex then
        return 21
    elseif 15 == cardIndex then
        return 22
    elseif rank == cardIndex then
        return 20
    else
        return cardIndex
    end
end

function SKCalculator:getCardPri(cardID, rank, gameFlags)
    if self:isFrame_1() then
        return self:getCardIndexPri_1(cardID, gameFlags)
    end

    local cardIndex = self:getCardIndex(cardID, gameFlags)
    local cardShape = self:getCardShape(cardID, gameFlags)
    return self:getCardIndexPri(cardIndex, rank, gameFlags) * SKGameDef.SK_CS_TOTAL + cardShape
end

function SKCalculator:getCardIndexPri_1(cardID, gameFlags)
    local cardValue = self:getCardValue(cardID, gameFlags)
    local cardShape = self:getCardShape(cardID, gameFlags)

    if cardShape == SKGameDef.SK_CS_KING then
        cardValue = cardValue + SKGameDef.SK_LAYOUT_MOD_1
    end

    return cardValue * SKGameDef.SK_CS_TOTAL + cardShape
end

function SKCalculator:getCardsCount(cardIDs, cardsLen)
    local cardsCount = 0
    for i = 1, cardsLen do
        if self:isValidCard(cardIDs[i]) then
            cardsCount = cardsCount + 1
        end
    end
    return cardsCount
end

function SKCalculator:isValidCard(cardID)
    if cardID and 0 <= cardID and SKGameDef.SK_TOTAL_CARDS > cardID then
        return true
    else
        return false
    end
end

function SKCalculator:isJoker(cardID)
    return false
end

function SKCalculator:isJokerEx(cardIndex)
    return false
end

function SKCalculator:preDealCards(cardIDs, cardsLen, cardsLay, layLen, gameFlags)
    local cardsCount, jokerCount = 0, 0
    for i = 1, cardsLen do
        if self:isValidCard(cardIDs[i]) then
            cardsCount = cardsCount + 1

            if self:isJoker(cardIDs[i]) and self:IS_BIT_SET(gameFlags, SKGameDef.SK_GF_USE_JOKER) then
                jokerCount = jokerCount + 1
            else
                local cardIndex = self:getCardIndex(cardIDs[i])
                cardsLay[cardIndex] = cardsLay[cardIndex] + 1
            end
        end
    end

    if cardsCount == jokerCount then
        for i = 1, cardsLen do
            jokerCount = 0

            if self:isValidCard(cardIDs[i]) then
                local cardIndex = self:getCardIndex(cardIDs[i])
                cardsLay[cardIndex] = cardsLay[cardIndex] + 1
            end
        end
    end

    return jokerCount, cardsCount
end

function SKCalculator:getSameCount(cardsLay, layLen, sameCount, jokerCount)
    local bigestIndex, rank = -1, SKGameUtilsInfoManager:getCurrentRank()
    for i = 1, layLen do
        if 0 < cardsLay[i] and cardsLay[i] + jokerCount >= sameCount then
            if -1 == bigestIndex or self:getCardIndexPri(i, rank, 0) > self:getCardIndexPri(bigestIndex, rank, 0) then
                bigestIndex = i
            end
        end
    end

    return bigestIndex
end

function SKCalculator:getSameCountEx(cardsLay, layLen, sameCount, jokerCount, destValue)
    local bigestIndex, smallValue, rank = -1, 0, SKGameUtilsInfoManager:getCurrentRank()
    for i = 1, layLen do
        if 0 < cardsLay[i] then
            local priPlus = 0
            if 4 < sameCount then
                priPlus = (sameCount - 4) * 10000
            end

            if cardsLay[i] + jokerCount >= sameCount and (self:getCardIndexPri(i, rank, 0) + priPlus) > destValue then
                if -1 == bigestIndex or (self:getCardIndexPri(i, rank, 0) + priPlus) < smallValue then
                    bigestIndex = i
                    smallValue  = self:getCardIndexPri(i, rank, 0) + priPlus
                end
            end
        end
    end

    return bigestIndex
end

function SKCalculator:getDoubleCount(cardsLay, layLen, count1, count2, jokerCount, destValue)
    local mainIndex, secondIndex, value, rank = -1, -1, 0, SKGameUtilsInfoManager:getCurrentRank()
    for i = 1, layLen do
        if 0 < cardsLay[i] then
            local restJokerCount = jokerCount
            if restJokerCount + cardsLay[i] >= count1 then
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

                cardsLay[i] = temp           --还原
            end
        end
    end

    if -1 == mainIndex then
        return false
    else
        return true, mainIndex, secondIndex
    end
end

function SKCalculator:skLayCards(cardIDs, cardsLen, cardsLay, gameFlags)
    local count, cardIndex = 0, 0
    for i = 1, cardsLen do
        if cardIDs[i] and 0 <= cardIDs[i] then
            cardIndex           = self:getCardIndex(cardIDs[i], gameFlags)
            cardsLay[cardIndex] = cardsLay[cardIndex] + 1
            count               = count + 1
        end
    end

    return count
end

function SKCalculator:skLayCards_1(cardIDs, cardsLen, cardsLay, gameFlags)
    local count = 0
    for i = 1, cardsLen do
        if cardIDs[i] and 0 <= cardIDs[i] then
            local shape         = self:getCardShape_1(cardIDs[i])
            local value         = self:getCardValue_1(cardIDs[i])
            local cardIndex     = shape * SKGameDef.SK_LAYOUT_MOD_1 + value
            cardsLay[cardIndex] = cardsLay[cardIndex] + 1
            count               = count + 1
        end
    end

    return count
end

--2.0模板牌型算法
function SKCalculator:getUniteDetails(cardIDs, cardsLen, unitDetail, dwFlags)
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

    if self:IS_BIT_SET(dwFlags, SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE) then
        self:calcCardType_ABT_Three_Couple(cardIDs, cardsLen, cardsCount, unitDetail)
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

function SKCalculator:compareCards(firstCards, fightCards)
    if self:IS_BIT_SET(fightCards.dwComPareType, firstCards.dwComPareType) then
        if fightCards.dwComPareType == firstCards.dwComPareType then        --牌型相同，比较主值
            if fightCards.nMainValue > firstCards.nMainValue then
                return true
            end
        else                                                                --克制牌型中包含了目标牌型
            return true
        end
    end

    return false
end

function SKCalculator:getBestUnitType1(fightCards)
    if 1 >= fightCards.nTypeCount then
        return
    end

    local dwDestType, dwDestMain, dwDestCompareType = fightCards.uniteType[1].dwCardType, fightCards.uniteType[1].nMainValue, fightCards.uniteType[1].dwComPareType
    local cardIDs = {}
    self:xygInitChairCards(cardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)

    local bnFindBig = false
    for i = 1, fightCards.nTypeCount do
        if self:IS_BIT_SET(fightCards.uniteType[i].dwComPareType, dwDestType) then
            if fightCards.uniteType[i].dwCardType ~= dwDestType or fightCards.uniteType[i].nMainValue > dwDestMain then
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

function SKCalculator:getBestUnitType2(firstCards, fightCards)
    --local dwDestType, dwDestMain, dwDestCompareType = firstCards.uniteType[1].dwCardType, firstCards.uniteType[1].nMainValue, fightCards.uniteType[1].dwComPareType
    local dwDestType, dwDestMain, dwDestCompareType = firstCards.dwCardType, firstCards.nMainValue, fightCards.dwComPareType
    local cardIDs = {}
    self:xygInitChairCards(cardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)

    local bnFindBig = false
    for i = 1, fightCards.nTypeCount do
        if self:IS_BIT_SET(fightCards.uniteType[i].dwComPareType, dwDestType) then
            if fightCards.uniteType[i].dwCardType ~= dwDestType or fightCards.uniteType[i].nMainValue > dwDestMain then
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

function SKCalculator:putCardToArray(destCardIDs, destLen, srcCardIDs, srcLen, cardIndex, count, shape)
    local common, start = 0, 1
    for i = 1, destLen do
        if destCardIDs[i] == -1 then
            break
        else
            start = start + 1
        end
    end

    for i = 1, count do
        for j = 1, srcLen do
            if -1 ~= srcCardIDs[j] and not self:isJoker(srcCardIDs[j]) and cardIndex == self:getCardIndex(srcCardIDs[j], 0)
                and (-1 == shape or self:getCardShape(srcCardIDs[j], 0) == shape) then
                destCardIDs[start]  = srcCardIDs[j]
                srcCardIDs[j]       = -1
                common              = common + 1
                start               = start + 1
                if common >= count then
                    self:reversalLessEx(destCardIDs, start - count, count)
                    return
                end
            end
        end
    end

    for i = common, count do
        for j = 1, srcLen do
            if -1 ~= srcCardIDs[j] and self:isJoker(srcCardIDs[j]) then
                destCardIDs[start]  = srcCardIDs[j]
                srcCardIDs[j]       = -1
                common              = common + 1
                start               = start + 1
                if common >= count then
                    self:reversalLessEx(destCardIDs, start - count, count)
                    return
                end
            end
        end
    end
end

function SKCalculator:calcCardType_Single(cardIDs, cardsLen, cardsCount, cardsDetail)
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

function SKCalculator:getCardType_Single(cardIDs, cardsLen, uniteType)
    if 0 >= cardsLen then
        return false
    end

    local minCardID, minValue, value, rank = -1, -1, uniteType.nMainValue, SKGameUtilsInfoManager:getCurrentRank()

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

function SKCalculator:calcCardType_Couple(cardIDs, cardsLen, cardsCount, cardsDetail)
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
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

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

function SKCalculator:getCardType_Couple(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    local cardIndex = self:getSameCountEx(cardsLay, layLen, 2, jokerCount, uniteType.nMainValue)
    if -1 == cardIndex then
        return false
    end

    local rank = SKGameUtilsInfoManager:getCurrentRank()

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
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_Three(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index]) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function SKCalculator:getCardType_Three(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    local cardIndex = self:getSameCountEx(cardsLay, layLen, 3, jokerCount, uniteType.nMainValue)
    if -1 == cardIndex then
        return false
    end

    local rank = SKGameUtilsInfoManager:getCurrentRank()

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

function SKCalculator:calcCardType_Bomb(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 4 > cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_Bomb(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function SKCalculator:getCardType_Bomb(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, useCount)
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
        for i = 4, 4 * SKGameDef.SK_TOTAL_PACK do
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

    local rank = SKGameUtilsInfoManager:getCurrentRank()

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_BOMB
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_BOMB
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

-- 1.0
function SKCalculator:getCardType_Kings(cardIDs, cardsLen, cardsLay, layLen, uniteType, useCount)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    if useCount ~= cardsLay[15] + cardsLay[16] then
        return false
    end
    if useCount < 3 then
        return false
    end

	if useCount == 3 and cardsLay[15] ~= 0 and cardsLay[16] ~= 0 then
		return false
	end
	
    local value = useCount * 10000
    if useCount == 6 then                           --6王最大
        value = value + 30000
    elseif useCount == 3 and cardsLay[15] > 0 then  --3小王比5炸大6炸小
        value = value - 10000
    end
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB and uniteType.nMainValue >= value then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_BOMB
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_BOMB
    uniteType.nMainValue    = value
    uniteType.nCardsCount    = useCount

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 15, cardsLay[15], -1)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 16, cardsLay[16], -1)
	return true
end

function SKCalculator:calcCardType_SuperBomb(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 6 > cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_SuperBomb(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function SKCalculator:getCardType_SuperBomb(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, useCount)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end

    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then
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
        for i = 6, 4 * SKGameDef.SK_TOTAL_PACK do
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

    local rank = SKGameUtilsInfoManager:getCurrentRank()

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB
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

function SKCalculator:calcCardType_Three_Couple(cardIDs, cardsLen, cardsCount, cardsDetail)
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
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

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

function SKCalculator:getCardType_Three_Couple(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end

    local bnFind, mainIndex, secondIndex = self:getDoubleCount(cardsLay, layLen, 3, 2, jokerCount, uniteType.nMainValue)
    if not bnFind then
        return false
    end

    local rank = SKGameUtilsInfoManager:getCurrentRank()

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

function SKCalculator:calcCardType_ABT_Single(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 5 > cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_ABT_Single(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function SKCalculator:getCardType_ABT_Single(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxCount)
    if 0 >= cardsLen or 0 >= layLen then
        return false
    end
    if 5 > maxCount then
        return false
    end

    local value = 0
    if uniteType.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        if uniteType.nCardsCount ~= maxCount then
            return false
        end
        value = uniteType.nMainValue
    end

    local startIndex, minValue, rank = -1, -1, SKGameUtilsInfoManager:getCurrentRank()

    for i = 2, 14 - maxCount do
        local abtCount = 0
        for j = 0, 13 - i do
            if 1 <= cardsLay[i + j] then
                abtCount = abtCount + 1
                if abtCount >= maxCount then
                    break
                end
            else
                break
            end
        end

        if abtCount >= maxCount and self:getCardIndexPri(i, rank, 0) > value
            and (-1 == minValue or self:getCardIndexPri(i, rank, 0) < minValue) then
            startIndex  = i
            minValue    = self:getCardIndexPri(i, rank, 0)
            break
        end
    end

    if -1 == startIndex then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
    uniteType.nMainValue    = minValue
    uniteType.nCardsCount    = maxCount

    local temp = {}
    self:copyTable(temp, cardIDs)
    for i = startIndex, startIndex + maxCount - 1 do
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, i, 1, -1)
    end

    return true
end

function SKCalculator:calcCardType_ABT_Couple(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 4 > cardsCount then
        return false
    end
    if 0 ~= cardsCount % 2 then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_ABT_Couple(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount / 2) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function SKCalculator:getCardType_ABT_Couple(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxPair)
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

    local startIndex, minValue, rank = -1, -1, SKGameUtilsInfoManager:getCurrentRank()

    for i = 2, 14 - maxPair do
        local abtCount = 0
        for j = 0, 13 - i do
            if 2 <= cardsLay[i + j] then
                abtCount = abtCount + 1
                if abtCount >= maxPair then
                    break
                end
            else
                break
            end
        end

        if abtCount >= maxPair and self:getCardIndexPri(i, rank, 0) > value
            and (-1 == minValue or self:getCardIndexPri(i, rank, 0) < minValue) then
            startIndex  = i
            minValue    = self:getCardIndexPri(i, rank, 0)
            break
        end
    end

    if -1 == startIndex then
        return false
    end

    self:xygInitChairCards(uniteType.nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    uniteType.dwCardType    = SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE
    uniteType.nMainValue    = minValue
    uniteType.nCardsCount    = maxPair * 2

    local temp = {}
    self:copyTable(temp, cardIDs)
    for i = startIndex, startIndex + maxPair - 1 do
        self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, i, 2, -1)
    end

    return true
end

function SKCalculator:calcCardType_ABT_Three(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 6 > cardsCount then
        return false
    end
    if 0 ~= cardsCount % 3 then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_ABT_Three(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount / 3) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function SKCalculator:getCardType_ABT_Three(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxPair)
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

    local startIndex, minValue, rank = -1, -1, SKGameUtilsInfoManager:getCurrentRank()

    for i = 2, 14 - maxPair do
        local abtCount = 0
        for j = 0, 13 - i do
            if 3 <= cardsLay[i + j] then
                abtCount = abtCount + 1
                if abtCount >= maxPair then
                    break
                end
            else
                break
            end
        end

        if abtCount >= maxPair and self:getCardIndexPri(i, rank, 0) > value
            and (-1 == minValue or self:getCardIndexPri(i, rank, 0) < minValue) then
            startIndex  = i
            minValue    = self:getCardIndexPri(i, rank, 0)
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

function SKCalculator:calcCardType_ABT_Three_Couple(cardIDs, cardsLen, cardsCount, cardsDetail)
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

function SKCalculator:getCardType_ABT_Three_Couple(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxPair)
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

    local startIndex, secondIndex, minValue, tempLay, rank = -1, -1, -1, {}, SKGameUtilsInfoManager:getCurrentRank()

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

function SKCalculator:calcCardType_TongHuaShun(cardIDs, cardsLen, cardsCount, cardsDetail)
    if 0 >= cardsLen then
        return false
    end
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    if 5 > cardsCount then
        return false
    end

    local cardsLay = {}
    self:xygZeroLays(cardsLay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_TongHuaShun(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function SKCalculator:getCardType_TongHuaShun(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, maxCount)
    return false --有同花顺的请自行处理
end

function SKCalculator:calcCardType_4King(cardIDs, cardsLen, cardsCount, cardsDetail)
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
    local jokerCount = self:preDealCards(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM)

    local index = cardsDetail.nTypeCount + 1
    self:zeroTable(cardsDetail.uniteType[index])

    if not self:getCardType_Bomb(cardIDs, cardsLen, cardsLay, SKGameDef.SK_LAYOUT_NUM, jokerCount, cardsDetail.uniteType[index], cardsCount) then
        return false
    end

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end

function SKCalculator:getCardType_4King(cardIDs, cardsLen, cardsLay, layLen, jokerCount, uniteType, useCount)
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
    uniteType.dwComPareType = SKGameDef.SK_CARD_UNITE_TYPE_4KING
    uniteType.nMainValue    = 1
    uniteType.nCardsCount    = 4

    local temp = {}
    self:copyTable(temp, cardIDs)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 14, 2, -1)
    self:putCardToArray(uniteType.nCardIDs, cardsLen, temp, cardsLen, 15, 2, -1)

    return true
end

function SKCalculator:calcCardType_BUG(cardIDs, cardsLen, cardsCount, cardsDetail)
    if cardsDetail.nTypeCount >= SKGameDef.SK_MAX_FIT_TYPE then
        return false
    end

    local index = cardsDetail.nTypeCount + 1
    self:xygInitChairCards(cardsDetail.uniteType[index].nCardIDs, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    self:copyTable(cardsDetail.uniteType[index].nCardIDs, cardIDs)
    cardsDetail.uniteType[index].dwCardType     = SKGameDef.SK_CARD_UNITE_TYPE_BUG
    cardsDetail.uniteType[index].dwComPareType  = SKGameDef.SK_CARD_UNITE_TYPE_BUG
    cardsDetail.uniteType[index].nMainValue     = 1
    cardsDetail.uniteType[index].nCardsCount     = cardsCount

    cardsDetail.nTypeCount = cardsDetail.nTypeCount + 1
    return true
end
--2.0模板牌型算法end

--1.0模板牌型算法 by yuyl
function SKCalculator:isValidCardsEx(nCardLen, nCardIDs, cardsDetails)
    self:zeroTable(cardsDetails)
    local lay = {}
    self:xygZeroLays(lay, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    local gameFlag = GamePublicInterface:getGameFlags()

    self:skLayCards_1(nCardIDs, nCardLen, lay, gameFlag)

    local not_allowed_indexes = {}
    self:xygZeroLays(not_allowed_indexes, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    local start = 0

    local dwType = self:isJokerBomb(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isBomb(lay, cardsDetails, 4)
    if dwType ~= 0  then
     return dwType
    end

    dwType = self:isBombVice(lay, cardsDetails, 4)
    if dwType ~= 0 then
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

    dwType = self:isCoupleVice(lay, cardsDetails)
    if dwType ~= 0  then
        return dwType
    end

    dwType = self:isThree(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isThreeVice(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isAbtSingle(lay, cardsDetails, 5)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isAbtSingleVice(lay, cardsDetails, 5)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isAbtCouple(lay, cardsDetails, 3)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isAbtCoupleVice(lay, cardsDetails, 3)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isAbtThree(lay, cardsDetails, 2)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isAbtThreeVice(lay, cardsDetails, 2)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isThree2(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isThree2Vice(lay, cardsDetails)
    if dwType ~= 0 then
        return dwType
    end

    dwType = self:isButterFly(lay, cardsDetails, 2)
    if dwType ~= 0 then
        return dwType
    end

    return 0
end

function SKCalculator:isThree2Vice(nCardsLay, cardsDetails)
    if 0 == SKGameDef.SK_JOKER_COUNT then
        return 0
    end
    local lay = {}
    self:copyTable(lay, nCardsLay)

    local sum = self:xygCardRemains(lay)
    if 5 ~= sum then  --必须5张
        return 0
    end
    local jokers = self:getJokerCount(lay)
    if 0 == jokers then
        return 0
    end

    self:removeJokers(lay)

    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(lay, layex)

    if self:haveSomeEx(layex, 4) ~=0 then
        return 0
    end

    if self:haveDiffCardsEx(layex) > 2 then
        return 0
    end

    if 1 == jokers then
        if self:haveSomeEx(layex, 3)~=0 then
            cardsDetails.dwType = SKGameDef.SK_CT_THREE2
            cardsDetails.bVice = true
            cardsDetails.nStart = self:haveSomeEx(layex, 3)
            return SKGameDef.SK_CT_THREE2
        elseif self:haveSomeEx(layex, 2)~=0 then
            cardsDetails.dwType = SKGameDef.SK_CT_THREE2
            cardsDetails.Vice = true
            cardsDetails.nStart = self:haveSomeExReverse(layex, 2)
            return SKGameDef.SK_CT_THREE2
        else
            return 0
        end
    elseif 2 == jokers then
        if self:haveSomeEx(layex, 3)~=0 then
            return 0
        elseif self:haveSomeEx(layex, 2)~=0 then
            cardsDetails.dwType = SKGameDef.SK_CT_THREE2
            cardsDetails.bVice = true
            cardsDetails.nStart = self:getTailIndex(layex)
            return SKGameDef.SK_CT_THREE2
        else
            return 0
        end
    elseif 3 == jokers then
        if self:haveSomeEx(layex, 2)~=0 then
            return 0
        else
            return 0
        end
    else
        return 0
    end
    return 0
end


function SKCalculator:getTailIndex(nCardsLayEx)
    for i = SKGameDef.SK_LAYOUT_NUM_EX_1 , 1, -1  do
        if nCardsLayEx[i]~=0 then
            return i
        end
    end
    return 0
end

function SKCalculator:haveSomeEx(nCardsLayEx, some)
    local index = 0
    for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        if some == nCardsLayEx[i] then
            index = i
        end
    end
    return index
end

function SKCalculator:haveSomeExReverse(nCardsLayEx, some)
    local index = 0
    for i = SKGameDef.SK_LAYOUT_NUM_EX_1, 1, -1 do --   for(int i = m_nLayoutNumEx - 1; i >= 0; i--)
        if some == nCardsLayEx[i] then
            index = i
        end
    end
    return index
end

function SKCalculator:isThree2(nCardsLay, cardsDetails)
    local layex={}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isThree2Ex(layex) ~= 0 then
        cardsDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_THREE2)
        cardsDetails.dwType = SKGameDef.SK_CT_THREE2
        return SKGameDef.SK_CT_THREE2
    end
    return 0
end

function SKCalculator:isThree2Ex(nCardsLayEx)
    local sum = self:xygCardRemains(nCardsLayEx)
    if 5 ~= sum then   -- 必须5张。
        return 0
    end
    local layex_2 = {}
    local layex_3 = {}
    self:xygZeroLays(layex_2, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:xygZeroLays(layex_3, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        while true do
            if 0 == nCardsLayEx[i] then
                break
            end
            if 2 == nCardsLayEx[i] then
                layex_2[i] = nCardsLayEx[i]
                break
            elseif 3 == nCardsLayEx[i] then
                layex_3[i] = nCardsLayEx[i]
                break
            else
                return 0
            end
        end
    end
    if self:isCoupleEx(layex_2) ~= 0 and self:isThreeEx(layex_3) ~= 0 then
        return SKGameDef.SK_CT_THREE2
    else
        return 0
    end
end

function SKCalculator:isAbtSingleVice(nCardsLay, cardsDetails, pair)
    if 0 == SKGameDef.SK_JOKER_COUNT then
        return 0
    end

    local lay = {}
    self:copyTable(lay, nCardsLay)

    local sum = self:xygCardRemains(lay)
    if sum < pair then -- 必须pair张以上
        return 0
    end
    local jokers = self:getJokerCount(lay)
    if 0 == jokers then
        return 0
    end
    self:removeJokers(lay)

    local layex={}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(lay, layex)

    for i = 1, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM do
        if 1 ~= layex[i] and 0 ~= layex[i] then
            return 0
        end
    end
    local vacant_index={}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM*2)

    local vacant_size = self:drawVacantIndex(layex, 1, vacant_index)

    if jokers > vacant_size then
        return 0
    end

    local ret = false
    cardsDetails.nStart, ret = self:isAbtWithJokers(jokers, 1, layex, vacant_index, vacant_size, cardsDetails.nStart)

    if ret then
        cardsDetails.dwType = SKGameDef.SK_CT_ABT_SINGLE
        cardsDetails.bVice = true
        return SKGameDef.SK_CT_ABT_SINGLE
    else
        return 0
    end
end

function SKCalculator:isAbtCoupleVice(nCardsLay, cardsDetails, pair)
    if 0 == SKGameDef.SK_JOKER_COUNT then
        return 0
    end

    local lay = {}
    self:copyTable(lay, nCardsLay)

    local sum = self:xygCardRemains(lay)
    if sum < pair*2 or 0 ~= sum % 2 then -- 必须pair张以上
        return 0
    end
    local jokers = self:getJokerCount(lay)
    if 0 == jokers then
        return 0
    end
    self:removeJokers(lay)

    local layex={}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(lay, layex)

    for i = 1, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM do
        if layex[i] >= 3 then
            return 0
        end
    end
    local vacant_index={}
    self:xygZeroLays(vacant_index, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM*2)

    local vacant_size = self:drawVacantIndex(layex, 2, vacant_index)

    if jokers > vacant_size then
        return 0
    end

    local ret = false
    cardsDetails.nStart, ret = self:isAbtWithJokers(jokers, 2, layex, vacant_index, vacant_size, cardsDetails.nStart)

    if ret then
        cardsDetails.dwType = SKGameDef.SK_CT_ABT_COUPLE
        cardsDetails.bVice = true
        return SKGameDef.SK_CT_ABT_COUPLE
    else
        return 0
    end
end

--最后一个参数 传引用 下面都是
function SKCalculator:isAbtWithJokers(jokers, twins, layex, vacant_index, vacant_size, start)
    if 1 == jokers then
        return self:isAbtWithJoker1(twins, layex, vacant_index, vacant_size, start)
    elseif 2 == jokers then
        return self:isAbtWithJoker2(twins, layex, vacant_index, vacant_size, start)
    elseif 3 == jokers then
        return self:isAbtWithJoker3(twins, layex, vacant_index, vacant_size, start)
    elseif 4 == jokers then
        return self:isAbtWithJoker4(twins, layex, vacant_index, vacant_size, start)
    else
        return start, false
    end
end

function SKCalculator:isAbtWithJoker1(twins, layex, vacant_index, vacant_size, start)

    local bResult = false
    for a = 1, vacant_size do
        layex[vacant_index[a]] = layex[vacant_index[a]] + 1
        local begin = 0
        bResult, begin = self:isAbtEx(twins, layex, begin)
        if bResult then
            if begin > start then
                start = begin
            end
        end
        layex[vacant_index[a]] = layex[vacant_index[a]] - 1
    end
    return start, bResult
end

function SKCalculator:isAbtWithJoker2(twins, layex, vacant_index, vacant_size, start)
    local bResult = false
    for a = 1, vacant_size - 1 do
        layex[vacant_index[a]] = layex[vacant_index[a]] + 1
        for b = a + 1, vacant_size do
            layex[vacant_index[b]] = layex[vacant_index[b]] + 1
            local begin = 0
            bResult, begin = self:isAbtEx(twins, layex, begin)
            if bResult then
                if begin > start then
                    start = begin
                end
            end

            layex[vacant_index[b]] = layex[vacant_index[b]] - 1
        end
        layex[vacant_index[a]] = layex[vacant_index[a]] - 1
    end
    return start, bResult
end

function SKCalculator:isAbtWithJoker3(twins, layex, vacant_index, vacant_size,start)
    local bResult = false
    for a = 1, vacant_size - 2 do
        layex[vacant_index[a]] = layex[vacant_index[a]] + 1
        for b = a + 1, vacant_size - 1 do
            layex[vacant_index[b]] = layex[vacant_index[b]] + 1
            for c = b + 1, vacant_size  do
                layex[vacant_index[c]] = layex[vacant_index[c]] + 1
                local begin = 0
                bResult, begin = self:isAbtEx(twins, layex, begin)
                if bResult then
                    if begin > start then
                        start = begin
                    end
                end
                layex[vacant_index[c]] = layex[vacant_index[c]] - 1
            end
            layex[vacant_index[b]] = layex[vacant_index[b]] - 1
        end
        layex[vacant_index[a]] = layex[vacant_index[a]] - 1
    end
    return start, bResult
end

function SKCalculator:isAbtWithJoker4(twins, layex, vacant_index, vacant_size, start)
    local bResult = false
    for a = 1, vacant_size - 3 do
        layex[vacant_index[a]] = layex[vacant_index[a]] + 1
        for b = a + 1, vacant_size - 3 do
            layex[vacant_index[b]] = layex[vacant_index[b]] + 1
            for c = b + 1, vacant_size - 1 do
                layex[vacant_index[c]] = layex[vacant_index[c]] + 1
                for d = c + 1, vacant_size do
                    layex[vacant_index[d]] = layex[vacant_index[d]] + 1
                    local begin = 0
                    bResult, begin = self:isAbtEx(twins, layex, begin)
                    if bResult then
                        if begin > start then
                            start = begin
                        end
                    end

                    layex[vacant_index[d]] = layex[vacant_index[d]] - 1
                end
                layex[vacant_index[c]] = layex[vacant_index[c]] - 1
            end
            layex[vacant_index[b]] = layex[vacant_index[b]] - 1
        end
        layex[vacant_index[a]] = layex[vacant_index[a]] - 1
    end
    return start, bResult
end

function SKCalculator:drawVacantIndex(nCardsLayEx, twins, vacant_index)
    local vacant_size = 0
    for i = 1, SKGameDef.SK_LAYOUT_MOD_1 do
        if nCardsLayEx[i] < twins then
            for j = 1,twins - nCardsLayEx[i] do
                vacant_index[vacant_size] = i
                vacant_size = vacant_size + 1
            end
        end
    end
    return vacant_size
end

function SKCalculator:isAbtSingle(nCardsLay, cardsDetails, pair)
    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isAbtSingleEx(layex, pair) ~= 0 then
        cardsDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_ABT_SINGLE)
        cardsDetails.dwType = SKGameDef.SK_CT_ABT_SINGLE
        return SKGameDef.SK_CT_ABT_SINGLE
    end
    return 0
end

function SKCalculator:isAbtCouple(nCardsLay, cardsDetails, pair)
    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isAbtCoupleEx(layex, pair) ~= 0 then
        cardsDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_ABT_COUPLE)
        cardsDetails.dwType = SKGameDef.SK_CT_ABT_COUPLE
        return SKGameDef.SK_CT_ABT_COUPLE
    end
    return 0
end

function SKCalculator:isAbtThree(nCardsLay, cardsDetails, pair)
    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isAbtThreeEx(layex, pair) ~= 0 then
        cardsDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_ABT_THREE)
        cardsDetails.dwType = SKGameDef.SK_CT_ABT_THREE
        return SKGameDef.SK_CT_ABT_THREE
    end
    return 0
end

function SKCalculator:isAbtSingleEx(nCardsLayEx, pair)
    local sum = self:xygCardRemains(nCardsLayEx)
    if pair * 1 > sum or 0 ~= sum % 1 then -- 必须pair * 1张以上。
        return 0
    end
    local pairs_abt = sum / 1
    local start = 0
    local ret = false
    start,ret = self:isAbuttingEx(nCardsLayEx, pairs_abt, 1, start)
    if ret then
        return SKGameDef.SK_CT_ABT_SINGLE
    else
        return 0
    end
end

function SKCalculator:isAbtCoupleEx(nCardsLayEx, pair)
    local sum = self:xygCardRemains(nCardsLayEx)
    if pair * 2 > sum or 0 ~= sum % 2 then -- 必须pair * 1张以上。
        return 0
    end
    local pairs_abt = sum / 2
    local start = 0
    local ret = false
    start,ret = self:isAbuttingEx(nCardsLayEx, pairs_abt, 2, start)
    if ret then
        return SKGameDef.SK_CT_ABT_COUPLE
    else
        return 0
    end
end

function SKCalculator:isAbtThreeEx(nCardsLayEx, pair)
    local sum = self:xygCardRemains(nCardsLayEx)
    if pair * 3 > sum or 0 ~= sum % 3 then -- 必须pair * 1张以上。
        return 0
    end
    local pairs_abt = sum / 3
    local start = 0
    local ret = false
    start,ret = self:isAbuttingEx(nCardsLayEx, pairs_abt, 3, start)
    if ret then
        return SKGameDef.SK_CT_ABT_THREE
    else
        return 0
    end
end

--最后一个参数 传引用
function SKCalculator:isAbuttingEx(nCardsLayEx, pair, twins, start)

    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:copyTable(layex, nCardsLayEx)

    if not self:checkTwinPairs(layex, pair, twins) then
        return start,false
    end

    start = 0
    local begin = 0
    local gameFlags = GamePublicInterface:getGameFlags()
    if self:IS_BIT_SET(gameFlags, SKGameDef.SK_GF_A23_ABT) then -- A23可以构成顺子
        if layex[13]~=0 then -- 有2
            layex[13] = 0
            pair  = pair - 1
            start = -1
            if layex[12]~=0 then  --有A
                layex[12] = 0
                pair  = pair - 1
                start = -2
            end
            begin = 1
        end
    end
    return start,self:isAbuttingBase(layex, pair, twins, begin)
end

function SKCalculator:isAbuttingBase(nCardsLayEx, pair, twins, begin)
    local gameFlags = GamePublicInterface:getGameFlags()
    if self:IS_BIT_SET(gameFlags, SKGameDef.SK_GF_ABT_A_END) then --  顺子到A为止
        if nCardsLayEx[13]~=0 then  -- 有2
            return false
        end
    end

    if begin~=0 and twins ~= nCardsLayEx[begin] then
        return false
    end

    return self:isAbuttingSmall(nCardsLayEx, pair, twins, begin)
end

function SKCalculator:isAbuttingSmall(nCardsLayEx, pair, twins, begin)
    for i = begin, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        if twins == nCardsLayEx[i] then
            for j = 1, (pair-1) do
                if i + j >= SKGameDef.SK_LAYOUT_NUM_EX_1 then
                    return false
                end
                if twins ~= nCardsLayEx[i + j] then
                    return false
                end
            end
            return true
        end
    end
    return false
end

function SKCalculator:checkTwinPairs(nCardsLayEx, pair, twins)
    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:copyTable(layex, nCardsLayEx)

    local pairs_count = 0
    for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        if twins == layex[i] then
            pairs_count = pairs_count + 1
        elseif 0 ~= layex[i] and twins ~= layex[i] then
            return false

        end
    end
    if pairs_count ~= pair then
        return false
    end
    return true
end

function SKCalculator:isThreeVice(nCardsLay, cardsDetails)
    if 0 == SKGameDef.SK_JOKER_COUNT then
        return 0
    end
    local lay = {}
    self:copyTable(lay, nCardsLay)

    if 3 ~= self:xygCardRemains(lay) then
        return 0
    end

    local jokers = self:getJokerCount(lay)
    if 0 == jokers then
        return 0
    end

    self:removeJokers(lay)

    local cards_details = {}
    --self:zeroTable(cards_details)

    if self:isCouple(lay, cards_details) ~= 0 or self:isSingle(lay, cards_details) ~= 0 then
        cardsDetails.dwType = SKGameDef.SK_CT_THREE
        cardsDetails.bVice = true
        cardsDetails.nStart = self:getStartIndex(lay)
        return SKGameDef.SK_CT_THREE
    end
    return 0
end


function SKCalculator:isCoupleVice(nCardsLay, cardsDetails)

    if 0 ==  SKGameDef.SK_JOKER_COUNT then
        return 0
    end
    local lay = {}
    self:copyTable(lay, nCardsLay)

    if 2 ~= self:xygCardRemains(lay) then
        return 0
    end

    local jokers = self:getJokerCount(lay)
    if 0 == jokers then
        return 0
    end

    self:removeJokers(lay)

    local cards_details = {}
    --self:zeroTable(cards_details)
    if self:isSingle(lay, cards_details) ~= 0 then
        cardsDetails.dwType = SKGameDef.SK_CT_COUPLE
        cardsDetails.bVice = true
        cardsDetails.nStart = self:getStartIndex(lay)
        return SKGameDef.SK_CT_COUPLE
    end
    return 0
end

function SKCalculator:isBombVice(nCardsLay, cardsDetails, twins)
    if 0 == SKGameDef.SK_JOKER_COUNT then
        return 0
    end

    local lay = {}
    self:copyTable(lay, nCardsLay)

    if twins > self:xygCardRemains(lay) then
        return 0
    end
    local jokers = self:getJokerCount(lay)
    if 0 == jokers then
        return 0
    end
    -------------------------------------------------------
    self:removeJokers(lay)

    local cards_details = {}
    --self:zeroTable(cards_details)
    --传引用 第二个参数
    if self:isBomb(lay, cards_details, twins) ~= 0 or self:isThree(lay, cards_details) ~= 0
        or self:isCouple(lay, cards_details) ~= 0 or self:isSingle(lay, cards_details) ~= 0 then
        cardsDetails.dwType = SKGameDef.SK_CT_BOMB
        cardsDetails.bVice = true
        cardsDetails.nStart = self:getStartIndex(lay)
        return SKGameDef.SK_CT_BOMB
    end
    return 0
end

function SKCalculator:getStartIndex(nCardsLay)

    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(nCardsLay, layex)

    return self:getHeadIndex(layex)
end

function SKCalculator:getHeadIndex(nCardsLayEx)
    for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        if 0 ~= nCardsLayEx[i] then
            return i
        end
    end
    return 0
end

function SKCalculator:isSingle(nCardsLay, cardsDetails)

    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isSingleEx(layex) ~= 0 then
        cardsDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_SINGLE)
        cardsDetails.dwType = SKGameDef.SK_CT_SINGLE
        return SKGameDef.SK_CT_SINGLE
    end
    return 0
end

function SKCalculator:isSingleEx(nCardsLayEx)
    if 1 == self:xygCardRemains(nCardsLayEx) then
        return SKGameDef.SK_CT_SINGLE
    end
    return 0
end

function SKCalculator:isCouple(nCardsLay, cardsDetails)

    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isCoupleEx(layex) ~= 0 then
        cardsDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_COUPLE)
        cardsDetails.dwType = SKGameDef.SK_CT_COUPLE
        return SKGameDef.SK_CT_COUPLE
    end
    return 0
end

function SKCalculator:isCoupleEx(nCardsLayEx)
    if 2 == self:xygCardRemains(nCardsLayEx) then
        for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
            if 2 == nCardsLayEx[i] then
                return SKGameDef.SK_CT_COUPLE
            end
        end
    end
    return 0
end

function SKCalculator:isThree(nCardsLay, cardsDetails)
    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isThreeEx(layex) ~= 0 then
        cardsDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_THREE)
        cardsDetails.dwType = SKGameDef.SK_CT_THREE
        return SKGameDef.SK_CT_THREE
    end
    return 0
end

function SKCalculator:isThreeEx(nCardsLayEx)
    if 3 == self:xygCardRemains(nCardsLayEx) then
        for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
            if 3 == nCardsLayEx[i] then
                return SKGameDef.SK_CT_THREE
            end
        end
    end
    return 0
end

function SKCalculator:removeJokers(nCardsLay)
    local count = 0
    for i = 1, SKGameDef.SK_LAYOUT_NUM_1 do
        if nCardsLay[i]~=0 then
            if self:isJokerIndex(i) then
                count = count + nCardsLay[i]
                nCardsLay[i] = 0
            end
        end
    end
    return count
end

function SKCalculator:getJokerCount(nCardsLay)
    local count = 0
    for i = 1, SKGameDef.SK_LAYOUT_NUM_1 do
        if nCardsLay[i]~=0 then
            if self:isJokerIndex(i) then
                count = count + nCardsLay[i]
             end
        end
    end
    return count
end


function SKCalculator:isJokerIndex(index)
    --[[
    for i = 1, SKGameDef.SK_JOKER_COUNT do
        if self.nJokerIndex[i] == index then
            return true
        end
    end
    ]]--
    return false
end

function SKCalculator:isBomb(nCardsLay, cardDetails, twins)
    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(nCardsLay, layex)

    local head, dwType = 0, 0
    head, dwType = self:isBombEx(layex, head, twins)
    if dwType ~= 0 then
        cardDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_BOMB)
        cardDetails.dwType = SKGameDef.SK_CT_BOMB
        return SKGameDef.SK_CT_BOMB
    end
    return 0
end

function SKCalculator:isJokerBomb(nCardsLay, cardDetails)
    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isJokerBombEx(layex) ~= 0 then
        cardDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_JOKER_BOMB)
        cardDetails.dwType = SKGameDef.SK_CT_JOKER_BOMB
        return SKGameDef.SK_CT_JOKER_BOMB
    end
    return 0
end

function SKCalculator:convertCardsLayToEx(nCardsLay, nCardsLayEx)
    local count = 0
    for i = 1, SKGameDef.SK_LAYOUT_NUM_1 do
        if i % SKGameDef.SK_LAYOUT_MOD_1 ~= 0 and 0 ~= nCardsLay[i] then
            count = count + nCardsLay[i]
            if i < (SKGameDef.SK_CS_TOTAL - 1)*SKGameDef.SK_LAYOUT_MOD_1 then
                nCardsLayEx[i%SKGameDef.SK_LAYOUT_MOD_1] = nCardsLayEx[i%SKGameDef.SK_LAYOUT_MOD_1] + nCardsLay[i]
            else
                nCardsLayEx[i%SKGameDef.SK_LAYOUT_MOD_1 + SKGameDef.SK_LAYOUT_MOD_1] = nCardsLayEx[i%SKGameDef.SK_LAYOUT_MOD_1 + SKGameDef.SK_LAYOUT_MOD_1] + nCardsLay[i]
            end
        end
    end
    return count
end

function SKCalculator:isJokerBombEx(nCardsLayEx)
    local sum = self:xygCardRemains(nCardsLayEx)
    if 2*SKGameDef.SK_TOTAL_PACK ~= sum then
        return 0
    end

    if SKGameDef.SK_TOTAL_PACK == nCardsLayEx[SKGameDef.SK_LAYOUT_NUM_EX_1 - 2] and SKGameDef.SK_TOTAL_PACK == nCardsLayEx[SKGameDef.SK_LAYOUT_NUM_EX_1 - 1] then
        return SKGameDef.SK_CT_JOKER_BOMB
    end
    return 0
end

function SKCalculator:getStartCard(nCardsLayEx, dwType)
    local head = 0
    if SKGameDef.SK_CT_JOKER_BOMB == dwType then
        return SKGameDef.SK_LAYOUT_NUM_EX_1
    elseif SKGameDef.SK_CT_THREE2 == dwType then
        head = self:haveSomeEx(nCardsLayEx, 3)
        if self:isJokerIndex(head) then
            return SKGameDef.SK_LAYOUT_MOD_1
        else
            return head
        end
    elseif SKGameDef.SK_CT_BUTTERFLY == dwType then
        head = self:haveSomeEx(nCardsLayEx, 3)
        return head
    elseif SKGameDef.SK_CT_ABT_SINGLE == dwType then
        return self:getStartCardAbt(nCardsLayEx, 1)
    elseif SKGameDef.SK_CT_ABT_COUPLE == dwType then
        return self:getStartCardAbt(nCardsLayEx, 2)
    elseif SKGameDef.SK_CT_ABT_THREE == dwType then
        return self:getStartCardAbt(nCardsLayEx, 3)
    elseif SKGameDef.SK_CT_ABT_BOMB == dwType then
        return self:getStartCardAbt(nCardsLayEx, self:getAbtBombTwins(nCardsLayEx))
    elseif SKGameDef.SK_CT_SINGLE == dwType or SKGameDef.SK_CT_COUPLE == dwType or SKGameDef.SK_CT_THREE == dwType then
        head = self:getHeadIndex(nCardsLayEx)
        if self:isJokerIndex(head) then
            return SKGameDef.SK_LAYOUT_MOD_1
        else
            return head
        end
    elseif SKGameDef.SK_CT_BOMB == dwType then
        local dwType = 0
        head, dwType = self:isBombEx(nCardsLayEx, head, self:getBombTwins(nCardsLayEx))
        if self:isJokerIndex(head) then
            return SKGameDef.SK_LAYOUT_MOD_1
        else
            return head
        end
    end

    return 0
end


function SKCalculator:compareCardEx(nCardID1, nCardID2)

    local CardsDetails1 = {}
    local CardsDetails2 = {}

    local nCardIDs1 = {}
    local nCardIDs2 = {}

    self:xygInitChairCards(nCardIDs1, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    self:xygInitChairCards(nCardIDs2, SKGameDef.SK_MAX_CARDS_PER_CHAIR)

    nCardIDs1[1] = nCardID1
    nCardIDs2[1] = nCardID2

    local dwType1 = self:isValidCardsEx(SKGameDef.SK_MAX_CARDS_PER_CHAIR, nCardIDs1, CardsDetails1)
    local dwType2 = self:isValidCardsEx(SKGameDef.SK_MAX_CARDS_PER_CHAIR, nCardIDs2, CardsDetails2)

    return self:compareCardsEx(SKGameDef.SK_MAX_CARDS_PER_CHAIR, nCardIDs1, CardsDetails1, nCardIDs2, CardsDetails2)
end

-- nCardIDs1: 自己出的牌    nCardIDs2: 上家出的牌
function SKCalculator:compareCardsEx(nCardsLen, nCardIDs1, pCardsDetails1, nCardIDs2, pCardsDetails2)
    local dwType1 = pCardsDetails1.dwType
    local dwType2 = pCardsDetails2.dwType

    if dwType1 ~= SKGameDef.SK_CT_BOMB and dwType1 ~= SKGameDef.SK_CT_JOKER_BOMB and dwType1 ~= SKGameDef.SK_CT_ABT_BOMB then
        if dwType2 ~= SKGameDef.SK_CT_BOMB and dwType2 ~= SKGameDef.SK_CT_JOKER_BOMB and dwType2 ~= SKGameDef.SK_CT_ABT_BOMB then
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

    if SKGameDef.SK_CT_BOMB == dwType1 then
        if SKGameDef.SK_CT_BOMB == dwType2 then
            if self:xygCardRemains(layex1) > self:xygCardRemains(layex2) then
                return 1
            elseif self:xygCardRemains(layex1) < self:xygCardRemains(layex2) then
                return -1
            else
                return self:compareStartCard(pCardsDetails1.nStart, pCardsDetails2.nStart)
            end
        elseif SKGameDef.SK_CT_JOKER_BOMB == dwType2 then
            return -1
        else
            return 1
        end
    elseif SKGameDef.SK_CT_JOKER_BOMB == dwType1 then
        return 1
    else
        if SKGameDef.SK_CT_BOMB == dwType2 then
            return -1
        elseif SKGameDef.SK_CT_JOKER_BOMB == dwType2 then
            return -1
        else
            --assert(dwType1 == dwType2)
            if self:xygCardRemains(layex1) ~= self:xygCardRemains(layex2) then   -- 张数不一样
                return SKGameDef.SK_INVALID_RELATIONSHIP
            end
            return self:compareStartCard(pCardsDetails1.nStart, pCardsDetails2.nStart)
        end
    end
    return SKGameDef.SK_INVALID_RELATIONSHIP
end


function SKCalculator:compareStartCard(start1, start2)
    if start1 > start2 then
        return 1
    elseif start1 < start2 then
        return -1
    else
        return 0
    end
end

function SKCalculator:isAbtEx(twins, layex, begin)
    local bResult = false

    if 1 == twins then
        if self:isAbtSingleEx(layex, self.nAbtPairs[twins]) ~= 0 then
            bResult = true
            begin   = self:getStartCard(layex, SKGameDef.SK_CT_ABT_SINGLE)
        end
    elseif 2 == twins then
        if self:isAbtCoupleEx(layex, self.nAbtPairs[twins]) ~= 0 then
            bResult = true
            begin   = self:getStartCard(layex, SKGameDef.SK_CT_ABT_SINGLE)
        end
    elseif 3 == twins then
        if self:isAbtThreeEx(layex, self.nAbtPairs[twins]) ~= 0 then
            bResult = true
            begin   = self:getStartCard(layex, SKGameDef.SK_CT_ABT_SINGLE)
        end
    elseif 4 <= twins then
        if self:isAbtBombEx(layex, self.nAbtPairs[twins], twins) ~= 0 then
            bResult = true
            begin   = self:getStartCard(layex, SKGameDef.SK_CT_ABT_SINGLE)
        end
    end

    return bResult, begin
end

function SKCalculator:isAbtThreeVice(nCardsLay, cardsDetails, pair)
    if  0 == SKGameDef.SK_JOKER_COUNT then
        return 0
    end

    local lay ={}
    self:xygZeroLays(lay, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    local sum = self:xygCardRemains(lay)
    if sum < pair*3 or 0 ~= sum%3 then
        return 0
    end

    local jokers = self:getJokerCount(lay)
    if 0 == jokers then
        return 0
    end
    self:removeJokers(lay)

    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:convertCardsLayToEx(lay, layex)

    for i = 1, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM do
        if layex[i] >= 4 then
            return 0
        end
    end

    local vacant = {}
    self:xygZeroLays(vacant,SKGameDef.SK_MAX_CARDS_LAYOUT_NUM*2)
    local vacant_size = self:drawVacantIndex(layex, 3, vacant)

    if jokers > vacant_size then
        return 0
    end
	local ret
	cardsDetails.nStart , ret = self:isAbtWithJokers(jokers, 3, layex, vacant, vacant_size, cardsDetails.nStart)
    if  ret then
        cardsDetails.dwType = SKGameDef.SK_CT_ABT_THREE
        cardsDetails.bVice = true
        return SKGameDef.SK_CT_ABT_THREE
    else
        return 0
    end
end

function SKCalculator:isButterFly(nCardsLay, cardDetails, pair)
    local layex = {}
    self:xygZeroLays(layex, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    self:convertCardsLayToEx(nCardsLay, layex)

    if self:isButterFlyEx(layex, pair) ~= 0 then
        cardDetails.nStart = self:getStartCard(layex, SKGameDef.SK_CT_BUTTERFLY)
        cardDetails.dwType = SKGameDef.SK_CT_BUTTERFLY
        return SKGameDef.SK_CT_BUTTERFLY
    end
    return 0
end

function SKCalculator:isButterFlyEx(nCardsLayEx, pair)
    local sum = self:xygCardRemains(nCardsLayEx)
    if pair*5 > sum or 0 ~= sum%5 then
        return 0
    end

    local layex2 = {}
    local layex3 = {}
    self:xygZeroLays(layex2, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)
    self:xygZeroLays(layex3, SKGameDef.SK_MAX_CARDS_LAYOUT_NUM)

    for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        if 0 ~= nCardsLayEx[i] then
            if 2 == nCardsLayEx[i] then
                layex2[i] = nCardsLayEx[i]
            elseif 3 == nCardsLayEx[i] then
                layex3[i] = nCardsLayEx[i]
            else
                return 0
            end
        end
    end

    if self:isAbtCoupleEx(layex2, pair) ~= 0 and self:isAbtThreeEx(layex3, pair) ~= 0 then
        return SKGameDef.SK_CT_BUTTERFLY
    else
        return 0
    end
end

function SKCalculator:isBombEx(nCardsLayEx, head, twins)
    head = 0
    local sum = self:xygCardRemains(nCardsLayEx)
    if twins > sum then
        return head, 0
    end

    local layex = {}
    self:copyTable(layex, nCardsLayEx)

    local gameFlags = GamePublicInterface:getGameFlags()

    for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        if twins <= layex[i] then
            layex[i] = 0
            if 0 == self:xygCardRemains(layex) or 1 == self:xygCardRemains(layex) and self:IS_BIT_SET(gameFlags, SKGameDef.SK_GF_BOMB_SINGLE)then
                head = i
                return head, SKGameDef.SK_CT_BOMB
            else
                return head, 0
            end
        end
    end
    return head,0
end

function SKCalculator:getStartCardAbt(nCardsLayEx, twins)
    local pair = self:xygCardRemains(nCardsLayEx) / twins
    local start = 0
    local ret
    start, ret = self:isAbuttingEx(nCardsLayEx, pair, twins, start)
    if start < 0 then
        return start
    end
    local head = self:getHeadIndex(nCardsLayEx)
    return head
end

function SKCalculator:getBombTwins(nCardsLayEx)
    for i = 1, SKGameDef.SK_LAYOUT_NUM_EX_1 do
        if 0 < nCardsLayEx[i] then
            return nCardsLayEx[i]
        end
    end

    return 4
end

function SKCalculator:getAbtBombTwins(nCardsLayEx)
    local head = self:getHeadIndex(nCardsLayEx)
    return nCardsLayEx[head]
end
--1.0模板牌型算法end

return SKCalculator
