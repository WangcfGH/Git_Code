local ArenaRankData = class("ArenaRankData")
local User = mymodel('UserModel'):getInstance()
local ArenaRankConfig =  cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ArenaRank.json"))
local ArenaPropConfig         = require("src.app.HallConfig.ArenaPropConfig")
local RewardTipDef       = import("src.app.plugins.RewardTip.RewardTipDef")

my.addInstance(ArenaRankData)

local event = cc.load('event')
event:create():bind(ArenaRankData)

ArenaRankData.ARENA_RANK_INFO_UPDATED = "ARENA_RANK_INFO_UPDATED"
ArenaRankData.ARENA_RANK_SIGN_UP_OK = "ARENA_RANK_SIGN_UP_OK"
ArenaRankData.ARENA_RANK_GET_REWARD_LIST_OK = "ARENA_RANK_GET_REWARD_LIST_OK"

ArenaRankData.ARENA_PROP_GET_LIST_OK = "ARENA_PROP_GET_LIST_OK"
ArenaRankData.ARENA_PROP_BUY_OK = "ARENA_PROP_BUY_OK"

ArenaRankData.DATA_AVAILABLE_TIME = 0  --单位秒

--状态
ArenaRankData.STATUS_NOT_SIGN_UP = "STATUS_NOT_SIGN_UP"
ArenaRankData.STATUS_SIGN_UP = "STATUS_SIGN_UP"
ArenaRankData.STATUS_NOT_REWARD = "STATUS_NOT_REWARD" --可以领奖但是没有领
ArenaRankData.STATUS_REWARD = "STATUS_REWARD" --已经领奖
ArenaRankData.STATUS_ERROR = "STATUS_ERROR"

--ͬArenaRank.json, prizeID
ArenaRankData.TYPE_SILVER = 1
ArenaRankData.TYPE_EXCHANGE = 2
ArenaRankData.TYPE_CARDMASTER = 3

function ArenaRankData:ctor() 
    self._rewardList = ArenaRankConfig["GroupReward"] or {} --默认为本地配置,配置文件的PrizeList的prizeID必须与服务器一致(CSV文件)
    self._matchConfig = {}
    self._rewardGetForServer = false
    self:resetData()
end

function ArenaRankData:resetData()
    self._data = {      
        ["rank"] = nil,  
        ["score"] = nil,
        ["status"] = nil,
        ["endDate"] = nil,
        ["groupRankList"] = nil
    }
        
    self._userID = nil
    self._lastGetTime = nil
    self._isOpen = false --实时开关
    self._localData = {}

    --道具添加
    self._lastGetPropTime = nil
    self._propList = ArenaPropConfig.ArenaPropList or {}
end

function ArenaRankData:onBuyUserPropOk(data)
    self:onGetUserPropOK(data)

    --my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = ArenaPropConfig["BuyPropSuccess"], removeTime = 2 }})
    self:dispatchEvent({name = ArenaRankData.ARENA_PROP_BUY_OK})
end

function ArenaRankData:onGetUserPropOK(data)
    self._lastGetPropTime = os.time() 
     
    for i = 1, #self._propList do
        self._propList[i].num = 0
        for j = 1, 10 do  --暂定最多10个道具
            if self._propList[i].nType == data.nPropID[j] then
                self._propList[i].num = data.nPropNum[j]
                break
            end
        end
        self._propList[i].price = data.nPropPrice[self._propList[i].nType]
    end

    local propType = {RewardTipDef.TYPE_PROP_JIACHENG, RewardTipDef.TYPE_PROP_BAOXIAN, RewardTipDef.TYPE_PROP_LIANSHENG}
    local propID = tonumber(data.nPropIDCurrent)

    if propID and propType[propID] then  --这里只显示前3种除记牌器之外的道具，记牌器在propmodel里有显示
        local rewardList = {}
        table.insert( rewardList,{nType = propType[propID], nCount = 1})
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
        local player=mymodel('hallext.PlayerModel'):getInstance()
        player:update({'SafeboxInfo'})
    end
    
    self:dispatchEvent({name = ArenaRankData.ARENA_PROP_GET_LIST_OK})
end

