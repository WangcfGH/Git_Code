local ShopModel = class("ShopModel", require('src.app.GameHall.models.BaseModel'))

local user=mymodel('UserModel'):getInstance()
local UpdateConfigsModel = mymodel('UpdateConfigsModel'):getInstance()
local RewardTipDef       = import("src.app.plugins.RewardTip.RewardTipDef")
local BankruptcyModel = import('src.app.plugins.Bankruptcy.BankruptcyModel'):getInstance()
local WeekCardModel = import('src.app.plugins.WeekCard.WeekCardModel'):getInstance()
local MonthCardModel = require("src.app.plugins.monthcard.MonthCardConn"):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local LuckyPackModel = import('src.app.plugins.LuckyPack.LuckyPackModel'):getInstance()
local ContinueRechargeModel = require("src.app.plugins.continuerecharge.ContinueRechargeModel"):getInstance()
local WeekMonthSuperCardModel= import("src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardModel"):getInstance()
local GratitudeRepayModel   = require('src.app.plugins.GratitudeRepay.GratitudeRepayModel'):getInstance()
local relief = mymodel('hallext.ReliefActivity'):getInstance()
local ValuablePurchaseModel = import('src.app.plugins.ValuablePurchase.ValuablePurchaseModel'):getInstance()
local RechargeActivityModel = import('src.app.plugins.RechargeActivity.RechargeActivityModel'):getInstance()

--my.addInstance(ShopModel)
--local event=cc.load('event')
local json = cc.load("json").json
local shopItems = nil


ShopModel.EVENT_GET_PAYITEM = "GET_PAY_ITEM"
--ShopModel.EVENT_SHOW_FIRSTRECHARGE = "SHOW_FIRST_RECHARGE"
--ShopModel.EVENT_HIDE_FIRSTRECHARGE = "HIDE_FIRST_RECHARGE"
ShopModel.EVENT_PURCHASE_SUCCESS = "PURCHASE_SUCCESS"
ShopModel.EVENT_UPDATE_RICH = "UPDATE_RICH"
ShopModel.EVENT_UPDATE_CARD_MAKER = "EVENT_UPDATE_CARD_MAKER"
ShopModel.EVENT_UPDATE_EXPRESSION_TIPS = "EVENT_UPDATE_EXPRESSION_TIPS"

ShopModel.EVENT_MAP = {
    ["shopModel_firstRechargeAvailChanged"] = "shopModel_firstRechargeAvailChanged",
}

function ShopModel:onCreate()
    self._ShopJsonItem = {}
    self._ShopUIConfig = {}
    self._ExpressionitemTouchAgain = {true, true, true}  --快速多次点击
    self._nobilityUniqueFlag = nil
end

function ShopModel:LoadShopTipsConfig()
    if not self._shopTipsJson then
        local shoptips = cc.FileUtils:getInstance():getStringFromFile("res/hall/hallstrings/PayTips.json")
        if shoptips then
            self._shopTipsJson = json.decode(shoptips)
        end
    end
end

function ShopModel:GetShopConfig()
    if not self._shopConfig then
        local s = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/shopconfig/shopconfig.json")
        self._shopConfig = json.decode(s)
    end
    return self._shopConfig
end

function ShopModel:loadShopVersionConfig()
    local abb = my.getGameShortName()
    local deVersion = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/shopconfig/shopversion.json")
    local version = json.decode(deVersion)
    self.versionID = version["version"]
    self._apkVersionID = version["version"]

    if my.isCacheExist("newshopversion.json") then
        local path = my.getFullCachePath("newshopversion.json")
        local deVersionCache = cc.FileUtils:getInstance():getStringFromFile(path)
        local versionCache = json.decode(deVersionCache)
        self._cacheVersionID = versionCache["version"]
        self._appversion_cache = versionCache["appversion"]

        if self._appversion_cache == my.getGameVersion() then
            if self._cacheVersionID > self.versionID then
                self.versionID = self._cacheVersionID
            end
        end
    end
end

function ShopModel:GetShopVersion()
    return versionID
end

function ShopModel:isHaveFirstRecharge()
    for i, v in pairs(self._ShopJsonItem) do
        if self:isIDinTabs(v["id"]) then
            if (v["First_Support"] == 1) then
                return true
            end
        end
    end
    return false
end

function ShopModel:doAfterPayItemOK(goodID)
    if not goodID then
        return
    end
    printf("~~~~~~~~~~~doAfterPayItemOK ~~~~~~~~~~~~~~")

    local LimitTimeGiftModel = require("src.app.plugins.limitTimeGift.limitTimeGiftModel"):getInstance()
    if LimitTimeGiftModel:dealAfterPayItemOk(goodID) then
        print("LimitTimeGiftModel:dealAfterPayItemOk")
    else
        for i, v in pairs(self._ShopJsonItem) do
            if tonumber(v["exchangeid"]) == goodID then
                if v["First_Support"] == 1 then
                    v["First_Support"] = 0
                    self:onDealFirstPay()
                end
                v["First_Support"] = 0
                self:updateCach(v["price"], v["producttype"])
                break
            end
        end
    end
end
--[[
local function ShowTips()
    printf("showtips")
    if not mymodel("ShopModel"):getInstance()._needshowtip then
        mymodel("ShopModel"):getInstance()._needshowtip = false
    else
        local showText=""
        local item = cc.exports.GetLastBuyItem()
        if item then
            for i, v in pairs(mymodel("ShopModel"):getInstance()._ShopJsonItem) do
                if( (v["price"]==item["Price"]) and (v["producttype"]==item["Type"]) )then
                    if (v["producttype"] == 1)then
                        if v["paytype"] and v["paytype"] == 1 then
                            showText = mymodel("ShopModel"):getInstance()._shopTipsJson["BuyDepositInboxOK"]
                        elseif v["paytype"] and v["paytype"] == 0 then
                            showText = mymodel("ShopModel"):getInstance()._shopTipsJson["BuyDepositOK"]
                        elseif v["paytype"] and v["paytype"] == 2 then
                            showText = mymodel("ShopModel"):getInstance()._shopTipsJson["BuyDepositInbackboxOK"]
                        end
                    elseif(v["producttype"] == 2)then
                        showText = mymodel("ShopModel"):getInstance()._shopTipsJson["BuyVIPOK"]
                    elseif(v["producttype"] == 3)then
                        showText = mymodel("ShopModel"):getInstance()._shopTipsJson["BuyScoreOK"]
                    end
                    printf("~~~~~ShowTips~~~%s~~~~~~",showText)
                    my.informPluginByName({pluginName='TipPlugin',params={tipString=showText,removeTime=2}})
                end
            end
        end
   end
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(mymodel("ShopModel"):getInstance()._TimerId)
    mymodel("ShopModel"):getInstance()._TimerId = nil
end
--]]

