
-------------------------------
--params=
--{
--tipContent="弹框内容描述"
--tipTitle="弹框标题", 可为空
--okBtTitle="我同意", 可为空
--cancelBtTitle="我拒绝", 可为空
--onOk=OK回调函数
--onCancel=Cancel回调函数
--onClose=关闭按钮回调函数
--closeBtVisible=关闭按钮是否可见, 默认false
--forbidKeyBack=是否禁用物理返回, 默认false
--onKeyBack=keyback回调函数
--isShowNetworkCheck=是否显示网络检测入口, 网络检测专用
--isCheckBoxSelected=复选框默认状态
--checkBoxContent=复选框提示的内容
--}

local viewCreater=import('src.app.plugins.choosedialog.ChooseTipView')

local Tip2Ctrl=class('ChooseDialog',myctrl('BaseTipCtrl'))

local nonEmptyString=function (str)
	return type(str)=='string' and str:len()>0
end

Tip2Ctrl.RUN_ENTERACTION = true
function Tip2Ctrl:onCreate(params)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
	self:bindUserEventHandler(viewNode,{'okBt','cancelBt','closeBt'})
	self:onClickOk(params.onOk)
	self:onClickCancel(params.onCancel)
	self:onClickClose(params.onClose)
	if(nonEmptyString(params.tipTitle))then
		viewNode.tipTitle:setVisible(true)
		viewNode.imgTitle:setVisible(false)
		viewNode.tipTitle:setString(params.tipTitle)
	end
	if(nonEmptyString(params.tipContent or params.tipString))then
		viewNode.tipContent:setString(params.tipContent or params.tipString)
	end
	if(nonEmptyString(params.okBtTitle))then
		viewNode.okBt:setTitleText(params.okBtTitle)
		viewNode.imgSure:setVisible(false)
	end
	if(nonEmptyString(params.cancelBtTitle))then
		viewNode.cancelBt:setTitleText(params.cancelBtTitle)
		viewNode.imgCancel:setVisible(false)
	end
	viewNode.closeBt:setVisible(params.closeBtVisible~=false)
    if(params.forbidKeyBack == true) then
        self:forbidKeyBack()
    elseif type(params.onKeyBack) == "function" then
        self.onKeyBack = function(...)
            params.onKeyBack(self._isCheckBoxSelected) 
            Tip2Ctrl.super.onKeyBack(...)
        end
	end
	viewNode.networkCheckTxt:setVisible(false)
	if params.isShowNetworkCheck and DeviceUtils:getInstance().ping then
		viewNode.networkCheckTxt:setVisible(true)
		viewNode.networkCheckBtn:addClickEventListener(function ()
            my.informPluginByName({pluginName='NetworkCheckCtrl'})
        end)
	end

	if self._viewNode.checkBoxPanel then
		self._viewNode.checkBoxPanel:setVisible(false)
		if params.checkBoxContent then
			self._viewNode.checkBox:setSelected(params.isCheckBoxSelected)
			self._isCheckBoxSelected = self._viewNode.checkBox:isSelected()
			self._viewNode.checkBox:addEventListenerCheckBox(function(sender, eventType)
				if eventType == ccui.CheckBoxEventType.selected then
					print("selected")
					self._isCheckBoxSelected = true
				elseif eventType == ccui.CheckBoxEventType.unselected then
					print("unselected")
					self._isCheckBoxSelected = false
				end
			end)
			self._viewNode.checkBoxPanel:setVisible(true)

			self._viewNode.checkBoxText:setString(params.checkBoxContent)
		end
	end
	Tip2Ctrl.super.onCreate(self,params)
	
end

function Tip2Ctrl:okBtClicked()
	if(self._onOkHandler)then
		self._onOkHandler(self._isCheckBoxSelected)
	end
end

function Tip2Ctrl:cancelBtClicked()
	if(self._onCancelHandler)then
		self._onCancelHandler(self._isCheckBoxSelected)
	end
end

function Tip2Ctrl:closeBtClicked()
	if(self._onCloseHandler)then
		self._onCloseHandler(self._isCheckBoxSelected)
	end
end

function Tip2Ctrl:onClickOk(callback)
	self._onOkHandler=callback
end

function Tip2Ctrl:onClickCancel(callback)
	self._onCancelHandler=callback
end

function Tip2Ctrl:onClickClose(callback)
	self._onCloseHandler=callback
end

function Tip2Ctrl:forbidKeyBack()
    self.onKeyBack = function()
        print('forbidKeyBack')
    end
end

function Tip2Ctrl:onGetCenterCtrlNotify(params)
    Tip2Ctrl.super.onGetCenterCtrlNotify(self, params)
    if params.message == 'onExit' then
        self:removeSelfInstance()
    end
end


return Tip2Ctrl
