
local CharteredRoom = class("CharteredRoom")
local CharterdRoomFriend = require("src.app.Game.mBaseGame.BaseGameCharteredRoom.CharteredRoomFriend")
local CharterdRoomTalk = require("src.app.Game.mBaseGame.BaseGameCharteredRoom.CharteredRoomTalk")
local SKGameDef                     = import("src.app.Game.mSKGame.SKGameDef")
local user=mymodel('UserModel'):getInstance()
local tcyFriendPluginWrapper = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

local friendDes = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
local friendDesConfig = json.decode(friendDes)

local levelstrings      = cc.load('json').loader.loadFile('LevelStrings')
local levelconfig = require('src.app.plugins.personalinfo.LevelConfig')

local event=cc.load('event')
event:create():bind(CharteredRoom)
CharteredRoom.EVENT_QUIT = "quit_game"

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(CharteredRoom,PropertyBinder)

local charteredFlag=0x00010000
local changeEnable=true
local tickoffDes=""
local changeFail=""
local changeTableResultType=
{   
    ["TableFind"]=0,
    ["NeedCreate"]=1,
    ["NoTable"]=2
}
local timer
local quitTimer

local addDes
local hostDes

local MAX_NAME_LENGTH=8

function CharteredRoom:isNodeExist()
    return self._isNodeExist
end

function CharteredRoom:setNodeExist(isNodeExist)
    self._isNodeExist = isNodeExist
end

function CharteredRoom:onNodeEnter()
    self:setNodeExist(true)
    
    self:isHaveFriendMsg()

    self:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_friendSdkNewMsg"],handler(self, self.ShowFriendTipsDot))
end 

function CharteredRoom:onNodeExit()
    self:setNodeExist(false)
    
    self:removeEventHosts()
end

function CharteredRoom:create(gameNode, gameController)
    self._gameController = gameController

    self._textSetLockRoom       = nil
    self._checkBtnSetLockRoom   = nil
    self._imagePlayerInfoHead   = nil


    self._gameController:setDispatcher(self)

    self._charterdRoomFriend = CharterdRoomFriend
    self._charterdRoomFriend._room=self
    self._charterdRoomTalk = CharterdRoomTalk
    self._charterdRoomTalk._room=self

    self._node = cc.CSLoader:createNode("res/GameCocosStudio/CharteredRoom/CharteredRoom.csb")
    
    --先获取变量
    self._friendsSdkBtn = self._node:getChildByName("Operate_Panel"):getChildByName("Btn_Friends")
    self._friendsSdkDot = self._friendsSdkBtn:getChildByName("Img_Dot")
    self._friendsSdkBtn:setVisible(true)
    self._friendsSdkDot:setVisible(false)

    --ccui.Helper:doLayout(self._node)
    local function nodeEventHandler(eventType)
        if eventType == "enter" then
            if self.onNodeEnter then self:onNodeEnter() end
        elseif eventType == "exit" then
            if self.onNodeExit then self:onNodeExit() end
        end
    end
    self._node:registerScriptHandler(nodeEventHandler)

    self:createControlNode()
    local gameOpePanel = gameNode:getChildByName("Operate_Panel")
    gameOpePanel:addChild(self._node)

    self:showTalkInterface()

    self._playerInfo={}
    self:createPlayerFlag()

    self._isStartMatch = false
    self._tempAbortPlayerInfo = nil

    changeEnable=true

    
    local json = cc.load("json").json
    local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
    if( ofile == "")then
        printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
        return
    end
    local des = json.decode(ofile)
    tickoffDes=des["ticktile"]
    changeFail=des["changeFailed"]
    addDes=des["CHARTEREDROOM_FRIENDSOURCE_CHARTEREDROOM"]
    hostDes=des["host"]

    ofile = MCFileUtils:getInstance():getStringFromFile("AppConfig.json")
    if( ofile == "")then
        printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
        return
    end
    des = json.decode(ofile)

    local set = gameOpePanel:getChildByName("Panel_Setting")
    if(set)then
        gameOpePanel:reorderChild(set, gameOpePanel:getChildrenCount()+1)
    end

    local gameOpePanelSize = gameOpePanel:getContentSize()
    self._node:getChildByName("Img_back"):setContentSize(display.size)
    self._node:getChildByName("Img_back"):setPosition(gameOpePanelSize.width / 2, gameOpePanelSize.height / 2)
    self._node:getChildByName("Operate_Panel"):setContentSize(gameOpePanelSize)
    self._node:getChildByName("Operate_Panel"):setPosition(cc.p(gameOpePanelSize.width / 2, gameOpePanelSize.height / 2))
    ccui.Helper:doLayout(self._node:getChildByName("Operate_Panel"))
    my.presetAllButton(self._node)

    local function openFriendSdk()
        my.playClickBtnSound()
        self:openFriendSdk()
    end
    self._friendsSdkBtn:addClickEventListener(openFriendSdk)
    self._friendsSdkBtn:setVisible(cc.exports.isFriendSupported())

    self._node:setLocalZOrder(SKGameDef.SK_ZORDER_CHARTEREDROOM)
    
    --[[ 2018.11.13  好友按钮改成固定显示
    if(cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode())then
        self._friendsSdkBtn:setVisible(false)
    else
        local function openFriendSdk()
            self:openFriendSdk()
        end
        self._friendsSdkBtn:addClickEventListener(openFriendSdk)
    end
    --]]
end

function CharteredRoom:isHaveFriendMsg()
    --好友未读消息
    if self._friendsSdkDot then
        self._friendsSdkDot:setVisible(false)
    end
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        local friendmsgJson = tcyFriendPlugin:getAllUnreadMsgInfo()
        if friendmsgJson and friendmsgJson ~= "" then
            local json = cc.load("json").json
	        local friendmsg = json.decode(friendmsgJson)
            if (friendmsg.unReadInviteCount and friendmsg.unReadMessagesCount ) then
                friendmsg.unReadInviteCount = tonumber(friendmsg.unReadInviteCount)
                friendmsg.unReadMessagesCount = tonumber(friendmsg.unReadMessagesCount)
                if (friendmsg.unReadInviteCount > 0  or friendmsg.unReadMessagesCount > 0 ) then
                    self._friendsSdkDot:setVisible(true)
                end
            end
        end
    end
end

function CharteredRoom:ShowFriendTipsDot()
    print("CharteredRoom:ShowFriendTipsDot")
    if self._friendsSdkDot then
        self._friendsSdkDot:setVisible(true)
    end
end

function CharteredRoom:openFriendSdk()
    if not CenterCtrl:checkNetStatus() then
        return false
    end
    self._friendsSdkDot:setVisible(false)

    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin and tcyFriendPlugin.showChatDialogMain then
        tcyFriendPlugin:showChatDialogMain()
    end

    --测试代码
    --[[local tcyFriendPluginWrapper = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()
    tcyFriendPluginWrapper:testInvitation()]]--
end

function CharteredRoom:createControlNode()
    --[[for i,v in pairs( self._node:getChildByName("Img_back"):getChildren() )do
        local n = v:getName()
        printf(n)
    end]]--

    self._quitBtn = self._node:getChildByName("Operate_Panel"):getChildByName("Btn_quit")
    self._quitBtn:addClickEventListener(function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("CharteredRoom_quitBtn") then
            return
        end
        UIHelper:refreshOpeBegin("CharteredRoom_quitBtn")
        CharteredRoom:dispatchEvent({name=CharteredRoom.EVENT_QUIT})
    end)
    --[[self._quitBtn:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                CharteredRoom:dispatchEvent({name=CharteredRoom.EVENT_QUIT})
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)]]--


    self._text_talk = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_community"):getChildByName("Img_up")
    self._text_tui = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_community"):getChildByName("Img_down")
    self._talkPanel = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_community"):getChildByName("Panel_talk")
    self._friendPanel = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_community"):getChildByName("Panel_friend")
    self._img_check_bk = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_community"):getChildByName("Img_check_bk")

    self._charterdRoomFriend:create(self._friendPanel)
    self._charterdRoomTalk:create(self._talkPanel)

    self._forbiddenBtn = self._node:getChildByName("Operate_Panel"):getChildByName("CheckBox_forbidden")
    self._forbiddenBtn:addEventListenerCheckBox( handler(self,self.onForbiddenBtnChecked) )
    self._textForbidden = self._node:getChildByName("Operate_Panel"):getChildByName("Text_forbidden")
    self._lastCheck=true
    
    self._textSetLockRoom = self._node:getChildByName("Operate_Panel"):getChildByName("Text_setlockroom")
    self._checkBtnSetLockRoom = self._node:getChildByName("Operate_Panel"):getChildByName("CheckBox_setlockroom")
    self._checkBtnSetLockRoom:addEventListenerCheckBox(handler(self, self.onSetLockRoomBtnChecked))
    self._checkBtnSetLockRoom:setSelected(false)

    self._name = self._node:getChildByName("Operate_Panel"):getChildByName("Text_Name")
    --self._name:setString(user.szUtf8Username)
    self._name:setAnchorPoint(cc.p(0.5, 0.5))
    SubViewHelper:refreshSelfName(self._name, 200)

    self._deposit = self._node:getChildByName("Operate_Panel"):getChildByName("Panel__deposit_silver"):getChildByName("Text_silver")
    self._deposit:setString(user.nDeposit)
    self._buyDepositBt = self._node:getChildByName("Operate_Panel"):getChildByName("Panel__deposit_silver"):getChildByName("Btn_pay")
    self._buyDepositBt:addClickEventListener(function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("CharteredRoom_buyDepositBt") then
            return
        end
        UIHelper:refreshOpeBegin("CharteredRoom_buyDepositBt")
        --self:quickPay()
        self._flag:setVisible(false)
        my.informPluginByName({pluginName = "ShopCtrl", params = {defaultPage = "silver"}})
    end)
    self._buyDepositBt:setVisible(cc.exports.isShopSupported())
    --[[self._buyDepositBt:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                self:quickPay()
                self._flag:setVisible(false)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)]]--
    self._scroe = self._node:getChildByName("Operate_Panel"):getChildByName("Panel__deposit"):getChildByName("Text_score")
    self._scroe:setString(user.nScore)
    self._buyBt = self._node:getChildByName("Operate_Panel"):getChildByName("Panel__deposit"):getChildByName("Btn_pay")
    --[[self._buyBt:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                self:quickPay()
                self._flag:setVisible(false)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)]]--

    local con = cc.exports.GetRoomConfig()

    self._right = self._node:getChildByName("Operate_Panel"):getChildByName("Text_right")
    local remiand = require("src.app.Game.mMyGame.GamePublicInterface"):getRemiandRoundCount()
    local rightDes = string.format(con["DAY_REMIAND"],tonumber(remiand))
    self._right:setString(con["CHARTERED_RIGHT"]..rightDes)

    self._ready = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_position"):getChildByName("Btn_ready")
    self._ready:addClickEventListener(function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("CharteredRoom_readyBt") then
            return
        end
        UIHelper:refreshOpeBegin("CharteredRoom_readyBt")

        self:gameReady()
        self._flag:setVisible(false)
    end)
    --[[self._ready:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                self:gameReady()
                self._flag:setVisible(false)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)]]--
    self._ready:getChildByName("Img_text_f"):setVisible(false)
    self._cancel= self._node:getChildByName("Operate_Panel"):getChildByName("Panel_position"):getChildByName("Btn_cancel")
    self._cancel:addClickEventListener(function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("CharteredRoom_cancelBt") then
            return
        end
        UIHelper:refreshOpeBegin("CharteredRoom_cancelBt")

        if self:isStartMatch() then
            self:onCancelTeamMatch()
            self._flag:setVisible(false)
        else
            self:onTeamGameStartBtnShow(true)
            self:dealWithChairSystemFindBtns()
        end         
    end)
    --[[self._cancel:onTouch(function (e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0) 
                if self:isStartMatch() then
                    self:onCancelTeamMatch()
                    self._flag:setVisible(false)
                else
                    self:onTeamGameStartBtnShow(true)
                    self:dealWithChairSystemFindBtns()
                end         
                --[[local con = cc.exports.GetRoomConfig()
                local des = con["TEAMR_ROOM_FAILD_TIPS"]
                my.informPluginByName({pluginName='ToastPlugin',params={tipString=des,removeTime=5}})                
                self._gameController:onKeyBack()]]
            --[[elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then
            end
    end)]]--

    self._start = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_position"):getChildByName("Btn_start")
    self._start:addClickEventListener(function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("CharteredRoom_startBt") then
            return
        end
        UIHelper:refreshOpeBegin("CharteredRoom_startBt")

        self:gameReady()
        self._flag:setVisible(false)
    end)
    --[[self._start:onTouch(function (e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                self:gameReady()
                self._flag:setVisible(false)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then
            end
    end)]]--

    self._gotoGame = self._node:getChildByName("Operate_Panel"):getChildByName("Btn_backtogame")
    self._gotoGame:setVisible(false)
    self._gotoGame:addClickEventListener(function()
        my.playClickBtnSound()

        self:hide()
    end)
    --[[self._gotoGame:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                self:hide()
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)]]--


    self._find = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_position"):getChildByName("Btn_system")
    self._find:addClickEventListener(function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("CharteredRoom_findBt") then
            return
        end
        UIHelper:refreshOpeBegin("CharteredRoom_findBt")

        self:systemFind()
        self._flag:setVisible(false)
    end)
    --[[self._find:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                self:systemFind()
                self._flag:setVisible(false)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)]]--
    self._findFromSDK = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_position"):getChildByName("Btn_invite")
    if not cc.exports.isSocialSupported() then
        self._findFromSDK:setVisible(false)
    end
    self._findFromSDK:addClickEventListener(function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("CharteredRoom_findFromSDKBt") then
            return
        end
        UIHelper:refreshOpeBegin("CharteredRoom_findFromSDKBt")

        self:systemFindFromSDK()
        self._flag:setVisible(false)
    end)
    --[[self._findFromSDK:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                self:systemFindFromSDK()
                self._flag:setVisible(false)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)]]--
     
     self._btnSet = self._node:getChildByName("Operate_Panel"):getChildByName("Btn_set")
     self._btnSet:addClickEventListener(function()
        my.playClickBtnSound()

        self._gameController:onSetting()
        self._flag:setVisible(false)
    end)
     --[[self._btnSet:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                self._gameController:onSetting()
                self._flag:setVisible(false)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)]]--

    self.Img_mem=self._node:getChildByName("Operate_Panel"):getChildByName("Img_mem")
    self.Img_mem_f=self._node:getChildByName("Operate_Panel"):getChildByName("Img_mem_f")

    self.Img_mem:setVisible(false)
    self.Img_mem_f:setVisible(false)
    
     self:setPermissions()

     local count = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()
     local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
     
     self.limitMin = count
     if roomInfo["type"] ~= 9 and roomInfo["type"] ~= 8 then   --�走��Ϸ��ʱд�� 8,9�����˶�ս
        count = 2
        self.limitMin = 1
     else
        self.limitMin = 4
     end
     self.limitMax = count
     --[[local roomCount = roomInfo["limitMin"]
     if roomCount then
        self.limitMin = roomCount
     end]]

     local panelName = "Panel_"..tostring(count)
     self._panelPosition = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_position"):getChildByName(panelName)
     self._panelPosition:setVisible(true)
     self._originalPos={}
     for i,v in pairs(self._panelPosition:getChildren())do
        local chair = v:getName()
        local pos={}
        pos.x=v:getPositionX()
        pos.y=v:getPositionY()
        self._originalPos[chair]=pos
     end

     -- screen relocation
     local gap = cc.Director:getInstance():getWinSizeInPixels().height-720
     self._quitBtn:setPositionY(self._quitBtn:getPositionY()+gap)
     self._node:getChildByName("Operate_Panel"):getChildByName("Panel__deposit"):setPositionY(self._node:getChildByName("Operate_Panel"):getChildByName("Panel__deposit"):getPositionY()+gap)
     self.Img_mem:setPositionY(self.Img_mem:getPositionY()+gap)
     self.Img_mem_f:setPositionY(self.Img_mem_f:getPositionY()+gap)
     self._btnSet:setPositionY(self._btnSet:getPositionY()+gap)
     local upName = self._node:getChildByName("Operate_Panel"):getChildByName("Text_Name")
     upName:setPositionY(upName:getPositionY()+gap)
     self._gotoGame:setPositionY(self._gotoGame:getPositionY()+gap)
     local Img_bk =  self._node:getChildByName("Operate_Panel"):getChildByName("Img_bk")
     Img_bk:setPositionY(Img_bk:getPositionY()+gap)
     local panel_conmmunity = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_community")
     local panel_position = self._node:getChildByName("Operate_Panel"):getChildByName("Panel_position")
     local Img_right_bk = self._node:getChildByName("Operate_Panel"):getChildByName("Img_right_bk")
     local text_right = self._node:getChildByName("Operate_Panel"):getChildByName("Text_right")
     local text_forbidden = self._node:getChildByName("Operate_Panel"):getChildByName("Text_forbidden")
     local checkBox_forbidden = self._node:getChildByName("Operate_Panel"):getChildByName("CheckBox_forbidden")
     panel_conmmunity:setPositionY(panel_conmmunity:getPositionY()+gap/3)
     panel_position:setPositionY(panel_position:getPositionY()+gap/3)
     Img_right_bk:setPositionY(Img_right_bk:getPositionY()+gap/3)
     text_right:setPositionY(text_right:getPositionY()+gap/3)
     text_forbidden:setPositionY(text_forbidden:getPositionY()+gap/3)
     checkBox_forbidden:setPositionY(checkBox_forbidden:getPositionY()+gap/3)
     --self._gotoGame:setPositionY(self._gotoGame:getPositionY()+gap/3)

     if not cc.exports.isSocialSupported() then
        self._text_tui:setVisible(false)
     end
