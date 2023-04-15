local SecondLayerTeam2V2    = class('SecondLayerTeam2V2', import('.SecondLayerBase'))
local RoomListModel         = import('src.app.GameHall.room.model.RoomListModel'):getInstance()
local TeamTableListLayer    = import('src.app.plugins.mainpanel.room.TeamTableListLayer')
local Team2V2Model          = import('src.app.plugins.Team2V2Model.Team2V2Model'):getInstance()
local Team2V2ModelDef       = require('src.app.plugins.Team2V2Model.Team2V2ModelDef')
local UserModel             = mymodel('UserModel'):getInstance()
local PlayerModel           = mymodel('hallext.PlayerModel'):getInstance()

local coms = cc.load('coms')
local PropertyBinder = coms.PropertyBinder
local WidgetEventBinder = coms.WidgetEventBinder

my.setmethods(SecondLayerTeam2V2, PropertyBinder)
my.setmethods(SecondLayerTeam2V2, WidgetEventBinder)

function SecondLayerTeam2V2:ctor(layerNode, roomManager)
    SecondLayerTeam2V2.super.ctor(self, layerNode, roomManager)
    self.layerName = 'team2V2'
    self._areaEntryByLayer = 'team2V2'
    self._roomBtnsInfo = {}

    self:initEventListeners()
end

function SecondLayerTeam2V2:initEventListeners()
    self:listenTo(PlayerModel, PlayerModel.PLAYER_DATA_UPDATED, handler(self, self.updatePlayerInfo))
end

function SecondLayerTeam2V2:updatePlayerInfo()
    local needSync = false
    if Team2V2Model:isSelfLeader() then
        if self._textLeaderDeposit and self._textLeaderDeposit.getString and tonumber(self._textLeaderDeposit:getString()) ~= UserModel.nDeposit then
            needSync = true
        end
    else
        if self._textMateDeposit and self._textMateDeposit.getString and tonumber(self._textMateDeposit:getString()) ~= UserModel.nDeposit then
            needSync = true
        end
    end
    if needSync then
        self:refreshTeamInfo()
        Team2V2Model:reqSynchronInfo()
    end
end

function SecondLayerTeam2V2:initView()
    local layerNode = self._layerNode
    self._opePanel = layerNode:getChildByName('Operate_Panel')
    self._panelTop = self._opePanel:getChildByName('Panel_Top')
    self._panelTeamInfo = self._opePanel:getChildByName('Panel_TeamInfo')
    self._panelRoomList = self._opePanel:getChildByName('Panel_RoomList')
    self._panelQuickStart = self._opePanel:getChildByName('Panel_QuickStart')
    self._bInEnterAction = false

    cc.exports.zeroBezelNodeAutoAdapt(self._opePanel)

    self:_initTopBar()
    self:_initPanelQuickStart()
    self:_initTeamInfo()
    self:_initRoomList()
    -- self:_runEntryAni()
end

function SecondLayerTeam2V2:_initTopBar()
    local btnBack = self._panelTop:getChildByName('Button_Back')

    btnBack:addClickEventListener(handler(self, self._onClickBtnBack))
    SubViewHelper:initTopBar(self._panelTop, handler(self._roomManager._mainCtrl, self._roomManager._mainCtrl.onClickExit),handler(self, self.showRule))
end

function SecondLayerTeam2V2:showRule()
    my.informPluginByName({pluginName = "SecondLayerTeam2V2RuleCtrl"})
end

function SecondLayerTeam2V2:_initPanelQuickStart()
    local btnQuickStart = self._panelQuickStart:getChildByName("Button_QuickStart")
    self._textQuickStart = btnQuickStart:getChildByName('Text_Desc')

    btnQuickStart:addClickEventListener(function()
        my.playClickBtnSound()
        if self._quickStartRoomInfo then
            self:_onStartTeam2V2Match(self._quickStartRoomInfo)
        end
    end)

    SubViewHelper:setQuickStartAni(self._panelQuickStart)
end

