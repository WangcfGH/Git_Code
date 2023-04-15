local LuckyCatModel         =class('LuckyCatModel',require('src.app.GameHall.models.BaseModel'))
local AssistModel           = mymodel('assist.AssistModel'):getInstance()
local LuckyCatDef           = require('src.app.plugins.LuckyCat.LuckyCatDef')
local user                  = mymodel('UserModel'):getInstance()
local BroadcastModel        = mymodel("hallext.BroadcastModel"):getInstance()
local ShopModel             = mymodel("ShopModel"):getInstance()
local CardRecorderModel     = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local ExchangeLotteryModel  = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
local LoginLotteryModel     = import("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
local deviceModel           = mymodel('DeviceModel'):getInstance()
local ShareCtrl             = import('src.app.plugins.sharectrl.ShareCtrl')
local treepack              = cc.load('treepack')
local json                  = cc.load("json").json

local GoldSilverModel = require('src.app.plugins.goldsilver.GoldSilverModel'):getInstance()
local GoldSilverDef = import('src.app.plugins.goldsilver.GoldSilverDef')

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(LuckyCatModel,PropertyBinder)

my.addInstance(LuckyCatModel)

protobuf.register_file('src/app/plugins/LuckyCat/proto/pbLuckyCat.pb')

function LuckyCatModel:onCreate()
    self._LuckyCatConfig = nil
    self._LuckyCatInfo = nil

    self:listenTo(ShareCtrl, ShareCtrl.SHARE_SUCCESS_RET, handler(self,self.changeShareParam))

    self:initAssistResponse()
end

function LuckyCatModel:reset( )
    self._LuckyCatConfig    = nil
    self._LuckyCatInfo      = nil
end

function LuckyCatModel:initAssistResponse()
    self._assistResponseMap = {
        [LuckyCatDef.GR_LUCKY_CAT_GET_INFO] = handler(self, self.onLuckyCatInfo),
        [LuckyCatDef.GR_LUCKY_CAT_TASK_PRIZE] = handler(self, self.onLuckyCatTaskPrizeTakeRet),
        [LuckyCatDef.GR_LUCKY_CAT_UPGRADE] = handler(self, self.onLuckyCatUpgradeRet),
        [LuckyCatDef.GR_LUCKY_CAT_TAKE_AWARD] = handler(self, self.onLuckyCatTakeAwardRet),
        [LuckyCatDef.GR_LUCKY_CAT_CHANGE_PARAM] = handler(self, self.onLuckyCatChangeParamRet)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function LuckyCatModel:changeShareParam()
    self:gc_ChangeLuckyCatParam(LuckyCatDef.LUCKYCAT_TASK_DAILY_HALL_SHARE, 1)
    
    my.scheduleOnce(function()
        self:gc_GetLuckyCatInfo()
    end, 0.1)
end

function LuckyCatModel:gc_GetLuckyCatInfo()
    if not cc.exports.isLuckyCatSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID = user.nUserID,
        needConfig = 1
    }
    local pdata = protobuf.encode('pbLuckyCat.luckyCatData', data)
    AssistModel:sendData(LuckyCatDef.GR_LUCKY_CAT_GET_INFO, pdata, false)
end

function LuckyCatModel:onLuckyCatInfo(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbLuckyCat.luckyCatData', data)
    protobuf.extract(pdata)

    if not pdata.config or pdata.config == "" then
        if self._TipConten == nil then
            local FileNameString = "src/app/plugins/LuckyCat/LuckyCat.json"
            local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
            self._TipConten = cc.load("json").json.decode(content)
        end
        self._LuckyCatConfig = self._TipConten
    else
        self._LuckyCatConfig = json.decode(pdata.config)
    end
    self._LuckyCatInfo = pdata

    self:dispatchEvent({name = LuckyCatDef.LUCKYCATINFORET})
end

function LuckyCatModel:gc_LuckyCatTaskPrizeTake(nGroupID,nID)
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local data = {
        userID = user.nUserID,
        groupID=nGroupID,
        subID = nID
    }

    local pdata = protobuf.encode('pbLuckyCat.taskResult', data)
    AssistModel:sendData(LuckyCatDef.GR_LUCKY_CAT_TASK_PRIZE,pdata, false)
end

function LuckyCatModel:onLuckyCatTaskPrizeTakeRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbLuckyCat.taskResult', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    
    local rewardList = {}
    --for u, v in pairs(awardRet.rewardIDList) do
        table.insert( rewardList,{nType = awardRet.rewardType,nCount = awardRet.rewardNum})
    --end
    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})

    --后续用返回字段处理
    self:gc_GetLuckyCatInfo()
