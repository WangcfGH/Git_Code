local WeakenScoreRoomModel = class('WeakenScoreRoomModel')

local json = cc.load("json").json
local UserModel = mymodel('UserModel'):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()

local WeakenScoreRoomReq = import('src.app.plugins.weakenscoreroom.WeakenScoreRoomReq')
local AssistModel        = mymodel('assist.AssistModel'):getInstance()
--local player             = mymodel('hallext.PlayerModel'):getInstance()
local user               = mymodel('UserModel'):getInstance()
local PublicInterface    = cc.exports.PUBLIC_INTERFACE
local treepack           = cc.load('treepack')
local event              = cc.load('event')

my.addInstance(WeakenScoreRoomModel)

local WeakenScoreRoomDef = {
    --查询积分场玩家当前积分和领奖情况
    ASSIT_GET_SCORE_INFO_FOR_PLAYER_REQ                   = 410031,
    ASSIT_GET_SCORE_INFO_FOR_PLAYER_RESP                  = 410032,

    --查询玩家积分场触发情况
    GR_GET_TRIGGER_INFO_FOR_SCORE_ROOM_REQ		          = 410403,--请求
    GR_GET_TRIGGER_INFO_FOR_SCORE_ROOM_RESP    	          = 410404,--回应
    GR_GET_TRIGGER_SCORE_ROOM_REQ    	                  = 410405,--触发
    --查询玩家连续登陆的当天累计局数
    GR_GET_BOUT_INFO_FOR_LOTTERY_REQ                      = 410401,
    GR_GET_BOUT_INFO_FOR_LOTTERY_RESP                     = 410402,
}

WeakenScoreRoomModel.EVENT_MAP = {
    ["WeakenScoreRoomModel_dealScoreInfoResp"] = "WeakenScoreRoomModel_dealScoreInfoResp",
    ["WeakenScoreRoomModel_dealTriggerInfoResp"] = "WeakenScoreRoomModel_dealTriggerInfoResp",
    ["WeakenScoreRoomModel_dealBoutInfoResp"] = "WeakenScoreRoomModel_dealBoutInfoResp",
    ["WeakenScoreRoomModel_refreshBtn"] = "WeakenScoreRoomModel_refreshBtn"
}

function WeakenScoreRoomModel:ctor()
    event:create():bind(self)

    self._assistResponseMap = {
        [WeakenScoreRoomDef.ASSIT_GET_SCORE_INFO_FOR_PLAYER_RESP] = handler(self, self.dealScoreInfoResp),
        [WeakenScoreRoomDef.GR_GET_TRIGGER_INFO_FOR_SCORE_ROOM_RESP] = handler(self, self.onRefreshTriggerInfo),
        [WeakenScoreRoomDef.GR_GET_BOUT_INFO_FOR_LOTTERY_RESP] = handler(self, self.dealBoutInfoForLottery)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)

    self.nBoutNum = 0
    self.nBoutDate = 0
    self.nUserID = nil
    self.numLimt = 0

    --self:listenTo(player, player.PLAYER_DATA_UPDATED, handler(self, self.setMobile))
end

function WeakenScoreRoomModel:dealAssistResponse(dataMap)
    print(self.__cname..":dealAssistResponse")
    local responseId, responseData = unpack(dataMap.value)

    if self._assistResponseMap == nil then
        print("no assistResponseMap defined!!!")
        return
    end

    local handlerFunc = self._assistResponseMap[responseId]
    if handlerFunc then
        handlerFunc(responseData)
    else
        printf('onDataReceived other = '..tostring(responseId))
    end
end

function WeakenScoreRoomModel:isResponseID(responseId)
    if self._assistResponseMap == nil then
        print("no assistResponseMap defined!!!")
        return false
    end

    if self._assistResponseMap[responseId] then
        return true
    end

    return false
end

function WeakenScoreRoomModel:sendGetScoreInfoForPlayer()--查询积分场玩家当前积分和领奖情况
    self:_senRequest(WeakenScoreRoomDef.ASSIT_GET_SCORE_INFO_FOR_PLAYER_REQ)
end

function WeakenScoreRoomModel:sendGetTriggerInfo()--查询玩家积分场触发情况
    self:_senRequest(WeakenScoreRoomDef.GR_GET_TRIGGER_INFO_FOR_SCORE_ROOM_REQ)
end
function WeakenScoreRoomModel:sendTriggerScoreRoom()--玩家触发积分场
    self:_senRequest(WeakenScoreRoomDef.GR_GET_TRIGGER_SCORE_ROOM_REQ)
