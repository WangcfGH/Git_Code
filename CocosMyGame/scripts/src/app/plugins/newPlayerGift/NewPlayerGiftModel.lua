local NewPlayerGiftModel =class('NewPlayerGiftModel',require('src.app.GameHall.models.BaseModel'))
-- local AssistConnect         = import('src.app.plugins.AssistModel.AssistConnect')
-- local AssistReq             = import('src.app.plugins.AssistModel.AssistReq')
local Def                       = import('src.app.plugins.newPlayerGift.NewPlayerGiftDef')
local Req                       = import('src.app.plugins.newPlayerGift.NewPlayerGiftReq')

local treepack              = cc.load('treepack')
local json                  = cc.load("json").json
local StringConfig          = json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/NewPlayerGiftString.json"))
local user                  = mymodel('UserModel'):getInstance()
local AssistModel = mymodel('assist.AssistModel'):getInstance()

-- my.addInstance(NewPlayerGiftModel)

NewPlayerGiftModel.EVENT_GIFT_INFO_UPDATE = "EVENT_GIFT_INFO_UPDATE"
NewPlayerGiftModel.EVENT_GIFT_REWARD_GOT = "EVENT_GIFT_REWARD_GOT"

NewPlayerGiftModel.TYPE_SILVER = 1       --银子
NewPlayerGiftModel.TYPE_TICKET = 4       --礼券

NewPlayerGiftModel.ERROR_CODE =
{
    NEWPLAYER_GIFT_REDIS_ERROR = -1,        --redis错误
    NEWPLAYER_GIFT_INDEX_INVALID = -2,      --对应天数没有奖励
    NEWPLAYER_GIFT_JSON_PARSE_ERROR = -3,   --json解析错误
    NEWPLAYER_GIFT_COUNT_ERROR = -4,        --领取数量与配置不符
    NEWPLAYER_GIFT_REWARDED = -5,           --今天已经领过礼包
    NEWPLAYER_GIFT_SOAP_ERROR = -6,         --soap调用失败
    NEWPLAYER_GIFT_INVALID_RESULT = -7,     --无效的返回结果
}

NewPlayerGiftModel.EVENT_MAP = {
    ["newPlayerGiftModel_rewardAvailChanged"] = "newPlayerGiftModel_rewardAvailChanged"
}

