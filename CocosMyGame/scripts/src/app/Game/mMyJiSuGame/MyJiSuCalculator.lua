local MyJiSuCalculator = class("MyJiSuCalculator", import("src.app.Game.mMyGame.MyCalculator"))
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")
local GamePublicInterface = import("src.app.Game.mMyGame.GamePublicInterface")

local DunCardCounts = {
    MyJiSuGameDef.FIRST_DUN_CARD_COUNT,
    MyJiSuGameDef.SECOND_DUN_CARD_COUNT,
    MyJiSuGameDef.THIRD_DUN_CARD_COUNT,
}

function MyJiSuCalculator:calcWhichDunCanAccept(cardsOrigin, cardsDest, cardsCount)
    local result = {
        [1]=false,
        [2]=false,
        [3]=false,
    }
    if cardsCount <= 0 then
        return result
    end
    
    for i = 1, 3 do
        local dunCards = clone(cardsOrigin)
        --向每一墩中加入cardsDest
        for j = 1, #cardsDest do
            table.insert(dunCards[i], cardsDest[j])
        end
        --判断是否符合规则
        local bValid = self:checkDunCardsCountValid(dunCards)
        --加入到result中
        result[i] = bValid
    end

    return result
end

--张数检测
function MyJiSuCalculator:checkDunCardsCountValid(dunCards)
    for i = 1, 3 do
        if #dunCards[i] > DunCardCounts[i] then
            return false
        end
    end
    
    return true
end 

--大小检测
function MyJiSuCalculator:checkDunCardsValueValid(dunUniteTypes)
    for i = 1, 3 do
        for j = i + 1, 3 do
            if dunUniteTypes[i] and dunUniteTypes[j] then
                local nResult = self:compareDunUniteType(dunUniteTypes[i], dunUniteTypes[j])
                if nResult > 0 then --左边的墩应该小于等于右边的墩
                    return false
                end
            end
        end
    end

    return true
end

--牌型从小到大排序
local CardTypes = {
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_SINGLE] = 1,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_COUPLE] = 2,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE] = 3,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE] = 4,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE] = 5,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_THREE] = 6,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE] = 7,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB] = 8,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN] = 9,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB] = 10,
    [MyJiSuGameDef.SK_CARD_UNITE_TYPE_4KING] = 11,
}

--比较两墩牌的大小，-1 0 1分别是 左边 小于等于大于 右边
function MyJiSuCalculator:compareDunUniteType(leftUniteTypes, rightUniteTypes)
    local nResult = -1
    for i = 1, 8 do --最多8个牌型
        local valueLeft = leftUniteTypes[i] and 1 or 0
        local valueRight = rightUniteTypes[i] and 1 or 0

        nResult = valueLeft - valueRight
        if nResult ~= 0 or (valueLeft == 0 and valueRight == 0) then
            break
        end

        if CardTypes[leftUniteTypes[i].dwCardType] > CardTypes[rightUniteTypes[i].dwCardType] then
            nResult = 1
        elseif CardTypes[leftUniteTypes[i].dwCardType] == CardTypes[rightUniteTypes[i].dwCardType] then
            nResult = leftUniteTypes[i].nMainValue - rightUniteTypes[i].nMainValue
            nResult = nResult > 0 and 1 or nResult
            nResult = nResult < 0 and -1 or nResult
        else
            nResult = -1
        end
        if nResult ~= 0 then
            break
        end
    end
    return nResult
end 

--根据所给cardid，找出所有牌的类型
function MyJiSuCalculator:getDunUniteType(cardIDs)
    local uniteTypes = {}
    local nInCards = clone(cardIDs)
    repeat
        local unite = self:initUniteType()
        local remindCardIDs = {}
        local nInCardLen = #nInCards
        if nInCardLen <= 0 then
            break
        end
        local bFind = self:ope_BuildMaxCard(nInCards,nInCardLen,remindCardIDs,nInCardLen,unite,unite,MyJiSuGameDef.SK_CARD_UNITE_TYPE_TOTAL,true)
        if bFind then
            table.insert(uniteTypes, clone(unite))
            for i=1, #remindCardIDs do
                table.removebyvalue(nInCards, remindCardIDs[i])
            end
        else
            printError("error getDunUniteType not find")
            dump(nInCards, "cardIDs:")
            break
        end
    until(false)
    
    return uniteTypes
