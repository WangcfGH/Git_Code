local LimitTimeGiftModel = class('LimitTimeGiftModel', require('src.app.GameHall.models.BaseModel'))

local json = cc.load("json").json
local UserModel = mymodel('UserModel'):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()

local LimitTimeGiftReq = import('src.app.plugins.limitTimeGift.LimitTimeGiftReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local LimitTimeGiftDef = {
    GR_SEND_LIMITTIMEGIFT_TAG_REQ              = 406001, -- 查询限时礼包开启状态
    GR_SEND_LIMITTIMEGIFT_TAG_RESP             = 406002, -- 回复限时礼包开启状态
    GR_SEND_LIMITTIMEGIFT_TRIG_REQ             = 406003, -- 触发限时礼包
    GR_SEND_LIMITTIMEGIFT_TRIG_RESP            = 406004, -- 触发限时礼包
    GR_SEND_LIMITTIMEGIFT_RECHARGED            = 406005, -- 触发限时礼包

    GR_LIMITTIMEGIFT_LOG_REQ = 407002,
}

LimitTimeGiftModel.EVENT_MAP = {
    ["limitTimeGiftModel_limitTimeUpdated"] = "limitTimeGiftModel_limitTimeUpdated",
    ["SHOW_LIMIT_TIME_GIFT_LAYER"] = "A_SHOW_LIMIT_TIME_GIFT_LAYER", --在结算界面显示限时礼包
    ["limitTimeGiftModel_purchaseSucceeded"] = "limitTimeGiftModel_purchaseSucceeded"
}

