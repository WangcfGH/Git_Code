
local NewUserInviteGiftCtrl = class("NewUserInviteGiftCtrl", cc.load('BaseCtrl'))
local viewCreater   = import('src.app.plugins.invitegift.newusergift.NewUserInviteGiftView')
local NewUserInviteGiftModel = require('src.app.plugins.invitegift.newusergift.NewUserInviteGiftModel'):getInstance()
local NewInviteGiftModel        = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()

-- NewUserInviteGiftCtrl.RUN_ENTERACTION = true
NewUserInviteGiftCtrl.GXHD_ANI_PATH = "res/hallcocosstudio/invitegiftactive/newuser/gxhd.csb"
NewUserInviteGiftCtrl.DQJD_ANI_PATH = "res/hallcocosstudio/invitegiftactive/newuser/dqjd.csb"

function NewUserInviteGiftCtrl:onCreate(params)
    params = params or {}
    self._isGame = params.isGame
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self._viewNode = viewNode
    local content = cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/InviteGiftAwardConfig.json")
    self._config = cc.load("json").json.decode(content)
    viewNode.textHelp:setString(self._config.newTxtHelp)
   
    self._isBinding = params.isBinding

    self:initPanel1()
    self:initPanel2()
    self:initClickEvent()
    self:initEvent()

    self:initData()
    self:refreshShow()
end


function NewUserInviteGiftCtrl:initData()
    local config = NewUserInviteGiftModel:getInviteGiftConfig()
    if not config or not config.newUser or not config.newUser.totalReward then
        print("没有数据")
        self._totalReward = 10
        return
    end
    self._totalReward = config.newUser.totalReward.rewardNum
end

--复制口令 未绑定显示 这种面板
function NewUserInviteGiftCtrl:initPanel1()
    local viewNode = self._viewNode
    local panelMain = viewNode.ProjectNode1:getChildByName("Panel_1")
    local playBtn = panelMain:getChildByName("Btn_Play") 
    local closeBtn = panelMain:getChildByName("Btn_close") 
    playBtn:addClickEventListener(handler(self, self.onPlayGame))

    local action = cc.CSLoader:createTimeline(self.GXHD_ANI_PATH)
    viewNode.ProjectNode1:runAction(action)
    action:play("chuxian", false) --chuxian chixu xiaoshi
    local function callback(frame)
        if frame and frame:getEvent() == "play_over" then
            action:play("chixu", true)
        end
    end
    action:setFrameEventCallFunc(callback)


    local function onClickPanel()
        self:closeByActionEnd(action)
    end
    closeBtn:addClickEventListener(onClickPanel)
end

--已经绑定显示这种面板
function NewUserInviteGiftCtrl:initPanel2()
    local viewNode = self._viewNode
    local panelMain = viewNode.ProjectNode2:getChildByName("Panel_1")

    self._aginPlayBtn = panelMain:getChildByName("Btn_AginPlay") 
    self._knowBtn = panelMain:getChildByName("Btn_Know") 
    self._changeBtn = panelMain:getChildByName("Btn_Change")

    local contentBg = panelMain:getChildByName("content_bg")
    local helpBtn = contentBg:getChildByName("Btn_help")
    local textPhoneNum = contentBg:getChildByName("TextPhoneNum")
    self._imgEditBoxBg = contentBg:getChildByName("Img_editBox_bg")
    self._textMoney = contentBg:getChildByName("Text_money")--2.22元
    self._textDiffMoney = contentBg:getChildByName("Text_diff_money")--再领0.42元即可兑换
    self._textTs = contentBg:getChildByName("Text_ts")
    self._endTime = self._textTs:getChildByName("Text_2_7") --3天后失效
    self._imgGeted = contentBg:getChildByName("Img_geted")
    

    local image="res/hallcocosstudio/images/plist/NewUserInviteGift/editbox.png"
    self.editbox = my.createEditBox(textPhoneNum,textPhoneNum,image,cc.c3b(217, 92, 97))

    self._aginPlayBtn:addClickEventListener(handler(self, self.onPlayGame))
    self._changeBtn:addClickEventListener(handler(self, self.onExchange))

    local function onClickHelp()
        self:playEffectOnPress()
        viewNode.panelClick:setVisible(true)
        viewNode.panelHelp:setVisible(true)
    end
    helpBtn:addClickEventListener(onClickHelp)

    local action1 = cc.CSLoader:createTimeline(self.DQJD_ANI_PATH)
    viewNode.ProjectNode2:runAction(action1)
    action1:play("chuxian", false) --chuxian chixu xiaoshi
    local function callback(frame)
        if frame and frame:getEvent() == "play_over" then
            action1:play("chixu", true)
        end
    end
    action1:setFrameEventCallFunc(callback)

    local function onClickPanel()
        self:closeByActionEnd(action1)
    end
    self._knowBtn:addClickEventListener(onClickPanel)
end

function NewUserInviteGiftCtrl:initEvent()
    NewUserInviteGiftModel:reqNewUserGetAwarddata()
    self:listenTo(NewUserInviteGiftModel, NewUserInviteGiftModel.EVENT_UPDATE_DATA, handler(self, self.refreshShow))
end

function NewUserInviteGiftCtrl:initClickEvent()
    local viewNode = self._viewNode
    if not viewNode then return end
    viewNode.panelClick:addClickEventListener(handler(self, self.onCloseHelpPanel))
    viewNode.BtnHelpclose:addClickEventListener(handler(self, self.onCloseHelpPanel))
    viewNode.ButtonClose:addClickEventListener(handler(self, self.onClosePanel))

    
