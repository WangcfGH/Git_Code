
local BaseGameLoadingPanel = import("src.app.Game.mBaseGame.BaseGameLoadingPanel")
local MyGameLoadingPanel = class("MyGameLoadingPanel", BaseGameLoadingPanel)
local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()

function MyGameLoadingPanel:initLoadingPanel()
    UIHelper:recordRuntime("EnterGameScene", "MyGameLoadingPanel:initLoadingPanel begin")
    local csbPath = "res/GameCocosStudio/csb/Loading.csb"
    if self._gameController:isArenaPlayer() then
        csbPath = "res/GameCocosStudio/csb/Loading_Arena.csb"
    end
    self._loadingPanel = cc.CSLoader:createNode(csbPath)
    if self._loadingPanel then
        self:addChild(self._loadingPanel)
        self._loadingPanel:setAnchorPoint(0.5, 0.5)
        local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_Ani_Loading.csb")
        if action then
            self._loadingPanel:getChildByName("Node_TextLoaing"):runAction(action)
            action:play("Animation_Loading", true)
        end
    end
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	self._loadingPanel:setContentSize(visibleSize)
    ccui.Helper:doLayout(self._loadingPanel)
    self:setSpringFestivalView()
    UIHelper:recordRuntime("EnterGameScene", "MyGameLoadingPanel:initLoadingPanel end")
end

function MyGameLoadingPanel:setSpringFestivalView( )
    local imageLoadingBg = self._loadingPanel:getChildByName('Image_1')
    if imageLoadingBg then
        -- 春节换背景
        if SpringFestivalModel:showSpringFestivalView() then
            imageLoadingBg:loadTexture('res/Game/png/Start/Hall_StartBG_SpringFestival.jpg')

            -- 按比例先缩放下长宽再设置大小
            local visibleSize = cc.Director:getInstance():getVisibleSize()
            local bgSize = cc.size(1600, 1000)
            if visibleSize.height / visibleSize.width > bgSize.height / bgSize.width then
                bgSize.width = visibleSize.height * bgSize.width / bgSize.height
                bgSize.height = visibleSize.height
            else
                bgSize.height = visibleSize.width * bgSize.height / bgSize.width
                bgSize.width = visibleSize.width
            end
            imageLoadingBg:setContentSize(bgSize)
        end
    end
end

return MyGameLoadingPanel