
local constStrings=cc.load('json').loader.loadFile('NetworkError.json')

local IGame=my.IGameForHall()

local mclient=mc.createClient()

local function setResponseHandler(respondId,portList,callback)
	if(portList=='*all')then
		portList={'room','hall'}
	end
	if(type(portList)=='string')then
		portList={portList}
	end

	for _,name in ipairs(portList)do
		mclient:registHandler(respondId,function(respondType,data,msgType,dataMap)
			callback(dataMap,data,msgType,respondType)
		end,name)
	end

end

local splitStringByLen=my.splitStringByLen
	
local function showTipByIdName(name)
	local msg=constStrings[name]
	my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})
end

local function deleteMsgStyle(msg)
	assert(msg,'')

	msg=string.gsub(msg,'<P>&nbsp;</P>','')
	msg=my.extractInfo(msg,'<P>(.-)</P>')
	msg=string.gsub(msg,'&nbsp;',' ')
	--msg=string.trim(msg)
	return msg
end

if(DEBUG>1)then
	--	local sd=deleteMsgStyle(nil)
	local sd=deleteMsgStyle('<kjwlfj><P>&nbsp;</P><P>1234</P>wef<dd></dd><P>5678</P><P>&nbsp;</P>joiwefj')
	local sd=deleteMsgStyle('')
end

local ExceptionHandlerList={
	----------------------------
	--	mc_respond_id_name=callback(dataMap,data,msgType,respondType)
	--
	ERROR_INFOMATION=function(dataMap,data,msgType)
		local msg=my.MCCharset.gb2Utf8String(data)
		my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})

	end,

	UR_OPERATE_FAIL=function (dataMap,data,msgType)
		local msg=constStrings['UR_OPERATE_FAIL']
		--my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})
	end,

	SYSTEM_MESSAGE=function(dataMap,data,msgType)
		local msg=deleteMsgStyle(data or '') or ''
		local msgList=splitStringByLen(msg,44)
		local msg=table.concat(msgList,'\n')
		local utf8msg=MCCharset:getInstance():gb2Utf8String(msg,msg:len())
--		my.informPluginByName({pluginName='TipPlugin',params={tipString=utf8msg,removeTime=20}})
        if string.len(msg) ~= 0 then 
            my.informPluginByName({pluginName='ToastPlugin',params={tipString=utf8msg,removeTime=20}})
        end

	end,

	ADMINMSG_TO_ROOM=function(dataMap,data,msgType)
--		local msg=deleteMsgStyle(dataMap.szMsgText)
		local msg=string.gfind(data or '','<.->(.+)')() or ''
		local utf8msg=MCCharset:getInstance():gb2Utf8String(msg,dataMap.nMsgLen)
--		IGame:onNotifyAdminMsgToRoom(msg)
		my.informPluginByName({pluginName='ToastPlugin',params={tipString=utf8msg,removeTime=20}})

	end,

	NOT_QUICKREGUSER=function(dataMap,data,msgType)
		local msg=constStrings['NOT_QUICKREGUSER']
		my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})

	end,

	KICKEDOFF_BYADMIN=function(dataMap,data,msgType)
		local msg=constStrings['KICKEDOFF_BYADMIN']
		my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})
		IGame:onNotifyKickedOffByAdmin()

	end,

	KICKOFF_ROOM_PLAYER=function(dataMap,data,msgType)
		local msg=constStrings['KICKOFF_ROOM_PLAYER']
		my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})
		IGame:onNotifyKickedOffByRoomPlayer()

	end,

	NEED_ENTERGAME=function(dataMap,data,msgType)

	end,

	--	SERVICE_BUSY=function(dataMap,data,msgType)
	--		showTipByIdName('SERVICE_BUSY')
	--	end,

	--	NODEPOSIT_GAME=function(dataMap,data,msgType)
	--	end,

	PLAYING_GAME=function(dataMap,data,msgType)
		showTipByIdName('PLAYING_GAME')
	end,

	NEED_LOGON=function(dataMap,data,msgType)
		local userPlugin = cc.exports.UserPlugin--require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
		userPlugin:login()
	end,

	WINSYSTEM_NOTENOUGH=function(dataMap,data,msgType)
	end,

	WINSYSTEM_NOTSUPPORT=function(dataMap,data,msgType)
	end,

	--!!!!!!!!!!!!!!!!!!!!!!!!!!
	UR_OBJECT_NOT_EXIST=function(dataMap,data,msgType)
    --[[
		my.scheduleOnce(function()
--			showTipByIdName('UR_OBJECT_NOT_EXIST')
            my.informPluginByName({pluginName='SureTipPlugin',params={tipContent=constStrings['UR_OBJECT_NOT_EXIST']}})
		end,1)
        ]]
	end,
	
	FORBID_UNEXPIRATION=function(dataMap,data,msgType)
		local msg=os.date(constStrings['FORBID_UNEXPIRATION'],dataMap.nForbidExpiration)
		my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})

	end,
--
--	LOGON_NEED_ACTIVATE=function(dataMap,data,msgType)
--	--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--	end,

	USER_LOCK=function(dataMap,data,msgType)
		showTipByIdName('USER_LOCKED')
	end,

	USER_FORBIDDEN=function(dataMap,data,msgType)
		showTipByIdName('USER_FORBIDDEN')
	end,

	SYSTEM_LOCK=function(dataMap,data,msgType)
		showTipByIdName('SYSTEM_LOCKED')
	end,

	FORBID_EXPIRATION=function(dataMap,data,msgType)
		showTipByIdName('FORBID_EXPIRATION')
	end,

	INPUTLIMIT_DAILY=function(dataMap,data,msgType)
		local msg
		local nRemain=dataMap.nTransferLimit - dataMap.nTransferTotal;
		if (nRemain >0)then
			msg = string.format(constStrings["INPUTLIMIT_DAILY"], dataMap.nTransferLimit, nRemain)
		else
			msg = string.format(constStrings["INPUTLIMIT_TOMORROW"], dataMap.nTransferLimit)
		end
		my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})

	end,

	KEEPDEPOSIT_LIMIT=function(dataMap,data,msgType)
		local msg=string.format(constStrings['KEEPDEPOSIT_LIMIT'],dataMap.nGameDeposit - dataMap.nKeepDeposit, dataMap.nKeepDeposit)
		my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})

	end,

	UR_DATABASE_ERROR=function(dataMap,data,msgType)
		showTipByIdName('DATABASE_ERROR')
	end,

	UR_PASSWORD_WRONG=function(dataMap,data,msgType)
--		showTipByIdName('PASSWORD_WRONG')
	end,
	
	UR_RESPONSE_TIMEOUT=function (dataMap,data,msgType)
		showTipByIdName('RESPONSE_TIMEOUT')
	end

} 

local function registerAllResponseHandler(port)
	for k,v in pairs(ExceptionHandlerList) do
		print(k,v)
		setResponseHandler(mc[k],port,v)
	end
end

local MCSocketBaseException={
	ExceptionHandlerList=ExceptionHandlerList,
	deleteMsgStyle=deleteMsgStyle,
	setResponseHandler=setResponseHandler,
	registerAllResponseHandler=registerAllResponseHandler,
}

return MCSocketBaseException
