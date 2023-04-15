local ExchangeCenterModel = class("ExchangeCenterModel", require('src.app.GameHall.models.BaseModel'))
local ExchangeCenterConfig = cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ExchangeCenterConfig.json"))
if BusinessUtils:getInstance():isGameDebugMode() then
    ExchangeCenterConfig = cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ExchangeCenterConfig_Debug.json"))
end
local UserModel = mymodel('UserModel'):getInstance()
local PlayerInfo         	= mymodel('hallext.PlayerModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local ExchangeCenterReq = import('src.app.plugins.ExchangeCenter.ExchangeCenterReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local treepack          = cc.load('treepack')
local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()

local event=cc.load('event')
event:create():bind(ExchangeCenterModel)

ExchangeCenterModel.EXCHANGE_CENTER_OPEN_STATUS_UPDATED = "EXCHANGE_CENTER_OPEN_STATUS_UPDATED"

ExchangeCenterModel.TICKET_LEFT_NUM_UPDATED = "TICKET_LEFT_NUM_UPDATED"
ExchangeCenterModel.TICKET_ITEM_LIST_UPDATED = "TICKET_ITEM_LIST_UPDATED"
ExchangeCenterModel.MY_TICKET_RECORD_UPDATED = "MY_TICKET_RECORD_UPDATED"

ExchangeCenterModel.EXCHANGE_CENTER_UPDATE_RICH = "EXCHANGE_CENTER_UPDATE_RICH"

ExchangeCenterModel.EXCHANGE_SILVER_OK = "EXCHANGE_SILVER_OK"
ExchangeCenterModel.EXCHANGE_TOOL_OK = "EXCHANGE_TOOL_OK"
ExchangeCenterModel.EXCHANGE_MOBILE_BILL_OK = "EXCHANGE_MOBILE_BILL_OK"
ExchangeCenterModel.EXCHANGE_REAL_ITEM_OK = "EXCHANGE_REAL_ITEM_OK"
ExchangeCenterModel.EXCHANGE_BROADCARST = "EXCHANGE_BROADCARST"
ExchangeCenterModel.EXCHANGE_CUSTOMPROP_OK = "EXCHANGE_CUSTOMPROP_OK"

--兑换券明细
ExchangeCenterModel.TICKET_RECORD_REWARD = 1  --奖励获得
ExchangeCenterModel.TICKET_RECORD_EXCHANGE = 2  --兑换消耗
ExchangeCenterModel.TICKET_RECORD_EXPIRE = 3  --过期消耗

ExchangeCenterModel.EXCHANGEITEM_TYPE_CUSTOMPROP = 4 --自定义道具
ExchangeCenterModel.EXCHANGEITEM_TYPE_SILVER = 1 --银子
ExchangeCenterModel.EXCHANGEITEM_TYPE_CELLPHONE = 2 --话费
ExchangeCenterModel.EXCHANGEITEM_TYPE_ENTITY = 3 --实物

ExchangeCenterModel.prizeIdToCustomPropId = {
    [185] = 1001,
    [186] = 1002,
    [187] = 1003
}

ExchangeCenterModel.customPropIdToPrizeId = {
    [1001] = 185,
    [1002] = 186,
    [1003] = 187
}

if BusinessUtils:getInstance():isGameDebugMode() then
    ExchangeCenterModel.prizeIdToCustomPropId = {
        [245] = 1001,
        [246] = 1002,
        [247] = 1003
    }

    ExchangeCenterModel.customPropIdToPrizeId = {
        [1001] = 245,
        [1002] = 246,
        [1003] = 247
    }
end

local ExchangeCenterDef = {
    GR_EXCHANGE_CENTER_BROAD_CAST = 409011, -- 兑换中心结果广播请求，给assistsvr
    GR_EXCHANGE_CARDMARKER_REQ = 410204,
    GR_EXCHANGE_CARDMARKER_RESP = 410205
}

ExchangeCenterModel.EVENT_MAP = {
    ["ExchangeCenterModel_rewardAvailChanged"] = "ExchangeCenterModel_rewardAvailChanged"
}

function ExchangeCenterModel:onCreate()
    self.exchConfig = ExchangeCenterConfig
    self._ticketLeftNum = 0
    self._ticketItemList = ExchangeCenterConfig["Product"] or {}--默认为本地兑换物品配置.只要用到兑换物品相关就用这个
    self._myTicketRecord = {}

    self._isOpen = false

    self._assistResponseMap = {
        [ExchangeCenterDef.GR_EXCHANGE_CARDMARKER_RESP] = handler(self, self.dealWithExchangeCustomPropResult)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function ExchangeCenterModel:getTicketBaseUrl()
	local baseUrl
	if BusinessUtils:getInstance():isGameDebugMode() then
		baseUrl = 'http://exchangemall.uc108.org:1505/mobile/'
	else
		baseUrl = 'https://exchangemall.tcy365.com/mobile/'
	end
	return baseUrl
end

function ExchangeCenterModel:getTicketActivityId()
    local ticketGuid
	if BusinessUtils:getInstance():isGameDebugMode() then
		ticketGuid = "8e6d2200-f550-4d33-998e-c3eaa9f5df58"
	else
		ticketGuid = "81294c44-e986-4ea5-8a32-b3fdbf91bf8f"
	end
	return ticketGuid
end

function ExchangeCenterModel:getTicketNum()
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local userId = playerInfo.nUserID
    local gameId = my.getGameID()

    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local tokenId = userPlugin:getAccessToken()
    local url = self:getTicketBaseUrl()
    url = url.."UserTickets/GetLeftNum?UserID="..userId.."&GameID="..gameId.."&UserToken="..tokenId

    print(tokenId)
    print(url)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    xhr:open("GET", url)

    local function onGetTicketNumOk()
        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            print("Get Ticket Num Success")
            local appJsonObj = json.decode(xhr.response)
            self:parseGetTicketNumResponse(appJsonObj)
            self:dispatchEvent({name = ExchangeCenterModel.TICKET_LEFT_NUM_UPDATED})

            self._myStatusDataExtended["isNeedReddot"] = self:isNeedReddot()
            self:dispatchModuleStatusChanged("ExchangeCenterModel", ExchangeCenterModel.EVENT_MAP["ExchangeCenterModel_rewardAvailChanged"])
        end
    end

    xhr:registerScriptHandler(onGetTicketNumOk)
    xhr:send()
end

function ExchangeCenterModel:parseGetTicketNumResponse(obj)
    local status = obj["Status"]
    local code = obj["Code"]
    local message = obj["Message"]
    local data = obj["Data"]
    print("parseGetTicketNumResponse data", data)
    dump(obj)

    if status then
        self._ticketLeftNum = data
        self._exchTicketUpdateTime = os.time() --记录最新更新时间
    else
    end
end

function ExchangeCenterModel:getTicketItemList()
    local url = self:getTicketBaseUrl()
    local guid = self:getTicketActivityId()

    url = url.."Activity/GetActivityItemList?activityGuid="..guid

    print(url)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    xhr:open("GET", url)

    local function onGetTicketItemListOk()
        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            print("Get Ticket ItemList Success")
            local appJsonObj = json.decode(xhr.response)
            self:parseGetTicketItemListResponse(appJsonObj)
            self:dispatchEvent({name = ExchangeCenterModel.TICKET_ITEM_LIST_UPDATED})
        end
    end

    xhr:registerScriptHandler(onGetTicketItemListOk)
    xhr:send()
end

function ExchangeCenterModel:parseGetTicketItemListResponse(obj)
    local status = obj["Status"]
    local code = obj["Code"]
    local message = obj["Message"]
    local data = obj["Data"]
    print("parseGetTicketItemListResponse")
    dump(data)
    
    if status then   
        for i, localItem in ipairs(self._ticketItemList) do --更新本地兑换物品配置信息
            for j, netItem in ipairs(data) do
                if localItem["prizeID"] == netItem["PrizeID"] then
                    localItem["price"] = netItem["Price"]
                    localItem["isAvailable"] = true --加有效字段
                    localItem["prizeName"] = netItem["PrizeName"]
                    if netItem["ImageUrl"] and netItem["ImageUrl"] ~= "" then
                        localItem["ImageUrl"] = netItem["ImageUrl"]
                    end
                end
            end
        end              
    else

    end
end

function ExchangeCenterModel:getNewExchangeRecord()
    local url = self:getTicketBaseUrl()
    local guid = self:getTicketActivityId()

    url = url.."Activity/GetNewExchangeRecord?activityGuid="..guid

    print(url)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    xhr:open("GET", url)

    local function onGetNewExchangeRecordOk()
        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            print("Get NewExchangeRecord Success")
            local appJsonObj = json.decode(xhr.response)
            self:parseGetNewExchangeRecordResponse(appJsonObj)
        end
    end

    xhr:registerScriptHandler(onGetNewExchangeRecordOk)
    xhr:send()
end

function ExchangeCenterModel:parseGetNewExchangeRecordResponse(obj)
    local status = obj["Status"]
    local code = obj["Code"]
    local message = obj["Message"]
    local data = obj["Data"]
    
    if status then
        for i, var in pairs(data) do
            local UserName = var["UserName"]
            local PrizeName = var["PrizeName"]
        end
    else

    end
end

function ExchangeCenterModel:exchangeProp(prizeId, number)
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local userId = playerInfo.nUserID
    local url = self:getTicketBaseUrl()
    local guid = self:getTicketActivityId()
    local gameId = my.getGameID()

    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local tokenId = userPlugin:getAccessToken() 

    url = url.."Activity/ExchangeProp?ActivityGuid="..guid.."&PrizeID="..prizeId
    .."&Number="..number.."&UserID="..userId.."&UserToken="..tokenId.."&GameID="..gameId

    print(url)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    xhr:open("POST", url)

    local function onExchangePropOk()
        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            print("Exchange Prop Success")
            local appJsonObj = json.decode(xhr.response)
            self:parseExchangePropResponse(appJsonObj)
            self:dealWithExchangeToolResult(appJsonObj["Status"], appJsonObj["Message"], prizeId)          
        end
    end

    xhr:registerScriptHandler(onExchangePropOk)
    xhr:send()
end

function ExchangeCenterModel:parseExchangePropResponse(obj)
    local status = obj["Status"]
    local code = obj["Code"]
    local message = obj["Message"]
    local data = obj["Data"]
    
    if status then
       
    else

    end
end

function ExchangeCenterModel:exchangeRealItem(prizeId, number, mobile, recipients, address)
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local userId = playerInfo.nUserID
    local url = self:getTicketBaseUrl()
    local guid = self:getTicketActivityId()
    local gameId = my.getGameID()

    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local tokenId = userPlugin:getAccessToken() 

    local encodeRecipients = string.urlencode(recipients)
    local encodeAddress = string.urlencode(address)

    url = url.."Activity/ExchangeRealItem?ActivityGuid="..guid.."&PrizeID="..prizeId
    .."&Number="..number.."&UserID="..userId.."&UserToken="..tokenId
    .."&Mobile="..mobile.."&Recipients="..encodeRecipients.."&Address="..encodeAddress
    .."&GameID="..gameId

    print(url)

    self:addExchangeCount(prizeId, 1)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            xhr:setRequestHeader("GsClientData", gsClient);
        end
    end
    xhr:open("POST", url)

    local function onExchangeRealItemOk()
        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            print("Exchange RealItem Success")
            local appJsonObj = json.decode(xhr.response)
            self:parseExchangeRealItemResponse(appJsonObj)
            self:dealWithExchangeRealItemResult(appJsonObj["Status"], appJsonObj["Message"], prizeId)         

            if string.find(tostring(appJsonObj["Message"]), tostring("兑换物品库存不足")) ~= nil then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString="该商品今日已达库存上限,请明日再来",removeTime=1}})
            end

            local status = appJsonObj["Status"]
            if status then
                local nCount, nType = self:getCountByPriceID(prizeId)    --获取实物奖励
                local strPrizeName = self:getPrizeNameByPriceID(prizeId)
                local broadcastData = {}
                broadcastData.nUserID = userId
                broadcastData.nCount = nCount
                broadcastData.nType = nType
                broadcastData.prizeName = strPrizeName
                --self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_BROADCARST, data = broadcastData}) 
                self:sendExchangeBroadCastData(broadcastData)
            else
                print("ExchangeCenterModel:exchangeRealItem appJsonObj[\"Status\"] fail")
                self:addExchangeCount(prizeId, -1)
            end    
        else
            print("Exchange RealItem failed "..xhr.status)
            self:addExchangeCount(prizeId, -1)
        end
    end

    xhr:registerScriptHandler(onExchangeRealItemOk)
    xhr:send()