end

function CharteredRoom:onTeamGameStartBtnShow(bShow)
    if self._gameController:isTeamGameRoom() and self:isRoomHost() then
        if self._start then
            self._start:setBright(bShow)
            self._start:setTouchEnabled(bShow)
            self._start:setVisible(bShow)
            
            self:dealWithStartButtonStatus()
        end
        if self._cancel then
            self._cancel:setBright(not bShow)
            self._cancel:setTouchEnabled(not bShow)
            self._cancel:setVisible(not bShow)
        end
        self._ready:setVisible(false)
    end
end

function CharteredRoom:onTalkBtnChecked()
    my.playClickBtnSound()
    self._flag:setVisible(false)
    self:showTalkInterface()
end

function CharteredRoom:onFriendBtnChecked()
    my.playClickBtnSound()
    self._flag:setVisible(false)
    self:showFriendInterface()
end

function CharteredRoom:showTalkInterface()
    self._text_talk:setVisible(true)
    self._text_tui:setVisible(false)
    self._talkPanel:setVisible(true)
    self._friendPanel:setVisible(false)
    CharterdRoomTalk:onEnterForgroud()
end

function CharteredRoom:showFriendInterface()
    self._text_talk:setVisible(false)
    self._text_tui:setVisible(true)
    self._talkPanel:setVisible(false)
    self._friendPanel:setVisible(true)
    self._charterdRoomFriend:update()
    CharterdRoomTalk:onEnterBackground()
end

function CharteredRoom:onForbiddenBtnChecked(sender,eventType)
    self._flag:setVisible(false)
    if(eventType == ccui.CheckBoxEventType.selected)then
        self._lastCheck=true
        self:forbiddenStranger(false)
        self._forbiddenBtn:setTouchEnabled(false)
    elseif(eventType == ccui.CheckBoxEventType.unselected)then
        self._lastCheck=false
        self:forbiddenStranger(true)
        self._forbiddenBtn:setTouchEnabled(false)
    end
end

function CharteredRoom:onSetLockRoomBtnChecked(sender, eventType)
    self._flag:setVisible(false)
    self._checkBtnSetLockRoom:setTouchEnabled(false)
    self:setLockTeamRoom(eventType == ccui.CheckBoxEventType.selected)
end

function CharteredRoom:onCallbackSetStatusHanlder(response, dataMap)
     self._forbiddenBtn:setTouchEnabled(true)
     if(response ~= 10)then
        
        if(self._lastCheck==false)then
            self._lastCheck=true
            self._forbiddenBtn:setSelected(true)
        else
            self._lastCheck=false
            self._forbiddenBtn:setSelected(false)
        end

     end
end

function CharteredRoom:onTeamRoomLockedStatusChanged(response, dataMap)
     self._checkBtnSetLockRoom:setTouchEnabled(true)

     if(response ~= 10)then       
        self._checkBtnSetLockRoom:setSelected(not self._checkBtnSetLockRoom:isSelected())
     end
end

function CharteredRoom:forbiddenStranger(f)
    local nIsOpening
    if(f)then
        nIsOpening = 0
    else
        nIsOpening = 1
    end

    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()

    local param={}
    param.nUserID       = playerInfoManager:getSelfUserID()
    param.nRoomID       = utilsInfoManager:getRoomID()
    param.nTableNO      = playerInfoManager:getSelfTableNO()
    param.nChairNO      = playerInfoManager:getSelfChairNO()
    param.nIsOpening    = nIsOpening

    cc.exports.PUBLIC_INTERFACE.SetForbiddenStatus( param, handler(self,self.onCallbackSetStatusHanlder) )

end

function CharteredRoom:setLockTeamRoom(bLocked)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()

    local param={}
    param.nUserID           = playerInfoManager:getSelfUserID()
    param.nRoomID           = utilsInfoManager:getRoomID()
    param.nTableNO          = playerInfoManager:getSelfTableNO()
    param.nChairNO          = playerInfoManager:getSelfChairNO()
    --param.nIsOpening        = not bLocked

    if bLocked == true then
        cc.exports.PUBLIC_INTERFACE.LockTable(param, handler(self, self.onTeamRoomLockedStatusChanged))
    else
        cc.exports.PUBLIC_INTERFACE.UnLockTable(param, handler(self, self.onTeamRoomLockedStatusChanged))
    end
end

function CharteredRoom:quickPay()
    if payModel then
        payModel.quickCharge()
    end
end

function CharteredRoom:isCharteredRoom()
    return self._gameController:isCharteredRoom()
end

local function touchEnable_ready(ready, enable)
    ready:setTouchEnabled(enable)
    ready:setBright(enable)
    --ready:getChildByName("Img_text"):setVisible(enable)
    --ready:getChildByName("Img_text_f"):setVisible(not enable)
end

function CharteredRoom:show(showReady)
    if not self:isCharteredRoom() then
        printf("~~~~~~~~~~not create chartered room~~~~~~~~~~~~~~~")
        return
    end

    self._node:setVisible(true)
    if(showReady)then
        touchEnable_ready(self._ready, true)

        self._gotoGame:setVisible(false)
        self._quitBtn:setVisible(true)
    else
        touchEnable_ready(self._ready, false)

        self._gotoGame:setVisible(true)
        self._quitBtn:setVisible(false)
    end

    self._quitBtn:setBright(true)
    self._quitBtn:setTouchEnabled(true)

	local resultPanel = self._gameController._baseGameScene:getResultPanel()
	if (resultPanel)then
	    resultPanel:hideResultPanel()
	end
    
	local info, i = self:SearchPlayer(user.nUserID)
	if info then
        touchEnable_ready(self._ready, not info.isReady)
    end
    
    self._scroe:setString(user.nScore)
    self._deposit:setString(user.nDeposit)
end

function CharteredRoom:hide()
    if not self:isCharteredRoom() then
        printf("~~~~~~~~~~not create chartered room~~~~~~~~~~~~~~~")
        return
    end
    self._node:setVisible(false)
end

function CharteredRoom:isVisible()
    if not self:isCharteredRoom() then
        return false
    end
    if self._node then
        return self._node:isVisible()
    end
    return false
end

function CharteredRoom:gameReady()
    self._gameController:playBtnPressedEffect()
    self._gameController:onStartGame()
end

function CharteredRoom:onCancelTeamMatch()
    if self._gameController then
        self._gameController:onCancelTeamMatch()
    end
end

local time=0
function CharteredRoom:changeDes()
    self._find:stopAllActions()
    time = time - 1
    if(time<=0)then
        self._find:setTouchEnabled(true)
        self._find:setBright(true)
        local count = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()
        if(table.maxn(self._playerInfo)>=count)then
           self._find:setTouchEnabled(false)
           self._find:setBright(false)
        end
        local con = cc.exports.GetRoomConfig()
        self._find:setTitleText(con["SYSTEM_FIND_TITLE"])
    else
        local con = cc.exports.GetRoomConfig()
        local des = con["SYSTEM_FIND_TITLE"].."("..tostring(time).."s)"
        self._find:setTitleText(des)

	    local a2 = cc.DelayTime:create(1)
	    local a4 = cc.Sequence:create(a2,cc.CallFunc:create(function() 
            self:changeDes() 
        end))
        self._find:runAction(a4)
    end
end

function CharteredRoom:systemFind()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()

    local param={}
    param.nUserID       = playerInfoManager:getSelfUserID()
    param.nRoomID       = utilsInfoManager:getRoomID()
    param.nGameID       = utilsInfoManager:getGameID()
    param.nTableNO      = playerInfoManager:getSelfTableNO()
    param.nChairNO      = playerInfoManager:getSelfChairNO()
    param.szHardID      = utilsInfoManager:getHardID()

    cc.exports.PUBLIC_INTERFACE.SystemFind( param )

    self._find:setTouchEnabled(false)
    self._find:setBright(false)
    time=10
    local con = cc.exports.GetRoomConfig()
    local des = con["SYSTEM_FIND_TITLE"].."("..tostring(time).."s)"
    self._find:setTitleText(des)

	local a2 = cc.DelayTime:create(1)
	local a4 = cc.Sequence:create(a2, cc.CallFunc:create(function() 
        self:changeDes() 
        end))

    self._find:runAction(a4)

end

function  CharteredRoom:systemFindFromSDK()
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        tcyFriendPlugin:showFriendListDialog()
    end

    --my.testInvitation()
end

