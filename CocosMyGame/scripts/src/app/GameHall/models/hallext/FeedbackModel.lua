
local SyncSender=cc.load('asynsender').SyncSender
local FeedbackModel=class('FeedbackModel',import('src.app.GameHall.models.BaseModel'))

local constStrings=cc.load('json').loader.loadFile('HelpStrings.json')
local userModel = mymodel("UserModel"):getInstance()

my.addInstance(FeedbackModel)

FeedbackModel.UN_REPLY=1
FeedbackModel.NEW_REPLY=2
FeedbackModel.NO_REPLY=3

FeedbackModel.FEEDBACK_STATE_UPDATED='STATE_UPDATED'
FeedbackModel.FEEDBACK_MSG_LIST_UPDATED='MSGLIST_UPDATED'
FeedbackModel.FEEDBACK_MSG_SENT='MSGSENTSTATU_UPDATED'

function FeedbackModel:onCreate()
end

function FeedbackModel:queryState()
    --userModel:ReadUserInfo()
	local client=my.jhttp:create()
	SyncSender.run(client,function()
		local sender,dataMap=SyncSender.send('obtainFeedbackState')
		dump(dataMap)
		self.state=dataMap
		self:dispatchEvent({name=self.FEEDBACK_STATE_UPDATED,value=dataMap})
	end)
end

function FeedbackModel:getState()
	return self.state
end

--msg=MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))

FeedbackModel._defaultMsg={
	reply=constStrings['default_reply_msg'] or 'hello',
	reply_time=os.time(),
}
function FeedbackModel:getDefaultMsg()
	return self._defaultMsg
end

function FeedbackModel:queryMsgList()
    --userModel:ReadUserInfo()
	local client=my.jhttp:create()
	SyncSender.run(client,function()
		local sender,dataMap=SyncSender.send('obtainFeedbackMsgList')
		if(dataMap==nil or dataMap.data==nil)then
			self:dispatchEvent({name=self.FEEDBACK_MSG_LIST_UPDATED,value=dataMap})
			return
		end
		if(#dataMap.data==0)then
			table.insert(dataMap.data,1,self:getDefaultMsg())
		end
		if(not self.state or self.state.data==self.NEW_REPLY)then
			self:queryState()
		end
		self:dispatchEvent({name=self.FEEDBACK_MSG_LIST_UPDATED,value=dataMap})
	end)
end

function FeedbackModel:getMsgList()
	return self.msgList
end

function FeedbackModel:submit(msg)
    --userModel:ReadUserInfo()
	local client=my.jhttp:create()
	SyncSender.run(client,function()
		local sender,dataMap=SyncSender.send('submitFeedbackMessage',{deviceType='Simulator',msg=msg})
		dump(dataMap)
		self:dispatchEvent({name=self.FEEDBACK_MSG_SENT,value=dataMap})
	end)
end

return FeedbackModel