function NewPlayerGiftModel:onCreate()
    --local event = cc.load('event')
    --event:create():bind(self)
    self._info = nil
    self._config = nil

    self._assistResponseMap = {
        [Def.GR_NEWPLAYER_GIFT_INFO_RESP] = handler(self, self.onReturnNewPlayerGiftInfo),
        [Def.GR_GET_NEWPLAYER_GIFT_RESP] = handler(self, self.getNewPlayerGiftRsp)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function NewPlayerGiftModel:reset()
    self._info = nil
    self._config = nil
end

--------------------------------------------------------------------------------------------------------
--消息接口
--新手礼包信息请求
function NewPlayerGiftModel:newPlayerGiftInfoReq()
    if self._isWaitingInfo then return end
    self._isWaitingInfo = true
    my.scheduleOnce(function()
        self._isWaitingInfo = false
    end, 2)
    
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data      = {
        nUserID     = user.nUserID,
    }

    AssistModel:sendRequest(Def.GR_NEWPLAYER_GIFT_INFO_REQ, Req.NEWPLAYER_GIFT_INFO_REQ, data, false)
end

--新手礼包领取请求
function NewPlayerGiftModel:getNewPlayerGiftReq()
    if self._isWaitingGift then return end
    self._isWaitingGift = true
    my.scheduleOnce(function()
        self._isWaitingGift = false
    end, 2)

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    if not self._info or not self._config then return end
    if not self._info.nGiftIndex then return end
    local nGiftIndex = self._info.nGiftIndex
    if nGiftIndex < 1 then return end
    
    if nGiftIndex > #self._config["newPlayerGiftConfig"] then return end
    local nCount = self._config["newPlayerGiftConfig"][nGiftIndex]["count"]

    local data      = {
        nUserID     = user.nUserID,
        nGiftIndex  = nGiftIndex,
        nCount      = nCount,
        kpiClientData = AssistModel:getKPIClientData()
    }
    AssistModel:sendRequest(Def.GR_GET_NEWPLAYER_GIFT_REQ, Req.GET_NEWPLAYER_GIFT_REQ, data, false)
end

--新手礼包信息回应
function NewPlayerGiftModel:onReturnNewPlayerGiftInfo(data)
    self._isWaitingInfo = false

    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    self:parseNewPlayerGiftInfo(data)
end

--新手礼包领取回应
function NewPlayerGiftModel:getNewPlayerGiftRsp(data)
    self._isWaitingGift = false
    self:onGetNewPlayerGift(data)
end

--------------------------------------------------------------------------------------------------------
--收到回应的处理接口
--接收到新手礼包信息和配置
function NewPlayerGiftModel:parseNewPlayerGiftInfo(data)
    print("NewPlayerGiftModel:parseNewPlayerGiftInfo")
    local mainctrl = cc.load('MainCtrl'):getInstance()
    if not mainctrl then return end
    local PublicInterface = cc.exports.PUBLIC_INTERFACE
    if not PublicInterface then return end
    local playerInfo = PublicInterface.GetPlayerInfo()
    if not playerInfo then return end

    local newPlayerGiftInfo,data = AssistModel:convertDataToStruct(data,Req["NEWPLAYER_GIFT_INFO_RESP"])
    if not newPlayerGiftInfo then return end
    dump(newPlayerGiftInfo)

    self._info = newPlayerGiftInfo
    if newPlayerGiftInfo.nGiftIndex > 0 and string.len(data) ~= 0 then
        --有新手礼包
        self._config = cc.load("json").json.decode(data)
        dump(self._config)
        --登录弹窗模块
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:setPluginReadyStatus("NewPlayerGiftCtrl",true)
        PluginProcessModel:startPluginProcess()        
    else
        --登录弹窗模块
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:setPluginReadyStatus("NewPlayerGiftCtrl",false)
        PluginProcessModel:startPluginProcess() 
    end

    self:dispatchEvent({name = self.EVENT_GIFT_INFO_UPDATE})

    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self._myStatusDataExtended["isPluginAvail"] = self:isPluginAvail()
    self:dispatchModuleStatusChanged("newPlayerGift", NewPlayerGiftModel.EVENT_MAP["newPlayerGiftModel_rewardAvailChanged"])
end

--收到领取礼包结果
function NewPlayerGiftModel:onGetNewPlayerGift(data)
    print("NewPlayerGiftModel:onGetNewPlayerGift")
    local giftResult = AssistModel:convertDataToStruct(data,Req["GET_NEWPLAYER_GIFT_RESP"])
    if not giftResult then return end
    dump(giftResult)

    if giftResult.nResult == 0 then
        --更新玩家银子和礼券
        local giftIndex = self:getGiftIndex()
        local giftConfig = self._config["newPlayerGiftConfig"]
        local ItemInfo = giftConfig[giftIndex]
        self:updateUserInfo(ItemInfo)

        --礼包领取成功，弹出领取动画
        local rewardList = {}
        if ItemInfo.type == NewPlayerGiftModel.TYPE_SILVER then
            table.insert(rewardList, {nType = 1,nCount = ItemInfo.count})
        elseif ItemInfo.type == NewPlayerGiftModel.TYPE_TICKET then
            table.insert(rewardList, {nType = 2,nCount = ItemInfo.count})
        end
        --弹出奖励界面
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList}})
        
        --self:dispatchEvent({name = self.EVENT_GIFT_REWARD_GOT,value = self._info.nGiftIndex})
        local totalDays = self._config["newPlayerDays"]
        local nGiftIndex = self._info.nGiftIndex
        if nGiftIndex >= totalDays then
            self._info.nGiftIndex = 0
        else
            self._info.nGiftIndex = nGiftIndex + 1
            self._info.nGiftTime = giftResult.nGiftTime
        end
        self:dispatchEvent({name = self.EVENT_GIFT_INFO_UPDATE})

        self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
        self._myStatusDataExtended["isPluginAvail"] = self:isPluginAvail()
        self:dispatchModuleStatusChanged("newPlayerGift", NewPlayerGiftModel.EVENT_MAP["newPlayerGiftModel_rewardAvailChanged"])
    else
        --礼包领取失败，提示错误信息
        local nResult = giftResult.nResult
        local ERRORS = NewPlayerGiftModel.ERROR_CODE
        local tipString = nil

        if nResult == ERRORS.NEWPLAYER_GIFT_REDIS_ERROR then
            tipString = StringConfig.NEWPLAYER_GIFT_REDIS_ERROR
        elseif nResult == ERRORS.NEWPLAYER_GIFT_INDEX_INVALID then
            tipString = StringConfig.NEWPLAYER_GIFT_INDEX_INVALID
        elseif nResult == ERRORS.NEWPLAYER_GIFT_JSON_PARSE_ERROR then
            tipString = StringConfig.NEWPLAYER_GIFT_JSON_PARSE_ERROR
        elseif nResult == ERRORS.NEWPLAYER_GIFT_COUNT_ERROR then
            tipString = StringConfig.NEWPLAYER_GIFT_COUNT_ERROR
        elseif nResult == ERRORS.NEWPLAYER_GIFT_REWARDED then
            tipString = StringConfig.NEWPLAYER_GIFT_REWARDED
        elseif nResult == ERRORS.NEWPLAYER_GIFT_SOAP_ERROR then
            tipString = StringConfig.NEWPLAYER_GIFT_SOAP_ERROR
        else 
            tipString = StringConfig.NEWPLAYER_GIFT_INVALID_RESULT
        end
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
    end
