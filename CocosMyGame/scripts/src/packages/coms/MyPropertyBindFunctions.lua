
local _privateNamePrefix='_my'

function my.addProperty(self,propertyName,defaultValue)
	local privateName=_privateNamePrefix..propertyName

	self[privateName]=defaultValue

	function self:___preparing_function()
		-- body
		return self[privateName]
	end
	self['get'..propertyName]=self.___preparing_function

	function self:___preparing_function(v)
		-- body
		self[privateName]=v
	end
	self['set'..propertyName]=self.___preparing_function

	self.___preparing_function=nil

end

function my.addPropertysByList(self,propertyList)
	for k,v in pairs(propertyList)do
		self:addProperty(k,v)
	end
end

function my.addSyncProperty(self,propertyName,defaultValue)
	local privateName=_privateNamePrefix..propertyName
	local eventName=propertyName..'_Updated'

	self[privateName]=defaultValue

	function self:___preparing_function()
		-- body
		return self[privateName]
	end
	self['get'..propertyName]=self.___preparing_function

	function self:___preparing_function(v)
		-- body
		self[privateName]=v
		assert(self.dispatchEvent,'self.dispatchEvent is nil')
		self:dispatchEvent({name=eventName,value=v})
	end
	self['set'..propertyName]=self.___preparing_function

	self.___preparing_function=nil

end

function my.addSyncPropertysByList(self,propertyList)
	for k,v in pairs(propertyList)do
		self:addSyncProperty(k,v)
	end
end


function my.bindProperty(self,selfPropertyName,target,targetPropertyName,params)
	--local params={...}
	params=params or {}

	local targetSet=target['set'..targetPropertyName]
	local targetGet=target['get'..targetPropertyName]
	--local selfSet=self['set'..selfPropertyName]
	local selfGet=self['get'..selfPropertyName]

	if((targetSet or selfGet)==nil)then
		return
	end

	targetSet(target,selfGet(self))
	local eventName=params.name or selfPropertyName..'_Updated'
	self:addEventListener(eventName,function(e)
		-- body
--		if(targetGet(target)~=selfGet(self))then
			targetSet(target,e.value or selfGet(self))
--		end
	end,
	params.tag)

end

function my.bindSyncProperty(self,selfPropertyName,target,targetPropertyName,params)

	params=params or {}

	self:bindProperty(selfPropertyName,target,targetPropertyName,params)

	--local targetSet=target['set'..targetPropertyName]
	--local targetGet = target['get'..targetPropertyName]
	local selfSet=self['set'..selfPropertyName]
	--local selfGet=self['get'..selfPropertyName]

	function target:___preparing_function(...)
		-- body
		selfSet(self, ...)
	end
	target['set'..targetPropertyName]=target.___preparing_function
	target.___preparing_function=nil

end
