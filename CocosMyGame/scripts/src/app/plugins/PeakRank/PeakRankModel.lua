local PeakRankModel = class('PeakRankModel', require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local UserModel = mymodel('UserModel'):getInstance()
local PeakRankDef = import('src.app.plugins.PeakRank.PeakRankDef')
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

my.addInstance(PeakRankModel)
my.setmethods(PeakRankModel, cc.load('coms').PropertyBinder)

protobuf.register_file('src/app/plugins/PeakRank/pbPeakRank.pb')

PeakRankModel.EVENT_ON_CONFIG_RSP = 'EVENT_ON_CONFIG_RSP'
PeakRankModel.EVENT_ON_PEAKRANKINFO_RSP = 'EVENT_ON_PEAKRANKINFO_RSP'
PeakRankModel.EVENT_ON_PEAKRANKTOTALVALUE_RSP = 'EVENT_ON_PEAKRANKTOTALVALUE_RSP'
PeakRankModel.EVENT_PEAKRANK_UPDATE_REDDOT = 'EVENT_PEAKRANK_UPDATE_REDDOT'

function PeakRankModel:onCreate()
    self._config = nil

    self._actStartDate = 0
    self._actEndDate = 0

    self._roundStartDate = 0
    self._roundEndDate = 0

    -- 以下是 rankType_dayType_areaType 为key的表
    self._rankData = {}
    self._selfRankInfo = {}
    self._rankTotalValue = {}
    self._lastQueryTime = {}
    self._isNewRound = false
    
    self:initAssistResponse()
    self:initEventListener()
end

function PeakRankModel:initAssistResponse()
    self._assistResponseMap = {
        [PeakRankDef.GR_PEAK_RANK_QUERY_CONFIG] = handler(self, self.onPeakRankConfigRsp),
        [PeakRankDef.GR_PEAK_RANK_QUERY_ITEMS_INFO] = handler(self, self.onPeakRankInfoRsp),
        [PeakRankDef.GR_PEAK_RANK_QUERY_TOTAL_VALUE] = handler(self, self.onPeakRankTotalValueRsp)
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function PeakRankModel:initEventListener()
    self:listenTo(MyTimeStamp, MyTimeStamp.UPDATE_DAY,  handler(self,self.updateDay))
end
 
function PeakRankModel:updateDay()
    self:reqPeakRankConfig()
end

function PeakRankModel:reqPeakRankConfig()
    print('PeakRankModel:reqPeakRankConfig()')

    local data = {
        userid = UserModel.nUserID
    }

    local pData = protobuf.encode('pbPeakRank.ReqPeakRankConfig', data)
    AssistModel:sendData(PeakRankDef.GR_PEAK_RANK_QUERY_CONFIG, pData, false)
end

function PeakRankModel:onPeakRankConfigRsp(data)
    self._config = nil
    local json = cc.load("json").json

    -- 更新本地数据
    self._config = json.decode(data)
    dump(self._config, 'PeakRankModel:onPeakRankConfigRsp')

    self._actStartDate = self._config.StartDate
    self._actEndDate = self._config.EndDate

    self._roundStartDate = self._config.RoundStartDate
    self._roundEndDate = self._config.RoundEndDate

    self:checkIsNewRound()

    -- 派发事件
    self:dispatchEvent({name = PeakRankModel.EVENT_ON_CONFIG_RSP})
end

function PeakRankModel:reqPeakRankInfo(rankType, dayType, areaType)
    print(string.format('PeakRankModel:reqPeakRankInfo rankType = %d, dayType = %d, areaType = %d', rankType, dayType, areaType))
    local statisticsType, listType, beforeStage = self:convertClientParams2ServerParams(rankType, dayType, areaType)
    if not statisticsType or not listType or not beforeStage then
        return
    end
    print(string.format('PeakRankModel:reqPeakRankInfo statisticsType = %d, listType = %d, beforeStage = %d', statisticsType, listType, beforeStage))
    local params = {
        userid = UserModel.nUserID,
        statisticsType = statisticsType,
        listType = listType,
        beforeStage = beforeStage
    }
    local pData = protobuf.encode('pbPeakRank.ReqPeakRankInfo', params)
    AssistModel:sendData(PeakRankDef.GR_PEAK_RANK_QUERY_ITEMS_INFO, pData, false)
end

function PeakRankModel:onPeakRankInfoRsp(data)
    if string.len(data) == nil then
        return nil
    end

    local pData = protobuf.decode('pbPeakRank.RespPeakRankInfo', data)
    protobuf.extract(pData)

    dump(pData, 'PeakRankModel:onPeakRankInfoRsp')

    local rankType, dayType, areaType = self:convertServerParams2ClientParams(pData.statisticsType, pData.listType, pData.beforeStage)
    if not rankType or not dayType or not areaType then
        return
    end

    -- 更新本地数据
    self._roundStartDate = pData.roundStartDate
    self._roundEndDate = pData.roundEndDate
    local key = self:getRankDataKey(rankType, dayType, areaType)
    self._rankData[key] = clone(pData.rankItems)
    self._selfRankInfo[key] = {rankValue = pData.selfValue, rankNo = pData.selfRankNo}
    self._rankTotalValue[key] = pData.totalValue
    self._lastQueryTime[key] = os.time()

    -- 派发事件
    local event = PeakRankModel.EVENT_ON_PEAKRANKINFO_RSP
    local value = {
        rankType = rankType,
        dayType = dayType,
        areaType = areaType
    }
    self:dispatchEvent({name = event, value = value})
end

function PeakRankModel:reqPeakRankTotalValue(rankType, dayType, areaType)
    print(string.format('PeakRankModel:reqPeakRankTotalValue rankType = %d, dayType = %d, areaType = %d', rankType, dayType, areaType))
    local statisticsType, listType, beforeStage = self:convertClientParams2ServerParams(rankType, dayType, areaType)
    if not statisticsType or not listType or not beforeStage then
        return
    end
    print(string.format('PeakRankModel:reqPeakRankTotalValue statisticsType = %d, listType = %d, beforeStage = %d', statisticsType, listType, beforeStage))
    local params = {
        userid = UserModel.nUserID,
        statisticsType = statisticsType,
        listType = listType,
        beforeStage = beforeStage
    }
    local pData = protobuf.encode('pbPeakRank.ReqPeakRankTotalValue', params)
    AssistModel:sendData(PeakRankDef.GR_PEAK_RANK_QUERY_TOTAL_VALUE, pData, false)
end

function PeakRankModel:onPeakRankTotalValueRsp(data)
    if string.len(data) == nil then
        return nil
    end

    local pData = protobuf.decode('pbPeakRank.RespPeakRankTotalValue', data)
    protobuf.extract(pData)

    dump(pData, 'PeakRankModel:onPeakRankTotalValueRsp')

    local rankType, dayType, areaType = self:convertServerParams2ClientParams(pData.statisticsType, pData.listType, pData.beforeStage)
    if not rankType or not dayType or not areaType then
        return
    end

    -- 更新本地数据
    local key = self:getRankDataKey(rankType, dayType, areaType)
    self._rankTotalValue[key] = pData.totalValue

    -- 派发事件
    local event = PeakRankModel.EVENT_ON_PEAKRANKTOTALVALUE_RSP
    local value = {
        rankType = rankType,
        dayType = dayType,
        areaType = areaType
    }
    self:dispatchEvent({name = event, value = value})
end

function PeakRankModel:getRankDataKey(rankType, dayType, areaType)
    return string.format("%d_%d_%d", rankType, dayType, areaType)
end

function PeakRankModel:isEnable()
    if not self._config then
        return false
    end

    if self._config.Enable ~= 1 then
        return false
    end

    local todayDate = tonumber(os.date("%Y%m%d", os.time()))
    if todayDate < self._actStartDate then
        return false
    end

    if todayDate > self._actEndDate then
        return false
    end

    return true
end

function PeakRankModel:isRankInfoExpire(rankType, dayType, areaType)
    local lastQueryTime = self:getRankLastQueryTime(rankType, dayType, areaType)
    local queryIntervalMinutes = cc.exports.getPeakRankRankListUpdateInterval()
    return os.time() - lastQueryTime >= queryIntervalMinutes
end

function PeakRankModel:getRankLastQueryTime(rankType, dayType, areaType)
    local key = self:getRankDataKey(rankType, dayType, areaType)
    return self._lastQueryTime[key] or 0
end

function PeakRankModel:getRankDataList(rankType, dayType, areaType)
    local key = self:getRankDataKey(rankType, dayType, areaType)
    return self._rankData[key]
end

function PeakRankModel:getSelfRankInfo(rankType, dayType, areaType)
    local key = self:getRankDataKey(rankType, dayType, areaType)
    return self._selfRankInfo[key]
end

function PeakRankModel:getRankTotalValue(rankType, dayType, areaType)
    local key = self:getRankDataKey(rankType, dayType, areaType)
    return self._rankTotalValue[key] or 0
end

function PeakRankModel:getRoundStartDate()
    return self._roundStartDate
end

function PeakRankModel:getRoundEndDate()
    return self._roundEndDate
end

function PeakRankModel:getStatisticsTypeByRankType(rankType)
    if rankType >= PeakRankDef.PeakRankRankType.GainTotal
        and rankType <= PeakRankDef.PeakRankRankType.ThumbsUp then
        
        return rankType
    end

    return nil
end

function PeakRankModel:getRankTypeByStatisticsType(statisticsType)
    if statisticsType >= PeakRankDef.STATISTICS_TYPE.GAIN
        and statisticsType <= PeakRankDef.STATISTICS_TYPE.PRAISE then
        return statisticsType
    end

    return nil
end

function PeakRankModel:getListTypeAndBeforeStageByDayTypeAndAreaType(rankType, dayType, areaType)
    if rankType == PeakRankDef.PeakRankRankType.GainTotal
        or rankType == PeakRankDef.PeakRankRankType.GainOnece then
        -- 盈利/胜银
        if dayType == PeakRankDef.PeakRankDayType.Total then
            -- 总榜
            if areaType == PeakRankDef.PeakRankAreaType.Classic then
                -- 经典
                return PeakRankDef.LIST_TYPE.CLASSIC_TOTAL, 0
            elseif areaType == PeakRankDef.PeakRankAreaType.NoShuffle then
                -- 不洗牌
                return PeakRankDef.LIST_TYPE.NOWASH_TOTAL, 0
            end
        elseif dayType == PeakRankDef.PeakRankDayType.Today then
            -- 今日
            if areaType == PeakRankDef.PeakRankAreaType.Classic then
                -- 经典房
                return PeakRankDef.LIST_TYPE.CLASSIC_DATE, 0
            elseif areaType == PeakRankDef.PeakRankAreaType.NoShuffle then
                -- 不洗牌
                return PeakRankDef.LIST_TYPE.NOWASH_DATE, 0
            end
        elseif dayType == PeakRankDef.PeakRankDayType.YesterDay then
            -- 昨日
            if areaType == PeakRankDef.PeakRankAreaType.Classic then
                -- 经典
                return PeakRankDef.LIST_TYPE.CLASSIC_DATE, 1
            elseif areaType == PeakRankDef.PeakRankAreaType.NoShuffle then
                -- 不洗牌
                return PeakRankDef.LIST_TYPE.NOWASH_DATE, 1
            end
        end
    else
        -- 其他榜单
        if dayType == PeakRankDef.PeakRankDayType.Total then
            -- 总榜
            return PeakRankDef.LIST_TYPE.NORMAL_TOTAL, 0
        elseif dayType == PeakRankDef.PeakRankDayType.Today then
            -- 今日
            return PeakRankDef.LIST_TYPE.NORMAL_DATE, 0
        elseif dayType == PeakRankDef.PeakRankDayType.YesterDay then
            -- 昨日
            return PeakRankDef.LIST_TYPE.NORMAL_DATE, 1
        end
    end

    return nil, nil
end

function PeakRankModel:getDayTypeAndAreaTypeByListTypeAndBeforeStage(listType, beforeStage)
    if listType == PeakRankDef.LIST_TYPE.CLASSIC_TOTAL then
        return PeakRankDef.PeakRankDayType.Total, PeakRankDef.PeakRankAreaType.Classic
    elseif listType == PeakRankDef.LIST_TYPE.NOWASH_TOTAL then
        return PeakRankDef.PeakRankDayType.Total, PeakRankDef.PeakRankAreaType.NoShuffle
    elseif listType == PeakRankDef.LIST_TYPE.NORMAL_TOTAL then
        return PeakRankDef.PeakRankDayType.Total, PeakRankDef.PeakRankAreaType.None
    elseif listType == PeakRankDef.LIST_TYPE.CLASSIC_DATE then
        if beforeStage == 0 then
            return PeakRankDef.PeakRankDayType.Today, PeakRankDef.PeakRankAreaType.Classic
        elseif beforeStage == 1 then
            return PeakRankDef.PeakRankDayType.YesterDay, PeakRankDef.PeakRankAreaType.Classic
        end
    elseif listType == PeakRankDef.LIST_TYPE.NOWASH_DATE then
        if beforeStage == 0 then
            return PeakRankDef.PeakRankDayType.Today, PeakRankDef.PeakRankAreaType.NoShuffle
        elseif beforeStage == 1 then
            return PeakRankDef.PeakRankDayType.YesterDay, PeakRankDef.PeakRankAreaType.NoShuffle
        end
    elseif listType == PeakRankDef.LIST_TYPE.NORMAL_DATE then
        if beforeStage == 0 then
            return PeakRankDef.PeakRankDayType.Today, PeakRankDef.PeakRankAreaType.None
        elseif beforeStage == 1 then
            return PeakRankDef.PeakRankDayType.YesterDay, PeakRankDef.PeakRankAreaType.None
        end
    end
    return nil, nil
end

function PeakRankModel:convertServerParams2ClientParams(statisticsType, listType, beforeStage)
    local rankType = self:getRankTypeByStatisticsType(statisticsType)
    local dayType, areaType = self:getDayTypeAndAreaTypeByListTypeAndBeforeStage(listType, beforeStage)
    return rankType, dayType, areaType
end

function PeakRankModel:convertClientParams2ServerParams(rankType, dayType, areaType)
    local statisticsType = self:getStatisticsTypeByRankType(rankType)
    local listType, beforeStage = self:getListTypeAndBeforeStageByDayTypeAndAreaType(rankType, dayType, areaType)
    return statisticsType, listType, beforeStage
end

-- 获取榜单类型开关
function PeakRankModel:isRankTypeEnable(rankType)
    local statisticsType = self:getStatisticsTypeByRankType(rankType)
    for i, rank in ipairs(self._config.RankList) do
        if rank.StatisticsType == statisticsType then
            return rank.Open == 1
        end
    end
    return false
end

-- 获取榜单类型名字
function PeakRankModel:getRankTypeName(rankType)
    local statisticsType = self:getStatisticsTypeByRankType(rankType)
    for i, rank in ipairs(self._config.RankList) do
        if rank.StatisticsType == statisticsType then
            return rank.RankItemName
        end
    end
    return nil
end

-- 榜单是否区分玩法
function PeakRankModel:isRankTypeSupportDiffArea(rankType)
    local statisticsType = self:getStatisticsTypeByRankType(rankType)
    for i, rank in ipairs(self._config.RankList) do
        if rank.StatisticsType == statisticsType then
            return rank.SupportDiffPlayModel == 1
        end
    end
    return false
end

-- 此榜单是否有奖励
function PeakRankModel:isRankRewardEnable(rankType, dayType, areaType)
    local statisticsType, listType, beforeStage = self:convertClientParams2ServerParams(rankType, dayType, areaType)
    for i, rank in ipairs(self._config.RankList) do
        if rank.StatisticsType == statisticsType then
            for j, list in ipairs(rank.ListReward) do
                if list.ListType == listType then
                    return list.RewardEnable == 1
                end
            end
        end
    end
    return false
end

-- 此榜单奖励显示类型 0:未找到，1:百分比，2:固定值
function PeakRankModel:getRankRewardGetType(rankType, dayType, areaType)
    local statisticsType, listType, beforeStage = self:convertClientParams2ServerParams(rankType, dayType, areaType)
    for i, rank in ipairs(self._config.RankList) do
        if rank.StatisticsType == statisticsType then
            for j, list in ipairs(rank.ListReward) do
                if list.ListType == listType then
                    return list.RewardGetType
                end
            end
        end
    end
    return 0
end

-- 榜单多少名内显示名次
function PeakRankModel:getRankMaxRankNo(rankType, dayType, areaType)
    local statisticsType, listType, beforeStage = self:convertClientParams2ServerParams(rankType, dayType, areaType)
    for i, rank in ipairs(self._config.RankList) do
        if rank.StatisticsType == statisticsType then
            for j, list in ipairs(rank.ListReward) do
                if list.ListType == listType then
                    return list.ListMaxNum
                end
            end
        end
    end
    return 0
end

-- 榜单奖励
function PeakRankModel:getRankReward(rankType, dayType, areaType, rankNo)
    local statisticsType, listType, beforeStage = self:convertClientParams2ServerParams(rankType, dayType, areaType)
    for i, rank in ipairs(self._config.RankList) do
        if rank.StatisticsType == statisticsType then
            for j, list in ipairs(rank.ListReward) do
                if list.ListType == listType and list.RewardEnable == 1 then
                    for k, reward in ipairs(list.RankReward) do
                        if rankNo >= reward.RankBeginNo and rankNo <= reward.RankEndNo then
                            return reward.Rewards[1]
                        end
                    end
                end
            end
        end
    end
    return nil
end

function PeakRankModel:getRankExchangeRatioAndRewardType(rankType, dayType, areaType)
    local statisticsType, listType, beforeStage = self:convertClientParams2ServerParams(rankType, dayType, areaType)
    for i, rank in ipairs(self._config.RankList) do
        if rank.StatisticsType == statisticsType then
            for j, list in ipairs(rank.ListReward) do
                if list.ListType == listType and list.RewardEnable == 1 then
                    return list.ExchangeRatio, list.RankReward[1].Rewards[1].RewardType
                end
            end
        end
    end
    return nil, nil
end

function PeakRankModel:checkIsNewRound()
    local roundDateCache = CacheModel:getCacheByKey("PeakRank_RoundDate")
    if roundDateCache and type(roundDateCache) == 'number' then
        if tonumber(roundDateCache) < self._roundStartDate then
            self._isNewRound = true
        else
            self._isNewRound = false
        end
    else
        self._isNewRound = true
    end

    self:updateRedDot()
end

function PeakRankModel:updateRoundDateCache()
    self._isNewRound = false
    CacheModel:saveInfoToCache("PeakRank_RoundDate", self._roundStartDate)
    self:updateRedDot()
end

function PeakRankModel:updateRedDot()
    self:dispatchEvent({name = PeakRankModel.EVENT_PEAKRANK_UPDATE_REDDOT})
end

function PeakRankModel:isNewRound()
    return self._isNewRound
end

function PeakRankModel:clearLastQueryTime()
    self._lastQueryTime = {}
end

return PeakRankModel