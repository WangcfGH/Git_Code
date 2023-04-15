local OldUserInitGiftView       = import('src.app.plugins.invitegift.oldusergift.OldUserInitGiftView')
local InviteGiftUserNodeView    = import('src.app.plugins.invitegift.oldusergift.InviteGiftUserNodeView')
local OldUserInviteGiftModel    = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
local RollNumberView            = import('src.app.plugins.invitegift.oldusergift.RollNumberView')
local UserModel                 = mymodel('UserModel'):getInstance()
local NewUserInviteGiftModel = require('src.app.plugins.invitegift.newusergift.NewUserInviteGiftModel'):getInstance()
local QRCodeCtrl                = require("src.app.BaseModule.QRCode.QRCodeCtrl")
local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
local OldUserInitGiftCtrl = class("OldUserInitGiftCtrl",  myctrl('BaseShareCtrl'))
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()

OldUserInitGiftCtrl.RUN_ENTERACTION = true

local PANEL_TYPE = {
    UNOPEN = 1,
    OPEN = 2,
    COUNT = 3,
    REWARD = 4,
    FLOWVIEW = 5
}

function OldUserInitGiftCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(OldUserInitGiftView:createViewIndexer())

    self._isOpenInGame = params.isOpenInGame
    self._notReqData = params.notReqData
    self._clickCloseBtnCb = params.clickCloseBtnCb
    self._bgAnimationRunning = false

    viewNode.Img_Hit1_0:hide()
    self:initClickEvent()
    self:initEvent()
    self._enableKeyBack = true
    self._scheduleList = {}
end

function OldUserInitGiftCtrl:runEnterAction()
    self._viewNode:runTimelineAction("animation_appear", false)
end

function OldUserInitGiftCtrl:onEnter()
    OldUserInitGiftCtrl.super.onEnter(self)
    self:initShareImg()


    local info = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_REWARD_NO)
    local data = OldUserInviteGiftModel:getInviteGiftData()
    --本期首次登录埋点
    if not info.RewardNo or(data and info.RewardNo ~= data.nRewardNo )then
        OldUserInviteGiftModel:setnRewardNoCache(data.nRewardNo)
        my.dataLink(cc.exports.DataLinkCodeDef.SMALL_CYCLE)
    end

    --首次弹领奖界面埋点
    local info1 = CacheModel:getCacheByKey(OldUserInviteGiftModel.OLDFIRSTSHOWREWARDPANEL)
    local sign = data.nRewardNo .. "_1"
    if (not info1.PopReward or info1.PopReward ~= sign) and OldUserInviteGiftModel:getInviteRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet then
        OldUserInviteGiftModel:setPopRewardPanel(sign)
        my.dataLink(cc.exports.DataLinkCodeDef.OLD_FIRST_SHOW_REWARD_PANEL)
    end

    --每日首次登入埋点
    local info2 = CacheModel:getCacheByKey(OldUserInviteGiftModel.CACHE_KEY_DAY_TIME)
    local curTime = OldUserInviteGiftModel:getCurTimeStr()
    if not info2.time or info2.time ~= curTime then
        OldUserInviteGiftModel:setDayTimeCache( curTime )
        my.dataLink(cc.exports.DataLinkCodeDef.FIRST_DAY_POP)
    end

    if self._notReqData then
        self:freshView()
        return
    end

    OldUserInviteGiftModel:sendInviteGiftData()
    self:showPanel(nil)
end

function OldUserInitGiftCtrl:onExit()
    for _, v in pairs(self._scheduleList) do
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(v)
    end
    OldUserInitGiftCtrl.super.onExit(self)
    PluginProcessModel:PopNextPlugin()
end

function OldUserInitGiftCtrl:onKeyBack()
    if self._isOpenInGame then
        OldUserInviteGiftModel:setFistBoutCache(0)
    end

    if self._enableKeyBack then
        OldUserInitGiftCtrl.super.onKeyBack(self)
    end
    --PluginProcessModel:stopPluginProcess()
end

function OldUserInitGiftCtrl:initClickEvent()
    local viewNode = self._viewNode
    self:addClickEvent(viewNode.btnClose, handler(self, self.closeBtnClicked), true)
    self:addClickEvent(viewNode.btnOpen, handler(self, self.openBtnClicked))
    self:addClickEvent(viewNode.btnExtract, handler(self, self.extractBtnClicked))
    self:addClickEvent(viewNode.btnAccelerate, handler(self, self.accelerateBtnClicked))
    self:addClickEvent(viewNode.btnLookUp, handler(self, self.lookUpBtnClicked))
    self:addClickEvent(viewNode.btnReward, handler(self, self.rewardBtnClicked))
    self:addClickEvent(viewNode.panelShade, function() viewNode.panelListContent:hide() end, true)
    self:addClickEvent(viewNode.btnHelp, handler(self, self.helpBtnClicked))
