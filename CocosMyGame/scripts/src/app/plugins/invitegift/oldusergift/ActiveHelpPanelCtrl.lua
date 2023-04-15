

local ActiveHelpPanelCtrl    = class('ActiveHelpPanelCtrl',cc.load('BaseCtrl'))
local viewCreater   = import('src.app.plugins.invitegift.oldusergift.ActiveHelpPanelView')

ActiveHelpPanelCtrl.RUN_ENTERACTION = true
function ActiveHelpPanelCtrl:onCreate( params )
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())

    self:bindSomeDestroyButtons(viewNode,{'closeBt'})

    if params.title then
        viewNode.Text_help_t:setString(params.title)
    end

    if params.content then
        viewNode.Text_help:setString(params.content)
    end


    local function onClickHelp()
        self:removeSelfInstance()
    end
    viewNode.panelShade:addClickEventListener(onClickHelp)
    if params.Height then
        viewNode.ScrollView:setInnerContainerSize(cc.size(viewNode.ScrollView:getContentSize().width, params.Height))
        local contentSize = viewNode.Text_help:getContentSize()
        viewNode.Text_help:setContentSize({width = contentSize.width,height = params.Height} )--{ width = 10, height =10 }
        viewNode.Text_help:setPositionY(viewNode.Text_help:getPositionY() +(params.Height- contentSize.height) )
    end
end


return ActiveHelpPanelCtrl
