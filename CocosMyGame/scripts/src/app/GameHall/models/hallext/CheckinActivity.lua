local SyncSender=cc.load('asynsender').SyncSender
local user=mymodel('UserModel'):getInstance()
local player=mymodel('hallext.PlayerModel'):getInstance()

local config=require('src.app.HallConfig.CheckinConfig')

local CheckinActivity=class('CheckinActivity',import('src.app.GameHall.models.hallext.ActivityModel'))

CheckinActivity.IS_PERIOD=1

my.addInstance(CheckinActivity)

CheckinActivity.NOT_OPENED='NOT_OPEN'
CheckinActivity.SATISFIED='SATISFIED'
CheckinActivity.UNSATISFIED='UNSATISFIED'
CheckinActivity.USED_UP='USED_UP'

CheckinActivity.NOT_LOGINED='NOT_LOGINED'

CheckinActivity.CHECKIN_CONFIG_UPDATED='CONFIG_UPDATED'
CheckinActivity.CHECKIN_DATA_UPDATED='DATA_UPDATED'
CheckinActivity.CHECKIN_TAKE_FAILED='TAKEFAILED_UPDATED'

CheckinActivity.CHECKED_TODAY=1
CheckinActivity.NOT_CHECK_TODAY=2
CheckinActivity.CHECKED_BEFORE=3
CheckinActivity.NOT_CHECKED_FUTURE=4

local Status={
    INVALID_VERIFY_CODE     = 0,
    SUCCESS                 = 1,
    ACTIVITY_CLOSED         = 2,
    DEVICE_CHECKED          = 3,
    USER_CHECKED            = 4,
    NO_SUCH_REWARD          = 5,
    REWARD_FAILED           = 6,
    UNEXPECTED_NETWORK      = 7,
    BUSY                    = 8,
    UNSATISFIED             = 9,
    USER_LIMIT_PER_DAY      = 10,
    DEVICE_LIMIT_PER_DAY    = 11,
}
CheckinActivity.Status = Status

local currentType

function CheckinActivity:onCreate()
    CheckinActivity.super.onCreate(self)
end

function CheckinActivity:queryConfig()
    if(true == self:readFromCacheData())then
        return
    end

    self:queryUserState()
end

function CheckinActivity:getState()
    local state = self.state or self.NOT_OPENED

    return state
end

function CheckinActivity:countIrregularFirstDay(dataList,todayIndex,period)

    local dataListLength=#dataList
    local firstDay
    --        local period=5
    local unregularLength=math.fmod(dataListLength,period)
    local regularLength=(dataListLength-unregularLength)
    if(todayIndex>regularLength and unregularLength>0)then
        firstDay=dataListLength-period+1
    else
        firstDay=todayIndex-math.fmod(todayIndex,period)+1
        if(firstDay>todayIndex)then firstDay=todayIndex-period+1 end
    end

    return firstDay
end

