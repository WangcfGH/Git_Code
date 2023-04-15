local NewUserRedbagLoadCtrl=class("NewUserRedbagLoadCtrl", cc.load('BaseCtrl'))
local NewUserInviteGiftModel = require('src.app.plugins.invitegift.newusergift.NewUserInviteGiftModel'):getInstance()
local viewCreater   = import('src.app.plugins.invitegift.newusergift.NewUserRedbagLoadView')
NewUserRedbagLoadCtrl.DJJL_ANI_PATH = "res/hallcocosstudio/invitegiftactive/newuser/djjl.csb"--飞红包
NewUserRedbagLoadCtrl.ZXJL_ANI_PATH = "res/hallcocosstudio/invitegiftactive/newuser/zxjl.csb"
NewUserRedbagLoadCtrl.XRHF_ANI_PATH = "res/hallcocosstudio/invitegiftactive/newuser/xrhf_icon.csb"

function NewUserRedbagLoadCtrl:ctor( param )
    param = param or {}


    self._isGame = param.isGame

    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self.viewNode = viewNode

    self._panelMain =  viewNode.Panel_main
    self._panelGame =  viewNode.Panel_game
    
    self._nodeMainIcon = viewNode.Node_main_icon 
    self._btnOpen =  viewNode.Button_open1 
    self._textMoney = viewNode.Text_money
   
    self._Node_bar = viewNode.Node_bar
 
    self._Ani_RedbagFei = viewNode.Node_RedbagFei
    self._nodeGameIcon = viewNode.Node_game_icon

    self._Text_Money = viewNode.Text_Money
    self._Text_AddMoney = viewNode.Text_AddMoney
    self._Text_Money1 = viewNode.Text_Money1
    self._Button_open = viewNode.Button_open
    self._textAddMoney1 =  viewNode.Text_addMoney1--第一次飘飞动画显示的增加值

    self._panelMain:setVisible(not self._isGame)
    self._panelGame:setVisible(self._isGame)

    if self._isGame then
        self:weimanAction()
    else
        self:normalAction()
    end
    self:onEnter()
    self:initInfo()
    self:initClickEvent()

    self:refresh()
end

function NewUserRedbagLoadCtrl:initInfo()
    local config = NewUserInviteGiftModel:getInviteGiftConfig() or {}
    local info = config.newUser or {}
    self._rewardTime = info.rewardTime or 30--一圈时间
    self._boutRewardTimes = info.boutRewardTimes or 3--累计几次
    self._boutReward = info.boutReward or {0.21,0.10,0.03,0.03,0.03}--进入游戏增加值
    self._timeReward = info.timeReward or 0.01 --每跑一圈加多少
    if not info or not info.totalReward then
        self._totalReward = 10
        return 
    end
    self._totalReward = info.totalReward.rewardNum or 10
end

function NewUserRedbagLoadCtrl:onEnter()
    NewUserRedbagLoadCtrl.super.onEnter(self)
    self:listenTo(NewUserInviteGiftModel, NewUserInviteGiftModel.EVENT_UPDATE_DATA, handler(self, self.refresh))
    self:listenTo(NewUserInviteGiftModel, NewUserInviteGiftModel.EVENT_UPDATE_DATA, handler(self, self.updateActionStatus))
end

function NewUserRedbagLoadCtrl:removeListen()
    self:removeEventHosts()
end

function NewUserRedbagLoadCtrl:normalAction()
 
    local action = cc.CSLoader:createTimeline(self.XRHF_ANI_PATH)
    self._nodeMainIcon:runAction(action)
    if NewUserInviteGiftModel:isCanGetAward() then
        action:play("klq", true)  
    else
        action:play("normal", true) 
    end
end

--领取奖励后更新icon动画状态
function NewUserRedbagLoadCtrl:updateActionStatus()
    if not self.viewNode then return end
    if self._isGame then
        self:weimanAction()
    else
        self:normalAction()
    end
    if self._isGame and NewUserInviteGiftModel:isGetedAward() then
        local action = cc.CSLoader:createTimeline(self.ZXJL_ANI_PATH)
        self._nodeGameIcon:runAction(action)
        action:play("weiman", true) 
    end
