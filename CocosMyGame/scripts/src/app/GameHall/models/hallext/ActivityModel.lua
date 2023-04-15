
--活动模型基类
local DeviceModel=require('src.app.GameHall.models.DeviceModel')
local ExtendProtocol=require('src.app.GameHall.models.hallext.ExtendProtocol')
local ActivityModel=class('ActivityModel',ExtendProtocol)

function ActivityModel:onCreate()
	ActivityModel.super.onCreate(self)
end

function ActivityModel:getDeviceId()
	return DeviceModel:getDeviceId()
end

return ActivityModel