end

--------------------------------------------------------------------------------------------------------
--[Comment]
--数据解析成table,并返回剩余的数据
function NewPlayerGiftModel:convertDataToStruct(data,struct_name)
    if data == nil then return nil, nil end

    local structDesc = AssistReq[struct_name]
    if structDesc then
        return treepack.unpack(data, structDesc), string.sub(data, structDesc.maxsize + 1)
    else
        return nil,nil
    end
end

--[Comment]
--返回新手礼包配置,礼包的天数、每天的物品和数量
function NewPlayerGiftModel:getGiftConfig()
    return self._config
end

--[Comment]
--返回新手礼包信息，第几天的礼包、是否可领
function NewPlayerGiftModel:getGiftInfo()
    return self._info
end

--[Comment]
--返回当前可领第几个礼包
function NewPlayerGiftModel:getGiftIndex()
    if self._info then
        return self._info.nGiftIndex
    end
end

--[Comment]
--更新玩家银子和礼券的信息
function NewPlayerGiftModel:updateUserInfo(ItemInfo)
    if not ItemInfo then return end

    if ItemInfo.type == NewPlayerGiftModel.TYPE_SILVER then
        local playerModel = mymodel("hallext.PlayerModel"):getInstance()
        playerModel:addGameDeposit(ItemInfo.count)
    elseif ItemInfo.type == NewPlayerGiftModel.TYPE_TICKET then
        my.scheduleOnce( function()
            require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance():getTicketNum()
        end,0.8)
    end
end

function NewPlayerGiftModel:isRewardAvail()
    local info = self:getGiftInfo()
    local config = self:getGiftConfig()
    if not info or not config then
        return false
    end

    if info.nGiftIndex and info.nGiftIndex > 0 and info.nGiftIndex <= config.newPlayerDays then
        
    else
        return false
    end

    if (os.time() > info.nGiftTime) and (os.date('%d',os.time()) ~= os.date('%d',info.nGiftTime)) or info.nGiftTime == 0 then
        return true
    end

    return false
end

function NewPlayerGiftModel:isPluginAvail()
    local info = self:getGiftInfo()
    local config = self:getGiftConfig()
    if not info or not config then
        return false
    end

    if info.nGiftIndex and info.nGiftIndex > 0 and info.nGiftIndex <= config.newPlayerDays then
        return true
    end

    return false
end

return NewPlayerGiftModel