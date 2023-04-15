local TipCtrl=class('TipCtrl',myctrl('BaseTipCtrl'))
local viewCreater=import('src.app.plugins.suretip.SureTipView')

my.addInstance(TipCtrl)

local nonEmptyString=function (str)
    return type(str)=='string' and str:len()>0
end

TipCtrl.RUN_ENTERACTION = true
function TipCtrl:onCreate(params)
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    TipCtrl.super.onCreate(self,params)
    self._curHeight = 0
end

function TipCtrl:setDialog(params)
    local viewNode = self._viewNode
    if(nonEmptyString(params.tipContent))then
        viewNode.scrollView:setVisible(false)
        viewNode.tipContent:setString(params.tipContent or params.tipString)
    elseif type(params.tipContent) == 'table' then
        viewNode.scrollView:setVisible(true)
        viewNode.scrollView:setBounceEnabled(true)
        viewNode.tipContent:setVisible(false)
        self:showScrollView(params.tipContent)
    end
    if(nonEmptyString(params.tipTitle))then
        viewNode.tipTitle:setString(params.tipTitle)
    end

    local imgTextConfirm = viewNode.okBt:getChildByName("img_text_confirm_4")
    local textBtnTitle = viewNode.okBt:getChildByName('Text_Btn_Title')
    imgTextConfirm:setVisible(true)
    textBtnTitle:setVisible(false)
    if(nonEmptyString(params.okBtTitle))then
        textBtnTitle:setString(params.okBtTitle)
        textBtnTitle:setVisible(true)
        imgTextConfirm:setVisible(false)
    end

    self._onOk=params.onOk
    self._onClose=params.onClose

    printLog("suredialog","needClose"..tostring(params.closeBtVisible))
    viewNode.closeBt:setVisible(checkbool(params.closeBtVisible))

    if(params.forbidKeyBack == true) then
        self:forbidKeyBack()
    elseif type(params.onKeyBack) == "function" then
        self.onKeyBack = function(...)
            params.onKeyBack() 
            TipCtrl.super.onKeyBack(...)
        end
    end
end

function TipCtrl:okBtClicked()
    print('hello')
    if(self._onOk)then
        self:_onOk()
    end
end

function TipCtrl:closeBtClicked()
    if(self._onClose)then
        self:_onClose()
    end
end

function TipCtrl:onKeyBack()
    if(self._onClose)then
        self:_onClose()
    end
    TipCtrl.super.onKeyBack(self)
end

function TipCtrl:respondDestroyEvent(  )
	if(not self._isDestroyingSelf) then
		self._isDestroyingSelf=true
	end
	if(self._toDestroySelf)then
		--if(self:informPluginByName(nil,nil))then
			self:removeSelfInstance()
		--end
		self._toDestroySelf=nil
	end
	self._isDestroyingSelf=nil

end

function TipCtrl:forbidKeyBack()
    self.onKeyBack = function()
        print('forbidKeyBack')
    end
end

function TipCtrl:createViewNode(...)
    local instance = TipCtrl:getInstance(...)
    instance:setDialog(...)
    return instance:getViewNode():getRealNode()
end

function TipCtrl:showScrollView(strTable)
    local scoSize = self._viewNode.scrollView:getContentSize()
    for i = 1, #strTable do
        local str = strTable[#strTable - i + 1]
        local text = ccui.Text:create()
        text:setColor(display.COLOR_BLACK)
        text:setFontSize(24) 
        text:setAnchorPoint(cc.p(0, 0))       
        text:setString(tostring(str)) 
        local height = text:getContentSize().height    
        local posY = self._curHeight
        self._curHeight = self._curHeight + height
        text:setPosition(cc.p(20,posY))  
        self._viewNode.scrollView:addChild(text)
    end
    scoSize.height = self._curHeight
    self._viewNode.scrollView:setInnerContainerSize(scoSize)
end

return TipCtrl
