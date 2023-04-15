--MainCtrl的子模块管理工具
local MainCtrlSubManager = class("MainCtrlSubManager")

local PlayerModel   = mymodel("hallext.PlayerModel"):getInstance()
local UserModel     = mymodel('UserModel'):getInstance()
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local tcyFriendPluginWrapper = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()

local MyRoomManager = import('src.app.plugins.mainpanel.room.MyRoomManager')
local MainCtrlTest = import("src.app.plugins.mainpanel.MainCtrlTest")
local WeakenScoreRoomModel = require('src.app.plugins.weakenscoreroom.WeakenScoreRoomModel'):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local AnchorTableModel = import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()
local NewUserGuideModel = mymodel('NewUserGuideModel'):getInstance()

function MainCtrlSubManager:ctor(mainCtrl)
    self._mainCtrl = mainCtrl
    self.subRoomManager = MyRoomManager:create(mainCtrl)
    AnchorTableModel._myRoomManager = self.subRoomManager
    self.subTestHeper = MainCtrlTest:create(mainCtrl)

    self:_addEventListeners()
end

function MainCtrlSubManager:_addEventListeners()
    self._mainCtrl:listenTo(PlayerModel, PlayerModel.EVENT_MAP["playerModel_onGetDxxwInfo"], handler(self.subRoomManager, self.subRoomManager.onGetDXXWInfo))
    self._mainCtrl:listenTo(RoomListModel, RoomListModel.EVENT_MAP["roomListModel_roomPlayerNumUpdated"], handler(self.subRoomManager, self.subRoomManager.onRoomPlayerNumUpdated))

    self._mainCtrl:listenTo(HallContext, HallContext.EVENT_MAP["netProcessWatcher_netProcessFinished"], handler(self.subRoomManager, self.subRoomManager.onNetProcessFinished))
    self._mainCtrl:listenTo(RoomListModel, RoomListModel.EVENT_MAP["roomListModel_allRoomsInfoGot"], handler(self.subRoomManager, self.subRoomManager.onAllRoomsInfoGot))
    --self._mainCtrl:listenTo(HallContext, HallContext.EVENT_MAP["gameScene_goBackToMainScene"], handler(self.subRoomManager, self.subRoomManager.onBackFromGame))
    self._mainCtrl:listenTo(HallContext, HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], handler(self.subRoomManager, self.subRoomManager.onGotoGameByQuickStartInHall))
    self._mainCtrl:listenTo(HallContext, HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], handler(self.subRoomManager, self.subRoomManager.onGotoGameByRoomIdInGameScene))
    self._mainCtrl:listenTo(HallContext, HallContext.EVENT_MAP["gameScene_gotoScoreGame"], handler(self.subRoomManager, self.subRoomManager.onGotoScoreGameInGameScene))

    self._mainCtrl:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_friendSdkNewMsg"], handler(self.subRoomManager.subTeamRoomManager, self.subRoomManager.subTeamRoomManager.onFriendSdkNewMessage))
    self._mainCtrl:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_friendSdkMsgReaded"], handler(self.subRoomManager.subTeamRoomManager, self.subRoomManager.subTeamRoomManager.onFriendSdkMessageReaded))
    self._mainCtrl:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_inviteChoose"], handler(self.subRoomManager.subTeamRoomManager, self.subRoomManager.subTeamRoomManager.onFriendInviteChoose))
    self._mainCtrl:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_recieveInvitation"], handler(self.subRoomManager.subTeamRoomManager, self.subRoomManager.subTeamRoomManager.onRecieveInvitation))

    -- self._mainCtrl:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_friendSdkNewMsg"], handler(self.subRoomManager.subTeam2V2RoomManager, self.subRoomManager.subTeam2V2RoomManager.onFriendSdkNewMessage))
    -- self._mainCtrl:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_friendSdkMsgReaded"], handler(self.subRoomManager.subTeam2V2RoomManager, self.subRoomManager.subTeam2V2RoomManager.onFriendSdkMessageReaded))
    -- self._mainCtrl:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_inviteChoose"], handler(self.subRoomManager.subTeam2V2RoomManager, self.subRoomManager.subTeam2V2RoomManager.onFriendInviteChoose))
    -- self._mainCtrl:listenTo(tcyFriendPluginWrapper, tcyFriendPluginWrapper.EVENT_MAP["tcyFriendPlugin_recieveInvitation"], handler(self.subRoomManager.subTeam2V2RoomManager, self.subRoomManager.subTeam2V2RoomManager.onRecieveInvitation))

    self._mainCtrl:listenTo(WeakenScoreRoomModel, WeakenScoreRoomModel.EVENT_MAP["WeakenScoreRoomModel_dealScoreInfoResp"], handler(self.subRoomManager, self.subRoomManager.onScoreRoomBtn))
    self._mainCtrl:listenTo(WeakenScoreRoomModel, WeakenScoreRoomModel.EVENT_MAP["WeakenScoreRoomModel_refreshBtn"], handler(self.subRoomManager, self.subRoomManager.refreshScoreRoomBtnInfo))
    
    self._mainCtrl:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_gotoGameByRoomID"], handler(self.subRoomManager, self.subRoomManager.doGotoTimingGame))
    self._mainCtrl:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getInfoDataFromSvr"], handler(self.subRoomManager, self.subRoomManager.refreshViewOnTimingGameRecvInfo))
    self._mainCtrl:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getConfigFromSvr"], handler(self.subRoomManager, self.subRoomManager.refreshViewOnTimingGameRecvConfig))

    self._mainCtrl:listenTo(NewUserGuideModel, NewUserGuideModel.EVENT_SKIP_GUIDE, handler(self.subRoomManager, self.subRoomManager.onSkipGuide))
    -- 主播房事件
    --self._mainCtrl:listenTo(AnchorTableModel, AnchorTableModel.EVENT_MAP["anchor_gotoRoom"], handler(self.subRoomManager, self.subRoomManager.doGotoAnchorRoom))
    --self._mainCtrl:listenTo(AnchorTableModel, AnchorTableModel.EVENT_MAP["anchor_leaveRoom"], handler(self.subRoomManager, self.subRoomManager.doLeaveCurrentRoom))
end

return MainCtrlSubManager