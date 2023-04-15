local ActivityJumpWebView = cc.load('ViewAdapter'):create()

ActivityJumpWebView.viewConfig = {
   'res/hallcocosstudio/activitycenter/activityjumpweb.csb',
    {
        bottomPanel = "Panel_Bottom",
        contentPanel = 'Panel_Content',
        backBtn = "Button_Back",
        forwardBtn = "Button_Forward",
        freshBtn = "Button_Fresh",
        closeBtn = "Button_Close"
    }
}

return ActivityJumpWebView