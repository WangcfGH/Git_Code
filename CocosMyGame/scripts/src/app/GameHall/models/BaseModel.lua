
local event=cc.load('event')

local BaseModel=class('BaseModel')

my.addInstance(BaseModel)

BaseModel.EVENT_MODULESTATUS_CHANGED = "EVENT_MODULESTATUS_CHANGED"
function BaseModel:ctor(...)
	event:create():bind(self)

    self._myStatusDataExtended = {} --扩展数据

	if(self.onCreate)then
		self:onCreate(...)
	end
end

function BaseModel:bindProperty(selfPropertyName,target,targetPropertyName,params)
	return my.bindProperty(self,selfPropertyName,target,targetPropertyName,params)
end

function BaseModel:bindSyncProperty(selfPropertyName,target,targetPropertyName,params)
	return my.bindSyncProperty(self,selfPropertyName,target,targetPropertyName,params)
end

function BaseModel:addProperty(propertyName,defaultValue)
	return my.addProperty(self,propertyName,defaultValue)
end

function BaseModel:addPropertysByList(propertyList)
	return my.addPropertysByList(self,propertyList)
end

function BaseModel:addSyncProperty(propertyName,defaultValue)
	return my.addSyncProperty(self,propertyName,defaultValue)
end

function BaseModel:addSyncPropertysByList(propertyList)
	return my.addSyncPropertysByList(self,propertyList)
end




--自定义功能
function BaseModel:dealAssistResponse(dataMap)
    print(self.__cname..":dealAssistResponse")
    local responseId, responseData = unpack(dataMap.value)

    if self._assistResponseMap == nil then
        print("no assistResponseMap defined!!!")
        return
    end

    local handlerFunc = self._assistResponseMap[responseId]
    if handlerFunc then
        handlerFunc(responseData)
    else
        printf('onDataReceived other = '..tostring(responseId))
    end
end

function BaseModel:isResponseID(responseId)
    if self._assistResponseMap == nil then
        print("no assistResponseMap defined!!!")
        return false
    end

    if self._assistResponseMap[responseId] then
        return true
    end

    return false
end

function BaseModel:getStatusDataExtended(itemName)
    return self._myStatusDataExtended[itemName]
end

function BaseModel:dispatchModuleStatusChanged(moduleName, eventName)
    print("BaseModel:dispatchModuleStatusChanged")
    if moduleName == nil or eventName == nil then return end

    local eventData = {
        ["moduleName"] = moduleName,
        ["eventName"] = eventName,
        ["dataModel"] = self
    }
    self:dispatchEvent({name = BaseModel.EVENT_MODULESTATUS_CHANGED, value = eventData})
end

return BaseModel
