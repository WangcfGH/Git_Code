local UniqueObject = class("UniqueObject")

function UniqueObject:ctor()
end

function UniqueObject:getInstance(...)
	if self._instance == nil then
		self._instance = self:create(...)
	end
	return self._instance
end

function UniqueObject:removeInstance()
	self.class._instance = nil
end

return UniqueObject