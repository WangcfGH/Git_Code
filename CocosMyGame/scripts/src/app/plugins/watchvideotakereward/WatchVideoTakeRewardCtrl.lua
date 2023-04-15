local WatchVideoTakeRewardCtrl = class("WatchVideoTakeRewardCtrl", cc.load("BaseCtrl"))
local WatchVideoTakeRewardView = require("src.app.plugins.watchvideotakereward.WatchVideoTakeRewardView")
local WatchVideoTakeRewardModel = require("src.app.plugins.watchvideotakereward.WatchVideoTakeRewardModel"):getInstance()
local AdvertModel = import('src.app.plugins.advert.AdvertModel'):getInstance()
local ComEvtTrkingModel = require("src.app.GameHall.models.ComEvtTrking.ComEvtTrkingModel"):getInstance()

function WatchVideoTakeRewardCtrl:onCreate(...)
    self:setViewIndexer(WatchVideoTakeRewardView:createViewIndexer(self))

    --
    self:listenTo(WatchVideoTakeRewardModel, WatchVideoTakeRewardModel.Events.CONFIG_DATA_UPDATED, handler(self, self._OnConfigDataUpdated))
    self:listenTo(WatchVideoTakeRewardModel, WatchVideoTakeRewardModel.Events.WVTR_RSP_RESULT, handler(self, self._OnLotteryResult))

    --
    if not self:_checkViewNode() then
        return
    end
    local viewNode = self:getViewNode()
    self:bindUserEventHandler(viewNode, {
        'closeBtn',
        'watchVideoBtn'
    })
end

function WatchVideoTakeRewardCtrl:onEnter()
    WatchVideoTakeRewardCtrl.super.onEnter(self)
    self:_updateView()
    WatchVideoTakeRewardModel:setViewVisibleFlag(true)
    self:_setRunningActionFlag(false)
end

function WatchVideoTakeRewardCtrl:onExit()
    WatchVideoTakeRewardCtrl.super.onExit(self)
    WatchVideoTakeRewardModel:setViewVisibleFlag(false)
    if self:_isRunningAction() then
        WatchVideoTakeRewardModel:update(true, {})
        WatchVideoTakeRewardModel:setDoing(false)
    end
    self:_setRunningActionFlag(false)
end

function WatchVideoTakeRewardCtrl:_updateView()
    self:_updateHitBoxProcess()
    self:_updateWatchVideoBtnProcess()
    self:_updateRewardItems()
end

function WatchVideoTakeRewardCtrl:_updateHitBoxProcess()
    if not self:_checkViewNode() then
        return
    end
    local info = WatchVideoTakeRewardModel:getHitBoxProcessInfo()
    local viewNode = self:getViewNode()
    viewNode.countTextTip:setString(tostring(info.hitboxcount))
    viewNode.countProgressText:setString(info.processtext)
    viewNode.loadingBar:setPercent(info.precesspercent)
end

function WatchVideoTakeRewardCtrl:_updateWatchVideoBtnProcess()
    if not self:_checkViewNode() then
        return
    end
    local str, avaiable = WatchVideoTakeRewardModel:getWatchVideoBtnProcessInfo()
    local viewNode = self:getViewNode()
    viewNode.watchVideoProcess:setString(str)
    viewNode.watchVideoBtn:setBright(avaiable)
    viewNode.watchVideoBtn:setTouchEnabled(avaiable)
end

function WatchVideoTakeRewardCtrl:_updateRewardItems()
    if not self:_checkViewNode() then
        return
    end
    local viewNode = self:getViewNode()
    local items = WatchVideoTakeRewardModel:getSortedRewardInfo()
    for i = 1, 9 do
        local btnName = "btn" .. i
        if viewNode[btnName] then
            local imageNode = viewNode[btnName]:getChildByName("Image")
            if imageNode then
                imageNode:setVisible(false)
            end
            local textNode = viewNode[btnName]:getChildByName("Text")
            if textNode then
                textNode:setVisible(false)
            end
        end
    end
    -- 顺时针银两数从小到大,注意服务端配置请保持这样的顺序
    for k, v in pairs(items) do
        local btnName = "btn" .. k
        local _, des = WatchVideoTakeRewardModel:GetItemFilePathAndDes(v)
        if des and viewNode[btnName] then
            local imageNode = viewNode[btnName]:getChildByName("Image")
            if imageNode then
                imageNode:setVisible(true)
            end
            local textNode = viewNode[btnName]:getChildByName("Text")
            if textNode then
                textNode:setString(des)
                textNode:setVisible(true)
            end
        end
    end
end

function WatchVideoTakeRewardCtrl:_OnConfigDataUpdated(event)
    self:_updateView()
end

