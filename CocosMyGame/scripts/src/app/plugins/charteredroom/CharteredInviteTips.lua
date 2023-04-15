local user = mymodel('UserModel'):getInstance()
local CharteredInviteTips = class("CharteredInviteTips")

local SettingsModel = mymodel("hallext.SettingsModel"):getInstance()

function CharteredInviteTips:CreateViewNode(param)
    self.node = cc.CSLoader:createNode("res/hallcocosstudio/gamefriend/node_tip.csb")
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local origin = cc.Director:getInstance():getVisibleOrigin()

    local oPosX = visibleSize.width / 2
    local oPosY = visibleSize.height + origin.y
    self.node:setPosition(cc.p(oPosX,oPosY))

    self.Text_tip_detail = self.node:getChildByName("Panel_Tip_Animation"):getChildByName("Text_Detail")
    local s = string.format(self.Text_tip_detail:getString(), param.inviteName)
    self.Text_tip_detail:setString(s)

    local config = cc.exports.GetRoomConfig()
    self.Text_right = self.node:getChildByName("Panel_Tip_Animation"):getChildByName("Text_Right")
    self.Text_right:setString(config["CHARTERED_RIGHT"])

    self.Btn_accept = self.node:getChildByName("Panel_Tip_Animation"):getChildByName("Btn_Accept")
    self.Btn_accept:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                    local p={}
                    p.x=oPosX
                    p.y=oPosY
                self:AcceptToRoom(param,p)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)

    self.Btn_refuse = self.node:getChildByName("Panel_Tip_Animation"):getChildByName("Btn_Refuse")
    self.Btn_refuse:onTouch(function(e)
            if(e.name=='began')then
                e.target:setScale(cc.exports.GetButtonScale(e.target))
                my.playClickBtnSound()
            elseif(e.name=='ended')then
                e.target:setScale(1.0)
                local p={}
                p.x=oPosX
                p.y=oPosY
                self:Refuse(p)
            elseif(e.name=='cancelled')then
                e.target:setScale(1.0)
            elseif(e.name=='moved')then

            end
        end)

     self.CheckBox_forbidden = self.node:getChildByName("Panel_Tip_Animation"):getChildByName("Check_Forbidden")
     self.CheckBox_forbidden:addEventListenerCheckBox( handler(self,self.selectedEvent) )

     local a1 = cc.MoveTo:create(0.2, cc.p(oPosX,oPosY-self.node:getChildByName("Panel_Tip_Animation"):getContentSize().height))
     local a2 = cc.DelayTime:create( 10 )
     local a3 = cc.MoveTo:create(0.2, cc.p(oPosX,oPosY))
	 local a4 = cc.Sequence:create(a1,a2,a3,cc.CallFunc:create(function()
                self.node:removeSelf()
            end))

     cc.Director:getInstance():getRunningScene():addChild(self.node,1000)
     self.node:runAction(a4)
end

--[[
    CharteredInviteTips:AcceptToRoom(param,pos) -- from user operation
    CharteredInviteTips:AcceptToRoom(param) -- form program accpet the invitation
--]]
function CharteredInviteTips:AcceptToRoom(param,pos)
    if cc.exports.isStartMatch then
        self:Refuse(pos)
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=config["SDK_BEINVITED_ERR_MATCHING"],removeTime=5}})
        return
    end

    if (self.node~= nil) then
        self.node:stopAllActions()
        self.Btn_refuse:setTouchEnabled(false)
        self.Btn_accept:setTouchEnabled(false)

     local a1 = cc.MoveTo:create(0.3, cc.p(pos.x,pos.y))
	 local a2 = cc.Sequence:create(a1,cc.CallFunc:create(function()
                self.node:removeSelf()
            end))
        self.node:runAction(a2)
     end
    --start enter room
    cc.exports.LastEnterRoomID = param.nRoomID
    --local area, iRoom = cc.exports.searchRoom(param.nRoomID)
    local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
    local iRoom = RoomListModel.roomsInfo[param.nRoomID]
    if iRoom== nil then 
        print("~~~~~~~~~~~~~~~no room find [%d]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", param.nRoomID)
    end

    local tcyFriendPluginWrapper = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()
    tcyFriendPluginWrapper:onChooseAgreeFromInviteDialog(param)

end

function CharteredInviteTips:Refuse(param)
     self.node:stopAllActions()
     self.Btn_refuse:setTouchEnabled(false)
     self.Btn_accept:setTouchEnabled(false)

     local a1 = cc.MoveTo:create(0.3, cc.p(param.x,param.y))
	 local a2 = cc.Sequence:create(a1,cc.CallFunc:create(function()
                self.node:removeSelf()
            end))

     self.node:runAction(a2)

end

function CharteredInviteTips:selectedEvent(sender,eventType)
    local SettingsData
    local filename=SettingsModel.getSettingsDataFilename()
    if(my.isCacheExist(filename))then
        SettingsData=my.readCache(filename)
		SettingsData=checktable(SettingsData)
	else
		SettingsData=require('src.app.HallConfig.DefaultSettingsData')
        my.saveCache(filename,SettingsData)
	end

    if eventType == ccui.CheckBoxEventType.selected then
        SettingsData.isCharteredRoomTipsForbbiden = true
        my.saveCache(filename,SettingsData)

    elseif eventType == ccui.CheckBoxEventType.unselected then
        SettingsData.isCharteredRoomTipsForbbiden = false
        my.saveCache(filename,SettingsData)
    end
    SettingsModel:setForbiddenRoomTips(SettingsData.isCharteredRoomTipsForbbiden)
end

return CharteredInviteTips