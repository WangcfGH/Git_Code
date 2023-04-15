-- //**********************************
-- // 继承自RedPack100Ctrl， 替换界面，给非同城游渠道使用
-- //**********************************

local RedPack100Ctrl = import("src.app.plugins.RedPack100.RedPack100Ctrl")
local Vocher_RedPack100Ctrl = class("Vocher_RedPack100Ctrl", RedPack100Ctrl)
local viewCreater       = import("src.app.plugins.RedPack100Vocher.Vocher_RedPack100View")
local RedPack100Model = require("src.app.plugins.RedPack100.RedPack100Model"):getInstance()
local RedPack100Def = import('src.app.plugins.RedPack100.RedPack100Def')
--local RedPack100Cache = import('src.app.plugins.RedPack100.RedPack100Cache'):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

my.addInstance(Vocher_RedPack100Ctrl)

function Vocher_RedPack100Ctrl:onCreate(params)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/plist/RedPack100Ani.plist")
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if self._RedPackTipConten == nil then
        local FileNameString = "src/app/plugins/RedPack100/RedPack100.json"
        local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
        self._RedPackTipConten = cc.load("json").json.decode(content)
    end

    self:initialize(viewNode)
end


function Vocher_RedPack100Ctrl:initialize(viewNode)
    local bindList={
        'btnChai',
		'btnReward',
        'btnClose'
	}
	
	self:bindUserEventHandler(viewNode, bindList)
    self._viewNode = viewNode
    self._viewNode.panelRedPack:setVisible(true)
    self._viewNode.panelBreak:setVisible(false)
    self._viewNode.btnClose:setVisible(false)
    self._viewNode.btnReward:setVisible(false)

    self:listenTo(RedPack100Model, RedPack100Def.MSG_REDPACK_BREAK_RESP, handler(self, self.OnBtnChaiResp))
    self:listenTo(RedPack100Model, RedPack100Def.MSG_REDPACK_BREAK_FAILED, handler(self, self.onBreakFailed))

    self:btnChaiAnimation(self._viewNode.btnChai)
    self:boxAnimation(self._viewNode)
end

function Vocher_RedPack100Ctrl:btnChaiClicked( ... )
    -- 发请求拆红包
    RedPack100Model:gc_BreakRedPack(RedPack100Def.BREAK_COND_EVERYDAY_LOGIN)
end

function Vocher_RedPack100Ctrl:boxAnimation(viewNode)
    self._viewNode.aniBreak:setVisible(true)
    if not self._spBox then
        if not cc.FileUtils:getInstance():isFileExist("res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.json") then return end
        local actionName = "box_ani_close"    
        self._spBox = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.json", "res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.atlas",1)
        self._spBox:setAnimation(0, actionName, true) 
        self._spBox:setPositionY(80)
        viewNode.aniBreak:addChild(self._spBox)
    end
end

function Vocher_RedPack100Ctrl:OnBtnChaiResp( data )
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
    local getMoney = breakInfo.nGetMoney
    self._viewNode.txtFontVocher:setString('x'..getMoney)
    local strTip = string.format(self._RedPackTipConten["VOCHER_RP100_CAN_EXCHANGE"], getMoney/100)
    self._viewNode.txtTip1:setString(strTip)
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
    self:playBreakRedPackAni(self._viewNode, maxMoney == breakInfo.nGetMoney, getMoney)
    -- 显示拆开后界面, 定时器做确保
    local function hideAniBreakNode()
        if nil  == self._bHideBreak then
            self:onFramePlayOverCallback()
        end
    end
    self._CDTimerHideAni = my.scheduleOnce(hideAniBreakNode, 1.5)
end


function Vocher_RedPack100Ctrl:onFramePlayOverCallback()
    local function callbackFunc()
        self._viewNode.panelRedPack:setVisible(false)
        self._viewNode.aniBreak:setVisible(false)
        self._viewNode.panelBreak:setVisible(true)
        -- 播放立即提现按钮动画
        self:playAniBtnRewardComming(self._viewNode.btnReward)
    end

    local aniNode = self._viewNode.panelRedPack

    -- 动画播放完逐渐消失
    local time = 0.5
    local firstDelay = 1.5
    local delayAction     = cc.DelayTime:create(firstDelay)    
    local a1 = cc.FadeTo:create(time, 0)
    local a2 = cc.ScaleTo:create(time, 0.2)
    local action1_spawn = cc.Spawn:create(a1, a2)
    aniNode:setOpacity(255)
    aniNode:setScale(1)
    aniNode:runAction(cc.Sequence:create(cc.Show:create(), delayAction, action1_spawn, cc.CallFunc:create(callbackFunc)))
    self._bHideBreak = true
end

function Vocher_RedPack100Ctrl:playBreakRedPackAni(viewNode, bHideSQ, strMoney)
    if not viewNode then return end
    -- 播放拆红包声音
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/RedPackBreak.mp3'),false)
    -- 播放动画
    viewNode.aniBreak:setVisible(true)
    viewNode.aniBreakEffect:setVisible(true)
    if not self._spBoxEffect then
        local actionName = "box_effect"    
        self._spBoxEffect = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.json", "res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.atlas",1)
        self._spBoxEffect:setAnimation(0, actionName, false) 
        self._spBoxEffect:setPositionY(80)
        viewNode.aniBreakEffect:addChild(self._spBoxEffect)
    end

    if self._spBox then
        local actionOpenName = "box_ani_open"    
        self._spBox:setAnimation(0, actionOpenName, false) 
    end
end

function Vocher_RedPack100Ctrl:btnCloseClicked( ...)
    if self._spBox then
        self._spBox:setVisible(false)
        self._spBox:removeFromParentAndCleanup()
        self._spBox = nil
    end

    if self._spBoxEffect then
        self._spBoxEffect:setVisible(false)
        self._spBoxEffect:removeFromParentAndCleanup()
        self._spBoxEffect = nil
    end

    Vocher_RedPack100Ctrl.super.btnCloseClicked(self)
end
return Vocher_RedPack100Ctrl