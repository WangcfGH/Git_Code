
local BatchProcessor=class('BatchProcessor')

function BatchProcessor:ctor(getTaskManager)
	self._getTaskManager=getTaskManager
end

function BatchProcessor:_getRespondingList()
	if(self._respondingList==nil)then
		self._respondingList={}
	end
	return self._respondingList
end

function BatchProcessor:postTask(taskId,...)
	self:addNewTask(taskId,...)
	self:driveProcessor()
end

function BatchProcessor:addNewTask(taskId,...)
	local respondingList=self:_getRespondingList()

	if(respondingList[taskId])then
		return
	end

	respondingList[taskId]=#respondingList+1
	respondingList[#respondingList+1]={taskId,...}

end

function BatchProcessor:tryHandler(eventHandler,...)
	if(eventHandler)then
		local params={...}
		local status, msg = my.mxpcall(function()
			eventHandler(unpack(params))
		end
		, __G__TRACKBACK__)
		if not status then
			release_print(msg)
		end
	end
end

function BatchProcessor:driveProcessor()
	if(self._isInProcessing)then
		return
	end
	self._isInProcessing=true

	local eventHandler
	local respondingList=self:_getRespondingList()
	local taskManager = self:_getTaskManager()
	while(#respondingList>0)do
		local eventItem=respondingList[1]

		local taskId=eventItem[1]
		table.remove(eventItem,1)

		table.remove(respondingList,1)
		respondingList[taskId]=nil

		taskManager:foreachTaskById(taskId,function(eventHandler)
			self:tryHandler(eventHandler,unpack(eventItem))
		end)

	end

	self._isInProcessing=false

end

return BatchProcessor