function ShopModel:getUniqueFlag()
    return self._nobilityUniqueFlag
end

local function payCallBack(code, msg)
    printInfo("%d",code)
    printInfo("%s",msg)

    --local config = cc.exports.GetShopConfig()

    local payResult = nil
    if( code == PayResultCode.kPaySuccess )then
        --mymodel("ShopModel"):getInstance()._needshowtip = false
        --printf("PayResultCode showtips")
        --mymodel("ShopModel"):getInstance()._TimerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(ShowTips, 3.0, false)
        printf("payresultcode success")
        --mymodel("ShopModel"):getInstance():doAfterPayItemOK()
        payResult = "paySuccess"
    else
        if( code == PayResultCode.kPayFail )then
            payResult = "payFail"
        elseif( code == PayResultCode.kPayTimeOut )then
            payResult = "payTimeOut"
        elseif( code == PayResultCode.kPayCancel )then
            payResult = "payCancel"
        elseif( code == PayResultCode.kPayProductionInforIncomplete )then
            payResult = "payProductionInforIncomplete"
        end
    end

    local model = mymodel("ShopModel"):getInstance()
    local uniqueFlag = model:getUniqueFlag()
    dump(uniqueFlag)
    if uniqueFlag then
        local payResultLogSdkInfo = {
            ["payResult"]       = payResult,
            ["behaviorUnique"]  = uniqueFlag
        }
        my.dataLink(cc.exports.DataLinkCodeDef.NOBILITY_PAY_RESULT, payResultLogSdkInfo)
    end
end



function ShopModel:LoadShopItemsConfig(bReadCache)
    local deshopItems
    local abb = my.getGameShortName()

    local configName = mymodel("UpdateConfigsModel"):getInstance():getShopConfigName()

    if bReadCache then
        local path = my.getFullCachePath(configName)
        deshopItems = cc.FileUtils:getInstance():getStringFromFile(path)
    else
        if not self._appversion_cache then
            deshopItems = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/shopconfig/" .. configName)
        else
            if self._appversion_cache == my.getGameVersion() then
                if self._cacheVersionID and self._cacheVersionID > self._apkVersionID then
                    local path = my.getFullCachePath(configName)
                    deshopItems = cc.FileUtils:getInstance():getStringFromFile(path)
                else
                    deshopItems = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/shopconfig/" .. configName)
                end
            else
                deshopItems = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/shopconfig/" .. configName)
            end
        end
    end
    self._ShopJsonItem = {}
    if deshopItems then
        shopItems = json.decode(deshopItems)
        self:ParseItem(shopItems)
        mymodel("PayModel"):getInstance():setCallback(self.payCallback)
    end
end

function ShopModel:LoadShopItemsConfigFromHttp(Json)

end

function ShopModel:queryShopConfigUpdate()
   -- local gameID = my.getGameID()
   -- local channelID = BusinessUtils:getInstance():getClientChannelId()
   -- local gameverString=my.getGameVersion()
   local UPDATETYPE = 1
   UpdateConfigsModel:SendHttp(self.versionID, UPDATETYPE)
end


function ShopModel:isIDinTabs(id)
    if self._ShopUIConfig["tabcount"] then
        for i=1, self._ShopUIConfig["tabcount"] do
            local ids = self:GetIDsByTabs(i)
            for j=1, #ids do
                if ids[j] == id then
                    return true
                end
            end
        end
        return false
    end
    return false
end

function ShopModel:GetShopUIConfig()
    return self._ShopUIConfig
end