end

--根据所给cardid，找出所有牌的类型，增加nOutCardLen用处，用来限制找出的牌型最多为多少张
function MyJiSuCalculator:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, dwUniteSupport, bnUseJoker)
    local remindUniteType = MyJiSuCalculator:initUniteType()
    local remindCards = {}
    local lastRemindUniteTypeList = {}
    local lastOutCardsList = {}
    
    repeat
        local bReClick = self:ope_BuildCard(nInCards, nInCardLen, remindCards, nInCardLen, remindUniteType, remindUniteType, dwUniteSupport, bnUseJoker)
        if not bReClick then
            break
        else
            -- 用于张数限制
            table.insert(lastRemindUniteTypeList, clone(remindUniteType))
            table.insert(lastOutCardsList, clone(remindUniteType.nCardIDs))
        end
    until (false)

    if #lastRemindUniteTypeList > 0 then --存在该类型的牌
        for i = #lastRemindUniteTypeList, 1, -1 do
            if lastRemindUniteTypeList[i].nCardsCount <= nOutCardLen then
                MyJiSuCalculator:copyTable(out_type, lastRemindUniteTypeList[i])
                MyJiSuCalculator:copyCardIDs(nOutCards, lastOutCardsList[i])
                return true
            end
        end
    end

    return false
end

--获取当前类型的所有牌型，从大到小排列
function MyJiSuCalculator:getBiggestUniteTypeList(nInCards, nInCardLen, dwUniteSupport, bnUseJoker)
    local remindUniteType = MyJiSuCalculator:initUniteType()
    local remindCards = {}
    local lastRemindUniteTypeList = {}
    local lastOutCardsList = {}
    
    repeat
        local bReClick = self:ope_BuildCard(nInCards, nInCardLen, remindCards, nInCardLen, remindUniteType, remindUniteType, dwUniteSupport, bnUseJoker)
        if not bReClick then
            break
        else
            table.insert(lastRemindUniteTypeList, clone(remindUniteType))
            table.insert(lastOutCardsList, clone(remindUniteType.nCardIDs))
        end
    until (false)

    return lastRemindUniteTypeList, lastOutCardsList
end

--nOutCardLen参数用来限制找出的牌型张数，找出的牌型张数不得大于该值
function MyJiSuCalculator:ope_BuildMaxCard(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, dwUniteSupport, bnUseJoker)
    local gameFlags = GamePublicInterface:getGameFlags()

    local lay = {}
    MyJiSuCalculator:xygZeroLays(lay, MyJiSuGameDef.SK_LAYOUT_NUM)

    local jokerCount = MyJiSuCalculator:preDealCards(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, MyJiSuGameDef.SK_GF_USE_JOKER)
    if not bnUseJoker then
        jokerCount = 0
    end

    MyJiSuCalculator:copyTable(out_type, in_type)

    local flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_4KING
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_4KING) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) and 
    MyJiSuCalculator:getCardType_4King(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM ,jokerCount , out_type, 4) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_SUPER_BOMB
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB, bnUseJoker) then
            return true
        end
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_TONGHUASHUN
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN, bnUseJoker) then
            return true
        end
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_BOMB
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB, bnUseJoker) then
            return true
        end
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE, bnUseJoker) then
            return true
        end
    end   

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_THREE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_THREE) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_THREE, bnUseJoker) then
            return true
        end
    end


    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE, bnUseJoker) then
            return true
        end
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_THREE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE, bnUseJoker) then
            return true
        end
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_THREE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE, bnUseJoker) then
            return true
        end
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_COUPLE) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_COUPLE, bnUseJoker) then
            return true
        end
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_SINGLE) and 
    self:IS_BIT_SET(flags, in_type.dwCardType) then
        if self:getBiggestUniteType(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, MyJiSuGameDef.SK_CARD_UNITE_TYPE_SINGLE, bnUseJoker) then
            return true
        end
    end

    return false
