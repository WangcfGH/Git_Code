
local player = mymodel('hallext.PlayerModel'):getInstance()
local MonthCardModel = require("src.app.plugins.monthcard.MonthCardConn"):getInstance()
local MonthCardRecharge = class("MonthCardRecharge")

local payInfo = mymodel("PayInfoModel"):getInstance()
MonthCardRecharge.EVENT_PURCHASE_SUCCEEDED = "purchase succeeded!"

local event = cc.load('event')
event:create():bind(MonthCardRecharge)

local payConfig = nil
local payObject = nil
local ShopJsonObj = {}
ShopJsonObj["PayItemConfig"] = {}
ShopJsonObj["FirstPayItemConfig"] = {}

if device.platform == "ios" then
    if cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
        payConfig = "monthcard_payconfig_forlua_ios.json"
        MonthCardRecharge.CurDeviceType = "ios"
    else
        payConfig = "monthcard_payconfig_forlua_ios_tcyapp.json"
        MonthCardRecharge.CurDeviceType = "ios_tcyapp"
    end
else
    payConfig = "monthcard_payconfig_forlua.json"
    MonthCardRecharge.CurDeviceType = "andriod"

    if cc.exports.IsHejiPackage() then
        payConfig = "monthcard_payconfig_forlua_Heji.json"
    end
end


local function payMCardCallBack(code, msg)
    printInfo("%d",code)
    printInfo("%s",msg)

    local config = cc.exports.GetShopConfig()

    if( code == PayResultCode.kPaySuccess )then
        MonthCardRecharge.Ctrl._PayResultOK = true 
        MonthCardRecharge:doAfterPayMCardOK()
    else
        MonthCardRecharge.Ctrl._PayResultOK = false 

        if string.len(msg) ~=0 then
            my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=1}})
        end
        if( code == PayResultCode.kPayFail )then

        elseif( code == PayResultCode.kPayTimeOut )then

        elseif( code == PayResultCode.kPayProductionInforIncomplete )then

        end
    end
end

function MonthCardRecharge:doAfterPayMCardOK()
    -- TODO：1、 notify assist server to save
    --  2、change the payButton status
    MonthCardRecharge.Ctrl:enablePayButton(false)
    MonthCardRecharge.Ctrl:StartPayLoading()
end

function MonthCardRecharge:StartGetMCardRechargeconfig()
    local s = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/" .. payConfig)
    payObject = json.decode( s )
    self:combinationMCardRechargeItem()
end

function MonthCardRecharge:combinationMCardRechargeItem()

    local pay = payObject["payconfig"]["products"]["product"]
    for i,v in pairs(pay)do
        local shopItem={}

        --for sdk
        if(v["sid"])then
            shopItem["Product_Id"] = v["sid"]
        else
            shopItem["Product_Id"] = ""
        end
        shopItem["Product_Name"]=         v["productname"]
        shopItem["Product_Final_Name"]=   v["productfinalname"]
        shopItem["Product_Price"]=        v["price"]
        shopItem["Product_Count"]=        v["productnum"]
        shopItem["Pay_Type"]=             v["paymodeids"]
        shopItem["ExchangeId"]=v["producttype"]

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
        shopItem["First_Support"]=0
        shopItem["product_subject"]  =  v["product_subject"]
        shopItem["product_body"]     =  v["product_body"]
        shopItem["app_currency_name"]=  v["app_currency_name"]
        shopItem["app_currency_rate"]=  v["app_currency_rate"]

        shopItem["limit"] = v["limit"]

        shopItem["ex_id"]=v["exchangeid"]
        shopItem["through_data"]=""

        ShopJsonObj["Trans_type"]=payObject["payconfig"]["paytype"]
        local ex
        local gameGoodsId = "g"..tostring(v["exchangeid"])
        MonthCardModel._MonthGoodsID = tostring(v["exchangeid"])       
        if(ShopJsonObj["Trans_type"]==2)then
            --ex = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d, \"GameGoodsId\":%d}",0,v["exchangeid"], gameGoodsId)
            ex = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}",0,v["exchangeid"])
        elseif(ShopJsonObj["Trans_type"]==3)then
            ex = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}",0,v["exchangeid"])
        end
        shopItem["through_data"] = ex

        -- 第一项作为月卡首充的配置;区别是 首充半价
        if 1 == i then
            ShopJsonObj["FirstPayItemConfig"] = shopItem
        elseif 2 == i then
            ShopJsonObj["PayItemConfig"] = shopItem
        else
            ShopJsonObj["OtherPayItemConfig"] = shopItem
        end
    end
end

function MonthCardRecharge:GetMCardRechargeItemsInfo(index)
    local keyTable = {"FirstPayItemConfig", "PayItemConfig", "OtherPayItemConfig"}
    local defaultKey = keyTable[index]
    if defaultKey ~= nil then
        return ShopJsonObj[defaultKey]
    else
        return ShopJsonObj["PayItemConfig"]
    end
end