function CheckinActivity:getRegularRange(dataList,todayIndex,TotalJoinNum,period)


    local firstDay
    local effectiveDataList={}
    local dataListLength=#dataList

    if(dataListLength<period)then
        firstDay = TotalJoinNum-todayIndex+2
        for i,v in pairs(dataList)do
            effectiveDataList[i]=v
        end
        local remind=period-dataListLength
        for j=1,remind do
            local data = {statu=CheckinActivity.NOT_CHECKED_FUTURE,reward=dataList[#dataList].reward,type=dataList[#dataList].type}
            effectiveDataList[#effectiveDataList+1]=data
        end
    elseif(dataListLength%period == 0)then
        firstDay = TotalJoinNum-todayIndex+2
        for i,v in pairs(dataList)do
            effectiveDataList[i]=v
        end
    elseif(dataListLength>period)then

        local irregularLength,x=math.modf( (todayIndex-1)/period)
        irregularLength=irregularLength*period+1
        effectiveDataList=table.sub(dataList,irregularLength,period)
        if(#effectiveDataList<period)then
            local remind=period-#effectiveDataList
            for j=1,remind do
                local data = {statu=CheckinActivity.NOT_CHECKED_FUTURE,reward=dataList[#dataList].reward,type=dataList[#dataList].type}
                effectiveDataList[#effectiveDataList+1]=data
            end
        end

        if(todayIndex==1)then
            firstDay = TotalJoinNum+1
        elseif(todayIndex==#dataList)then
            firstDay = TotalJoinNum+1
        else
            firstDay = TotalJoinNum-todayIndex+2
        end


    end

    return effectiveDataList,firstDay
end

function CheckinActivity:queryUserState()
    local client=my.jhttp:create()
    SyncSender.run(client,function()

        local sender,dataMap=SyncSender.send('queryPeriodCheckinConfig',{IsTrunk = isBackBoxSupported() and not isSafeBoxSupported()})

        if dataMap.Status == Status.SUCCESS or dataMap.Status==Status.DEVICE_CHECKED or dataMap.Status==Status.USER_CHECKED then
            self:saveCacheData(dataMap)
            self:calculateCheckData(dataMap)
        else
            self:dispatchNotOpen()
        end

        printf("~~~~~~~~~~read checkin From net~~~~~~~~~~~~~~`")

    end)
end

function CheckinActivity:getConfig()
    return self.config
end

function CheckinActivity:getData()
    return self.data
end

function CheckinActivity:takeReward()
    if(self.takingReward)then
        print('is taking reward')
        return
    end
    self.takingReward=true

    local client=my.jhttp:create()
    SyncSender.run(client,function()
        local isTrunk = false

        if isBackBoxSupported() and not isSafeBoxSupported() then
            isTrunk = true
        end

        local sender,dataMap=SyncSender.send('takeCheckin',{IsTrunk = isTrunk, SilverToGame = config.SilverToGame or 1})
        self.takingReward=false
        dataMap.type=currentType
        dump(dataMap)

        if dataMap.Status == Status.SUCCESS then
            self:setCheckinResult(dataMap, isTrunk, config.SilverToGame or 1)
        end

        self:saveCheckinResult(dataMap)
        self:dispatchEvent({name=self.CHECKIN_DATA_UPDATED,value=dataMap})
    end)
end

function CheckinActivity:getCacheDataName()
    local cacheFile= "CheckState.xml"
    local id = tostring(user.nUserID)
    cacheFile = id.."_"..cacheFile
    return cacheFile
end

function CheckinActivity:readFromCacheData()
    local dataMap
    local filename = self:getCacheDataName()
    if(false == my.isCacheExist(filename))then
        return false
    end

    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)
    local date = self:getTodayDate()
    if(date ~= dataMap.queryDate)then
        return false
    end

    printf("~~~~~~~~~~readFromCacheData~~~~~~~~~~~~~~`")
    self:calculateCheckData(dataMap)

    return true
end

function CheckinActivity:calculateCheckData(dataMap)

    printf("~~~~~~~~~~calculateCheckData~~~~~~~~~~~~~~~")
    local RewardList = dataMap.Reward

    local dataList={}
    local TotalJoinNum = dataMap.TotalJoinNum

    if(table.maxn(RewardList)==0)then
        self:dispatchNotOpen()
        return
    end

    local todayIndex = 0
    for i,v in ipairs(RewardList)do
        if(v.IsCheck or v.IsRewarded)then
            todayIndex = i
            currentType = v.Type
            --break
        end
    end
    if(todayIndex==0)then
        self:dispatchNotOpen()
        return
    end

    local statu,reward,type
    for i,v in ipairs(RewardList)do
        if(i < todayIndex)then
            statu = CheckinActivity.CHECKED_BEFORE
        elseif(i == todayIndex)then
            if(not v.IsRewarded)then
                statu = CheckinActivity.NOT_CHECK_TODAY
            else
                statu = CheckinActivity.CHECKED_TODAY
            end
        else
            statu=CheckinActivity.NOT_CHECKED_FUTURE
        end
        reward = v.SilverNum
        type = v.Type
        dataList[#dataList+1]={statu=statu,reward=reward,type=type}
    end

    local period
    period = config['period']
    if (period == nil) then
        period = 1
    end
    local effectiveDataList
    local firstDay
    if (dataMap.IsPeriod == self.IS_PERIOD) then     --这里有人提出有BUG 但是改了之后还是不行的 所以先不改！这样周期性签到还是正常
    --非周期性签到在下一版本重构中修改掉
        firstDay = self:countIrregularFirstDay(dataList, todayIndex, period)
        effectiveDataList = table.sub(dataList, firstDay, period)
    else
        effectiveDataList,firstDay = self:getRegularRange(dataList, todayIndex, TotalJoinNum, period)
    end

    local config = {
        message = dataMap.Message,
        code = dataMap.Status,
        dataList = effectiveDataList,
        totalChecked = TotalJoinNum,
        todayIndex = todayIndex - firstDay + 1,
        firstDay = firstDay,
        isPeriod = dataMap.IsPeriod == self.IS_PERIOD
    }
    if(dataMap.IsPeriod ~= self.IS_PERIOD)then
        local x = math.mod(todayIndex-1, period)
        config.todayIndex = x + 1
    end


    self.config=config
    self:dispatchEvent({name=self.CHECKIN_CONFIG_UPDATED,value=self:getConfig()})
    self.state = self.SATISFIED
    printf("~~~~~~~~~~~~calculateCheckData ok~~~~~~~~~~~~~~~~~~")
end

function CheckinActivity:getTodayDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())
    return tmYear.."_"..tmMon.."_"..tmMday
end

function CheckinActivity:saveCacheData(dataMap)
    local data=checktable(dataMap)
    data.queryDate = CheckinActivity:getTodayDate()
    my.saveCache(CheckinActivity:getCacheDataName(),data)
end

function CheckinActivity:setCheckinResult(dataMap, isTrunk, silverToGame)
    if not dataMap.SilverNum then return end
    local resutlTable = {}
    if      dataMap.type == 1 then
        if silverToGame == 1 then
            if user.nDeposit then
                resutlTable.nDeposit = user.nDeposit + dataMap.SilverNum
            end
        elseif isTrunk then
            if user.nBackDeposit then
                resutlTable.nBackDeposit = user.nBackDeposit + dataMap.SilverNum
            end
        else
            if user.nSafeboxDeposit then
                resutlTable.nSafeboxDeposit = user.nSafeboxDeposit + dataMap.SilverNum
            end
        end
    elseif  user.nScore and dataMap.type == 6 then
        resutlTable.nScore = user.nScore + dataMap.SilverNum
    end
    player:mergeUserData(resutlTable)
end

function CheckinActivity:saveCheckinResult(dataMap)
    local filename = self:getCacheDataName()
    if(false == my.isCacheExist(filename))then
        return false
    end

    local cache = my.readCache(filename)
    cache = checktable(cache)
    if(dataMap.Status==Status.SUCCESS)then

        local RewardList=cache.Reward
        for i,v in pairs(RewardList)do
            if(v.IsCheck)then
                v.IsRewarded=true
                break
            end
        end
        self:saveCacheData(cache)
        self:calculateCheckData(cache)
    elseif dataMap.Status == Status.DEVICE_CHECKED
        or dataMap.Status == Status.USER_CHECKED
        or dataMap.Status == Status.USER_LIMIT_PER_DAY
        or dataMap.Status == Status.DEVICE_LIMIT_PER_DAY then
        cache.Status = dataMap.Status
        self:saveCacheData(cache)
        self:calculateCheckData(cache)
    end
end

function CheckinActivity:dispatchNotOpen()
    self.state = self.NOT_OPENED
    self:dispatchEvent({name=self.CHECKIN_CONFIG_UPDATED,value=self:getConfig()})
end

return CheckinActivity
