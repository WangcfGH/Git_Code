local NoticeTipCtrl=class('NoticeTipCtrl',myctrl('BaseTipCtrl'))
local viewCreater=import('src.app.plugins.noticetip.NoticeTipView')

my.addInstance(NoticeTipCtrl)

local OK_BTN_NOTTOUCH_TIME = 5
local ONE_LINE_WORD_NUM = 17
local nonEmptyString=function (str)
    return type(str)=='string' and str:len()>0
end

NoticeTipCtrl.RUN_ENTERACTION = true
function NoticeTipCtrl:onCreate(params)
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    NoticeTipCtrl.super.onCreate(self,params)
end

function NoticeTipCtrl:setDialog(params)
    local viewNode = self._viewNode
    if(nonEmptyString(params.tipContent))then
        self:setStringOntip(params.tipContent)
    end
  
    self:forbidKeyBack()
    self:setOkBtnEnabled(false)
    self._okBtnTime = OK_BTN_NOTTOUCH_TIME
    self:startTimerFreshOkBtn()   
end

function NoticeTipCtrl:setOkBtnEnabled(bEnable)
    if self._viewNode.okBt then
        if bEnable then
            self._viewNode.okBt:setTouchEnabled(true)
            self._viewNode.okBt:setBright(true)
        else
            self._viewNode.okBt:setTouchEnabled(false)
            self._viewNode.okBt:setBright(false)
        end
    end
end

function NoticeTipCtrl:startTimerFreshOkBtn()
    if self._viewNode.okBt then
        local btnName = "确定".."("..tostring(self._okBtnTime)..")"
        self._viewNode.okBt:setTitleText(btnName)
    end
    self._timerID = my.scheduleFunc(function()
		self:freshOkBtn()
	end,1)
end

function NoticeTipCtrl:freshOkBtn()
    local btnName = "确定"
    if self._okBtnTime > 0 then
        self._okBtnTime = self._okBtnTime - 1
        btnName = btnName.."("..tostring(self._okBtnTime)..")"
    else
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerID)
        self:setOkBtnEnabled(true)      
    end
    if self._viewNode.okBt then
        self._viewNode.okBt:setTitleText(btnName)
    end
end

function NoticeTipCtrl:okBtClicked()
    print('hello')
    if(self._onOk)then
        self:_onOk()
    end
end

function NoticeTipCtrl:respondDestroyEvent(  )
	if(not self._isDestroyingSelf) then
		self._isDestroyingSelf=true
	end
	if(self._toDestroySelf)then	
		self:removeSelfInstance()
		self._toDestroySelf=nil
	end
	self._isDestroyingSelf=nil

end

function NoticeTipCtrl:forbidKeyBack()
    self.onKeyBack = function()
        print('forbidKeyBack')
    end
end

function NoticeTipCtrl:createViewNode(...)
    local instance = NoticeTipCtrl:getInstance(...)
    instance:setDialog(...)
    return instance:getViewNode():getRealNode()
end

function NoticeTipCtrl:setStringOntip(content)
    local viewNode = self._viewNode
    local strTable = my.subContentToTableByNum(content, ONE_LINE_WORD_NUM)
    content = table.concat(strTable, "\n")
    viewNode.tipContent:setString(tostring(content))  
    local tipContentSize = viewNode.tipContent:getContentSize()
    local listContentSize = viewNode.listContent:getContentSize()
    if tipContentSize.height > listContentSize.height then
        viewNode.tipContent:removeFromParent()
        viewNode.listContent:addChild(viewNode.tipContent:getRealNode())
    end
end

return NoticeTipCtrl
