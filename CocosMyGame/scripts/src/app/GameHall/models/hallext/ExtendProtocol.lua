
--扩展协议，业务模型需要扩展UserModel用于绑定业务数据时可以继承

local ExtendProtocol=class('ExtendProtocol', import('src.app.GameHall.models.BaseModel'))

function ExtendProtocol:onCreate()
	self:presetData()
end

function ExtendProtocol:presetData()
	self:_initData()
	self:_initSettings()
end

function ExtendProtocol:_initData()

end

function ExtendProtocol:_initSettings()
	
end

return ExtendProtocol
