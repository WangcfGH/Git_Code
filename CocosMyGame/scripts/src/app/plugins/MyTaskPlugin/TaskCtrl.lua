
local TaskCtrl          = class('TaskCtrl', cc.load('SceneCtrl'))
local viewCreater       = import('src.app.plugins.MyTaskPlugin.TaskView')
local TaskNodeView      = import('src.app.plugins.MyTaskPlugin.TaskNodeView')

--local TaskModel.TaskDef         = import('src.app.plugins.AssistModel.TaskModel.TaskDef')
--local AssistConnect     = require('src.app.plugins.AssistModel.AssistConnect'):getInstance()
--local MainCtrl          = require('src.app.plugins.mainpanel.MainCtrl')
local ShareCtrl         = import('src.app.plugins.sharectrl.ShareCtrl')
local TaskModel = import("src.app.plugins.MyTaskPlugin.TaskModel"):getInstance()

--[[local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(AssistConnect,PropertyBinder)]]--

function TaskCtrl:onCreate( ... )
    local viewNode  = self:setViewIndexer(viewCreater:createViewIndexer())

    --viewNode.ScoreText:setVisible(false)
    self._scrollView = viewNode.ScrollView
    self:bindUserEventHandler(viewNode, {'closeBt'})
    TaskModel:loadTaskConfig()

    self:_addListeners()
    --self:onAutoSize()

    --[[my.scheduleOnce(function()
        self:showScoreRainWithPhysic()
    end, 3)]]-- 测试代码
end

function TaskCtrl:_addListeners()
    self:listenTo(ShareCtrl, ShareCtrl.SHARE_SUCCESS_RET, handler(self,self.UpdateTaskListEx))
    self:listenTo(TaskModel, TaskModel.EVENT_MAP["taskModel_updateTaskList"], handler(self, self.updateTaskList))
    self:listenTo(TaskModel, TaskModel.EVENT_MAP["taskModel_taskRewardGot"], handler(self, self.onTaskRewardGot))
end

function TaskCtrl:onEnter()
    --self:createConnect(self)
    TaskModel:SendTaskDataReq(TaskModel.TaskDef.REQ_TYPE_ALL, 0)

    if cc.exports._TCYGameGuide and cc.exports._tcyGameTaskParam == nil then
        --AssistConnect:sendGetTCYGameTask()
        --TaskModel:sendGetTCYGameTask()
    end
end

--接口，游戏中需要用到
--function TaskCtrl:createConnect(ctrl)
    --[[if nil ~= AssistConnect._client then
        self:closeAssistConnect()        
    end]]

    --[[AssistConnect:initTaskCtrl(ctrl)
    AssistConnect:createNetwork()
end]]--

--接口，游戏中需要用到
function TaskCtrl:updateTaskList()
    self:refreshScrollView(TaskModel:getTaskList())
end

function TaskCtrl:onTaskRewardGot(data)
    if data and data.value then
        self:_playTaskAction(data.value["minValue"])
    end
end

function TaskCtrl:_playTaskAction(minValue)
	self:updateTaskList()
    self:showScoreRainWithPhysic()
    audio.playSound('res/Game/GameSound/PublicSound/Snd_Coin.mp3', false)
end

