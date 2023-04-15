local PayModel = class("PayModel")


function PayModel:ctor()
    self._productToBuy    = nil 
    self._iapPlugin       = plugin.AgentManager:getInstance():getIAPPlugin() 
    self._itemInfo        = cc.exports.GetShopItemsInfo()
    --self._shopConfig      = cc.exports.GetShopConfig()
    self._user            = mymodel("UserModel"):getInstance() 
    self._playerModel     = mymodel('hallext.PlayerModel'):getInstance()
    self._playerModel:addEventListener(self._playerModel.PLAYER_LOGIN_SUCCEEDED, handler(self,self.onPlayerLogined))
    --self._iapPlugin:setCallback(handler(self,self.payCallback))
end

function PayModel:getInstance()
    PayModel._instance = PayModel._instance or PayModel:create()
    return PayModel._instance
end

function PayModel:payCallback(code, msg)
    if self._callback then
        printLog("paymodel", "payCallback")
        self._callback(code, msg)
	end
end

--shopCallback是shopModel初始化时设置的回调，每次都会得到通知；callback是支付的时候传入的回调，会被下一次支付设置的回调所覆盖
function PayModel:setCallback(shopCallback, callback)
    assert(type(shopCallback) == "function", "please set a function as callback")
    self._shopCallback   = shopCallback
    self._callback       = callback
    self._iapPlugin:setCallback(function(code, msg)
        printLog("paymodel","setCallback")
        self:payCallback(code, msg)
        self._shopCallback(code, msg)
    end)
end

function PayModel:onPlayerLogined(event)
    self:getPayMetaTable()
end

function PayModel:getPayMetaTable()
    self._payMetaTable = self._payMetaTable or {}
    if #self._payMetaTable == 0 then
        self._payMetaTable["App_name"]       = my.getGameShortName().."_an"
        self._payMetaTable["EXT"]            = ""
        self._payMetaTable["Game_Id"]        = tostring(my.getGameID())
        self._payMetaTable["Server_Id"]      = tostring( 1 )
        
        local gameModel = require("src/app/GameHall/models/GameModel"):getInstance()
        self._payMetaTable["Channel_Id"]     = tostring( gameModel.szChannelID )
        self._payMetaTable["Client_Id"]      = tostring( gameModel.clientID )
        
        local deviceModel = require("src/app/GameHall/models/DeviceModel"):getInstance()
        self._payMetaTable["WifiID"]         = tostring( deviceModel.szWifiID )
        self._payMetaTable["Imei"]           = tostring( deviceModel.szImeiID )
        self._payMetaTable["SystemId"]       = tostring( deviceModel.szSystemID )
        
        self._payMetaTable["Role_Id"]        = tostring( self._user["nUserID"] )
        self._payMetaTable["Role_Grade"]     = tostring( self._user["nExperience"] )
        self._payMetaTable["Role_Balance"]   = tostring( self._user["nDeposit"] )
        self._payMetaTable["Role_Token"]     = tostring( self._user["szPassword"] )
        self._payMetaTable["Role_Name"]      = MCCharset:getInstance():gb2Utf8String(self._user["szUsername"],string.len(self._user["szUsername"]) )
        return self._payMetaTable    
    elseif self._payMetaTable.Role_Id ~= self._user.nUserID then 
        self._payMetaTable["Role_Id"]        = tostring( self._user["nUserID"] )
        self._payMetaTable["Role_Grade"]     = tostring( self._user["nExperience"] )
        self._payMetaTable["Role_Balance"]   = tostring( self._user["nDeposit"] )
        self._payMetaTable["Role_Token"]     = tostring( self._user["szPassword"] )
        self._payMetaTable["Role_Name"]      = MCCharset:getInstance():gb2Utf8String(self._user["szUsername"],string.len(self._user["szUsername"]) )

        return self._payMetaTable
    else
        return self._payMetaTable
    end
end

