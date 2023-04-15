local NetlessConnect = class("NetlessConnect")

require("src.cocos.cocos2d.bitExtend")

local MyGameReq                             = import("src.app.Game.mMyGame.MyGameReq")

function NetlessTable:create(gameController)
    return NetlessConnect.new(gameController)
end

function NetlessTable:ctor(gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController                    = gameController
end

function NetlessTable:ResetMembers()
    
end

function NetlessTable:StartDeal()
    self:MarkAndRandomSortAllCard()
end

function NetlessTable:MarkAndRandomSortAllCard()
    local card = {}
    local value = {}
    math.randomseed(os.time())
    local s = MyGameReq.MY_TOTAL_CARDS*1000
    for i = 1, MyGameReq.MY_TOTAL_CARDS do
        card[i] = i
        value[i] = math.random(1,s)
    end
    self:SvrReversalMoreByValue(card, value, MyGameReq.MY_TOTAL_CARDS)
end

function NetlessTable:SvrReversalMoreByValue(array, value, length)
    local temp = 0
    for i = 1, length-1 do
        for j = i+1, length do
            if value[i] < value[j] then
                temp=array[i]
                array[i]=array[j]
                array[j]=temp
                temp=value[i]
                value[i]=value[j]
                value[j]=temp
            end
        end
    end
end


return NetlessTable