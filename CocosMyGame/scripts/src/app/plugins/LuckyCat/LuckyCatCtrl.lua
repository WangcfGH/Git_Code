local LuckyCatCtrl      = class("LuckyCatCtrl", cc.load('BaseCtrl'))
local LuckyCatView      = import('src.app.plugins.LuckyCat.LuckyCatView')
local LuckyCatModel     = import("src.app.plugins.LuckyCat.LuckyCatModel"):getInstance()
local LuckyCatDef       = import('src.app.plugins.LuckyCat.LuckyCatDef')
local CenterCtrl        = require('src.app.BaseModule.CenterCtrl'):getInstance()
local PluginProcessModel= mymodel('hallext.PluginProcessModel'):getInstance()
local Def               = import("src.app.plugins.RewardTip.RewardTipDef")
local ShareCtrl         = import('src.app.plugins.sharectrl.ShareCtrl')

function LuckyCatCtrl:onCreate()
	local viewNode = self:setViewIndexer(LuckyCatView:createViewIndexer())
    self._viewNode = viewNode
    self._curSelect = LuckyCatDef.TAB_DAILY_TASK
    local pCallBack = {}
    table.insert(pCallBack, handler(self, self.onSelectDayTask))
    table.insert(pCallBack, handler(self, self.onSelectWelfareTask))
    self._viewNode:initTabs(#pCallBack, 1, pCallBack)
    
    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()
    LuckyCatModel:gc_GetLuckyCatInfo()
end

function LuckyCatCtrl:initialListenTo( )
    self:listenTo(LuckyCatModel, LuckyCatDef.LUCKYCATINFORET, handler(self,self.updateUI))
end

function LuckyCatCtrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.BtnClose:addClickEventListener(handler(self, self.onClickClose))
    viewNode.BtnHelp:addClickEventListener(handler(self, self.onClickHelp))
    viewNode.BtnUnlock:addClickEventListener(handler(self, self.onClickUnlock))
    viewNode.BtnUpdate:addClickEventListener(handler(self, self.onClickUnlock))


    viewNode.PanelDayTask:getChildByName("Panel_Gift1Detail"):setVisible(false)
    viewNode.PanelDayTask:getChildByName("Panel_Gift2Detail"):setVisible(false)
    viewNode.PanelDayTask:getChildByName("Panel_Gift3Detail"):setVisible(false)

    viewNode.PanelDayTask:getChildByName("Panel_Gift1"):getChildByName("Button_Box"):onTouch(function(e)
        self:freshGiftItem(e.name,1)
    end)

    viewNode.PanelDayTask:getChildByName("Panel_Gift2"):getChildByName("Button_Box"):onTouch(function(e)
        self:freshGiftItem(e.name,2)
    end)

    viewNode.PanelDayTask:getChildByName("Panel_Gift3"):getChildByName("Button_Box"):onTouch(function(e)
        self:freshGiftItem(e.name,3)
    end)
end

function LuckyCatCtrl:onClickUnlock()
    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    local driedFishNum = LuckyCatInfo.catData.driedFishNum
    local multiGrade = LuckyCatInfo.catData.multiGrade
    local driedFishTotalNum = (LuckyCatConfig.DriedCatUpgrade[1])[tostring(multiGrade+1)]

    if driedFishNum < driedFishTotalNum then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "您的小鱼干数量不足，先去收集小鱼干吧", removeTime = 3}})
    else
        LuckyCatModel:gc_LuckyCatUpgrade()
    end
end