function SecondLayerTeam2V2:_initTeamInfo()
    -- 初始化队长
    local panelTeamLeader = self._panelTeamInfo:getChildByName('Panel_TeamLeader')
    if panelTeamLeader then
        self._panelTeamLeader =  panelTeamLeader
        self._imgLeaderHead = panelTeamLeader:getChildByName('Img_Head')
        self._imgLeaderReady = panelTeamLeader:getChildByName('Img_Ready')
        self._textLeaderName = panelTeamLeader:getChildByName('Text_UserName')
        self._textLeaderDeposit = panelTeamLeader:getChildByName('Text_Deposit')
    end

    local panelTeamMate = self._panelTeamInfo:getChildByName('Panel_TeamMate')
    if panelTeamMate then
        self._panelTeamMate = panelTeamMate
        self._imgMateHead = panelTeamMate:getChildByName('Img_Head')
        self._imgMateReady = panelTeamMate:getChildByName('Img_Ready')
        self._imgMateFlag = panelTeamMate:getChildByName('Img_FlagMate')
        self._imgMateNameLine = panelTeamMate:getChildByName('Img_NameLine')
        self._imgMateIconDeposit = panelTeamMate:getChildByName('Img_IconDeposit')
        self._textMateName = panelTeamMate:getChildByName('Text_UserName')
        self._textMateDeposit = panelTeamMate:getChildByName('Text_Deposit')
        self._textMateInvate = panelTeamMate:getChildByName('Text_Invite')
        self._btnKickoutMate = panelTeamMate:getChildByName('Btn_Kickout')
        self._btnInviteMate = panelTeamMate:getChildByName('Btn_Invite')
        self._btnKickoutMate:addClickEventListener(handler(self, self.onKickoutMateClicked))
        self._btnInviteMate:addClickEventListener(handler(self, self.onInviteMateClicked))
    end

    self._btnReady = self._panelTeamInfo:getChildByName('Btn_Ready')
    self._btnReady:setVisible(false)
    self._btnReady:addClickEventListener(handler(self, self.onReadyClicked))
    
    self._btnCancelReady = self._panelTeamInfo:getChildByName('Btn_CancelReady')
    self._btnCancelReady:setVisible(false)
    self._btnCancelReady:addClickEventListener(handler(self, self.onCancelReadyClicked))

    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:refreshTeamInfo()
    self:refreshTeamLeaderInfo()
    self:refreshTeamMateInfo()
    self:refreshPanelQuickStart()
end

function SecondLayerTeam2V2:refreshTeamLeaderInfo()
    local teamInfo = Team2V2Model:getTeamInfo()
    if teamInfo and next(teamInfo) and teamInfo.leaderUserID ~= 0 then
        my.fitStringInWidget(teamInfo.leaderUserName, self._textLeaderName, 176)

        if teamInfo.leaderUserID == UserModel.nUserID then
            self._textLeaderDeposit:setMoney(UserModel.nDeposit)
        else
            self._textLeaderDeposit:setMoney(teamInfo.leaderUserSliver)
        end

        if teamInfo.leaderUserGender == 1 then
            self._imgLeaderHead:loadTexture('hallcocosstudio/images/plist/Team2V2Room/img_js_1.png', ccui.TextureResType.plistType)
        else
            self._imgLeaderHead:loadTexture('hallcocosstudio/images/plist/Team2V2Room/img_js_2.png', ccui.TextureResType.plistType)
        end
    end
end

