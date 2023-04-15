local TaskModel = class('TemplateModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(TaskModel)

local TaskReq = import('src.app.plugins.MyTaskPlugin.TaskReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local PlayerModel = mymodel('hallext.PlayerModel'):getInstance()

local TaskDef = {
    TASK_PARAM_TOTAL                      = 28,

    TASK_GAME_RESULT_WIN                  = 1, -- 赢的局敿
    TASK_GAME_RESULT_LOSE                 = 2, -- 输的局敿
    TASK_GAME_RESULT_DRAW                 = 3, -- 平局
	TASK_GAME_TOUYOU_WIN		  		  = 4, --做头游赢	
	TASK_GAME_THS		  		          = 5, --打出同花顺牌型次数
	TASK_GAME_SHARE						  = 21,--分享的次敿
	TASK_GAME_UP						  = 22,--点赞的次敿
	TASK_GAME_BE_UP						  = 23,--被点赞的次数
    TASK_CONDITION_COM_GAME_COUNT         = 1001, --玩了几局

    TASKDATA_FLAG_DOING                   = 0, -- 任务正在进行丿
    TASKDATA_FLAG_CANGET_REWARD           = 1, -- 任务可领叿
    TASKDATA_FLAG_FINISHED                = 2, -- 任务已完房
    TASKDATA_FLAG_FINISHED_HIDE           = 3, -- 任务完成隐藏

    REQ_TYPE_ALL                          = 0, -- 请求所有任势
    REQ_TYPE_INGAME                       = 1, -- 请求游戏内显示任势
    REQ_TYPE_GROUPID                      = 2, -- 请求单独任务

    -----------------------------------------------
    GR_TASK_PARAM_CHANGE                  = 402010,
    GR_SEND_TASKPARAM_REQ                 = 402011,
    GR_SEND_TASKPARAM_RESP                = 402012,
    GR_SEND_TASKDATA_REQ                  = 402013,
    GR_SEND_TASKDATA_RESP                 = 402014,
    GR_SEND_TASKFINISH_REQ                = 402015,
    GR_SEND_TASKFINISH_RESP               = 402016,
	GR_TASK_PARAM_CHANGE_FROM_CLIENT      = 402017,
    -----------------------------------------------
}
TaskModel.TaskDef = TaskDef

TaskModel.UPDATE_TASK_RED_DOT = "UPDATE_TASK_RED_DOT"
TaskModel.EVENT_MAP = {
    ["taskModel_updateTaskList"] = "taskModel_updateTaskList",
    ["taskModel_taskRewardGot"] = "taskModel_taskRewardGot",
    ["taskModel_rewardAvailChanged"] = "taskModel_rewardAvailChanged"
}

function TaskModel:onCreate()
    self._taskParamData  = nil
    self._taskData = nil
    self._nGetTaskStep = -1

    self._assistResponseMap = {
        [TaskDef.GR_SEND_TASKPARAM_RESP] = handler(self, self.dealTaskParamDataResp),
        [TaskDef.GR_SEND_TASKDATA_RESP] = handler(self, self.dealTaskDataResp),
        [TaskDef.GR_SEND_TASKFINISH_RESP] = handler(self, self.updateTaskData)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function TaskModel:SendTaskDataReq(reqType, nGroupID)
    self._nGetTaskStep = 2
    local playerInfo = PublicInterface.GetPlayerInfo()

    local GR_TASK_DATA_REQ = TaskReq["TASK_DATA_REQ"]
    local data      = {
        nUserID     = playerInfo.nUserID,
        nReqType    = reqType,
        nGroupID    = nGroupID
    }
    local pData = treepack.alignpack(data, GR_TASK_DATA_REQ)
    AssistModel:sendData(TaskDef.GR_SEND_TASKDATA_REQ, pData)
end

function TaskModel:sendGetTCYGameTask()
	local playerInfo = PublicInterface.GetPlayerInfo()
    local GR_TCYGAME_TASK = TaskReq["TcyGameTask"]
    local data      = {
        nUserID     = playerInfo.nUserID,
        nGetReward  = 0,
		nTaskFlag   = 0,
		kpiClientData = AssistModel:getKPIClientData()
    }
    local pData = treepack.alignpack(data, GR_TCYGAME_TASK)
    AssistModel:sendData(TaskDef.GR_GET_DONWLOAD_TCYGAME, pData)
end

function TaskModel:SendTCYGameDonwloadTaskFinishReq()
	local playerInfo = PublicInterface.GetPlayerInfo()
    local GR_TCYGAME_TASK = TaskReq["TcyGameTask"]
    local data      = {
        nUserID     = playerInfo.nUserID,
        nGetReward  = 0,
		nTaskFlag   = 0,
		kpiClientData = AssistModel:getKPIClientData()
    }
    local pData = treepack.alignpack(data, GR_TCYGAME_TASK)
    AssistModel:sendData(TaskDef.GR_FINISH_DONWLOAD_TCYGAME, pData)
end

function TaskModel:SendTaskFinishReq(nGroupID, nTaskID)
    local playerInfo = PublicInterface.GetPlayerInfo()

    local GR_TASK_FINISH_REQ = TaskReq["TASK_FINISH_REQ"]
    local data      = {
        nUserID     = playerInfo.nUserID,
        nGroupID    = nGroupID,
        nTaskID     = nTaskID,
        kpiClientData = AssistModel:getKPIClientData()
    }
    local pData = treepack.alignpack(data, GR_TASK_FINISH_REQ)

    AssistModel:sendData(TaskDef.GR_SEND_TASKFINISH_REQ, pData)
end

function TaskModel:SendChangeTaskParamReq(reqType)
    local playerInfo = PublicInterface.GetPlayerInfo()

    local TASK_PARAM = TaskReq["TASK_PARAM"]
    local data      = {
        nUserID         = playerInfo.nUserID,
        nAddParamType   = reqType,
        nAddParamValue  = 1,
        nNowValue       = 0    
    }
    local pData = treepack.alignpack(data, TASK_PARAM)

    AssistModel:sendData(TaskDef.GR_TASK_PARAM_CHANGE_FROM_CLIENT, pData)
end

function TaskModel:dealTaskDataResp(responseData)
    print('send taskdata resp')
    local taskDataInfo = TaskReq["TASK_DATA_RESP"]
    local msgTaskDataInfo = treepack.unpack(responseData, taskDataInfo)

    if (msgTaskDataInfo.nRequestType == 0) then
        self._taskData =  msgTaskDataInfo
    elseif (msgTaskDataInfo.nRequestType==1 or msgTaskDataInfo.nRequstType==2) then
        for i = 1, msgTaskDataInfo.nTaskNum do
            local data = {
                groupID = msgTaskDataInfo['nGroupID'..i],
                ID      = msgTaskDataInfo['nID'..i],
                Flag    = msgTaskDataInfo['nFlag'..i]
            }
            local bFind = false
            for j = 1, self._taskData.nTaskNum do
                 if self._taskData['nGroupID'..j] == data.groupID then
                    self._taskData['nID'..j] = data.ID
                    self._taskData['nFlag'..j] = data.Flag
                     bFind = true
                     break
                 end
            end
            if not bFind then
                self._taskData.nTaskNum = self._taskData.nTaskNum + 1
                local index = self._taskData.nTaskNum
                self._taskData['nGroupID'..index] = data.groupID
                self._taskData['nID'..index] = data.ID
                self._taskData['nFlag'..index] = data.Flag
            end
        end
    end    
    self._nGetTaskStep = self._nGetTaskStep - 1
    if self._nGetTaskStep == 0 and self._taskParamData and self._taskData then
        --self._TaskCtrl:updateTaskList()
        self:dispatchEvent({name = TaskModel.EVENT_MAP["taskModel_updateTaskList"]})
    end

    --[[if self._nGetTaskStep == 0 and self._GameCtr and self._taskParamData and self._taskData then
        self._GameCtr:getTaskList()
    end]]-- 已弃置不用

    if  self._nGetTaskStep == 0 and self._taskParamData and self._taskData then
        --[[cc.exports.getTaskList()
        cc.load('MainCtrl'):getInstance():ShowTaskTip()]]--

        self:getTaskListForGlobal()
        self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
        self:dispatchModuleStatusChanged("task", TaskModel.EVENT_MAP["taskModel_rewardAvailChanged"])

        self._nGetTaskStep = -1
    end
end

function TaskModel:dealTaskParamDataResp(responseData)
    print('send taskparam resp')
    local paramInfo = TaskReq["TASK_PARAM_RESP"]
    local msgParamInfo = treepack.unpack(responseData, paramInfo)
    self._taskParamData = msgParamInfo

    self._nGetTaskStep = self._nGetTaskStep - 1
    if self._nGetTaskStep == 0 and self._taskParamData and self._taskData then
        --self._TaskCtrl:updateTaskList()
        self:dispatchEvent({name = TaskModel.EVENT_MAP["taskModel_updateTaskList"]})
    end

    --[[if self._nGetTaskStep == 0 and self._GameCtr and self._taskParamData and self._taskData then
        self._GameCtr:getTaskList()
    end]]--

    if self._nGetTaskStep == 0 and self._taskParamData and self._taskData then
        --[[cc.exports.getTaskList()
        cc.load('MainCtrl'):getInstance():ShowTaskTip()]]--
        self:getTaskListForGlobal()
        self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
        self:dispatchModuleStatusChanged("task", TaskModel.EVENT_MAP["taskModel_rewardAvailChanged"])

        self._nGetTaskStep = -1
    end
end

function TaskModel:updateTaskData(responseData)
    print('send taskfinish resp')
    local taskFinishInfo = TaskReq["TASK_FINISH_RESP"]
    local msgTaskFinishInfo = treepack.unpack(responseData, taskFinishInfo)

    if (msgTaskFinishInfo.nResult == 0) then
        print('FinishTask ok')
        local bFind = false
        for j = 1, self._taskData.nTaskNum do
            if self._taskData['nGroupID'..j] == msgTaskFinishInfo.nGroupID then
                self._taskData['nFlag'..j] = msgTaskFinishInfo.nFlag

                local nNextID = msgTaskFinishInfo.nNextTaskID
                if 0 ~= nNextID then
                    self._taskData['nID'..index] = nNextID
                end
                bFind = true
                break
            end
        end
        if not bFind then
            self._taskData.nTaskNum = self._taskData.nTaskNum + 1
            local index = self._taskData.nTaskNum
            self._taskData['nGroupID'..index] = msgTaskFinishInfo.nGroupID
            self._taskData['nFlag'..index] = msgTaskFinishInfo.nFlag

            local nTaskID = msgTaskFinishInfo.nTaskID
            local nNextID = msgTaskFinishInfo.nNextTaskID
            if 0 ~= nNextID then
                self._taskData['nID'..index] = nNextID
            else
                self._taskData['nID'..index] = nTaskID
            end
        end

        --[[if self._TaskCtrl then
            local nMinValue = msgTaskFinishInfo.Reward[1].nMinValue
            --local nMinValue = msgTaskFinishInfo.nMinValue1
            self._TaskCtrl:playTaskAction(nMinValue)
        end]]--
        self:dispatchEvent({name = TaskModel.EVENT_MAP["taskModel_taskRewardGot"], value = {["nMinValue"] = msgTaskFinishInfo.Reward[1].nMinValue}})
        PlayerModel:update({'UserGameInfo'})
    else
        --[[if self._TaskCtrl then
            self._TaskCtrl:updateTaskList()
        end]]--
        self:dispatchEvent({name = TaskModel.EVENT_MAP["taskModel_updateTaskList"]})
    end
    --[[if self._TaskCtrl and self._TaskCtrl._CanNotClose then
        self._TaskCtrl._CanNotClose = false
        if self._TaskCtrl.onFinishTaskTimerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TaskCtrl.onFinishTaskTimerID)
            self._TaskCtrl.onFinishTaskTimerID = nil
        end
    end   ]]-- 
    
    --[[cc.exports.getTaskList()
    cc.load('MainCtrl'):getInstance():ShowTaskTip()
    self:dispatchEvent({name=self.UPDATE_TASK_RED_DOT})]]--

    self:getTaskListForGlobal()
    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("task", TaskModel.EVENT_MAP["taskModel_rewardAvailChanged"])
end

function TaskModel:getTaskListForGlobal()
    local FileNameString = "src/app/plugins/MyTaskPlugin/TaskConfig.json"
    if not cc.exports.isShareSupported() then
        FileNameString = "src/app/plugins/MyTaskPlugin/TaskConfig_noShare.json"
    end
    local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
    local taskConfig = cc.load("json").json.decode(content)
    if not taskConfig  then return {} end

    --更新下服务端的配置
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.PhoneGameTaskConfig then
        for i, v in pairs(taskConfig.Task) do
            for j, w in pairs(cc.exports._gameJsonConfig.PhoneGameTaskConfig) do
                if v.GroupID == w.nGroupID and v.TaskList[1].ID == w.nTaskID then
                    v.TaskList[1].Condition[1].ConValue = w.nCondition
                    v.TaskList[1].Reward[1].RewardValueMin = w.nReward
                    v.TaskList[1].Reward[1].RewardValueMax = w.nReward
                end
            end
        end
    end
    
    --[[local AssistConnect = require('src.app.plugins.AssistModel.AssistConnect'):getInstance()
    cc.exports._taskData      = clone(AssistConnect._TaskData)
    local taskParamData = clone(AssistConnect._TaskParamData)]]--
    cc.exports._taskData      = clone(self._taskData)
    local taskParamData = clone(self._taskParamData)

    local list = {}
    local imagePath = taskConfig.ImagePath
    for i, v in pairs(taskConfig.Task) do
        local nGroupID  = tonumber(v.GroupID)
        if nGroupID ~= 100 then
        
            local nData     = self:getFlagByGroupIDForGlobal(nGroupID)
            if not nData then
                nData       = {
                    nID     = v.BeginID,
                    nFlag   = TaskDef.TASKDATA_FLAG_DOING
                }
            end
            local config = nil
            for j, w in pairs(v.TaskList) do
                if nData.nID == w.ID then
                    config = w
                    break
                end
            end
            if v.Active == 1 and nData and TaskDef.TASKDATA_FLAG_FINISHED_HIDE ~= nData.nFlag and config then
                local task          = {
                    _groupID        = nGroupID,
                    _taskID         = nData.nID,
                    _title          = v.Title,
                    _image          = imagePath..v.Image,
                    _description    = config.Name,
                    _btnState       = nData.nFlag,
                    _reward         = {},
                    _progress       = {}
                }

                for j , w in pairs(config.Reward) do
                    local reward    = {}
                    local image     = taskConfig.Reward[w.RewardType].Image
                    local text      = taskConfig.Reward[w.RewardType].Text
                    reward._image   = imagePath..image
                    reward._text    = text
                    reward._value   = w.RewardValueMin
                    table.insert(task._reward, reward)
                end

                local bFinished = true
                for j , w in pairs(config.Condition) do
                    local nAmount   = 0 -- 任务完成量
                    local nConType  = tonumber(w.ConType)
                    local nParam    = taskParamData.nParam
                    if TaskDef.TASK_CONDITION_COM_GAME_COUNT == nConType then
                        nAmount     = nParam[1] + nParam[2] + nParam[3]
                    else
                        nAmount     = nParam[nConType]
                    end
				    task._nConType = nConType

                    local progress  = {}
                    local nValue    = tonumber(w.ConValue)
                    if nAmount >= nValue then
                        progress._value = 100
                        progress._text  = tostring(nValue).."/"..tostring(nValue)
                    else
                        bFinished   = false
                        progress._value = 100 * (nAmount / nValue)
                        progress._text  = tostring(nAmount).."/"..tostring(nValue)
                    end
                    table.insert(task._progress, progress)
                
                    task._Amount = nAmount
                    task._value = nValue
                end
                if TaskDef.TASKDATA_FLAG_DOING == nData.nFlag and bFinished then
                    task._btnState  = TaskDef.TASKDATA_FLAG_CANGET_REWARD
                end

                table.insert(list, task)
            end
        
        end
    end
    cc.exports._GameTaskList = list

    --self:IsHaveTaskFinish()

    return list
end

function TaskModel:getFlagByGroupIDForGlobal(nGroupID)
    for i = 1, cc.exports._taskData.nTaskNum do
        if cc.exports._taskData['nGroupID'..i] == nGroupID then
            local nFlag = cc.exports._taskData['nFlag'..i]
            local nID   = cc.exports._taskData['nID'..i]
            return {
                nFlag   = nFlag,
                nID     = nID
            }
        end
    end

    return nil
end


function TaskModel:IsHaveTaskFinishForGlobal()
    --self._baseGameScene:showFinishTaskNode()
    if not cc.exports._GameTaskList then
        return false
    end
    for i, v in pairs(cc.exports._GameTaskList) do
        if v._btnState == TaskDef.TASKDATA_FLAG_CANGET_REWARD then
            return true
        end
    end
    return false

    --return true --测试代码
end

function TaskModel:loadTaskConfig()
    local FileNameString = "src/app/plugins/MyTaskPlugin/TaskConfig.json"
    if not cc.exports.isShareSupported() then
        FileNameString = "src/app/plugins/MyTaskPlugin/TaskConfig_noShare.json"
    end
    local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
    self._taskConfig = cc.load("json").json.decode(content)
end

function TaskModel:getTaskList()
    if not self._taskConfig  then return {} end

    --更新下服务端的配置
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.PhoneGameTaskConfig then
        for i, v in pairs(self._taskConfig.Task) do
            for j, w in pairs(cc.exports._gameJsonConfig.PhoneGameTaskConfig) do
                if v.GroupID == w.nGroupID and v.TaskList[1].ID == w.nTaskID then
                    v.TaskList[1].Condition[1].ConValue = w.nCondition
                    v.TaskList[1].Reward[1].RewardValueMin = w.nReward
                    v.TaskList[1].Reward[1].RewardValueMax = w.nReward
                end
            end
        end
    end

    --[[self._taskData      = clone(AssistConnect._TaskData)
    self._taskParamData = clone(AssistConnect._TaskParamData)]]--
    --self._taskData = clone(TaskModel._TaskData)
    --self._taskParamData = clone(TaskModel._TaskParamData)

    local list = {}
    local imagePath = self._taskConfig.ImagePath
    for i, v in pairs(self._taskConfig.Task) do
        local nGroupID  = tonumber(v.GroupID)
        if nGroupID ~= 100 then        
            local nData     = self:getFlagByGroupID(nGroupID)
            if not nData then
                nData       = {
                    nID     = v.BeginID,
                    nFlag   = TaskDef.TASKDATA_FLAG_DOING
                }
            end
            local config = nil
            for j, w in pairs(v.TaskList) do
                if nData.nID == w.ID then
                    config = w
                    break
                end
            end
            if v.Active == 1 and nData and TaskDef.TASKDATA_FLAG_FINISHED_HIDE ~= nData.nFlag and config then
                local task          = {
                    _groupID        = nGroupID,
                    _taskID         = nData.nID,
                    _title          = v.Title,
                    _image          = imagePath..v.Image,
                    _description    = config.Name,
                    _btnState       = nData.nFlag,
                    _reward         = {},
                    _progress       = {}
                }

                for j , w in pairs(config.Reward) do
                    local reward    = {}
                    local image     = self._taskConfig.Reward[w.RewardType].Image
                    local text      = self._taskConfig.Reward[w.RewardType].Text
                    reward._image   = imagePath..image
                    reward._text    = text
                    reward._value   = w.RewardValueMin
                    table.insert(task._reward, reward)
                end

                local bFinished = true
                for j , w in pairs(config.Condition) do
                    local nAmount   = 0 -- 任务完成量
                    local nConType  = tonumber(w.ConType)
                    local nParam    = self._taskParamData.nParam
                    if TaskDef.TASK_CONDITION_COM_GAME_COUNT == nConType then
                        nAmount     = nParam[1] + nParam[2] + nParam[3]
                    else
                        nAmount     = nParam[nConType]
                    end
				    task._nConType = nConType

                    local progress  = {}
                    local nValue    = tonumber(w.ConValue)
                    if nAmount >= nValue then
                        progress._value = 100
                        progress._text  = tostring(nValue).."/"..tostring(nValue)
                    else
                        bFinished   = false
                        progress._value = 100 * (nAmount / nValue)
                        progress._text  = tostring(nAmount).."/"..tostring(nValue)
                    end
                    table.insert(task._progress, progress)
                end

                if TaskDef.TASKDATA_FLAG_DOING == nData.nFlag and bFinished then
                    task._btnState  = TaskDef.TASKDATA_FLAG_CANGET_REWARD
                end

                table.insert(list, task)
            end
        end
    end
    return list
end

function TaskModel:getFlagByGroupID(nGroupID)
    for i = 1, self._taskData.nTaskNum do
        if self._taskData['nGroupID'..i] == nGroupID then
            local nFlag = self._taskData['nFlag'..i]
            local nID   = self._taskData['nID'..i]
            return {
                nFlag   = nFlag,
                nID     = nID
            }
        end
    end

    return nil
end




function TaskModel:isRewardAvail()
    if self:IsHaveTaskFinishForGlobal() == true then
        return true
    end

    if cc.exports._TCYGameGuide and cc.exports._tcyGameTaskParam and cc.exports._tcyGameTaskParam.nTaskFlag == 1 then
        return true
    end

    return false
end

return TaskModel