end

function NewUserRedbagLoadCtrl:setCallback(callback)
    self._callback = callback
end


function NewUserRedbagLoadCtrl:refresh()
    local data = NewUserInviteGiftModel:getNewUserData()
    local nBoutNum = data.nBoutNum or 0
    self._addMoneyNum = self._boutReward[nBoutNum+1] or 0
    self._curMoneyNum = NewUserInviteGiftModel:getCurPhoneTicket()
    if self._curMoneyNum >= self._totalReward then
        self._curMoneyNum = self._totalReward
    end

    if self._textMoney and self._Text_Money and self._Text_Money1 and self._textAddMoney1 and self._Text_AddMoney and self._curMoneyNum and self._addMoneyNum and self._timeReward then
        self._textMoney:setString(string.format("%.2f元",self._curMoneyNum))
        self._Text_Money:setString(string.format("%.2f元",self._curMoneyNum))
        self._Text_Money1:setString(string.format("%.2f元",self._curMoneyNum))
        self._textAddMoney1:setString(string.format("+%.2f元",self._addMoneyNum))
        self._Text_AddMoney:setString(string.format("+%.2f元",self._timeReward))
    end
end

function NewUserRedbagLoadCtrl:weimanAction()
    local action = cc.CSLoader:createTimeline(self.ZXJL_ANI_PATH)
    self._nodeGameIcon:runAction(action)
    if NewUserInviteGiftModel:isCanGetAward() then
        action:play("klq", true)  
    else
        action:play("weiman", true)   
    end
end

function NewUserRedbagLoadCtrl:enterGameAction()
    local curMoneyNum = NewUserInviteGiftModel:getCurPhoneTicket()
    if curMoneyNum >= self._totalReward then
        return 
    end

    if self._curMoneyNum and curMoneyNum < self._curMoneyNum then
        curMoneyNum = self._curMoneyNum
    end
    curMoneyNum = (math.floor(curMoneyNum * 100 + 0.5)) / 100

    local tempTotalReward = 0
    for i=1, #self._boutReward do
        tempTotalReward = tempTotalReward + self._boutReward[i]
        if tempTotalReward > curMoneyNum then
            self._textAddMoney1:setString(string.format("+%.2f元", self._boutReward[i] or 0))
            break
        end
    end

    if tempTotalReward >= self._totalReward then
        tempTotalReward = self._totalReward
    end

    local action = cc.CSLoader:createTimeline(self.DJJL_ANI_PATH)
    self._Ani_RedbagFei:runAction(action)
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/StartRedbag.mp3'),false)
    action:play("feiAni", false) 
    local function callback(frame)
        if frame and frame:getEvent() == "play_over" then
            self._endFeiAni = false
            self:addMoneyAction(true, tempTotalReward)
        end
    end
    action:setFrameEventCallFunc(callback)
end


function NewUserRedbagLoadCtrl:manAction()
    local total,addmoney = self:getTotalAndAddMoney()
    self._Text_AddMoney:setString(string.format("+%.2f元",addmoney))
    local action = cc.CSLoader:createTimeline(self.ZXJL_ANI_PATH)
    self._nodeGameIcon:runAction(action)
    action:play("man", false)  
    
    local function callback(frame)
        if frame and frame:getEvent() == "play_over" then
            self:weimanAction()
            self:addMoneyAction()
        elseif frame and frame:getEvent() == "playSound" then
            audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/sound/hall/OnlineAward.mp3'),false)
        end
    end
    action:setFrameEventCallFunc(callback)
end

function NewUserRedbagLoadCtrl:getTotalAndAddMoney(isFirst)
    local addmoney = isFirst and self._addMoneyNum or self._timeReward
    local total = self._curMoneyNum + addmoney
    if self._totalReward < total then
        total = self._totalReward
        addmoney = self._totalReward - self._curMoneyNum
        self._Text_AddMoney:setString(string.format("+%.2f元",addmoney))
    end
    return total,addmoney
