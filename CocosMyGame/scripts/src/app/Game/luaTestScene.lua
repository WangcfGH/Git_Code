
local LuaTestScene = class("LuaTest", cc.load("mvc").ViewBase)


require("src.app.GameHall.PublicInterface")
local PublicInterface                           = cc.exports.PUBLIC_INTERFACE

local labellatitude
local labellongitude
local labelprovinceName
local labelcityName
local labeltownShip
local labeldistrictName
local labelstreetName
local labelbuidingName
local labeluserid

local labelbatteryState
local labelbatteryLevel

local labelwifiState
local labelwifiLevel

local editbox
local editboxPhoneNum

function LuaTestScene:ctor(app, name)
    LuaTestScene.super.ctor(self, app, name)
end

function LuaTestScene:onCreate()
		local function touchEvent(sender,eventType)
		    if eventType == ccui.TouchEventType.ended then
		        PublicInterface.GoBackToMainScene()
		    end
		end
		local button = ccui.Button:create()
		button:setTouchEnabled(true)
		button:setTitleText("go back")
		button:setTitleFontSize(30)
		button:setPosition(cc.p(900, 700))
		button:addTouchEventListener(touchEvent)
		self:addChild(button)

        local lable = cc.Label:create()
        if lable then
            lable:setString("current user id")
            lable:setSystemFontSize(30)
            lable:setAnchorPoint(cc.p(0.5, 0))
            lable:setTextColor(cc.c4b(255, 255, 255, 255))
            lable:setPosition(cc.p(100, 630))
            self:addChild(lable)
        end

		editbox = ccui.EditBox:create(cc.size(200,34), "res/GameCocosStudio/safebox/frame/safebox_editframe.png")
		editbox:setPosition(cc.p(100, 600))
        editbox:setFontColor(cc.c4b(129, 129, 129,255))
        editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        editbox:setMaxLength(10)
        editbox:setText(157419)
        self:addChild(editbox)

        local lable = cc.Label:create()
        if lable then
            lable:setString("phone number")
            lable:setSystemFontSize(30)
            lable:setAnchorPoint(cc.p(0.5, 0))
            lable:setTextColor(cc.c4b(255, 255, 255, 255))
            lable:setPosition(cc.p(300, 630))
            self:addChild(lable)
        end

		editboxPhoneNum = ccui.EditBox:create(cc.size(200,34), "res/GameCocosStudio/safebox/frame/safebox_editframe.png")
		editboxPhoneNum:setPosition(cc.p(300, 600))
        editboxPhoneNum:setFontColor(cc.c4b(129, 129, 129,255))
        editboxPhoneNum:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        editboxPhoneNum:setMaxLength(13)
        editboxPhoneNum:setText(123456789)
        self:addChild(editboxPhoneNum)

        local lable = cc.Label:create()
        if lable then
            lable:setString("battery state")
            lable:setSystemFontSize(30)
            lable:setAnchorPoint(cc.p(0.5, 0))
            lable:setTextColor(cc.c4b(255, 255, 255, 255))
            lable:setPosition(cc.p(500, 630))
            self:addChild(lable)
        end

        labelbatteryState = cc.Label:create()
        if labelbatteryState then
            labelbatteryState:setString("nil")
            labelbatteryState:setSystemFontSize(30)
            labelbatteryState:setAnchorPoint(cc.p(0.5, 0))
            labelbatteryState:setTextColor(cc.c4b(255, 255, 255, 255))
            labelbatteryState:setPosition(cc.p(500, 600))
            self:addChild(labelbatteryState)
        end

        local lable = cc.Label:create()
        if lable then
            lable:setString("battery level")
            lable:setSystemFontSize(30)
            lable:setAnchorPoint(cc.p(0.5, 0))
            lable:setTextColor(cc.c4b(255, 255, 255, 255))
            lable:setPosition(cc.p(500, 570))
            self:addChild(lable)
        end

        labelbatteryLevel = cc.Label:create()
        if labelbatteryLevel then
            labelbatteryLevel:setString("nil")
            labelbatteryLevel:setSystemFontSize(30)
            labelbatteryLevel:setAnchorPoint(cc.p(0.5, 0))
            labelbatteryLevel:setTextColor(cc.c4b(255, 255, 255, 255))
            labelbatteryLevel:setPosition(cc.p(500, 540))
            self:addChild(labelbatteryLevel)
        end

        local lable = cc.Label:create()
        if lable then
            lable:setString("wifi state")
            lable:setSystemFontSize(30)
            lable:setAnchorPoint(cc.p(0.5, 0))
            lable:setTextColor(cc.c4b(255, 255, 255, 255))
            lable:setPosition(cc.p(700, 630))
            self:addChild(lable)
        end

        labelwifiState = cc.Label:create()
        if labelwifiState then
            labelwifiState:setString("nil")
            labelwifiState:setSystemFontSize(30)
            labelwifiState:setAnchorPoint(cc.p(0.5, 0))
            labelwifiState:setTextColor(cc.c4b(255, 255, 255, 255))
            labelwifiState:setPosition(cc.p(700, 600))
            self:addChild(labelwifiState)
        end

        local lable = cc.Label:create()
        if lable then
            lable:setString("wifi level")
            lable:setSystemFontSize(30)
            lable:setAnchorPoint(cc.p(0.5, 0))
            lable:setTextColor(cc.c4b(255, 255, 255, 255))
            lable:setPosition(cc.p(700, 570))
            self:addChild(lable)
        end

        labelwifiLevel = cc.Label:create()
        if labelwifiLevel then
            labelwifiLevel:setString("nil")
            labelwifiLevel:setSystemFontSize(30)
            labelwifiLevel:setAnchorPoint(cc.p(0.5, 0))
            labelwifiLevel:setTextColor(cc.c4b(255, 255, 255, 255))
            labelwifiLevel:setPosition(cc.p(700, 540))
            self:addChild(labelwifiLevel)
        end

		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("latitude")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
        lable1:setPosition(cc.p(500, 100))
        self:addChild(lable1)
    end
		labellatitude = cc.Label:create()
    if labellatitude then
        labellatitude:setString("nil")
        labellatitude:setSystemFontSize(30)
        labellatitude:setAnchorPoint(cc.p(0, 0))
        labellatitude:setTextColor(cc.c4b(255, 255, 255, 255))
				labellatitude:setPosition(cc.p(900, 100))
        self:addChild(labellatitude)
    end
		
		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("longitude")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				lable1:setPosition(cc.p(500, 150))
        self:addChild(lable1)
    end
		labellongitude = cc.Label:create()
    if labellongitude then
        labellongitude:setString("nil")
        labellongitude:setSystemFontSize(30)
        labellongitude:setAnchorPoint(cc.p(0, 0))
        labellongitude:setTextColor(cc.c4b(255, 255, 255, 255))
				labellongitude:setPosition(cc.p(900, 150))
        self:addChild(labellongitude)
    end
    
		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("provinceName")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				lable1:setPosition(cc.p(500, 200))
        self:addChild(lable1)
    end
		labelprovinceName = cc.Label:create()
    if labelprovinceName then
        labelprovinceName:setString("nil")
        labelprovinceName:setSystemFontSize(30)
        labelprovinceName:setAnchorPoint(cc.p(0, 0))
        labelprovinceName:setTextColor(cc.c4b(255, 255, 255, 255))
				labelprovinceName:setPosition(cc.p(900, 200))
        self:addChild(labelprovinceName)
    end
    
		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("cityName")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				lable1:setPosition(cc.p(500, 250))
        self:addChild(lable1)
    end
		labelcityName = cc.Label:create()
    if labelcityName then
        labelcityName:setString("nil")
        labelcityName:setSystemFontSize(30)
        labelcityName:setAnchorPoint(cc.p(0, 0))
        labelcityName:setTextColor(cc.c4b(255, 255, 255, 255))
				labelcityName:setPosition(cc.p(900, 250))
        self:addChild(labelcityName)
    end
    
		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("townShip")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				lable1:setPosition(cc.p(500, 300))
        self:addChild(lable1)
    end
		labeltownShip = cc.Label:create()
    if labeltownShip then
        labeltownShip:setString("nil")
        labeltownShip:setSystemFontSize(30)
        labeltownShip:setAnchorPoint(cc.p(0, 0))
        labeltownShip:setTextColor(cc.c4b(255, 255, 255, 255))
				labeltownShip:setPosition(cc.p(900, 300))
        self:addChild(labeltownShip)
    end
    
		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("districtName")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				lable1:setPosition(cc.p(500, 350))
        self:addChild(lable1)
    end
		labeldistrictName = cc.Label:create()
    if labeldistrictName then
        labeldistrictName:setString("nil")
        labeldistrictName:setSystemFontSize(30)
        labeldistrictName:setAnchorPoint(cc.p(0, 0))
        labeldistrictName:setTextColor(cc.c4b(255, 255, 255, 255))
				labeldistrictName:setPosition(cc.p(900, 350))
        self:addChild(labeldistrictName)
    end
    
		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("streetName")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				lable1:setPosition(cc.p(500, 400))
        self:addChild(lable1)
    end
		labelstreetName = cc.Label:create()
    if labelstreetName then
        labelstreetName:setString("nil")
        labelstreetName:setSystemFontSize(30)
        labelstreetName:setAnchorPoint(cc.p(0, 0))
        labelstreetName:setTextColor(cc.c4b(255, 255, 255, 255))
				labelstreetName:setPosition(cc.p(900, 400))
        self:addChild(labelstreetName)
    end
    
		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("buidingName")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				lable1:setPosition(cc.p(500, 450))
        self:addChild(lable1)
    end
		labelbuidingName = cc.Label:create()
    if labelbuidingName then
        labelbuidingName:setString("nil")
        labelbuidingName:setSystemFontSize(30)
        labelbuidingName:setAnchorPoint(cc.p(0, 0))
        labelbuidingName:setTextColor(cc.c4b(255, 255, 255, 255))
				labelbuidingName:setPosition(cc.p(900, 450))
        self:addChild(labelbuidingName)
    end
    
		local lable1 = cc.Label:create()
    if lable1 then
        lable1:setString("userid")
        lable1:setSystemFontSize(30)
        lable1:setAnchorPoint(cc.p(0, 0))
        lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				lable1:setPosition(cc.p(500, 500))
        self:addChild(lable1)
    end
		labeluserid = cc.Label:create()
    if labeluserid then
        labeluserid:setString("nil")
        labeluserid:setSystemFontSize(30)
        labeluserid:setAnchorPoint(cc.p(0, 0))
        labeluserid:setTextColor(cc.c4b(255, 255, 255, 255))
				labeluserid:setPosition(cc.p(900, 500))
        self:addChild(labeluserid)
    end
		
		local httptime = os.clock()
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr.timeout = 3000
    xhr:open("GET", "www.google.com")
    local function onReadyStateChange()
        local json = cc.load("json").json
        if( xhr.status == HTTP_REQUEST_SUCCESS)then
            print(111111111111111111111111)
        else
            print(os.clock(), httptime)
            print(os.clock() - httptime)
            print(xhr.status,2222222222222222222222222)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()

		
		
		local function touchEvent1(sender,eventType)
		    if eventType == ccui.TouchEventType.ended then
		   	 		local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
		       	
		       	
		       	local tcyLBSPlugin = plugin.AgentManager:getInstance():getLBSPlugin()
    if tcyLBSPlugin then
        tcyLBSPlugin:getSelfLBSInfo(userPlugin:getUserID(), 584, userPlugin:getAccessToken(), function(code, msg, userid, lbsInfo)
            printf("getSelfLBSInfo")
            printf("code = " .. code)
            printf("msg = " .. msg)
            printf("userid = " .. userid)
            
            labeluserid:setString(tostring(userid))

            if lbsInfo ~= nil then
                printf("latitude is " .. lbsInfo.latitude)
                printf("longitude is " .. lbsInfo.longitude)
                printf("provinceName is " .. lbsInfo.provinceName)
                printf("cityName is " .. lbsInfo.cityName)
                printf("townShip is " .. lbsInfo.townShip)
                printf("districtName is " .. lbsInfo.districtName)
                printf("streetName is " .. lbsInfo.streetName)
                printf("buidingName is " .. lbsInfo.buidingName)
                
                if lbsInfo.latitude ~= nil then labellatitude:setString(tostring(lbsInfo.latitude)) else labellatitude:setString("nil") end
                if lbsInfo.longitude ~= nil then labellongitude:setString(tostring(lbsInfo.longitude)) else labellongitude:setString("nil") end
                if #lbsInfo.provinceName > 0 then labelprovinceName:setString(lbsInfo.provinceName) else labelprovinceName:setString("nil") end
                if #lbsInfo.cityName > 0 then labelcityName:setString(lbsInfo.cityName) else labelcityName:setString("nil") end
                if #lbsInfo.townShip > 0 then labeltownShip:setString(lbsInfo.townShip) else labeltownShip:setString("nil") end
                if #lbsInfo.districtName > 0 then labeldistrictName:setString(lbsInfo.districtName) else labeldistrictName:setString("nil") end
                if #lbsInfo.streetName > 0 then labelstreetName:setString(lbsInfo.streetName) else labelstreetName:setString("nil") end
                if #lbsInfo.buidingName > 0 then labelbuidingName:setString(lbsInfo.buidingName) else labelbuidingName:setString("nil") end
            end
        end)
    else
        printf("tcyLBSPlugintcyLBSPlugintcyLBSPlugintcyLBSPlugintcyLBSPlugintcyLBSPlugin")
    end
		       	
		    end
		end
		local button1 = ccui.Button:create()
		button1:setTouchEnabled(true)
		button1:setTitleText("getSelfLBSInfo")
		button1:setTitleFontSize(30)
		button1:setPosition(cc.p(200, 100))
		button1:addTouchEventListener(touchEvent1)
		self:addChild(button1)
		
		local function touchEvent2(sender,eventType)
		    if eventType == ccui.TouchEventType.ended then
		   	 		local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
		       	
		       	
		       	local tcyLBSPlugin = plugin.AgentManager:getInstance():getLBSPlugin()
    if tcyLBSPlugin then
        tcyLBSPlugin:getLBSInfoByUserID(userPlugin:getUserID(), 584, userPlugin:getAccessToken(), tonumber(editbox:getText()), function(code, msg, userid, lbsInfo)
            printf("getLBSInfoByUserID")
            printf("code = " .. code)
            printf("msg = " .. msg)
            printf("userid = " .. userid)
            
            labeluserid:setString(tostring(userid))

            if lbsInfo ~= nil then
                printf("latitude is " .. lbsInfo.latitude)
                printf("longitude is " .. lbsInfo.longitude)
                printf("provinceName is " .. lbsInfo.provinceName)
                printf("cityName is " .. lbsInfo.cityName)
                printf("townShip is " .. lbsInfo.townShip)
                printf("districtName is " .. lbsInfo.districtName)
                printf("streetName is " .. lbsInfo.streetName)
                printf("buidingName is " .. lbsInfo.buidingName)
                
                if lbsInfo.latitude ~= nil then labellatitude:setString(tostring(lbsInfo.latitude)) else labellatitude:setString("nil") end
                if lbsInfo.longitude ~= nil then labellongitude:setString(tostring(lbsInfo.longitude)) else labellongitude:setString("nil") end
                if #lbsInfo.provinceName > 0 then labelprovinceName:setString(lbsInfo.provinceName) else labelprovinceName:setString("nil") end
                if #lbsInfo.cityName > 0 then labelcityName:setString(lbsInfo.cityName) else labelcityName:setString("nil") end
                if #lbsInfo.townShip > 0 then labeltownShip:setString(lbsInfo.townShip) else labeltownShip:setString("nil") end
                if #lbsInfo.districtName > 0 then labeldistrictName:setString(lbsInfo.districtName) else labeldistrictName:setString("nil") end
                if #lbsInfo.streetName > 0 then labelstreetName:setString(lbsInfo.streetName) else labelstreetName:setString("nil") end
                if #lbsInfo.buidingName > 0 then labelbuidingName:setString(lbsInfo.buidingName) else labelbuidingName:setString("nil") end
                
            end
        end)
    else
        printf("tcyLBSPlugintcyLBSPlugintcyLBSPlugintcyLBSPlugintcyLBSPlugintcyLBSPlugin")
    end
		       	
		    end
		end
		local button2 = ccui.Button:create()
		button2:setTouchEnabled(true)
		button2:setTitleText("getLBSInfoByUserID")
		button2:setTitleFontSize(30)
		button2:setPosition(cc.p(200, 300))
		button2:addTouchEventListener(touchEvent2)
		self:addChild(button2)


        
		
		local function touchEvent3(sender,eventType)
		    if eventType == ccui.TouchEventType.ended then
                local lable1 = cc.Label:create()
                if lable1 then
                    lable1:setString(BusinessUtils:getInstance():getCloakroomDirectory())
                    lable1:setSystemFontSize(20)
                    lable1:setAnchorPoint(cc.p(0, 0))
                    lable1:setTextColor(cc.c4b(255, 255, 255, 255))
				    lable1:setPosition(cc.p(30, 550))
                    self:addChild(lable1)
                end
		    end
		end
		local button3 = ccui.Button:create()
		button3:setTouchEnabled(true)
		button3:setTitleText("getCloakroomDir")
		button3:setTitleFontSize(30)
		button3:setPosition(cc.p(200, 400))
		button3:addTouchEventListener(touchEvent3)
		self:addChild(button3)


        local function touchEvent4(sender,eventType)
		    if eventType == ccui.TouchEventType.ended then
                DeviceUtils:getInstance():dialPhone(editboxPhoneNum:getText())
		    end
		end
		local button4 = ccui.Button:create()
		button4:setTouchEnabled(true)
		button4:setTitleText("DialPhone")
		button4:setTitleFontSize(30)
		button4:setPosition(cc.p(200, 500))
		button4:addTouchEventListener(touchEvent4)
		self:addChild(button4)

        local batteryinfo = DeviceUtils:getInstance():getGameBatteryInfo()
        if batteryinfo then
            local stateText = "unknown"
            local stateTable = {
                [cc.exports.BatteryState.kBatteryStateUnknown] = function()
                    stateText = "unknown"
                end,
                [cc.exports.BatteryState.kBatteryStateCharging] = function()
                    stateText = "charging"
                end,
                [cc.exports.BatteryState.kBatteryStateDisCharging] = function()
                    stateText = "discharging"
                end,
                [cc.exports.BatteryState.kBatteryStateNotCharging] = function()
                    stateText = "not charging"
                end,
                [cc.exports.BatteryState.kBatteryStateFull] = function()
                    stateText = "full"
                end,
            }
            if stateTable[batteryinfo.batteryState] then
                stateTable[batteryinfo.batteryState]()
            end
            if labelbatteryState ~= nil then
                labelbatteryState:setString(stateText)
            end
            if labelbatteryLevel ~= nil then
                labelbatteryLevel:setString(tostring(batteryinfo.batteryLevel))
            end
        else
            printf("batteryInfo is nil")
        end
        DeviceUtils:getInstance():setGameBatteryInfoCallback(function(batteryInfo)
            if batteryInfo ~= nil then
                printf("batteryState is " .. batteryInfo.batteryState)
                printf("batteryLevel is " .. batteryInfo.batteryLevel)

                local stateText = "unknown"
                local stateTable = {
                    [cc.exports.BatteryState.kBatteryStateUnknown] = function()
                        stateText = "unknown"
                    end,
                    [cc.exports.BatteryState.kBatteryStateCharging] = function()
                        stateText = "charging"
                    end,
                    [cc.exports.BatteryState.kBatteryStateDisCharging] = function()
                        stateText = "discharging"
                    end,
                    [cc.exports.BatteryState.kBatteryStateNotCharging] = function()
                        stateText = "not charging"
                    end,
                    [cc.exports.BatteryState.kBatteryStateFull] = function()
                        stateText = "full"
                    end,
                }
                if stateTable[batteryInfo.batteryState] then
                    stateTable[batteryInfo.batteryState]()
                end
                if labelbatteryState ~= nil then
                    labelbatteryState:setString(stateText)
                end
                if labelbatteryLevel ~= nil then
                    labelbatteryLevel:setString(tostring(batteryInfo.batteryLevel))
                end
            else
                printf("batteryInfo is nil")
            end
        end)

        local wifiinfo = DeviceUtils:getInstance():getGameWifiInfo()
        if wifiinfo then
            local stateText = "unknown"
            local stateTable = {
                [cc.exports.WifiState.kWifiStateDisabling] = function()
                    stateText = "disabling"
                end,
                [cc.exports.WifiState.kWifiStateDisabled] = function()
                    stateText = "diabled"
                end,
                [cc.exports.WifiState.kWifiStateEnabling] = function()
                    stateText = "enabling"
                end,
                [cc.exports.WifiState.kWifiStateEnabled] = function()
                    stateText = "enabled"
                end,
                [cc.exports.WifiState.kWifiStateUnkonwn] = function()
                    stateText = "unknown"
                end,
            }
            if stateTable[wifiinfo.wifiState] then
                stateTable[wifiinfo.wifiState]()
            end
            if labelwifiState ~= nil then
                labelwifiState:setString(stateText)
            end
            if labelwifiLevel ~= nil then
                labelwifiLevel:setString(tostring(wifiinfo.wifiLevel))
            end
        else
            printf("wifiInfo is nil")
        end
        DeviceUtils:getInstance():setGameWifiInfoCallback(function(wifiInfo)
            if wifiInfo ~= nil then
                printf("wifiState is " .. wifiInfo.wifiState)
                printf("wifiLevel is " .. wifiInfo.wifiLevel)

                local stateText = "unknown"
                local stateTable = {
                    [cc.exports.WifiState.kWifiStateDisabling] = function()
                        stateText = "disabling"
                    end,
                    [cc.exports.WifiState.kWifiStateDisabled] = function()
                        stateText = "diabled"
                    end,
                    [cc.exports.WifiState.kWifiStateEnabling] = function()
                        stateText = "enabling"
                    end,
                    [cc.exports.WifiState.kWifiStateEnabled] = function()
                        stateText = "enabled"
                    end,
                    [cc.exports.WifiState.kWifiStateUnkonwn] = function()
                        stateText = "unknown"
                    end,
                }
                if stateTable[wifiInfo.wifiState] then
                    stateTable[wifiInfo.wifiState]()
                end
                if labelwifiState ~= nil then
                    labelwifiState:setString(stateText)
                end
                if labelwifiLevel ~= nil then
                    labelwifiLevel:setString(tostring(wifiInfo.wifiLevel))
                end
            else
                printf("wifiInfo is nil")
            end
        end)
end

function LuaTestScene:onExit()
    DeviceUtils:getInstance():setGameBatteryInfoCallback(nil)
    DeviceUtils:getInstance():setGameWifiInfoCallback(nil)

    labelbatteryState   = nil
    labelbatteryLevel   = nil
    labelwifiState      = nil
    labelwifiLevel      = nil
end

return LuaTestScene