end

function ExchangeCenterModel:parseExchangeRealItemResponse(obj)
    local status = obj["Status"]
    local code = obj["Code"]
    local message = obj["Message"]
    local data = obj["Data"]
    
    if status then
       
    else

    end
end

function ExchangeCenterModel:exchangeMobileBill(prizeId, number, mobile)
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local userId = playerInfo.nUserID
    local url = self:getTicketBaseUrl()
    local guid = self:getTicketActivityId()
    local gameId = my.getGameID()

    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local tokenId = userPlugin:getAccessToken() 

    url = url.."Activity/ExchangeMobileBill?ActivityGuid="..guid.."&PrizeID="..prizeId
    .."&Number="..number.."&UserID="..userId.."&UserToken="..tokenId
    .."&Mobile="..mobile.."&GameID="..gameId

    print(url)
    self:addExchangeCount(prizeId, 1)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
     
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            xhr:setRequestHeader("GsClientData", gsClient);
        end
    end

    xhr:open("POST", url)

    local function onExchangeMobileBillOk()
        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            print("Exchange RealItem Success")
            local appJsonObj = json.decode(xhr.response)
            self:parseExchangeMobileBillResponse(appJsonObj)   
            self:dealWithExchangeMobileBillResult(appJsonObj["Status"], appJsonObj["Message"], prizeId)     
            
            if string.find(tostring(appJsonObj["Message"]), tostring("兑换物品库存不足")) ~= nil then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString="该商品今日已达库存上限,请明日再来",removeTime=1}})
            end

            local status = appJsonObj["Status"]
            if status then
                local nCount, nType = self:getCountByPriceID(prizeId)    --获取银子（话费）数量， 类型
                local broadcastData = {}
                broadcastData.nUserID = userId
                broadcastData.nCount = nCount
                broadcastData.nType = nType
                --self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_BROADCARST, data = broadcastData})  
                self:sendExchangeBroadCastData(broadcastData)
            else
                print("ExchangeCenterModel:exchangeMobileBill appJsonObj[\"Status\"] fail")
                self:addExchangeCount(prizeId, -1)
            end
        else
            print("Exchange MobileBill failed "..xhr.status)
            self:addExchangeCount(prizeId, -1)      
        end
    end

    xhr:registerScriptHandler(onExchangeMobileBillOk)
    xhr:send()
