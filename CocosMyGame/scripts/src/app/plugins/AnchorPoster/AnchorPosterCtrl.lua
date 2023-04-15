local AnchorPosterCtrl 		= class('AnchorPosterCtrl', cc.load('SceneCtrl'))
local viewCreater 			= import('src.app.plugins.AnchorPoster.AnchorPosterView')
local AchorPosterNodeView 	= import('src.app.plugins.AnchorPoster.AnchorPosterNodeView')

-- 创建实例
function AnchorPosterCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

	self._scrollView = viewNode.scrollAnchors
    local params = {...}

    --self:initialListenTo()
    self:initialUI()
    self:initialBtnClick()
end

-- 注册监听
function AnchorPosterCtrl:initialListenTo()
end

-- 初始化界面
function AnchorPosterCtrl:initialUI()
    if self._viewNode == nil then return end
	
	self:refreshScrollView()
end

-- 注册点击事件
function AnchorPosterCtrl:initialBtnClick()
    local viewNode = self._viewNode    
    viewNode.btnClose:addClickEventListener(handler(self, self.onClickClose))
end

-- 刷新主播海报
function AnchorPosterCtrl:refreshScrollView()
	if self._scrollView and tolua.isnull(self._scrollView:getRealNode()) then return end

    if self._scrollView then
        self._scrollView:removeAllChildren()
    end

    local anchorPosterNum = cc.exports.getAnchorPosterNum()
	
	local width    = AchorPosterNodeView.Width * anchorPosterNum
    local content   = self._scrollView:getContentSize()
	if width < content.width then
        width      = content.width
        self._scrollView:setInnerContainerSize(content)
    else
        self._scrollView:setInnerContainerSize(cc.size(width, content.height))
    end

	if anchorPosterNum == 1 then
		for i=1, anchorPosterNum do
			local node  = cc.CSLoader:createNode(AchorPosterNodeView.CsbPath)
			local view  = my.NodeIndexer(node, AchorPosterNodeView.ViewConfig)
			my.presetAllButton(node)
			self:initItemInfo(view, i)
			node:setPosition(cc.p(600, 310)) 
			self._scrollView:addChild(node)
		end
	elseif anchorPosterNum == 2 then
		for i=1, anchorPosterNum do
			local node  = cc.CSLoader:createNode(AchorPosterNodeView.CsbPath)
			local view  = my.NodeIndexer(node, AchorPosterNodeView.ViewConfig)
			my.presetAllButton(node)
			self:initItemInfo(view, i)
			node:setPosition(cc.p(300 + (i - 1) * 600, 310)) 
			self._scrollView:addChild(node)
		end
	else
		for i=1, anchorPosterNum do
			local node  = cc.CSLoader:createNode(AchorPosterNodeView.CsbPath)
			local view  = my.NodeIndexer(node, AchorPosterNodeView.ViewConfig)
			my.presetAllButton(node)
			self:initItemInfo(view, i)
			node:setPosition(cc.p(200 + (i - 1) * AchorPosterNodeView.Width, 310)) 
			self._scrollView:addChild(node)
		end				
	end

	if anchorPosterNum <= 3 then
		self._scrollView:setBounceEnabled(false)
	else
		self._scrollView:setBounceEnabled(true)
	end
end

function AnchorPosterCtrl:initItemInfo(itemNode, index)
	local anchorPosterName = cc.exports.getAnchorPosterName()
	local anchorPosterTime = cc.exports.getAnchorPosterTime()
	local anchorPosterUrl = cc.exports.getAnchorPosterUrl()
	local anchorIDs = cc.exports.getAnchorRoomID()
	local wechatIDs = cc.exports.getAnchorWechatID()

	-- 设置主播名称
	itemNode.txtAnchorName:setString(anchorPosterName[index])
	-- 设置主播海报
	local url = anchorPosterUrl[index]
	local urlArr = string.split(url, '/')
	local fileName = urlArr[#urlArr]
	local filePath = my.getDataCachePath() .. fileName
	if(my.isCacheExist(fileName)) then
		itemNode.imgPoster:loadTexture(filePath, ccui.TextureResType.localType)
	else		
		local thirdPartyImageCtrl = require('src.app.BaseModule.YQWImageCtrl')
		thirdPartyImageCtrl:getUserhuodongImage(url, function(code, path)
			if code == cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess and not tolua.isnull(itemNode.imgPoster:getRealNode()) then
				itemNode.imgPoster:loadTexture(filePath, ccui.TextureResType.localType)
			else
				print("AnchorPosterCtrl:downloadCallback err url:".. url)
			end
		end)
	end
	-- 设置主播时间
	itemNode.txtAnchorTime:setString(anchorPosterTime[index])
	-- 设置主播号	
	my.fitStringInWidget(anchorIDs[index], itemNode.txtAchorID, 195)
	-- 设置主播微信号	
	my.fitStringInWidget(wechatIDs[index], itemNode.txtWechatID, 195)
	-- 绑定主播号复制按钮事件
    itemNode.btnCopyAnchorID:addClickEventListener(function()
		local copyAchorIDStr = anchorIDs[index]
		if copyAchorIDStr then
			DeviceUtils:getInstance():copyToClipboard(copyAchorIDStr)
			my.informPluginByName({pluginName='ToastPlugin',params={tipString="主播抖音号已复制",removeTime=1}})
		end
	end)
	-- 绑定主播微信号复制按钮事件
	itemNode.btnCopyWechatID:addClickEventListener(function()
		local copyWechatIDStr = wechatIDs[index]
		if copyWechatIDStr then
			DeviceUtils:getInstance():copyToClipboard(copyWechatIDStr)
			my.informPluginByName({pluginName='ToastPlugin',params={tipString="主播微信号已复制",removeTime=1}})
		end
	end)
end

function AnchorPosterCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()

    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:PopNextPlugin()
end

function AnchorPosterCtrl:goBack()
    if type(self._callback) == 'function' then
        self._callback()
    end
    AnchorPosterCtrl.super.removeSelf(self)
end

return AnchorPosterCtrl