end

function OldUserInitGiftCtrl:initEvent()
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_UPDATE_DATA, handler(self, self.freshView))
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_ATTEND_SUCCESS, handler(self, self.onAttendSuccess))
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_ATTEND_FAILED, handler(self, self.onAttendFailed))
    -- self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_SHAREREWARD_SUCCEED, handler(self, self.freshView))
end

-- 根据当前数据刷新界面
function OldUserInitGiftCtrl:freshView()
    -- 播放背景动画
    if not self._bgAnimationRunning then
        local aniInfo = {
            aniName = 'animation_loop',
            resPath = 'res/hallcocosstudio/invitegiftactive/animation/ani_bg.csb',
            isLoop = true
        }
        local aniNode = AnimationPlayer:playNodeFrameAni(self._viewNode.nodeBgAniPos, aniInfo)
        self._bgAnimationRunning = true
    end
  
    -- 根据数据的状态决定显示哪个阶段
    if not OldUserInviteGiftModel:isOpenPacket() then
        self._enableKeyBack = false
        my.dataLink(cc.exports.DataLinkCodeDef.FIRST_POP)
        self:setUnopenStatus()
        return
    end

    self:textHintShow()
    --如果大奖可以领取或者已经领取 直接弹大奖界面
    if OldUserInviteGiftModel:getInviteRewardStatus() ~= OldUserInviteGiftModel.RewardStatus.notGet then
        self:setRewardStatus() 
        --好友助力后请求领取奖励(策划说分享有点击奖励可领取 显示这步的时候直接领取 9-27)
        if OldUserInviteGiftModel:getInviteClickTakeRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet then
            OldUserInviteGiftModel:requireGetShareAward( 2 )
        end
        return 
    end

    --没有分享成功
    if OldUserInviteGiftModel:getShareTakeRewardStatus() then
        self:setOpenStatus()
        return
    end

    -- 分享成功 但没有绑定新玩家 如果又绑定关系但是有
    if not OldUserInviteGiftModel:isBinding() or 
    (OldUserInviteGiftModel:isBinding() and OldUserInviteGiftModel:getInviteClickTakeRewardStatus() ~= OldUserInviteGiftModel.RewardStatus.getted ) then
        self:setCountStatus()
        --好友助力后请求领取奖励
        if OldUserInviteGiftModel:getInviteClickTakeRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet then
            OldUserInviteGiftModel:requireGetShareAward( 2 )
        end
        return
    end

    self:setRewardStatus() 

end

-- 设置为未开启界面
function OldUserInitGiftCtrl:setUnopenStatus()
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/TestResult.mp3'), false)
    local viewNode = self._viewNode
    self:showPanel(PANEL_TYPE.UNOPEN)
    local aniInfo = {
        aniName = 'animation_scale',
        resPath = 'res/hallcocosstudio/invitegiftactive/olduser/olduserinitgift.csb',
        isLoop = true
    }
    AnimationPlayer:playExistNodeFrameAni(self._viewNode, aniInfo)
end