end

function ExchangeCenterModel:parseExchangeMobileBillResponse(obj)
    local status = obj["Status"]
    local code = obj["Code"]
    local message = obj["Message"]
    local data = obj["Data"]
    dump(obj)
    if status then
       
    else

    end
end

function ExchangeCenterModel:exchangeSilver(prizeId, number)
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local userId = playerInfo.nUserID
    local url = self:getTicketBaseUrl()
    local guid = self:getTicketActivityId()
    local gameId = my.getGameID()

    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local tokenId = userPlugin:getAccessToken() 

    url = url.."Activity/ExchangeSilver?ActivityGuid="..guid.."&PrizeID="..prizeId
    .."&Number="..number.."&UserID="..userId.."&UserToken="..tokenId
    .."&SilverTo="..tostring(4).."&GameID="..gameId

    print(url)
    
    self:addExchangeCount(prizeId, 1)
    
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            xhr:setRequestHeader("GsClientData", gsClient);
        end
    end
    xhr:open("POST", url)

    local function onExchangeSilverOk()
        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            print("Exchange Silver Success")
            local appJsonObj = json.decode(xhr.response)
            self:parseExchangeSilverResponse(appJsonObj)
            self:dealWithExchangeSilverResult(appJsonObj["Status"], appJsonObj["Message"], prizeId)       
            
            if string.find(tostring(appJsonObj["Message"]), tostring("兑换物品库存不足")) ~= nil then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString="该商品今日已达库存上限,请明日再来",removeTime=1}})
            end

            local status = appJsonObj["Status"]
            if status then
                local nCount, nType = self:getCountByPriceID(prizeId)    --获取银子（话费）数量， 类型
                local broadcastData = {}
                broadcastData.nUserID = userId
                broadcastData.nCount = nCount
                broadcastData.nType = nType
                --self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_BROADCARST, data = broadcastData})    
                self:sendExchangeBroadCastData(broadcastData)
            else
                print("ExchangeCenterModel:exchangeSilver appJsonObj[\"Status\"] fail")
                self:addExchangeCount(prizeId, -1)
            end
        else
            print("Exchange Silver failed "..xhr.status)
            self:addExchangeCount(prizeId, -1)
        end
    end
      
    xhr:registerScriptHandler(onExchangeSilverOk)
    xhr:send()
