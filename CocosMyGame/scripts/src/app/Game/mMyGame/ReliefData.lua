local ReliefData = class('ReliefData',cc.load('BaseCtrl'))
local relief=mymodel('hallext.ReliefActivity'):getInstance()
local user=mymodel('UserModel'):getInstance()

function ReliefData:onCreate()
	self:bindProperty(relief,'State',self,'ReliefState')
end

function ReliefData:setReliefState(data)
	assert(data,'')
	
	local config=data.config
	local state=data.state
	local reliefData=user.reliefData
	
    if self._gameController then
        self._gameController:setReliefState(data, reliefData)
    end
end

return ReliefData