function MonthCardRecharge:PayForProduct()

    local con = DeviceUtils:getInstance():isNetworkConnected()
    if(con == false)then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName='TipPlugin',params={tipString=config["NET_NOT_CONNECTED"],removeTime=1}})
        return false
    end

    if(my.IsInCommunication)then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName='TipPlugin',params={tipString=config["InLoginTip"],removeTime=1}})
        return false
    end

    if(my.IsOffline)then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName='TipPlugin',params={tipString=config["LoginOffTip"],removeTime=1}})

        local mclient=mc.createClient()
        mclient:reconnect('hall')
        return false
    end

    if(my.IsLoginOff)then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName='TipPlugin',params={tipString=config["LoginOffTip"],removeTime=1}})

        local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
        --local constStrings=cc.load('json').loader.loadFile('KickedOff.json')
        local gameId = require('src.app.HallConfig.PluginConfig').ExtraConfig.GameID
        userPlugin:userLogin(gameId,cc.exports.GetLoginExtra())
        return false
    end
    
    local idx = 3    -- 2019年3月11日  取最新的配置
    -- 由于同城游IOS没有3元计费点，因此ios_tcyapp类型直接取消首充3元的优惠。 --- 与策划沟通后的处理
    if MonthCardRecharge.Ctrl:isFirstPay() and MonthCardRecharge.CurDeviceType ~= "ios_tcyapp" then  idx = 1 end
    local v = MonthCardRecharge:GetMCardRechargeItemsInfo(idx)
    if(v == nil)then
        printf("~~~~~~~~~~~~~~nil monthCard item~~~~~~~~~")
        return
    end

    local param = {}
    param["Product_Id"]=  tostring( v["Product_Id"] )
    param["Product_Price"]= tostring( v["Product_Price"] )
    if(v["First_Support"]==1)then
        param["Product_Name"]=v["Product_Final_Name"]
        param["Product_Count"]= tostring(v["Product_Count"]+v["First_Reward"])
        param["pay_point_num"]= tostring(v["First_Point"])
    else
        param["Product_Name"]=v["Product_Name"]
        param["Product_Count"]= tostring( v["Product_Count"] )
        param["pay_point_num"]= tostring(v["Charge_Point"])
    end
    

    param["through_data"]= v["through_data"]

    local user = PUBLIC_INTERFACE.GetPlayerInfo()
    param["Role_Id"]= tostring( user["nUserID"] )
    param["Role_Name"]= MCCharset:getInstance():gb2Utf8String( user["szUsername"],string.len(user["szUsername"]) )
    param["Role_Grade"]= tostring( user["nExperience"] )
    param["Role_Balance"]= tostring( user["nDeposit"] )
    param["Role_Token"]= tostring( user["szPassword"] )
    param["Server_Id"]= tostring( 1 )

    local g = require("src/app/GameHall/models/GameModel"):getInstance()
    param["Channel_Id"]= tostring( g.szChannelID )
    param["Client_Id"]= tostring( g.clientID )
    param["Exchange_Id"]= tostring( v["ExchangeId"] )
    param["Game_Id"]= 81 --require('src.app.HallConfig.PluginConfig')["ExtraConfig"]["GameID"]
    param["EXT"]=""
    --local constStrings=cc.load('json').loader.loadFile('KickedOff.json')
    param["ext_args"]= cc.exports.getPayExtArgs(v)
    local short = cc.exports.PUBLIC_INTERFACE.GetGameShortName().."_an"
    param["App_name"]=short

    local m = require("src/app/GameHall/models/DeviceModel"):getInstance()
    param["WifiID"]= tostring( m.szWifiID )
    param["Imei"]= tostring( m.szImeiID )
    param["SystemId"] = tostring( m.szSystemID )

    local kpiData = my.getKPIClientData()
    param["RecomGameId"]   = tostring(kpiData.RecomGameId)
    param["RecomGameCode"] = kpiData.RecomGameCode
    param["RecomGameVers"] = ""
    
    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "MonthCardRecharge:payForProduct param")
        my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
    else
        local iapPlugin = plugin.AgentManager:getInstance():getIAPPlugin()
        iapPlugin:setCallback( payMCardCallBack )        

        dump(param)
        MonthCardRecharge:readyForReChargeLogReg(param)
        iapPlugin:payForProduct(param)
        --MonthCardRecharge:doAfterPayMCardOK()  -- only test
    end
end

function MonthCardRecharge:readyForReChargeLogReg(payParam)
    local mainCtrl = cc.load('MainCtrl'):getInstance()
    local SafeboxDeposit = mainCtrl._nSafeboxDeposit

    local JudgeNewPlayer = import("src.app.plugins.judgenewplayer.JudgeNewPlayer"):getInstance()
    local tag = (JudgeNewPlayer:isNewPlayer() == 1)
    local isNew = 0
    if tag then
        isNew = 1
    end

    local reqData = cc.exports.LogReChargeData
    reqData.nUserID             = payParam["Role_Id"]                   -- 即 nUserID
    reqData.nRechageType        = ReChargeType.RECHARGE_TYPE_MONTH_CARD -- 表示月卡
    reqData.nRechargePlace      = ReChargeScene.RECHARGE_SCENE_IN_HALL  -- 表示大厅
    reqData.nMoney              = payParam["Product_Price"]
    reqData.nSilverWhenRecharge = payParam["Role_Balance"]
    reqData.nSilverInSafeBox    = SafeboxDeposit
    reqData.nIsNewHand          = isNew
    reqData.nTimedBagType       = -1
end


return MonthCardRecharge