function LuckyCatCtrl:freshGiftItem(event,index)
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    local viewNode = self._viewNode
    local NodeDetail = viewNode.PanelDayTask:getChildByName("Panel_Gift"..index.."Detail")

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    local taskGroup = LuckyCatConfig.BoxTask[1].TaskGroupList[1]  --配置列表
    if not self._BoxStatus[index] then return end
    if self._BoxStatus[index] == LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD then
        LuckyCatModel:gc_LuckyCatTaskPrizeTake(taskGroup.GroupID, taskGroup.TaskList[index].ID)
        --领奖处理
    else --触摸弹出预览
        if event == 'began' then
            NodeDetail:setVisible(true)
            local rewardList = {}
            local boxReward = LuckyCatConfig.BoxTask[1].TaskGroupList[1].TaskList[index].Reward
            if not boxReward then return end 

            for u, v in pairs (boxReward) do
                if v then
                    table.insert(rewardList,{nType = v.RewardType,nCount = v.RewardCount})
                end
            end
            self:freshGiftDetail(NodeDetail,rewardList)
        elseif event == 'cancelled' then
            NodeDetail:setVisible(false)
        elseif event == 'ended' then
            NodeDetail:setVisible(false)
        end
    end
end

function LuckyCatCtrl:onSelectDayTask()
    local viewNode = self._viewNode
    if not viewNode then return end 

    self._curSelect = LuckyCatDef.TAB_DAILY_TASK

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    viewNode.PanelWelfareTask:setVisible(false)
    viewNode.PanelDayTask:setVisible(true)
    self:freshGiftInfo()   --刷新每日宝箱信息
    self:freshDayTaskScrollView()
end

function LuckyCatCtrl:onSelectWelfareTask()
    local viewNode = self._viewNode
    if not viewNode then return end 

    self._curSelect = LuckyCatDef.TAB_WELFARE_TASK

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    viewNode.PanelWelfareTask:setVisible(true)
    viewNode.PanelDayTask:setVisible(false)
    self:freshWelfareTaskScrollView()

    -- 保存缓存
    local welfareClicked = self:getWelfareClicked()
    if welfareClicked ~= 1 then
        self:setWelfareClicked()
        viewNode.tabList:getChildByName("Btn_Tab2"):getChildByName("Node_TipAni"):setVisible(false)
        viewNode.tabList:getChildByName("Btn_Tab2"):getChildByName("Node_TipAni"):stopAllActions()
    end
end

function LuckyCatCtrl:freshDayTaskScrollView()
    local viewNode = self._viewNode
    if not viewNode then return end

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    --local taskGroupList = LuckyCatConfig.DailyTask[1].TaskGroupList
    local taskGroupList = LuckyCatModel:FillTaskData(LuckyCatDef.LUCKY_CAT_DAY)
    local nTaskCount = #taskGroupList
    if nTaskCount < 5 then
        viewNode.DayScrollInfo:setInnerContainerSize(cc.size(550, 400))
    else
        viewNode.DayScrollInfo:setInnerContainerSize(cc.size(400, 100*nTaskCount))
    end

    viewNode.DayScrollInfo:removeAllChildren()
    for i=1,nTaskCount do
        local nodeItem = cc.CSLoader:createNode(LuckyCatView.PATH_NODE_LUCKYCATITEM)
        local nodeAward = nodeItem:getChildByName("Panel_Item")
        nodeAward:retain()
        nodeAward:removeFromParent()
        self:scriptAwardItem(nodeAward,i,taskGroupList[i],false)
        if nTaskCount < 5 then
            nodeAward:setPosition(cc.p(275,440-100 * i))
        else
            nodeAward:setPosition(cc.p(275,100 *(nTaskCount-i)+40))
        end
        viewNode.DayScrollInfo:addChild(nodeAward)
        nodeAward:release()
    end
end

function LuckyCatCtrl:freshWelfareTaskScrollView()
    local viewNode = self._viewNode
    if not viewNode then return end

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    local taskGroupList = LuckyCatModel:FillTaskData(LuckyCatDef.LUCKY_CAT_WELFARE)
    local nTaskCount = #taskGroupList
    if nTaskCount < 5 then
        viewNode.WelfareScrollInfo:setInnerContainerSize(cc.size(550, 530))
    else
        viewNode.WelfareScrollInfo:setInnerContainerSize(cc.size(400, 100*nTaskCount))
    end

    viewNode.WelfareScrollInfo:removeAllChildren()
    for i=1,nTaskCount do
        local nodeItem = cc.CSLoader:createNode(LuckyCatView.PATH_NODE_LUCKYCATITEM)
        local nodeAward = nodeItem:getChildByName("Panel_Item")
        nodeAward:retain()
        nodeAward:removeFromParent()
        self:scriptAwardItem(nodeAward,i,taskGroupList[i],false)
        if nTaskCount < 5 then
            nodeAward:setPosition(cc.p(275,570-100 * i))
        else
            nodeAward:setPosition(cc.p(275,100 *(nTaskCount-i)+40))
        end
        viewNode.WelfareScrollInfo:addChild(nodeAward)
        nodeAward:release()
    end
