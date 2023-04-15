
local dataCollector=cc.load('datacollector'):getInstance()

--local dataCollector=cc.load('DataCollector'):getInstance()

local dataSourceClassList={
	'DeviceModel',
	'GameModel',
	'UserModel',
}

for _,v in pairs(dataSourceClassList) do
	dataCollector:addIndex(mymodel(v):getInstance())
end
