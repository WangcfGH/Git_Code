
local DynamicMatrix2=import('.DynamicMatrix2')
local BatchTaskProcessor=import('.BatchTaskProcessor')

local targetObj={}

function targetObj:_getWidgetEventBindList(  )
	if(self._widgetEventBindList==nil)then
		self._widgetEventBindList=DynamicMatrix2:create()
	end
	return self._widgetEventBindList
end

function targetObj:_getBatchTaskProcessor(  )
	if(not self._batchTaskProcessor)then
		local _widgetEventBindList=self:_getWidgetEventBindList()
		local taskManager={}
		function taskManager:foreachTaskById(taskId,theHandler)
			DynamicMatrix2.foreachBySecondKey(_widgetEventBindList,taskId,theHandler)
		end
		self._batchTaskProcessor=BatchTaskProcessor:create(function() return taskManager end)
	end
	return self._batchTaskProcessor
end

function targetObj:postClickEvent( widget,... )
	self:_getBatchTaskProcessor():postTask(widget,...)
end

function targetObj:_bindWidgetEventProxy(widget)
	self:_bindWidgetClickEventProxy(widget)
end

function targetObj:_bindWidgetClickEventProxy(widget)
	local ctrl=self
	local onClickHandler=function (...)
		ctrl:postClickEvent(widget,...)
	end

	if(widget.onClick)then
		widget:onClick(onClickHandler)
	elseif(widget.addClickEventListener)then
		widget:addClickEventListener(onClickHandler)
	end
end

function targetObj:bindWidgetToClickEventHandler(button,eventTypeName,eventHandler)
	if(button.addClickEventListener==nil and button.onClick==nil)then
		return
	end
	local widgetEventBindList=self:_getWidgetEventBindList()
	widgetEventBindList[eventTypeName][button]=eventHandler
	self:_bindWidgetEventProxy(button)
end

return targetObj