function SecondLayerTeam2V2:refreshTeamMateInfo()
    local teamInfo = Team2V2Model:getTeamInfo()
    if teamInfo and next(teamInfo) and teamInfo.mateUserID ~= 0 then
        my.fitStringInWidget(teamInfo.mateUserName, self._textMateName, 176)
        self._textMateDeposit:setMoney(teamInfo.mateUserSliver)
        if teamInfo.mateUserState == Team2V2ModelDef.TEAM_PLAYER_READY_OK then
            self._imgMateReady:loadTexture('hallcocosstudio/images/plist/Team2V2Room/img_yzb.png', ccui.TextureResType.plistType)
        else
            self._imgMateReady:loadTexture('hallcocosstudio/images/plist/Team2V2Room/img_wzb.png', ccui.TextureResType.plistType)
        end

        if UserModel.nUserID == teamInfo.mateUserID then
            self._btnReady:setVisible(teamInfo.mateUserState ~= Team2V2ModelDef.TEAM_PLAYER_READY_OK)
            self._btnCancelReady:setVisible(teamInfo.mateUserState == Team2V2ModelDef.TEAM_PLAYER_READY_OK)
        else
            self._btnReady:setVisible(false)
            self._btnCancelReady:setVisible(false)
        end

        self._imgMateHead:setVisible(true)
        self._imgMateReady:setVisible(true)
        self._textMateName:setVisible(true)
        self._textMateDeposit:setVisible(true)
        self._imgMateNameLine:setVisible(true)
        self._imgMateIconDeposit:setVisible(true)
        self._btnKickoutMate:setVisible(true)
        self._imgMateFlag:setVisible(true)
        self._textMateInvate:setVisible(false)
        self._btnInviteMate:setVisible(false)

        if teamInfo.mateUserGender == 1 then
            self._imgMateHead:loadTexture('hallcocosstudio/images/plist/Team2V2Room/img_js_1.png', ccui.TextureResType.plistType)
        else
            self._imgMateHead:loadTexture('hallcocosstudio/images/plist/Team2V2Room/img_js_2.png', ccui.TextureResType.plistType)
        end
    else
        self._imgMateHead:setVisible(false)
        self._imgMateReady:setVisible(false)
        self._textMateName:setVisible(false)
        self._textMateDeposit:setVisible(false)
        self._imgMateNameLine:setVisible(false)
        self._imgMateIconDeposit:setVisible(false)
        self._btnKickoutMate:setVisible(false)
        self._imgMateFlag:setVisible(false)
        self._btnReady:setVisible(false)
        self._btnCancelReady:setVisible(false)
        self._textMateInvate:setVisible(true)
        self._btnInviteMate:setVisible(true)
    end
end

function SecondLayerTeam2V2:_initRoomList()
    local roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsTeam2V2)

    for i = 1, #roomInfoList do
        local roomInfo = roomInfoList[i]
        local nodeRoomBtn = self._panelRoomList:getChildByName('Btn_Room_' .. tostring(i))
        if nodeRoomBtn then
            local itemData = {['roomInfo'] = roomInfo, ['roomNode'] = nodeRoomBtn}
            table.insert(self._roomBtnsInfo, itemData)
    
            self:_initRoomBtn(itemData)
            self:refreshRoomBtnInfo(itemData)
        end
    end
end

function SecondLayerTeam2V2:_onStartTeam2V2Match(roomInfo)
    if self._bInEnterAction then
        return
    end
    
    local teamInfo = Team2V2Model:getTeamInfo()

    -- 判断入场条件
    if Team2V2Model:isSelfLeader() then
        local matchFailReason = 0
        if Team2V2Model:isAllReady() then
            -- 校验队长自己银两，无需同步
            local selfDeposit = UserModel.nDeposit
            if selfDeposit < roomInfo.nEnterMin then
                self._roomManager:onDepositNotEnoughWhenEnterRoom(roomInfo.nRoomID)
                return
            elseif selfDeposit > roomInfo.nEnterMax then
                if isSafeBoxSupported() then
                    self:showToastTip('您的携银太多了，请存一点掉吧！')
                    my.informPluginByName({
                        pluginName = "SafeboxCtrl", 
                        params = {
                            takeDepositeNum = (selfDeposit - roomInfo.nEnterMax),
                            btnOutVisible = false,
                            HallOrGame = true,
                            gameController = self._roomManager._mainCtrl
                        }
                    })
                else
                    self:showToastTip('您的携银太多了，请选择更高级的房间！')
                end
                return
            end

            if teamInfo.mateUserID ~= 0 then
                local mateDeposit = teamInfo.mateUserSliver
                if mateDeposit < roomInfo.nEnterMin then
                    matchFailReason = Team2V2ModelDef.MATCH_FAIL_REASON.MATCH_FAIL_MATE_DEPOSIT_NOT_ENOUGH
                elseif mateDeposit > roomInfo.nEnterMax then
                    matchFailReason = Team2V2ModelDef.MATCH_FAIL_REASON.MATCH_FAIL_MATE_DEPOSIT_TOO_HIGH
                end
            end
        else
            matchFailReason = Team2V2ModelDef.MATCH_FAIL_REASON.MATCH_FAIL_MATE_NOT_READY
        end

        if matchFailReason ~= 0 then
            Team2V2Model:reqMatchFail(matchFailReason, roomInfo['nRoomID'])
        else
            self._roomManager:tryEnterRoom(roomInfo['nRoomID'], nil, function()

            end)
        end
    else
        self:showToastTip('只有队长可以开启游戏！')
    end
