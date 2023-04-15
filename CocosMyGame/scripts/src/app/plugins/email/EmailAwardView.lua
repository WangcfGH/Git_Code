local viewCreator = cc.load('ViewAdapter'):create()
local config      = import("src.app.HallConfig.EmailConfig")

viewCreator.viewConfig={
    "res/hallcocosstudio/hallcommon/itemunit.csb",
    {
        -- _option={prefix = 'Panel_Main.'},
        awardImage = "Img_Items",
        countText = "Text_Num",
        rewardedImage = "Img_Rewarded",
        awardImageOnline = "Img_Items_Web",
        imgBg1 = "Img_ItemsBG",
        imgBg2 = "Img_ItemsBG2",
    }
}

function viewCreator:onCreateView(viewNode, awardInfo)
    self:wrapViewNode(viewNode)

    viewNode:setAwardInfo(awardInfo)
end

function viewCreator:createViewNode(filename)
    local root = cc.CSLoader:createMyNode(filename)
    self._viewNode = root:getChildByName("Panel_Main")
    self._viewNode:removeFromParent()
	return self._viewNode
end

function viewCreator:_createViewIndexer(filename,exchMap)
	self._viewNode=my.NodeIndexer(self:createViewNode(filename),exchMap)
    self:_setActionCall()
	return self._viewNode
end

function viewCreator:wrapViewNode(viewNode)
    function viewNode:setAwardInfo(awardInfo)
        if type(awardInfo) == "table" and table.nums(awardInfo) > 0 then
            local itemTypeConfig = config.itemConfig[awardInfo.ItemTypeID] or {}
            if awardInfo.ItemTypeID == ItemType.HAPPYCOIN then
                --欢乐点要单独特殊处理，丑点也没办法了
                awardInfo = clone(awardInfo)
                awardInfo.ItemName = itemTypeConfig.title
                awardInfo.ItemCount = awardInfo.ItemCount/10
            end
            local localPath = itemTypeConfig.localPath
            local url       = awardInfo.ItemImageUrl
            if type(localPath) == "string" and string.len(localPath) > 0 then
                self:setAwardImage(localPath)
            end
            if type(url) == "string" and string.len(url) > 0 and itemTypeConfig.enableOnlineImg then
                self:setAwardImageByUrl(url)
            end

            self:setAwardCount(awardInfo.ItemCount)
            self:setAwardStatus(awardInfo.isRewarded)
        else
            self:setDefaultInfo()
        end
    end

    function viewNode:setDefaultInfo()
        self:setAwardImage(config.itemConfig.localPath)
        self:setAwardCount(0)
        self:setAwardStatus(false)
    end

    function viewNode:setAwardImage(path)
        self.awardImage:loadTexture(path)
        self.awardImage:show()
        self.awardImageOnline:hide()
    end

    function viewNode:setAwardImageByUrl(url)
        local bExit = false
        self.awardImageOnline:onNodeEvent("exit", function()
            bExit = true
        end)
        local thirdPartyImageCtrl = import('src.app.BaseModule.YQWImageCtrl')
        thirdPartyImageCtrl:getUserhuodongImage(url, function(code, path)
            if type(path) == "string" and string.len(path) > 0 then
                if not bExit then 
                    self.awardImageOnline:loadTexture(path)
                    self.awardImage:hide()
                    self.awardImageOnline:show()
                end
            end
        end)
    end

    function viewNode:setAwardCount(count)
        if type(count) == "number" and (count == 1 or count == 0) then
            self.countText:hide()
        else
            self.countText:show()
            self.countText:setString(string.format("×%s", tostring(count)))
        end
    end

    function viewNode:setAwardStatus(bRewarded)
        self.rewardedImage:setVisible(bRewarded)
    end

    function viewNode:switchBg(bgCode)
        local bShow1 = bgCode == 1 
        self.imgBg1:setVisible(bShow1)
        self.imgBg2:setVisible(not bShow1)
    end

    return viewNode
end

function viewCreator:wrapUserdataNode( node )
    self._viewNode = my.NodeIndexer(node, self.viewConfig[2])
    return self:wrapViewNode(self._viewNode)
end

return viewCreator