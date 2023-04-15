
local viewCreater=import('src.app.plugins.help.HelpViewExpand')
local FeedbackView=require('src.app.plugins.help.FeedbackView')
local feedback=mymodel('hallext.FeedbackModel'):getInstance()
local HelpCtrl=class('HelpCtrl',cc.load('SceneCtrl'))
local constStrings=cc.load('json').loader.loadFile('HelpStrings.json')

my.addInstance(HelpCtrl)

function HelpCtrl:onCreate(parameters)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())

	local webView=viewNode.webView
	webView:setVisible(true)
    --viewNode.kefuWebView:setVisible(false)
	local bindList={
		'clearBt',
		'sendMsgBt',
		'titles',
	}

	self:bindDestroyButton(viewNode.backBt)
	self:bindUserEventHandler(viewNode,bindList)

	viewNode.feedbackMsgListNode=FeedbackView:create(viewNode.msglistLs)

    if cc.exports.isCustomerServiceSupported() == true then
	    feedback:queryMsgList()
    end
	self:bindProperty(feedback,'MsgList',self,'MsgList')
	self:listenTo(feedback,feedback.FEEDBACK_MSG_SENT,handler(self,self.onMsgSentResult))

	self:setOnExitCallback(function()
		self:informPluginByName('MainScene')
		--require("src.app.plugins.roomspanel.RoomsCtrl"):playTipAni()
	end)
end

function HelpCtrl:_clearInputed()
	self._viewNode.inputInp:setString('')
end

function HelpCtrl:clearBtClicked(e)
	self:_clearInputed()
end

function HelpCtrl:sendMsgBtClicked()
	print('send msg')
	local msg=self._viewNode.inputInp:getString()
	if(DEBUG==4)then
	end
	if(my.utfstrlen(msg)>=8)then
		feedback:submit(msg)
		self:_clearInputed()
	else
		self:showTip(constStrings['text_to_short'],1)
	end
end

function HelpCtrl:titlesClicked(e)
	print(e.index)
	self._viewNode:showPageByIndex(e.index)

end

function HelpCtrl:refreshFeedbackMsgList(dataList)
-- body
end

function HelpCtrl:setMsgList(data)
	if(data==nil or data.data==nil)then
--		local message
--		message=constStrings['server_broken']
--		self:showTip(message,1)
		return
	end
	if(data and data.is_success and data.data)then
		self._viewNode.feedbackMsgListNode:updateMsgList(data.data)
	end
end

function HelpCtrl:showTip(msg,time)
	time=time or 1
	self:informPluginByName('TipPlugin',{tipString=msg,removeTime=time})
end

function HelpCtrl:onMsgSentResult(data)
	local result=data.value
	if(result.is_success)then
		feedback:queryMsgList()
	else
		local message=result.message
		if(message==nil or message:len()==0)then
			message=constStrings['server_broken']
		end
		self:showTip(message,1)
	end
	dump(result)
end

function HelpCtrl:onKeyBack()
    printf("HelpCtrl onkeyBack")
    if self._viewNode.keFuwebPanel and self._viewNode.keFuwebPanel:isVisible() then
        self._viewNode.keFuwebPanel:setVisible(false)
        if self._viewNode.kefuWebView and self._viewNode.kefuWebView:isVisible() then
            self._viewNode.kefuWebView:setVisible(false)
        end
        if self._viewNode.webView then
            self._viewNode.webView:setVisible(true)        
        end
        return
    end
    self:playEffectOnPress()
	my.scheduleOnce(function()
--		self._toDestroySelf=true
--		self:respondDestroyEvent()
		if(self:informPluginByName(nil,nil))then
			self:removeSelfInstance()
		end
	end)
end

return HelpCtrl