function ShopModel:ParseItem(payObject)
    if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["tabcount"] then
        self._ShopUIConfig["tabcount"] = payObject["payconfig"]["shopui"]["tabcount"]
    end
    if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["shoptips"] then
        self._ShopUIConfig["shoptips"] = payObject["payconfig"]["shopui"]["shoptips"]
    end
    if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["viptips"] then
        self._ShopUIConfig["viptips"] = payObject["payconfig"]["shopui"]["viptips"]
    end

    if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["announce"] then
        self._ShopUIConfig["announce"] = payObject["payconfig"]["shopui"]["announce"]
    end

    if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["showitemperline"] then
        self._ShopUIConfig["showitemperline"] = payObject["payconfig"]["shopui"]["showitemperline"]
    end

    if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["headheight"] then
        self._ShopUIConfig["headheight"] = payObject["payconfig"]["shopui"]["headheight"]
    end

    if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["perheight"] then
        self._ShopUIConfig["perheight"] = payObject["payconfig"]["shopui"]["perheight"]
    end

    if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["personinfogototab"] then
        self._ShopUIConfig["personinfogototab"] = payObject["payconfig"]["shopui"]["personinfogototab"]
    end
    
    
    if self._ShopUIConfig["tabcount"] then
        for p=1, self._ShopUIConfig["tabcount"] do
            if payObject["payconfig"] and payObject["payconfig"]["shopui"] and payObject["payconfig"]["shopui"]["items_tab" ..p] then
                self._ShopUIConfig["items_tab" ..p] = payObject["payconfig"]["shopui"]["items_tab" ..p]
            end
        end
    end
    local pay = payObject["payconfig"]["products"]["product"]
    for i, v in pairs(pay)do
        local shopItem={}
        shopItem["id"] = v["id"]
        if v["sid"] then
            shopItem["productid"] = v["sid"]
        else
            shopItem["productid"] = ""
        end

        shopItem["exchangeid"] = v["exchangeid"]
        shopItem["producttype"] = v["producttype"]
        shopItem["producttypeex"] = v["producttypeex"]

        --只有银子才有paytype
        if v["producttype"] == 1 then
            shopItem["paytype"] = v["paytype"]
        end

        --自定义字段（用于区分道具类型）
        shopItem["proptype"] = v["proptype"]

        shopItem["price"] = v["price"]
        shopItem["productnum"] =  v["productnum"]
        shopItem["limit"] =  v["limit"]
        shopItem["notetip"] =  v["notetip"]

        shopItem["page"] =  v["page"]
        shopItem["order"] =  v["order"]
        shopItem["icontype"] =  v["icontype"]
        shopItem["labeltype"] =  v["labeltype"]
        shopItem["title"] =  v["title"]
        shopItem["description"] =  v["description"]

        shopItem["productname"] =  v["productname"]
        shopItem["product_subject"] =  v["product_subject"]
        shopItem["product_body"] =  v["product_body"]
        shopItem["app_currency_name"] =  v["app_currency_name"]
        shopItem["app_currency_rate"] =  v["app_currency_rate"]

        if cc.exports.isFirstRechargeSupported() and v["firstpay"] and cc.exports.isShopSupported() then
            shopItem["firstpay_rewardnum"] = v["firstpay"]["rewardnum"]
            if v["firstpay"]["description"] and v["firstpay"]["description"]~='' then
                shopItem["fristpay_description"] = v["firstpay"]["description"]
            else
                shopItem["fristpay_description"] = v["description"]
            end

            if v["firstpay"]["productname"] and v["firstpay"]["productname"]~='' then
                shopItem["fristpay_productname"] = v["firstpay"]["productname"]
            else
                shopItem["fristpay_productname"] = v["productname"]
            end

            if v["firstpay"]["product_subject"] and v["firstpay"]["product_subject"]~='' then
                shopItem["fristpay_product_subject"] = v["firstpay"]["product_subject"]
            else
                shopItem["fristpay_product_subject"] = v["product_subject"]
            end

            if v["firstpay"]["product_body"] and v["firstpay"]["product_body"]~='' then
                shopItem["fristpay_product_body"] = v["firstpay"]["product_body"]
            else
                shopItem["fristpay_product_body"] = v["product_body"]
            end

            if v["firstpay"]["app_currency_name"] and v["firstpay"]["app_currency_name"]~='' then
                shopItem["fristpay_app_currency_name"] = v["firstpay"]["app_currency_name"]
            else
                shopItem["fristpay_app_currency_name"] = v["app_currency_name"]
            end

            if v["firstpay"]["app_currency_rate"] and v["firstpay"]["app_currency_rate"]~='' then
                shopItem["fristpay_app_currency_rate"] = v["firstpay"]["app_currency_rate"]
            else
                shopItem["fristpay_app_currency_rate"] = v["app_currency_rate"]
            end
        end

        shopItem["through_data"]=""
        local ex

        local RewardToGame = 0
        --[[
        if (v["producttype"] == 1) then
            RewardToGame = v["paytype"]
        else
            RewardToGame = 0
        end]]
        ex = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}",RewardToGame, v["exchangeid"])
        shopItem["through_data"] = ex

        table.insert(self._ShopJsonItem, shopItem)
    end
    if cc.exports.isFirstRechargeSupported() and cc.exports.isShopSupported() then
        -- if(true == self:readFromCacheData())then
        --     return
        -- end
        --self:GetFirstRechargeInfo()
    end
end


function ShopModel:GetFirstRechargeInfo()
    local baseUrl
    local ActId = require("src.app.HallConfig.ActivitysConfig").RechargeId
    if cc.exports.IsHejiPackage() then
        ActId = require("src.app.HallConfig.ActivitysConfig").RechargeId_HJ  --合集
    end
    if not ActId then
        return
    end

    local UserId = user.nUserID
    local device=mymodel('DeviceModel'):getInstance()
    local szWifiID,szImeiID,szSystemID=device.szWifiID,device.szImeiID,device.szSystemID
    local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)

    local Time = os.time()*1000

    local keyString=string.format('%d|%d|%.0f',ActId,UserId ,Time)
    local md5String = my.md5(keyString)

    if (BusinessUtils:getInstance():isGameDebugMode()) then
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
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == 200 )then
            local AppJsonObj = json.decode(xhr.response)
            printf("~~~~~~~~~~~~~save recharge~~~~~~~~~~~~~~")
            self:saveCacheFirstRecharge(AppJsonObj)
            self:ParseResurceResponse(AppJsonObj)
        else
            self:DispatchPayItem()
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

function ShopModel:saveCacheFirstRecharge(dataMap)
    local data=checktable(dataMap)
    data.queryDate = self:getTodayDate()
    my.saveCache(ShopModel:getCacheDataName(),data)
end

function ShopModel:getCacheDataName()
    local cacheFile= "firstpayState.xml"
    local user=mymodel('UserModel'):getInstance()
    local id = user.nUserID
    cacheFile = id.."_"..cacheFile
    return cacheFile
end

function ShopModel:getTodayDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())
    return tmYear.."_"..tmMon.."_"..tmMday
end

function ShopModel:readFromCacheData()
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

    self:ParseResurceResponse(dataMap)
    return true
end

function ShopModel:ParseResurceResponse(obj)
    local support = {}
    local item = obj["Data"]
    if not item then 
        return
    end
    for i,v in pairs(item)do
        local s = {}
        --混蛋啊 游戏ID 这么好的东西传过来 之前居然不判断 现在加上 想用别人的活动想都别想
        if v["GameCode"] and (v["GameCode"] == my.getAbbrName() or v["GameCode"] == my.getParentAbbrName()) then
            s["Price"] = tonumber( v["GoodsPrice"] )
            s["Type"] = tonumber( v["GoodsType"] )
            s["Code"] = v["GameCode"]
            table.insert(support,s)
        end
    end

    local ActId = require("src.app.HallConfig.ActivitysConfig").RechargeId
    if cc.exports.IsHejiPackage() then
        ActId = require("src.app.HallConfig.ActivitysConfig").RechargeId_HJ  --合集
    end

    local device = mymodel('DeviceModel'):getInstance()
    local szWifiID,szImeiID,szSystemID=device.szWifiID,device.szImeiID,device.szSystemID
    local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)

    if not self._ShopJsonItem then
        return
    end
    for p,q in pairs(self._ShopJsonItem)do
        if q then
            q["First_Support"] = 0
        end
    end

    for i,v in pairs(support)do
        for z,k in pairs(self._ShopJsonItem)do
            if( (k["producttype"]==v["Type"]) and (k["price"]==v["Price"]) )then
                k["First_Support"] = 1

                local ex=""

                if k["producttype"]==1 then
                    if k["exchangeid"] then
                        ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}",v["Code"],ActId,deviceId,0,k["exchangeid"])
                    end
                    --[[
                    if k["paytype"] then
                        if k["exchangeid"] then
                            ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}",v["Code"],ActId,deviceId,k["paytype"],k["exchangeid"])
                        else
                            ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}",v["Code"],ActId,deviceId,k["paytype"])
                        end
                    else
                         if k["exchangeid"] then
                            ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}",v["Code"],ActId,deviceId,0,k["exchangeid"])
                        else
                            ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}",v["Code"],ActId,deviceId,0)
                        end
                    end
                else
                    if k["exchangeid"] then
                        ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}",v["Code"],ActId,deviceId,0,k["exchangeid"])
                    else
                        ex = string.format("{\"GameCode\":\"%s\",\"ActId\":%d,\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}",v["Code"],ActId,deviceId,0)
                    end
                --]]
                end
                
                k["through_data"] = ex
            end
        end
    end
    self:onDealFirstPay()