function LimitTimeGiftModel:onCreate()
    self._giftItemData = nil

    self._assistResponseMap = {
        [LimitTimeGiftDef.GR_SEND_LIMITTIMEGIFT_TAG_RESP] = handler(self, self.onSetLimitTimeGiftInfo),
        [LimitTimeGiftDef.GR_SEND_LIMITTIMEGIFT_TRIG_RESP] = handler(self, self.onRefreshLimitTimeGiftInfo)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function LimitTimeGiftModel:StartGetLimitTimeGiftconfig()
    local appJsonObj = nil
    if cc.exports._gameJsonConfig.LimitTimeGiftConfig and next(cc.exports._gameJsonConfig.LimitTimeGiftConfig) ~=nil then
        appJsonObj = clone(cc.exports._gameJsonConfig.LimitTimeGiftConfig)
        --cc.exports._gameJsonConfig.LimitTimeGiftConfig = nil
    else
        appJsonObj = self:readLimitTimeGiftConfig()
    end

    local giftconfig = {}
    giftconfig["Item_Config"] ={}

    local pay = {}
    giftconfig["Trans_Type"] = 2
    if appJsonObj ~= nil then
        pay = appJsonObj["payconfig"]["gifts"]["gift"]
        giftconfig["Trans_Type"]= appJsonObj["payconfig"]["paytype"]
    end

    for i,v in pairs(pay)do
        local shopItem = {}

        if(v["sid"])then
            shopItem["Product_Id"] = v["sid"]
        else
            shopItem["Product_Id"] = ""
        end
        shopItem["BaseSilver"] = v["basesilver"]

        shopItem["Product_Name"]=         v["productname"]
        shopItem["Product_Final_Name"]=   v["productfinalname"]
        shopItem["Product_Price"]=        v["price"]
        shopItem["Product_Count"]=        v["productnum"]
        shopItem["Pay_Type"]=             v["paymodeids"]

        shopItem["ExchangeId"]=v["exchangeid"]

        --for lua show
        shopItem["Title"]=           v["title"]
        shopItem["Product_Type"] =  v["producttype"]
        shopItem["Icon_Type"]    =  v["icontype"]
        shopItem["Icon_DesplayNo"]    =  v["icondesplayno"]
        shopItem["Des"]          =  v["description"]
        shopItem["Charge_Point"] =  v["chargepoint"]
        shopItem["Label"]        =  v["labeltype"]
        shopItem["First_Reward"] =  v["firstpayrewardnum"]
        shopItem["First_Des"]    =  v["firstpaydescription"]
        shopItem["First_Point"]  =  v["firstpaychargepoint"]
        shopItem["product_subject"]  =  ""
        shopItem["product_body"]     =  ""
        shopItem["app_currency_name"]=  ""
        shopItem["app_currency_rate"]=  ""

        shopItem["limit"] = v["limit"]

        shopItem["ex_id"]=v["productid"]
        shopItem["through_data"]=""

        table.insert(giftconfig["Item_Config"], shopItem )
    end
    cc.exports.limitTimeGiftConfig = giftconfig

    if cc.exports.isLimitTimeGiftSupported() then
        if(true == LimitTimeGiftModel:readLimitTimeGiftFromCacheData())then
            print("readLimitTimeGiftFromCacheData")
            return
        end
        print("StartLimitTimeGift")
        self:StartLimitTimeGift()
    end
end

function LimitTimeGiftModel:StartLimitTimeGift()
    local baseUrl

    local ActId = require("src.app.HallConfig.ActivitysConfig").LimitTimeGiftId
    if cc.exports.IsHejiPackage() then
        ActId = require("src.app.HallConfig.ActivitysConfig").LimitTimeGiftId_HJ  --合集
    end

    if(ActId==nil)then
        return
    end

    local UserId = mymodel('UserModel'):getInstance().nUserID

    local device=mymodel('DeviceModel'):getInstance()
    local szWifiID,szImeiID,szSystemID=device.szWifiID,device.szImeiID,device.szSystemID
    local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)

    local Time = os.time()*1000

    local keyString=string.format('%d|%d|%.0f',ActId,UserId ,Time)
    local md5String = my.md5(keyString)

    if BusinessUtils:getInstance():isGameDebugMode() then
        baseUrl='http://huodong.uc108.org:922/rechargeactivity/getrechargeactivity/?'
    else
        baseUrl='https://huodong.tcy365.com/rechargeactivity/getrechargeactivity/?'
    end

    baseUrl = baseUrl.."ActId="..tostring(ActId).."&"
    baseUrl = baseUrl.."UserId="..tostring(UserId).."&"
    baseUrl = baseUrl.."DeviceId="..deviceId.."&"
    baseUrl = baseUrl.."Time="..tostring(Time).."&"
    baseUrl = baseUrl.."Key="..md5String

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0
    xhr:open("GET", baseUrl)

    printf("~~~~~~~url~~~~~ %s",baseUrl)
    local function onReadyStateChange()

        local json = cc.load("json").json
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            local AppJsonObj = json.decode( xhr.response )
            printf("~~~~~~~~~~~~~save recharge~~~~~~~~~~~~~~")
            self:saveCacheLimitTimeGift(AppJsonObj)
            self:ParseLimitTimeGiftResurceResponse(AppJsonObj)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()

end

function LimitTimeGiftModel:ParseLimitTimeGiftResurceResponse(obj)
    local support = {}

    local item = {}
    if obj["Data"] then
        item = obj["Data"]
    end
    for i,v in pairs(item)do
        local s = {}
        s["Price"] = tonumber( v["GoodsPrice"] )
        s["Type"]= tonumber( v["GoodsType"] )
        s["Code"]=v["GameCode"]
        table.insert(support,s)
    end
    cc.exports.limitTimeGiftList = support


    local ActId = require("src.app.HallConfig.ActivitysConfig").LimitTimeGiftId
    if cc.exports.IsHejiPackage() then
        --合集
        ActId = require("src.app.HallConfig.ActivitysConfig").LimitTimeGiftId_HJ
    end

    local device=mymodel('DeviceModel'):getInstance()
    local szWifiID,szImeiID,szSystemID=device.szWifiID,device.szImeiID,device.szSystemID
    local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)

    for i,v in pairs(cc.exports.limitTimeGiftConfig["Item_Config"])do
        for k,w in pairs(support)do
            if tonumber(w["Price"]) == tonumber(v["Product_Price"]) then
                local ex
                if(tonumber(cc.exports.limitTimeGiftConfig["Trans_Type"])==0)then
                    if cc.exports.isBackBoxSupported() then 
                        ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d}",v["Code"],ActId,deviceId,2)
                    else 
                        ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d}",v["Code"],ActId,deviceId,1)
                    end
                elseif(tonumber(cc.exports.limitTimeGiftConfig["Trans_Type"])==2)then
                    ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}",w["Code"],ActId,deviceId,0,v["ex_id"])
                end
                v["through_data"] = ex
                break
            end
        end
    end
