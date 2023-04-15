local viewCreater = import('src.app.plugins.AnchorLuckyBag.CheckTiktokAccountView')
local CheckTiktokAccountCtrl = class('CheckTiktokAccountCtrl', cc.load('BaseCtrl'))

CheckTiktokAccountCtrl.RUN_ENTERACTION = true

function CheckTiktokAccountCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnClose)
end

return CheckTiktokAccountCtrl