end

function ShopModel:GetShopItemsInfo()
    return self._ShopJsonItem
end

function ShopModel:GetItemByID(id)
    for i, v in pairs(self._ShopJsonItem) do
        if v then
            if v["id"] == id then
                return v   
            end
        end
    end
    return nil
end

function ShopModel:GetIDsByTabs(tab)
    self._tabIDs = {}
    if self._ShopUIConfig["items_tab"..tab] then 
        for i=1, #self._ShopUIConfig["items_tab"..tab] do
            local v = self:GetItemByID(self._ShopUIConfig["items_tab"..tab][i])
            if v then
                local ids={}
                ids = v["id"]
                table.insert(self._tabIDs, ids)
            end
        end
    end
    return self._tabIDs
end


function ShopModel:GetFirstRechargeItem()
    local pItem = nil
    for i, v in pairs(self._ShopJsonItem) do
        if v["First_Support"] == 1 and self:isIDinTabs (v["id"]) then
            if not pItem then
                pItem = v
            else
                if pItem["price"] > v["price"] then
                    pItem = v
                end
            end
        end
    end
    return pItem
end

function ShopModel:onDealFirstPay()
    for i,v in ipairs(self._ShopJsonItem) do
        if v["First_Support"] == 1 and self:isIDinTabs(v["id"]) then
            --self:dispatchEvent({name = ShopModel.EVENT_SHOW_FIRSTRECHARGE})
            self._myStatusDataExtended["isFirstRechargeAvail"] = true
            self:dispatchModuleStatusChanged("shop", ShopModel.EVENT_MAP["shopModel_firstRechargeAvailChanged"])
            return
        end
    end
    --self:dispatchEvent({name = ShopModel.EVENT_HIDE_FIRSTRECHARGE})
    self._myStatusDataExtended["isFirstRechargeAvail"] = false
    self:dispatchModuleStatusChanged("shop", ShopModel.EVENT_MAP["shopModel_firstRechargeAvailChanged"])
end

function ShopModel:DispatchPayItem()
    self:dispatchEvent({name = ShopModel.EVENT_GET_PAYITEM})
end

function ShopModel:GetShopTipsConfig()
    if not self._shopTipsJson then
        self:LoadShopTipsConfig()
    end
    return self._shopTipsJson
end

function ShopModel:updateCach(price,GoodsType)
    printf("~~~~start update cach price[%d] type[%d]",price,GoodsType)
    local dataMap
    local filename = self:getCacheDataName()
    if(false == my.isCacheExist(filename))then
        printf("~~~~~~~~~~no cach~~~~~~~~~~~~~~~~~~")
        return
    end
    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)
    if dataMap and dataMap["Data"] and type(dataMap["Data"]) == "table" then
    else
        return  
    end
    for j,k in pairs(dataMap["Data"])do
        if( (k["GoodsPrice"]==tonumber(price))and(k["GoodsType"]==tonumber(GoodsType)) )then
            table.remove(dataMap["Data"],j)
            self:saveCacheFirstRecharge(dataMap)
        end
    end
end

local function RechargeCallBack(code, msg)
    printInfo("%d", code)
    printInfo("%s", msg)
    printf("RechargePay.paycallback_working")

    if code == PayResultCode.kPaySuccess then
        
    elseif code == PayResultCode.kPayFail then
        printf("FirstRechargePay.BuyFailed")
    elseif code == PayResultCode.kPayTimeOut then
        printf("FirstRechargePay.Timeout")
    elseif code == PayResultCode.kPayProductionInforIncomplete then
        printf("FirstRechargePay.Infoincomplete")
    end
end


function ShopModel:PayForProduct(Item)
    self:PayForProductWithCustomCallback(Item, RechargeCallBack)
end

function ShopModel:PayForProductWithCustomCallback(Item, payCallBack)
    local extraParams = {}
    local shopconfig = self:GetShopTipsConfig()
    if shopconfig then
        extraParams["Pay_Title"]    = shopconfig["RechargeNeeded_Title"]
        extraParams["Pay_Content"]  = shopconfig["RechargeNeeded_Content"]
        mymodel("PayModel"):getInstance():payForProduct(Item, payCallBack, extraParams)
    end
end

--点号是故意的 ！
function ShopModel.payCallback(code,msg)
    print("ShopModel.payCallback")
    payCallBack(code,msg)
end

