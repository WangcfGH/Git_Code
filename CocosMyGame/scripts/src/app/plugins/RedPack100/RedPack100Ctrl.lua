local RedPack100Ctrl = class('RedPack100Ctrl', cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.RedPack100.RedPack100View")
local RedPack100Model = require("src.app.plugins.RedPack100.RedPack100Model"):getInstance()
local RedPack100Def = import('src.app.plugins.RedPack100.RedPack100Def')
local RedPack100Cache = import('src.app.plugins.RedPack100.RedPack100Cache'):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()


local BTN_REWARD_STATUS = {
    NOMAL_REWARD = 0,
    ALEADY_REWARD = 1
}

my.addInstance(RedPack100Ctrl)

function RedPack100Ctrl:onCreate(params)
    UIHelper:recordRuntime("ShowRedPackOnLaunch", "RedPack100Ctrl:onCreate begin")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/plist/RedPack100Ani.plist")
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if self._RedPackTipConten == nil then
        local FileNameString = "src/app/plugins/RedPack100/RedPack100.json"
        local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
        self._RedPackTipConten = cc.load("json").json.decode(content)
    end

    ----self:bindDestroyButton(viewNode.btnClose)
    self:initialize(viewNode)

    UIHelper:recordRuntime("ShowRedPackOnLaunch", "RedPack100Ctrl:onCreate end")
    UIHelper:printRuntime("ShowRedPackOnLaunch")
end

function RedPack100Ctrl:initialize(viewNode)
    local bindList={
        'btnChai',
		'btnReward',
        'btnClose'
	}
	
	self:bindUserEventHandler(viewNode, bindList)
    self._viewNode = viewNode
    self._viewNode.aniBreak:setVisible(false)
    self._viewNode.panelRedPack:setVisible(true)
    self._viewNode.panelBreak:setVisible(false)
    self._viewNode.btnClose:setVisible(false)
    self._viewNode.btnReward:setVisible(false)
    self._viewNode.panelOtherUsers:setVisible(false)

    self:listenTo(RedPack100Model, RedPack100Def.MSG_REDPACK_BREAK_RESP, handler(self, self.OnBtnChaiResp))
    self:listenTo(RedPack100Model, RedPack100Def.MSG_REDPACK_BREAK_FAILED, handler(self, self.onBreakFailed))

    self:btnChaiAnimation(self._viewNode.btnChai)
end

function RedPack100Ctrl:btnChaiClicked( ... )
    --local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    --HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    
    -- 发请求拆红包
    RedPack100Model:gc_BreakRedPack(RedPack100Def.BREAK_COND_EVERYDAY_LOGIN)

end

function RedPack100Ctrl:btnRewardClicked( ... )
    -- 跳转活动界面
    my.dataLink(cc.exports.DataLinkCodeDef.RED_PACK100_TI_XIAN_ON_LOGIN)
    local breakInfo = RedPack100Model:GetRedPackInfo()
    if not breakInfo then
        self:btnCloseClicked()
        return
    end

    -- 设置 拆开后显示数据
    local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
    local strNowDate = os.date("%Y%m%d", nowtimestamp)
    local nNowDate = tonumber(strNowDate)
    if nNowDate >= breakInfo.nEndDate then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_BREAK_OUT_DATE"], removeTime = 2}})
        RedPack100Model:onCountDownZero()

        self:onCloseAndContinuePlugin()
        return
    end

    local prevMoney = breakInfo.nAccumulateMoney - breakInfo.nGetMoney
    RedPack100Model:setDataForProcessAni(prevMoney, true)
    my.informPluginByName({pluginName='ActivityCenterCtrl',params = {moudleName='redpack100'}})
    RedPack100Model:notifyActivityCenterSwitch()
    self:btnCloseClicked()
end

function RedPack100Ctrl:btnCloseClicked( ...)
    if self._CDTimerHideAni then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CDTimerHideAni)
        self._CDTimerHideAni = nil
    end

    if self._aniBtnChai then
        self._aniBtnChai:stopAllActions()
        self._aniBtnChai = nil 
    end
    
    if self._viewNode.btnReward then
        self._viewNode.btnReward:stopAllActions()
        self._viewNode.btnReward = nil 
    end

    if self._viewNode.panelOtherUsers then
        self._viewNode.panelOtherUsers:stopAllActions()
        self._viewNode.panelOtherUsers = nil 
    end
    self:closeBtnChaiTimer()
    self:removeSelfInstance()
end