function CharteredRoom:onEnterGameOK(gameEnterInfo, soloPlayers)
    
    --about bat
    local base
    if cc.exports.isDepositSupported() then
        base=gameEnterInfo.nBaseDeposit
    else
        if cc.exports.isScoreSupported() then
            base=gameEnterInfo.nBaseScore
        end
    end

    if(base==0)then
        self._node:getChildByName("Operate_Panel"):getChildByName("Text_bat"):setVisible(false)
    else
        local json = cc.load("json").json
        local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
        if( ofile == "")then
            printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
            return
        end
        local des = json.decode(ofile)
        local title = des["bat"]

        self._node:getChildByName("Operate_Panel"):getChildByName("Text_bat"):setString(title..tostring(base))
        self._node:getChildByName("Operate_Panel"):getChildByName("Text_bat"):setVisible(true)
    end

    --recover to no one in chiar
     for z=1,gameEnterInfo.nTotalChair do
        local chair = self:getChairNodeName(z - 1)
        if(chair)then
            local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
            change:onTouch(function(e)
                if(e.name=='began')then

                elseif(e.name=='ended')then
                    self._flag:setVisible(false)
                    self:changeChair(z-1)
                elseif(e.name=='cancelled')then

                elseif(e.name=='moved')then

                end
            end)

            local invite = chair:getChildByName("Img_head"):getChildByName("Btn_invite")
            invite:onTouch(function(e)
                if(e.name=='began')then

                elseif(e.name=='ended')then
                    self._flag:setVisible(false)
                    self:systemFindFromSDK()
                elseif(e.name=='cancelled')then

                elseif(e.name=='moved')then

                end
            end)

            if self._gameController:isTeamGameRoom() then
                change:setVisible(false)
            else
                change:setVisible(true)
            end

            local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
            ready:setVisible(false)

            local f = chair:getChildByName("Img_head"):getChildByName("Img_friend")
            f:setVisible(false)

            local b = chair:getChildByName("Img_head"):getChildByName("Btn_head")
            b:setVisible(false)

            local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	        h:setVisible(false)

            local name = chair:getChildByName("Img_head"):getChildByName("Text_name")
            local con = cc.exports.GetRoomConfig()
            name:setString(con["WAIT_ENTER"])
        end
    end

    --reset chair pos
    for i,v in pairs(self._originalPos)do
        local chair = self._panelPosition:getChildByName(i)
        chair:setPosition(v)
    end

    --reset ready
    touchEnable_ready(self._ready, true)
    self:onTeamGameStartBtnShow(true)

    local currentChair
    self._playerInfo=soloPlayers
    for i,v in pairs(self._playerInfo)do
        local chair = self:getChairNodeName(v.nChairNO)
        if(chair)then
            local hostID=user.hostID

            local name = chair:getChildByName("Img_head"):getChildByName("Text_name")
            local msg = MCCharset:getInstance():gb2Utf8String( v.szUserName,string.len(v.szUserName) )
            name:setString(msg)

            if(v.nUserID==hostID)then
                local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	            h:setVisible(true)
            else
                local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	            h:setVisible(false)
            end 

            local f = chair:getChildByName("Img_head"):getChildByName("Img_friend")
            f:setVisible(false)

            local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
            if tcyFriendPlugin then
                if(tcyFriendPlugin:isFriend(v.nUserID))then
                    local remark = tcyFriendPlugin:getRemarkName(v.nUserID)
                    if(remark~=nil)then
                        if(remark~="")then
                            if(v.nUserID==hostID)then
                                name:setString(hostDes..remark)
                            else
                                name:setString(remark)
                            end
                        end
                    end 

                    f:setVisible(true)
                end

            end
            local gg=MCCharset:getInstance():utf82GbString(name:getString(),string.len(name:getString()) )
            --[[local len=string.len(gg)
            if(len>MAX_NAME_LENGTH)then
                gg=string.sub(gg,0,MAX_NAME_LENGTH-2).."..."
                local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))
                name:setString(newName)
            end]]
            local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))

            if self:isMyself(v.nUserID) then
                newName = user.szUtf8Username
            end

            my.fixUtf8Width(newName, name, 88)


            local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
            change:setVisible(false)

            if( bit.band(gameEnterInfo.dwUserStatus[i], BaseGameDef.BASEGAME_US_GAME_STARTED)~=BaseGameDef.BASEGAME_US_GAME_STARTED )then
                local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
                ready:setVisible(false)
                v.isReady=false
            else
                local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
                ready:setVisible(true)
                v.isReady=true
            end
            v.readyTime=20
            v.hasPlayed=false

            local b = chair:getChildByName("Img_head"):getChildByName("Btn_head")
            if b then
                b:setVisible(true)
                local bSex = 1
                if v then
                    bSex = v.nNickSex
                end

                b:loadTextureNormal(self:_getHeadResPath(v.nUserID, bSex), ccui.TextureResType.localType)
                b:loadTexturePressed(self:_getHeadResPath(v.nUserID, bSex),ccui.TextureResType.localType)
                b:onTouch(function(e)
                    if(e.name=='began')then

                    elseif(e.name=='ended')then
                        local pos={}
                        pos.x=400
                        pos.y=360
                        local position = b:getParent():convertToWorldSpace(cc.p(b:getPosition()))
                        position.x = position.x + 50
                        position.y = position.y - 160
                        pos = position
                        self:showFlag(v.nUserID,pos,true,addDes)
                    elseif(e.name=='cancelled')then

                    elseif(e.name=='moved')then

                    end
                end)
            end

            --lbs and url
            if(user.nUserID == v.nUserID)then
                currentChair=v.nChairNO
                local imageCtrl = require('src.app.BaseModule.ImageCtrl')
                local t = imageCtrl:getPortraitCacheForGS()
                if(t.url==nil)then
                v.url=""
                else
                v.url=t.url
                end

                --lbs
                if(tcyFriendPlugin and tcyFriendPlugin.getPositionInfo)then
                    local positionInfo = tcyFriendPlugin:getPositionInfo()
                    local info={}
                    if positionInfo then
                        info["la"]=positionInfo.latitude
                        info["lo"]=positionInfo.longitude
                        info["po"]=positionInfo.provinceName
                        info["ci"]=positionInfo.cityName
                        info["di"]=positionInfo.districtName
                        info["st"]=positionInfo.streetName
                        info["bu"]=positionInfo.buidingName
                        local json = cc.load("json").json
                        local lbs = json.encode(info)
                        v.lbs=lbs
                        printf("~~~~~~~~~~lbs lenth[%d] [%s]~~~~~~~~~~~~~~",string.len(v.lbs),v.lbs)
                    else
                        printf("positionInfo is nil")
                        v.lbs=""
                    end
                end
                --lbs end

            end

        end
    end

    self:setFinalChairPosition(currentChair)
    self:dealWithChairSystemFindBtns()

    local count = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()
    if(table.maxn(self._playerInfo)>=count)then
        self._find:setTouchEnabled(false)
        self._find:setBright(false)
        self._findFromSDK:setTouchEnabled(false)
        self._findFromSDK:setBright(false)
    end

    --start count tickoff
    if(self._countTickoffTimer)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._countTickoffTimer)
        self._countTickoffTimer=nil
    end
    self._countTickoffTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countTickoffTime), 1, false)

    --get path
    self:getSelfHeadImage()

    self._maxPlayer=gameEnterInfo.nTotalChair

    --set isDXXW 
    self._charterdRoomTalk.isDXXW = false

    --about tip sdk
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        if(cc.exports.sdkSession)then
            tcyFriendPlugin:onAgreeToBeInvitedBack(cc.exports.sdkSession, cc.exports.AgreeToBeInvitedType.kAgreeToBeInvitedSuccess,"")
            printf("~~~~~~~~~~~~~onAgreeToBeInvitedBack ok~~~~~~~~~~~~~~")
            dump(cc.exports.sdkSession)
            cc.exports.sdkSession=nil
        end
    end

    --about host button
    if (table.maxn(self._playerInfo)==1) then
        user.hostID=user.nUserID
        --PUBLIC_INTERFACE.GetEnterGameInfo().tableHostId=user.nUserID
        PUBLIC_INTERFACE.SetHostIdOfEnterTeamInfo(user.nUserID)
    end

    self:setPermissions()
    self._charterdRoomTalk:quit()
     
end

function CharteredRoom:_getHeadResPath(userId, nickSex)
    local nickSexChecked = user:getNickSexWithCheckSelf(userId, nickSex)
    return cc.exports.getHeadResPath(nickSexChecked)
end

function CharteredRoom:clearPlayers()
	for i = 1, self._gameController:getTableChairCount() do
		table.remove(self._playerInfo, 1)
		local nChairNO = i -1
	    local chair = self:getChairNodeName(nChairNO)
	    if(chair)then
	        local name = chair:getChildByName("Img_head"):getChildByName("Text_name")
	        local nameTx = cc.exports.GetRoomConfig()["WAIT_ENTER"]
	        name:setString(nameTx)

	        local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
	        change:onTouch(function(e)
	                if(e.name=='began')then

	                elseif(e.name=='ended')then
	                    self._flag:setVisible(false)
	                    self:changeChair(nChairNO)
	                elseif(e.name=='cancelled')then

	                elseif(e.name=='moved')then

	                end
	            end)

	        local invite = chair:getChildByName("Img_head"):getChildByName("Btn_invite")
	        if self._gameController:isTeamGameRoom() then
	            change:setVisible(false)
                if cc.exports.isSocialSupported then
	                invite:setVisible(true)
                else
                    invite:setVisible(false)
                end
	        else
	            change:setVisible(true)
	            invite:setVisible(false)
	        end

	        local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
	        ready:setVisible(false)

	        local f = chair:getChildByName("Img_head"):getChildByName("Img_friend")
	        f:setVisible(false)

	        local b = chair:getChildByName("Img_head"):getChildByName("Btn_head")
	        b:setVisible(false)

            local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	        h:setVisible(false)
	    end
	end
end
function CharteredRoom:onCancelTeamMatchOK(hostID)
    self:stopMatchStartedTimer()
    self:stopMatchTimeoutTimer()
    self:onTeamGameStartBtnShow(true)

    if self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() then
        if self._quitBtn then
            self._quitBtn:setBright(true)
            self._quitBtn:setTouchEnabled(true)

            self:setStartMatch(false)
            self:dealWithChairSystemFindBtns()
        end
    end

    local chair = -1
    for i,v in pairs(self._playerInfo)do
        if(hostID == v.nUserID)then
            chair =  v.nChairNO
            v.isReady = false
        end
    end
    if(chair == -1)then
        return
    end

    local chair = self:getChairNodeName(chair)
    if chair then
        local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
        if ready then
            ready:setVisible(false)
        end
    end

    if self._gameController:isTeamGameRoom() then
        if self._tempAbortPlayerInfo ~= nil then
            local userName = MCCharset:getInstance():gb2Utf8String(self._tempAbortPlayerInfo.szUserName, string.len(self._tempAbortPlayerInfo.szUserName))
            self:onCustomerServiceTalked(userName .. friendDesConfig["CHARTEREDROOM_NOTIFY_MATCHOFFLINE"])

            self._tempAbortPlayerInfo = nil
        else
            self:onCustomerServiceTalked(friendDesConfig["CHARTEREDROOM_NOTIFY_MATCHCANCELED"])
        end
    end
end

function CharteredRoom:onPlayerAbort(soloPlayer)
    if(soloPlayer==nil or soloPlayer.nTableNO < 2000)then
        return
    end

    local userName = ""
    local chair = self:getChairNodeName(soloPlayer.nChairNO)
    if(chair)then
        local name = chair:getChildByName("Img_head"):getChildByName("Text_name")
        local nameTx = cc.exports.GetRoomConfig()["WAIT_ENTER"]
        name:setString(nameTx)

        local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
        change:onTouch(function(e)
                if(e.name=='began')then

                elseif(e.name=='ended')then
                    self._flag:setVisible(false)
                    self:changeChair(soloPlayer.nChairNO)
                elseif(e.name=='cancelled')then

                elseif(e.name=='moved')then

                end
            end)

        local invite = chair:getChildByName("Img_head"):getChildByName("Btn_invite")
        if self._gameController:isTeamGameRoom() then
            change:setVisible(false)
            if self:isCurrentPlayerHost() and cc.exports.isSocialSupported() then
                invite:setVisible(true)
            else
                invite:setVisible(false)
            end
        else
            change:setVisible(true)
            invite:setVisible(false)
        end

        local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
        ready:setVisible(false)

        local f = chair:getChildByName("Img_head"):getChildByName("Img_friend")
        f:setVisible(false)

        local b = chair:getChildByName("Img_head"):getChildByName("Btn_head")
        b:setVisible(false)

        local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	    h:setVisible(false)
        local v, i = self:SearchPlayer(soloPlayer.nUserID)
        if v ~= nil then
            userName = v.szUserName
            table.remove(self._playerInfo,i)
            if(self._flagUserID == soloPlayer.nUserID)then
                self._flag:setVisible(false)
            end
        end

        local count = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()
        if(table.maxn(self._playerInfo)>=count)then
            self._find:setTouchEnabled(false)
            self._find:setBright(false)
            self._findFromSDK:setTouchEnabled(false)
            self._findFromSDK:setBright(false)
        else
            self._find:setTouchEnabled(true)
            self._find:setBright(true)
            self._findFromSDK:setTouchEnabled(true)
            self._findFromSDK:setBright(true)
        end

    end

    self:dealWithStartButtonStatus()

    local des
    local json = cc.load("json").json
    local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
    if( ofile == "")then
        printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
        return
    end
    if( (self._node:isVisible()==false)and(soloPlayer.nUserID ~= user.nUserID) )then
        local opt = json.decode(ofile)
        userName=MCCharset:getInstance():gb2Utf8String( userName,string.len(userName) )

        if(user.nUserID==user.hostID)then
            des=userName..opt['leaveToClient']
        elseif(user.hostID ~= soloPlayer.nUserID)then
            des=userName..opt['leaveToHost']
        end
    end

    if self:isStartMatch() then
        soloPlayer.szUserName = userName
        self._tempAbortPlayerInfo = soloPlayer
    end

    if(des)then
        if not self:isVisible() then
            if self._gameController:isCharteredRoom() and not self._gameController:isRandomRoom() then
                my.informPluginByName({pluginName='ToastPlugin',params={tipString=des,removeTime=5}})
            elseif self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() then
            end
        end
    end
end

function CharteredRoom:onPlayerEnter(soloPlayer)
    if(soloPlayer==nil)then
        return
    end

   local chair = self:getChairNodeName(soloPlayer.nChairNO)
   if (chair)then
        local name = chair:getChildByName("Img_head"):getChildByName("Text_name")
        local msg = MCCharset:getInstance():gb2Utf8String( soloPlayer.szUserName,string.len(soloPlayer.szUserName) )
        name:setString(msg)
                    
        local f = chair:getChildByName("Img_head"):getChildByName("Img_friend")
        f:setVisible(false)

        local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
        if tcyFriendPlugin then
            if(tcyFriendPlugin:isFriend(soloPlayer.nUserID))then
                local remark = tcyFriendPlugin:getRemarkName(soloPlayer.nUserID)
                if(remark~=nil)then
                    if(remark~="")then
                        name:setString(remark)
                    end
                end
                f:setVisible(true)
            end

        end
        local gg=MCCharset:getInstance():utf82GbString(name:getString(),string.len(name:getString()) )
        --[[local len=string.len(gg)
        if(len>MAX_NAME_LENGTH)then
            gg=string.sub(gg,0,MAX_NAME_LENGTH-2).."..."
            local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))
            name:setString(newName)
        end]]
        local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))
        if self:isMyself(soloPlayer.nUserID) then
            newName = user.szUtf8Username
        end

        my.fixUtf8Width(newName, name, 88)

        local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
        change:setVisible(false)
        local invite = chair:getChildByName("Img_head"):getChildByName("Btn_invite")
        invite:setVisible(false)