end

function ExchangeCenterModel:parseExchangeSilverResponse(obj)
    local status = obj["Status"]
    local code = obj["Code"]
    local message = obj["Message"]
    local data = obj["Data"]
    dump(obj)
    if status then
       
    else

    end
end

function ExchangeCenterModel:getMyTicketsRecord(recordType)
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    recordType = recordType or ExchangeCenterModel.TICKET_RECORD_EXCHANGE

    local userId = playerInfo.nUserID
    local url = self:getTicketBaseUrl()
    local gameId = my.getGameID()

    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local tokenId = userPlugin:getAccessToken() 
    --tokenId = '3SI-2EkO2dx8XAqJLp7XfdUUlgNe7ksBx3b1h53dFAN6f3uvlGEfEZczuVIEJRRUULIS8TiyxV6AQ1BAtlhCMi6Rfi_OuRsL_BhoSWP_sU7LB0HZPtBJvNMmldwGBVOTZRVe8PLBTZkIIddzHcTWJg'

    url = url.."UserTickets/GetMyTicketsRecord?UserID="..userId.."&UserToken="..tokenId
    .."&PageIndex="..tostring(1).."&GameID="..gameId.."&OperateType="..recordType

    print(url)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    xhr:open("GET", url)

    local function onGetMyTicketsRecordOk()
        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            print("Get MyTicketsRecord Success")
            local appJsonObj = json.decode(xhr.response)
            self:parseGetMyTicketsRecordResponse(appJsonObj)

            if appJsonObj and appJsonObj["Data"] and appJsonObj["Data"]["LogList"] and #appJsonObj["Data"]["LogList"] > 0 then
                self:dispatchEvent({name = ExchangeCenterModel.MY_TICKET_RECORD_UPDATED})
            end
        end
    end
    
    xhr:registerScriptHandler(onGetMyTicketsRecordOk)
    xhr:send()