end


function SecondLayerTeam2V2:_initRoomBtn(roomBtnInfo)
    local roomNode = roomBtnInfo['roomNode']
    local roomInfo = roomBtnInfo['roomInfo']

    roomNode:addClickEventListener(function()
        my.playClickBtnSound()
        self:_onStartTeam2V2Match(roomInfo)
    end)
end

function SecondLayerTeam2V2:refreshAllRoomBtnInfo()
    for i, itemData in ipairs(self._roomBtnsInfo) do
        self:refreshRoomBtnInfo(itemData)
    end
end

function SecondLayerTeam2V2:refreshRoomBtnInfo(roomBtnInfo)
    local roomNode = roomBtnInfo['roomNode']
    local roomInfo = roomBtnInfo['roomInfo']

    --设置底银
    self:refreshBaseDeposit(roomNode, roomInfo)
    --设置人数
    self:refreshOnlineUserCount(roomNode, roomInfo)
    --设置银两区间
    self:refreshDepositSection(roomNode, roomInfo)
    --设置房间规则
    self:refreshRoomRule(roomNode, roomInfo)
end

function SecondLayerTeam2V2:refreshBaseDeposit(roomNode, roomInfo)
    local bfBaseDeposit = roomNode:getChildByName('Bf_BaseDeposit')
    bfBaseDeposit:setString(RoomListModel:getRoomBaseDeposit(roomInfo['nRoomID']))
end

function SecondLayerTeam2V2:refreshOnlineUserCount(roomNode, roomInfo)
    local realUserCount = roomInfo['nUsers']
    local roomLevel = roomInfo['nRoomLevel']
    local textOnline = roomNode:getChildByName('Text_Online')
    if not realUserCount or realUserCount == '' then
        realUserCount = 1
    end

    local userCount = 0
    if roomLevel == 1 then
        userCount = realUserCount * 7 + 100
    elseif roomLevel == 2 then
        userCount = realUserCount * 5 + 50
    elseif roomLevel == 3 then
        userCount = realUserCount * 3 + 20
    end
    textOnline:setString(userCount)
end

function SecondLayerTeam2V2:refreshDepositSection(roomNode, roomInfo)
    local textDeposit = roomNode:getChildByName('Text_Deposit')

    local maxRoomDeposits = roomInfo['nEnterMax']
    if maxRoomDeposits == 2000000000 then -- 表示房间无上限
        local strDepositFrom = my.convertMoneyToTenThousand(roomInfo['nEnterMin'])
        textDeposit:setString('≥' .. strDepositFrom)
    else
        local strDepositFrom = my.convertMoneyToTenThousand(roomInfo['nEnterMin'])
        local strDepositTo = my.convertMoneyToTenThousand(roomInfo['nEnterMax'])
        textDeposit:setString(strDepositFrom..'-'..strDepositTo)
    end
end

function SecondLayerTeam2V2:refreshRoomRule(roomNode, roomInfo)
    local ruleString = Team2V2Model:getRuleStringByRoomInfo(roomInfo)
    local textRule = roomNode:getChildByName('Text_Rule')
    textRule:setString(ruleString)
end

function SecondLayerTeam2V2:refreshPanelQuickStart()
    local teamInfo = Team2V2Model:getTeamInfo()
    if not teamInfo or teamInfo.leaderUserID == 0 then
        return
    end
    if not self._roomBtnsInfo or #self._roomBtnsInfo <= 0 then
        return
    end

    local fitRoom
    for i, roomBtnInfo in ipairs(self._roomBtnsInfo) do
        local roomInfo = roomBtnInfo['roomInfo']
        local enterMin = roomInfo['nEnterMin']
        local enterMax = roomInfo['nEnterMax']
        local leaderFit = false
        local mateFit = false
        if teamInfo.leaderUserSliver <= enterMax and teamInfo.leaderUserSliver >= enterMin then
            leaderFit = true
        end

        if teamInfo.mateUserID == 0 or (teamInfo.mateUserID ~= 0 and teamInfo.mateUserSliver <= enterMax and teamInfo.mateUserSliver >= enterMin) then
            mateFit = true
        end
        if leaderFit and mateFit then
            fitRoom = roomInfo
        end
    end

    if not fitRoom then
        fitRoom = self._roomBtnsInfo[1]['roomInfo']
    end

    for i, roomBtnInfo in ipairs(self._roomBtnsInfo) do
        roomBtnInfo['roomNode']:getChildByName('Img_Light'):setVisible(roomBtnInfo['roomInfo'] == fitRoom)
    end

    self._quickStartRoomInfo = fitRoom
    if fitRoom then
        self._textQuickStart:setString(fitRoom['szTeamRoomName'])
    else
        self._textQuickStart:setString('')
    end
