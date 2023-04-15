local MyGameCardMakerInfo = class("MyGameCardMakerInfo")
my.addInstance(MyGameCardMakerInfo)

local MyCalculator                  = import("src.app.Game.mMyGame.MyCalculator")


function MyGameCardMakerInfo:ctor()
    self:resert()
end

function MyGameCardMakerInfo:onPutInMyselfCards(cardsID, chairNo)
    if not chairNo or not cardsID then
        print("MyGameCardMakerInfo:onPutInMyselfCards")
        return
    end
    local realChairNo = chairNo + 1
    for i=1, #cardsID do
        local card = cardsID[i]
        if card == -1 then 
            break
        end
        local index = MyCalculator:getCardIndex(card)
        local test = self.ThrowCardByIndex[index]
        self.ThrowCardByIndex[index] = self.ThrowCardByIndex[index] - 1
        
        table.insert( self.ThrowCardsByChairNo[realChairNo], card)
    end
end
function MyGameCardMakerInfo:onThrowCards(cardsID, chairNo)
    if not chairNo or not cardsID then
        print("MyGameCardMakerInfo:onThrowCards")
        return
    end
    local realChairNo = chairNo + 1
    for i=1, #cardsID do
        local card = cardsID[i]
        if card == -1 then 
            break
        end
        local index = MyCalculator:getCardIndex(card)
        self.ThrowCardByIndex[index] = self.ThrowCardByIndex[index] - 1

        table.insert( self.ThrowCardsByChairNo[realChairNo], card)
    end
end
--[[
function MyGameCardMakerInfo:setGamecontroller(Gamecontroller)
    if not self.Gamecontroller and Gamecontroller then
        self.Gamecontroller = Gamecontroller
    end
end
--]]

function MyGameCardMakerInfo:resert()
    self.ThrowCardsByChairNo = {{},{},{},{}}
    self.ThrowCardByIndex = {8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 2, 2}
end

-- 自己的牌加一，index减一
function MyGameCardMakerInfo:ope_CardsAdd(chairNo, carsID)
    local realChairNo = chairNo + 1
    table.insert(self.ThrowCardsByChairNo[realChairNo], carsID)
    local index = MyCalculator:getCardIndex(carsID)
    self.ThrowCardByIndex[index] = self.ThrowCardByIndex[index] - 1
end

-- 自己的牌减一，index加一
function MyGameCardMakerInfo:ope_CardsSub(chairNo, carsID)
    local realChairNo = chairNo + 1
    for i=1, #self.ThrowCardsByChairNo[realChairNo] do
        local itemCard = self.ThrowCardsByChairNo[realChairNo][i]
        if itemCard == carsID then
            table.remove( self.ThrowCardsByChairNo[realChairNo], i)
            local index = MyCalculator:getCardIndex(carsID)
            self.ThrowCardByIndex[index] = self.ThrowCardByIndex[index] + 1
            break
        end
    end
end
return MyGameCardMakerInfo
