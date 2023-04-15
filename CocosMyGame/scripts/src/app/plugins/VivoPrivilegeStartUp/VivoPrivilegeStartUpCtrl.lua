local VivoPrivilegeStartUpCtrl = class('VivoPrivilegeStartUpCtrl', cc.load('SceneCtrl'))
local viewCreater = import('src.app.plugins.VivoPrivilegeStartUp.VivoPrivilegeStartUpView')
local VivoPrivilegeStartUpModel = import('src.app.plugins.VivoPrivilegeStartUp.VivoPrivilegeStartUpModel'):getInstance()
local VivoPrivilegeStartUpDef = require('src.app.plugins.VivoPrivilegeStartUp.VivoPrivilegeStartUpDef')
local json = cc.load("json").json
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()

-- 创建实例
function VivoPrivilegeStartUpCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    self._itemImg = {
        "hallcocosstudio/images/plist/vivoPrivilegeStartUp/Item_Silver.png",            --银子
        "hallcocosstudio/images/plist/vivoPrivilegeStartUp/Item_Exchange.png",          --兑换券
        "hallcocosstudio/images/plist/vivoPrivilegeStartUp/Item_Rose.png",              --玫瑰
        "hallcocosstudio/images/plist/vivoPrivilegeStartUp/Item_Lighting.png",          --闪电
        "hallcocosstudio/images/plist/vivoPrivilegeStartUp/Item_Card_Maker.png",        --记牌器
        "hallcocosstudio/images/plist/vivoPrivilegeStartUp/Item_Timinggame_Ticket.png", --门票
    }

    local params = {...}

    self:initialListenTo()
    self:initialUI()
    self:initialBtnClick()
end

-- 注册监听
function VivoPrivilegeStartUpCtrl:initialListenTo()
    self:listenTo(VivoPrivilegeStartUpModel, VivoPrivilegeStartUpDef.VIVO_PRIVILEGE_STARTUP_QUERY_STATE_RSP, handler(self,self.updateState))
end

-- 退出
function VivoPrivilegeStartUpCtrl:GetItemImgPath(rewardType, propID)
    if rewardType == VivoPrivilegeStartUpDef.REWARD_TYPE_SILVER then
        return self._itemImg[1]
    elseif rewardType == VivoPrivilegeStartUpDef.REWARD_TYPE_EXCHANGE then
        return self._itemImg[2]
    else
        if propID == VivoPrivilegeStartUpDef.REWARD_PROP_ID_EXPRESSION_ROSE then
            return self._itemImg[3]
        elseif propID == VivoPrivilegeStartUpDef.REWARD_PROP_ID_EXPRESSION_LIGHTNING then
            return self._itemImg[4]
        elseif propID == VivoPrivilegeStartUpDef.REWARD_PROP_ID_ONEBOUT_CARDMARKER then
            return self._itemImg[5]
        elseif propID == VivoPrivilegeStartUpDef.REWARD_PROP_ID_TIMING_GAME_TICKET then
            return self._itemImg[6]
        end
    end
end

-- 初始化界面
function VivoPrivilegeStartUpCtrl:initialUI()
    if self._viewNode == nil then return end

    local viewNode = self._viewNode
    local config = VivoPrivilegeStartUpModel:getConfig()
    local state = VivoPrivilegeStartUpModel:getState()

    viewNode.btnStartUp:setVisible(false)
    viewNode.btnReceive:setVisible(true)
    viewNode.btnReceive:setTouchEnabled(true)
    viewNode.btnReceived:setVisible(false)

    if state == VivoPrivilegeStartUpDef.VIVO_PRIVILEGE_STARTUP_REWARDED then
        -- 已领取
        viewNode.btnStartUp:setVisible(false)
        viewNode.btnReceive:setVisible(false)
        viewNode.btnReceived:setVisible(true)
        viewNode.btnReceived:setTouchEnabled(false)
    else
        -- 未领取
        local lauchParam = BusinessUtils:getInstance():getLaunchParamInfo()
        if lauchParam and lauchParam.extra and lauchParam.extra ~= "" then
            local extra = json.decode(lauchParam.extra) or {}
            if extra["fromPackage"] and extra["fromPackage"] == "com.vivo.game" then
                viewNode.btnStartUp:setVisible(false)
                viewNode.btnReceive:setVisible(true)
                viewNode.btnReceive:setTouchEnabled(true)
                viewNode.btnReceived:setVisible(false)
            else
                viewNode.btnStartUp:setVisible(true)
                viewNode.btnStartUp:setTouchEnabled(true)
                viewNode.btnReceive:setVisible(false)
                viewNode.btnReceived:setVisible(false)
            end
        end
    end

    local rewardDesc = config["Reward"][1]["RewardDesc"]
    local rewardType = config["Reward"][1]["RewardType"]
    local PropID = config["Reward"][1]["PropID"]
    local rewardNum = config["Reward"][1]["RewardNum"]
    local itemImgPath = self:GetItemImgPath(rewardType, PropID)
    viewNode.itemImg1:loadTexture(itemImgPath, ccui.TextureResType.plistType)
    viewNode.itemText1:setString(string.format(rewardDesc, rewardNum))

    rewardDesc = config["Reward"][2]["RewardDesc"]
    rewardType = config["Reward"][2]["RewardType"]
    PropID = config["Reward"][2]["PropID"]
    rewardNum = config["Reward"][2]["RewardNum"]
    itemImgPath = self:GetItemImgPath(rewardType, PropID)
    viewNode.itemImg2:loadTexture(itemImgPath, ccui.TextureResType.plistType)
    viewNode.itemText2:setString(string.format(rewardDesc, rewardNum))

    rewardDesc = config["Reward"][3]["RewardDesc"]
    rewardType = config["Reward"][3]["RewardType"]
    PropID = config["Reward"][3]["PropID"]
    rewardNum = config["Reward"][3]["RewardNum"]
    itemImgPath = self:GetItemImgPath(rewardType, PropID)
    viewNode.itemImg3:loadTexture(itemImgPath, ccui.TextureResType.plistType)
    viewNode.itemText3:setString(string.format(rewardDesc, rewardNum))
end

-- 注册点击事件
function VivoPrivilegeStartUpCtrl:initialBtnClick()
    local viewNode = self._viewNode
    viewNode.btnStartUp:addClickEventListener(handler(self, self.onClickStartUp))
    viewNode.btnReceive:addClickEventListener(handler(self, self.onClickReceive))
    viewNode.btnClose:addClickEventListener(handler(self, self.onClickClose))
end

-- 更新抽奖状态
function VivoPrivilegeStartUpCtrl:updateState()
    -- 重新刷新UI
    self:initialUI()
end

-- Vivo特权活动点击启动按钮事件
function VivoPrivilegeStartUpCtrl:onClickStartUp()
    my.playClickBtnSound()
    
    VivoPrivilegeStartUpModel:startUpGame()

    self:goBack()
end

-- Vivo特权活动点击领奖按钮事件
function VivoPrivilegeStartUpCtrl:onClickReceive()
    my.playClickBtnSound()
    
    VivoPrivilegeStartUpModel:reqTakeReward()

    self:goBack()
end

-- 点击关闭
function VivoPrivilegeStartUpCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()

    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:PopNextPlugin()
end

-- 退出
function VivoPrivilegeStartUpCtrl:goBack()
    if type(self._callback) == 'function' then
        self._callback()
    end
    VivoPrivilegeStartUpCtrl.super.removeSelf(self)
end

return VivoPrivilegeStartUpCtrl