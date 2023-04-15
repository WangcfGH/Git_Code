
local viewCreater=import('src.app.plugins.MemberTransfer.MemberTransferView')

local MemberTransferCtrl=class('ChooseDialog',myctrl('BaseTipCtrl'))
local NobilityPrivilegeGiftModel      = import("src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftModel"):getInstance()

local nonEmptyString=function (str)
	return type(str)=='string' and str:len()>0
end

MemberTransferCtrl.RUN_ENTERACTION = true
function MemberTransferCtrl:onCreate(params)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self._viewNode = viewNode
	self:bindUserEventHandler(viewNode,{'okBt','cancelBt','closeBt','sureBt'})
	MemberTransferCtrl.super.onCreate(self,params)
    self:updateUI()
end

function MemberTransferCtrl:updateUI()
	local nobilityPrivilegeGiftInfo = NobilityPrivilegeGiftModel:GetNobilityPrivilegeGiftInfo()
    if not nobilityPrivilegeGiftInfo then
        NobilityPrivilegeGiftModel:gc_GetNobilityPrivilegeGiftInfo()
        return
    end

    local nDay = nobilityPrivilegeGiftInfo.remainDays
    local nLevel = nobilityPrivilegeGiftInfo.nobilityLevel
    local nExperience = nobilityPrivilegeGiftInfo.transGainExperience

    --未转化
    if nobilityPrivilegeGiftInfo.transStatus == 0 then
        self._viewNode.PanelMemberTransfer:setVisible(true)
        self._viewNode.PanelTransferSuccess:setVisible(false)
        self._viewNode.PanelMemberTransfer:getChildByName("Panel_Member"):getChildByName("Text_Value"):setString(nDay.."天")
        self._viewNode.PanelMemberTransfer:getChildByName("Panel_NobilityPrivilege"):getChildByName("Text_Value"):setString(nExperience.."经验值")
    elseif nobilityPrivilegeGiftInfo.transStatus == 1 then
        self._viewNode.PanelMemberTransfer:setVisible(false)
        self._viewNode.PanelTransferSuccess:setVisible(true)
        self._viewNode.PanelTransferSuccess:getChildByName("Panel_NobilityPrivilege"):getChildByName("Text_Value"):setString(nExperience.."经验值")
        self._viewNode.PanelTransferSuccess:getChildByName("Text_Title"):setString("恭喜您成为贵族"..nLevel)
    end
end

function MemberTransferCtrl:okBtClicked()
	my.playClickBtnSound()
    NobilityPrivilegeGiftModel:gc_TransferNobilityPrivilegeGift()
end

function MemberTransferCtrl:cancelBtClicked()
	my.playClickBtnSound()
    self:goBack()
end

function MemberTransferCtrl:closeBtClicked()
	my.playClickBtnSound()
    self:goBack()
end

function MemberTransferCtrl:sureBtClicked()
	my.playClickBtnSound()
    self:goBack()
end

function MemberTransferCtrl:goBack()
            --每日登录弹框
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:PopNextPlugin()
    MemberTransferCtrl.super.removeSelf(self)
end

function MemberTransferCtrl:onKeyBack()
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:stopPluginProcess()
    MemberTransferCtrl.super.onKeyBack(self)
end

return MemberTransferCtrl