end

function WeakenScoreRoomModel:_senRequest(msg_type)
    local SCORE_INFO_FOR_PLAYER_REQ = WeakenScoreRoomReq["SCORE_INFO_FOR_PLAYER_REQ"]
    local data      = {
        nUserID     = PublicInterface:GetPlayerInfo().nUserID
    }

    local pData = treepack.alignpack(data, SCORE_INFO_FOR_PLAYER_REQ)
    AssistModel:sendData(msg_type, pData)
end

function WeakenScoreRoomModel:dealScoreInfoResp(data)
    printf('deal dealScoreInfoResp resp')
    local SCORE_INFO_FOR_PLAYER_RESP = WeakenScoreRoomReq["SCORE_INFO_FOR_PLAYER_RESP"]
    local msgScoreResultInfo = treepack.unpack(data, SCORE_INFO_FOR_PLAYER_RESP)

    cc.exports.nScoreInfo.nScore  = msgScoreResultInfo.nScore --积分场的积分
    cc.exports.nScoreInfo.nReward = msgScoreResultInfo.nReward --积分场的奖励
    cc.exports.nScoreInfo.nDate   = msgScoreResultInfo.nDate --积分场的奖励

    self.nUserID = msgScoreResultInfo.nUserID

    if cc.exports.nScoreInfoNeedResponse == 0 then
        cc.exports.nScoreInfoNeedResponse = 1
        --cc.load('MainCtrl'):getInstance():onScoreRoomBtn()
        -- 新大厅这边用下面的方式 调用原来的onScoreRoomBtn逻辑
        self:dispatchEvent({name = WeakenScoreRoomModel.EVENT_MAP["WeakenScoreRoomModel_dealScoreInfoResp"], value = {["isInGame"] = nil}})
    end

    self:dispatchEvent({name = WeakenScoreRoomModel.EVENT_MAP["WeakenScoreRoomModel_refreshBtn"]})
    dump(cc.exports.nScoreInfo, "dealScoreInfoResp nScoreInfo")
end
function WeakenScoreRoomModel:onRefreshTriggerInfo(data)
    printf('send LIMIT TIME GIFT TRIG resp')
    local TRIGGER_INFO_FOR_SCORE_ROOM_RESP = WeakenScoreRoomReq["TRIGGER_INFO_FOR_SCORE_ROOM_RESP"]
    local triggerResp = treepack.unpack(data, TRIGGER_INFO_FOR_SCORE_ROOM_RESP)
    cc.exports.nScoreInfo.nTrigger  = triggerResp.nTrigger
    cc.exports.nScoreInfo.nTriggerDate   = triggerResp.nDate

    local channelId = BusinessUtils:getInstance():getTcyChannel()
    if not cc.exports._gameJsonConfig.WeakenScoreRoom then return end
    local boutLimit = cc.exports._gameJsonConfig.WeakenScoreRoom.BoutLimit

    if not ((not cc.exports.isChannelWeakenScoreRoomBoutLimit(channelId))
        or (not boutLimit)
        or (boutLimit == 0)
        or (user.nBout < boutLimit)) then

        cc.exports.nScoreInfo.nTrigger = 0
        cc.exports.nScoreInfo.nTriggerDate = 0
    end

    --如果积分场积分数据没有，或者是0，或者2者的日期不是同一天，或者切换用户，请求
    if cc.exports.nScoreInfo.nScore == nil or cc.exports.nScoreInfo.nScore == 0 
        or (cc.exports.nScoreInfo.nDate and os.date("%Y-%m-%d", cc.exports.nScoreInfo.nTriggerDate) ~= os.date("%Y-%m-%d", cc.exports.nScoreInfo.nDate)) 
        or (self.nUserID ~= triggerResp.nUserID)then
        self:sendGetScoreInfoForPlayer()--查询积分场积分和领奖情况
    else
        if cc.exports.nScoreInfoNeedResponse == 0 then
            cc.exports.nScoreInfoNeedResponse = 1
            self:dispatchEvent({name = WeakenScoreRoomModel.EVENT_MAP["WeakenScoreRoomModel_dealScoreInfoResp"], value = {["isInGame"] = nil}})
        end
    end
    dump(cc.exports.nScoreInfo, "onRefreshTriggerInfo nScoreInfo")
end

