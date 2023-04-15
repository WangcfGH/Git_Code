--[[
    地理信息模块
    获取客户端的详细地理信息
]]

local LbsModel  = class('LbsModel', require('src.app.GameHall.models.hallext.ExtendProtocol'))

function LbsModel:onCreate()
    self._lbsInfo = {}
    self:refreshLbsInfo()
end

function LbsModel:refreshLbsInfo()
    local agentManager = plugin.AgentManager:getInstance()
    local lbsPlugin, userPlugin = agentManager:getLBSPlugin(), agentManager:getUserPlugin()
    if not lbsPlugin then
        printLog(self.__cname, 'lbs is not support')
        return
    end
    
    if type(lbsPlugin.isSystemLocationServiceOpen) == 'function' and not lbsPlugin:isSystemLocationServiceOpen()  then
       print("没有开启定位服务")
       self:ptintLbsErrorInfo("refreshLbsInfo:Do not start lbs server")
    end

    if type(lbsPlugin.isApplicationLocationPermissionGranted) == 'function' and not lbsPlugin:isApplicationLocationPermissionGranted() then
        print("没有定位权限")         
        self:ptintLbsErrorInfo("refreshLbsInfo:Do not have lbs power")  
    end

    lbsPlugin:getSelfLBSInfo(
        userPlugin:getUserID(),
        my.getGameID(),
        userPlugin:getAccessToken(),
        function(code, msg, id, lbsInfo)
            if LBSActionResultCode.kLBSGetLBSInfoSuccess == code and lbsInfo then
                self._lbsInfo = lbsInfo  
				dump(lbsInfo)				
                if lbsInfo.cityName == "" then
                    local errMsg = "getSelfLBSInfo error  "
                    for k,v in pairs(lbsInfo) do
                        errMsg = errMsg..k..":"..v.." ,"
                    end  
                    print(errMsg)
                    self:ptintLbsErrorInfo(errMsg)
                end        
            else
                local errMsg = "getSelfLBSInfo failed"..'code: ' .. code .. ' msg: ' .. msg
                print(errMsg)
                self:ptintLbsErrorInfo(errMsg)
            end
        end
    )
end

function LbsModel:ptintLbsErrorInfo(errStr)
    my.scheduleOnce(function ()
        my.dataLink(cc.exports.DataLinkCodeDef.PTINT_LBS_ERROR_INFO, {errorInfo = errStr})
    end,1)
    
end

function LbsModel:getLbsInfo()
    return self._lbsInfo
end

function LbsModel:getLbsAreaString()
    local stringLbsArea = ''
    local lbsInfo = self._lbsInfo
    if lbsInfo then
        if lbsInfo.cityName then
            stringLbsArea = string.format(stringLbsArea..lbsInfo.cityName)
        end
        if lbsInfo.townShip then
            stringLbsArea = string.format(stringLbsArea..lbsInfo.townShip)
        end
        if lbsInfo.districtName then
            stringLbsArea = string.format(stringLbsArea..lbsInfo.districtName)
        end
        if lbsInfo.streetName then
            stringLbsArea = string.format(stringLbsArea..lbsInfo.streetName)
        end
        if lbsInfo.buildingName then 
            stringLbsArea = string.format(stringLbsArea..lbsInfo.buildingName)
        end
    end
    return stringLbsArea
end

function LbsModel:getLbsStr()
    local lbsInfo = self._lbsInfo
    local stringLbs
    if lbsInfo and lbsInfo.latitude and lbsInfo.longitude then
        stringLbs = string.format(lbsInfo.latitude..","..lbsInfo.longitude)
    else
        stringLbs = string.format("0,0")
    end
    return stringLbs
end

function LbsModel:getDistanceByLbs(selfLbs, otherLbs)
    local lbsString = ""
    local distance  = 0

    local tcyFriendPlugin = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()
    local selfLbsTable = string.split(selfLbs, ",")
    local otherLbsTable = string.split(otherLbs, ",")
    if tcyFriendPlugin then
        distance = tcyFriendPlugin:getDistance(selfLbsTable[1], selfLbsTable[2], otherLbsTable[1], otherLbsTable[2])
    end

    if distance and type(distance) == "number" then
        local dis_km = math.ceil(distance / 1000 - 0.5)
        if dis_km >= 1 then
            lbsString = tostring(dis_km).."千米"
        else
            lbsString = string.format("%.2f", distance).."米"
        end
    end

    return lbsString
end

return LbsModel