end

function LuckyCatModel:gc_LuckyCatUpgrade()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local UserModel = mymodel('UserModel'):getInstance()

    local data = {
        userID = user.nUserID,
        userName = UserModel.szUsername
    }

    local pdata = protobuf.encode('pbLuckyCat.luckyCatUpgrade', data)
    AssistModel:sendData(LuckyCatDef.GR_LUCKY_CAT_UPGRADE,pdata, false)
end

function LuckyCatModel:onLuckyCatUpgradeRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbLuckyCat.luckyCatUpgrade', data)
    protobuf.extract(awardRet)
    
    local tipStr = "解锁成功，已获得瓜分10亿银两资格"
    local LuckyCatConfig = self:GetLuckyCatConfig()
    if LuckyCatConfig and LuckyCatConfig.LuckyCatReward then
        local rewardType = LuckyCatConfig.LuckyCatReward[1].RewardType
        if tonumber(rewardType) == LuckyCatDef.LUCKYCAT_REWARD_EXCHANGE then
            tipStr = "解锁成功，已获得瓜分10万话费资格"
        end
    end
    
    if awardRet.multiGrade == 1 then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString = tipStr, removeTime=3}})
    else
        tipStr = "升级成功，瓜分奖励翻"..awardRet.multiGrade.."倍哦~"
        my.informPluginByName({pluginName='ToastPlugin',params={tipString = tipStr, removeTime=3}})
    end

    --用返回字段处理
    self:gc_GetLuckyCatInfo()
end

function LuckyCatModel:gc_LuckyCatTakeAward()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local data = {
        userID = user.nUserID
    }

    local pdata = protobuf.encode('pbLuckyCat.luckyCatAward', data)
    AssistModel:sendData(LuckyCatDef.GR_LUCKY_CAT_TAKE_AWARD,pdata, false)
end

function LuckyCatModel:onLuckyCatTakeAwardRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbLuckyCat.luckyCatAward', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)
    
    local rewardList = {}
    --for u, v in pairs(awardRet.rewardIDList) do
        table.insert( rewardList,{nType = awardRet.rewardType,nCount = awardRet.rewardNum})
    --end
    

    self:dispatchEvent({name = LuckyCatDef.LUCKYCATAWARDGET, value = rewardList})

    --后续用返回字段处理
    self:gc_GetLuckyCatInfo()
end

function LuckyCatModel:gc_ChangeLuckyCatParam(taskType, taskCount)
    if not cc.exports.isLuckyCatSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID = user.nUserID,
        type = taskType,
        value = taskCount
    }
    local pdata = protobuf.encode('pbLuckyCat.taskParamChange', data)
    AssistModel:sendData(LuckyCatDef.GR_LUCKY_CAT_CHANGE_PARAM, pdata, false)
end

function LuckyCatModel:onLuckyCatChangeParamRet( ... )
    
end

function LuckyCatModel:GetLuckyCatInfo()
    if self._LuckyCatInfo then
        return self._LuckyCatInfo
    end
    return nil
end

function LuckyCatModel:GetLuckyCatConfig()
    if self._LuckyCatConfig then
        return self._LuckyCatConfig
    end
    return nil
end

