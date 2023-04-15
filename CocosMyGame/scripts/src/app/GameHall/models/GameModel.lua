
--ÓÎÏ·Ä£ÐÍ£¨Çø¡¢·¿¼äÁÐ±íµÈ£©

local GameModel=class('GameModel')

my.addInstance(GameModel)

function GameModel:ctor()
    my.forbidKey(self, {"nReserved"})
	local hallverString = "2.1.20130822"
	assert(hallverString,'')
	local verinfos=string.split(hallverString,'.')
	local nMajorVer=tonumber(verinfos[1])
	local nMinorVer=tonumber(verinfos[2])
    self.nMajorVer = nMajorVer
    self.nMinorVer = nMinorVer
    self.nBuildNO = verinfos[3]

	self.dwGameVer=my.makeLong(nMinorVer,nMajorVer)

	local GROUP_TYPE_DEFAULT=1
	self.nGroupType=GROUP_TYPE_DEFAULT

	self.nHallBuildNO	=	toint(verinfos[3])

	local agentId
	local utils = HslUtils:create(abstract)
	agentId = utils:getHallSvrAgentGroup()
	self.nAgentGroupID=agentId
    self.nGroupID=agentId
	
	local gameverString=my.getGameVersion()
	assert(gameverString,'')
	local verinfos=string.split(gameverString,'.')
	self.nExeMajorVer=toint(verinfos[1])
	self.nExeMinorVer=toint(verinfos[2])
	self.nExeBuildno=toint(verinfos[3])
	self.dwVersion=my.makeLong(self.nExeMinorVer,self.nExeMajorVer)
    self.gameVer = gameverString
	
	local FLAG_ENTERROOM_HANDPHONE=0x00000800
	local FLAG_ENTERROOM_EXEBUILDNO=0x00004000
	local remindUpdate=false
--	self.dwEnterFlags=18432
	self.szChannelID=BusinessUtils:getInstance():getClientChannelId()
	if(type(self.szChannelID)~='string' or self.szChannelID:len()==0 or self.szChannelID=='0')then
		self.szChannelID='100003'
	end

	self.nGameID=toint(my.getGameID())
	
	self.szAppName=my.getAppAbbrName()
	self.abbrName=my.getAbbrName()

	local json = cc.load("json").json
    local s = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/shopconfig/shopconfig.json")
    if device.platform == "ios" then
		s = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/shopconfig/shopconfig_ios.json")
	end

    local AppJsonObj = json.decode(s)
    self.clientID=AppJsonObj["ClientId"]

    if cc.exports.isDepositSupported() then
        self.gameType='Deposit'
    else
        if cc.exports.isScoreSupported() then
            self.gameType='Point'
        end
    end

	
	self.dwSysVer=toint(DeviceUtils:getInstance():getSystemVersion())
	self.nHallNetDelay=323
	self.nHallRunCount=0
	self.nRecommenderID=toint(BusinessUtils:getInstance():getRecommenderId())
	
	self.nHallRunCount=0
	
end

return GameModel
