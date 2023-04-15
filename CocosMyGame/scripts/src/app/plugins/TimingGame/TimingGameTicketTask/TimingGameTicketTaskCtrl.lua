local TimingGameTicketTaskCtrl = class('TimingGameTicketTaskCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.TimingGame.TimingGameTicketTask.TimingGameTicketTaskView')
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local user = mymodel('UserModel'):getInstance()
local TimingGameDef = require('src.app.plugins.TimingGame.TimingGameDef')

local TIMING_GAME_TICKET_TASK_NUM = TimingGameDef.TIMING_GAME_TICKET_TASK_NUM

function TimingGameTicketTaskCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:bindSomeDestroyButtons(viewNode,{
		'btnClose',
    })

    local bindList={
		'btnToPlay',
	}
	
    self:bindUserEventHandler(self._viewNode,bindList)

    self:initListener()
    self:updateUI()
end

function TimingGameTicketTaskCtrl:initListener()
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getConfigFromSvr"], handler(self, self.updateUI))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getInfoDataFromSvr"], handler(self, self.updateUI))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_addGameBout"], handler(self, self.updateUI))
end

function TimingGameTicketTaskCtrl:updateUI()
    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    if not config or not infoData 
    or not config.GradeBoutObtainTickets
    or #config.GradeBoutObtainTickets ~= TIMING_GAME_TICKET_TASK_NUM
    or not infoData.gradeBoutNums then 
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return
    end

    self:updateLoadingBar(config, infoData)
    self:updateItems(config, infoData)
end

function TimingGameTicketTaskCtrl:updateLoadingBar(config, infoData)
    if not config or not infoData then return end

    local totalBouts = 0
    local curBouts = 0
    for i = 1, TIMING_GAME_TICKET_TASK_NUM do
        totalBouts = totalBouts + config.GradeBoutObtainTickets[i].MinBoutNum
        curBouts = curBouts + infoData.gradeBoutNums[i]
    end
    if curBouts > totalBouts then curBouts = totalBouts end
    local todayBoutTxt = self._viewNode.txtTodayBout
    if todayBoutTxt then
        todayBoutTxt:setString(curBouts)
    end
    local totalBoutTxt = self._viewNode.txtTotalBout
    if totalBoutTxt then
        totalBoutTxt:setString(string.format("/%d", totalBouts))
    end

    local loadingBar = self._viewNode.loadingBar
    local loadingBarSize = loadingBar:getContentSize()
    local maxWidth = 0
    local sumBout = 0
    for i = 1, TIMING_GAME_TICKET_TASK_NUM do
        local minBout = config.GradeBoutObtainTickets[i].MinBoutNum
        sumBout = sumBout + minBout
        local posX = sumBout / totalBouts * loadingBarSize.width
        local item = self._viewNode["loadingBarItem" .. i]
        if item then
            item:setPositionX(posX)  
            local size = item:getContentSize()
            if size.width > maxWidth then
                maxWidth = size.width
            end
            local txtBg = item:getChildByName("Img_TextBG")  
            if txtBg then
                local itemDesc = txtBg:getChildByName("Text_Desc")  
                if itemDesc then
                    itemDesc:setString(string.format("第%d局", sumBout))    
                end
            end
            local imgSuo = item:getChildByName("Img_Suo")
            local imgHasTaken = item:getChildByName("Img_HasTaken")
            local imgBox1 = item:getChildByName("Img_Reward")
            local imgBox2 = item:getChildByName("Img_Reward1")
            local imgNode = item:getChildByName("Img_Node")
            if infoData.gradeBoutNums[i] >= minBout then
                imgSuo:setVisible(false)
                imgBox1:setVisible(false)
                imgBox2:setVisible(true)
                imgHasTaken:setVisible(true)
                imgNode:loadTexture("hallcocosstudio/images/plist/TimingGameShop/jingdu_1.PNG", ccui.TextureResType.plistType)
            else
                imgSuo:setVisible(true)
                imgBox1:setVisible(true)
                imgBox2:setVisible(false)
                imgHasTaken:setVisible(false)
                imgNode:loadTexture("hallcocosstudio/images/plist/TimingGameShop/jingdu_2.PNG", ccui.TextureResType.plistType)
            end
        end
    end

    if maxWidth == 0 then
        return
    end
    local offset = 0
    for i = TIMING_GAME_TICKET_TASK_NUM - 1, 1, -1 do --调整下loadingBar上item的位置，防止挨得太近
        local itemLeft = self._viewNode["loadingBarItem" .. i]
        local itemRigth = self._viewNode["loadingBarItem" .. i + 1]
        local leftPos = itemLeft:getPositionX()
        local rigthPos = itemRigth:getPositionX()
        if rigthPos - leftPos < maxWidth + 10 then
            offset = offset + maxWidth + 10 - rigthPos + leftPos
        end
        itemLeft:setPositionX(leftPos - offset)
    end

    local percent = 0 --同时需要调整进度条
    local sumDistance = 0
    local leftPosX = 0
    local bouts = curBouts
    for i = 1, TIMING_GAME_TICKET_TASK_NUM do
        local minBout = config.GradeBoutObtainTickets[i].MinBoutNum
        local item = self._viewNode["loadingBarItem" .. i]
        local itemPosX = item:getPositionX()
        local diff = itemPosX - leftPosX
        leftPosX = itemPosX
        if bouts >= minBout then
            sumDistance = sumDistance + diff
            bouts = bouts - minBout
        else
            local dis = bouts / minBout * diff
            sumDistance = sumDistance + dis
            break
        end
    end
    percent = sumDistance / loadingBarSize.width
    loadingBar:setPercent(percent * 100)