end

function NewUserInviteGiftCtrl:onClosePanel()
    self:playEffectOnPress()
    self:removeSelfInstance()
    --弹窗功能实现
    PluginProcessModel:PopNextPlugin()
end


--在活动期间内
--如果没有绑定关系 复制口令 显示第一种状态
--如果有绑定关系 第二种（继续对局和达到满值时可兑换界面）
function NewUserInviteGiftCtrl:refreshShow()
    if self._isBinding then                           --复制口令 显示复制口令并且为绑定的界面
        self._viewNode.panelInitStatus:show()
        self._viewNode.panelCountStatus:hide()
        return
    else                                      -- 显示再玩一局和兑换界面  
        self._viewNode.panelInitStatus:hide()
        self._viewNode.panelCountStatus:show()
    end
    local data = NewUserInviteGiftModel:getNewUserData()
    local curMoney = data.fPhoneTicket or 0

    if curMoney>= self._totalReward then
        curMoney = self._totalReward
    end
 
    self._textMoney:setString(string.format("%.2f元",curMoney))
    self._textDiffMoney:setString(string.format("再领%.2f元即可兑换",self._totalReward-curMoney))
    
    local time = NewUserInviteGiftModel:getAwardEndTime()
    time = time<=1 and 1 or time 
    self._endTime:setString(string.format("%s天后失效",time))

    local nRewardStatus = data.nRewardStatus or 0--领取状态
    local isChanged = nRewardStatus > 0 --是否兑换过
    local isCanChange = curMoney >= self._totalReward --是否可兌換
    local phoneNum = data.szPhoneNum or ""
    if phoneNum and string.len( phoneNum ) == 11 and my.isNumberByString( phoneNum ) then
        self.editbox:setString(phoneNum)
        self.editbox:setEnabled(false)
        isChanged = true
    end

    if isChanged then                            -- 已经兑换过
        self._imgGeted:setVisible(true)
        self._textTs:setVisible(false)
        self._imgEditBoxBg:setVisible(true)
        self.editbox:setVisible(true)
        self._knowBtn:setVisible(true)
        self._aginPlayBtn:setVisible(false)
        self._changeBtn:setVisible(false)
        self._textDiffMoney:setVisible(false)
    elseif isCanChange and not isChanged then    -- 可兑换
        self._imgGeted:setVisible(false)
        self._textTs:setVisible(true)  
        self._imgEditBoxBg:setVisible(true)
        self.editbox:setVisible(true)
        self._knowBtn:setVisible(false)
        self._aginPlayBtn:setVisible(false)
        self._changeBtn:setVisible(true)
        self._textDiffMoney:setVisible(false)
        --首次可领取埋点
        local info = CacheModel:getCacheByKey(NewUserInviteGiftModel.NEWFIRSTSHOWREWARDPANEL)
        if not info.firstReward or info.firstReward ~= 1 then
            NewUserInviteGiftModel:setPopRewardPanel(1)
            my.dataLink(cc.exports.DataLinkCodeDef.NEW_FIRST_SHOW_REWARD_PANEL)
        end
    else                                         -- 继续对局
        self._imgGeted:setVisible(false)
        self._textTs:setVisible(true)  
        self._imgEditBoxBg:setVisible(false)
        self.editbox:setVisible(false)
        self._knowBtn:setVisible(false)
        self._aginPlayBtn:setVisible(true)
        self._changeBtn:setVisible(false)
        self._textDiffMoney:setVisible(true)
    end
end

function NewUserInviteGiftCtrl:onCloseHelpPanel()
    self:playEffectOnPress()
    self._viewNode.panelClick:setVisible(false)
    self._viewNode.panelHelp:setVisible(false)
end

function NewUserInviteGiftCtrl:onExchange()
    self:playEffectOnPress()
    local viewNode = self._viewNode
    local textPhoneNum=self.editbox:getString()
    local subs =  textPhoneNum:sub(1,1)
	if tonumber(subs) ~= 1 or string.len( textPhoneNum ) < 11 or not my.isNumberByString( textPhoneNum ) then
        self:informPluginByName('TipPlugin',{tipString="请输入正确的手机号"})
        return
	end

    local function sendExchange()
        NewUserInviteGiftModel:requireGetAward(textPhoneNum)
        self:removeSelfInstance()
    end

    my.informPluginByName({pluginName='NewUserInviteTipCtr', params = { phone = textPhoneNum ,item = "10元话费",callBack = sendExchange}})
end

function NewUserInviteGiftCtrl:onPlayGame()
    self:playEffectOnPress()
    print("开始对局",self._isGame)
    if not NewUserInviteGiftModel:isOpenActiveTime() then
        self:informPluginByName('TipPlugin',{tipString="活动已结束"})
        self:removeSelfInstance()
        return
    end
    if self._isGame then
        self:removeSelfInstance()
    else
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end
    
    -- 
end

function NewUserInviteGiftCtrl:closeByActionEnd(action)
    self:playEffectOnPress()
    action:play("xiaoshi", false) --chuxian chixu xiaoshi
    local function callback(frame)
        if frame and frame:getEvent() == "play_close" then
            self:removeSelfInstance()
        end
    end
    action:setFrameEventCallFunc(callback)
end
return NewUserInviteGiftCtrl