end

function LuckyCatCtrl:scriptAwardItem(nodeAward, nIndex, nTaskDetail,iconStatus)
    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    if tolua.isnull(nodeAward) then return end

    --刷新信息
    nodeAward:getChildByName("Fnt_Num"):setString("x"..nTaskDetail._rewardCount)
    nodeAward:getChildByName("Text_Title"):setString(nTaskDetail._description)
    nodeAward:getChildByName("Button_Task"):setTouchEnabled(true)
    if nTaskDetail._btnState == LuckyCatDef.TASKDATA_FLAG_DOING then
        nodeAward:getChildByName("Button_Task"):loadTextureNormal("hallcocosstudio/images/plist/LuckyCat/LuckyCat_btn_qw.png",ccui.TextureResType.plistType)
        nodeAward:getChildByName("Button_Task"):loadTexturePressed("hallcocosstudio/images/plist/LuckyCat/LuckyCat_btn_qw.png",ccui.TextureResType.plistType)
    elseif nTaskDetail._btnState == LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD then
        nodeAward:getChildByName("Button_Task"):loadTextureNormal("hallcocosstudio/images/plist/LuckyCat/LuckyCat_btn_lq.png",ccui.TextureResType.plistType)
        nodeAward:getChildByName("Button_Task"):loadTexturePressed("hallcocosstudio/images/plist/LuckyCat/LuckyCat_btn_lq.png",ccui.TextureResType.plistType)
    elseif nTaskDetail._btnState == LuckyCatDef.TASKDATA_FLAG_FINISHED then
        nodeAward:getChildByName("Button_Task"):setTouchEnabled(false)
        nodeAward:getChildByName("Button_Task"):loadTextureNormal("hallcocosstudio/images/plist/LuckyCat/LuckyCat_Completed.png",ccui.TextureResType.plistType)
        nodeAward:getChildByName("Button_Task"):loadTexturePressed("hallcocosstudio/images/plist/LuckyCat/LuckyCat_Completed.png",ccui.TextureResType.plistType)
    end
    nodeAward:getChildByName("Panel_Progress"):getChildByName("LoadingBar"):setPercent(nTaskDetail._progress[1]._value)
    nodeAward:getChildByName("Panel_Progress"):getChildByName("Text_Progress"):setString(nTaskDetail._progress[1]._text)

    local function callback()
        print("1111111111")
        self:goToTask(nTaskDetail)
    end
    nodeAward:getChildByName("Button_Task"):addClickEventListener(callback)
end

