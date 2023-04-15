local EmailViewFactory      = {}
cc.exports.EmailViewFactory = EmailViewFactory

local EmailTabView          = import("src.app.plugins.email.EmailTabView")
local EmailAwardView        = import("src.app.plugins.email.EmailAwardView")

function EmailViewFactory.newEmailTab(emailInfo)
    return EmailTabView:createViewIndexer(emailInfo)
end

function EmailViewFactory.newAwardItem(awardInfo)
    return EmailAwardView:createViewIndexer(awardInfo)
end

function EmailViewFactory.wrapAwardItem(viewNode)
    return EmailAwardView:wrapUserdataNode(viewNode)
end

function EmailViewFactory.wrapEmailTab(viewNode)
    return EmailTabView:wrapUserdataNode(viewNode)
end

return EmailViewFactory