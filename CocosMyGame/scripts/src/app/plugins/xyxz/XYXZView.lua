local XYXView = {}

local hintArray = {
    "切换炮弹威力会看到不一样的地图哦",
    "选择合适的角度至关重要",
    "后面几幅地图会有额外大奖哦"
}

function XYXView:getViewNode()      
    local viewNode          = cc.CSLoader:createNode("res/xyxz/public/apploading/AppLoading.csb")
    local nodeLoadingBar    = viewNode:getChildByName("Panel_Main"):getChildByName("Node_LoadingBar")
    local spriteBg          = nodeLoadingBar:getChildByName("Sprite_LoadingBarBg")
    viewNode.loadingPercent = spriteBg:getChildByName("Loading_Bar")
    viewNode.nodeBullet     = spriteBg:getChildByName("Node_Bullet")
    viewNode.textHint1      = spriteBg:getChildByName("Text_Hint1")
    viewNode.textHint2      = spriteBg:getChildByName("Text_Hint2")
    local size              = viewNode.loadingPercent:getContentSize()

    function viewNode:setPercent(percent)
        self.loadingPercent:setPercent(percent)
        self.nodeBullet:setPositionX( percent / 100 * size.width)
    end
    function viewNode:getPercent()
        return self.loadingPercent:getPercent()
    end
    local num = math.random(1, 3)
    viewNode.textHint1:setText(hintArray[num])
    viewNode.textHint2:setText('正在加载星球资源......')
    viewNode:setPercent(0)
	viewNode:setContentSize(cc.Director:getInstance():getVisibleSize())
	ccui.Helper:doLayout(viewNode)
    -- viewNode:setPosition(display.center)

    return viewNode
end

return XYXView