-- 设置为开启后的界面
function OldUserInitGiftCtrl:setOpenStatus()
   
    local viewNode = self._viewNode
    if not viewNode.ProcessBarOpen then
        local bar = self:createProcessBar()
        viewNode.panelBarOpenRes:addChild(bar)
        bar:setPosition(cc.p(viewNode.nodeBarPosOpenRes:getPosition()))
        viewNode.ProcessBarOpen = bar
    end
    local cfg = OldUserInviteGiftModel:getCurTimeActCfgData()
    if not cfg then return end

   
    self:showPanel(PANEL_TYPE.OPEN)
    local openTips = ""
    if OldUserInviteGiftModel.RewardType.YINZI == cfg.RewardType then
        openTips='恭喜获得' .. cfg.RewardNum / 10000 .. '万两银子领取资格'
        viewNode.textTotalRewardOpen:setString(self:formatNum(cfg.RewardNum) .. "两")
        viewNode.textTotalRewardOpen:show()
        viewNode.Image_huafeibg:hide()
    else
        openTips='恭喜获得' .. cfg.RewardNum .. '元话费领取资格'
        local huafei = cfg.RewardNum
        if huafei < 100 then
            huafei = string.format("%.2f",huafei)
        end
        viewNode.textTotalHuafei:setString(huafei .. "元")
        viewNode.textTotalRewardOpen:hide()
        viewNode.Image_huafeibg:show()
    end
    viewNode.textOpenHint1:setString(openTips)

    local shareCfg = OldUserInviteGiftModel:getInviteShareCfg()
    
    -- viewNode.Fnt_Extract:setString( string.format("分享立领%s两",shareCfg.Share_RewardNum))

    if not OldUserInviteGiftModel:isOpenShare() then
        viewNode.Fnt_Extract:setString( "邀请好友对局" )
    else
        viewNode.Fnt_Extract:setString( string.format("分享立领%s两",shareCfg.Share_RewardNum))
    end

   
    -- 播放按钮动画
    viewNode.btnExtract:runAction(self:getScaleAnimation())
    -- 标题动画
    local aniNode = viewNode.panelOpenRes:getChildByName('Node_AniTitle1')
    local aniInfo = {
        aniName = 'animation_loop',
        resPath = 'res/hallcocosstudio/invitegiftactive/animation/ani_title1.csb',
        isLoop = true
    }
    AnimationPlayer:playExistNodeFrameAni(aniNode, aniInfo)
    -- my.scheduleOnce(function ()
    --     if viewNode and viewNode.Img_Hit1_0 then
            viewNode.Img_Hit1_0:show()
    --     end
    -- end, 0.5)
    local progressAction = cc.ProgressTo:create(0.5, 95)
    viewNode.ProcessBarOpen:runAction(progressAction)
end

-- 分享成功
function OldUserInitGiftCtrl:setCountStatus()
    local viewNode = self._viewNode
    self:showPanel(PANEL_TYPE.COUNT)
    local cfg = OldUserInviteGiftModel:getCurTimeActCfgData()
    viewNode.imgBarHint:hide()

    if not viewNode.ProcessBarCount then
        local bar = self:createProcessBar()
        viewNode.panelBarCount:addChild(bar)
        bar:setPosition(cc.p(viewNode.nodeBarPosCount:getPosition()))
        viewNode.ProcessBarCount = bar
    end

    local progressAction = cc.ProgressTo:create(0.5, (14 / 15) * 100)
    local sequence = cc.Sequence:create(progressAction, cc.CallFunc:create(function ()
        viewNode.imgBarHint:show()
    end))
    viewNode.ProcessBarCount:runAction(sequence)

    local openTips = ""
   
    if OldUserInviteGiftModel.RewardType.YINZI == cfg.RewardType then
        openTips='恭喜获得' .. cfg.RewardNum / 10000 .. '万两银子领取资格'
        viewNode.textTotalRewardCount:setString(self:formatNum(cfg.RewardNum) .. "两")
        viewNode.textTotalRewardCount:show()
        viewNode.Image_huafeibg1:hide()
    else
        openTips='恭喜获得' .. cfg.RewardNum .. '元话费领取资格'
        local huafei = cfg.RewardNum
        if huafei < 100 then
            huafei = string.format("%.2f",huafei)
        end
        viewNode.textTotalHuafei1:setString(huafei .. "元")
        viewNode.textTotalRewardCount:hide()
        viewNode.Image_huafeibg1:show()
    end
    local qipaoStr = ""
    local topTip = ""
    if OldUserInviteGiftModel:getDefaultShareType() == 1 then
        qipaoStr = "好友识别二维码\n再领%s两"
        topTip = "你的微信好友识别二维码，为你助力%s两银子"
    else
        qipaoStr = "好友点击分享链接\n再领%s两"
        topTip = "你的微信好友点击链接，为你助力%s两银子"
    end

    local shareCfg = OldUserInviteGiftModel:getInviteShareCfg()
    local status = OldUserInviteGiftModel:getInviteClickTakeRewardStatus()
    --本次打开不刷新 特殊处理
    if not self.notSetfrendhelp_bg then
        self.notSetfrendhelp_bg = true
        viewNode.Img_frendhelp_bg:setVisible(status == OldUserInviteGiftModel.RewardStatus.canGet)
    end
    viewNode.Img_Tip:setVisible(status ~= OldUserInviteGiftModel.RewardStatus.getted)
    viewNode.Text_frendhelp:setString(string.format(topTip,shareCfg.Click_RewardNum))
    viewNode.Text_share_tip:setString(string.format(qipaoStr,shareCfg.Click_RewardNum))

    if not OldUserInviteGiftModel:isOpenShare() then
        viewNode.Img_Tip:setVisible(false)
        viewNode.Img_frendhelp_bg:setVisible(false)
    end

    viewNode.btnAccelerate:runAction(self:getScaleAnimation())
    viewNode.Img_Tip:runAction(self:getScaleAnimation())

    viewNode.textDescribe:setString(openTips)
    viewNode.btnAccelerate:getChildByName('Fnt_Accelerate'):setString("邀请好友对局")
  
    -- 播放标题动画('好友助力'循环)
    local aniNode = viewNode.panelCountStatus:getChildByName('Node_AniTitle2')
    aniNode:getChildByName('Panel_5'):getChildByName('Sprite_TitleBG1'):hide()
    aniNode:getChildByName('Panel_5'):getChildByName('Sprite_TitleBG2'):hide()
    aniNode:getChildByName('Panel_5'):getChildByName('Sprite_TitleBG3'):show()
    aniNode:getChildByName('Panel_5'):getChildByName('Sprite_TitleBG4'):hide()
    local aniInfo = {
        aniName = 'animation_loop',
        resPath = 'res/hallcocosstudio/invitegiftactive/animation/ani_title2.csb',
        isLoop = true
    }
    AnimationPlayer:playExistNodeFrameAni(aniNode,aniInfo)
