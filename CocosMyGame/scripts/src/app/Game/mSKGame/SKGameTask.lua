local SKGameTask                  = class("SKGameTask", ccui.Layout)
local TaskModel = import("src.app.plugins.MyTaskPlugin.TaskModel"):getInstance()
local taskObj = {}
local json = cc.load("json").json

local config = TaskModel:loadTaskConfig()

my.setmethods(SKGameTask, cc.load('coms').PropertyBinder)

function SKGameTask:create(gameController)
    self._gameController        = gameController
    self._curSel                = 1
    self._taskList              = nil
    self._taskNode              = nil
    self._taskPanel             = nil
    self._scorePanel            = nil
    self._noTaskPanel           = nil
    self._allTaskPanel          = nil
    self._action                = nil
    self._loading               = nil
    
    self._taskUnitPanel         = nil
    self._taskUnitHeight        = 0
    self._taskUnitWidth        = 0
    self._taskDetail            = {}
    self._taskListUnit          = {}
    self._btnUp                 = nil
    self._btnDown               = nil
    self._CanNotClose           = false

    local json = cc.load("json").json
	local tt = cc.FileUtils:getInstance():getStringFromFile("src/app/Game/mSKGame/TaskStrings.json")
	self.TaskJson = json.decode(tt)

    self:init()

    local curScene = cc.Director:getInstance():getRunningScene()
    curScene:addChild(self._taskNode)
    local visibleRect=cc.Director:getInstance():getOpenGLView():getVisibleRect()
    self._taskNode:setPosition(visibleRect.width/2, visibleRect.height/2)

    --���create����self._taskNode�е������⣬�����ò���SKGameTask��instance�������ֶ�������
    self._taskNode.ctrl = self

    return self._taskNode
end

function SKGameTask:init()
    local csbPath = "res/GameCocosStudio/csb/Node_Mission.csb"
    self._taskNode = cc.CSLoader:createNode(csbPath)
    if self._taskNode then
        self._taskNode:setVisible(true)
        if not tolua.isnull(self._taskNode) then
            local panelContent = self._taskNode:getChildByName("Panel_Main")
            panelContent:setVisible(true)
            panelContent:setScale(0.6)
            panelContent:setOpacity(255)
            local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
            local scaleTo2 = cc.ScaleTo:create(0.09, 1)

            local ani = cc.Sequence:create(scaleTo1, scaleTo2)
            panelContent:runAction(ani)
        end

        self._taskPanel = self._taskNode:getChildByName("Panel_Main")
        self._taskLoading = self._taskPanel:getChildByName("FileNode_1")
        if self._taskLoading then            
            local loadingPath = "res/GameCocosStudio/csb/Node_light.csb"
            self._action = cc.CSLoader:createTimeline(loadingPath)
            self._taskLoading:runAction(self._action)
            self._taskLoading:setVisible(true)
            self._action:play("animation_light", true)
        end 
    end
    if self._taskPanel then
        self._taskList      = ccui.Helper:seekWidgetByName(self._taskPanel, "List_MissionUnit")
        --self._taskDetalPanne = self._taskNode:getChildByName("Panel_mission_Detail")
        --self._taskDetalPanne:setVisible(false)
        
        --[[self._taskDetail    = {
            _title          = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "Text_mission_name"),
            _description    = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "Text_mission_detail"),
            _loadingBar1    = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "progress_mission"),
            _loadingValue1  = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "value_progress"),
            _rewardImg1     = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "icon_score"),
            _rewardValue1   = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "Text_1"),
            _collectBtn     = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "btn_reward"),
            _completeImg    = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "img_btn_rewarder"),
            _iconImg        = ccui.Helper:seekWidgetByName(self._taskDetalPanne, "img_mission_icon")
        }--]]
        --self._loading = self._taskPanel:getChildByName("Panel_animation"):getChildByName("Node_loading")
        --self._loading       = ccui.Helper:seekWidgetByName(self._taskPanel, "Node_loading")
        --local action        = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/Node_loading_S.csb")
        --self._loading:runAction(action)
        --action:play("animation_loading", true)
    end

    self:initButtons()
    self:_addListeners()
    self:createConnect()
