
local httpjson=require('src.app.GameHall.models.http2json.http2json')
local SyncSender=cc.load('asynsender').SyncSender
local device=mymodel('DeviceModel'):getInstance()

local httpj=httpjson:create()
SyncSender.run(httpj,function()
	local sender,data=SyncSender.send('relief',{nUserID=5665})
	dump(data)
end)