end

-- 领奖阶段界面
function OldUserInitGiftCtrl:setRewardStatus()
    local viewNode = self._viewNode
    self:showPanel(PANEL_TYPE.REWARD)
    viewNode.panelListContent:hide()
    viewNode.imgBarHintReward:hide()
    viewNode.imgBarHintReward2:hide()
    viewNode.Panel_Hint_1:show()
    viewNode.Img_Dot:setVisible(OldUserInviteGiftModel:lookUserListRed())


    viewNode.btnReward:runAction(self:getScaleAnimation())
    local cfg = OldUserInviteGiftModel:getCurTimeActCfgData()
    local openTips = ""
    if OldUserInviteGiftModel.RewardType.YINZI == cfg.RewardType then
        openTips='恭喜获得' .. cfg.RewardNum / 10000 .. '万两银子领取资格'
        viewNode.textTotalRewardCount2:setString(self:formatNum(cfg.RewardNum) .. "两")
        viewNode.textTotalRewardCount:show()
        viewNode.Image_huafeibg2:hide()
    else
        openTips='恭喜获得' .. cfg.RewardNum .. '元话费领取资格'
        local huafei = cfg.RewardNum
        if huafei < 100 then
            huafei = string.format("%.2f",huafei)
        end
        viewNode.textTotalHuafei2:setString(huafei .. "元")
        viewNode.textTotalRewardCount2:hide()
        viewNode.Image_huafeibg2:show()
    end
    viewNode.textDescribe:setString(openTips)

    if not viewNode.ProcessBarReward then
        local bar = self:createProcessBar()
        viewNode.panelBarReward:addChild(bar)
        bar:setPosition(cc.p(viewNode.nodeBarPosReward:getPosition()))
        viewNode.ProcessBarReward = bar
    end

    viewNode.btnInviteMore:hide()
    viewNode.btnReward:show()
    viewNode.dailinquImg:show()
    viewNode.Panel_getted:hide()
    viewNode.gettedBtn:hide()
    viewNode.panelBarReward:show()
    viewNode.btnReward:runAction(self:getScaleAnimation())

    local status = OldUserInviteGiftModel:getInviteRewardStatus()--如果邀请的人数达到 并且每个新人对局数也满足
    if status == OldUserInviteGiftModel.RewardStatus.canGet then
        local progressAction = cc.ProgressTo:create(0.5, 100)
        local sequence = cc.Sequence:create(progressAction, cc.CallFunc:create(function ()
            viewNode.imgBarHintReward2:show()
        end))
        viewNode.ProcessBarReward:runAction(sequence)
        viewNode.imgBarHintReward2:getChildByName('Fnt_BarHint'):setString('可领奖')
        viewNode.Fnt_Reward:setString( "领取奖励" )
    elseif status == OldUserInviteGiftModel.RewardStatus.notGet then
        local progressAction = cc.ProgressTo:create(0.5, (14 / 15) * 100)
        local sequence = cc.Sequence:create(progressAction, cc.CallFunc:create(function ()
            viewNode.imgBarHintReward:show()
        end))
        viewNode.ProcessBarReward:runAction(sequence)

        local str = ""
        local type,num = OldUserInviteGiftModel:getNeedSatisfy()
        if type == 1 then
            str = string.format("仅差%s人",num)
        else
            str = string.format("仅差%s局",num)
        end

        viewNode.imgBarHintReward:getChildByName('Fnt_BarHint'):setString(str)
        viewNode.Fnt_Reward:setString( "邀请好友对局" ) 
    else
        viewNode.dailinquImg:hide()
        viewNode.Panel_getted:show()
        viewNode.gettedBtn:show()
        viewNode.Panel_Hint_1:hide()
        viewNode.panelBarReward:hide()
        viewNode.btnReward:hide()
        local nextCfg = OldUserInviteGiftModel:getNextTimeActCfgData(cfg.RewardType,cfg.Id)
        if OldUserInviteGiftModel.RewardType.YINZI == nextCfg.RewardType then
            local str = (nextCfg.RewardNum / 10000) .. "万两银子"
            viewNode.Text_getted_tip:setString(str)
        else
            local str = nextCfg.RewardNum .. "元话费"
            viewNode.Text_getted_tip:setString(str)
        end
    end
    viewNode.imgTopHint:hide()

    local aniNode = viewNode.panelRewardStatus:getChildByName('Node_AniTitle2')
    aniNode:getChildByName('Panel_5'):getChildByName('Sprite_TitleBG1'):hide()
    aniNode:getChildByName('Panel_5'):getChildByName('Sprite_TitleBG2'):hide()
    aniNode:getChildByName('Panel_5'):getChildByName('Sprite_TitleBG3'):hide()
    aniNode:getChildByName('Panel_5'):getChildByName('Sprite_TitleBG4'):show()
    local aniInfo = {
        aniName = 'animation_loop',
        resPath = 'res/hallcocosstudio/invitegiftactive/animation/ani_title2.csb',
        isLoop = true
    }
    AnimationPlayer:playExistNodeFrameAni(aniNode,aniInfo)