function LuckyCatModel:isDayTaskNeedReddot()
    if not self:isAlive() then
        return false
    end

    local taskGroupList = self:FillTaskData(LuckyCatDef.LUCKY_CAT_DAY)
    for i=1,#taskGroupList do
        if taskGroupList[i]._btnState == LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD then
            return true
        end
    end

    local taskGroupList = self:FillTaskData(LuckyCatDef.LUCKY_CAT_BOX)
    for i=1,#taskGroupList do
        if taskGroupList[i]._btnState == LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD then
            return true
        end
    end

    return false
end

function LuckyCatModel:isWelfareTaskNeedReddot()
    if not self:isAlive() then
        return false
    end

    local taskGroupList = self:FillTaskData(LuckyCatDef.LUCKY_CAT_WELFARE)
    for i=1,#taskGroupList do
        if taskGroupList[i]._btnState == LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD then
            return true
        end
    end

    return false
end

function LuckyCatModel:isNeedReddot()
    if not self:isAlive() then
        return false
    end

    if self:isDayTaskNeedReddot() then
        return true
    end

    if self:isWelfareTaskNeedReddot() then
        return true
    end

    return false
end

--获取翻倍数
function LuckyCatModel:getMultiGrade()
    local LuckyCatInfo = self:GetLuckyCatInfo()
    if not LuckyCatInfo or not LuckyCatInfo.catData or not LuckyCatInfo.catData.multiGrade then
        return 0
    end
    return LuckyCatInfo.catData.multiGrade

end

--获取解锁人数
function LuckyCatModel:getLockCount()
    if  not self._LuckyCatInfo or not self._LuckyCatInfo.divideNum then
        return 0
    end
 
    return self._LuckyCatInfo.divideNum
end

--获取领奖缓存天数
function LuckyCatModel:getBufferDate()
    if  not self._LuckyCatConfig or not self._LuckyCatConfig.RwardBufferData then
        return 0
    end
 
    return self._LuckyCatConfig.RwardBufferData
end

function LuckyCatModel:isAlive()
   if not cc.exports.isLuckyCatSupported()  then
       return  false
   end

   if  not self._LuckyCatInfo then
       return false
   end

   if self._LuckyCatInfo and  self._LuckyCatInfo.state == LuckyCatDef.LUCKYCAT_STATUS_CLOSE then
       return false
   end

    return true
end

function LuckyCatModel:getFlagByGroupID(nGroupID,subID)
    -- 校验招财猫信息和配置
    if not self:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = self:GetLuckyCatInfo()
    local LuckyCatConfig = self:GetLuckyCatConfig()
    
    for i = 1, #LuckyCatInfo.taskData do
        if LuckyCatInfo.taskData[i].groupID == nGroupID and LuckyCatInfo.taskData[i].subID == subID then
            local nFlag = LuckyCatInfo.taskData[i].flag
            local nID   = subID
            return {
                nFlag   = nFlag,
                nID     = nID
            }
        end
    end
end

