local NewUserInviteTipCtr=class('NewUserInviteTipCtr',cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.invitegift.newusergift.NewUserInviteTipView')

my.addInstance(NewUserInviteTipCtr)


function NewUserInviteTipCtr:onCreate(params)
    self._params = params or {}
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())

    -- self:bindDestroyButton(viewNode.closeBt)

	self:bindUserEventHandler(viewNode,{'sureBt','cancelBt',"knowBt","closeBt"})

	local action = cc.CSLoader:createTimeline('res/hallcocosstudio/invitegiftactive/newuser/newusersure_panel.csb')
    viewNode:runAction(action)
    action:play('animation_appear', false)

    viewNode.textPhone:setString(self._params.phone or "")
    viewNode.textItem:setString(self._params.item or "")
    viewNode.tipContent:setString(self._params.content or "")

    self:btnShowState(viewNode)
end


function NewUserInviteTipCtr:btnShowState(viewNode)
    
    local isOne = self._params.isOne or false

    viewNode.knowBt:setVisible(isOne)
    viewNode.sureBt:setVisible(not isOne)
    viewNode.cancelBt:setVisible(not isOne)

    viewNode.textPhone:setVisible(not isOne)
    viewNode.textItem:setVisible(not isOne)
    viewNode.tipContent:setVisible(isOne)

    viewNode.Text_1:setVisible(not isOne)
    viewNode.Text_2:setVisible(not isOne)
end

function NewUserInviteTipCtr:sureBtClicked(e)
    self:playEffectOnPress()
    if self._params.callBack then
        self._params.callBack()
    end
    self:removeSelfInstance()
end

function NewUserInviteTipCtr:cancelBtClicked(e)
    self:playEffectOnPress()
    self:removeSelfInstance()
end

function NewUserInviteTipCtr:knowBtClicked(e)
    self:playEffectOnPress()

    if self._params.knowCallBack then
        self._params.knowCallBack()
    end

    self:removeSelfInstance()
end


function NewUserInviteTipCtr:closeBtClicked(e)
    self:playEffectOnPress()
    if self._params.closeCallBack then
        self._params.closeCallBack()
    end
    self:removeSelfInstance()
end
return NewUserInviteTipCtr