function LuckyCatCtrl:goToTask(nTaskDetail) 
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    if not LuckyCatInfo then return end

    local GAP_SCHEDULE = 0.5 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return
    end

    if nTaskDetail._btnState == LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD then
        LuckyCatModel:gc_LuckyCatTaskPrizeTake(nTaskDetail._groupID, nTaskDetail._taskID)
    elseif nTaskDetail._btnState == LuckyCatDef.TASKDATA_FLAG_DOING then
        if nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_HALL_SHARE then
            ShareCtrl:loadShareConfig()
            ShareCtrl:shareToFriendsCornerClicked(0)
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_HALL_EXCHANGE_LOTTERY then
            my.informPluginByName({pluginName='ActivityCenterCtrl',params = {moudleName='exchangelottery'}})
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_HALL_TAKE_GOLDSILVER_REWARD then
            my.informPluginByName({ pluginName = 'GoldSilverCtrl' })
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_GAME_USE_EXPRESSION 
            or nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_GAME_PLAY_FIRST
            or nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_GAME_PLAY_TONGHUASHUN
            or nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_WELFARE_GAME_WIN_TOTAL then  --快速开始
            
            --触发快速开始的逻辑
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_GAME_ROOM_CLASSIC then  --经典场
            --经典房
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["findScope"] = "classic"}})
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_GAME_ROOM_NOWASH then  --不洗牌
            --不洗牌房间
            local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
            if RoomListModel:checkAreaEntryAvail("noshuffle") == false then
                local tipString = "不洗牌场未解锁，建议前往经典场进行对局"
                my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
                return
            end
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["findScope"] = "noshuffle"}})
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_HALL_RECHARGE 
            or nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_WELFARE_HALL_RECHARGE_TOTAL then  --充值
            my.informPluginByName({pluginName = "ShopCtrl", params = {defaultPage = "silver"}})
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_WELFARE_HALL_REALNAME then  --实名认证
            local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
            userPlugin:realNameRegister()
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_GAME_ROOM_CLASSIC_MASTER then  --经典大师
            local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
            local roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsClassic)
            local nMasterRoomIndex = #roomInfoList
            if nMasterRoomIndex > 5 then
                nMasterRoomIndex = 5    -- 大师房在此列表中的index是5
            end
            local nMasterRoomID = roomInfoList[nMasterRoomIndex].nRoomID
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], value = {["targetRoomId"] = nMasterRoomID}})
            self:goBack()
        elseif nTaskDetail._taskType == LuckyCatDef.LUCKYCAT_TASK_DAILY_GAME_ROOM_NOWASH_MASTER then  --不洗牌大师
            local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
            local roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsNoShuffle)
            local nMasterRoomIndex = #roomInfoList
            if nMasterRoomIndex > 5 then
                nMasterRoomIndex = 5    -- 大师房在此列表中的index是5
            end
            local nMasterRoomID = roomInfoList[nMasterRoomIndex].nRoomID
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], value = {["targetRoomId"] = nMasterRoomID}})
            self:goBack()
        end
    end
end

