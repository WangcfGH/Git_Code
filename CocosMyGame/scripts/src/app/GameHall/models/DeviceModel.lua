
--设备信息（各种硬件信息）

local DeviceModel=class('DeviceModel',import('src.app.GameHall.models.BaseModel'))

my.addInstance(DeviceModel)

function DeviceModel:onCreate()
    my.forbidKey(self, {"nReserved"})
	self:updateHardInfo()
end

local function GetUniqueHardID(deviceModel)

	local unique = nil
	unique = deviceModel.szHardID
	if( unique ~= nil ) then
		return unique
	end

	unique = deviceModel.szMachineID
	if( unique ~= nil ) then
		return unique
	end

	unique = deviceModel.szIMSI
	if( unique ~= nil ) then
		return unique
	end

	unique = deviceModel.szSimID
	if( unique ~= nil ) then
		return unique
	end

	local mod = require('src.app.GameHall.models.UserModel'):getInstance()
	unique = mod["szUniqueID"]

	return unique

end

function DeviceModel:updateHardInfo()

	local deviceUtils=DeviceUtils:getInstance()
	--	self.nHallNetDelay=465

	-- Simulator/Android/IOS
	local DeviceTypeList={
		iphone='IOS',
		android='Android',
		windows='Simulator',
	}
--	self.szDeviceType='Simulator'
	self.szDeviceType=DeviceTypeList[device.platform] or 'Unknown'
	self.szPhoneBrand=deviceUtils:getPhoneBrand()
	self.szPhoneModel=deviceUtils:getPhoneModel()
	self.nSysVersion=deviceUtils:getSystemVersion()
	self.szWifiID=deviceUtils:getMacAddress()
    	self.szWifiID=self.szWifiID..string.rep('0',31-self.szWifiID:len())
	self.szMacID=self.szWifiID
	self.szHardID=self.szWifiID--..string.rep('0',31-self.szWifiID:len())
	self.szVolumeID=deviceUtils:getSystemId()
	self.szSystemID=self.szVolumeID
	self.szImeiID=deviceUtils:getIMEI()
	self.szMachineID=self.szImeiID
	self.szIMSI=deviceUtils:getIMSI()
	self.szSimID=deviceUtils:getSimSerialNumber()
	--"50A4C8D1111600000000000000000000"
	--	self.szHardID='1824575232180000000000000000000'
	--	self.szVolumeID='2532bf3d25532298'
	--	self.szMachineID='252596444332288'
	--	self.szPhysAddr='182457523218'
	local MAX_PHYSADDR_LEN=16
	self.szPhysAddr=self.szWifiID:sub(1,MAX_PHYSADDR_LEN-1)
	--	self.dwScreenXY=31458134
	local nFrameWidth = cc.Director:getInstance():getOpenGLView():getFrameSize().width
	local nFrameHeight = cc.Director:getInstance():getOpenGLView():getFrameSize().height;
	local dwScreenXY=my.makeLong(nFrameWidth,nFrameHeight)
	self.dwScreenXY=dwScreenXY

	self.szHashPwd	=	''

	self.szHardID=GetUniqueHardID(self)
	self.szExeName = device.platform == "ios" and 'IPHONE' or 'AND'
end

return DeviceModel
