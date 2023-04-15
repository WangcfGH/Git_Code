local MainCtrlTest = class("MainCtrlTest")

local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local LimitTimeGiftModel = require("src.app.plugins.limitTimeGift.limitTimeGiftModel"):getInstance()

function MainCtrlTest:ctor(mainCtrl)
    self._mainCtrl = mainCtrl
end

--测试弹出限时礼包
function MainCtrlTest:testLimitTimeGift()
    LimitTimeGiftModel:__testLimitTimeGift(12)

    HallContext.context["roomContext"]["roomInfo"] = RoomListModel.roomsInfo[10035]
    self._mainCtrl:OnGetItemInfo(10035, 10000)
end

--测试大厅按钮没有红点
function MainCtrlTest:testHallBtnNoReddot()
    local mainCtrlView = self._mainCtrl._view
    local pluginViewData = mainCtrlView._pluginViewData
    for _, itemData in pairs(pluginViewData) do
        itemData["isNeedReddot"] = false
        mainCtrlView:refreshPluginBtnReddot(itemData)
    end
    mainCtrlView:refreshView(self._mainCtrl._viewNode)
end

--测试让所有大厅按钮不需要播放动画
function MainCtrlTest:testHallBtnNoAni()
    local mainCtrlView = self._mainCtrl._view
    local pluginViewData = mainCtrlView._pluginViewData
    for _, itemData in pairs(pluginViewData) do
        if itemData["btnAniType"] then
            if itemData["btnAniCondition"] == "onAvail" then
                itemData["isAvail"] = false
            elseif itemData["btnAniCondition"] == "onReddot" then
                itemData["isNeedReddot"] = false
            end
            mainCtrlView:refreshPluginBtnReddot(itemData)
        end
    end
    mainCtrlView:refreshView(self._mainCtrl._viewNode)
end

--把大厅所有插件按钮都显示出来
function MainCtrlTest:testHallBtnAllAvail()
    local mainCtrlView = self._mainCtrl._view
    local pluginViewData = mainCtrlView._pluginViewData
    for _, itemData in pairs(pluginViewData) do
        itemData["isAvail"] = true
    end
    mainCtrlView:refreshView(self._mainCtrl._viewNode)
end

--测试好友邀请组队
function MainCtrlTest:testFriendInvitation()
    local tcyFriendPluginWrapper = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()
    tcyFriendPluginWrapper:testInvitation()
end

function MainCtrlTest:testGameNodeCsb()
    local csbPath = "res/GameCocosStudio/csb/Node_Upgrade.csb"
    local csbNode = cc.CSLoader:createNode(csbPath)
    self._mainCtrl._viewNode:addChild(csbNode)
    csbNode:setPosition(display.center)
    csbNode:getChildByName("Panel_1"):setContentSize(display.size)

    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        csbNode:runAction(action)
        action:play("animation0", false)
    end
end

return MainCtrlTest