function ShopModel:DealPayResult(payResult)
    print("ShopModel:DealPayResult")
    dump(payResult)

    local FirstRechargeModel      = import("src.app.plugins.firstrecharge.FirstRechargeModel"):getInstance()

    if self:isTongbaoShopItem(tonumber(payResult['szGameGoodsID'])) then
        local PlayerModel = mymodel('hallext.PlayerModel'):getInstance()
        PlayerModel:update({'WealthInfo'})
        return
    end

    if payResult.nGameID ~= my.getGameID() then  --屏蔽其他游戏
        return
    end
    local pay_for = {
        [0] = function (to, amount)-- deposit
            if to == 0 then
                user.nSafeboxDeposit = amount
            elseif to==1 then
                user.nBackDeposit = amount
            elseif to==2 then
                user.nDeposit = amount
            end
        end,
        [1] = function (to, amount)-- score
            if to == 2 then
                user.nScore = amount
            end
        end;
    }
    local pay = pay_for[payResult['nPayFor']]
    if pay~=nil then pay(payResult['nPayTo'], payResult['llBalance']) end

    print("shopmodel EVENT_UPDATE_RICH")
    self:dispatchEvent({name=ShopModel.EVENT_UPDATE_RICH})
    local goodID = tonumber(payResult['szGameGoodsID'])
    print("goodID", goodID)
    local payInfo = mymodel("PayInfoModel"):getInstance()
    local infoTab = payInfo:getInfo()
    dump(infoTab)

    if goodID and goodID == infoTab.buyID then
        print("is ========================================================")
        if infoTab.buyType == PayInfoType.PAY_INFO_TYPE_CARD_MAKER then --购买记牌器
            local days = infoTab.buyNum
            self:PayForCardMaker(days)
        elseif infoTab.buyType == PayInfoType.PAY_INFO_TYPE_SILVER then --购买银子
            local rewardList = {}
            if infoTab.giveNum > 0 then
                table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = infoTab.buyNum})            
                table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = infoTab.giveNum})            
            else
                table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = infoTab.buyNum + infoTab.giveNum})            
            end
            my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
        elseif infoTab.buyType == PayInfoType.PAY_INFO_TYPE_TIMING_TICKET then --购买定时赛门票
            --交给TimingModel处理
            print("infoTab.buyType == PayInfoType.PAY_INFO_TYPE_TIMING_TICKET")
        end
    else  --防止充完值，回调还未回来时，再次点击充值，导致此时的infoTab信息已经修改，做校验
        print("goodID,  infoTab.buyID", goodID, infoTab.buyID)
            if goodID then
                if self:dealPropPayResult(goodID) then  --是道具
                    print("function ShopModel:DealPayResult(payResult) is prop")
                elseif self:dealLimitTimeGiftPayResult(goodID) then  --是限时礼包
                    print("function ShopModel:DealPayResult(payResult) is limitTimeGift")
                elseif self:dealSilverPayResult(goodID) then  --是商城银两充值
                    print("function ShopModel:DealPayResult(payResult) is NormalPay")
                elseif FirstRechargeModel:isFirstRechargeResult(goodID) then  --是首充充值
                    print("function ShopModel:isFirstRechargeResult(payResult) is NormalPay")
                elseif BankruptcyModel:isBankruptcyRechargeResult(goodID) then  --是破产礼包
                    print("function ShopModel:isBankruptcyRechargeResult(payResult) is NormalPay")
                elseif WeekCardModel:isWeekCardRechargeResult(goodID) then  --是周卡礼包
                    print("function ShopModel:isWeekCardRechargeResult(payResult) is NormalPay")
                elseif relief:isReliefRechargeResult(goodID) then  --是破产礼包
                    print("function ShopModel:isReliefRechargeResult(payResult) is NormalPay")
                elseif TimingGameModel:isTimingGameRechargeResult(goodID) then  --是定时赛
                    print("function ShopModel:isTimingGameRechargeResult(payResult) is NormalPay")
                elseif LuckyPackModel:isLuckyPackRechargeResult(goodID) then
                    print("function LuckyPackModel:isLuckyPackRechargeResult(payResult) is NormalPay")
                elseif ContinueRechargeModel:isContinueRechargeResult(goodID) then  --是连充
                    print("function ShopModel:isContinueRechargeResult(payResult) is NormalPay")
                elseif WeekMonthSuperCardModel:isWeekMonthSuperRechargeResult(goodID) then
                    print("function WeekMonthSuperCardModel:isWeekMonthSuperRechargeResult(payResult) is NormalPay")    
                elseif GratitudeRepayModel:isGratitudeRepayPayResult(goodID) then
                    print("function GratitudeRepayModel:isGratitudeRepayPayResult(payResult) is NormalPay")  
                elseif ValuablePurchaseModel:isValuablePurchasePayResult(goodID) then
                    print("function ValuablePurchaseModel:isValuablePurchasePayResult(payResult) is NormalPay")  
                elseif RechargeActivityModel:isRechargeActivityPayResult(goodID) then
                    RechargeActivityModel:rechargeInfoReq()
                    print("function ValuablePurchaseModel:iisRechargeActivityPayResult(payResult) is NormalPay")
                else --其他充值，包含月卡
                    print("function ShopModel:DealPayResult(payResult) is else", payResult["nOperateAmount"])
                    if tonumber(payResult["nOperateAmount"]) > 10 then  --认为大于10是购买银子，小于10可能是道具或者其他
                        local rewardList = {}
                        table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = payResult["nOperateAmount"]})
                        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
                        print("MonthCardModel._MonthGoodsID, ", MonthCardModel._MonthGoodsID)
                        if MonthCardModel._MonthGoodsID and MonthCardModel._MonthGoodsID == tostring(goodID) then
                            my.scheduleOnce(function()
                                MonthCardModel:QueryMonthCardReq()
                            end, 1)
                        end
                    else
                        local pJson = self:GetShopTipsConfig()
                        if pJson then
                            local showAccountText = pJson["BuyCommonOK"]
                            my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = showAccountText, removeTime = 2}})
                        end
                    end
                end
            end
        end

    if goodID then
        self:doAfterPayItemOK(goodID)
    end

    --充值完刷新充值有礼信息
    --local RechargeActivityModel = import('src.app.plugins.RechargeActivity.RechargeActivityModel'):getInstance()
    --RechargeActivityModel:rechargeInfoReq()

    --[[
    if self:dealPropPayResult(payResult) == false then
    else
        self._needshowtip = true
		local pJson = self:GetShopTipsConfig()
		if pJson then
			local showAccountText
			local pLastBuy = cc.exports.GetLastBuyItem()
			if pLastBuy then
				if pLastBuy["Type"] == 3 then
					showAccountText = pJson["AccountScoreOK"]
				else 
					if payResult["nPayTo"]==0 then
						showAccountText = pJson["AccountDepositInboxOK"]
					elseif payResult['nPayTo']==1 then
						showAccountText = pJson["AccountDepositInbackboxOK"]
					elseif(payResult["nPayTo"]==2)then
						showAccountText = pJson["AccountDepositOK"]
					end
				end
			end
			printf("~~~~~DealPayResult~~~%s~~~~~~",showAccountText)
			my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = showAccountText, removeTime = 2}})
		end
        print("shopmodel EVENT_UPDATE_RICH")
        self:dispatchEvent({name=ShopModel.EVENT_UPDATE_RICH})
    end
    --]]
    print("shopmodel : dealpayresult")

    -- 发送充值准备的数据，给chunsvr埋点使用
    if next(cc.exports.LogReChargeData) ~= nil then
        local AssistCommon = import("src.app.GameHall.models.assist.common.AssistCommon"):getInstance()
        AssistCommon:onReChargeLogReq(cc.exports.LogReChargeData)
        cc.exports.LogReChargeData = {}
    end