end

--根据配置中不同的奖励（门票数量) ， 显示不同的图片(返回相应图片的路径）
--入参 config：model获得的服务端配置信息 Grade：指在配置信息数组里第几位
function TimingGameTicketTaskCtrl:showTicketsPng(config,Grade)
    if (Grade>4 or Grade<1) then
        return  hallcocosstudio/images/plist/TimingGameShop/g_img_piao_1.png
    end
    local  RewardTickets = config.GradeBoutObtainTickets[Grade].BoutExchangeTicketsNum
    if(RewardTickets>=1 and RewardTickets <=3) then
        return "hallcocosstudio/images/plist/TimingGameShop/g_img_piao_1.png"
    elseif(RewardTickets >3 and RewardTickets <=9) then
        return "hallcocosstudio/images/plist/TimingGameShop/g_img_piao_2.png"
    elseif(RewardTickets > 9) then
        return "hallcocosstudio/images/plist/TimingGameShop/g_img_piao_3.png"
    end

    return "hallcocosstudio/images/plist/TimingGameShop/g_img_piao_1.png"
end

--刷新界面
function TimingGameTicketTaskCtrl:updateItems(config, infoData)
    if not config or not infoData then return end
    local tblRooms = TimingGameModel:getTimingGameLowestGradeBoutTicketRoom()
    if #tblRooms ~= 4 then return end
    
    --获取门票的图片
    local imgTicketList = {
        "hallcocosstudio/images/plist/TimingGameShop/g_img_piao_3.png",
        "hallcocosstudio/images/plist/TimingGameShop/g_img_piao_2.png",
    }
    --获取宝箱的图片
    local imgBoxList = {
        "hallcocosstudio/images/plist/TimingGameShop/baoxiang1.png",
        "hallcocosstudio/images/plist/TimingGameShop/baoxiang2.png",
        "hallcocosstudio/images/plist/TimingGameShop/baoxiang3.png",
        "hallcocosstudio/images/plist/TimingGameShop/baoxiang4.png",
    }

    --设置标记，用于获取最小的那个未完成-------将其设置为进行中
    local MinNoFinish = 5;
    --对每个等级或者任务进行 对局数和要求对局数进行比较 判断是否完成
    for i = 1, TIMING_GAME_TICKET_TASK_NUM do
        --根据传入的字符，获取对应的cocos控件
        local panelItem = self._viewNode["panelItem" .. i]
        if panelItem then
            local title = panelItem:getChildByName("Text_Title")
            --获取要求的对局数
            local minBout = config.GradeBoutObtainTickets[i].MinBoutNum
            --获取当前的对局数
            local curBout = infoData.gradeBoutNums[i]
            if curBout > minBout then
                curBout = minBout
            end
            if title then
                local titleStr = string.format("%s以上(%d/%d)",tblRooms[i].gradeNameZh, curBout, minBout)
                title:setString(titleStr)
            end

            local txtReward = panelItem:getChildByName("Text_Reward")
            if txtReward then
                --该注释部分是对局送门票的界面由门票x？改成对应门票x配置对应数
                --[[
                local rewardStr = "门票x?"
                if curBout >= minBout then
                    rewardStr = string.format("门票x%d", config.GradeBoutObtainTickets[i].BoutExchangeTicketsNum)
                end
                ]]
                local rewardStr = string.format("门票x%d", config.GradeBoutObtainTickets[i].BoutExchangeTicketsNum)
                txtReward:setString(rewardStr)
            end

            local imgStatus = panelItem:getChildByName("Img_Status")
        
            if imgStatus then
                if curBout >= minBout then
                    --已完成 的状态图片
                    imgStatus:loadTexture("hallcocosstudio/images/plist/TimingGameShop/yilingqu2.png", ccui.TextureResType.plistType)
                else
                    --未完成 的状态图片
                    imgStatus:loadTexture("hallcocosstudio/images/plist/TimingGameShop/weiwancheng.PNG", ccui.TextureResType.plistType)
                    --获取 未完成 最小 的那张图片
                    if(i < MinNoFinish) then
                        MinNoFinish = i
                    end
                end
            end
            local imgPath = imgTicketList[1]
            if config.GradeBoutObtainTickets[i].BoutExchangeTicketsNum <= 3 then
                imgPath = imgTicketList[2]
            end
            local imgReward = panelItem:getChildByName("Img_Reward")
            if imgReward then

                --这注释部分的想法是在四个等级显示不同样式的宝箱，到达不同的要求后，宝箱变成门票
                --[[
                if curBout >= minBout then
                    imgReward:loadTexture(imgPath, ccui.TextureResType.plistType)
                else
                    imgReward:loadTexture(imgBoxList[i], ccui.TextureResType.plistType)
                end
                ]]

                --获取对应的上方控件，完成和未完成
                local RewardPanel = self._viewNode["loadingBarItem".. i]
                local Reward_noget = RewardPanel:getChildByName("Img_Reward1")
                local Reward_get = RewardPanel:getChildByName("Img_Reward")

                --根据服务端传入的配置信息，返回合适的图片路径
                local PngPatch = self:showTicketsPng(config,i)

                --显示图片
                imgReward:loadTexture(PngPatch, ccui.TextureResType.plistType)

                --显示上方的领取进度条的图片
                Reward_noget:loadTexture(PngPatch, ccui.TextureResType.plistType)
                Reward_get:loadTexture(PngPatch, ccui.TextureResType.plistType)
            end
        end
    end
    --在for循环结束时，把最大的未完成替换成正在进行
    if(MinNoFinish < 5) then
        --获取控件
        local newpanelItem = self._viewNode["panelItem" .. MinNoFinish]
        local newimgStatus = newpanelItem:getChildByName("Img_Status")
        --显示图片--进行中
        newimgStatus:loadTexture("hallcocosstudio/images/plist/TimingGameShop/doing.PNG", ccui.TextureResType.plistType)
    end
end

function TimingGameTicketTaskCtrl:isInClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

function TimingGameTicketTaskCtrl:isInit()
    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    if not config or not infoData 
    or not config.GradeBoutObtainTickets
    or #config.GradeBoutObtainTickets ~= TIMING_GAME_TICKET_TASK_NUM
    or not infoData.gradeBoutNums then 
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return false
    end
    return true
end

function TimingGameTicketTaskCtrl:btnToPlayClicked()
    if not self:isInit() then end
    if self:isInClickGap() then return end

    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    if not config or not infoData then return end

    local lowRoom, bAllDone = TimingGameModel:getTimingGameTicketRoom()
    -- if bAllDone then
    --     local tipString = "所有任务已完成~"
    --     my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
    --     return
    -- end

    if not my.isInGame() then
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        local nRoomID = lowRoom and lowRoom.nRoomID
        local findScope = "noshuffle"
        if lowRoom and not lowRoom.isNoShuffleRoom then
            findScope = "classic"
        end
        local fitRoom = RoomListModel:findFitRoomByDeposit(user.nDeposit, findScope, user.nSafeboxDeposit)
        if fitRoom and fitRoom.gradeIndex > lowRoom.gradeIndex then
            nRoomID = fitRoom.nRoomID
        end
        if lowRoom and not bAllDone then
            TimingGameModel:dispatchEvent({name = TimingGameModel.EVENT_MAP["timinggame_gotoGameByRoomID"], value = {["nRoomID"] = nRoomID}})
        else --快速开始
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["findScope"] = "noshuffle"}})
        end
    else
        local GamePublicInterface = cc.exports.GamePublicInterface
        local gameController =  GamePublicInterface._gameController
        local currentRoom = PUBLIC_INTERFACE.GetCurrentRoomInfo()
        if gameController and currentRoom and gameController:isGameRunning() then
            local tipString = "正在游戏中，请稍后再试~"
            my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        elseif gameController and currentRoom and not gameController:isGameRunning() then
            if (bAllDone or currentRoom.gradeIndex >= lowRoom.gradeIndex) and gameController:canRestart() then
                TimingGameModel:dispatchRestartGame()
            elseif currentRoom.gradeIndex >= lowRoom.gradeIndex and not gameController:canRestart() then
                local tipString = "正在游戏中，请稍后再试~"
                my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
            else
                gameController._gotoTimingGameTicketRoom = true
                gameController._baseGameConnect:gc_LeaveGame()
            end
        else
            local tipString = "服务异常，请稍后再试~"
            my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        end
    end
    
    self:goBack()
end

function TimingGameTicketTaskCtrl:goBack()
    TimingGameTicketTaskCtrl.super.removeSelf(self)
end

return TimingGameTicketTaskCtrl