function PayModel:payForProduct(product, callback, extraParams, totalSilver)
    if not product then
         local config = cc.exports.GetShopTipsConfig()
         if config and config["PRODUCT_OVER"] then
             my.informPluginByName({pluginName='TipPlugin',params={tipString=config["PRODUCT_OVER"],removeTime=1}})
         end
         return
    end

    printf("payforproduct 11111")
    dump(product)

    local param = clone(self:getPayMetaTable())
    --setmetatable(param, self:getPayMetaTable())
    if product["First_Support"] == 1 then
        param["Product_Name"]   = product["fristpay_productname"]
	    param["Product_Count"]  = tostring(product["productnum"] + product["firstpay_rewardnum"]) 
    else
        param["Product_Name"]   = product["productname"]
	    param["Product_Count"]  = tostring(product["productnum"])
    end

    --[[if product["firstpoint"] then
	    param["pay_point_num"]  = tostring(product["firstpoint"])
    else
        param["pay_point_num"]  = 0
    end]]--
    param["pay_point_num"]  = 0

    param["Product_Id"]         = tostring(product["productid"])
    param["Product_Price"]      = tostring(product["price"])
    param["Exchange_Id"]        = tostring(product["producttype"])
    param["through_data"]       = product["through_data"]
    param["ext_args"]           = cc.exports.getPayExtArgs(product)

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
    param["Game_Id"]= my.getGameID()
    param["EXT"]=""
    --local constStrings=cc.load('json').loader.loadFile('KickedOff.json')
    local short = cc.exports.PUBLIC_INTERFACE.GetGameShortName().."_an"
    param["App_name"]=short

    local m = require("src/app/GameHall/models/DeviceModel"):getInstance()
    param["WifiID"]= tostring( m.szWifiID )
    param["Imei"]= tostring( m.szImeiID )
    param["SystemId"] = tostring( m.szSystemID )


    if type(extraParams) == "table" then
    	for k,v in pairs(extraParams) do 
    	    param[k] = v
    	end
    end

    dump(param)
    self:setCallback(self._shopCallback, callback)
    cc.exports.SaveLastBuyItem(product.price, product.producttype, param["Product_Count"], product["First_Support"])

    --[[if cc.exports.isQuickPaySupported() then
        if cc.exports.isDepositSupported() then
            if product.producttype == 1 then
                cc.exports.SaveQuickBuyItem(product.id)
            end
        elseif cc.exports.isScoreSupported() then
            if product.producttype == 3 then
                cc.exports.SaveQuickBuyItem(product.id)
            end
        end
    end]]--

    --KPI start
    --充值接口透传 RecomGameId RecomGameCode RecomGameVers
    local kpiData = my.getKPIClientData()
    param["RecomGameId"]   = tostring(kpiData.RecomGameId)
    param["RecomGameCode"] = kpiData.RecomGameCode
    param["RecomGameVers"] = ""
    --KPI end

    local payInfo = mymodel("PayInfoModel"):getInstance()
    local infoTab = {}
    infoTab.buyID = tonumber(product.exchangeid)
    infoTab.giveNum = 0
    infoTab.buyNum = tonumber(product.productnum)
    if totalSilver then
        infoTab.giveNum = totalSilver - infoTab.buyNum
    end
    
    if(product["First_Support"] == 1)then
        infoTab.giveNum = tonumber(product.firstpay_rewardnum)
    end

    if product.producttypeex == "deposit" then
        infoTab.buyType = PayInfoType.PAY_INFO_TYPE_SILVER
        payInfo:setInfo(infoTab)
    elseif product.producttypeex == "prop" then
        infoTab.buyType = PayInfoType.PAY_INFO_TYPE_CARD_MAKER
        payInfo:setInfo(infoTab)
    elseif product.producttypeex == "prop_timinggame_ticket_rmb" or product.producttypeex == "prop_timinggame_ticket_rmb_first" then
        infoTab.buyType = PayInfoType.PAY_INFO_TYPE_TIMING_TICKET
        payInfo:setInfo(infoTab)
    end

    printf('pay param')
    dump(param)
    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
    else
        self._iapPlugin:payForProduct(param)
    end
end