end


function OldUserInitGiftCtrl:textHintShow()
    local viewNode = self._viewNode
    local cfg = OldUserInviteGiftModel:getCurTimeActCfgData()
    local list = OldUserInviteGiftModel:getUserList()
    if cfg.IsShowLimit > 0 or #list > 0 then
        local guideBout = cc.exports.getNewUserGuideBoutCount()
        if not guideBout then guideBout = 0 end

        if cfg.Limit_OldPlayer == 1 then             
            viewNode.textHint1Reward:setString(string.format("邀请%s名好友玩%s局掼蛋领取",cfg.Limit_OldPlayer,cfg.Limit_NewPlayer + guideBout))
        else
            viewNode.textHint1Reward:setString(string.format("邀请%s名好友各玩%s局掼蛋领取",cfg.Limit_OldPlayer,cfg.Limit_NewPlayer + guideBout))
        end
    else
        viewNode.textHint1Reward:setString("邀请好友玩掼蛋即可领取")
    end
    
    local remainSecond = OldUserInviteGiftModel:getCurrentPeriodTime()
    viewNode.textHint2Reward:setString("")
    if remainSecond <= 0 then
        viewNode.textHint2Reward:setString("本期活动已结束")
    else
        local scheduler = cc.Director:getInstance():getScheduler()
        if not self._sheHintID then
            local scheID = scheduler:scheduleScriptFunc(function ()
                local remainSecond = OldUserInviteGiftModel:getCurrentPeriodTime()
                local timeTb = OldUserInviteGiftModel:GetRemainTimeDHM(remainSecond)
                local str = string.format("%d小时%d分钟%d秒后奖励将失效",  timeTb.hour, timeTb.minute,timeTb.second)
                viewNode.textHint2Reward:setString(str)
                if remainSecond <= 0 then
                    viewNode.textHint2Reward:setString("本期活动已结束")
                    OldUserInviteGiftModel:sendInviteGiftData()
                    self:removeSelfInstance()
                end
                
            end, 1, false)
            self._sheHintID = scheID
            table.insert(self._scheduleList, scheID)
        end
    end
  
    self:hintChangeAni()
end


-- 提示语轮播动画
function OldUserInitGiftCtrl:hintChangeAni()
    if not self._sheRunHintID then 
        local scheduler = cc.Director:getInstance():getScheduler()
        local isFirst = true
        local scheID = scheduler:scheduleScriptFunc(function ()
            local aniInfo = {
                -- aniName = 'animation_hint1',
                resPath = 'res/hallcocosstudio/invitegiftactive/olduser/olduserinitgift.csb',
                isLoop = false
            }
            if isFirst then
                aniInfo.aniName = 'animation_hint1'
                isFirst = false
            else
                aniInfo.aniName = 'animation_hint2'
                isFirst = true
            end

            AnimationPlayer:playExistNodeFrameAni(self._viewNode, aniInfo)
        end, 3, false)
        self._sheRunHintID = scheID
        table.insert(self._scheduleList, scheID)
    end