function LuckyCatCtrl:freshFishInfo()
    local viewNode = self._viewNode
    if not viewNode then return end 

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    local driedFishNum = LuckyCatInfo.catData.driedFishNum
    local multiGrade = LuckyCatInfo.catData.multiGrade
    local multiGradeMax = LuckyCatConfig.DriedCatUpgradeMax
    local lockCount = LuckyCatInfo.divideNum
    local driedFishTotalNum = 0
    if multiGrade == multiGradeMax then
        driedFishTotalNum = (LuckyCatConfig.DriedCatUpgrade[1])[tostring(multiGrade)]
    else
        driedFishTotalNum = (LuckyCatConfig.DriedCatUpgrade[1])[tostring(multiGrade+1)]
    end
    viewNode.TxtSelfNum:setString(driedFishNum)
    viewNode.TxtTotalNum:setString("/"..driedFishTotalNum)

    viewNode.TxtMultip:setVisible(false)
    viewNode.BtnUnlock:setVisible(true)
    viewNode.TxtMultipFish:setVisible(false)
    if tonumber(multiGrade) > 0 then
        viewNode.BtnUnlock:setVisible(false)
        if multiGrade == multiGradeMax then
            viewNode.TxtMultipFish:setVisible(true)
            viewNode.ImgFish:setVisible(false)
            viewNode.TxtSelfNum:setVisible(false)
            viewNode.TxtTotalNum:setVisible(false)
            viewNode.TxtMultip:setVisible(false)
        else
            viewNode.TxtMultipFish:setVisible(false)
            viewNode.ImgFish:setVisible(true)
            viewNode.TxtSelfNum:setVisible(true)
            viewNode.TxtTotalNum:setVisible(true)
            viewNode.TxtMultip:setVisible(true)
            viewNode.TxtMultip:setString("X"..multiGrade + 1)
        end
    end

    viewNode.TxtLockCount:setVisible(false)
    if tonumber(multiGrade) > 0 and tonumber(lockCount) > 0 then
        viewNode.TxtLockCount:setVisible(true)
        viewNode.TxtLockCount:setString(string.format("已有%d人解锁瓜分资格", LuckyCatModel:getLockCount()))
    end

    local rewardType = LuckyCatConfig.LuckyCatReward[1].RewardType
    if tonumber(multiGrade) > 0 then
        viewNode.TextFishTips:setString("喂养小鱼干可提升奖励倍数，\n快去收集小鱼干吧")
    else
        if tonumber(rewardType) == LuckyCatDef.LUCKYCAT_REWARD_SILVER then
            viewNode.TextFishTips:setString("喂养小鱼干可解锁招财猫，\n瓜分10亿银两")
        else
            viewNode.TextFishTips:setString("喂养小鱼干可解锁招财猫，\n瓜分10万话费")
        end
    end

    if tonumber(rewardType) == LuckyCatDef.LUCKYCAT_REWARD_SILVER then
        viewNode.TextFishTips2:setString("喂养小鱼干\n可解锁招财猫,可\n参与瓜分十亿银两\n活动！")
        if tonumber(multiGrade) > 0 then
            --解锁之后升级
            viewNode.TextFishTips2:setString(string.format("奖励X%d", multiGrade))
            viewNode.ImgIcon:loadTexture("hallcocosstudio/images/plist/LuckyCat/LuckyCat_guanggao4.png",ccui.TextureResType.plistType)
        else
            viewNode.ImgIcon:loadTexture("hallcocosstudio/images/plist/LuckyCat/LuckyCat_guanggao2.png",ccui.TextureResType.plistType)
        end
    elseif tonumber(rewardType) == LuckyCatDef.LUCKYCAT_REWARD_EXCHANGE then
        --如果是用礼券
        viewNode.TextFishTips2:setString("喂养小鱼干\n可解锁招财猫,可\n参与瓜分十万话费\n活动！")
        if tonumber(multiGrade) > 0 then
            --升级礼券
            viewNode.TextFishTips2:setString(string.format("奖励X%d", multiGrade))
            viewNode.ImgIcon:loadTexture("hallcocosstudio/images/plist/LuckyCat/LuckyCat_guanggao3.png",ccui.TextureResType.plistType)
        else
            viewNode.ImgIcon:loadTexture("hallcocosstudio/images/plist/LuckyCat/LuckyCat_guanggao1.png",ccui.TextureResType.plistType)
        end
    end

    viewNode.PanelFishBtn:stopAllActions()
    if driedFishNum < driedFishTotalNum then
        viewNode.TxtSelfNum:setColor(cc.c3b(255,0,0))
    elseif driedFishNum >= driedFishTotalNum and multiGrade < multiGradeMax then
        local aniFish = cc.CSLoader:createTimeline('res/hallcocosstudio/LuckyCat/LuckyCat.csb')
        viewNode.PanelFishBtn:runAction(aniFish)
        aniFish:play("ani_fish", true)
        viewNode.TxtSelfNum:setColor(cc.c3b(33,216,33))
    end

    if tonumber(multiGrade) >= tonumber(multiGradeMax) then
        viewNode.BtnUpdate:setTouchEnabled(false)
    else
        viewNode.BtnUpdate:setTouchEnabled(true)
    end
end

function LuckyCatCtrl:freshImgRedDot()
    local viewNode = self._viewNode
    if not viewNode then return end 
    viewNode.tabList:getChildByName("Btn_Tab1"):getChildByName("Img_Dot"):setVisible(false)
    viewNode.tabList:getChildByName("Btn_Tab2"):getChildByName("Img_Dot"):setVisible(false)

    if LuckyCatModel:isDayTaskNeedReddot() then
        viewNode.tabList:getChildByName("Btn_Tab1"):getChildByName("Img_Dot"):setVisible(true)
    end

    if LuckyCatModel:isWelfareTaskNeedReddot() then
        viewNode.tabList:getChildByName("Btn_Tab2"):getChildByName("Img_Dot"):setVisible(true)
    end
end