--            if( bit.band(soloPlayer.nStatus, BaseGameDef.BASEGAME_TS_WAITING_START) == BaseGameDef.BASEGAME_TS_WAITING_START)then
            local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
            ready:setVisible(false)
            soloPlayer.isReady=false
--           else
--               local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
--               ready:setVisible(true)
--                soloPlayer.isReady=true
--           end

        local b = chair:getChildByName("Img_head"):getChildByName("Btn_head")
        b:setVisible(true)
        --[[ if(soloPlayer.nNickSex == 1)then
            b:loadTextureNormal(defaultGirlPath, ccui.TextureResType.localType)
            b:loadTexturePressed(defaultGirlPath,ccui.TextureResType.localType)
        else
            b:loadTextureNormal(defaultBoyPath,ccui.TextureResType.localType)
            b:loadTexturePressed(defaultBoyPath,ccui.TextureResType.localType)
        end]]

            b:loadTextureNormal(self:_getHeadResPath(soloPlayer.nUserID, soloPlayer.nNickSex),ccui.TextureResType.localType)
            b:loadTexturePressed(self:_getHeadResPath(soloPlayer.nUserID, soloPlayer.nNickSex),ccui.TextureResType.localType)
        b:onTouch(function(e)
            if(e.name=='began')then

            elseif(e.name=='ended')then
                local pos={}
                pos.x=400
                pos.y=360
                local position = b:getParent():convertToWorldSpace(cc.p(b:getPosition()))
                position.x = position.x + 50
                position.y = position.y - 160
                pos = position
                self:showFlag(soloPlayer.nUserID,pos,true,addDes)
            elseif(e.name=='cancelled')then

            elseif(e.name=='moved')then

            end
        end)
        soloPlayer.readyTime=20
        soloPlayer.hasPlayed=false
        local info, i = self:SearchPlayer(soloPlayer.nUserID)
        if info ~= nil then
            table.remove(self._playerInfo, i)
        end
        table.insert(self._playerInfo, soloPlayer)
        local count = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()
        if(table.maxn(self._playerInfo)>=count)then
            self._find:setTouchEnabled(false)
            self._find:setBright(false)
            self._findFromSDK:setTouchEnabled(false)
            self._findFromSDK:setBright(false)
        end
    end

    self:dealWithStartButtonStatus()
end

function CharteredRoom:onUserPosition(soloPlayers)
	self:clearPlayers()
    for i = 1, #soloPlayers do
        self:onPlayerEnter(soloPlayers[i])
    end

    self:getSelfHeadImage()
end
function CharteredRoom:rspStartGame()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    if(playerInfoManager==nil or playerInfoManager:getSelfTableNO() < 2000)then
        return
    end
    local chair = -1
    local v, i = self:SearchPlayer(user.nUserID)
    if v ~= nil then
        chair =  v.nChairNO
        v.isReady=true
    end
    if(chair == -1)then
        return
    end

    local chair = self:getChairNodeName(chair)
    if(chair)then
        chair:getChildByName("Img_head"):getChildByName("Img_ready"):setVisible(true)
    end
    touchEnable_ready(self._ready, false)

    if self._gameController:isTeamGameRoom() then
        if user.nUserID == PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo() then
            self:onCustomerServiceTalked(friendDesConfig["CHARTEREDROOM_NOTIFY_MATCHSTATED"])

            self:startMatchStartedTimer()
            self:startMatchTimeoutTimer()

            self:onTeamGameStartBtnShow(false)

            if self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() then
                if self._quitBtn then
                    self._quitBtn:setBright(false)
                    self._quitBtn:setTouchEnabled(false)

                    self:setStartMatch(true)
                    self:dealWithChairSystemFindBtns()
                end
            end
        end
    end
end

function CharteredRoom:onPlayerStartGame(playerStartGame)
    if(playerStartGame==nil or playerStartGame.nTableNO < 2000)then
        return
    end

    local chair = self:getChairNodeName(playerStartGame.nChairNO)
    if(chair)then
        chair:getChildByName("Img_head"):getChildByName("Img_ready"):setVisible(true)
    end
    local v, i = self:SearchPlayer(playerStartGame.nUserID)
    if v ~= nil then
        v.isReady = true
    end

    if self._gameController:isTeamGameRoom() then
        if playerStartGame.nUserID == PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo() then
            self:onCustomerServiceTalked(friendDesConfig["CHARTEREDROOM_NOTIFY_MATCHSTATED"])

            self:startMatchStartedTimer()
            self:startMatchTimeoutTimer()

            if self._gameController:isHallEntery() then
                if self._quitBtn then
                    self._quitBtn:setBright(false)
                    self._quitBtn:setTouchEnabled(false)
                end

                self:setStartMatch(true)
                self:dealWithChairSystemFindBtns()
            end
        end
    end
    self:dealWithStartButtonStatus()
end

function CharteredRoom:onStartSoloTable(soloPlayers)
    if self._gameController:isTeamGameRoom() then
        self:onCustomerServiceTalked(friendDesConfig["CHARTEREDROOM_NOTIFY_MATCHFINISHED"])

        self:stopMatchStartedTimer()
    end

    for i = 1, #soloPlayers do
        local info, j = self:SearchPlayer(soloPlayers[i].nUserID)
        if info == nil then
            self:onPlayerEnter(soloPlayers[i])
        end
    end
end

function CharteredRoom:countTickoffTime()
    if(self._countTickoffTimer)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._countTickoffTimer)
        self._countTickoffTimer=nil
    end

    if( PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo() ~= user.nUserID)then
        self._countTickoffTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countTickoffTime), 1, false)
        return
    end
    for i,v in pairs(self._playerInfo)do
        if(v.isReady==false)then
            v.readyTime=v.readyTime-1
            if(v.readyTime<0)then
                v.readyTime=0
            end
        end
        if( (self._flagUserID==v.nUserID)and(v.isReady==false))then
            local tick = self._flag:getChildByName("Img_back"):getChildByName("Btn_kick")
            if(v.hasPlayed==false)then
                if(v.readyTime==0)then

                    tick:setTitleText(tickoffDes)
                    tick:setTouchEnabled(true)
                    tick:setBright(true)
                else
                    tick:setTitleText(tickoffDes.."("..tostring(v.readyTime)..")")
                    printf("~~~~~~~~~~~readyTime %d~~~~~~~~~~~~~~~~~~~~~~~~~",v.readyTime)
                    tick:setTouchEnabled(false)
                    tick:setBright(false)
                end
            else
                tick:setTitleText(tickoffDes)
                tick:setTouchEnabled(true)
                tick:setBright(true)
            end

            if(user.nUserID~=user.hostID)then
                tick:setVisible(false)
            end

        end
    end

    self._countTickoffTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countTickoffTime), 1, false)
end

function CharteredRoom:quit()
    self:stopMatchStartedTimer()
    self:stopMatchTimeoutTimer()

    if(self._countTickoffTimer)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._countTickoffTimer)
        self._countTickoffTimer=nil
    end
    if(timer)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer)
        timer=nil
    end
    if(quitTimer)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(quitTimer)
        quitTimer=nil
    end
    
    if self:isCharteredRoom() then
        if(self._charterdRoomTalk)then
            printf("~~~~~~~~~~~~~~~~_charterdRoomTalk:quit~~~~~~~~~~~~~~~~~~~~~~")
            self._charterdRoomTalk:quit()
        end
        return
    end

end

function CharteredRoom:createPlayerFlag()
    self._flag = cc.CSLoader:createNode("res/GameCocosStudio/CharteredRoom/PlayerHead.csb")
    self._node:addChild(self._flag,10)
    self._flag:setVisible(false)
    self._flagUserID=0

    local function onTouchBegan(touch, event)
        local content = self._flag:getChildByName("Img_back"):getContentSize()
        local rect = cc.rect(0,0,content.width,content.height)
        local posInNodeSpace = self._flag:convertToNodeSpace(touch:getLocation())
        if(cc.rectContainsPoint(rect,posInNodeSpace)==false)then
            self._flag:setVisible(false)
        end

        content = self._text_talk:getContentSize()
        rect = cc.rect(0,0,content.width,content.height)
        posInNodeSpace = self._text_talk:convertToNodeSpace(touch:getLocation())
        if(cc.rectContainsPoint(rect,posInNodeSpace)==true)then
            self:showTalkInterface()
        end

        content = self._text_tui:getContentSize()
        rect = cc.rect(0,0,content.width,content.height)
        posInNodeSpace = self._text_tui:convertToNodeSpace(touch:getLocation())
        if(cc.rectContainsPoint(rect,posInNodeSpace)==true)then
            if not cc.exports.isSocialSupported() then
               local json = cc.load("json").json
               local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
               if( ofile == "")then
                            printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
                            return
                end
                local opt = json.decode(ofile)
                my.informPluginByName({pluginName='ToastPlugin',params={tipString=opt["NOT_SUPPORT"],removeTime=5}})
                return
            end
            self:showFriendInterface()
        end
    end
    local listener1 = cc.EventListenerTouchOneByOne:create()
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener1,self._flag)
end

function CharteredRoom:showFlag(userID,pos,showTick,des)
    local tickoff = self._flag:getChildByName("Img_back"):getChildByName("Btn_kick")
    self._imagePlayerInfoHead = self._flag:getChildByName("Img_back"):getChildByName("Image_userhead")

    if(showTick==false)then
        tickoff:setVisible(false)
    else
        tickoff:setVisible(true)
    end
    if( PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo()==userID)then
        tickoff:setVisible(false)
    end
    if( PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo()~=user.nUserID)then
        tickoff:setVisible(false)
    end

    self._flag:setPosition(pos.x, pos.y)
    self._flag:setVisible(true)

    local info=nil
    local v, i = self:SearchPlayer(userID)
    if v ~= nil then
        info = v
        self._flagUserID=userID
        local tick = self._flag:getChildByName("Img_back"):getChildByName("Btn_kick")
        if(v.isReady==false)then
            if(v.hasPlayed==false)then
                if(v.readyTime==0)then

                    tick:setTitleText(tickoffDes)
                    tick:setTouchEnabled(true)
                    tick:setBright(true)
                else
                    tick:setTitleText(tickoffDes.."("..tostring(v.readyTime)..")")
                    tick:setTouchEnabled(false)
                    tick:setBright(false)
                end
            else
                    tick:setTitleText(tickoffDes)
                    tick:setTouchEnabled(true)
                    tick:setBright(true)
            end
        else
                tick:setTitleText(tickoffDes)
                tick:setTouchEnabled(false)
                tick:setBright(false)
        end
    end
    if(info==nil)then
        printf("~~~~~~~~~~~~~no such userid %d~~~~~~~~~~~~",userID)
        self._flag:setVisible(false)
        return
    end

    if self._imagePlayerInfoHead then
        if info.portraitPath ~= nil and string.len(info.portraitPath) > 0 and cc.exports.isSocialSupported() then
            self._imagePlayerInfoHead:loadTexture(info.portraitPath)
        else
            self._imagePlayerInfoHead:loadTexture(self:_getHeadResPath(info.nUserID, info.nNickSex))
            --[[if (info.nNickSex == 1) then
                self._imagePlayerInfoHead:loadTexture(defaultGirlPath)
            else
                self._imagePlayerInfoHead:loadTexture(defaultBoyPath)
            end]]
        end
    end

    tickoff:onTouch(function(e)
        if(e.name=='began')then
            e.target:setScale(cc.exports.GetButtonScale(e.target))
            my.playClickBtnSound()
        elseif(e.name=='ended')then
            e.target:setScale(1.0)
            self:tickoff(info.nUserID)
        elseif(e.name=='cancelled')then
            e.target:setScale(1.0)
        elseif(e.name=='moved')then

        end
    end)

    local name = self._flag:getChildByName("Img_back"):getChildByName("Text_name")
    local utfName=MCCharset:getInstance():gb2Utf8String(info.szUserName,string.len(info.szUserName) )
    utfName = user:getDisplayNameWithCheckSelf(info.nUserID, utfName)
    my.fixUtf8Width(utfName, name, 156)
    --name:setString(utfName)
    local deposit = self._flag:getChildByName("Img_back"):getChildByName("Text_silver")
    deposit:setString( tostring(info.nDeposit) )
    local scroe = self._flag:getChildByName("Img_back"):getChildByName("Text_score")
    scroe:setString( tostring(info.nScore) )
    local level = self._flag:getChildByName("Img_back"):getChildByName("Text_level")
    --local levelName = levelstrings[string.format("G_LEVEL_%d", info.nPlayerLevel + 1)]
    local levelnum = levelconfig.getLevelStringId(info.nDeposit)
	local levelName = levelstrings[levelnum]
    level:setString(levelName)
    local victoer = self._flag:getChildByName("Img_back"):getChildByName("Text_victoer")
    local dess = string.format("%d/%d/%d",info.nWin,info.nLoss,info.nStandOff)
    victoer:setString(dess)
    local rate = self._flag:getChildByName("Img_back"):getChildByName("Text_rate")
    local totle = info.nWin+info.nLoss+info.nStandOff
    if(totle==0)then
        rate:setString( tostring(totle)  .. "%")
    else
        local c = math.floor(info.nWin*100/totle)
        rate:setString( tostring(c) .. "%")
    end

    local Img_male = self._flag:getChildByName("Img_back"):getChildByName("Img_male")
    local Img_female = self._flag:getChildByName("Img_back"):getChildByName("Img_female")
    if(info.nNickSex==0)then
        Img_male:setVisible(true)
        Img_female:setVisible(false)
    else
        Img_male:setVisible(false)
        Img_female:setVisible(true)
    end

    if(userID == user.nUserID)then
        local btnFriend = self._flag:getChildByName("Img_back"):getChildByName("Btn_friend")--:setVisible(false)
        btnFriend:setBright(false)
        btnFriend:setTouchEnabled(false)
        return
    end

    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        if(tcyFriendPlugin:isFriend(userID))then
            local btnFriend = self._flag:getChildByName("Img_back"):getChildByName("Btn_friend")--:setVisible(false)
            btnFriend:setBright(false)
            btnFriend:setTouchEnabled(false)
            local remark = tcyFriendPlugin:getRemarkName(userID)
            if(remark~=nil)then
                if(remark~="")then
                    name:setString(remark)
                end
            end

        else
            local add = self._flag:getChildByName("Img_back"):getChildByName("Btn_friend")
            add:setBright(true)
            add:setTouchEnabled(true)
            if add then
                if cc.exports.isSocialSupported() then  
                    add:setVisible(true)
                    add:onTouch(function(e)
                        if(e.name=='began')then
                            e.target:setScale(cc.exports.GetButtonScale(e.target))
                            my.playClickBtnSound()
                        elseif(e.name=='ended')then
                            e.target:setScale(1.0)
                            self._flag:setVisible(false)
                            self:addFriend(userID,des)
                        elseif(e.name=='cancelled')then
                            e.target:setScale(1.0)
                        elseif(e.name=='moved')then

                        end
                    end)
                else
                    --add:setVisible(false)
                    add:setBright(false)
                    add:setTouchEnabled(false)
                end
            end
            
        end
    end
    if not cc.exports.isSocialSupported() then
        local btnFriend = self._flag:getChildByName("Img_back"):getChildByName("Btn_friend")--:setVisible(false)
        btnFriend:setBright(false)
        btnFriend:setTouchEnabled(false)
    end