function PayModel:quickCharge(destinyItem, callback, extraParams)
	if not (self._itemInfo and #self._itemInfo ~= 0) then
			printLog("quickCharge", "no shopItem")
	end
	local lastItemkey  = cc.exports.GetQuickBuyItem()
	local lastItem, smallestItem
	local function getItem()
		for _, item in pairs(self._itemInfo) do
            if item and cc.exports.isIDinTabs(item.id) then
                local pCanin = false
                if cc.exports.isDepositSupported() then
                    if item["producttype"] == 1 then
                        pCanin = true
                    end
                elseif cc.exports.isScoreSupported() then
                    if item["producttype"] == 3 then
                        pCanin = true
                    end
                end
                if pCanin then
		    if destinyItem then
		                if item.id == destinyItem.id then 
		            return item
		        end
		    end
		    if lastItemkey then
		                if item.id == lastItemkey.id then
                            if cc.exports.isDepositSupported() then
                                if item["producttype"] == 1 then
		            lastItem = item
		        end
                            elseif cc.exports.isScoreSupported() then
                                if item["producttype"] == 3 then
                                    if item["limit"] then
                                        if not cc.exports.isScoreLimit(item["limit"]) then
                                            lastItem = item
		    end
                                    end
                                end
                            end
		                end
		            end
		    smallestItem = smallestItem or item
		            if smallestItem.price > item.price then
		        smallestItem = item
		    end
                end
                if smallestItem and smallestItem["producttype"] == 3 then
                    if smallestItem["limit"] then
                        if cc.exports.isScoreLimit(smallestItem["limit"]) then
                            smallestItem = nil
                        end
                    end
                end
            end
		end
		return lastItem or smallestItem
	end
	local pTempItem = getItem()
    local pShopItem = pTempItem
    if pTempItem and pTempItem["id"] then
        pShopItem = mymodel("ShopModel"):getInstance():GetItemByID(pTempItem["id"])
    end
	self:payForProduct(pShopItem, callback, extraParams)
end

function PayModel:quickChargeForSmallGame(destinyItem, callback, extraParams)
	if not (self._itemInfo and #self._itemInfo ~= 0) then
			printLog("quickCharge", "no shopItem")
	end
	local lastItemkey  = cc.exports.GetQuickBuyItem()
	local lastItem, smallestItem
	local function getItem()
		for _, item in pairs(self._itemInfo) do
            if item and cc.exports.isIDinTabs(item.id) then
                local pCanin = false
                if cc.exports.isDepositSupported() then
                    if item["producttype"] == 1 then
                        pCanin = true
                    end
                elseif cc.exports.isScoreSupported() then
                    if item["producttype"] == 3 then
                        pCanin = true
                    end
                end
                if pCanin then
                    if destinyItem then
                        if item.price == destinyItem.Product_Price and item.producttype == destinyItem.Product_Type then 
                            return item
                        end
                    end
		    if lastItemkey then
		                if item.id == lastItemkey.id then
                            if cc.exports.isDepositSupported() then
                                if item["producttype"] == 1 then
		            lastItem = item
		        end
                            elseif cc.exports.isScoreSupported() then
                                if item["producttype"] == 3 then
                                    if item["limit"] then
                                        if not cc.exports.isScoreLimit(item["limit"]) then
                                            lastItem = item
		    end
                                    end
                                end
                            end
		                end
		            end
		    smallestItem = smallestItem or item
		            if smallestItem.price > item.price then
		        smallestItem = item
		    end
                end
                if smallestItem and smallestItem["producttype"] == 3 then
                    if smallestItem["limit"] then
                        if cc.exports.isScoreLimit(smallestItem["limit"]) then
                            smallestItem = nil
                        end
                    end
                end
            end
		end
		return lastItem or smallestItem
	end
	local pTempItem = getItem()
    local pShopItem = pTempItem
    if pTempItem and pTempItem["id"] then
        pShopItem = mymodel("ShopModel"):getInstance():GetItemByID(pTempItem["id"])
    end
	self:payForProduct(pShopItem, callback, extraParams)
end
function PayModel:isPropertySolutionAquired(floor, ceil)
    if floor > ceil then 
		print("failed obtainPropertySolutions, since ceil > floor")
		return false
	end
	local boxDeposit  = 0
	if 	   uiConfig.depositBox == "safebox" then
			boxDeposit = self._user.nSafeboxDeposit
	elseif uiConfig.depositBox == "backbox" then
			boxDeposit = self._user.nBackDeposit
	end
	local overFlow = self._user["nDeposit"] - ceil
	local less 	   = self._user["nDeposit"] - floor
	local depositGap = 0
	if 	overFlow > 0 and less > 0 then depositGap = overFlow
	elseif overFlow < 0 and less < 0 then depositGap = less
	else
		return false
	end
    return true, depositGap, boxDeposit
end

function PayModel:obtainPropertySolutions(floor, ceil, callback)
	local isPropertySolutionRequired, depositGap, boxDeposit = self:isPropertySolutionAquired(floor, ceil)
    if not isPropertySolutionRequired then 
        return false
    end 
	if depositGap 	  > 0 then
			self:activateDepositBox(depositGap, callback)
	elseif depositGap < 0 then
		if depositGap + boxDeposit < 0 then
				self:activateIapPlugin(depositGap + boxDeposit, callback)
		else
			if self._shopConfig["Trans_type"]     == 0 then --to safebox
				self:activateDepositBox(depositGap, callback)
			elseif self._shopConfig["Trans_type"] == 2 then --to game
				if self._shopConfig["ActivateIAPPluginOrDepositBox"] == "pay" then
					self:activateIapPlugin(depositGap, callback)
				else
					self:activateDepositBox(depositGap, callback)
				end
			end
		end
	end
	return true
end

function PayModel:obtainPropertySolutionsEnterRoom()
	--[[local areaList = cc.exports.RoomModelList
	local lastEnterRoomID = cc.exports.LastEnterRoomID
	print("lastEnterRoomID"..lastEnterRoomID)
	if not lastEnterRoomID then return end
	for areaCount,area in ipairs(areaList) do
		for roomCount,room in ipairs(area.RoomList) do
			if room.id == lastEnterRoomID then
				print("min:"..room.min.." max:"..room.max)
				self._roomInfo = room
				local function enterRoom()
                    printLog("enterRoom","called")               
	                local isPropertySolutionRequired, depositGap, boxDeposit = self:isPropertySolutionAquired(room.min, room.max)
                    if (not isPropertySolutionRequired) or (depositGap + boxDeposit >= 0) then 
                        PUBLIC_INTERFACE.GetEnterGameInfo():EnterRoom(area.id, room.id, room)
                        return true
                    else
                        return false
                    end
				end
                local function asynEnterRoom()
                    if not enterRoom() then 
                        my.scheduleOnce(enterRoom,3)
                    end
                end
				local isSolutionOfferred = self:obtainPropertySolutions(room.min, room.max, asynEnterRoom)
                return isSolutionOfferred
			end
		end
	end]]--
end

function PayModel:activateDepositBox(depositGap, callback)
    print("activateDepositBox, depositGap"..depositGap)
    my.informPluginByName({pluginName='SafeboxCtrl',params={depositGap = depositGap, callback = callback}})
end

function PayModel:activateIapPlugin(depositGap, callback)
    print("activateIapPlugin, depositGap:"..depositGap)
    local destinyItem = {}
    for i, product in pairs(self._itemInfo) do
        if product["First_Support"]     == 0 and depositGap + product["Product_Count"] > 0 then
            destinyItem["Product_Price"] = product["Product_Price"]
            destinyItem["Product_Type"]  = product["Product_Type"]
            break 
        elseif product["First_Support"] == 1 and depositGap + product["Product_Count"] + product["First_Reward"] > 0 then
            destinyItem["Product_Price"] = product["Product_Price"]
            destinyItem["Product_Type"]  = product["Product_Type"]
            break
        end
    end
    local extraParams = {}
    extraParams["Pay_Title"]    = self._shopConfig["RechargeNeeded_Title"]
    extraParams["Pay_Content"]  = self._shopConfig["RechargeNeeded_Content"]
    self:quickCharge(destinyItem, callback, extraParams)
end

cc.exports.payModel = {
    --[[the interface to buy product，use payForProduct as follow:
    local itemList = cc.exports.GetPayItemsInfo()
    payModel.payForProduct(itemList[1]),

    "callback", "extraParams" are Optional Arguments, 
    callback will be called when payAction finished(bought or cancelled),
    "extraparams" is for special product with extra params]]
    payForProduct                    = function(product, callback, extraParams)
		return PayModel:getInstance():payForProduct(product, callback, extraParams)
    end,
    --[[quickCharge will choose product automatically, use quickCharge as follow:
    local destinyItem = {
        Product_Type  = 1,
        Product_Price = 2,
    }
    payModel.quickCharge(destinyItem, callback)

    and it comes in order of:destinyItem > lastBoughtItem > smallestItem
    destinyItem, callback are optioanl]]
    quickCharge                    = function(destinyItem, callback)
        return PayModel:getInstance():quickCharge(destinyItem, callback)
    end,
    --[[obtainPropertySolutions offers propertySolution, use as follow:
    payModel.obtainPropertySolutions(10, 10000, callback)

    callback is optional, solutions include safebox and pay, please input the deposit range you want,
    if safebox is activated then 
    	callback will be called when safebox clicked.
    elseif iappay is activated then 
    	callback will be called when payAction finished.]]
    obtainPropertySolutions          = function(floor, ceil, callback)
        return PayModel:getInstance():obtainPropertySolutions(floor, ceil, callback)
    end,
    --[[offer propertySolutions for enterRoom, use as follow:
    payModel.obtainPropertySolutionsEnterRoom()

    based on the last room clicked, offer propertySolution, will enterRoom, when condition satisfies]]
    obtainPropertySolutionsEnterRoom = function()
        return PayModel:getInstance():obtainPropertySolutionsEnterRoom()
    end,
      
    --[[activateDepositBox by the depositGap, use as follow:
    payModel.activateDepositBox(-1,callback)
    
    callback is optional, and will be callback when deposit transferred, depositGap can be either positive or negative]]
    activateDepositBox               = function(depositGap, callback)
        return PayModel:getInstance():activateDepositBox(depositGap, callback)
    end,
    --[[activateIapPlugin by the depositGap, use as follow:
    payModel.activateIapPlugin(1, callback)

    callback is optioanl, will find the product higher and closest to the input value]]
    activateIapPlugin                = function(depositGap, callback)
        return PayModel:getInstance():activateIapPlugin(depositGap, callback)
    end,
    quickChargeForSmallGame            = function(destinyItem, callback)
        return PayModel:getInstance():quickChargeForSmallGame(destinyItem, callback)
    end,
}
       
return PayModel