end

function NewUserRedbagLoadCtrl:addMoneyAction(isFirst, totalRewardNum)
    self:unAddMoneyScheduler()
    local total,addmoney = self:getTotalAndAddMoney(isFirst)

    -- 校正下当前总奖励数值
    if totalRewardNum and totalRewardNum ~= total then
        total = totalRewardNum
        addmoney = total - self._curMoneyNum
    end

    local signMoney = self._curMoneyNum
    local index = 1
    local add = addmoney > 1 and 0.21 or 0.01
    self._shareTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        index = index + 1
        signMoney = signMoney +add
        if signMoney < total then
            self._Text_Money:setString(string.format("%.2f元",signMoney))
            self._Text_Money1:setString(string.format("%.2f元",signMoney))
        else 
            --等飘完红包并且累加完数字才开始转圈
            if not self._endFeiAni then
                self:createProgressRadial( )
                self._endFeiAni = true
            end
            self._curMoneyNum = total
            self._Text_Money:setString(string.format("%.2f元",total))
            self._Text_Money1:setString(string.format("%.2f元",total))
            self:runSequenceAction( self._curMoneyNum >= self._totalReward or self._totalReward - self._curMoneyNum < 0.001 )
            self:unAddMoneyScheduler()
        end
    end, 0.05, false)
end

function NewUserRedbagLoadCtrl:unAddMoneyScheduler()
    if self._shareTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._shareTimerID)
        self._shareTimerID = nil
    end
end


function NewUserRedbagLoadCtrl:updateInfo(data)
   
end

function NewUserRedbagLoadCtrl:initClickEvent()
    self._Button_open:addClickEventListener(handler(self, self.onShowRedbag))
    self._btnOpen:addClickEventListener(handler(self, self.onShowRedbag))
end

function NewUserRedbagLoadCtrl:onShowRedbag()
    my.playClickBtnSound()
    my.informPluginByName({pluginName='NewUserInviteGiftCtrl',params={isGame=self._isGame,removeTime=1.0}})
end
-- 创建环形进度条ProgressTimer
function NewUserRedbagLoadCtrl:createProgressRadial( )
    if not self._timeProgress then 
        cc.SpriteFrameCache:getInstance():addSpriteFrames('res/hallcocosstudio/images/plist/Animation/Ani_NewUserJL.plist')
        local circleSp = display.newSprite()
        circleSp:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("hallcocosstudio/images/plist/Animation/Ani_NewUserJL/gq.png"))
        self._timeProgress = cc.ProgressTimer:create(circleSp)
        self._Node_bar:addChild(self._timeProgress) 
        self._timeProgress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        self._timeProgress:setScale(-1,1)
        self._timeProgress:setMidpoint(cc.p(0.5,0.5))    
        self._timeProgress:setReverseProgress(true)  
        self._timeProgress:setAnchorPoint(cc.p(0.5,0.5))
        self._timeProgress:setPosition(cc.p(0,0))
    end 
    self._timeProgress:setPercentage(0)   
    self._progressRunNum = 0

end
--isMan--提前满值
function NewUserRedbagLoadCtrl:runSequenceAction( isMan )
    self._progressRunNum = self._progressRunNum + 1
    if self._progressRunNum > self._boutRewardTimes or isMan then
        NewUserInviteGiftModel:reqNewUserGetAwarddata()
        return 
    end
    local progressTo = cc.ProgressTo:create(self._rewardTime, 100)

    local anim = cc.CallFunc:create(function()  
        if self._callback then
            self._callback(NewUserInviteGiftModel.GR_NEWUSER_UPDATE_REWARD)
        end
        self:manAction()
    end)  
    
    local clear = cc.CallFunc:create(function()  
        self._timeProgress:setPercentage(0)  
    end)  
    local seq = cc.Sequence:create(progressTo, clear,anim)  
    self._timeProgress:runAction(seq)    
end



return NewUserRedbagLoadCtrl