function RedPack100Ctrl:OnBtnChaiResp( data )
    if data and data.value then
        if data.value ~= RedPack100Def.BREAK_COND_EVERYDAY_LOGIN then
            return
        end
    end

    local breakInfo = RedPack100Model:GetRedPackInfo()
    if not breakInfo then
        return
    end

    -- 设置 拆开后显示数据
    local getMoney = breakInfo.nGetMoney/100
    self._viewNode.txtBmFontMoney:setString('$'..getMoney)
    if breakInfo.szUserNameArry and type(breakInfo.szUserNameArry) == 'table' then
        for k ,v in pairs(breakInfo.szUserNameArry) do
            local utf8Name=MCCharset:getInstance():gb2Utf8String(v, string.len(v))
            local txtUserName = 'txtUser'..k
            local txtUserMoney = 'txtMoney'..k
            self._viewNode[txtUserName]:setString(utf8Name)

            local a, b  = math.modf(breakInfo.nMoneyArry[k]/100)
            local strMoney =  string.format(self._RedPackTipConten.BREAK_INFO_MONEY, a+b)
            self._viewNode[txtUserMoney]:setString(strMoney)
        end
    end

    local maxMoney = math.max(breakInfo.nGetMoney, breakInfo.nMoneyArry[1], breakInfo.nMoneyArry[2], breakInfo.nMoneyArry[3],breakInfo.nMoneyArry[4])
    if maxMoney == breakInfo.nGetMoney then   -- 收起最佳控制逻辑
        self._viewNode.imgBestShouQi:setVisible(true)
    else
        self._viewNode.imgBestShouQi:setVisible(false)
    end

    local strTodayDate = os.date("%Y%m%d000000", MyTimeStamp:getLatestTimeStamp())
    local strTomorrow = cc.exports.getNewDate(strTodayDate, 1, "Day")
    local nTomorrowDate = tonumber(strTomorrow)
    if nTomorrowDate == breakInfo.nEndDate then  --最后一天不要显示 明日可继续提现
        self._viewNode.txtTommorow:setVisible(false)
    else
        self._viewNode.txtTommorow:setVisible(true)
    end
    -- 关闭拆按钮动作
    self:closeBtnChaiTimer()
    -- 播放动画
    self:playBreakRedPackAni(self._viewNode.aniBreak, maxMoney == breakInfo.nGetMoney, getMoney)
    -- 显示拆开后界面, 定时器做确保
    local function hideAniBreakNode()
        if nil  == self._bHideBreak then
            self:onFramePlayOverCallback()
        end
    end
    self._CDTimerHideAni = my.scheduleOnce(hideAniBreakNode, 2.5)
end

function RedPack100Ctrl:playAniBtnRewardComming(aniBtnRewardNode)
    local function callbackFunc()
        local repeatForever = self:createQuickAnimationRepeat(1)
        self._viewNode.btnReward:runAction(repeatForever)
    end

    local time = 0.5
    local firstDelay = 1.5
    local delayAction     = cc.DelayTime:create(firstDelay)    
    local a1 = cc.FadeTo:create(time, 255)
    local a2 = cc.ScaleTo:create(time, 1)
    local action1_spawn = cc.Spawn:create(a1, a2)
    aniBtnRewardNode:setOpacity(0)
    aniBtnRewardNode:setScale(0)
    aniBtnRewardNode:runAction(cc.Sequence:create(cc.Show:create(), delayAction, action1_spawn, cc.CallFunc:create(callbackFunc)))
end

function RedPack100Ctrl:onFramePlayOverCallback()
    local function callbackFunc()
        self._viewNode.panelRedPack:setVisible(false)
        self._viewNode.aniBreak:setVisible(false)
        self._viewNode.panelBreak:setVisible(true)

        local panelOtherUsers = self._viewNode.panelOtherUsers
        local a1 = cc.FadeTo:create(0.5, 255)
        local a2 = cc.ScaleTo:create(0.5, 1)
        local action1_spawn = cc.Spawn:create(a1, a2)
        panelOtherUsers:setOpacity(0)
        panelOtherUsers:runAction(cc.Sequence:create(cc.Show:create(), action1_spawn))

        -- 播放立即提现按钮动画
        self:playAniBtnRewardComming(self._viewNode.btnReward)
    end

    local aniNode = self._viewNode.panelRedPack
    local time = 0.5
    local firstDelay = 0
    --aniNode:setOpacity(255)
    local delayAction     = cc.DelayTime:create(firstDelay)    
    local scaleto2 = cc.ScaleTo:create(time, 1.2, 1.2)
    local scaleto3 = cc.ScaleTo:create(time,0.95, 0.95)
    local sequenceAction  = cc.Sequence:create(delayAction, scaleto2,scaleto3, cc.CallFunc:create(callbackFunc))
    aniNode:runAction(sequenceAction)

    self._bHideBreak = true
end