end

-- 通过类型显示对应Panel
function OldUserInitGiftCtrl:showPanel(type)
    local viewNode = self._viewNode
    viewNode.panelUnopen:hide()
    viewNode.panelOpenRes:hide()
    viewNode.panelCountStatus:hide()
    viewNode.panelRewardStatus:hide()
    viewNode.panelFlowView:hide()
    viewNode.panelListContent:hide()
    viewNode.btnClose:show()
    if type == PANEL_TYPE.UNOPEN then
        viewNode.btnClose:hide()
        viewNode.panelUnopen:show()
    elseif type == PANEL_TYPE.OPEN then
        viewNode.panelOpenRes:show()
    elseif type == PANEL_TYPE.COUNT then
        viewNode.panelCountStatus:show()
    elseif type == PANEL_TYPE.REWARD then
        viewNode.panelRewardStatus:show()
    end
end

function OldUserInitGiftCtrl:getScaleAnimation()
    local actScale1 = cc.ScaleTo:create(0.5, 1.1)
    local actScale2 = cc.ScaleTo:create(0.5, 1)
    local sequence = cc.Sequence:create(actScale1, actScale2)
    local animation = cc.RepeatForever:create(sequence)
    return animation
end

function OldUserInitGiftCtrl:createProcessBar()
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/hallcocosstudio/images/plist/OldUserPacket.plist')
    local sprite = display.newSprite()
    sprite:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("hallcocosstudio/images/plist/OldUserPacket/progress_main.png"))
    local progress = cc.ProgressTimer:create(sprite)
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setMidpoint(cc.p(0, 1))
    progress:setBarChangeRate(cc.p(1, 0))
    progress:setPercentage(0)
    return progress
end

-- 格式化数字为带逗号的字符串
function OldUserInitGiftCtrl:formatNum(number)
    local str = tostring(number)
    local len = string.len(str)
    local s1 = string.sub(str, 1, len - 3)
    local s2 = string.sub(str, len - 2)
    return s1 .. ',' .. s2
end

function OldUserInitGiftCtrl:onRollingOver()
    self._viewNode.btnClose:show()
    self:setCountStatus()
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/TestResult.mp3'), false)
end

function OldUserInitGiftCtrl:openBtnClicked()
    OldUserInviteGiftModel:reqAttendActivity()
    my.dataLink(cc.exports.DataLinkCodeDef.OPEND_REDPACKET)
end

-- 分享立领500两
function OldUserInitGiftCtrl:extractBtnClicked()
    print("分享链接或图片")
    self:sendInviteGiftShare()
end

--邀请好友对局
function OldUserInitGiftCtrl:accelerateBtnClicked()
    print("邀请好友对局")
    self:sendInviteGiftShare()
end

function OldUserInitGiftCtrl:lookUpBtnClicked()
    OldUserInviteGiftModel:clickLookUserList()
    local viewNode = self._viewNode
    viewNode.Img_Dot:setVisible(false)
    viewNode.panelListContent:show()
    viewNode.listViewUser:removeAllItems()
    local cfg = OldUserInviteGiftModel:getCurTimeActCfgData()
    local list = OldUserInviteGiftModel:getUserList()
    local node = cc.CSLoader:createNode(InviteGiftUserNodeView.CsbPath)
    local view = my.NodeIndexer(node, InviteGiftUserNodeView.ViewConfig)
    local imageLoaderPlugin = plugin.AgentManager:getInstance():getImageLoaderPlugin()
    for i, v in ipairs(list) do
        my.fitStringInWidget(v.szNickName, view.textName, 155)

        local guideBout = cc.exports.getNewUserGuideBoutCount()
        if not guideBout then guideBout = 0 end

        if v.nBoutNum >= cfg.Limit_NewPlayer then
            v.nBoutNum = cfg.Limit_NewPlayer
        end
        
        view.valueScore:setString(string.format("%d/%d", v.nBoutNum + guideBout, cfg.Limit_NewPlayer + guideBout))
        view.imgIcon:setScale(0.8)
        local imageData = imageLoaderPlugin:getLocalImage_sync(v.nNewUserID, "100-100")
        local path = cc.exports.getHeadResPath(0)
        if imageData and imageData.path and imageData.path ~= ""  then
            path = imageData.path
        end
        view.imgIcon:loadTexture(path)

        local panel = view.backUnit:clone()
        viewNode.listViewUser:pushBackCustomItem(panel)
    end

    viewNode.listViewUser:scrollToTop(0.01, false)