function ArenaRankData:onGetRankInfoOK(data)
    self._lastGetTime = os.time() 
    self._userID = data.nUserID
    if data.nOpen == 1 then
        self._isOpen = true
    else
        self._isOpen = false
    end

    if data.nState == 0 then
        self._data["status"] = ArenaRankData.STATUS_NOT_SIGN_UP
    elseif data.nState == 1 then
        self._data["status"] = ArenaRankData.STATUS_SIGN_UP
    elseif data.nState == 2 then
        self._data["status"] = ArenaRankData.STATUS_NOT_REWARD
    elseif data.nState == 3 then
        self._data["status"] = ArenaRankData.STATUS_REWARD
    elseif data.nState == 10 then
        self._data["status"] = ArenaRankData.STATUS_ERROR
    end

    --日期 data.nEndDate:2016092912
    self._data["endDate"] = {}
    self._data["endDate"].year = tonumber(string.sub(tostring(data.nEndDate), 1, 4))
    self._data["endDate"].month = tonumber(string.sub(tostring(data.nEndDate), 5, 6))
    self._data["endDate"].day = tonumber(string.sub(tostring(data.nEndDate), 7, 8))
    self._data["endDate"].hour = tonumber(string.sub(tostring(data.nEndDate), 9, 10)) 
       
    self._data["groupRankList"] = {}
    self._data["rank"] = data.nSortID 
    self._data["score"] = data.nRankScore
    for index, player in ipairs(data.stSingleRankInfos) do               
        local tPlayer = {}
        tPlayer["userID"] = player.nUserID        
        tPlayer["userName"] = player.szUserName
        tPlayer["userName"] = MCCharset:getInstance():gb2Utf8String(tPlayer["userName"], string.len(tPlayer["userName"]))
        tPlayer["score"] = player.nRankScore
        tPlayer["rank"] = index
        --[[ 新排行榜 分数相同，按时间先后排名
        if index > 1 and self._data["groupRankList"][index - 1].score == tPlayer["score"] then
            tPlayer["rank"] = self._data["groupRankList"][index - 1].rank
        end 
        ]]--
        if player.nUserID == self._userID then
            self._data["rank"] = tPlayer["rank"]  
            self._data["score"] = tPlayer["score"]      
        end                
        table.insert(self._data["groupRankList"], tPlayer)        
    end

    --[[ -- 新排行榜不用 2018年11月14日 wuym
    if self._data["status"] == ArenaRankData.STATUS_NOT_REWARD then --只有在可以领奖的时候，data.nSortID和data.nRankScore这两个字段有效
        self._data["rank"] = data.nSortID 
        self._data["score"] = data.nRankScore
    end
    ]]--
    dump(self._data)

    self:dispatchEvent({name = ArenaRankData.ARENA_RANK_INFO_UPDATED})
end

function ArenaRankData:onGetRewardListOK(data)
    self._rewardList = {}     
    for i, listItem in ipairs(data.stListItem) do
        self._rewardList[i] = {}
        self._rewardList[i]["rankBegin"] = listItem.nRankBegin
        self._rewardList[i]["rankEnd"] = listItem.nRankEnd
        self._rewardList[i]["prizeList"] = {}
        for j, rewardItem in ipairs(listItem.stReward) do            
            local reward = {}
            reward["prizeID"] = rewardItem.nPrizeID
            reward["count"] = rewardItem.nNum
            table.insert(self._rewardList[i]["prizeList"], reward)
        end
    end
    self._rewardGetForServer = true

    self:dispatchEvent({name = ArenaRankData.ARENA_RANK_GET_REWARD_LIST_OK}) 
end

function ArenaRankData:onSignUpOK(data)
    self:onGetRankInfoOK(data)
    self:dispatchEvent({name = ArenaRankData.ARENA_RANK_SIGN_UP_OK}) 
end

function ArenaRankData:isDataAvailable()
    if self._userID
        and self._userID == User.nUserID
        and self._data["status"]
        and self._data["rank"]
        and self._data["score"]        
        and self._data["endDate"]
        and self._data["groupRankList"] then
        return true
    end

    return false
end

function ArenaRankData:isDataInAvailableTime()
    local curTime = os.time()
    local isInAvailableTime = false
    if self._lastGetTime and curTime - self._lastGetTime <= ArenaRankData.DATA_AVAILABLE_TIME then
        isInAvailableTime = true
    end

    return isInAvailableTime
