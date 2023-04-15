
local SceneCtrl=class('SceneCtrl',import('.BaseCtrl'))

function SceneCtrl:respondDestroyEvent(  )
	if(not self._isDestroyingSelf) then
		self._isDestroyingSelf=true
	end
	if(self._toDestroySelf)then
		if(self:informPluginByName(nil,{message='remove'}))then
			self:removeSelfInstance()
		end
		self._toDestroySelf=nil
	end
	self._isDestroyingSelf=nil

end 

function SceneCtrl:onKeyBack()
    printf("basectrl onkeyBack")
	self:playEffectOnPress()
	my.scheduleOnce(function()
--		self._toDestroySelf=true
--		self:respondDestroyEvent()
		if(self:informPluginByName(nil,{message='remove'}))then
			self:removeSelfInstance()
		end
	end)
end

--自定义功能
function SceneCtrl:closeSelf()
    my.scheduleOnce(function()
		if self:informPluginByName(nil, {message = 'remove'}) then
			self:removeSelfInstance()
		end
    end)
end

cc.register('SceneCtrl',SceneCtrl)

return SceneCtrl