end

function CharteredRoom:showFlagForAddFriend(strangeInfo,pos,des)
    local tickoff = self._flag:getChildByName("Img_back"):getChildByName("Btn_kick")
    tickoff:setVisible(false)
    self._imageStangerInfoHead = self._flag:getChildByName("Img_back"):getChildByName("Image_userhead")

    --[[ 这段果断写的有问题啊。。。下面重写了
    local add = self._flag:getChildByName("Img_back"):getChildByName("Btn_friend"):setVisible(true)
    add:onTouch(function(e)
        if(e.name=='began')then
                    e.target:setScale(cc.exports.GetButtonScale(e.target))
                    my.playClickBtnSound()
         elseif(e.name=='ended')then
                    e.target:setScale(1.0)
                    self._flag:setVisible(false)
                    self:addFriend(strangeInfo.userId,des)
         elseif(e.name=='cancelled')then
                    e.target:setScale(1.0)
         elseif(e.name=='moved')then

         end
    end)]] --时间比较紧 之后的代码整理需要周兴和添泽搞定！
     local pImgBack = self._flag:getChildByName("Img_back")
     if pImgBack then
         local add = pImgBack:getChildByName("Btn_friend")
         add:setBright(true)
         add:setTouchEnabled(true)
         if add then
            if cc.exports.isSocialSupported() then
                add:setVisible(true)
                add:onTouch(function(e)
                    if(e.name=='began')then
                        e.target:setScale(cc.exports.GetButtonScale(e.target))
                        my.playClickBtnSound()
                     elseif(e.name=='ended')then
                        e.target:setScale(1.0)
                        self._flag:setVisible(false)
                        self:addFriend(strangeInfo.userId,des)
                     elseif(e.name=='cancelled')then
                        e.target:setScale(1.0)
                     elseif(e.name=='moved')then

                     end
                end)
            else
                --add:setVisible(false)
                add:setBright(false)
                add:setTouchEnabled(false)
            end
        end
    end

    local name = self._flag:getChildByName("Img_back"):getChildByName("Text_name")
    name:setString(strangeInfo.userName)
    local deposit = self._flag:getChildByName("Img_back"):getChildByName("Text_silver")
    deposit:setString( tostring(strangeInfo.nDeposit) )
    local scroe = self._flag:getChildByName("Img_back"):getChildByName("Text_score")
    scroe:setString( tostring(strangeInfo.nScore) )
    local level = self._flag:getChildByName("Img_back"):getChildByName("Text_level")
    --local levelName = levelstrings[string.format("G_LEVEL_%d", strangeInfo.nPlayerLevel + 1)] 
    local levelnum = levelconfig.getLevelStringId(strangeInfo.nDeposit)
	local levelName = levelstrings[levelnum]
    level:setString(levelName)
    local victoer = self._flag:getChildByName("Img_back"):getChildByName("Text_victoer")
    local dess = string.format("%d/%d/%d",strangeInfo.nWin,strangeInfo.nLoss,strangeInfo.nStandOff)
    victoer:setString(dess)
    local rate = self._flag:getChildByName("Img_back"):getChildByName("Text_rate")
    local totle = strangeInfo.nWin+strangeInfo.nLoss+strangeInfo.nStandOff
    if(totle==0)then
        rate:setString( tostring(totle) )
    else
        local c = math.ceil(strangeInfo.nWin*100/totle)
        rate:setString( tostring(c) )
    end

    local Img_male = self._flag:getChildByName("Img_back"):getChildByName("Img_male")
    local Img_female = self._flag:getChildByName("Img_back"):getChildByName("Img_female")
    if(strangeInfo.sex==0)then
        Img_male:setVisible(true)
        Img_female:setVisible(false)
    else
        Img_male:setVisible(false)
        Img_female:setVisible(true)
    end

    self._flag:setPosition(pos.x,pos.y)
    self._flag:setVisible(true)

    if self._imageStangerInfoHead then
        if strangeInfo.portraitPath ~= nil and string.len(strangeInfo.portraitPath) > 0  and cc.exports.isSocialSupported() then
            self._imageStangerInfoHead:loadTexture(strangeInfo.portraitPath)
        else
            self._imageStangerInfoHead:loadTexture(self:_getHeadResPath(strangeInfo.userId, strangeInfo.sex))
            --[[if (strangeInfo.sex == 1) then
                self._imageStangerInfoHead:loadTexture(defaultGirlPath)
            else
                self._imageStangerInfoHead:loadTexture(defaultBoyPath)
            end]]
        end
    end

    if cc.exports.isSocialSupported() then
        local t={}
        t.userID=strangeInfo.userId
        t.url=strangeInfo.url
        local data = {}
        table.insert(data,t)
--        local imageCtrl = require('src.app.BaseModule.ImageCtrl')
--        imageCtrl:getImageForGameScene(data, 60-60, handler(self,self.onGetStrangerHeadPath))
    end
end

function CharteredRoom:onGetStrangerHeadPath(list)
    if(not my.isInGame())then
        return
    end
    dump(list)

    for i,v in pairs(list)do
        dump(v)
        self._imageStangerInfoHead:loadTexture(v.path)
        break
    end
end

function CharteredRoom:hideFlag()
    self._flag:setVisible(false)
end

function CharteredRoom:addFriend(userID,des)
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        tcyFriendPlugin:addFriend(userID, des)
    end
end

function  CharteredRoom:tickoff(userID)
    local info, i = self:SearchPlayer(userID)
    if info ~= nil then
        self._gameController:tickoff(1,userID,info.nChairNO)
    end

end

function CharteredRoom:changeChair(toChairNO)
    if(changeEnable)then
        self._gameController:changeChair(toChairNO)
    end
end

function CharteredRoom:onChairChanged(data)
    dump(data)
    local playinfo, i = self:SearchPlayer(data.nUserID)
    if(playinfo==nil)then
        return
    end

    local chair = self:getChairNodeName(data.nOldChairNO)
    if(chair)then
        chair:getChildByName("Img_head"):getChildByName("Btn_head"):setVisible(false)
        chair:getChildByName("Img_head"):getChildByName("Img_ready"):setVisible(false)
        local con = cc.exports.GetRoomConfig()
        chair:getChildByName("Img_head"):getChildByName("Text_name"):setString(con["WAIT_ENTER"])
        local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
        change:setVisible(true)
        change:onTouch(function(e)
                if(e.name=='began')then

                elseif(e.name=='ended')then
                    self._flag:setVisible(false)
                    self:changeChair(data.nOldChairNO)
                elseif(e.name=='cancelled')then

                elseif(e.name=='moved')then

                end
            end)
            local f = chair:getChildByName("Img_head"):getChildByName("Img_friend")
            f:setVisible(false)
            local v, i = self:SearchPlayer(data.nUserID)
            if v ~= nil then
                v.nChairNO=-1
            end

    end

    chair = self:getChairNodeName(data.nNewChairNO)
    if(chair==nil)then
        return
    end
    local v, i = self:SearchPlayer(data.nUserID)
    if v ~= nil then
        v.nChairNO=data.nNewChairNO

        local t={}
        t.userID=data.nUserID
        t.url=v.url
        local data = {}
        table.insert(data,t)
        local imageCtrl = require('src.app.BaseModule.ImageCtrl')
        imageCtrl:getImageForGameScene(data, 60-60, handler(self,self.onGetHeadPath))
    end
        local head = chair:getChildByName("Img_head"):getChildByName("Btn_head")
        head:setVisible(true)
        head:loadTextureNormal(self:_getHeadResPath(playinfo.nUserID, playinfo.nNickSex),ccui.TextureResType.localType)
        head:loadTexturePressed(self:_getHeadResPath(playinfo.nUserID, playinfo.nNickSex),ccui.TextureResType.localType)
        --[[if(playinfo.nNickSex == 1)then
            head:loadTextureNormal(defaultGirlPath, ccui.TextureResType.localType)
            head:loadTexturePressed(defaultGirlPath,ccui.TextureResType.localType)
        else
            head:loadTextureNormal(defaultBoyPath,ccui.TextureResType.localType)
            head:loadTexturePressed(defaultBoyPath,ccui.TextureResType.localType)
        end]]
        head:onTouch(function(e)
                if(e.name=='began')then

                elseif(e.name=='ended')then
                    local pos={}
                    pos.x=400
                    pos.y=360
                    local position = head:getParent():convertToWorldSpace(cc.p(head:getPosition()))
                    position.x = position.x + 50
                    position.y = position.y - 160
                    pos = position
                    self:showFlag(data.nUserID,pos,true,addDes)
                elseif(e.name=='cancelled')then

                elseif(e.name=='moved')then

                end
            end)
        
        if(playinfo.isReady==true)then
            chair:getChildByName("Img_head"):getChildByName("Img_ready"):setVisible(true)
        else
            chair:getChildByName("Img_head"):getChildByName("Img_ready"):setVisible(false)
        end
        
        local utName = MCCharset:getInstance():gb2Utf8String(playinfo.szUserName,string.len(playinfo.szUserName) )
        if(data.nUserID==PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo())then
            chair:getChildByName("Img_head"):getChildByName("Text_name"):setString(utName)

            local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	        h:setVisible(true)
        else
            chair:getChildByName("Img_head"):getChildByName("Text_name"):setString(utName)

            local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	        h:setVisible(false)
        end 

        local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
        if tcyFriendPlugin then
            if(tcyFriendPlugin:isFriend(data.nUserID) == true)then
                 local remark = tcyFriendPlugin:getRemarkName(data.nUserID)
                 if(remark~=nil)then
                    if(remark~="")then
                        if(data.nUserID==PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo())then
                            chair:getChildByName("Img_head"):getChildByName("Text_name"):setString(hostDes..remark)

                            local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	                        h:setVisible(true)
                        else
                            chair:getChildByName("Img_head"):getChildByName("Text_name"):setString(remark)

                            local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	                        h:setVisible(false)
                        end 
                    end
                 end

                 chair:getChildByName("Img_head"):getChildByName("Img_friend"):setVisible(true)
            else
                chair:getChildByName("Img_head"):getChildByName("Img_friend"):setVisible(false)
            end
        end
        local name = chair:getChildByName("Img_head"):getChildByName("Text_name")
        local gg=MCCharset:getInstance():utf82GbString(name:getString(),string.len(name:getString()) )
        --[[local len=string.len(gg)
        if(len>MAX_NAME_LENGTH)then
              gg=string.sub(gg,0,MAX_NAME_LENGTH-2).."..."
              local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))
              name:setString(newName)
        end]]
        
        local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))
        if self:isMyself(v.nUserID) then
            newName = user.szUtf8Username
        end
        my.fixUtf8Width(newName, name, 88)


    local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
    change:setVisible(false)

    if(data.nUserID == user.nUserID)then
        self._gameController._baseGamePlayerInfoManager:setSelfChairNO(data.nNewChairNO)
        self:startShowChangeChair(data.nOldChairNO,data.nNewChairNO)

        self:getSelfHeadImage()
    end

end