end

function ExchangeCenterModel:parseGetMyTicketsRecordResponse(obj)
    local status = obj["Status"]
    local code = obj["Code"]
    local message = obj["Message"]
    local data = obj["Data"]
    print("parseGetMyTicketsRecordResponse")
    dump(data)    
    
    --获取不要礼券信息返回 20200413
    if not data then return end

    if status then
        self:decodeMyTicketsRecord(data["LogList"])
    else

    end
end

function ExchangeCenterModel:resetMyTicketRecordList()
    self._myTicketRecord = {}
end

function ExchangeCenterModel:decodeMyTicketsRecord(recordList) 
    --{"LogCreateTime":"2016-07-15T14:24:47.74","OperateNumber":2,"OperateType":2,"Descript":"50元话费"}
    --self._myTicketRecord = {}
    for i = 1, #recordList do  --倒序
        local record = {}
        if recordList[i].OperateType == ExchangeCenterModel.TICKET_RECORD_EXCHANGE then
            record["Description"] = recordList[i].Descript  --string.sub(recordList[i].Descript, 7) --注意中文编码问题
        elseif recordList[i].OperateType == ExchangeCenterModel.TICKET_RECORD_EXPIRE and recordList[i].OperateNumber > 0 then
            record["Description"] = recordList[i].Descript
        end

        if next(record) ~= nil then
            record["Count"] = recordList[i].OperateNumber            
            local yearMonthDay = string.sub(recordList[i].LogCreateTime, 1, 10)
            yearMonthDay = string.gsub(yearMonthDay, "%-", "/")
            local hourMinute = string.sub(recordList[i].LogCreateTime, 12, 16)
            record["YearMonthDay"] = yearMonthDay
            record["HourMinute"] = hourMinute
            table.insert(self._myTicketRecord, record)
        end
    end      

    local compareFunc = function(a, b)
        if a.YearMonthDay ~= b.YearMonthDay then
            return a.YearMonthDay > b.YearMonthDay 
        end
        return a.HourMinute > b.HourMinute 
    end
    table.sort(self._myTicketRecord, compareFunc)
    dump(self._myTicketRecord)     
end

function ExchangeCenterModel:getTicketNumData()
    return self._ticketLeftNum

    --return 9999 --测试代码
end

function ExchangeCenterModel:getTicketItemListData()--只要用到兑换物品相关就用这个
    return self._ticketItemList
end

function ExchangeCenterModel:getMyTicketRecordData()
    return self._myTicketRecord
end

function ExchangeCenterModel:addMyTicketRecord(record)    
    --table.insert(self._myTicketRecord, record)
    table.insert(self._myTicketRecord, 1, record)
end

function ExchangeCenterModel:updateTicketNumData(num)
    self._ticketLeftNum = num
    self:dispatchEvent({name = ExchangeCenterModel.TICKET_LEFT_NUM_UPDATED})

    self._myStatusDataExtended["isNeedReddot"] = self:isNeedReddot()
    self:dispatchModuleStatusChanged("ExchangeCenterModel", ExchangeCenterModel.EVENT_MAP["ExchangeCenterModel_rewardAvailChanged"])
end

--玩家领取兑换券成功后，更新兑换券数量
function ExchangeCenterModel:addTicketNum(nTicketToAdd)
    if nTicketToAdd == nil then return end
    
    self._ticketLeftNum = self._ticketLeftNum + nTicketToAdd

    self:dispatchEvent({name = ExchangeCenterModel.TICKET_LEFT_NUM_UPDATED})

    self._myStatusDataExtended["isNeedReddot"] = self:isNeedReddot()
    self:dispatchModuleStatusChanged("ExchangeCenterModel", ExchangeCenterModel.EVENT_MAP["ExchangeCenterModel_rewardAvailChanged"])
end

--请求最新兑换券数量
function ExchangeCenterModel:requestExchangeTicketNum()
    --在更新周期内使用现有数据，不作更新
    if self._exchTicketUpdateTime ~= nil then
        local refreshCycle = 180
        local curTime = os.time()
        local timeDiff = curTime - self._exchTicketUpdateTime
        if timeDiff <= refreshCycle then
            return false
        end
    end

    self:getTicketNum() --向网络端发送更新请求
    return true