function LuckyCatCtrl:freshGiftInfo()
    local viewNode = self._viewNode
    if not viewNode then return end 

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    local taskGroupList = LuckyCatModel:FillTaskData(LuckyCatDef.LUCKY_CAT_BOX)
    local nTaskDetail = taskGroupList[1]

    viewNode.PanelProgress:getChildByName("ProgressBar"):setPercent(nTaskDetail._amount*10)
    viewNode.PanelDayTask:getChildByName("Panel_Tips"):getChildByName("Text_Num"):setString(nTaskDetail._amount)

    --找到各个礼包的状态
    self._BoxStatus = {0,0,0}
    for i=1,3 do
        local nGroupID = LuckyCatConfig.BoxTask[1].TaskGroupList[1].GroupID
        local nID   = LuckyCatConfig.BoxTask[1].TaskGroupList[1].TaskList[i].ID
        local nData = LuckyCatModel:getFlagByGroupID(nGroupID,nID)
        local nConValue = LuckyCatConfig.BoxTask[1].TaskGroupList[1].TaskList[i].Condition[1].ConValue
        viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Text"):setVisible(true)
        viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Text"):setString(nConValue)
        if nData and nData.nFlag == 1 then
            self._BoxStatus[i] = LuckyCatDef.TASKDATA_FLAG_FINISHED
            viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Bg"):setVisible(false)
            viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Lock"):setVisible(false)
            viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Icon"):loadTexture("hallcocosstudio/images/plist/LuckyCat/LuckyCat_jdt_ys_bg_1.png",ccui.TextureResType.plistType)
            viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Status"):setVisible(true)
            viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Text"):setVisible(false)
        elseif not nData then
            if nTaskDetail._amount >= nConValue  then
                self._BoxStatus[i] = LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD
                viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Bg"):setVisible(true)
                viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Lock"):setVisible(false)
                viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Icon"):loadTexture("hallcocosstudio/images/plist/LuckyCat/LuckyCat_jdt_ys_bg_2.png",ccui.TextureResType.plistType)
                viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Status"):setVisible(false)
            elseif nTaskDetail._amount < nConValue then
                self._BoxStatus[i] = LuckyCatDef.TASKDATA_FLAG_DOING
                viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Bg"):setVisible(false)
                viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Lock"):setVisible(true)
                viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Icon"):loadTexture("hallcocosstudio/images/plist/LuckyCat/LuckyCat_jdt_ys_bg_1.png",ccui.TextureResType.plistType)
                viewNode.PanelDayTask:getChildByName("Panel_Gift"..i):getChildByName("Image_Status"):setVisible(false)
            end
        end
    end
end

function LuckyCatCtrl:freshActivityTime()
    local viewNode = self._viewNode
    if not viewNode then return end

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    local strBeginDate = string.format("%d",math.floor((LuckyCatConfig.StartTime %10000) /100)) .. "月" .. string.format("%d", math.floor(LuckyCatConfig.StartTime %100)) .."日"
    local strEndDate = string.format("%d",math.floor((LuckyCatConfig.TaskEndTime %10000) /100)) .. "月" .. string.format("%d", math.floor(LuckyCatConfig.TaskEndTime%100)) .."日"

    viewNode.TextTips:setString("活动时间："..strBeginDate.."-"..strEndDate)
end

function LuckyCatCtrl:updateUI()
    local viewNode = self._viewNode
    if not viewNode then return end
    
    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    if self._curSelect == LuckyCatDef.TAB_DAILY_TASK then
        self:onSelectDayTask()
    else
        self:onSelectWelfareTask() 
    end
    self:freshActivityTime()
    self:freshFishInfo()
    self:freshImgRedDot()
    self:playAnimation()
end

function LuckyCatCtrl:goBack()
    LuckyCatCtrl.super.removeSelf(self)
end

function LuckyCatCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()
end

function LuckyCatCtrl:onKeyBack()
    self:goBack()
end

function LuckyCatCtrl:onClickBtnShop( )
    my.playClickBtnSound()
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end

    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return
    end

    my.informPluginByName({pluginName = "ShopCtrl", params = {defaultPage = "silver"}})
end