end

function OldUserInitGiftCtrl:rewardBtnClicked()
    if OldUserInviteGiftModel:getInviteRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet then
        local cfg = OldUserInviteGiftModel:getCurTimeActCfgData()
        if OldUserInviteGiftModel.RewardType.YINZI == cfg.RewardType then
            OldUserInviteGiftModel:requireGetAward(0)
        else
            local content = string.format("%s元话费",cfg.RewardNum)
            my.informPluginByName({pluginName='ExchangeHuafeiCtrl',params= {exchangeType = NewUserInviteGiftModel.ExchangeType.OldUser,content = content}})
        end
       
    else
        self:sendInviteGiftShare()
    end
end

function OldUserInitGiftCtrl:closeBtnClicked()
    self:onKeyBack()
    if self._clickCloseBtnCb then
        self._clickCloseBtnCb()
    end
end

-- 开红包成功
function OldUserInitGiftCtrl:onAttendSuccess()
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/OpenRedPacket.mp3'), false)
    local viewNode = self._viewNode
    viewNode.btnOpen:hide()
    viewNode.panelUnopen:getChildByName('Panel_Light'):hide()
    self._enableKeyBack = true
    -- 播放开启动画
    local aniInfo = {
        aniName = 'animation_open',
        resPath = 'res/hallcocosstudio/invitegiftactive/animation/ani_openpacket.csb',
        isLoop = false
    }

    local size = viewNode.panelAnimation:getContentSize()

    AnimationPlayer:playNodeFrameAni(viewNode.panelAnimation, aniInfo, cc.p(250, 295), nil, function(eventName)
        if eventName == 'rotateover' then
            viewNode.panelOpenRes:getChildByName('Node_AniTitle1'):hide()
            self:setOpenStatus()
        elseif eventName == 'shellexit' then
            -- 红包壳子消失
            -- 走进度条
            local progressAction = cc.ProgressTo:create(0.5, 95)
            local sequence = cc.Sequence:create(progressAction, cc.CallFunc:create(function ()
                self:textHintShow()
            end))
            viewNode.ProcessBarOpen:runAction(sequence)
            -- 奖励数值渐显
            local action = cc.FadeTo:create(0.7, 255)
            viewNode.textTotalRewardOpen:runAction(action)

        elseif eventName == 'titleshow' then
            local aniInfo = {
                aniName = 'animation_paper',
                resPath = 'res/hallcocosstudio/invitegiftactive/animation/ani_paper.csb',
                isLoop = false
            }
            AnimationPlayer:playNodeFrameAni(viewNode.panelAnimation, aniInfo, cc.p(250, 385))
        end
    end, function()
        viewNode.panelOpenRes:getChildByName('Node_AniTitle1'):show()
    end)
end

function OldUserInitGiftCtrl:onAttendFailed()
    self._enableKeyBack = true
    self:onKeyBack()
end

function OldUserInitGiftCtrl:helpBtnClicked()
    local content = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/InviteGiftAwardConfig.json")
    local config = cc.load("json").json.decode(content)
    my.informPluginByName({pluginName='ActiveHelpPanelCtrl',params= {content = config.xyhbTxtHelp}})  
end

--分享成功
function OldUserInitGiftCtrl:onShareSuccess()
    --请求立领
    if OldUserInviteGiftModel:getShareTakeRewardStatus() then
        OldUserInviteGiftModel:requireGetShareAward( 1 )
        return 
    end
    --好友助力后请求领取奖励
    if not OldUserInviteGiftModel:isBinding() and  OldUserInviteGiftModel:getInviteClickTakeRewardStatus() == OldUserInviteGiftModel.RewardStatus.canGet then
        OldUserInviteGiftModel:requireGetShareAward( 2 )
        return 
    end
end

-----------------------分享
function OldUserInitGiftCtrl:initShareImg()
    self._viewNode.imgQRCodeBg = self._viewNode:getChildByName("Img_QRCodeBG")
    self._viewNode.panelQRCode = self._viewNode.imgQRCodeBg:getChildByName('Panel_QRCode')
    self._viewNode.panelMask = self._viewNode:getChildByName("Panel_Mask")

    self._viewNode.imgQRCodeBg:hide()
    self._viewNode.panelMask:hide()