--可以进入积分房的条件：低保和银两是否符合要求
function WeakenScoreRoomModel:onCheckSliverStatus()
    local user=mymodel('UserModel'):getInstance()
    if not user.nSafeboxDeposit or not user.nDeposit then
        return false
    end

    local nDeposit = user:getSafeboxDeposit() + user.nDeposit
    local relief = mymodel('hallext.ReliefActivity'):getInstance()

    if relief.state == relief.USED_UP and cc.exports.gameReliefData and cc.exports.gameReliefData.config and nDeposit < cc.exports.gameReliefData.config.Limit.LowerLimit then
        return true
    end

    return false
end

--可以进入积分房的条件：1.没有打开限制 2.有限制，但已经触发，并且没有领奖，需要校验时间
function WeakenScoreRoomModel:onCheckTriggerLimitStatus()
    if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
        if cc.exports.nScoreInfo.nTrigger and cc.exports.nScoreInfo.nScore then
            if cc.exports.nScoreInfo.nTrigger == 1 and cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score then
                if  os.date("%Y-%m-%d", cc.exports.nScoreInfo.nTriggerDate) == os.date("%Y-%m-%d", os.time())  then
                    return true
                end
            end
            
        end
    elseif cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 0 then
        return true
    end
    return false
end

--可以进入积分房的条件：1.没有打开限制 2.有限制，但已经触发，并且没有领奖
--不校验时间，按照服务器返回的为准，为了解决手机时间与服务器不同步，或者开启自然天
function WeakenScoreRoomModel:onCheckTriggerLimitStatusAgain()
    if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
        if cc.exports.nScoreInfo.nTrigger and cc.exports.nScoreInfo.nScore then
            if cc.exports.nScoreInfo.nTrigger == 1 and cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score then
                return true
            end
            
        end
    elseif cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 0 then
        return true
    end
    return false
end

--判断需不需要连接服务器，重新校验
function WeakenScoreRoomModel:onCheckStatusFromServer()
    if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
        if cc.exports.nScoreInfo.nTrigger then
            if os.date("%Y-%m-%d", cc.exports.nScoreInfo.nTriggerDate) ~= os.date("%Y-%m-%d", os.time())  then
                return true
            end
        else
            return true
        end
    end
    return false
end

--获取活动开关
function WeakenScoreRoomModel:onGetWeakOpen()
    if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 0 then
        return false
    end
    return true
end
--检查获奖情况
function WeakenScoreRoomModel:onCheckScore()
    if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
        if cc.exports.nScoreInfo.nTrigger and cc.exports.nScoreInfo.nScore then
            if cc.exports.nScoreInfo.nTrigger == 1 and cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports.nScoreInfo.nScore >= cc.exports._gameJsonConfig.WeakenScoreRoom.Score then
                if  os.date("%Y-%m-%d", cc.exports.nScoreInfo.nTriggerDate) == os.date("%Y-%m-%d", os.time())  then
                    return true
                end
            end
        end
    end
    return false
end

function WeakenScoreRoomModel:sendGetBoutInfoForLottery() --查询玩家的当天累计局数，仅用于银子场
    local SCORE_INFO_FOR_PLAYER_REQ = WeakenScoreRoomReq["SCORE_INFO_FOR_PLAYER_REQ"]
    local data      = {
        nUserID     = PublicInterface.GetPlayerInfo().nUserID
    }

    local pData = treepack.alignpack(data, SCORE_INFO_FOR_PLAYER_REQ)
    AssistModel:sendData(WeakenScoreRoomDef.GR_GET_BOUT_INFO_FOR_LOTTERY_REQ, pData)
end

function WeakenScoreRoomModel:dealBoutInfoForLottery(data)
    local BOUT_INFO_FOR_TODAY_RESP = WeakenScoreRoomReq["BOUT_INFO_FOR_TODAY_RESP"]
    local expressionLottery = treepack.unpack(data, BOUT_INFO_FOR_TODAY_RESP)

    self.nBoutNum = expressionLottery.nBout
    self.nBoutDate = expressionLottery.nDate
end

function WeakenScoreRoomModel:onGetBoutInfo()
    return self.nBoutNum, self.nBoutDate
end

function WeakenScoreRoomModel:onAddBoutInfo()
    self.nBoutNum = self.nBoutNum + 1
end