end

function ArenaRankData:request()
    local ArenaModel = require('src.app.plugins.arena.ArenaModel'):getInstance()
    if not self:isMoveRankDataCacheExists()  then -- 不存在搬迁数据的缓存，就发消息搬迁
        if nil == self._sendMoveOnce then    -- 用来控制只发送该消息一次（因为缓存在部分机型可能失效，故这里用缓存+内存双重控制）
            ArenaModel:sendMoveMyArenaRankData()
        end
    end
    if not self:isDataAvailable() 
        or not self:isDataInAvailableTime() then
        ArenaModel:sendGetArenaRankState()
    end

    local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
    if not self:isPropDataAvailable() 
        or not self:isPropDataInAvailableTime() then
        PropModel:sendGetUserPropInfo()
    end
end

function ArenaRankData:requestBuyPropItem(id)
    local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
    PropModel:sendBuyUserProp(id)
end

function ArenaRankData:isPropDataAvailable()
    if self._propList then
        return true
    end

    return false
end

function ArenaRankData:isPropDataInAvailableTime()
    local curTime = os.time()
    local isInAvailableTime = false
    if self._lastGetPropTime and curTime - self._lastGetPropTime <= ArenaRankData.DATA_AVAILABLE_TIME then
        isInAvailableTime = true
    end

    return isInAvailableTime
end

function ArenaRankData:requestRewardList()
    local ArenaModel = require('src.app.plugins.arena.ArenaModel'):getInstance()

    if not self._rewardGetForServer then
        ArenaModel:sendGetArenaRankRewardList()
    end
end

function ArenaRankData:setStatus(status)
    self._data["status"] = status
end

function ArenaRankData:getStatus()
    return self._data["status"] 
end

function ArenaRankData:getSelfRank()
    return self._data["rank"]
end

function ArenaRankData:getSelfScore()
    return self._data["score"]
end

function ArenaRankData:getGroupRankList()
    return self._data["groupRankList"]
end

function ArenaRankData:getEndDate()
    return self._data["endDate"]
end

function ArenaRankData:getRewardList()
    return self._rewardList
end

function ArenaRankData:isOpen()
    return self._isOpen
end 

function ArenaRankData:getCacheFileName()
    local User = mymodel('UserModel'):getInstance()
    if User.nUserID == nil then
        return 
    end

    return User.nUserID .. "_ArenaRankData.xml"
end

function ArenaRankData:read()
    local fileName = self:getCacheFileName()
    if fileName == nil then
        return false
    end
    
    if not my.isCacheExist(fileName) then
        return false         
    end

    local data = my.readCache(fileName)
    data = checktable(data)
    self._localData.signUpCount = data.signUpCount or 0

    return true
end

function ArenaRankData:save()
    local fileName = self:getCacheFileName()
    if fileName == nil then
        return 
    end

    self._localData = checktable(self._localData) 
       
    my.saveCache(fileName, self._localData)
end

function ArenaRankData:getSignUpCount()
    return self._localData.signUpCount or 0
end

function ArenaRankData:setSignUpCount(count)
    self._localData.signUpCount = count
end

function ArenaRankData:addSignUpCount(addNum)
    if self._localData.signUpCount == nil then
        self._localData.signUpCount = 0
    end

    self._localData.signUpCount = self._localData.signUpCount + addNum
end

function ArenaRankData:setMoveFlagToCache(nFlag)
    self._sendMoveOnce = true   -- 迁移消息响应时，设置内存控制变量
    self._localData.RankScoreIsMoved = nFlag -- 迁移消息响应时，设置缓存控制变量
    if self._localData.signUpCount == nil then
        self._localData.signUpCount = 0
    end
    self:save()
end

function ArenaRankData:isMoveRankDataCacheExists()
    local fileName = self:getCacheFileName()
    if fileName == nil then
        return false
    end
    
    if not my.isCacheExist(fileName) then
        return false         
    end

    local data = my.readCache(fileName)
    data = checktable(data)
    if data.RankScoreIsMoved ~= nil then
        return true
    end

    return false
end

function ArenaRankData:setMatchConfig(config)
    self._matchConfig = config
end

function ArenaRankData:getMatchConfig()
    return self._matchConfig
end

return ArenaRankData