end

function ShopModel:PayForCardMaker(days)
    cc.exports.CardMakerInfo.nCardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown or 0
    cc.exports.CardMakerInfo.nCardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown + days*24*60*60

    self:dispatchEvent({name = self.EVENT_UPDATE_CARD_MAKER})
    --ShopExModel.Ctrl:OnUpdateCardMakerCount()
    
    --local config = cc.exports.GetShopConfig()
    --my.informPluginByName({pluginName='TipPlugin',params={tipString=config['TOOLS_BUY_SUCCESS'],removeTime=2}})
    print("isTool cc.exports.CardMakerInfo.nCardMakerCountdown", cc.exports.CardMakerInfo.nCardMakerCountdown)

    --[[local AssistConnect = require('src.app.plugins.AssistModel.AssistConnect'):getInstance()
    AssistConnect:DealPayResultCardMakerInfo()]]--
    local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
    CardRecorderModel:onCardRecorderInfoChanged()

    local rewardList = {}
    if days == 1 then
        table.insert( rewardList,{nType = RewardTipDef.TYPE_CARDMARKER_1D, nCount = 1})
    elseif days == 7 then
        table.insert( rewardList,{nType = RewardTipDef.TYPE_CARDMARKER_7D, nCount = 1})
    elseif days == 30 then
        table.insert( rewardList,{nType = RewardTipDef.TYPE_CARDMARKER_30D, nCount = 1})
    end
    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
end

function ShopModel:dealPropPayResult(goodID)  --充值是不是道具
    for i, v in pairs(self._ShopJsonItem) do
        if v and v.producttypeex == "prop" then
            if tonumber(v["exchangeid"]) == goodID then
                if v["proptype"] == "prop_cardrecorder_bout" 
                or v["proptype"] == "prop_cardrecorder_day" then
                    local days = tonumber(v["productnum"])
                    self:PayForCardMaker(days)
                    return true
                end
            end
        end
    end
    return false
end
function ShopModel:dealLimitTimeGiftPayResult(goodID)  --充值是不是限时礼包
    if type(cc.exports.limitTimeGiftConfig["Item_Config"]) ~= "table" then
        return false
    end
    for i,v in pairs(cc.exports.limitTimeGiftConfig["Item_Config"]) do  --限时礼包
        if tonumber(v["ex_id"]) == goodID then
            local rewardList = {}
            table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = v["Product_Count"] + v["First_Reward"]})
            my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
            return true
        end
    end
    return false
end
function ShopModel:dealSilverPayResult(goodID)  --充值是不是商城普通充值
    for i, v in pairs(self._ShopJsonItem) do
        if v and v.producttypeex == "deposit" then
            if tonumber(v["exchangeid"]) == goodID then
                local silverNum = v["productnum"]
                if v["First_Support"] == 1 then  --首充
                    silverNum = silverNum + v["firstpay_rewardnum"]
                end
                local rewardList = {}
                table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = silverNum})
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
                return true
            end
        end
    end
    return false
end
--local accountVIPTimer=nil

--[[local function ShowVIPAccountTips()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(accountVIPTimer)
    accountVIPTimer=nil
    printf("~~~~~ShowVIPAccountTips ok~~~~~~~~~")

end

function ShopModel:doAfterPayVIPOK()
    printf("~~~~~~~~~~~doAfterPayVIPOK ~~~~~~~~~~~~~~")
    accountVIPTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(ShowVIPAccountTips, 3, false)
end]]--

function ShopModel:DealPayVIPResult(payResult)
    --if(accountVIPTimer==nil)then
        local showAccountText
        showAccountText = cc.exports.GetShopTipsConfig()["AccountVIPOK"]
        printf("~~~~~DealPayResult~~~%s~~~~~~",showAccountText)
        my.informPluginByName({pluginName='TipPlugin',params={tipString=showAccountText,removeTime=2}})

    --end
    user.isMember=true
    local relief=mymodel('hallext.ReliefActivity'):getInstance()
    relief:queryUserState()
    local s=tostring(payResult["nMemberEnd"])
    if user.memberInfo == nil then
        user.memberInfo = {}
        user.memberInfo.endline = {}
    end
    user.memberInfo.endline.nYearEnd= tonumber(string.sub(s,1,4))
    user.memberInfo.endline.nMonthEnd=tonumber(string.sub(s,5,6))
    user.memberInfo.endline.nDayEnd=tonumber(string.sub(s,7,8))
    self:dispatchEvent({name=ShopModel.EVENT_UPDATE_RICH})
    print("shopmodel : dealpayvipresult")
end

function ShopModel:getLastItemFileName()
    local cacheFile= "shopstate.xml"
    local id = user.nUserID
    cacheFile = id.."_"..cacheFile
    return cacheFile
end

function ShopModel:SaveLastBuyItem(productrice, producttype, productnum, isfirstsupport)
    local data={}
    data.productrice = productrice
    data.producttype = producttype
    data.productnum = productnum or 0
    data.isfirstsupport = isfirstsupport or 0
    my.saveCache(self:getLastItemFileName(),data)

    printf("~~~~~~~~save lastitem price[%d] type[%d] num[%d] first[%d]~~~~~~~~",data.productrice, data.producttype, data.productnum, data.isfirstsupport)
end

function ShopModel:GetLastBuyItem()

    local dataMap
    local filename = self:getLastItemFileName()
    if(false == my.isCacheExist(filename))then
        printf("~~~~~~~~no shop item file~~~~~~~~")
        return nil
    end

    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)

    local item = {}
    item["Price"] = dataMap.productrice
    item["Type"]= dataMap.producttype
    item["Num"] = dataMap.productnum
    item["First"]= dataMap.isfirstsupport

    return item
end


function ShopModel:getQuickBuyItemFileName()
    local cacheFile= "quickbuy.xml"
    local id = user.nUserID
    cacheFile = id.."_"..cacheFile
    return cacheFile
end