function TaskCtrl:refreshScrollView(list)
    local count = #list

    if self._scrollView and tolua.isnull(self._scrollView:getRealNode()) then return end

    if self._scrollView then
        self._scrollView:removeAllChildren()
    end

    if cc.exports._TCYGameGuide and cc.exports._tcyGameTaskParam then
        count = count + 1
    end

    local height    = TaskNodeView.Height * count + 20
    local content   = self._scrollView:getContentSize()
    if height < content.height then
        height      = content.height
        self._scrollView:setInnerContainerSize( content )
    else
        self._scrollView:setInnerContainerSize(cc.size(content.width, height))
    end

    if cc.exports._TCYGameGuide and cc.exports._tcyGameTaskParam then
        local imagePath = TaskModel._taskConfig.ImagePath
        for i, v in pairs(TaskModel._taskConfig.Task) do
            if v.GroupID == 100 then
                local config = nil
                for j, w in pairs(v.TaskList) do
                    if 100 == w.ID then
                        config = w
                        break
                    end
                end
                local node  = cc.CSLoader:createNode(TaskNodeView.CsbPath)
                local view  = my.NodeIndexer(node, TaskNodeView.ViewConfig)

                view.TaskImage:loadTexture(imagePath..v.Image)
                view.TaskDescription:setString(config.Name)

                for j = 0, TaskModel.TaskDef.TASKDATA_FLAG_FINISHED do
                    view["TaskBtn"..j]:setVisible(false)
                end

                if cc.exports._tcyGameTaskParam.nTaskFlag == 1 then
                    view["TaskBtn1"]:setVisible(true)
                elseif cc.exports._tcyGameTaskParam.nTaskFlag == 2 then
                    view["TaskBtn2"]:setVisible(true)
                    view["TaskBtn2"]:setBright(false)
			        view["TaskBtn2"]:setTouchEnabled(false)
                elseif cc.exports._tcyGameTaskParam.nTaskFlag == 0 then
                    if cc.exports._TCYGameShowEntry == false then
                        view["TaskBtn0"]:setBright(false)
			            view["TaskBtn0"]:setTouchEnabled(false)
                    end
                    view["TaskBtn0"]:setVisible(true)
                    view["TaskBtn0"]:setTitleText(TaskModel._taskConfig.DonwLoadText)
                end
                local function onGoDonwloadGameTask()           
                    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/KeypressStandard.mp3'),false)
                    self:goDonwloadGameTask()
                end
                view.TaskBtn0:addClickEventListener(onGoDonwloadGameTask)
                local function onFinishTask()           
                    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/KeypressStandard.mp3'),false)
                    view.TaskBtn1:setBright(false)
                    view.TaskBtn1:setTouchEnabled(false)
                    self:onFinishTCYGameDonwloadTask()
                end
                view.TaskBtn1:addClickEventListener(onFinishTask)

                local value = 0
                if cc.exports._tcyGameTaskParam.nTaskFlag == 1 or cc.exports._tcyGameTaskParam.nTaskFlag == 2 then
                    value = 1
                end
                view["LoadingBar1"]:setPercent(value*100)
                view["LoadingValue1"]:setString(tostring(value).."/"..config.Condition[1].ConValue)

                view["RewardValue1"]:setString(TaskModel._taskConfig.Reward[config.Reward[1].RewardType].Text..config.Reward[1].RewardValueMin)

                node:setPosition(cc.p(52, height - TaskNodeView.Height *1)) 
                self._scrollView:addChild(node)
            end
        end
    end

    for i, v in pairs(list) do
        local node  = cc.CSLoader:createNode(TaskNodeView.CsbPath)
        local view  = my.NodeIndexer(node, TaskNodeView.ViewConfig)
        my.presetAllButton(node)

        view.TaskImage:loadTexture(v._image)
        view.TaskDescription:setString(v._description)

        --view.CheckImage:setVisible(false)
        for j = 0, TaskModel.TaskDef.TASKDATA_FLAG_FINISHED do
            view["TaskBtn"..j]:setVisible(false)
        end

        local taskBtn = view["TaskBtn"..v._btnState]
        if TaskModel.TaskDef.TASKDATA_FLAG_DOING == v._btnState then
            taskBtn:setVisible(true)
            taskBtn:setTitleText(TaskModel._taskConfig.MakeTaskText)
			if TaskModel.TaskDef.TASK_GAME_SHARE == v._nConType then
			    taskBtn:setTitleText(TaskModel._taskConfig.ShareText)
			end
        elseif TaskModel.TaskDef.TASKDATA_FLAG_CANGET_REWARD == v._btnState then
            taskBtn:setVisible(true)
            taskBtn:setBright(true)
            taskBtn:setTouchEnabled(true)
            --view.CheckImage:setVisible(true)
        elseif TaskModel.TaskDef.TASKDATA_FLAG_FINISHED == v._btnState then
            taskBtn:setVisible(true)
            taskBtn:setBright(false)
			taskBtn:setTouchEnabled(false)
        end

        local function onGoTask()           
             audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/KeypressStandard.mp3'),false)
             if TaskModel.TaskDef.TASK_GAME_SHARE == v._nConType then
                self:goShare()
            else
                self:goTask()
            end
        end
        view.TaskBtn0:addClickEventListener(onGoTask)
        local function onFinishTask()           
            audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/KeypressStandard.mp3'),false)
            view.TaskBtn1:setBright(false)
            view.TaskBtn1:setTouchEnabled(false)
            self:onFinishTask(v._groupID, v._taskID)
        end
        view.TaskBtn1:addClickEventListener(onFinishTask)

        for j, w in pairs(v._progress) do
            view["LoadingBar"..j]:setPercent(w._value)
            view["LoadingValue"..j]:setString(w._text)
        end
        for j, w in pairs(v._reward) do
            --view["RewardImage"..j]:loadTexture(w._image)
            view["RewardValue"..j]:setString(w._text..w._value)
        end
        if cc.exports._TCYGameGuide and cc.exports._tcyGameTaskParam then
            node:setPosition(cc.p(52, height - TaskNodeView.Height * (i+1)))
        else
            node:setPosition(cc.p(52, height - TaskNodeView.Height * (i)))
        end
        self._scrollView:addChild(node)
    end