function LuckyCatModel:FillTaskData(index)
    -- 校验招财猫信息和配置
    if not self:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = self:GetLuckyCatInfo()
    local LuckyCatConfig = self:GetLuckyCatConfig()

    local taskDataList = {}
    
    local taskShow = LuckyCatConfig.DailyTask[1].TaskGroupList  --配置列表
    if index == LuckyCatDef.LUCKY_CAT_WELFARE then
        taskShow = LuckyCatConfig.WelfareTask[1].TaskGroupList
    elseif index == LuckyCatDef.LUCKY_CAT_BOX then
        taskShow = LuckyCatConfig.BoxTask[1].TaskGroupList
    end
    if not taskShow or type(taskShow) ~= "table" then
        return
    end
    local newTable = {}
    for i,v in pairs(taskShow) do
        local bInsert = true
        if v.GroupID == LuckyCatDef.LUCKYCAT_TASK_DAILY_HALL_TAKE_GOLDSILVER_REWARD then
            local goldsilverinfo = GoldSilverModel:GetGoldSilverInfo()
            if not goldsilverinfo or goldsilverinfo.nStatusCode ~= GoldSilverDef.GOLDSILVER_SUCCESS then
                bInsert = false
            end
        end
        if bInsert then
            table.insert(newTable, taskShow[i])
        end
    end
    taskShow = newTable

    for i, v in pairs(taskShow) do
        if v.GroupID ~= LuckyCatDef.LUCKYCAT_TASK_DAILY_HALL_SHARE or cc.exports.isShareSupported() then
            local nGroupID  = tonumber(v.GroupID)
            local nData = nil

            local groupStatus = true  --是否当前group任务全都完成
            for j=1,#v.TaskList do
                local nID = v.TaskList[j].ID

                nData = self:getFlagByGroupID(nGroupID,nID)
                if not nData then
                    groupStatus = false
                    nData       = {
                        nID     = j,
                        nFlag   = LuckyCatDef.TASKDATA_FLAG_DOING
                    }
                    break
                end
            end

            if groupStatus then  --全部完成
                nData       = {
                    nID     = #v.TaskList,
                    nFlag   = LuckyCatDef.TASKDATA_FLAG_FINISHED
                }
            end

            local config = nil
            for j, w in pairs(v.TaskList) do 
                if nData.nID == w.ID then
                    config = w
                    break
                end
            end

            local task          = {
                _groupID        = nGroupID,
                _taskID         = nData.nID,
                _taskType       = config.Condition[1].ConType,
                _description    = config.Name,
                _btnState       = nData.nFlag,
                _rewardCount    = config.Reward[1].RewardCount,
                _amount         = 0,
                _progress       = {}
            }

            local bFinished = true
            local nAmount   = 0 -- 任务完成量
            for j , w in pairs(LuckyCatInfo.taskParam) do
                if w["type"] == config.Condition[1].ConType then
                    nAmount     = w.param
                    break;
                end
            end

                if nAmount == nil then
                    nAmount = 0
                end
                task._amount = nAmount

                local progress  = {}
                local nValue    = tonumber(config.Condition[1].ConValue)
                if nAmount >= nValue then
                    progress._value = 100
                    progress._text  = tostring(nValue).."/"..tostring(nValue)                    
                else 
                    bFinished   = false
                    progress._value = 100 * (nAmount / nValue)
                    progress._text  = tostring(nAmount).."/"..tostring(nValue)
                end
                table.insert(task._progress, progress)


            if LuckyCatDef.TASKDATA_FLAG_DOING == nData.nFlag and bFinished then                
                task._btnState  = LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD
            end

            table.insert(taskDataList, task)
        end
    end
    --排序，可领取 > 进度中 > 零进度 > 已完成
    local function comps(a, b)
        return self:sortUnit(a, b)
    end
    table.sort(taskDataList, comps)

    return taskDataList
end

function LuckyCatModel:sortUnit(unitA, unitB)
    if LuckyCatDef.TASKDATA_FLAG_FINISHED <= unitA._btnState
        and LuckyCatDef.TASKDATA_FLAG_FINISHED <= unitB._btnState then
        return (unitA._groupID < unitB._groupID)
    elseif LuckyCatDef.TASKDATA_FLAG_FINISHED > unitA._btnState
        and LuckyCatDef.TASKDATA_FLAG_FINISHED > unitB._btnState then
        local progressA, progressB = 0, 0
        for index, value in pairs(unitA._progress) do
            progressA = progressA + value._value
        end
        progressA = progressA / (#unitA._progress)
        for index, value in pairs(unitB._progress) do
            progressB = progressB + value._value
        end
        progressB = progressB / (#unitB._progress)
        
        if progressA == progressB then
            return (unitA._groupID < unitB._groupID)
        else
            return (progressA > progressB)
        end
    else
        return (unitA._btnState < unitB._btnState)
    end
end

function LuckyCatModel:checkCatInfoAndConfig()
    if not self._LuckyCatInfo or not self._LuckyCatConfig then
        self:gc_GetLuckyCatInfo()
        return false
    end
    return true
end

return LuckyCatModel