function ShopModel:SaveQuickBuyItem(id)
    local data={}
    data.id = id
    my.saveCache(self:getQuickBuyItemFileName(),data)
end

function ShopModel:GetQuickBuyItem()
    local dataMap
    local filename = self:getQuickBuyItemFileName()
    if(false == my.isCacheExist(filename))then
        printf("~~~~~~~~no shop item file~~~~~~~~")
        return nil
    end

    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)

    local item={}
    item["id"] = dataMap.id

    return item
end

--[[function ShopModel:GetPersonInfoGotoTab(index)
    if self._ShopUIConfig and self._ShopUIConfig["personinfogototab"] and self._ShopUIConfig["personinfogototab"][index]then
        return self._ShopUIConfig["personinfogototab"][index]
    end
    return 1
end]]--

function ShopModel:isScoreLimit(limit)
    local nScore = user.nScore
    if nScore and limit and nScore >= limit then
        return true
    end
    return false
end

function ShopModel:tryBuyShopItem(itemData)
    print("ShopModel:tryBuyShopItem")
    if itemData == nil then
        print("shop itemData is nil!!!")
        return
    end

    if itemData["producttypeex"] == "prop" then
        self:tryBuyProp(itemData)
    elseif itemData["producttypeex"] == "expression" then
        self:tryBuyExpression(itemData)
    elseif itemData["producttypeex"]  == "exchange" then
        self:tryExchangeTongbaoToSilver(itemData)
    else
	    ShopModel:PayForProduct(itemData) --银子和VIP
    end
end

--购买道具
function ShopModel:tryBuyProp(itemData)
    print("ShopModel:tryBuyShopItem")
    if itemData == nil then
        print("shop itemData is nil!!!")
        return
    end

    print("ShopModel:_tryBuyProp "..tostring(itemData["proptype"]))
    if itemData["proptype"] == "prop_cardrecorder_bout" or itemData["proptype"] == "prop_cardrecorder_day" then
        self:tryBuyCardRecorder(itemData) --记牌器
    elseif itemData["proptype"] == "prop_timinggame_ticket_deposit" or itemData["proptype"] == "prop_timinggame_ticket_rmb" or itemData["proptype"] == "prop_timinggame_ticket_rmb_first" then
        self:tryBuyTimingGameTicket(itemData)
    end
end

--购买表情
function ShopModel:tryBuyExpression(itemData)
    print("ShopModel:tryBuyExpression")
    if itemData == nil then
        print("shop itemData is nil!!!")
        return
    end

    local allItemCanTouch = true
    for i = 1, #self._ExpressionitemTouchAgain do
        if not self._ExpressionitemTouchAgain[i] then
            allItemCanTouch = false
            break
        end
    end

    local shopconfig = self:GetShopTipsConfig()
    if not allItemCanTouch then  --同时点击和快速点击
        my.informPluginByName({pluginName='TipPlugin',params={tipString=shopconfig["EXPRESSION_CD_TIPS"],removeTime=2}})
        return
    end

    local index = tonumber(itemData.icontype) - 4
    self._ExpressionitemTouchAgain[index] = false
    my.scheduleOnce(function()
        self._ExpressionitemTouchAgain[index] = true
        end, 1.2)
    

    print("ShopModel:tryBuyExpression "..tostring(itemData["proptype"]))
    if user.nDeposit == nil then
        user.nDeposit = 0
    end


    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.ExpressionTools then
        if user.nDeposit < itemData["price"] then
            my.informPluginByName({pluginName='TipPlugin',params={tipString=shopconfig["EXPRESSION_CLICK_TIPS"],removeTime=2}})
        elseif cc.exports._gameJsonConfig.ExpressionTools.ExpressionSilverLimit > 0 and user.nDeposit < cc.exports._gameJsonConfig.ExpressionTools.ExpressionSilverLimit then
            my.informPluginByName({pluginName='TipPlugin',params={tipString=shopconfig["EXPRESSION_CLICK_TIPS"],removeTime=2}})
        else
            local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
			PropModel:sendBuyUserProp(itemData.icontype, 1)
        end
    else
        local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
		PropModel:sendBuyUserProp(itemData.icontype, 1)
    end
end
--购买记牌器
function ShopModel:tryBuyCardRecorder(itemData)
    print("ShopModel:tryBuyCardRecorder")
    if itemData == nil then
        print("shop itemData is nil!!!")
        return
    end

    if self:_checkBuyCardRecorder(itemData["proptype"]) == false then
        return
    end

    if itemData["proptype"] == "prop_cardrecorder_bout" then
        --银两购买记牌器
        local shopconfig = self:GetShopTipsConfig()
        if cc.exports.CardMakerInfo.nCardMakerCountdown and cc.exports.CardMakerInfo.nCardMakerCountdown > 0 then
            my.informPluginByName({pluginName='TipPlugin',params={tipString=shopconfig["TOOLS_HAVE_RMB"],removeTime=2}})
        else
            if user.nDeposit and user.nDeposit >= itemData["price"] then
                my.informPluginByName({pluginName = 'ShopToolsSelectPlugin', params = itemData})
            else
                my.informPluginByName({pluginName ='TipPlugin',params = {tipString = shopconfig["EXPRESSION_CLICK_TIPS"], removeTime = 1}})
            end
        end
    else
        --人民币购买记牌器
        ShopModel:PayForProduct(itemData) 
    end
end


--有局数记牌器，则不让购买天数记牌器
function ShopModel:_checkBuyCardRecorder(propType)
    if propType == "prop_cardrecorder_day" then
        if cc.exports.CardMakerInfo and 
           cc.exports.CardMakerInfo.nCardMakerNum and 
           cc.exports.CardMakerInfo.nCardMakerNum > 0 then
            local config = cc.exports.GetShopTipsConfig()
            my.informPluginByName({pluginName='TipPlugin',params={tipString=config["TOOLS_HAVE_SLIVER"],removeTime=2}})
            return false
        end
    end
    return true
end

--定时赛相关 start
function ShopModel:addShopItemToConfig(config, tabIndex)
    local index = #self._ShopJsonItem
    for i = 1, #self._ShopJsonItem do
        local shopItem = self._ShopJsonItem[i]
        if shopItem.proptype and shopItem.proptype == config.proptype then
            return
        end
    end
    local item = clone(config)
    item.id = index + 1
    if self._ShopUIConfig["items_tab" .. tabIndex] and self._ShopJsonItem then
        table.insert(self._ShopUIConfig["items_tab" .. tabIndex], index + 1) 
        table.insert(self._ShopJsonItem, item) 
    else
        if not self._hasAddTimingGameConfig then
            self._hasAddTimingGameConfig = true
            my.scheduleOnce(function()
                TimingGameModel:addConfigToShopModel()
            end, 3)
        end
    end
