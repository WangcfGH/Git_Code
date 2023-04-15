local WinningStreakRewardCtrl    = class("WinningStreakRewardCtrl", import("src.app.plugins.RewardTip.RewardTipCtrl"))

local player                =mymodel('hallext.PlayerModel'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

--初始化发奖界面
function WinningStreakRewardCtrl:init()
    if type(self._rewardList)~='table' then return end
    local path = "res/hallcocosstudio/activitycenter/WinningStreakAward.csb"
    local aniFile = "res/hallcocosstudio/RewardCtrl/gd-kuang.csb"
    local index = 1
    local function showNodeItem()
        local itemCount = #self._rewardList
        if index > itemCount and self._TimerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TimerID)
            self._TimerID = nil
            --显示按钮
            self:SetBtnStatus()
            self:showPanelBtns()
            return
        end

        if self._showOneByOne then
            audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/reward.mp3'),false)
        end

        local item = self._rewardList[index]
        local imgPath = self:GetItemFilePath(item)
        local bShowEffct = self:IsNeedShowEffect(item)
        local pos = self:GetItemPos(index, itemCount)
        local node = cc.CSLoader:createNode(path)
        node:getChildByName("Panel_Main"):getChildByName("Img_Item"):loadTexture(imgPath, ccui.TextureResType.plistType)
        node:getChildByName("Panel_Main"):getChildByName("Fnt_Num"):setString(item.nCount)

        node:getChildByName("Panel_Main"):getChildByName("Fnt_FanBei"):setString("翻"..item.nMultiple.."倍")
        node:getChildByName("Panel_Main"):getChildByName("Fnt_FanBei"):setVisible(true)
        node:getChildByName("Panel_Main"):getChildByName("Img_FanBei"):setVisible(true)
        if item.nMultiple == "1.0" then
            node:getChildByName("Panel_Main"):getChildByName("Fnt_FanBei"):setVisible(false)
            node:getChildByName("Panel_Main"):getChildByName("Img_FanBei"):setVisible(false)
        end
        if self._showMemberTip then
            node:getChildByName("Panel_Main"):getChildByName("Image_1"):setVisible(true)
        else
            node:getChildByName("Panel_Main"):getChildByName("Image_1"):setVisible(false)
        end
        self._viewNode.List_Item:addChild(node)
        node:setPosition(pos)
        local aniNode = node:getChildByName("Panel_Main"):getChildByName("Ani_Effect")
        aniNode:stopAllActions()
        if bShowEffct then
            local action = cc.CSLoader:createTimeline(aniFile)
            if not tolua.isnull(action) then
                aniNode:runAction(action)
                action:play("animation0", true)
            end
            aniNode:setVisible(true)
        else
            aniNode:setVisible(false)
        end
        index = index + 1
    end

    local itemCount = #self._rewardList

    if self._showOneByOne then
        if self._TimerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TimerID)
            self._TimerID = nil
        end
        self._TimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(showNodeItem, 0.2, false)
    else
        for i = 1, itemCount do
            showNodeItem()
        end
        self:SetBtnStatus()
        self:showPanelBtns()
        audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/reward.mp3'),false)
    end

    self:freshTitle()
end

return WinningStreakRewardCtrl