function WatchVideoTakeRewardCtrl:_OnLotteryResult(event)
    if not (event and event.value) then
        print("[ERROR] invalid event in WatchVideoTakeReward-module...")
        return
    end
    self:_updateView()

    -- 收到该事件,意味着抽奖已经成功了
    local rsp = event.value 
    if not (type(rsp.items) == 'table' and #rsp.items > 0) then
        return
    end
    local oneItem = rsp.items[1]

    --
    local buttons = {
        { id = 1, name =  'btn1', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_1.png', 
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_1f.png',resType = ccui.TextureResType.plistType }, -- 1
        { id = 2, name = 'btn2', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_2.png', 
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_2f.png', resType = ccui.TextureResType.plistType },-- 2
        { id = 9, name = 'btn9', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_9.png', 
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_9f.png',resType = ccui.TextureResType.plistType },-- 3
        { id = 3, name =  'btn3', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_3.png', 
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_3f.png',resType = ccui.TextureResType.plistType }, -- 4
        { id = 4, name = 'btn4', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_4.png', 
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_4f.png',resType = ccui.TextureResType.plistType },-- 5
        { id = 5, name = 'btn5',image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_8.png',
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_8f.png', resType = ccui.TextureResType.plistType }, -- 6
        { id = 6, name = 'btn6', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_7.png', 
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_7f.png',resType = ccui.TextureResType.plistType }, -- 7
        { id = 9, name = 'btn9', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_9.png', 
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_9f.png', resType = ccui.TextureResType.plistType }, -- 8
        { id = 7, name = 'btn7', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_6.png',
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_6f.png', resType = ccui.TextureResType.plistType }, -- 9
        { id = 8, name = 'btn8', image = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_5.png', 
            image2 = 'hallcocosstudio/images/plist/watchvideotakedeposit/btn_bg_5f.png', resType = ccui.TextureResType.plistType }-- 10
    }
    local getIndex = function (id) 
        for index, v in pairs(buttons) do
            if v.id == id then
                return index
            end
        end
        return 0
    end
    local finalButtonIndex = getIndex(oneItem.idx)
    if finalButtonIndex == 0 then
        WatchVideoTakeRewardModel:showRewards(rsp.items, rsp.extraitems)
    else
        local actionSeq = {}
        table.insert(actionSeq, cc.CallFunc:create(function () self:_setRunningActionFlag(true) end))
        --
        local viewNode = self:getViewNode()
        local loops = math.ceil(math.random(1, 3))
        local loopButtons = {}
        for i = 1, loops do
            table.insertto(loopButtons, buttons)
        end
        for i = 1, finalButtonIndex do
            table.insert(loopButtons, buttons[i])
        end
        for index, one in pairs(loopButtons) do 
            table.insert(actionSeq, cc.CallFunc:create(function ()  viewNode[one.name]:loadTextureNormal(one.image, one.resType) end))
            table.insert(actionSeq, cc.DelayTime:create( 1.0 / 10.0))
            if index ~= #loopButtons then
                table.insert(actionSeq, cc.CallFunc:create(function ()  viewNode[one.name]:loadTextureNormal(one.image2, one.resType) end))
            end
        end
        table.insert(actionSeq, cc.DelayTime:create(1.5)) -- 延时看停留处是什么奖励
        table.insert(actionSeq, cc.CallFunc:create(function ()
            -- 显示弹窗
            WatchVideoTakeRewardModel:showRewards(rsp.items, rsp.extraitems)
        end))
        table.insert(actionSeq, cc.CallFunc:create(function () 
            local last = loopButtons[#loopButtons]
            if type(last) == 'table' then
                viewNode[last.name]:loadTextureNormal(last.image2, last.resType)
            end
        end))
        --
        table.insert(actionSeq, cc.CallFunc:create(function () self:_setRunningActionFlag(false) end))
        local seq = cc.Sequence:create(unpack(actionSeq))
        viewNode:runAction(seq)
    end
end

function WatchVideoTakeRewardCtrl:watchVideoBtnClicked()
    if WatchVideoTakeRewardModel:isDoing() or self:_isRunningAction() then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString = '您正在抽奖,请您耐心等待抽奖结果',removeTime=1}})
        return
    end
    WatchVideoTakeRewardModel:setDoing(true)
    ComEvtTrkingModel:initWatchVideoEventInfo(ComEvtTrkingModel.WATCH_VIDEO_SCENE.WATCH_VIDEO_TAKE_REWARD)
    AdvertModel:ShowVideoAd(function (code, msg)
        ComEvtTrkingModel:watchVideoCallback(code, msg)
        if code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOCOMPLETE then
            WatchVideoTakeRewardModel:reqLottery() -- 发起抽奖
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_LOADAD_FAIL then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
            WatchVideoTakeRewardModel:setDoing(false)
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOPLAYERROR then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
            WatchVideoTakeRewardModel:setDoing(false)
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_DIMISS then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
            WatchVideoTakeRewardModel:setDoing(false)
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
            WatchVideoTakeRewardModel:setDoing(false)
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_CLOSED then
            WatchVideoTakeRewardModel:setDoing(false)
        end
    end)
    -- test 
    -- WatchVideoTakeRewardModel:reqLottery()
end

function WatchVideoTakeRewardCtrl:closeBtnClicked()
    if WatchVideoTakeRewardModel:isDoing() or self:_isRunningAction() then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString = '您正在抽奖,请您耐心等待抽奖结果',removeTime=1}})
        return
    end
    self:removeSelfInstance()
    -- self:onKeyBack()
end

function WatchVideoTakeRewardCtrl:onKeyBack()
    if WatchVideoTakeRewardModel:isDoing() or self:_isRunningAction() then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString = '您正在抽奖,请您耐心等待抽奖结果',removeTime=1}})
        return
    end
    WatchVideoTakeRewardCtrl.super.onKeyBack(self)
end

function WatchVideoTakeRewardCtrl:_checkViewNode()
    local viewNode = self:getViewNode()
    if not viewNode then
        return false
    end
    if viewNode.getRealNode and tolua.isnull(viewNode:getRealNode()) then
        return false
    end
    return true
end

function WatchVideoTakeRewardCtrl:_checkClickAvaiable()
    if WatchVideoTakeRewardModel:isDoing() then
        return false
    end
    return true
end

function WatchVideoTakeRewardCtrl:_setRunningActionFlag(flag)
    self._isRunningAct = flag
end

function WatchVideoTakeRewardCtrl:_isRunningAction()
    return self._isRunningAct
end

return WatchVideoTakeRewardCtrl