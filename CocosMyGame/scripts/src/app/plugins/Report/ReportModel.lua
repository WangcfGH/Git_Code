local ReportModel = class("ReportModel", require('src.app.GameHall.models.BaseModel'))

function ReportModel:onCreate()
    --是否是结算的举报界面 
    self.ReportResultType = false
    --举报功能是否打开
    self.oneswitch = false
    self.twoswitch = false
    self.open = false
    --举报对象目前的对象(那个人哪里按的按钮，就选谁)
    self.newObject = 0
    --举报对象的表
    self.ReportNameList = {}
    self.url = nil
    self.roomid = nil
    --获取jscon消息，打开第一开关
    if cc.exports.isReportSupported() then
        self.oneswitch = true
    else
        self.oneswitch = false
    end

    --获取房间列表
    self.RoomConfig = cc.exports.getReportRoomConfig()
    --获取目前的房间号,判断是否在房间列表中
    self:updateRoominfo()

    if self.oneswitch == true and self.twoswitch == true then
        self.open = true
    end

    self.url =  self.getReportUrl()
end

--[[
举报功能的url的接口
"1507:http://workorder.tcy365.org:1507/api/report/submitorder",
"1505:http://workorder.tcy365.org:1505/api/report/submitorder",
"80:http://workorder.tcy365.com/api/report/submitorder"
]]

function ReportModel:getReportUrl()
    if DEBUG > 0 then
        return "http://workorder.tcy365.org:1505/api/report/submitorder"
    end

    return "https://workorder.tcy365.com/api/report/submitorder"
end

function ReportModel:selectRoomList(Config,id)
    if not Config or type(Config) ~= "table" then
        return false
    end
    for K, v in pairs(Config) do
        if(K == id) then
            if(v == 1) then
                return true
            else
                return false 
            end
        end
    end
    return false
end

function ReportModel:updateRoominfo()

    local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    self.roomid = tostring(roomInfo.nRoomID)

    if(self:selectRoomList(self.RoomConfig,self.roomid) == true) then
        self.twoswitch = true
    else
        self.twoswitch = false
    end

    if self.oneswitch and self.twoswitch then
        self.open = true
    else
        self.open = false
    end

end

function ReportModel:clearReportNameList()
    self.ReportNameList = {}
end

-- local UserModel = mymodel('UserModel'):getInstance()
-- UserModel.nUserID

function ReportModel:SetReportResultSwoitch(result)
    self.ReportResultType = result
end

function ReportModel:GetReportResultSwoitch()
    return self.ReportResultType 
end


return ReportModel