end

function TaskCtrl:goDonwloadGameTask()
    my.dataLink(cc.exports.DataLinkCodeDef.TASK_GOTO_AD)
    my.informPluginByName({pluginName='AdvertisementCtrl', params ={gototype = 2} })
end

function TaskCtrl:onFinishTCYGameDonwloadTask()
    --AssistConnect:SendTCYGameDonwloadTaskFinishReq()
    TaskModel:SendTCYGameDonwloadTaskFinishReq()
end

function TaskCtrl:onFinishTask(groupID, taskID)
    --AssistConnect:SendTaskFinishReq(groupID, taskID)
    TaskModel:SendTaskFinishReq(groupID, taskID)
end

--[[function TaskCtrl:closeAssistConnect()
    self._taskData = {}
    self._taskParamData = {}
    if AssistConnect._client ~= nil then
        AssistConnect:closeNetwork()
    end
end]]--

-----------------------------------------
function TaskCtrl:goTask()
    local function quickStart(dt)
        --MainCtrl:quickStartBtClicked(nil)
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end
    my.scheduleOnce(quickStart, 0.5)
    self:goBack()
end

function TaskCtrl:goShare()
    ShareCtrl:loadShareConfig()
    ShareCtrl:shareToFriendsCornerClicked()
    --AssistConnect:SendChangeTaskParamReq(TaskModel.TaskDef.TASK_GAME_SHARE)
end

function TaskCtrl:goBack()
    --self:closeAssistConnect()
    --my.informPluginByName({params={message='remove'}})
	--require("src.app.plugins.roomspanel.RoomsCtrl"):playTipAni()

    my.informPluginByName({params = {message = 'remove'}})
end

function TaskCtrl:closeBtClicked()
    self:goBack()
end

function TaskCtrl:onKeyBack()
    self:goBack()
end


local visibleSize = cc.Director:getInstance():getVisibleSize()
local origin = cc.Director:getInstance():getVisibleOrigin()
cc.SpriteFrameCache:getInstance():addSpriteFrames("hallcocosstudio/images/plist/ScoreAniPic.plist")
function TaskCtrl:showScoreRainWithPhysic()

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
    local totalCount = math.floor(display.width / 80)
	for i=1,totalCount do
		basePosTable[i]=cc.p(start+(i-1)*80, origin.y+visibleSize.height-100)
	end

	for i=1,rowNum do
		local mask = 2^i
		for j,v in pairs(basePosTable)do
			local posX = v.x+math.random(4)*20
			local posY = v.y+(i-1)*100+math.random(3)*35
			TaskCtrl:createOneRain(physicLayer,cc.p(posX, origin.y+30), cc.p(posX, posY),mask)
		end
	end

end


function TaskCtrl:createOneRain(physicLayer,groudPos,rainPos,mask)

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

function TaskCtrl:UpdateTaskListEx()
    --AssistConnect:SendTaskDataReq(TaskModel.TaskDef.REQ_TYPE_ALL, 0)
    TaskModel:SendTaskDataReq(TaskModel.TaskDef.REQ_TYPE_ALL, 0)

    local function updatelist()
        print("TaskCtrl, updateList ....")
        self:updateTaskList()
    end
    my.scheduleOnce(updatelist, 1)
end


return TaskCtrl