end

--重置兑换券数据的有效时间
function ExchangeCenterModel:resetTicketNumData()
    self._exchTicketUpdateTime = nil 
    self._ticketLeftNum = 0
end

--[[function ExchangeCenterModel:isExchangeCenterOpen()
    --return self._isOpen and cc.exports.isExchangeSupported()
    return true   --默认都是开的
end]]--

function ExchangeCenterModel:setExchangeCenterOpenStatus(isOpen)
    self._isOpen = isOpen
    self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_CENTER_OPEN_STATUS_UPDATED})
end

function ExchangeCenterModel:onExchangeOK(prizeID)--本地支付兑换券
    local itemList = self._ticketItemList
    local ticketCost = 0
    for i, n in ipairs(itemList) do
        if tonumber(prizeID) == tonumber(n.prizeID) then
            ticketCost = tonumber(n.price)
        end 
    end

    self:updateTicketNumData(self._ticketLeftNum - ticketCost)
end

function ExchangeCenterModel:dealWithExchangeSilverResult(status, message, prizeID)
    if status then    
        self:onExchangeOK(prizeID)

        local itemList = self._ticketItemList
        local silverGain = 0
        for i, n in ipairs(itemList) do
            if tonumber(prizeID) == tonumber(n.prizeID) then
                silverGain = tonumber(n.count)
            end 
        end
        
    	PlayerInfo:update({'UserGameInfo'})
        --[[UserModel.nDeposit = UserModel.nDeposit + silverGain        
        self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_CENTER_UPDATE_RICH}) --刷新大厅银子    ]]
    end
    local dataMap = {}
    dataMap.status = status
    dataMap.message = message
    dataMap.prizeID = prizeID

    self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_SILVER_OK, data = dataMap})
end

function ExchangeCenterModel:dealWithExchangeCustomPropResult(responseData)
    local theStruct = ExchangeCenterReq["EXCHANGE_CARDMARKER_RESP"]
    local exchangeResult = treepack.unpack(responseData, theStruct)
    dump(exchangeResult)

    if exchangeResult == nil then return end
    local prizeID = ExchangeCenterModel.customPropIdToPrizeId[exchangeResult["nPropId"]]
    if prizeID == nil then
        print("dealWithExchangeCustomPropResult prizeID nil, propId is " .. tostring(exchangeResult["nPropId"]))
    end
    if exchangeResult["szMessage"] then
        exchangeResult["szMessage"] = MCCharset:getInstance():gb2Utf8String(exchangeResult["szMessage"], string.len(exchangeResult["szMessage"]))
    end
    local userId = exchangeResult["nUserId"]

    if exchangeResult["nResult"] == 0 then 
        local nCount, nType = self:getCountByPriceID(prizeID)    --获取银子（话费）数量， 类型   
        --self:addCardRecorderLeftTime(nCount * 24 * 3600)
        CardRecorderModel:sendGetCardMakerInfo() --兑换成功后不手动增加剩余时间，而是主动查询一次

        self:onExchangeOK(prizeID)

        --播放公告
        local broadcastData = {}
        broadcastData.nUserID = userId
        broadcastData.nCount = nCount
        broadcastData.nType = 4
        broadcastData.prizeName = "prop_cr" --prop_cardrecorder
        --self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_BROADCARST, data = broadcastData}) 
        self:sendExchangeBroadCastData(broadcastData)   
    end

    local dataMap = {}
    dataMap.status = (exchangeResult["nResult"] == 0)
    dataMap.message = exchangeResult["szMessage"]
    dataMap.prizeID = prizeID

    self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_CUSTOMPROP_OK, data = dataMap})
end

--[[function ExchangeCenterModel:addCardRecorderLeftTime(seconds)
    if seconds == nil or seconds < 0 then return end

    if cc.exports.CardMakerInfo.nCardMakerCountdown == nil or cc.exports.CardMakerInfo.nCardMakerCountdown < 0 then
        cc.exports.CardMakerInfo.nCardMakerCountdown = 0
    end

    cc.exports.CardMakerInfo.nCardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown + seconds
end]]--

function ExchangeCenterModel:dealWithExchangeToolResult(status, message, prizeID)
    if status then    
        self:onExchangeOK(prizeID)
                
        local itemList = self._ticketItemList
        local days = 0
        local img = ""
        for i, n in ipairs(itemList) do
            if tonumber(prizeID) == tonumber(n.prizeID) then
                days = tonumber(n.count)
                img = n.image
            end 
        end
        
        if string.find(img, "CardMaster") then
            local price = cc.exports.GetCardMasterPriceByDays(days)
            cc.exports.SaveLastBuyToolItem("CardMaster", price, true, days)
        end           
    end    

    local dataMap = {}
    dataMap.status = status
    dataMap.message = message
    dataMap.prizeID = prizeID

    self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_TOOL_OK, data = dataMap})