end

--移除首次购买项
function ShopModel:removeShopItemFromConfig(proptype, tabIndex)
    for i = 1, #self._ShopJsonItem do
        local shopItem = self._ShopJsonItem[i]
        if shopItem.proptype and shopItem.proptype == proptype then
            table.remove(self._ShopUIConfig["items_tab" .. tabIndex], shopItem.id)
            table.remove(self._ShopJsonItem, i)
            return
        end
    end
end

--购买门票
function ShopModel:tryBuyTimingGameTicket(itemData)
    print("ShopModel:tryBuyTimingGameTicket")
    if itemData == nil then
        print("shop itemData is nil!!!")
        return
    end

    if itemData["proptype"] == "prop_timinggame_ticket_deposit" then
        --银两购买记牌器
        local shopconfig = self:GetShopTipsConfig()
        if user.nDeposit and user.nDeposit >= itemData["price"] then
            local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
            PropModel:sendBuyUserProp(itemData.propid)
        else
            my.informPluginByName({pluginName ='TipPlugin',params = {tipString = shopconfig["EXPRESSION_CLICK_TIPS"], removeTime = 1}})
        end
    else
        --人民币购买记牌器
        ShopModel:PayForProduct(itemData) 
    end
end
--end

function ShopModel:getShopItemData(productTypeEx, productPrice, propType)
    for _, itemData in pairs(self._ShopJsonItem) do
        if itemData and itemData["producttypeex"] == productTypeEx and itemData["price"] == productPrice then
            if propType and itemData["proptype"] == propType then
                return itemData
            else
                return itemData
            end
        end
    end
    return nil
end

function ShopModel:getQuickChargeItemDataForRoom(roomMinDeposit, lackDeposit)
    local RechargeData = {
        ["lackDeposit"] = lackDeposit,
        ["itemData"] = nil
    }
    if roomMinDeposit == nil then 
        return RechargeData 
    end

    local needMoney = nil
    local QuickBuyConfig = cc.exports._QuickBuyConfig
    dump(QuickBuyConfig)
    if QuickBuyConfig and QuickBuyConfig.nDeposit and QuickBuyConfig.nMoney then
        for i = 1, table.maxn(QuickBuyConfig.nDeposit) do
            if roomMinDeposit <= QuickBuyConfig.nDeposit[i]  then
                needMoney = QuickBuyConfig.nMoney[i]
                break
            end
        end
        if needMoney == nil then
            needMoney = QuickBuyConfig.nMoney[ table.maxn(QuickBuyConfig.nMoney)]
        end
    end
    if needMoney then
        for _, itemData in pairs(self._ShopJsonItem) do
            if itemData and itemData["producttype"] == 1 and itemData["price"] == needMoney then
                RechargeData.itemData = itemData
                break
            end
        end
    end
    if RechargeData.itemData == nil then
        for _, itemData in pairs(self._ShopJsonItem) do
            if itemData and itemData["producttype"] == 1 then
                local totalProductCount = itemData["productnum"]
                if itemData["First_Support"] == 1 then
                    totalProductCount = totalProductCount + itemData["firstpay_rewardnum"]
                end
                if totalProductCount >= roomMinDeposit then
                    RechargeData.itemData = itemData
                    break
                end
            end
        end
    end

    return RechargeData
end

function ShopModel:getQuickChargeItemDataByExchangeId(exchangeid, lackDeposit)
    if type(exchangeid) ~= 'number' or type(lackDeposit) ~= 'number' then
        return nil
    end
    for _, itemData in pairs(self._ShopJsonItem) do
       if itemData["exchangeid"] == exchangeid then
            local RechargeData = {
                ["lackDeposit"] = lackDeposit,
                ["itemData"] = itemData
            }
            return RechargeData
       end
    end
    return nil
end

function ShopModel:onUpdateExpressionTips()
    self:dispatchEvent({name = ShopModel.EVENT_UPDATE_EXPRESSION_TIPS})
end

function ShopModel:onDealFirstRecharge(status)
    if status then
        self._myStatusDataExtended["isFirstRechargeAvail"] = true
        self:dispatchModuleStatusChanged("shop", ShopModel.EVENT_MAP["shopModel_firstRechargeAvailChanged"])
        return
    end

    self._myStatusDataExtended["isFirstRechargeAvail"] = false
    self:dispatchModuleStatusChanged("shop", ShopModel.EVENT_MAP["shopModel_firstRechargeAvailChanged"])
end

function ShopModel:initConfigVersion(  )
    local ChangeToNewAddtion = CacheModel:getCacheByKey("ChangeToNewAddtion")
    if type(ChangeToNewAddtion) == "number" and ChangeToNewAddtion == 1 then
        self.__configVersion = self:parseVersion(self.__configContent)
    else
        self.__configVersion = 0
    end
end

function ShopModel:getShopItemByExchangeId(exchangeid)
    for _, itemData in pairs(self._ShopJsonItem) do
        if itemData["exchangeid"] == exchangeid then
             return clone(itemData)
        end
    end
    return nil
end

function ShopModel:tryExchangeTongbaoToSilver(itemData)
    if itemData.price > user.dWealth then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '通宝余额不足，请充值~', removeTime = 2}})
        return
    end

    local tipContent = string.format('是否使用%d通宝兑换%d银子？', itemData.price, itemData.productnum)
    my.informPluginByName({
        pluginName="SureDialog",
        params = {
            tipContent = tipContent,
            onOk = function()
                local TongbaoModel = import('src.app.plugins.shop.tongbao.TongbaoModel'):getInstance()
                TongbaoModel:onTongbaoExchange(itemData.exchangeid, itemData.price)
            end,
            closeBtVisible = true,
        }
    })
end

function ShopModel:isTongbaoShopItem(exchangeid)
    if exchangeid == 0 then
        return true
    end
    local shopItem = self:getShopItemByExchangeId(exchangeid)
    if shopItem and shopItem.producttypeex == 'tongbao' then
        return true
    end
    return false
end

return ShopModel