end

--从handcardmanager中复制过来
function MyJiSuCalculator:ope_BuildCard(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, dwUniteSupport, bnUseJoker)
    local gameFlags = GamePublicInterface:getGameFlags()

    local lay = {}
    MyJiSuCalculator:xygZeroLays(lay, MyJiSuGameDef.SK_LAYOUT_NUM)

    local jokerCount = MyJiSuCalculator:preDealCards(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, MyJiSuGameDef.SK_GF_USE_JOKER)
    if not bnUseJoker then
        jokerCount = 0
    end

    MyJiSuCalculator:copyTable(out_type, in_type)

    local flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_SINGLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_Single(nInCards, nInCardLen, out_type) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_Couple(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_THREE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_Three(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_THREE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_Three_CoupleEx(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, MyJiSuGameController._baseGameUtilsInfoManager:getWaitUniteInfo()) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end
    
    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_ABT_Single(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 5) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_ABT_Couple(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 3) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end   

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_THREE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_THREE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_ABT_Three(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 2) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_BOMB
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB)
                and self:IS_BIT_SET(flags, in_type.dwCardType) then
        for i = 4, 5 do        
            if MyJiSuCalculator:getCardType_Bomb(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
                MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
                return true
            end
        end
    end
    
    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_TONGHUASHUN
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_TongHuaShun(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 5) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_SUPER_BOMB
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB)
                and self:IS_BIT_SET(flags, in_type.dwCardType) then
        for i = 6, 8 do       --急速掼蛋最多8炸
            if MyJiSuCalculator:getCardType_SuperBomb(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
                MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
                return true
            end
        end
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_4KING
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_4KING)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_4King(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM ,jokerCount , out_type, 4) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    return false
end

function MyJiSuCalculator:autoSetCards(cardIDs, cardsCount)
    if cardsCount ~= 18 then
       return
    end
    -- assert(cardsCount == 18)
    local dunCardIDs = {}
    local nInCards = clone(cardIDs)
    for i = 1, 3 do
        dunCardIDs[4-i] = {}
        local remindCards = {}
        local nInCardLen = #nInCards
        local remindUniteType = self:initUniteType()
        self:ope_BuildMaxCard(nInCards, nInCardLen, remindCards, DunCardCounts[4-i], remindUniteType, remindUniteType, MyJiSuGameDef.SK_CARD_UNITE_TYPE_TOTAL, true)
        for j=1, #remindUniteType.nCardIDs do
            table.removebyvalue(nInCards, remindUniteType.nCardIDs[j])
        end
        for j=1,#remindCards do
            if remindCards[j]~= -1 then
                table.insert(dunCardIDs[4-i], remindCards[j])
            end    
        end
    end
    for i = 3, 1, -1 do
        while #dunCardIDs[i] < DunCardCounts[i] do
            local remindCards = {}
            local nInCardLen = #nInCards
            local remindUniteType = self:initUniteType()
            self:ope_BuildMaxCard(nInCards, nInCardLen, remindCards, DunCardCounts[i] - #dunCardIDs[i], remindUniteType, remindUniteType, MyJiSuGameDef.SK_CARD_UNITE_TYPE_TOTAL, true)
            for j=1, #remindUniteType.nCardIDs do
                table.removebyvalue(nInCards, remindUniteType.nCardIDs[j])
            end
            for j=1,#remindCards do
                if remindCards[j]~= -1 then
                    table.insert(dunCardIDs[i], remindCards[j])
                end    
            end
        end
    end
    return dunCardIDs
end

return MyJiSuCalculator