end

function SKGameTask:_addListeners()
    self:listenTo(TaskModel, TaskModel.EVENT_MAP["taskModel_updateTaskList"], handler(self, self.updateTaskList))
    self:listenTo(TaskModel, TaskModel.EVENT_MAP["taskModel_taskRewardGot"], handler(self, self.onTaskRewardGot))
end

function SKGameTask:createConnect()
    TaskModel:loadTaskConfig()
    --HallTaskCtrl:createConnect(self)
    TaskModel:SendTaskDataReq(TaskModel.TaskDef.REQ_TYPE_ALL, 0)
end

function SKGameTask:initButtons()
    if not self._taskPanel then return end

    local function onClose()
        self:onClose()
    end
    local btnClose = ccui.Helper:seekWidgetByName(self._taskPanel, "Btn_Close")
    if btnClose then
        btnClose:addClickEventListener(onClose)
    end
    
    local function onBtnUp()
        self:onBtnUp()
    end
    self._btnUp = ccui.Helper:seekWidgetByName(self._taskPanel, "Btn_Left")
    if self._btnUp then
        self._btnUp:setVisible(false)
        self._btnUp:addClickEventListener(onBtnUp)
    end
    
    local function onBtnDown()
        self:onBtnDown()
    end
    self._btnDown = ccui.Helper:seekWidgetByName(self._taskPanel, "Btn_Right")
    if self._btnDown then
        self._btnDown:setVisible(false)
        self._btnDown:addClickEventListener(onBtnDown)
    end
end

function SKGameTask:updateTaskList()
--    if self._loading then
--        self._loading:setVisible(false)
--        self._loading:stopAllActions()
--    end

    taskObj = TaskModel:getTaskList()
    if 0 == #taskObj then
        if self._noTaskPanel then
            self._noTaskPanel:setVisible(true)
        end
        if self._allTaskPanel then
            self._allTaskPanel:setVisible(false)
        end
    else
        if self._noTaskPanel then
            self._noTaskPanel:setVisible(false)
        end
        if self._allTaskPanel then
            self._allTaskPanel:setVisible(true)
        end
        self._delayTimer = my.scheduleOnce(function()
            if self then
                self:refreshScrollView()
            end
        end,0.5)
    end
end

function SKGameTask:refreshScrollView()
    local count = #taskObj

    --[[if self._taskList then 
        self._taskList:removeAllChildren()
    end--]]

    local csbPath   = "res/GameCocosStudio/csb/Node_MissionBox.csb"
    self._taskUnitPanel = cc.CSLoader:createNode(csbPath):getChildByName("Panel_MissionBox")
    --增加判空处理防止为空报错
    if not self._taskUnitPanel then
      return
    end
    self._taskUnitHeight = self._taskUnitPanel.getContentSize() and self._taskUnitPanel:getContentSize().height
    self._taskUnitWidth =  self._taskUnitPanel.getContentSize and  self._taskUnitPanel:getContentSize().width
    local height = self._taskUnitHeight
    local width = self._taskUnitWidth
    local listHeight = height * count + 20
    local listWidth = width * count + 40
    --增加判空处理防止为空报错
    if self._taskList then 
       local content   = self._taskList.getContentSize and self._taskList:getContentSize()
       listHeight = content.height
       if listWidth < content.width then
           listWidth = content.width
           self._taskList:setInnerContainerSize( content )
       else
           self._taskList:setInnerContainerSize(cc.size(listWidth, content.height))
       end
    end
   

    self._taskListUnit = {}
    for i, v in pairs(taskObj) do
        local node = self._taskList:getChildByTag(i)
        if node == nil then           
            node   = cc.CSLoader:createNode(csbPath)     
            self._taskList:addChild(node)         
        end
        local panel  = node:getChildByName("Panel_MissionBox")

        --[[local function onTaskList()
            self._gameController:playBtnPressedEffect()
            self:onTaskList(i)
        end
        self._taskListUnit[i] = {
            _btn = panel:getChildByName("btn_complete"),
            _bg  = panel:getChildByName("img_missionbg"),
            _txt = panel:getChildByName("Text_mission_name")
        }
        if self._taskListUnit[i]._btn then
            self._taskListUnit[i]._btn:setSwallowTouches(false)
            self._taskListUnit[i]._btn:addClickEventListener(onTaskList)
        end
        if self._taskListUnit[i]._txt then
            self._taskListUnit[i]._txt:setString(v._title)
        end--]]

        self:onTaskList(i, panel)

        node:setPosition(cc.p(width / 2 + (width + 10) * (i-1), listHeight / 2 ))
        node:setTag(i)
    end
    
    self._taskLoading:stopAllActions()
    self._taskLoading:setVisible(false)
    --self._taskDetalPanne:setVisible(true)
    self._btnUp:setVisible(true)
    self._btnDown:setVisible(true)
    --self:onTaskList(self._curSel)