function RedPack100Ctrl:playBreakRedPackAni(aniNode, bHideSQ, strMoney)
    if not aniNode then return end
    -- 播放拆红包声音
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/RedPackBreak.mp3'),false)
    -- 播放动画
    aniNode:setVisible(true)
    local aniHitFile= "res/hallcocosstudio/redpack100/kaihongbao.csb"
    aniNode:stopAllActions()
    local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
    if not tolua.isnull(aniDraw) then
        aniNode:runAction(aniDraw)
        aniDraw:play("animation0", false)
    end

    local function onBMFontShow()
        local fatherNode = aniNode:getChildByName("dakai")
        fatherNode:getChildByName("sq_16"):setVisible(bHideSQ)   --是否隐藏手气最佳
        fatherNode:getChildByName("jg_7"):setVisible(false)   --隐藏金额图片
        local labelBMFont = ccui.TextBMFont:create()
        labelBMFont:setFntFile("res/hallcocosstudio/images/font/Redpack100/byhbl_sz_01.fnt")
        labelBMFont:setString('$'..strMoney)
        local pos = cc.p(fatherNode:getChildByName("jg_7"):getPosition())
        labelBMFont:setScale(1.2)
        labelBMFont:setPosition(cc.p(pos.x, pos.y+15))
        fatherNode:addChild(labelBMFont)  
    end

    local function onFrameEvent(frame)  -- 要再资源文件里勾选  自动记录帧，否则时间不会触发
        if frame then 
            local event = frame:getEvent()
            if "Fnt_Show" == event then
                onBMFontShow()
            end
            if "Play_Over" == event then
                self:onFramePlayOverCallback()
            end
        end
    end

    aniDraw:setFrameEventCallFunc(onFrameEvent)
end

function RedPack100Ctrl:createAnimationRepeat(delayTime)
    local time = 0.3
    local scaleto2 = cc.ScaleTo:create(time, 1.1, 1.1)
    local scaleto3 = cc.ScaleTo:create(time, 1, 1)
    local delayAction     = cc.DelayTime:create(delayTime)         
    --序列
    local sequenceAction  = cc.Sequence:create(scaleto2, scaleto3, delayAction)
    --重复
    local repeatForever = cc.RepeatForever:create(sequenceAction)
    return repeatForever
end

function RedPack100Ctrl:createQuickAnimationRepeat(delayTime)
    local time = 0.2
    local scaleto2 = cc.ScaleTo:create(time, 1.1, 1.1)
    local scaleto3 = cc.ScaleTo:create(time, 1, 1)
    local delayAction     = cc.DelayTime:create(delayTime)         
    --序列
    local sequenceAction  = cc.Sequence:create(scaleto2, scaleto3, scaleto2, scaleto3, delayAction)
    --重复
    local repeatForever = cc.RepeatForever:create(sequenceAction)
    return repeatForever
end

function RedPack100Ctrl:btnChaiAnimation(aniBtn)
    local function playBtnChaiAni()
        if aniBtn ~= nil then
            self._aniBtnChai = aniBtn
            local repeatForever = self:createAnimationRepeat(0.1)
            self._aniBtnChai:runAction(repeatForever)
        end
    end

    self._CDTimerBtnChai = my.scheduleOnce(playBtnChaiAni, 0.5)
end

function RedPack100Ctrl:closeBtnChaiTimer()
    if self._CDTimerBtnChai then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CDTimerBtnChai)
        self._CDTimerBtnChai = nil
    end
end


function RedPack100Ctrl:onBreakFailed(data)
    local nRespCode = data.value
    if nRespCode == RedPack100Def.BREAK_DB_DATA_NOT_FOUND then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_BREAK_DB_NOT_FOUND"], removeTime = 2}})
    elseif nRespCode == RedPack100Def.BREAK_ALEADY_TODAY then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_BREAK_ALEADY"], removeTime = 2}})
    else
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_BREAK_OUT_DATE"], removeTime = 2}})
    end

    self:onCloseAndContinuePlugin()
end

function RedPack100Ctrl:onCloseAndContinuePlugin()
    -- 登陆拆红包失败要触发下连续弹窗
    my.scheduleOnce(function()
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:continuePluginProcess()    
    end, 1)

    self:btnCloseClicked()
end

-- 弹出红包界面立马物理键，报错问题解决
function RedPack100Ctrl:onKeyBack()
    -- 需求： 红包弹窗物理键返回屏蔽掉
--[[
    if self._CDTimerHideAni then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CDTimerHideAni)
        self._CDTimerHideAni = nil
    end

    if self._aniBtnChai then
        self._aniBtnChai:stopAllActions()
        self._aniBtnChai = nil 
    end

    if self._viewNode.btnReward then
        self._viewNode.btnReward:stopAllActions()
        self._viewNode.btnReward = nil 
    end

    if self._viewNode.panelOtherUsers then
        self._viewNode.panelOtherUsers:stopAllActions()
        self._viewNode.panelOtherUsers = nil 
    end

    self:closeBtnChaiTimer()

    RedPack100Ctrl.super.onKeyBack(self)
    ]]
end

return RedPack100Ctrl