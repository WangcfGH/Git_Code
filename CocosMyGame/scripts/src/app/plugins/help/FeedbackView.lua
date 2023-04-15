
local FeedbackView=class('FeedbackView')
local QuestRecordView=require('src.app.plugins.help.QuestRecordView')
local ReplyRecordView=require('src.app.plugins.help.ReplyRecordView')

local viewConfig=require('src.app.HallConfig.FeedbackViewConfig')
local MSG_MARGIN_OFFSET_X=viewConfig.MSG_MARGIN_OFFSET_X or 50
local MSG_MARGIN_OFFSET_Y=viewConfig.MSG_MARGIN_OFFSET_Y or 20
local MSG_POSITION_OFFSET_X=viewConfig.MSG_POSITION_OFFSET_X or 0
local MSG_POSITION_OFFSET_Y=viewConfig.MSG_POSITION_OFFSET_Y or 0

function FeedbackView:ctor(viewNode)
	self._viewNode=viewNode
end

function FeedbackView:updateMsgList(msgList)

	local viewNode=self._viewNode

	viewNode:removeAllChildren()
	local questRecord
	local replyRecord
	local message,reply,message_time,reply_time

	for i,msg in ipairs(msgList) do
		message,reply,message_time,reply_time=msg.message,msg.reply,msg.message_time,msg.reply_time

		if(message and message:len()>0)then
			questRecord=QuestRecordView:createViewIndexer()
			questRecord:setMsg(message)
			local PublicInterface = cc.exports.PUBLIC_INTERFACE
			local playerInfo = PublicInterface:GetPlayerInfo()
			local nSex = playerInfo.nNickSex or 2
            questRecord:setHead(nSex)
			questRecord:setTime(message_time)
			local height=questRecord:getContentHeight()
			questRecord:setPosition(cc.p(1280-270-MSG_MARGIN_OFFSET_X+MSG_POSITION_OFFSET_X,MSG_MARGIN_OFFSET_Y+MSG_POSITION_OFFSET_Y))
			local node=ccui.Widget:new()
			node:setContentSize(cc.size(100,height))
			questRecord:addTo(node)
			viewNode:pushBackCustomItem(node)
		end

		if(reply and reply:len()>0)then
			replyRecord=ReplyRecordView:createViewIndexer()
			replyRecord:setMsg(reply)
			replyRecord:setTime(reply_time)
			local height=replyRecord:getContentHeight()
			replyRecord:setPosition(cc.p(MSG_MARGIN_OFFSET_X+MSG_POSITION_OFFSET_X,MSG_MARGIN_OFFSET_Y+MSG_POSITION_OFFSET_Y))
			local node=ccui.Widget:new()
			node:setContentSize(cc.size(100,height))
			replyRecord:addTo(node)
			viewNode:pushBackCustomItem(node)
		end

	end

	function viewNode:jumpToBottom()
		local inner=self:getInnerContainer()
		inner:setPosition(cc.p(inner:getPositionX(),inner:getContentSize().height+60))
	end
	viewNode:jumpToBottom()
end

return FeedbackView