end

function SKGameTask:onTaskRewardGot(data)
    if data and data.value then
        self:_playTaskAction(data.value["nMinValue"])
    end
end

function SKGameTask:_playTaskAction(minValue)
--    if self._action then
--        self._gameController:playCoinEffect()
--        self._action:play("animation_missionfinish", false)
--        local function callback(frame)
--            if "play_over" == frame:getEvent() then
--                self._action:clearFrameEventCallFunc()
--                
--            end
--        end
--        self._action:setFrameEventCallFunc(callback)
--    end
--    if self._scorePanel then
--        self._scorePanel:setVisible(true)
--    end
--    self._gameController:addSelfScore(minValue)

    --[[local csbPath = "res/GameCocosStudio/csb/Node_mission.csb"
    local action = cc.CSLoader:createTimeline(csbPath)
    local aniNode = self._taskNode:getChildByName("Panel_checkin_score")
    if aniNode and action then   
        aniNode:runAction(action)
        action:play("animation_mission_complete", false)
    end
    audio.playSound("res/Game/GameSound/PublicSound/Snd_Coin.ogg",false)--]]
    
    local drawIndex = self._gameController:getMyDrawIndex()
    --self._gameController:addPlayerScore(drawIndex, minValue)
    self._gameController:addPlayerDeposit(drawIndex, minValue)

    local user=mymodel('UserModel'):getInstance()
    if(user.nDeposit)then
        self._gameController._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
    end

    self:updateTaskList(true)  
end

function SKGameTask:onTaskList(index, node)

    
    self:setTaskDetail(index, node)

    --[[if not self._taskListUnit then return end

    for i, w in pairs(self._taskListUnit) do
        if index == i then
            printf("change task")
            w._bg:setVisible(true)
            self:setTaskDetail(index, node)
            self._curSel = index
        else
            w._bg:setVisible(false)
        end
    end--]]
end