function LuckyCatCtrl:onClickBtnDayGift( )
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    if LuckyCatInfo.dailyGiftBagStatus == LuckyCatDef.NOBILITY_PRIVILEGE_UNTAKE then
        LuckyCatModel:gc_LuckyCatDailyGiftBagTake()
    end
end

function LuckyCatCtrl:onClickBtnWeekGift( )
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    if LuckyCatInfo.dailyGiftBagStatus == LuckyCatDef.NOBILITY_PRIVILEGE_UNTAKE then
        LuckyCatModel:gc_LuckyCatDailyGiftBagTake()
    end
end

function LuckyCatCtrl:onClickBtnMonthGift( )
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    if LuckyCatInfo.dailyGiftBagStatus == LuckyCatDef.NOBILITY_PRIVILEGE_UNTAKE then
        LuckyCatModel:gc_LuckyCatDailyGiftBagTake()
    end
end

function LuckyCatCtrl:playAnimation()
    local viewNode = self._viewNode

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    if not self._BoxStatus then return end 
    --礼包动画
    for i=1,3 do
        local aniFile = "res/hallcocosstudio/NobilityPrivilege/kelingqu.csb"
        local aniNode = self._viewNode.PanelDayTask:getChildByName("Ani_Gift"..i)
        aniNode:stopAllActions()
        aniNode:setVisible(false)
        if self._BoxStatus[i] == LuckyCatDef.TASKDATA_FLAG_CANGET_REWARD then
            aniNode:setVisible(true)
            local action = cc.CSLoader:createTimeline(aniFile)
            if not tolua.isnull(action) then
                aniNode:runAction(action)
                action:play("animation0", true)
            end
        end
    end

    -- 播放招财猫提示动画
    viewNode.PanelBubble:stopAllActions()
    local time = 0.3
    local scaleto1 = cc.ScaleTo:create(time, 0.9, 0.9)
    local scaleto2 = cc.ScaleTo:create(time, 1.1, 1.1)
    local scaleto3 = cc.ScaleTo:create(time, 1, 1)
    local actMoveBy1 = cc.MoveBy:create(time, cc.p(0, 10))
    local actMoveBy2 = cc.MoveBy:create(time, cc.p(0, -10))
    local delayAction     = cc.DelayTime:create(3)  
    --序列
    local sequenceAction  = cc.Sequence:create(scaleto1, scaleto2, scaleto1, scaleto2, scaleto3, actMoveBy1,actMoveBy2, actMoveBy1,actMoveBy2, delayAction)
    --重复
    local repeatForever = cc.RepeatForever:create(sequenceAction)
    viewNode.PanelBubble:runAction(repeatForever)

    -- 播放福利任务提示动画  
    viewNode.tabList:getChildByName("Btn_Tab2"):getChildByName("Node_TipAni"):setVisible(false)  
    viewNode.tabList:getChildByName("Btn_Tab2"):getChildByName("Node_TipAni"):stopAllActions()
    local welfareClicked = self:getWelfareClicked()
    if welfareClicked ~= 1 then
        viewNode.tabList:getChildByName("Btn_Tab2"):getChildByName("Node_TipAni"):setVisible(true)
        local aniTip = cc.CSLoader:createTimeline('res/hallcocosstudio/LuckyCat/LuckyTipAni.csb')
        viewNode.tabList:getChildByName("Btn_Tab2"):getChildByName("Node_TipAni"):runAction(aniTip)
        aniTip:play("tip_ani", true)
    end
end