end

function ExchangeCenterModel:dealWithExchangeMobileBillResult(status, message, prizeID)
    if status then    
        self:onExchangeOK(prizeID)         
    end
    local dataMap = {}
    dataMap.status = status
    dataMap.message = message
    dataMap.prizeID = prizeID

    self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_MOBILE_BILL_OK, data = dataMap})
end

function ExchangeCenterModel:dealWithExchangeRealItemResult(status, message, prizeID)
    if status then    
        self:onExchangeOK(prizeID)
    end
    local dataMap = {}
    dataMap.status = status
    dataMap.message = message
    dataMap.prizeID = prizeID

    self:dispatchEvent({name = ExchangeCenterModel.EXCHANGE_REAL_ITEM_OK, data = dataMap})
end


function ExchangeCenterModel:getCountByPriceID(prizeID)
    local itemList = self._ticketItemList
    local nType = 0
    local nCount = 0
    for i, n in ipairs(itemList) do
        if tonumber(prizeID) == tonumber(n.prizeID) then
            nCount = tonumber(n.count)
            nType = tonumber(n.nType)
            break
        end 
    end
    return nCount, nType
end

function ExchangeCenterModel:getPrizeNameByPriceID(prizeID)
    local itemList = self._ticketItemList
    local prizeName = ''
    for i, n in ipairs(itemList) do
        if tonumber(prizeID) == tonumber(n.prizeID) then
            prizeName = tostring(n.prizeName)
            break
        end 
    end
    return prizeName
end

function ExchangeCenterModel:reqExchangePropOfCardRecorder(prizeId)
    local playerInfo = cc.exports.PUBLIC_INTERFACE.GetPlayerInfo()

    if not playerInfo then return end
    if not playerInfo.nUserID then return end

    --有局数记牌器，则不让购买天数记牌器
    if cc.exports.CardMakerInfo and cc.exports.CardMakerInfo.nCardMakerNum > 0 then
        my.informPluginByName({pluginName = 'TipPlugin', params = { tipString = "您的局数记牌器尚未使用完，请用完后再来兑换哦", removeTime = 2}})
        return
    end

    if prizeId == nil or prizeId <= 0 or ExchangeCenterModel.prizeIdToCustomPropId[prizeId] == nil then
        print("reqExchangePropOfCardRecorder, prizeId illegal, prizeId=" .. tostring(prizeId))
        return
    end

    local EXCHANGE_CARDMARKER_REQ = ExchangeCenterReq["EXCHANGE_CARDMARKER_REQ"]
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local tokenId = userPlugin:getAccessToken()
    --tokenId = "3SI-2EkO2dx8XAqJLp7XffwxR5nBVW6fj0yHpfbL8lOJDHWxrfXw8eljuMcmvs8X84uRxrPJstRUOY341fu3lro_BcDJZo6BZcewa6GogQl6urI4Z32maoMoMW54VIEquNMrMxG4A-JkqKX7BHI2Kg"
    local data      = {
        nUserId = playerInfo.nUserID,
        nPropId = ExchangeCenterModel.prizeIdToCustomPropId[prizeId],
        szUserToken = tokenId
    }

    local pData = treepack.alignpack(data, EXCHANGE_CARDMARKER_REQ)
    AssistModel:sendData(ExchangeCenterDef.GR_EXCHANGE_CARDMARKER_REQ, pData)

    self:addExchangeCount(prizeId, 1)
    --测试代码
    --[[self:dealWithExchangeCustomPropResult({
        ["nResult"] = 0,
        ["nUserId"] = 159127,
        ["nPropId"] = ExchangeCenterModel.prizeIdToCustomPropId[prizeId],
        ["szMessage"] = "兑换成功哈哈哈"
    })]]--
end

function ExchangeCenterModel:sendExchangeBroadCastData(broadcastData)
    print("ExchangeCenterModel:sendExchangeBroadCastData")
    dump(broadcastData)
    if broadcastData.nUserID == nil or broadcastData.nCount == nil or broadcastData.nType == nil then
        print("broadcastData illegal!!!")
        return
    end

    
    local utf8Name = UserModel:getSelfDisplayName()
    local bOpen, bUnlock, nLevel = NobilityPrivilegeModel:isExchangeBroadcast()
    if bOpen and bUnlock and type(nLevel) == "number" then
        utf8Name = "【贵族" .. tostring(nLevel).."】" .. utf8Name
    end

    local gb2Name = MCCharset:getInstance():utf82GbString(utf8Name, string.len(utf8Name))
    local gb2PrizeName = ""
    if broadcastData.prizeName then
        gb2PrizeName = MCCharset:getInstance():utf82GbString(broadcastData.prizeName, string.len(broadcastData.prizeName))
    end
    local exCenterBroadCast = ExchangeCenterReq["EXCHANGE_CENTER_BROAD_CAST"]
    local data      = {
        nUserID     = broadcastData.nUserID,
        nType       = broadcastData.nType,
        nCount      = broadcastData.nCount,
		szUserName   = gb2Name,
        szPrizName   = gb2PrizeName -- 实物名称
    }
    local pData = treepack.alignpack(data, exCenterBroadCast)

    AssistModel:sendData(ExchangeCenterDef.GR_EXCHANGE_CENTER_BROAD_CAST, pData)