end

function SecondLayerTeam2V2:refreshView()
    self:refreshTopBarInfo()
    self:refreshAllRoomBtnInfo()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:refreshViewOnDepositChange()
    self:refreshTopBarInfo()
end

function SecondLayerTeam2V2:refreshTopBarInfo()
    SubViewHelper:setTopBarInfo(self._panelTop)
end

function SecondLayerTeam2V2:dealOnClose()
    self:removeEventHosts()
end

function SecondLayerTeam2V2:onRoomPlayerNumUpdated()
    for i = 1, #self._roomBtnsInfo do
        local roomNode = self._roomBtnsInfo[i]['roomNode']
        local roomInfo = self._roomBtnsInfo[i]['roomInfo']
        if roomNode and roomInfo then
            self:refreshOnlineUserCount(roomNode, roomInfo)
        end
    end
end

function SecondLayerTeam2V2:onInviteMateClicked()
    if cc.exports.isTeam2V2ShareSupported() then
        Team2V2Model:inviteMate()
    else
        self:showToastTip('当前版本不支持该功能哦~')
    end
end

function SecondLayerTeam2V2:onKickoutMateClicked()
    if Team2V2Model:isSelfLeader() then
        Team2V2Model:reqKickTeam()
    else
        Team2V2Model:setNeedJoinNewTeam(true)
        Team2V2Model:reqQuitTeam()
    end
end

function SecondLayerTeam2V2:onReadyClicked()
    Team2V2Model:reqDoReady()
end

function SecondLayerTeam2V2:onCancelReadyClicked()
    Team2V2Model:reqCancelReady()
end

function SecondLayerTeam2V2:onQueryConfigRsp()
    self:refreshAllRoomBtnInfo()
end

function SecondLayerTeam2V2:onCreateTeamRsp()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:onCancelTeamRsp()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:onQueryTeamRsp()
    self:refreshTeamInfo()
    self:refreshAllRoomBtnInfo()
end

function SecondLayerTeam2V2:onJoinTeamRsp()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:onQuitTeamRsp(data)
    if data and data.value then
        
    end
    self:showToastTip('当前队伍已解散~')
    self._roomManager:closeSecondeLayer(true)
end

function SecondLayerTeam2V2:onKickTeamRsp(data)
    if data and data.value then
        if  data.value.kickuserID == UserModel.nUserID then
            self:showToastTip('你已经被队长踢出~')
            self._roomManager:closeSecondeLayer(true)
        else
            self:showToastTip('您已将队友踢出~')
        end
    end
end

function SecondLayerTeam2V2:onReadyOKRsp()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:onCancelReadyRsp()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:onChangeRoomRsp()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:onSyncInfoRsp()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:onStartMatchRsp()
    
end