function CharteredRoom:onTickoff(data)
    if(cc.exports.inTickoff==true)then
        return
    end

    local json = cc.load("json").json
    local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
    if( ofile == "")then
        printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
        return
    end
    local des = json.decode(ofile)

    local str 
    if(data.nTickModel==1)then
        str=des["timeout"]
    else
        str=des["tickoff"]
    end

    self.tick = cc.CSLoader:createNode("res/GameCocosStudio/CharteredRoom/TickoffTips.csb")
    self._node:addChild(self.tick)
    self._node:setVisible(true)

    cc.exports.inTickoff=true
    local exit = self.tick:getChildByName("Img_back"):getChildByName("Btn_exit")
    exit:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)

                printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~onKeyBack~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`")
                cc.exports.isAutogotoCharteredRoom = true
                self._gameController:onKeyBack()

            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)
    local tell = self.tick:getChildByName("Img_back"):getChildByName("Text_full")
    tell:setString(str)

    local change = self.tick:getChildByName("Img_back"):getChildByName("Btn_change")
    change:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                cc.exports.inTickoff=false
                cc.exports.PUBLIC_INTERFACE.ChangeTableAndEnter(data.nRoomID, handler(self,self.callbackChangeTableAndEnter))
                timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.showChangeFailedAndGoHall), 5, false)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)

    self._gameController:getPlayerInfoManager():clearPlayersInfo()
    --self._gameController:onQuit()
end

function CharteredRoom:goHall()
    if(quitTimer ~= nil)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(quitTimer)
        quitTimer=nil
        self._gameController:onKeyBack()
    end
end

function CharteredRoom:startChangeTableAndEnter()
    local roomID = self._gameController._baseGameUtilsInfoManager:getUtilsInfo().nRoomID
    cc.exports.PUBLIC_INTERFACE.ChangeTableAndEnter(roomID, handler(self,self.callbackChangeTableAndEnter))
end

function CharteredRoom:showChangeFailedAndGoHall()
    if(timer ~= nil)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer)
        timer = nil
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=changeFail,removeTime=5}})
        
        quitTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.goHall), 1, false)
    end
end

function CharteredRoom:callbackChangeTableAndEnter(res,data)
    if(res~=10)then
        cc.exports.isAutogotoCharteredRoom=true 
        self:showChangeFailedAndGoHall()
        return
    end
    
    if(data.nResultType == changeTableResultType["TableFind"])then
        
        if(timer ~= nil)then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer)
            timer=nil
        end

        if(self.tick)then
            self.tick:removeSelf()
        end
        PUBLIC_INTERFACE.SetHostIdOfEnterTeamInfo(data.nHomeUserID)
        user.applyTableId = data.nTableNO
        user.hostID   = data.nHomeUserID
        self._gameController:onLeaveGameForChangeOK()

    elseif(data.nResultType == changeTableResultType["NeedCreate"])then

        if(timer ~= nil)then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer)
            timer=nil
        end
            cc.exports.isAutogotoCharteredRoom=false
            if(self.tick)then
                self.tick:removeSelf()
            end

            user.applyTableId = data.nTableNO
            self._gameController:createNewTableInGame()
            timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.showChangeFailedAndGoHall), 5, false)
        
    else
        self:showChangeFailedAndGoHall()
    end
end

function CharteredRoom:setFinalChairPosition(currentChair)
    if(currentChair==nil)then
        return
    end
    if(currentChair == 0)then
        return
    end

    local lastPos={}
    for i=1,self._panelPosition:getChildrenCount() do
        local chair = self._panelPosition:getChildByName("chair_"..tostring(i - 1))
        if chair then
            --[[local p={}
            p.x = chair:getPositionX()
            p.y = chair:getPositionY()]]--
            table.insert(lastPos, cc.p(chair:getPositionX(), chair:getPositionY()))
        end
    end
    local maxIndex = table.maxn(lastPos)-1
    local diff = (table.maxn(lastPos)-currentChair)
    for ii=1,table.maxn(lastPos)do
        local index = ii-1
        local chairName = "chair_"..tostring(index)
        local chair = self:getChairNodeName(index)
        index=index+diff
        if(index>maxIndex)then
            index = index-maxIndex-1
        end
        local pos = lastPos[index+1]
        if pos ~= nil then
            chair:setPosition(pos)
        else
            print("pos is nil, index "..tostring(index))
            print(currentChair)
            print(maxIndex)
            print(diff)
            dump(lastPos)
        end
    end
end

function CharteredRoom:setFinalChairPositionTwoEx(currentChair)
    if(currentChair==nil)then
        return
    end
    if(currentChair == 0)then
        return
    end
    if currentChair == 1 or currentChair == 3 then
        currentChair = currentChair - 1
    end

    local lastPos={}
    for i=1,self._panelPosition:getChildrenCount() do
        local chair = self._panelPosition:getChildByName("chair_"..tostring(i - 1))
        if chair then
            local p={}
            p.x = chair:getPositionX()
            p.y = chair:getPositionY()
            table.insert(lastPos,p)
        end
    end
    local maxIndex = table.maxn(lastPos)-1
    local diff = (table.maxn(lastPos)-currentChair)
    for ii=1,table.maxn(lastPos)do
        local index = ii-1
        local chairName = "chair_"..tostring(index)
        local chair = self:getChairNodeName(index)
        index=index+diff
        if(index>maxIndex)then
            index = index-maxIndex-1
        end
        local pos = lastPos[index+1]
        chair:setPosition(pos)
    end
end

function CharteredRoom:startShowChangeChair(oldChairNO,newChairNO)
    local lastPos={}
    for i=1,self._panelPosition:getChildrenCount() do
        local chair = self._panelPosition:getChildByName("chair_"..tostring(i - 1))
        if chair then
            local p={}
            p.x = chair:getPositionX()
            p.y = chair:getPositionY()
            table.insert(lastPos,p)
        end
    end
    local maxIndex = table.maxn(lastPos)-1

    local diff
    if(newChairNO~=0)then
        if(oldChairNO>newChairNO)then
            diff = oldChairNO-newChairNO
        else
            diff = table.maxn(lastPos)- (newChairNO-oldChairNO)
        end
    else
        diff=oldChairNO
    end

    for ii=1,table.maxn(lastPos)do
        local index = ii-1
        local chairName = "chair_"..tostring(index)
        local chair = self._panelPosition:getChildByName(chairName)

        if chair then
        
            local posList={}
            for z=1,diff do
                local dex = index+z
                if(dex>maxIndex)then
                    dex = dex-maxIndex-1
                end
                table.insert(posList,lastPos[dex+1])
            end
        

            local function continueMove()
                if(table.maxn(posList)>0)then
                    local b = cc.MoveTo:create(0.5, posList[1])
                    table.remove(posList,1)
                    local b1 = cc.Sequence:create(b,cc.CallFunc:create(continueMove))
                    chair:runAction(b1)
                else
                    changeEnable=true
                end
            end

            local a = cc.MoveTo:create(0.5, posList[1])
            table.remove(posList,1)
            local a1 = cc.Sequence:create(a,cc.CallFunc:create(continueMove))
            chair:runAction(a1)
            changeEnable=false
        
        end
    end


end

function CharteredRoom:onGameStartForCharteredRoom(data)
    self:stopMatchStartedTimer()
    self:stopMatchTimeoutTimer()

    for i,v in pairs(self._playerInfo)do
        v.isReady=true
    end
    self:hide()

    if self._gameController._showCharteredBtn then   
        self._gameController._showCharteredBtn:setVisible(true)
    end

    if(data==nil)then
        return
    end
    local base
    if(data.nBaseDeposit==nil)then
        return
    end
    if(data.nBaseScore==nil)then
        return
    end

     if cc.exports.isDepositSupported() then
        base=data.nBaseDeposit
    else
        if cc.exports.isScoreSupported() then
            base=data.nBaseScore
        end
    end

    if(base~=0)then
        local json = cc.load("json").json
        local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
        if( ofile == "")then
            printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
            return
        end
        local des = json.decode(ofile)
        local title = des["bat"]

        self._node:getChildByName("Operate_Panel"):getChildByName("Text_bat"):setString(title..tostring(base))
        self._node:getChildByName("Operate_Panel"):getChildByName("Text_bat"):setVisible(true)
    end

    local gameXmlData  = self._gameController:getMyGameDataXml()
    gameXmlData.isLockTeam = self._checkBtnSetLockRoom:isSelected()
    self._gameController:saveMyGameDataXml(gameXmlData)
end

function CharteredRoom:isNeedShow()

    if not self:isCharteredRoom() then
        printf("~~~~~~~~~~not create chartered room~~~~~~~~~~~~~~~")
        return false
    end

    if self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() and cc.exports.hasStartGame then
        if not self:isVisible() then
            return false
        end
    end

    if(self._node==nil)then
        return false
    end
    if(self._node:isVisible()==true)then
        return false
    end

    return true
end

function CharteredRoom:onGameOneSetEnd(data)
    cc.exports.hasStartGame = false

    for i,v in pairs(self._playerInfo)do
        v.isReady=false
        v.readyTime=0
    end

    for z,v in pairs(self._playerInfo) do
        local chair = self:getChairNodeName(v.nChairNO)
        if(chair)then
            local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
            ready:setVisible(false)
        end
        v.hasPlayed=true
    end
    touchEnable_ready(self._ready, true)
    self:setStartMatch(false)
    self:dealWithChairSystemFindBtns()

    if self._quitBtn then
        self._quitBtn:setBright(true)
        self._quitBtn:setTouchEnabled(true)
    end

    self:saveStrangers()

end

function CharteredRoom:saveStrangers()
    
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        for z,v in pairs(self._playerInfo) do
            if(tcyFriendPlugin:isFriend(v.nUserID))then
                printf("~~~~~~~~~find friend %d~~~~~~~~~~~~~~",v.nUserID)
            else
                if(user.nUserID ~=v.nUserID)then
                   local info={}
                    info.userId = v.nUserID
                    local utfName = MCCharset:getInstance():gb2Utf8String( v.szUserName,string.len(v.szUserName) )
                    info.userName = utfName
                    info.time = os.time()
                    info.url = v.url
                    info.sex = v.nNickSex
                    info.nScore = v.nScore
                    info.nDeposit = v.nDeposit
                    info.nPlayerLevel = v.nPlayerLevel
                    info.nWin = v.nWin
                    info.nLoss = v.nLoss
                    info.nStandOff = v.nStandOff
                    if(info.url==nil)then
                        info.url=""
                    end
                    cc.exports.PUBLIC_INTERFACE.AddStranger(info)
                end
            end
        end
    end
end

function CharteredRoom:onHostChanged(data)
    printf("~~~~~~~~~~~~~onHostChanged~~~~~~~~~~~~~~~~~")
    dump(data)
    local des
    local json = cc.load("json").json
    local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
    if( ofile == "")then
        printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
        return
    end
    local opt = json.decode(ofile)
   
    local hostName 
    PUBLIC_INTERFACE.SetHostIdOfEnterTeamInfo(data.nHomeUserID)
    local info, i = self:SearchPlayer(data.nHomeUserID)
    if info ~= nil then
        hostName=info.szUserName
        hostName = MCCharset:getInstance():gb2Utf8String( hostName,string.len(hostName) )
    end

    user.hostID =  data.nHomeUserID
    PUBLIC_INTERFACE.SetHostIdOfEnterTeamInfo(data.nHomeUserID)
    self:setPermissions()
    self:onTeamGameStartBtnShow(true)

    if (data.nHomeUserID == user.nUserID) then
        des = opt['newHost']
    else
        des = string.format(opt['newClient'],hostName)
    end

    if not self:isVisible() then
        if self._gameController:isCharteredRoom() and not self._gameController:isRandomRoom() then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString=des,removeTime=5}})
        elseif self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() then
        end
    end

    local count = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()
    if(table.maxn(self._playerInfo)>=count)then
          self._find:setTouchEnabled(false)
          self._find:setBright(false)
          self._findFromSDK:setTouchEnabled(false)
          self._findFromSDK:setBright(false)
    end

    local currentChair
    for i,v in pairs(self._playerInfo)do
        local chair = self:getChairNodeName(v.nChairNO)
        if(chair)then

            local name = chair:getChildByName("Img_head"):getChildByName("Text_name")
            local msg = MCCharset:getInstance():gb2Utf8String( v.szUserName,string.len(v.szUserName) )
            if(v.nUserID==data.nHomeUserID)then
                local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	            h:setVisible(true)

                name:setString(msg)

                local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
                ready:setVisible(false)

                local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
                if tcyFriendPlugin then
                    if(tcyFriendPlugin:isFriend(data.nHomeUserID) == true)then
                        local remark = tcyFriendPlugin:getRemarkName(data.nHomeUserID)
                        if(remark~="")then
                             name:setString(hostDes..remark)
                        end
                     end
                end

                local gg=MCCharset:getInstance():utf82GbString(name:getString(),string.len(name:getString()) )
                --[[local len=string.len(gg)
                if(len>MAX_NAME_LENGTH)then
                    gg=string.sub(gg,0,MAX_NAME_LENGTH-2).."..."
                    local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))
                    name:setString(newName)
                end]]
                local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))
                my.fixUtf8Width(newName, name, 88)

            end

            if self:isMyself(v.nUserID) then
                --name:setString(user.szUtf8Username)
                my.fixUtf8Width(user.szUtf8Username, name, 88)
            end
        end
    end

    self:setStartMatch(false)
    self:dealWithChairSystemFindBtns()
end

function CharteredRoom:startGotoNewTable(respondType,dataMap)
    if(respondType~=10)then
        self:showChangeFailedAndGoHall()
        return
    end
    if(timer)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer)
        timer=nil
    end
    user.hostID = user.nUserID
    PUBLIC_INTERFACE.SetHostIdOfEnterTeamInfo(user.nUserID)
    self._gameController:setResponse(self._gameController:getResWaitingNothing())
    self._gameController:startChangeTable(dataMap.nTableNO, dataMap.nChairNO)
end

function CharteredRoom:onDXXW(data)
    if(table.maxn(data)==0)then
        return
    end
    if(table.maxn(self._playerInfo)>0)then
        return
    end

    --set isDXXW
    self._charterdRoomTalk.isDXXW = true

    --about bat
    local base

    if cc.exports.isDepositSupported() then
        base=self._gameController:getBaseDeposit()
    else
        if cc.exports.isScoreSupported() then
            base=self._gameController:getBaseScore()
        end
    end
   
    if(base)then
        local json = cc.load("json").json
        local ofile = MCFileUtils:getInstance():getStringFromFile("res/Game/GameDes/FriendDes.json")
        if( ofile == "")then
            printf("~~~~~~~~~~no FriendDes~~~~~~~~~~~")
            return
        end
        local des = json.decode(ofile)
        local title = des["bat"]

        self._node:getChildByName("Operate_Panel"):getChildByName("Text_bat"):setString(title..tostring(base))
        self._node:getChildByName("Operate_Panel"):getChildByName("Text_bat"):setVisible(true)
    end

    --recover to no one in chiar
    for z=1,self._gameController:getTableChairCount() do
        local chair = self:getChairNodeName(z - 1)
        if(chair)then
            local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
            change:onTouch(function(e)
                if(e.name=='began')then

                elseif(e.name=='ended')then
                    self._flag:setVisible(false)
                    self:changeChair(z-1)
                elseif(e.name=='cancelled')then

                elseif(e.name=='moved')then

                end
            end)
            local invite = chair:getChildByName("Img_head"):getChildByName("Btn_invite")
            if not cc.exports.isSocialSupported() then
                invite:setVisible(false)
            end
            invite:onTouch(function(e)
                if(e.name=='began')then

                elseif(e.name=='ended')then
                    self._flag:setVisible(false)
                    self:systemFindFromSDK()
                elseif(e.name=='cancelled')then

                elseif(e.name=='moved')then

                end
            end)

            if self._gameController:isTeamGameRoom() then
                change:setVisible(false)
            else
                change:setVisible(true)
            end
            local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
            ready:setVisible(true)

            local f = chair:getChildByName("Img_head"):getChildByName("Img_friend")
            f:setVisible(false)

            local b = chair:getChildByName("Img_head"):getChildByName("Btn_head")
            b:setVisible(false)

            local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	        h:setVisible(false)
        end
    end

    --reset chair pos
    for i,v in pairs(self._originalPos)do
        local chair = self._panelPosition:getChildByName(i)
        chair:setPosition(v)
    end


    local currentChair
    self._playerInfo=data
    for i,v in pairs(self._playerInfo)do
        local chair = self:getChairNodeName(v.nChairNO)
        if(chair)then

            local name = chair:getChildByName("Img_head"):getChildByName("Text_name")
            local msg = MCCharset:getInstance():gb2Utf8String( v.szUserName,string.len(v.szUserName) )

            local hostID=user.hostID
            if(v.nUserID == hostID)then
                 name:setString(msg)
                 local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	             h:setVisible(true)
            else
                 name:setString(msg)
                 local h = chair:getChildByName("Img_head"):getChildByName("Img_host")
	             h:setVisible(false)
            end
            local f = chair:getChildByName("Img_head"):getChildByName("Img_friend")
            f:setVisible(false)

            local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
            if tcyFriendPlugin then
                if(tcyFriendPlugin:isFriend(v.nUserID))then
                    local remark = tcyFriendPlugin:getRemarkName(v.nUserID)
                    
                    if(remark~=nil)then
                        if(remark~="")then
                            if(v.nUserID == hostID)then
                                name:setString(hostDes..remark)
                            else
                                name:setString(remark)
                            end
                        end
                    end

                    f:setVisible(true)
                end
            end
            local gg=MCCharset:getInstance():utf82GbString(name:getString(),string.len(name:getString()) )
            --[[local len=string.len(gg)
            if(len>MAX_NAME_LENGTH)then
                gg=string.sub(gg,0,MAX_NAME_LENGTH-2).."..."
                local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))
                name:setString(newName)
            end]]
            local newName=MCCharset:getInstance():gb2Utf8String(gg,string.len(gg))

            if self:isMyself(v.nUserID) then
                newName = user.szUtf8Username
            end

            my.fixUtf8Width(newName, name, 88)


            local change = chair:getChildByName("Img_head"):getChildByName("Btn_change")
            change:setVisible(false)

            local ready = chair:getChildByName("Img_head"):getChildByName("Img_ready")
            ready:setVisible(true)
            v.isReady=true

            v.readyTime=0
            v.hasPlayed=true

            local b = chair:getChildByName("Img_head"):getChildByName("Btn_head")
            b:setVisible(true)
            b:loadTextureNormal(self:_getHeadResPath(v.nUserID, v.nNickSex), ccui.TextureResType.localType)
            b:loadTexturePressed(self:_getHeadResPath(v.nUserID, v.nNickSex),ccui.TextureResType.localType)
           --[[ if(v.nNickSex == 1)then
                b:loadTextureNormal(defaultGirlPath, ccui.TextureResType.localType)
                b:loadTexturePressed(defaultGirlPath,ccui.TextureResType.localType)
            else
                b:loadTextureNormal(defaultBoyPath,ccui.TextureResType.localType)
                b:loadTexturePressed(defaultBoyPath,ccui.TextureResType.localType)
            end]]
            b:onTouch(function(e)
                if(e.name=='began')then

                elseif(e.name=='ended')then
                    local pos={}
                    pos.x=400
                    pos.y=360
                    local position = b:getParent():convertToWorldSpace(cc.p(b:getPosition()))
                    position.x = position.x + 50
                    position.y = position.y - 160
                    pos = position
                    self:showFlag(v.nUserID,pos,true,addDes)
                elseif(e.name=='cancelled')then

                elseif(e.name=='moved')then

                end
            end)

            if(user.nUserID == v.nUserID)then
                currentChair=v.nChairNO
            end

        end
    end

    if self.limitMax == 2 then
        self:setFinalChairPositionTwoEx(currentChair)
    else
        self:setFinalChairPosition(currentChair)
    end

    local count = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()
    if(table.maxn(self._playerInfo)>=count)then
        self._find:setTouchEnabled(false)
        self._find:setBright(false)
        self._findFromSDK:setTouchEnabled(false)
        self._findFromSDK:setBright(false)
    end
    self:rspStartGame()
    self:onGameStartForCharteredRoom(nil)
    self:hide()

    --start count tickoff
    if(self._countTickoffTimer)then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._countTickoffTimer)
        self._countTickoffTimer=nil
    end
    self._countTickoffTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.countTickoffTime), 1, false)

    --get path
    self:getSelfHeadImage()

   --reload talkData
   self._charterdRoomTalk:loadHistory()
   self._charterdRoomTalk:updateTalk()

    self:setStartMatch(false)
    self:dealWithChairSystemFindBtns()
    if self._quitBtn then
        self._quitBtn:setBright(true)
        self._quitBtn:setTouchEnabled(true)
    end


    local gameXmlData  = self._gameController:getMyGameDataXml()

    self._checkBtnSetLockRoom:setSelected(gameXmlData.isLockTeam)
end

function CharteredRoom:onGetHeadPath(list)
    if not self:isNodeExist() then return end

    if(not my.isInGame())then
        return
    end
    dump(list)


    for i,v in pairs(list)do
        self._gameController:setPlayerHead(v.userID, v.path)
    end

    if(self._playerInfo==nil)then 
        return
    end

    for i,v in pairs(list)do
    	local vv, i = self:SearchPlayer(v.userID)
        if vv ~= nil then
            local chair = self:getChairNodeName(vv.nChairNO)
            if(chair and (v.path~=""))then
                printf("~~~~~~~~~onGetHeadPath path %s~~~~~~~~~~~~~~~~~~~~~~",v.path)
                chair:getChildByName("Img_head"):getChildByName("Btn_head"):loadTextureNormal(v.path)
                chair:getChildByName("Img_head"):getChildByName("Btn_head"):loadTexturePressed(v.path)
            else
                printf("~~~~~~~~~onGetHeadPath path empty~~~~~~~~~~~~~~~~~~~~~~")
            end
                
            vv.portraitPath = v.path  
        end
    end
    self._charterdRoomTalk:onGetSyncInfo() --ctz 

end

function CharteredRoom:selfHeadcallbackFuc(code,path,imageStatus)
    if not self:isNodeExist() then return end

    printf("code = %d", code)
    printf("d = %s", path)
    print('selfHeadcallbackFuc')

    local show=false
    if code == cc.exports.ImageLoadActionResultCode.kImageLoadGetLocalSuccess then
        show=true
    elseif code ==cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess then 
        show=true
    end
    
    if(show==false)then
        printf("~~~~~~~~~~~~not show self head~~~~~~~~~~~~~~~~~~~~")
        --return
    end

    if self._gameController then
        self._gameController:setPlayerHead(user.nUserID, path)
    end

    if(self._playerInfo==nil)then
        return
    end
    local vv, i = self:SearchPlayer(user.nUserID)
    if vv ~= nil then
        local chair = self:getChairNodeName(vv.nChairNO)
        if(chair and (path~=""))then
            printf("~~~~~~~~~selfHeadcallbackFuc path %s~~~~~~~~~~~~~~~~~~~~~~",path)
            chair:getChildByName("Img_head"):getChildByName("Btn_head"):loadTextureNormal(path)
            chair:getChildByName("Img_head"):getChildByName("Btn_head"):loadTexturePressed(path)
        else
            printf("~~~~~~~~~selfHeadcallbackFuc path empty~~~~~~~~~~~~~~~~~~~~~~")
        end
                
        vv.portraitPath = path  
    end

    self._charterdRoomTalk:onGetSyncInfo() --ctz 

end

function CharteredRoom:onGetSyncInfo(sync)
    if not self:isNodeExist() then return end
    
    dump(sync)
    for i,v in pairs(sync)do
        self:showLBS(v.nUserID,v.szLBSInfo)
    end


    if(self._playerInfo==nil)then
        local data={}
        for i,v in pairs(sync)do
            local d={}
            d.userID=v.nUserID
            d.url=v.szHeadUrl
            table.insert(data,d)
        end
        local imageCtrl = require('src.app.BaseModule.ImageCtrl')
        imageCtrl:getImageForGameScene(data, 60-60, handler(self,self.onGetHeadPath))
        return
    end

    local data={}
    for i,v in pairs(sync)do
        local vv, ii = self:SearchPlayer(v.nUserID)
        if vv ~= nil then 
            vv.url = (v.szHeadUrl and v.szHeadUrl) or ''
            vv.lbs = v.szLBSInfo
            local d={}
            d.userID=v.nUserID
            d.url=v.szHeadUrl
            table.insert(data,d)
        end
    end

    local imageCtrl = require('src.app.BaseModule.ImageCtrl')
    imageCtrl:getImageForGameScene(data, 60-60, handler(self,self.onGetHeadPath))

  --  self._charterdRoomTalk:onGetSyncInfo(data)  
end

function CharteredRoom:onSomeOneTalked(chatFromTable,tableChatContent)
    if self._gameController:isTeamGameRoom() and self._gameController:isHallEntery() and self:isVisible() then
        self._charterdRoomTalk:onSomeOneTalked(chatFromTable,tableChatContent)
    end
end

function CharteredRoom:onCustomerServiceTalked(content)
    if self._charterdRoomTalk then
        self._charterdRoomTalk:customerServiceTalked(content)
    end
end

function CharteredRoom:sendTalk(message)
    local gbChatContent = MCCharset:getInstance():utf82GbString(message, string.len(message))
    self._gameController:onChatSend(gbChatContent)
end

function CharteredRoom:showLBS(nUserID,lbsJson)
    if(lbsJson==nil)then
        return
    end
    if(lbsJson=="")then
        return
    end
    printf("~~~~~~~~~~start showLBS~~~~~~~~~~~~")
    printf("~~~~~~~~~~lbsJson is %s~~~~~~~~~~~~",lbsJson)
    local json = cc.load("json").json
    local lbsJ = json.decode(lbsJson)
    if(lbsJ["la"]=="")then
        return
    end
    if(lbsJ["lo"]=="")then
        return
    end

    local lbsDes
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin==nil then
        lbsDes=lbsJ["ci"]
        if(lbsDes==nil)then
            return
        end
        printf("~~~~~~~nUserID [%d]  lbsDes is[%s]~~~~~~~~~~~~~~~~~~~",nUserID,lbsDes)
        self._gameController:setPlayerLbs(nUserID,lbsDes)
        return
    end

    if(not tcyFriendPlugin or tcyFriendPlugin.getPositionInfo==nil)then
        printf("~~~~~~~~~~~no getPositionInfo~~~~~~~~~~~~~~~~~~~~~~~`")      
        return
    end

    local lengthTable={}
    lengthTable.letters = 0
    lengthTable.words = 0
    local positionInfo = tcyFriendPlugin:getPositionInfo()
    if positionInfo then
        local latitude=positionInfo.latitude
        local longitude=positionInfo.longitude
        local la = lbsJ["la"]
        local lo = lbsJ["lo"]
        local distance = tcyFriendPlugin:getDistance(latitude,longitude,la,lo)
		--distance = distance *1000000
        local kmDistance=math.ceil(distance/1000-0.5)
        
        if type(distance) == "number" then 
            if (distance >= 1000) then
                if(kmDistance>10)then
                    if (lbsJ["ci"] and lbsJ["ci"] ~= "") then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["ci"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["ci"]

                    else

                        lbsDes = tostring(kmDistance).."km"
                        lengthTable.letters = string.len(tostring(kmDistance).."km")
                        printf("~~~~~~~~~showLBS no city~~~~~~~~~~~~~~~~~~~~~~~~")

                    end
                elseif(kmDistance<=10 and kmDistance>=1)then
                    if     (lbsJ["di"] and lbsJ["di"] ~= "") then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["di"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["di"]

                    elseif (lbsJ["ci"] and lbsJ["ci"] ~= "") then 

                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["ci"]
                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["ci"])
                        printf("~~~~~~~~~showLBS no districtName~~~~~~~~~~~~~~~~~~~~~~~~")

                    else

                        lbsDes = tostring(kmDistance).."km"
                        lengthTable.letters = string.len(tostring(kmDistance).."km")
                        printf("~~~~~~~~~showLBS no city~~~~~~~~~~~~~~~~~~~~~~~~")

                    end
                else
                    if     (lbsJ["bu"] ~= "" and lbsJ["bu"])then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["bu"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["bu"]

                    elseif (lbsJ["st"] ~= "" and lbsJ["st"])then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["st"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["st"]

                    elseif (lbsJ["di"] ~= "" and lbsJ["di"])then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["di"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["di"]

                    elseif (lbsJ["ci"] ~= "" and lbsJ["ci"]) then 

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["ci"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["ci"]

                    else

                        lengthTable.letters = string.len(tostring(kmDistance).."km")
                        lbsDes = tostring(kmDistance).."km"
                        printf("~~~~~~~~~showLBS no city~~~~~~~~~~~~~~~~~~~~~~~~")

                    end
                end
            elseif distance >= 0 then 
                if    (lbsJ["bu"] ~= "" and lbsJ["bu"])then
                    lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                    lengthTable.words = string.len(lbsJ["bu"])
                    lbsDes = distance.."m".." "..lbsJ["bu"]
                elseif(lbsJ["st"] ~= "" and lbsJ["st"])then
                    lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                    lengthTable.words = string.len(lbsJ["st"])
                    lbsDes = distance.."m".." "..lbsJ["st"]
                elseif(lbsJ["di"] ~= "" and lbsJ["di"])then
                    lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                    lengthTable.words = string.len(lbsJ["di"])
                    lbsDes = distance.."m".." "..lbsJ["di"]
                elseif(lbsJ["ci"] ~= "" and lbsJ["ci"])then
                    lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                    lengthTable.words = string.len(lbsJ["ci"])
                    lbsDes = distance.."m".." "..lbsJ["ci"]
                end
            else
                print("unexpected distance number value")
                lengthTable.words = string.len(lbsJ["ci"])
                lbsDes=lbsJ["ci"]
            end
        else
            print("wrong value type of distance, type:"..type(distance))
            lengthTable.words = string.len(lbsJ["ci"])
            lbsDes=lbsJ["ci"]
        end
        dump(distance)
    else
        printf("showLBS positionInfo is nil")
        lengthTable.words = string.len(lbsJ["ci"])
        lbsDes=lbsJ["ci"]
    end  

    if(lbsDes == nil)then
        return
    end

    --local tempLabel = cc.LabelTTF:create("","Marker Felt",18,cc.size(0,0),cc.TEXT_ALIGNMENT_LEFT)
    --local tempLabel = cc.Label:createWithSystemFont("","Marker Felt",18,cc.size(0,0),cc.TEXT_ALIGNMENT_LEFT)
    --tempLabel:setString(lbsDes)
	--lbsDes = "aaaaaaaaa"..lbsDes
    local function getLabelWidth()
        local length = lengthTable.words/3*2 +lengthTable.letters 
		print("getLableWidth:"..length)
        return length 
    end
    if getLabelWidth() >12 then 
        local lengthOverflow = getLabelWidth() - 12
		print("lengthOverflow:"..lengthOverflow)
		dump(lengthTable)
        if math.ceil((lengthOverflow + 2)/2)*3 <= lengthTable.words then 
            lbsDes = string.sub(lbsDes, 1, string.len(lbsDes)-math.ceil((lengthOverflow+2)/2)*3)..".."
        elseif lengthOverflow + 2 <= lengthTable.word/3*2 +lengthTable.letters then
            lbsDes = string.sub(lbsDes, 1, string.len(lbsDes)-lengthTable.words/3-lengthOverflow-2)..".."
        else
            print("lengthOverflow out of range")
        end
		
    end
    --print("label width:"..tempLabel:getWidth())
   --[[while tempLabel:getWidth() > 108 
    do
        --print("label width:"..tempLabel:getWidth())
        if lengthTable.words > 0 then 
            lengthTable.words = lengthTable.words -1 
            local a, b = string.find(lbsDes, "..") 
            if (a and b) then 
                lbsDes = string.sub(lbsDes, 1, string.len(lbsDes)-5)..".."
                tempLabel:setString(lbsDes)
            else
                lbsDes = string.sub(lbsDes, 1, string.len(lbsDes)-3)..".."
                tempLabel:setString(lbsDes)
            end
        elseif lengthTable.letters > 0 then 

            local a, b = string.find(lbsDes, "..")
            if (a and b) then 
                lengthTable.letters = lengthTable.letters - 1
                lbsDes = string.sub(lbsDes, 1, string.len(lbsDes)-3)..".."
                tempLabel:setString(lbsDes)
            else
                lengthTable.letters = lengthTable.letters - 2
                lbsDes = string.sub(lbsDes, 1, string.len(lbsDes)-2)..".."
                tempLabel:setString(lbsDes)
            end
        else
            print("unable to deduce lbsMsg")
            break
        end
    end]]

    printf("~~~~~~~nUserID [%d]  lbsDes is[%s]~~~~~~~~~~~~~~~~~~~",nUserID,lbsDes)
    if self._gameController then
        self._gameController:setPlayerLbs(nUserID,lbsDes)
    end

    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        if(cc.exports.sdkSession)then
            tcyFriendPlugin:onAgreeToBeInvitedBack(cc.exports.sdkSession, cc.exports.AgreeToBeInvitedType.kAgreeToBeInvitedSuccess,"")
            printf("~~~~~~~~~~~~~onAgreeToBeInvitedBack ok dxxw~~~~~~~~~~~~~~")
            dump(cc.exports.sdkSession)
            cc.exports.sdkSession=nil
        end
    end
end

function CharteredRoom:isFriend(playerUserID)
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin==nil then
        return true
    end
    if(tcyFriendPlugin:isFriend(playerUserID))then
        return true
    else
        return false
    end

end

function CharteredRoom:onGetHomeInfoOnDXXW(info)
    if(info)then
        user.hostID = info.nHomeUserID
        PUBLIC_INTERFACE.SetHostIdOfEnterTeamInfo(info.nHomeUserID)
        self:setPermissions()
    end
end

function CharteredRoom:isPlayerinCharteredRoom(userID)
	local info, i = self:SearchPlayer(user.hostID)
    return info ~= nil
end

function CharteredRoom:GetCharteredRoomHostName()
	local info, i = self:SearchPlayer(user.hostID)
    if info then 
        if self:isMyself(user.hostID) then
            return user.szUtf8Username
        end
    	return MCCharset:getInstance():gb2Utf8String( info.szUserName,string.len(info.szUserName) )
    end
    return ""
end

function CharteredRoom:SearchPlayer(nUserID)
    for i,v in pairs(self._playerInfo)do
    	if v.nUserID == nUserID then return v, i end
    end
end

function CharteredRoom:GetCharteredRoomHostID()
    if(user.hostID)then
        return user.hostID
    end
    return ""
end

function CharteredRoom:ResetInterfaceAfterGameEnd()

    if not self:isCharteredRoom()
    and not self._gameController:isTeamGameRoom() then
        printf("~~~~~~~~~~not create chartered room~~~~~~~~~~~~~~~")
        return
    end

    if(self._node:isVisible()==false)then
        return
    end

    touchEnable_ready(self._ready, true)

    self._gotoGame:setVisible(false)
    self._quitBtn:setVisible(true)

    local resultPanel = self._gameController._baseGameScene:getResultPanel()
    if(resultPanel)then
        resultPanel:hideResultPanel()
    end

end

function CharteredRoom:getSelfHeadImage()
    local imageCtrl = require('src.app.BaseModule.ImageCtrl')
    imageCtrl:getSelfImage(60-60, handler(self,self.selfHeadcallbackFuc))
end

function CharteredRoom:setPermissions()
     if (PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo() == user.nUserID) then
        if self._gameController:isTeamGameRoom() then
            self._findFromSDK:setVisible(false)
            self._find:setVisible(false)
            self._forbiddenBtn:setVisible(false)
            self._textForbidden:setVisible(false)
            self._textSetLockRoom:setVisible(true)
            self._checkBtnSetLockRoom:setVisible(true)
        else
            self._findFromSDK:setVisible(cc.exports.isSocialSupported())
            self._find:setVisible(true)
            self._forbiddenBtn:setVisible(true)
            self._textForbidden:setVisible(true)
            self._textSetLockRoom:setVisible(false)
            self._checkBtnSetLockRoom:setVisible(false)
        end
     else
        self._findFromSDK:setVisible(false)
        self._find:setVisible(false)
        self._forbiddenBtn:setVisible(false)
        self._textForbidden:setVisible(false)
        self._textSetLockRoom:setVisible(false)
        self._checkBtnSetLockRoom:setVisible(false)
     end
end

function CharteredRoom:isCurrentPlayerHost()
    return PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo() == user.nUserID
end

function CharteredRoom:dealWithChairSystemFindBtns()
    for z = 1, self._gameController:getTableChairCount() do
        local chair = self:getChairNodeName(z - 1)
        if chair then
            local invite = chair:getChildByName("Img_head"):getChildByName("Btn_invite")
            if self._gameController:isTeamGameRoom() then
                if self:isCurrentPlayerHost() and not self:isStartMatch() then
                    if cc.exports.isSocialSupported() then
                        invite:setVisible(true)
                    else
                        invite:setVisible(false)
                    end

                    self:showLockRoomInfo(true)
                else
                    invite:setVisible(false)
                    self:showLockRoomInfo(false)
                end
            else
                invite:setVisible(false)
                self:showLockRoomInfo(false)
            end
        end
    end

    for i, v in pairs(self._playerInfo) do
        local chair = self:getChairNodeName(v.nChairNO)
        if chair then
            local invite = chair:getChildByName("Img_head"):getChildByName("Btn_invite")
            invite:setVisible(false)
        end
    end
end

function CharteredRoom:showLockRoomInfo(bShow)
    if self._checkBtnSetLockRoom then
        self._checkBtnSetLockRoom:setVisible(bShow)
        if self._textSetLockRoom then
            self._textSetLockRoom:setVisible(bShow)
        end
    end
end

function CharteredRoom:startMatchStartedTimer()
    self:stopMatchStartedTimer()

    local function onMatchStartInterval(dt)
        self:onMatchStartedInterval()
    end
    self.matchStartedTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.onMatchStartedInterval), 5.0, false)
end

function CharteredRoom:stopMatchStartedTimer()
    if self.matchStartedTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.matchStartedTimerID)
        self.matchStartedTimerID = nil
    end
end

function CharteredRoom:onMatchStartedInterval()
    self:stopMatchStartedTimer()

    if self._gameController:isTeamGameRoom() then
        self:onCustomerServiceTalked(friendDesConfig["CHARTEREDROOM_NOTIFY_MATCHING"])
    end
end

function CharteredRoom:startMatchTimeoutTimer()
    self:stopMatchTimeoutTimer()

    local function onMatchTimeoutInterval(dt)
        self:onMatchTimeoutInterval()
    end
    self.matchTimeoutTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.onMatchTimeoutInterval), 120.0, false)
