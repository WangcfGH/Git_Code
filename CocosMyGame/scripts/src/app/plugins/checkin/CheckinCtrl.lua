
local CheckinNodeView = import('src.app.plugins.checkin.CheckinNodeView')
local CheckinCtrl=class('CheckinCtrl',cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.checkin.CheckinView')
local checkin=mymodel('hallext.CheckinActivity'):getInstance()

--local constStrings=cc.load('json').loader.loadFile('CheckinStrings.json')
local visibleSize = cc.Director:getInstance():getVisibleSize()
local origin = cc.Director:getInstance():getVisibleOrigin()

CheckinCtrl.LOGUI = 'Checkin'
CheckinCtrl.RUN_ENTERACTION = true

function CheckinCtrl:onCreate( ... )

	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())

	self:bindProperty(checkin,'Config',self,'CheckinStatu')
	self:bindProperty(checkin,'Data',self,'CheckinResult')
	self:bindDestroyButton(viewNode.closeBt)

end

function CheckinCtrl:runEnterAction()
    self._viewNode:runTimelineAction("animation_appear", false)
end

function CheckinCtrl:setCheckinStatu(params)
	if(type(params)~='table')then
		return
	end

	local viewNode=self._viewNode

	local dataList=params.dataList
	
	if(not dataList)then
	   return
	end
	if(table.maxn(dataList)==0)then
		return
	end

	local todayIndex=params.todayIndex
	local firstDay=params.firstDay

    if not params.isPeriod then
        -- has been checked.
        firstDay = firstDay - ( params.code == 4 and 1 or 0 )
    end

	local i=1
	local checkinTabList=viewNode.checkinTabList
	while(true)do
		local theNode=checkinTabList['checkinNode_'..i]
		if( (theNode==nil)or(dataList[i]==nil) )then
			break
		end
		CheckinNodeView.setStatu(theNode,dataList[i].statu or CheckinNodeView.NOT_CHECK_TODAY,dataList[i].type)
		CheckinNodeView.addSetRewardLableMethod(theNode,dataList[i].type)
		theNode:setRewardLable(dataList[i].reward or 0)
		CheckinNodeView.setCurTime(theNode,firstDay+i-1)
		CheckinNodeView:setRewardImage(theNode,dataList[i].reward or 0,dataList[i].type)
		i=i+1
	end

	self._nTodayIndex = todayIndex
	CheckinNodeView.onClick(checkinTabList['checkinNode_'..todayIndex],handler(self,self.onCheckinClicked))
end

function CheckinCtrl:onCheckinClicked(e)
	print('click checkin')
    my.playClickBtnSound()
	my.dataLink(cc.exports.DataLinkCodeDef.HALL_CHECKIN_TAKE_REWARD, {todayIndex = self._nTodayIndex or 0})
	self.curCheckinNode=e.curNode
	checkin:takeReward()
end

function CheckinCtrl:setCheckinResult(result)
	if(result==nil)then
		return
	end
	if(result.Status==checkin.Status.SUCCESS)then
		local theNode=self._viewNode.checkinTabList['checkinNode_'..self._nTodayIndex]
		CheckinNodeView.setStatu(theNode,CheckinNodeView.CHECKED_TODAY)
		if(result.type==1)then
			CheckinCtrl:showDepositeGain()
		else
			CheckinCtrl:showScoreRainWithPhysic()
		end
	else
        local netWorkStrings = cc.load('json').loader.loadFile('NetworkError')

        local message = result.Message or netWorkStrings['NET_ERROR_CHECKIN']

		self:informPluginByName('TipPlugin',{tipString=message, removeTime=1.5})
	end

end