function SecondLayerTeam2V2:onMatchFailRsp(data)
    local failReason = data.value.failReason
    local teamInfo = Team2V2Model:getTeamInfo()
    if failReason == Team2V2ModelDef.MATCH_FAIL_REASON.MATCH_FAIL_MATE_NOT_READY then
        if UserModel.nUserID == data.value.friendUserID then
            local tipString = string.format('请准备，队长%s正在开始游戏！', teamInfo.leaderUserName)
            self:showToastTip(tipString)
        else
            local tipString = string.format('队友%s还未准备！', teamInfo.mateUserName)
            self:showToastTip(tipString)
        end
    elseif failReason == Team2V2ModelDef.MATCH_FAIL_REASON.MATCH_FAIL_MATE_DEPOSIT_NOT_ENOUGH then
        if UserModel.nUserID == data.value.friendUserID then
            local tipString = string.format('队长%s正在开始游戏，你的银两不够了！', teamInfo.leaderUserName)
            self:showToastTip(tipString)
            self._roomManager:onDepositNotEnoughWhenEnterRoom(data.value.roomID)
        else
            local tipString = string.format('队友%s银两不够了！', teamInfo.mateUserName)
            self:showToastTip(tipString)
        end
    elseif failReason == Team2V2ModelDef.MATCH_FAIL_REASON.MATCH_FAIL_MATE_DEPOSIT_TOO_HIGH then
        if UserModel.nUserID == data.value.friendUserID then
            local tipString = string.format('队长%s正在开始游戏，你的银两太多了！', teamInfo.leaderUserName)
            self:showToastTip(tipString)

            if isSafeBoxSupported() then
                local enterMax = 0
                for i, roomBtnInfo in ipairs(self._roomBtnsInfo) do
                    if roomBtnInfo.roomInfo and roomBtnInfo.roomInfo.nRoomID == data.value.roomID then
                        enterMax = roomBtnInfo.roomInfo.nEnterMax
                    end
                end
                if enterMax ~= 0 then
                    my.informPluginByName({
                        pluginName = "SafeboxCtrl", 
                        params = {
                            takeDepositeNum = (UserModel.nDeposit - enterMax),
                            btnOutVisible = false,
                            HallOrGame = true,
                            gameController = self._roomManager._mainCtrl
                        }
                    })
                end
            end
        else
            local tipString = string.format('队员%s银两太多了！', teamInfo.mateUserName)
            self:showToastTip(tipString)
        end
    end
end

function SecondLayerTeam2V2:onSyncRealTeamRsp()
    self:refreshTeamInfo()
end

function SecondLayerTeam2V2:onOverTimeCancelTeamRsp()
end

function SecondLayerTeam2V2:_onClickBtnBack()
    my.playClickBtnSound()

    if not UIHelper:checkOpeCycle('SecondLayer_btnBack') then
        return
    end
    UIHelper:refreshOpeBegin('SecondLayer_btnBack')
    Team2V2Model:reqQuitTeam()
end

function SecondLayerTeam2V2:onKeyback()
    Team2V2Model:reqQuitTeam()
end

function SecondLayerTeam2V2:showToastTip(tipString, waitTime)
    my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = tipString, removeTime = waitTime and waitTime or 2}})
end

function SecondLayerTeam2V2:_runEntryAni()
    self._bInEnterAction = true
    local nodeTeamInfo = self._panelTeamInfo
    if nodeTeamInfo.posXRaw == nil then
        nodeTeamInfo.posXRaw = nodeTeamInfo:getPositionX()
    end

    nodeTeamInfo:setPositionX(nodeTeamInfo.posXRaw - 300)
    nodeTeamInfo:setOpacity(10)

    my.scheduleOnce(function()
        local moveAction = cc.MoveTo:create(0.4, cc.p(nodeTeamInfo.posXRaw, nodeTeamInfo:getPositionY()))
        local fadeAction = cc.FadeTo:create(0.4, 255)
        local spawnAction = cc.Spawn:create(cc.EaseBackOut:create(moveAction), fadeAction)
        nodeTeamInfo:runAction(spawnAction)
    end, 0)
    

    local nodeRoomList = self._panelRoomList
    if nodeRoomList.posXRaw == nil then
        nodeRoomList.posXRaw = nodeRoomList:getPositionX()
    end

    local curPosX = nodeRoomList:getPositionX()
    if curPosX > nodeRoomList.posXRaw then
        return
    end

    --先设定好初始位置和透明度，下一帧再执行帧动画，可以更流畅
    nodeRoomList:setPositionX(nodeRoomList.posXRaw + 300)
    nodeRoomList:setOpacity(10)

    my.scheduleOnce(function()
        local moveAction = cc.MoveTo:create(0.4, cc.p(nodeRoomList.posXRaw, nodeRoomList:getPositionY()))
        local fadeAction = cc.FadeTo:create(0.4, 255)
        local spawnAction = cc.Spawn:create(cc.EaseBackOut:create(moveAction), fadeAction)
        local sequenceAction = cc.Sequence:create(spawnAction, cc.CallFunc:create(function()
            self._bInEnterAction = false
        end))
        nodeRoomList:runAction(sequenceAction)
    end, 0)
end

return SecondLayerTeam2V2