function SKGameTask:setTaskDetail(index, node)
    local data = taskObj[index]

    if data then
        local title = node:getChildByName("Text_Mission")
        title:setString( data._description )
        --[[view._description:setString( data._description )
        view._iconImg:loadTexture(data._image)--]]
        local loadingBar = node:getChildByName("Panel_Progress"):getChildByName("LoadingBar_Mission")
        local loadingValue = node:getChildByName("Panel_Progress"):getChildByName("Value_Progress")
        for i, v in pairs(data._progress) do
            loadingBar:setPercent(v._value)
            loadingValue:setString(v._text)
        end
        local rewardValue = node:getChildByName("Value_Silver")

        local rewardValueNum = 0
        for i, v in pairs(data._reward) do
            --view["_rewardImg"..i]:loadTexture(v._image)
            rewardValue:setString(v._value..self.TaskJson.HLS_TASK_YINZI)
            rewardValueNum = v._value
        end

        local Btn_Claim = node:getChildByName("Btn_Claim")
        local Img_Claim = node:getChildByName("Img_Claim")

        if TaskModel.TaskDef.TASKDATA_FLAG_DOING == data._btnState then
            self:enableBtn(Btn_Claim, false)
            Img_Claim:setVisible(false)
        elseif TaskModel.TaskDef.TASKDATA_FLAG_CANGET_REWARD == data._btnState then
            self:enableBtn(Btn_Claim, true)
            Img_Claim:setVisible(false)
        elseif TaskModel.TaskDef.TASKDATA_FLAG_FINISHED == data._btnState then
            self:enableBtn(Btn_Claim, false)
            if not Img_Claim:isVisible() then
                Img_Claim:setVisible(true)
                local csbPath   = "res/GameCocosStudio/csb/Node_MissionBox.csb"
                local action = cc.CSLoader:createTimeline(csbPath)
                node:runAction(action)    
                action:gotoFrameAndPlay(1, 8, false)
                self._gameController:playGamePublicSound("chouma.mp3")
                self._gameController:OPE_ShowBombBonu(self._gameController:getMyChairNO(), rewardValueNum)

                if self._gameController.GameTaskList and self._gameController.GameTaskList[index] then
                    self._gameController.GameTaskList[index]._btnState = TaskModel.TaskDef.TASKDATA_FLAG_FINISHED
                end
            end
        end

        local function onFinishTask()
            if self._CanNotClose then
                return
            end
            self._gameController:playBtnPressedEffect()
            self:enableBtn(Btn_Claim, false)
            self:onFinishTask(data._groupID, data._taskID)        
        end
        Btn_Claim:addClickEventListener(onFinishTask)
    end
end

function SKGameTask:onFinishTask(groupID, taskID)
    TaskModel:SendTaskFinishReq(groupID, taskID)

    self._CanNotClose = true
    local function onFinishTaskTime(dt)
        self:onFinishTaskTime()
    end
    self.onFinishTaskTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onFinishTaskTime, 2, false)
end

function SKGameTask:onFinishTaskTime()
    self._CanNotClose = false
    if self.onFinishTaskTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onFinishTaskTimerID)
        self.onFinishTaskTimerID = nil
    end
end

function SKGameTask:enableBtn(btn, enable)
    if btn then
        btn:setBright(enable)
        btn:setTouchEnabled(enable)
    end
end

function SKGameTask:onClose()
    if self._CanNotClose then
        return
    end
    if self._delayTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._delayTimer)
        self._delayTimer = nil
    end

    --HallTaskCtrl:closeAssistConnect()
    self._gameController:playBtnPressedEffect()
    self._taskNode:setVisible(false)
    self._taskNode:removeAllChildren()

    self:removeEventHosts()

    --测试代码
    --[[my.scheduleOnce(function()
        TaskModel:dispatchEvent({name = TaskModel.EVENT_MAP["taskModel_updateTaskList"]})
    end, 3)]]--
end

function SKGameTask:onBtnDown()
    --[[local count = #taskObj
    self._curSel = self._curSel + 1
    if self._curSel > count then
        self._curSel = 1
        self._taskList:scrollToLeft(0.5, false)
    end
    if self._curSel > 3 then
        self._taskList:scrollToRight(0.5, false)
    end
    --self:onTaskList(self._curSel)--]]
    self._gameController:playBtnPressedEffect()
    self._taskList:scrollToRight(0.5, false)
end

function SKGameTask:onBtnUp()
    --[[local count = #taskObj
    self._curSel = self._curSel - 1
    if self._curSel == 0 then
        self._curSel = count
        self._taskList:scrollToRight(0.5, false)
    end
    if self._curSel < 4 then
        self._taskList:scrollToLeft(0.5, false)
    end
    --self:onTaskList(self._curSel)--]]
    self._gameController:playBtnPressedEffect()
    self._taskList:scrollToLeft(0.5, false)
end

function SKGameTask:containsTouchLocation(x, y)
    local b = false
    if self._taskPanel then
        local position = self._layerPosition
        local s = self._taskPanel:getContentSize()
        local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
        b = cc.rectContainsPoint(touchRect, cc.p(x, y))
    end
    return b
end

return SKGameTask