end

function CharteredRoom:stopMatchTimeoutTimer()
    if self.matchTimeoutTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.matchTimeoutTimerID)
        self.matchTimeoutTimerID = nil
    end
end

function CharteredRoom:onMatchTimeoutInterval()
    self:stopMatchTimeoutTimer()

    if self._gameController:isTeamGameRoom() then
        self:onCustomerServiceTalked(friendDesConfig["CHARTEREDROOM_NOTIFY_MATCHTIMEOUT"])

        if self:isRoomHost() then
            self:onCancelTeamMatch()
        end
    end
end

function CharteredRoom:onStartTeamReadyFailed()
    if self._gameController:isTeamGameRoom() and self:isRoomHost() then
        self._gameController:tipMessageByUTF8Str(friendDesConfig["CHARTEREDROOM_STARTMATCH_FAILED"])
    end
end

function CharteredRoom:dealWithStartButtonStatus()
    if self._gameController:isTeamGameRoom() and
        self:isRoomHost() and
        self._start and
        self._start:isVisible() then

        local bAllReady = true
        local playcount = 0
        for i, v in pairs(self._playerInfo) do
            playcount = playcount + 1

            if v.nUserID ~= user.nUserID and not v.isReady then
                bAllReady = false
                break
            end
        end
        if bAllReady then
            if playcount < self.limitMin then
                bAllReady = false
            end
        end
        self._start:setTouchEnabled(bAllReady)
        self._start:setBright(bAllReady)
    end