function LuckyCatCtrl:freshGiftDetail(NodeDetail,rewardList)
     local viewNode = self._viewNode
    if type(rewardList)~='table' then return end
    local index = 1
    local function showNodeItem()
        local itemCount = #rewardList
        local item = rewardList[index]
        local imgPath = self:GetItemFilePath(item)
        local node = NodeDetail:getChildByName("Node_"..index)
        node:getChildByName("Panel_Main"):getChildByName("Img_Item"):loadTexture(imgPath, ccui.TextureResType.plistType)
        node:getChildByName("Panel_Main"):getChildByName("Fnt_Num"):setString(item.nCount)

        node:getChildByName("Panel_Main"):getChildByName("Image_1"):setVisible(false)

        local aniNode = node:getChildByName("Panel_Main"):getChildByName("Ani_Effect")
        aniNode:stopAllActions()
        aniNode:setVisible(false)
        index = index + 1
    end

    local itemCount = #rewardList
    if itemCount == 0 then return end
    for i = 1, itemCount do
        showNodeItem()
    end

    for i = 2, 5 do
        NodeDetail:getChildByName("Sprite_SepLine"..(i - 1)):setVisible(true)
        NodeDetail:getChildByName("Node_"..i):setVisible(true)
    end

    if itemCount + 1 <= 5 then
        for i = itemCount + 1, 5 do
            NodeDetail:getChildByName("Sprite_SepLine"..(i - 1)):setVisible(false)
            NodeDetail:getChildByName("Node_"..i):setVisible(false)
        end
    end
    local newBkWidth = 600 - 120 * (5 - itemCount)
    NodeDetail:getChildByName("Image_Bk"):setContentSize(cc.size(newBkWidth, 136))
end

function LuckyCatCtrl:GetItemFilePath(item)
    local dir = "hallcocosstudio/images/plist/RewardCtrl/"
    local path = nil

    local nType = item.nType
    local nCount = item.nCount

    if nType == Def.TYPE_SILVER then --银子
        if nCount>=10000 then 
            path = dir .. "Img_Silver4.png"
        elseif nCount>=5000 then
            path = dir .. "Img_Silver3.png"
        elseif nCount>=1000 then
            path = dir .. "Img_Silver2.png"
        else
            path = dir .. "Img_Silver1.png"
        end
    elseif nType == Def.TYPE_TICKET then --礼券
        if nCount>=100 then 
            path = dir .. "Img_Ticket4.png"
        elseif nCount>=50 then
            path = dir .. "Img_Ticket3.png"
        elseif nCount>=20 then
            path = dir .. "Img_Ticket2.png"
        else
            path = dir .. "Img_Ticket1.png"
        end
    elseif nType == Def.TYPE_CARDMARKER_1D then --1d记牌器
        path = dir .. "1tian.png"
    elseif nType == Def.TYPE_CARDMARKER_7D then --7d记牌器
        path = dir .. "7tian.png"
    elseif nType == Def.TYPE_CARDMARKER_30D then --30d记牌器
        path = dir .. "30tian.png"
    elseif nType == Def.TYPE_ROSE then --玫瑰
        path = dir .. "Img_Rose.png"
    elseif nType == Def.TYPE_LIGHTING then --闪电
        path = dir .. "Img_Lighting.png"
    elseif nType == Def.TYPE_CARDMARKER then
        path = dir .. "Img_CardMarker.png"
    elseif nType == Def.TYPE_PROP_LIANSHENG then
        path = dir .. "Img_Prop_Liansheng.png"
    elseif nType == Def.TYPE_PROP_JIACHENG then
        path = dir .. "Img_Prop_Jiacheng.png"
    elseif nType == Def.TYPE_PROP_BAOXIAN then
        path = dir .. "Img_Prop_Baoxian.png"
    elseif nType == Def.TYPE_RED_PACKET then --红包
        path = dir .. "Img_RedPacket_100.png"
    elseif nType == Def.TYPE_RED_PACKET_VOCHER then --红包礼券
        path = dir .. "Img_RedPacket_Vocher.png"
    elseif nType == Def.TYPE_REWARDTYPE_LOTTERY_TIME then --惊喜夺宝
        path = dir .. "Img_RewardType_Lottery.png"
    end
    return path
end

function LuckyCatCtrl:onClickHelp()
    my.informPluginByName({pluginName = "LuckyCatRuleCtrl"})
end

function LuckyCatCtrl:getWelfareClicked()
    return CacheModel:getCacheByKey("welfareClicked")
end

function LuckyCatCtrl:setWelfareClicked()
    CacheModel:saveInfoToCache("welfareClicked", 1)
end

return LuckyCatCtrl