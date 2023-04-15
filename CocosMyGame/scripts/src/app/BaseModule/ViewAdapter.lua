
local ViewAdapter=class('ViewAdapter')

function ViewAdapter:createViewIndexer(...)
	local viewNode=self.viewConfig and self:_createViewIndexer(unpack(self.viewConfig)) or {}
	if(self.onCreateView)then
		self:onCreateView(viewNode,...)
	end
	return viewNode
end

function ViewAdapter:createViewNode(filename)
	if(filename and filename:len()>0)then
		self._viewNode=cc.CSLoader:createMyNode(filename)	--:addTo(self)
        self:_tryPlayPopoutAni(filename)
	else
		self._viewNode=ccui.Widget:new()
	end
	if(DEBUG)then
		self._viewNode._hostname=self.__cname
	end

	return self._viewNode
end

function ViewAdapter:_createViewIndexer(filename,exchMap)
	self._viewNode=my.NodeIndexer(self:createViewNode(filename),exchMap)
    self:_setActionCall()
	self._viewNode:setContentSize(cc.Director:getInstance():getVisibleSize())
	ccui.Helper:doLayout(self._viewNode:getRealNode())
	self:_senseOperateLayerAndAutoAdapt(self._viewNode)
	return self._viewNode
end

--[Comment]
--注入runTimelineAction和gotoFrame函数 可以通过viewnode调用动画接口
function ViewAdapter:_setActionCall()
    self._viewNode.runTimelineAction = function(viewNode, actionName, bLoop, onFrameEvent)
        local fileName = unpack(self.viewConfig)
        local timeline = cc.CSLoader:createTimeline(fileName)
        self._viewNode:stopAllActions()
        self._viewNode:runAction(timeline)
        timeline:play(actionName, bLoop)
		if type(onFrameEvent) == "function" then
			timeline:setFrameEventCallFunc(onFrameEvent)
		end
	end
	self._viewNode.gotoFrame = function (viewNode, frame)
		local fileName = unpack(self.viewConfig)
		local timeline = cc.CSLoader:createTimeline(fileName)
		self._viewNode:runAction(timeline)
		timeline:gotoFrameAndPause(frame)
	end
end

--[Comment]
--指定名称为Opereate_Panel的认定为操作层，在大于等于2/1的屏幕上需要自动缩进
--注意：如果界面上有ScrollView，可能需要额外单独处理下子节点的自适应位置和缩放
--（因为ScrollView的内部容器能自适应放大不能自适应缩小，在刘海屏情况下会先放大再缩小，所以需要手动设置下setInnerConentSize）
local function zeroBezelNodeAutoAdapt(layout)
	local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local ratio = framesize.width / framesize.height
	if ratio >= 2 then
		if layout then
			layout:setContentSize(cc.size(display.size.width * (1280 - 80)/1280, display.height))
			ccui.Helper:doLayout(layout)
		end
	end
end

function ViewAdapter:_senseOperateLayerAndAutoAdapt(viewNode)
	local panelOperate = viewNode:getChildByName("Operate_Panel")
	if panelOperate then
		zeroBezelNodeAutoAdapt(panelOperate)
	end
end



--自定义功能
function ViewAdapter:setCtrl(ctrl)
    self._ctrl = ctrl
end

--播放弹出动画
function ViewAdapter:_tryPlayPopoutAni(csbFileName)
    if csbFileName == nil then return end
    local popupAniConfig = self.viewConfig["popupAni"]
    if popupAniConfig == nil or popupAniConfig["aniNode"] == nil then return end
    if popupAniConfig["isPlayAni"] ~= true then return end
    local panelContent = self._viewNode:getChildByName(popupAniConfig["aniNode"])
    if panelContent == nil then return end

    if popupAniConfig["aniName"] == "scaleandshake" then
		--由小到大缩放加抖动
		-- panelContent:setScale(0.1)
		-- panelContent:setOpacity(0)
		panelContent:setVisible(false)
		--异步防止卡顿
		my.scheduleOnce(function()
			if not tolua.isnull(panelContent) then
				panelContent:setVisible(true)
				panelContent:setScale(0.6)
				panelContent:setOpacity(255)
				local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
				local scaleTo2 = cc.ScaleTo:create(0.09, 1)

				local ani = cc.Sequence:create(scaleTo1, scaleTo2)
				panelContent:runAction(ani)
			end
		end,0)
        
		
		
        -- panelContent:setScale(0.01)
        -- panelContent:setOpacity(0)
        -- panelContent:setVisible(false)
        -- local a1 = cc.FadeTo:create(0.17, 255)
        -- local a2 = cc.ScaleTo:create(0.17, 1.2)
        -- local action1_spawn = cc.Spawn:create(a1, a2)
        -- local action2_scale = cc.ScaleTo:create(0.08, 0.95)
        -- local action3_scale = cc.ScaleTo:create(0.08, 1.0)
        -- panelContent:runAction(cc.Sequence:create(cc.Show:create(), action1_spawn, action2_scale, action3_scale))
    else
        --仅由小到大缩放
        panelContent:setScale(0.01)
        panelContent:setVisible(false)
        panelContent:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.25, 1.0)))
    end
end

cc.exports.zeroBezelNodeAutoAdapt = zeroBezelNodeAutoAdapt

cc.register('ViewAdapter',ViewAdapter)

return ViewAdapter