end

function LimitTimeGiftModel:SendTimeGiftTagRequest()
    self:_sendTimeGiftTagRequest(LimitTimeGiftDef.GR_SEND_LIMITTIMEGIFT_TAG_REQ)
end

function LimitTimeGiftModel:SendTimeGiftTrigRequest(giftid)
    self:_sendTimeGiftTrigRequest(LimitTimeGiftDef.GR_SEND_LIMITTIMEGIFT_TRIG_REQ,giftid)
end

function LimitTimeGiftModel:_sendTimeGiftTagRequest(msg_type)
    local playerInfo = PublicInterface.GetPlayerInfo()

    local nPlatform = 0
    if device.platform == "ios" then
        nPlatform = 1
    end
    local limit_Time_Gift_REQ = LimitTimeGiftReq["Limit_Time_Gift_Req"]
    local data      = {
        nUserID     = playerInfo.nUserID,
        nPlatform   = nPlatform
    }
    local pData = treepack.alignpack(data, limit_Time_Gift_REQ)
    AssistModel:sendData(msg_type, pData)
end

function LimitTimeGiftModel:_sendTimeGiftTrigRequest(msg_type,giftid)
    local playerInfo = PublicInterface.GetPlayerInfo()
    local gameModel = require("src/app/GameHall/models/GameModel"):getInstance()

    local limit_Time_Gift_Trig_Req = LimitTimeGiftReq["Limit_Time_Gift_Trig_Req"]
    local data      = {
        nUserID     = playerInfo.nUserID,
        nGiftID     = giftid or 1,
        nEquipID    = gameModel.clientID
    }
    local pData = treepack.alignpack(data, limit_Time_Gift_Trig_Req)
    AssistModel:sendData(msg_type, pData)
end

