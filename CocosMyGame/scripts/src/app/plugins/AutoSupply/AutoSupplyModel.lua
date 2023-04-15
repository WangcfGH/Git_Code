local AutoSupplyModel =class('AutoSupplyModel',require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local user = mymodel('UserModel'):getInstance()
local player=mymodel('hallext.PlayerModel'):getInstance()

local treepack = cc.load('treepack')
local json = cc.load("json").json

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(AutoSupplyModel,PropertyBinder)

my.addInstance(AutoSupplyModel)

function AutoSupplyModel:onCreate()
end

function AutoSupplyModel:reset( )
end

function AutoSupplyModel:doSupply(roomInfo)
    local bStartSupply = CacheModel:getCacheByKey("StartSupply" .. tostring(user.nUserID))
    if type(bStartSupply) ~= "boolean" then
        bStartSupply = false
    end
    print("AutoSupplyModel:doSupply begin")
    if not bStartSupply then return end

    local ratioInfo = cc.exports.getAutoSupplyRatioValue()
    local supplyCount = CacheModel:getCacheByKey("SupplyCount" .. roomInfo.nRoomID .. tostring(user.nUserID))
    if type(supplyCount) == "string" and tonumber(supplyCount) > 0 then
        self._supplyCount = tonumber(supplyCount)
    else
        self._supplyCount =  self._roomInfo.nMinDeposit * ratioInfo[tostring(self._roomInfo.nRoomID)]
    end

    local gameDeposit = user.nDeposit
    local safeboxDeposit = user.nSafeboxDeposit

    print("AutoSupplyModel:doSupply  gameDeposit:"..gameDeposit.."safeboxDeposit:"..safeboxDeposit.."self._supplyCount:"..self._supplyCount)

    -- 需取出银两数
    local transDeposit = supplyCount - gameDeposit

    if transDeposit == 0 then 
        return 
    elseif transDeposit > 0 then   --需要补银
        if safeboxDeposit > 0  then
            -- 保险箱银两不足
            if safeboxDeposit < transDeposit then
                transDeposit = 0
                my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = "保险箱银子不足，自动取银失败", removeTime = 2}})
                return
            end
        else
            my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = "保险箱银子不足，自动取银失败", removeTime = 2}})
            return
        end

        if(player:isSafeboxHasSecurePwd() and not player:hasSafeboxGotRndKey())then
            my:informPluginByName('SafeboxPswPlaneCtrl',{})
        else
            player:moveSafeDeposit(transDeposit)
        end

    elseif transDeposit < 0 then   --需要存银  不能超过存银线
        transDeposit = 0 - transDeposit
        local depositLimit = cc.exports.getAutoSupplyDepositLimit()
        printf("doSupply of save depositLimit:%d", depositLimit)
        if self._supplyCount > depositLimit then
            player:transferSafeDeposit(transDeposit)
        else
            if (gameDeposit - depositLimit) > 0 then
                player:transferSafeDeposit(gameDeposit - depositLimit)
            end
        end
    end
        
end

function AutoSupplyModel:isAlive( )
    return self._bAlive
end

function AutoSupplyModel:setAlive(bAlive)
    self._bAlive = bAlive
end

return AutoSupplyModel