end

function ExchangeCenterModel:getItemDataListByType(itemType)
    local itemList = self:getTicketItemListData()

    local currentPage = {}
    for _, itemData in ipairs(itemList) do
        if itemData["isAvailable"] and itemData["nType"] == itemType then
            table.insert(currentPage, itemData)
        end
    end

    return currentPage
end

--可以通过GameConfig.json配置ExchangeImgDotValue 决定什么时候亮礼券中心的红点
function ExchangeCenterModel:isNeedReddot()
    --不再需要红点了，用气泡代替  20200304 by taoqiang
--    local imgDotValue = 20
--    if cc.exports._gameJsonConfig.ExchangeImgDotValue then
--        imgDotValue = cc.exports._gameJsonConfig.ExchangeImgDotValue
--    end

--    local ticketNum = self:getTicketNumData() or 0
--    if ticketNum >= imgDotValue then
--        return true
--    end

    return false
end

function ExchangeCenterModel:onGameJsonConfigUpdated()
    self._myStatusDataExtended["isNeedReddot"] = self:isNeedReddot()
    self:dispatchModuleStatusChanged("ExchangeCenterModel", ExchangeCenterModel.EVENT_MAP["ExchangeCenterModel_rewardAvailChanged"])
end

function ExchangeCenterModel:getLastDateExchange(prizeID, userID)
    return CacheModel:getCacheByKey("date_"..prizeID.."_"..userID)
end

function ExchangeCenterModel:setLastDateExchange(prizeID, userID)
    CacheModel:saveInfoToCache("date_"..prizeID.."_"..userID, os.date('%Y%m%d',os.time()))
end

function ExchangeCenterModel:getExchangeCount(prizeID, userID)
    return CacheModel:getCacheByKey("count_"..prizeID.."_"..userID)
end

function ExchangeCenterModel:setExchangeCount(prizeID, userID, count)
    CacheModel:saveInfoToCache("count_"..prizeID.."_"..userID, count)
end

function ExchangeCenterModel:addExchangeCount(prizeID, addCount)
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil or playerInfo.nUserID == nil or playerInfo.nUserID <= 0 then
        return 
    end

    local userID = playerInfo.nUserID    
    local lastDate = self:getLastDateExchange(prizeID, userID)
    local curDate = os.date('%Y%m%d',os.time())
    if lastDate ~= curDate then
        -- 最后兑换日期不是今天则重置最后兑换日期和兑换次数
        self:setLastDateExchange(prizeID, userID)
        self:setExchangeCount(prizeID, userID, addCount)
    else
        -- 最后兑换日期就是今天累加兑换次数
        local exchangeCount = self:getExchangeCount(prizeID, userID)
        if exchangeCount == nil then
            exchangeCount = 0
        end
        self:setLastDateExchange(prizeID, userID)
        self:setExchangeCount(prizeID, userID, addCount + exchangeCount)
    end
end

function ExchangeCenterModel:getRemainExchangeCount(prizeID)
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil or playerInfo.nUserID == nil or playerInfo.nUserID <= 0 then
        return 
    end

    local userID = playerInfo.nUserID    
    local lastDate = self:getLastDateExchange(prizeID, userID)
    local curDate = os.date('%Y%m%d',os.time())
    local prizeName = self:getPrizeNameByPriceID(prizeID)
    local maxCount = cc.exports.getExchangeMaxCount(prizeName)
    if lastDate ~= curDate then
        -- 最后兑换日期不是今天则重置最后兑换日期和兑换次数
        self:setLastDateExchange(prizeID, userID)
        self:setExchangeCount(prizeID, userID, 0)
        return maxCount
    else
        -- 最后兑换日期就是今天则返回兑换次数
        local exchangeCount = self:getExchangeCount(prizeID, userID)
        if exchangeCount == nil then
            exchangeCount = 0
        end
        local count = maxCount - exchangeCount
        if count < 0 then
            count = 0
        end
        return count
    end
end
return ExchangeCenterModel