function LimitTimeGiftModel:onSetLimitTimeGiftInfo(data)
    printf('send LIMIT TIME GIFT TAG resp')
    local limit_Time_Gift_Resp = LimitTimeGiftReq["Limit_Time_Gift_Resp"]
    local tagResp = treepack.unpack(data, limit_Time_Gift_Resp)
    dump(tagResp)
    cc.exports.limitTimeGiftInfo.nUserID = tagResp.nUserID
    cc.exports.limitTimeGiftInfo.nGiftID = tagResp.nGiftID
    cc.exports.limitTimeGiftInfo.nTrigTime = tagResp.szTrigTime
    cc.exports.limitTimeGiftInfo.nCountdown = tonumber(tagResp.nCountdown) --默认-99表示没有触发，-1表示当天已经触发，>=0表示实际触发时间
    if cc.exports.limitTimeGiftInfo.nCountdown > 0 then
        local tag = 0
        for m,n in pairs(cc.exports.limitTimeGiftList) do
            if tonumber(tagResp.nGiftID) == tonumber(n["Price"]) then
                tag = tagResp.nGiftID
                break
            end
        end
        if tag > 0 then   --如果当前可充值的礼包有这个giftid
            self:calcLimitTimeGiftItem()
            self:startLimitTimeUpdateTimer()
        else
            cc.exports.limitTimeGiftInfo.nCountdown = -1   --如果当前可充值的礼包没有这个giftid，倒计时设为-1，原因是购买成功之后有可能chunk收不到添加数据库的消息
            --self:dispatchEvent({name = self.HIDE_LIMIT_TIME_GIFT})
            --self:dispatchEvent({name = LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_limitTimeUpdated"]})
        end
    else
        --self:dispatchEvent({name = self.HIDE_LIMIT_TIME_GIFT})
        --self:dispatchEvent({name = LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_limitTimeUpdated"]})
    end
    self:dispatchEvent({name = LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_limitTimeUpdated"]})
end

function LimitTimeGiftModel:onRefreshLimitTimeGiftInfo(data)
    printf('send LIMIT TIME GIFT TRIG resp')
    local limit_Time_Gift_Trig_Resp = LimitTimeGiftReq["Limit_Time_Gift_Trig_Resp"]
    local triggerResp = treepack.unpack(data, limit_Time_Gift_Trig_Resp)
    dump(triggerResp)
    cc.exports.limitTimeGiftInfo.nUserID = triggerResp.nUserID
    cc.exports.limitTimeGiftInfo.nGiftID = triggerResp.nGiftID
    cc.exports.limitTimeGiftInfo.nTrigTime = triggerResp.szTrigTime
    cc.exports.limitTimeGiftInfo.nCountdown = tonumber(triggerResp.nCountdown)

    if cc.exports.limitTimeGiftInfo.nCountdown > 0 then
        self:calcLimitTimeGiftItem()
        self:startLimitTimeUpdateTimer()
        self:dispatchEvent({name = LimitTimeGiftModel.EVENT_MAP["SHOW_LIMIT_TIME_GIFT_LAYER"]})
        --[[
        if not self._LimitTimeGiftTimer then
            self._LimitTimeGiftTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updateTime),1,false)
        end
        --]]

        self:onLimitTimeGiftLogReq() 
    end
end

--数据埋点
function LimitTimeGiftModel:onLimitTimeGiftLogReq()
    local playerInfo = PublicInterface.GetPlayerInfo()
    local JudgeNewPlayer = import("src.app.plugins.judgenewplayer.JudgeNewPlayer"):getInstance()
    local tag = (JudgeNewPlayer:isNewPlayer() == 1)
    local isNew = 0
    if tag then
        isNew = 1
    end

    local limitTimeGiftLogReq = LimitTimeGiftReq["TIMEDBAG_LOG_REQ"]

    local data      = {
        nUserID     = playerInfo.nUserID,
        nIsNewHand  = isNew,
        nTimedBagType = tonumber(cc.exports.LimitTimeGiftType[tonumber(cc.exports.limitTimeGiftInfo.nGiftID)])
    }
    local pData = treepack.alignpack(data, limitTimeGiftLogReq)

    dump(data)       
    AssistModel:sendData(LimitTimeGiftDef.GR_LIMITTIMEGIFT_LOG_REQ, pData)
end

function LimitTimeGiftModel:startLimitTimeUpdateTimer()
    TimerManager:scheduleLoop("Timer_LimitTimeGiftModel_LimitTimeUpdate", function()
        if cc.exports.limitTimeGiftInfo.nCountdown >= 0 then
            cc.exports.limitTimeGiftInfo.nCountdown = cc.exports.limitTimeGiftInfo.nCountdown - 1
        else
            TimerManager:stopTimer("Timer_LimitTimeGiftModel_LimitTimeUpdate")
        end
        self:dispatchEvent({name = LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_limitTimeUpdated"]})
    end, 1.0)
end

function LimitTimeGiftModel:getTime(countdown)
    if countdown and countdown >= 0  then
    else
        return
    end
    local hours = math.modf(countdown/3600)
    local mins = math.modf((countdown - hours*3600)/60)
    local secs = countdown - hours*3600 - mins*60
    if tonumber(hours) < 10 then
        hours = "0"..hours
    end
    if tonumber(mins) < 10 then
        mins = "0"..mins
    end
    if tonumber(secs) < 10 then
        secs = "0"..secs
    end
    local time = hours..":"..mins..":"..secs
    return time
end

function LimitTimeGiftModel:calcLimitTimeGiftItem()
    self._giftItemData = nil
    if next(cc.exports.limitTimeGiftList) == nil then
        return false
    end

    if cc.exports.limitTimeGiftInfo.nCountdown and cc.exports.limitTimeGiftInfo.nCountdown > 0  then
        print("LimitTimeGiftCtrl:createViewNode",cc.exports.limitTimeGiftInfo.nGiftID)
        dump(cc.exports.limitTimeGiftConfig["Item_Config"])
        for _, itemData in pairs(cc.exports.limitTimeGiftConfig["Item_Config"]) do
            if tonumber(itemData["Product_Price"]) == tonumber(cc.exports.limitTimeGiftInfo.nGiftID) then
                self._giftItemData = self:normalizeGiftItemData(itemData)
                return true
            end
        end  
    end
    return false
end

--按shopitemsconfig标准化成统一格式；
function LimitTimeGiftModel:normalizeGiftItemData(itemData)
    if itemData == nil then return nil end

    local itemDataNormalized = {
        ["id"] = -1,
        ["productid"] = itemData["Product_Id"],
        ["exchangeid"] = itemData["ex_id"],
        ["productname"] = itemData["Product_Final_Name"],
        ["productnum"] = itemData["Product_Count"],
        ["price"]  = itemData["Product_Price"],
        ["producttype"] = itemData["Product_Type"],
        ["producttypeex"] = "deposit",
        ["through_data"] = itemData["through_data"],
        ["icondesplayno"] = itemData["Icon_DesplayNo"],
        ["labeltype"] =  itemData["Label"],
        ["icontype"] =  itemData["Icon_Type"],

        ["First_Support"] = 1,
        ["fristpay_productname"] = itemData["Product_Final_Name"],
        ["firstpay_rewardnum"] = itemData["First_Reward"]
    }

    return itemDataNormalized
end

function LimitTimeGiftModel:payCurrentGiftItem(isTriggeredInGame)
    print("LimitTimeGiftModel:payCurrentGiftItem")

    self:_payLimitTimeGiftItem(self._giftItemData, isTriggeredInGame)
end

function LimitTimeGiftModel:_payLimitTimeGiftItem(targetItemData, isTriggeredInGame)
    print("LimitTimeGiftModel:_payLimitTimeGiftItem")
    if targetItemData == nil then
        print("targetItemData is nil")
        return
    end

    local payCallBack = function(code, msg)
		printInfo("%d",code)
		printInfo("%s",msg)
		printf("LimitTimeGiftModel.paycallback_working")

		if code == PayResultCode.kPaySuccess then
            printf("LimitTimeGiftModel.kPaySuccess")
			if isTriggeredInGame == true then
				my.dataLink(cc.exports.DataLinkCodeDef.LIMIT_TIME_GIFT_BUY_OK) --17期客户端埋点
			end
		elseif( code == PayResultCode.kPayFail )then
			printf("LimitTimeGiftModel.BuyFailed")
			if isTriggeredInGame then
				my.dataLink(cc.exports.DataLinkCodeDef.LIMIT_TIME_GIFT_BUY_CANCEL) --17期客户端埋点
			end
		elseif( code == PayResultCode.kPayTimeOut )then
			printf("LimitTimeGiftModel.Timeout")
			if isTriggeredInGame then
				my.dataLink(cc.exports.DataLinkCodeDef.LIMIT_TIME_GIFT_BUY_TIME_OUT) --17期客户端埋点
			end
		elseif( code == PayResultCode.kPayProductionInforIncomplete )then
			  printf("LimitTimeGiftModel.Infoincomplete")
		end
	end

    ShopModel:PayForProductWithCustomCallback(targetItemData, payCallBack)
end

function LimitTimeGiftModel:dealAfterPayItemOk(goodID)
    print("LimitTimeGiftModel:dealAfterPayItemOk")
    dump(cc.exports.limitTimeGiftList)

    if type(cc.exports.limitTimeGiftList) ~= "table" or not cc.exports.limitTimeGiftConfig["Item_Config"] then
        print("LimitTimeGiftModel:dealAfterPayItemOk  config is null")
        return
    end

	for i,v in pairs(cc.exports.limitTimeGiftConfig["Item_Config"]) do  --限时礼包
        if tonumber(v["ex_id"]) == goodID then
            cc.exports.limitTimeGiftInfo.nCountdown = -1
            self:dispatchEvent({name = LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_purchaseSucceeded"]})

			local dataMap
			local filename = self:getLimitTimeGiftCacheDataName()
			print("doAfterPayItemOK 675 filename",filename)
			if(false == my.isCacheExist(filename))then
				printf("~~~~~~~~~~no cach~~~~~~~~~~~~~~~~~~")
				return false
			end
			dataMap=my.readCache(filename)
			dataMap=checktable(dataMap)
			for j, k in pairs(dataMap["Data"]) do
				if tonumber(k["GoodsPrice"]) == tonumber(cc.exports.limitTimeGiftInfo.nGiftID) then
					print("table.remove")
					table.remove(dataMap["Data"], j)
					table.remove(cc.exports.limitTimeGiftList,i)
					dump(cc.exports.limitTimeGiftList)
					
					self:saveCacheLimitTimeGift(dataMap)
					return true
				end
			end
		end
	end

    return false
end

function LimitTimeGiftModel:getLimitTimeGiftCacheDataName()
    local cacheFile= "LimitTimeGiftState.xml"
    local UserModel = mymodel('UserModel'):getInstance()
    local id = UserModel.nUserID or "default"
    cacheFile = id.."_"..cacheFile
    return cacheFile
end

function LimitTimeGiftModel:getTodayDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())
    return tmYear.."_"..tmMon.."_"..tmMday
end

function LimitTimeGiftModel:saveCacheLimitTimeGift(dataMap)
    local data=checktable(dataMap)
    data.queryDate = self:getTodayDate()
    dump(data)
    my.saveCache(self:getLimitTimeGiftCacheDataName(),data)

end

function LimitTimeGiftModel:readLimitTimeGiftFromCacheData()
    local dataMap
    local filename = self:getLimitTimeGiftCacheDataName()
    if(false == my.isCacheExist(filename))then
        return false
    end

    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)
    local date = self:getTodayDate()
    if(date ~= dataMap.queryDate)then
        return false
    end
    print("readLimitTimeGiftFromCacheData",filename)
    dump(dataMap)
    LimitTimeGiftModel:ParseLimitTimeGiftResurceResponse(dataMap)

    return true
end

function LimitTimeGiftModel:readLimitTimeGiftConfig()
   local filename= "LimitTimeGiftConfig.xml"

    if my.isCacheExist(filename) then
        local dataMap = my.readCache(filename)
        dataMap = checktable(dataMap)

        local tmYear=os.date('%Y',os.time())
        local tmMon=os.date('%m',os.time())
        local tmMday=os.date('%d',os.time())

        local date = tmYear.."_"..tmMon.."_"..tmMday
        if(date == dataMap.queryDate)then
            dump(dataMap)
            return dataMap
        end
    end
end

--测试函数，仅用于测试
function LimitTimeGiftModel:__testLimitTimeGift(giftPrice)
    cc.exports.limitTimeGiftInfo.nCountdown = 1000
    cc.exports.limitTimeGiftInfo.nGiftID = giftPrice
    self:calcLimitTimeGiftItem()
    self:startLimitTimeUpdateTimer()
end

function LimitTimeGiftModel:onLogoff()
    if next(cc.exports.limitTimeGiftInfo) ~= nil and cc.exports.limitTimeGiftInfo.nCountdown >= 0 then
        cc.exports.limitTimeGiftInfo = {}
        TimerManager:stopTimer("Timer_LimitTimeGiftModel_LimitTimeUpdate")
        self:dispatchEvent({name = LimitTimeGiftModel.EVENT_MAP["limitTimeGiftModel_limitTimeUpdated"]})
    end
end

return LimitTimeGiftModel