end

-- 生成最终的分享图片
function OldUserInitGiftCtrl:generateShareImg(str, path)
    self._viewNode.imgQRCodeBg:show()
    self._viewNode.panelMask:show()
    QRCodeCtrl:drawQRCode(self._viewNode.panelQRCode, str)
    -- 将图片输出到本地
    cc.exports.outputNodeTexture(self._viewNode.imgQRCodeBg, path, cc.IMAGE_FORMAT_JPEG, cc.p(1.67, 1.67))
    my.scheduleOnce(function ()
        self._viewNode.panelQRCode:removeAllChildren()
        self._viewNode.imgQRCodeBg:hide()
        self._viewNode.panelMask:hide()
    end, 0)
end

-- 生成分享的口令
function OldUserInitGiftCtrl:generateShareUrl()
    local userIdStr = tostring(UserModel.nUserID)
    -- local resStr = ""
    -- local len = #userIdStr
    -- local times = math.ceil(len / 3)
    -- local pos = 1
    -- for i = 1, times do
    --     local str = string.sub(userIdStr, pos, pos + 2)
    --     local encodeRes = MCCrypto:encodeBase64(str, #str)
    --     resStr = resStr .. encodeRes .. '/'
    --     pos = pos + 3
    -- end

    local config = OldUserInviteGiftModel:getConfig()
    local reqinfo = NewInviteGiftModel:getWinXinReqInfo()
    local unionId = ""
    if reqinfo and reqinfo.unionId then
        unionId = reqinfo.unionId
    end
    local nickname = ""
    local wxStr = string.format("/%s/%s",unionId,nickname)
    local assitSvrIpSource = config.oldUser.assitsvrip
    local assitSvrIpEncode = string.urlencode(tostring(assitSvrIpSource))
    local assitSvrIp = string.format("connector=%s", assitSvrIpEncode)
    local url = config.oldUser.urlCode.."?"..assitSvrIp.."&c="..userIdStr..wxStr.."/"..config.activityID
    return url
end

local IMG_PATH = "QRCodeBG.jpg"
-- 生成最终的分享图片
function OldUserInitGiftCtrl:generateShareImg(str, path)
    self._viewNode.imgQRCodeBg:show()
    self._viewNode.panelMask:show()
    QRCodeCtrl:drawQRCode(self._viewNode.panelQRCode, str)
    -- 将图片输出到本地
    cc.exports.outputNodeTexture(self._viewNode.imgQRCodeBg, path, cc.IMAGE_FORMAT_JPEG, cc.p(1.67, 1.67))
    my.scheduleOnce(function ()
        self._viewNode.panelQRCode:removeAllChildren()
        self._viewNode.imgQRCodeBg:hide()
        self._viewNode.panelMask:hide()
    end, 0)
end


-- 获取二维码的分享参数列表
function OldUserInitGiftCtrl:getQrCodeShareContent()

    local url = self:generateShareUrl()
    self:generateShareImg(url, IMG_PATH)

    local tbl = {
        content = "",
        title = "",
        image = IMG_PATH,
        description = "",
        type = tostring(cc.exports.C2DXContentType["C2DXContentTypeImage"])
    }

    local fileutils = cc.FileUtils:getInstance()
    local writablePath = fileutils:getGameWritablePath()

    if tbl["image"] then
        tbl["image"] = writablePath .. tbl["image"]
        tbl["imagePath"] = tbl["image"]
    end

    return tbl
end

function OldUserInitGiftCtrl:sendInviteGiftShare()
    -- 图片分享
    if OldUserInviteGiftModel:getDefaultShareType() == 1 then
        my.dataLink(cc.exports.DataLinkCodeDef.SHARE_IMG)
        local shareContent = self:getQrCodeShareContent()
        my.scheduleOnce(function ()
            self:share(shareContent, C2DXPlatType.C2DXPlatTypeWeixiSession)
            --self:onShareSuccess()
        end, 0.3)
    else
        my.dataLink(cc.exports.DataLinkCodeDef.SHARE_LINK)
        local shareContent = self:getShareContent("ToInviteGiftShare")
        shareContent["url"] = self:generateShareUrl()
        self:share(shareContent, C2DXPlatType.C2DXPlatTypeWeixiSession)
        --self:onShareSuccess()
    end

    OldUserInviteGiftModel:reqShareBtnClick()
end


return OldUserInitGiftCtrl