
import('.MyPropertyBindFunctions.lua')

local targetObj={}

function targetObj:addProperty(propertyName,defaultValue)
	return my.addProperty(self,propertyName,defaultValue)
end

function targetObj:addPropertysByList(propertyList)
	return my.addPropertysByList(self,propertyList)
end

function targetObj:addSyncProperty(propertyName,defaultValue)
	return my.addSyncProperty(self,propertyName,defaultValue)
end

function targetObj:addSyncPropertysByList(propertyList)
	return my.addSyncPropertysByList(self,propertyList)
end

function targetObj:removeEventHosts()
	local eventTag = self:getEventTag()
	local eventHostList = self:getEventHostList()
	for k,_ in pairs(eventHostList) do
		k:removeEventListenersByTag(eventTag)
	end
end

function targetObj:getEventHostList()
	-- body
	local eventHostList=self._eventHostList
	if(eventHostList==nil)then
		eventHostList={}
		setmetatable(eventHostList,{__mode='k'})
		self._eventHostList=eventHostList
	end
	return eventHostList
end

function targetObj:getEventTag()
	-- body
	local eventTag=self._eventTag
	if(eventTag==nil)then
		eventTag='eventTag'..self.__cname
		self._eventTag=eventTag
	end
	return eventTag
end

function targetObj:bindProperty(eventHost,hostPropertyName,target,targetPropertyName,params)
	local eventHostList=self:getEventHostList()
	eventHostList[eventHost]=true

	local eventTag=self:getEventTag()
	params=params or {}
	params.tag=params.tag or eventTag

	return my.bindProperty(eventHost,hostPropertyName,target,targetPropertyName,params)
end

function targetObj:bindSyncProperty(eventHost,hostPropertyName,target,targetPropertyName,params)
	local eventHostList=self:getEventHostList()
	eventHostList[eventHost]=true

	local eventTag=self:getEventTag()
	params=params or {}
	params.tag=params.tag or eventTag

	return my.bindSyncProperty(eventHost,hostPropertyName,target,targetPropertyName,params)
end

function targetObj:listenTo(eventHost,eventId,handler)
	if(eventHost.addEventListener)then
		local eventHostList=self:getEventHostList()
		eventHostList[eventHost]=true
		local eventTag=self:getEventTag()

		eventHost:addEventListener(eventId,handler,eventTag)
	end
end

return targetObj