end

function CharteredRoom:isRoomHost()
    return user:isRoomHost()
end

function CharteredRoom:getChairNodeName(chairNO)
    if self._panelPosition and self._gameController then
        if self.limitMax == 2 then
            if chairNO == self._gameController:getMyChairNO() then
                return self._panelPosition:getChildByName("chair_0")
            end
            return self._panelPosition:getChildByName("chair_1")
        end
        return self._panelPosition:getChildByName("chair_"..tostring(self._gameController:rul_GetDrawIndexByChairNO(chairNO) - 1))
    end
    return ""
end

function CharteredRoom:isSelfReady()
    local v, i = self:SearchPlayer(user.nUserID)
    if v ~= nil then
        return v.isReady
    end
    return false
end

function CharteredRoom:isStartMatch()
    return self._isStartMatch
end

function CharteredRoom:setStartMatch(isStartMatch)
    cc.exports.isStartMatch = isStartMatch
    self._isStartMatch = isStartMatch

    if isStartMatch then
        self._tempAbortPlayerInfo = nil
    end
end

function CharteredRoom:updateGameDataForMoney()
    self._scroe:setString(user.nScore)
    self._deposit:setString(user.nDeposit)
end

function CharteredRoom:isMyself(userID)
    if userID == user.nUserID then
        return true
    end

    return false
end

return CharteredRoom