function CheckinCtrl:showDepositeGain()
	local newScene = cc.Director:getInstance():getRunningScene()
	local physicLayer = cc.Layer:create()
	newScene:addChild(physicLayer,100)

	local csbPath = "res/hallcocosstudio/checkin/node_animation_score.csb"
	local node = cc.CSLoader:createNode(csbPath)
	if node then
		physicLayer:addChild(node)
		node:setPosition(cc.p(visibleSize.width/2-100, origin.y+visibleSize.height/2))
		local action = cc.CSLoader:createTimeline(csbPath)
		if action then
            audio.playSound("res/hall/sounds/Snd_Coin.mp3", false)
			node:runAction(action)
			action:gotoFrameAndPlay(0, 45, false)
		end
	end

end

cc.SpriteFrameCache:getInstance():addSpriteFrames("hallcocosstudio/images/plist/ScoreAniPic.plist")
function CheckinCtrl:showScoreRainWithPhysic()

	local newScene = cc.Director:getInstance():getRunningScene()
	local gravity = cc.vertex2F(0,-1000)
	newScene:getPhysicsWorld():setGravity(gravity)
--	newScene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
	local physicLayer = cc.Layer:create()
	newScene:addChild(physicLayer,100)
--[[	local node = cc.Node:create()
	local edge = cc.PhysicsBody:createEdgeBox(cc.size(visibleSize.width*4, visibleSize.height*10),cc.PhysicsMaterial(1, 1, 0),1)
	node:setPhysicsBody(edge)
	node:setPosition(visibleSize.width, 0)
	physicLayer:addChild(node)--]]

	local rowNum=4

	math.randomseed(os.time())
	local start=20
	local basePosTable={}
	for i=1,16 do
		basePosTable[i]=cc.p(start+(i-1)*80, origin.y+visibleSize.height-100)
	end

	for i=1,rowNum do
		local mask = 2^i
		for j,v in pairs(basePosTable)do
			local posX = v.x+math.random(4)*20
			local posY = v.y+(i-1)*100+math.random(3)*35
			CheckinCtrl:createOneRain(physicLayer,cc.p(posX, origin.y+30), cc.p(posX, posY),mask)
		end
	end

end


function CheckinCtrl:createOneRain(physicLayer,groudPos,rainPos,mask)

	local groundNode = cc.Sprite:create()
	physicLayer:addChild(groundNode)
	local ground = cc.PhysicsBody:createBox(cc.size(20, 20),cc.PhysicsMaterial(1, 1, 0))
	ground:setDynamic(true)
	ground:setGravityEnable(false)
	ground:setCategoryBitmask(mask)
	ground:setCollisionBitmask(mask)

	groundNode:setPhysicsBody(ground)
	groundNode:setPosition(groudPos)

	local rain = cc.Sprite:create()
	physicLayer:addChild(rain)
	local box = cc.PhysicsBody:createBox(cc.size(20, 20),cc.PhysicsMaterial(0.6+math.random(2)*0.1, 1.3+math.random(3)*0.1, 0))
	box:setDynamic(true)
	box:setVelocity( cc.p(0, -400-math.random(4)*20) )
	box:setGravityEnable(true)
	box:setCategoryBitmask(mask)
	box:setCollisionBitmask(mask)

	rain:setPhysicsBody(box)
	rain:setPosition(rainPos)

	local index=math.random(7)
	local list={}
	for i=1,7 do
		table.insert(list,index)
		index = index + 1
		if(index>7)then
			index=1
		end
	end

	local animation = cc.Animation:create()
	for i,v in pairs(list)do
		local path = "hallcocosstudio/images/plist/ScoreAniPic/score_coin_"
		path = path..""..v..".png"
        local coin = cc.SpriteFrameCache:getInstance():getSpriteFrame(path)
		animation:addSpriteFrame(coin)
	end
	animation:setDelayPerUnit(0.1)
	local action = cc.Animate:create(animation)
	local reAction = cc.Repeat:create(action,4)

	rain:runAction(cc.Sequence:create(reAction, cc.DelayTime:create(0.0), cc.CallFunc:create(function()
		rain:removeSelf()
		groundNode:removeSelf()
	end)))
end

return CheckinCtrl