--可以跳转进去积分房的条件：有限制，1.已经触发，并且没有领奖，局数<X，2.没有触发，局数<X，触发
function WeakenScoreRoomModel:onCheckJumpStatus()
    dump(cc.exports._gameJsonConfig.WeakenScoreRoom, "WeakenScoreRoom")
    dump(cc.exports.nScoreInfo, "nScoreInfo")

    if cc.exports._gameJsonConfig.WeakenScoreRoom 
    and cc.exports._gameJsonConfig.WeakenScoreRoom.Open 
    and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
        if cc.exports.nScoreInfo.nTrigger 
        and cc.exports.nScoreInfo.nScore then
            if cc.exports.nScoreInfo.nTrigger == 1  then
                if  os.date("%Y-%m-%d", cc.exports.nScoreInfo.nTriggerDate) == os.date("%Y-%m-%d", os.time()) then
                    if cc.exports._gameJsonConfig.WeakenScoreRoom.Score 
                    and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score then
                        return true
                    end
                else   --时间对不上
                    self:sendGetTriggerInfo()--查询玩家积分场触发情况
                    return true
                end
            elseif cc.exports.nScoreInfo.nTrigger == 0 then
                local boutNum = cc.exports._gameJsonConfig.WeakenScoreRoom.BoutNum
                if (boutNum and self.nBoutNum < boutNum) then
                    self:sendTriggerScoreRoom()--玩家触发积分场
                    return true
                end
            end
        end
    end
    return false
end


--玩家银两变化是查询，能否触发，1.未触发，去svr触发 2.已触发，是否还能进入
function WeakenScoreRoomModel:onPlayerDepositChange()
    if not cc.exports._gameJsonConfig or not cc.exports._gameJsonConfig.WeakenScoreRoom  
    or not cc.exports.nScoreInfo.nTrigger 
    or self.nUserID ~= user.nUserID then
        self.numLimt = self.numLimt + 1
        my.scheduleOnce(function()
            if self.numLimt < 4 then
                self:onPlayerDepositChange()
            end
        end, 2.0)
        return
    end
    local config = cc.exports.GetRoomConfig()

    local function popSureDialog()
        local lastNoticeTime = CommonData:getUserData("scoreRoom_lastNoticeTime")
        if lastNoticeTime and DateUtil:isTodayTime(lastNoticeTime) then
            return
        else
            CommonData:setUserData("scoreRoom_lastNoticeTime", os.time())
            CommonData:saveUserData()
        end
        my.informPluginByName({
            pluginName = "SureDialog",
            params =
            {
                tipContent  = string.format(config['SCORE_ROOM_SCORE_IN'], cc.exports._gameJsonConfig.WeakenScoreRoom.Score),
                onOk        = function() end
            }
        })
    end


    if self:onCheckSliverStatus() then  --先检查是否破产
        if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
            if cc.exports.nScoreInfo.nTrigger and cc.exports.nScoreInfo.nScore then
                if cc.exports.nScoreInfo.nTrigger == 1  then
                    if  os.date("%Y-%m-%d", cc.exports.nScoreInfo.nTriggerDate) == os.date("%Y-%m-%d", os.time()) then
                        if cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score then
                            if not my.isInGame() then  --游戏内不处理
                                local sureDialog = cc.Director:getInstance():getRunningScene():getChildByName("SureDialog")
                                if tolua.isnull(sureDialog) then  --防止覆盖断线续玩
                                    popSureDialog()
                                end
                            end
                         end
                    else
                        self:sendGetTriggerInfo()--玩家积分场重新获取

                        my.scheduleOnce(function()
                            if cc.exports.nScoreInfo.nTrigger == 1  then
                                if cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score then
                                    if not my.isInGame() then  --游戏内不处理
                                        local sureDialog = cc.Director:getInstance():getRunningScene():getChildByName("SureDialog")
                                        if tolua.isnull(sureDialog) then  --防止覆盖断线续玩
                                            popSureDialog()
                                        end
                                    end
                                end
                            end
                        end, 1)
                    end
                elseif cc.exports.nScoreInfo.nTrigger == 0 then
                    local boutNum = cc.exports._gameJsonConfig.WeakenScoreRoom.BoutNum
                    if (boutNum and self.nBoutNum < boutNum)then
                        self:sendTriggerScoreRoom()--玩家触发积分场
                        
                        my.scheduleOnce(function()
                            if cc.exports.nScoreInfo.nTrigger == 1  then
                                if  os.date("%Y-%m-%d", cc.exports.nScoreInfo.nTriggerDate) == os.date("%Y-%m-%d", os.time()) then
                                    if cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score then
                                        if not my.isInGame() then  --游戏内不处理
                                            local sureDialog = cc.Director:getInstance():getRunningScene():getChildByName("SureDialog")
                                            if tolua.isnull(sureDialog) then  --防止覆盖断线续玩
                                                popSureDialog()
                                            end
                                        end
                                    end
                                end
                            end
                        end, 1)
                    end
                end
            end
        end
    end
end

return WeakenScoreRoomModel