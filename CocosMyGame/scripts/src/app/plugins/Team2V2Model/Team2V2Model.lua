local Team2V2Model                  = class('Team2V2Model', require('src.app.GameHall.models.BaseModel'))
local Team2V2ModelDef               = require('src.app.plugins.Team2V2Model.Team2V2ModelDef')
local AssistModel                   = mymodel('assist.AssistModel'):getInstance()
local user                          = mymodel('UserModel'):getInstance()
local deviceModel                   = mymodel('DeviceModel'):getInstance()
local MyTimeStampCtrl               = import("src.app.mycommon.mytimestamp.MyTimeStamp"):getInstance()
local PluginProcessModel            = mymodel("hallext.PluginProcessModel"):getInstance()
local UserModel                     = mymodel('UserModel'):getInstance()
local json                          = cc.load("json").json

my.addInstance(Team2V2Model)

local coms=cc.load('coms')
local PropertyBinder        =coms.PropertyBinder
local WidgetEventBinder     =coms.WidgetEventBinder
my.setmethods(Team2V2Model,PropertyBinder)
my.setmethods(Team2V2Model,WidgetEventBinder)

protobuf.register_file('src/app/plugins/Team2V2Model/pbTeam2V2Model.pb')

local RankString = {
    "过2", "过3", "过4", "过5", "过6", "过7", "过8", "过9", "过10", "过J", "过Q", "过K", "过A",
}

function Team2V2Model:onCreate()
    self._lastLoginUserID           = nil       -- 最后登陆用户ID
    self._config                    = nil       -- 组队2V2配置

    self:initTeamInfo()

    -- self._teamInfo = {
    --     teamPlayerNum = 0,
    --     leaderUserID = 0,
    --     mateUserID = 0,
    --     leaderUserSliver = 0,
    --     mateUserSliver = 0,
    --     leaderUserState = 0,
    --     mateUserState = 0,
    --     leaderUserName = '',
    --     mateUserName = '',
    --     realTeamInfo = {
    --         leaderUserID = 0,
    --         mateUserID = 0,
    --         roomID = 0,
    --         tableNO = 0,
    --         enterGameFlag = 0,
    --         roomLevel = 0,
    --         leastRank = 0,
    --     }
    -- }

    self:listenTo(MyTimeStampCtrl, MyTimeStampCtrl.UPDATE_DAY,  handler(self,self.updateDay))

    -- 注册回调
    self:initAssistResponse()
    self:initEvent()
end

function Team2V2Model:initTeamInfo()
    self._teamInfo = {
        teamPlayerNum = 0,
        leaderUserID = 0,
        mateUserID = 0,
        leaderUserSliver = 0,
        mateUserSliver = 0,
        leaderUserState = 0,
        mateUserState = 0,
        leaderUserName = '',
        mateUserName = '',
        realTeamInfo = {
            leaderUserID = 0,
            mateUserID = 0,
            roomID = 0,
            tableNO = 0,
            enterGameFlag = 0,
            roomLevel = 0,
            leastRank = 0,
        }
    }
end

function Team2V2Model:initEvent()
    -- 切后台
    AppUtils:getInstance():addResumeCallback(handler(self, self.onResumeCallback), 'Team2V2Model_SetForegroundCallback')
end

function Team2V2Model:onResumeCallback()
    local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
    if not RoomListModel:checkAreaEntryAvail('team2V2') then
        local clipBoardCmd = ""
        clipBoardCmd = DeviceUtils:getInstance():getClipboardContent()
        if clipBoardCmd and string.len(clipBoardCmd) > 0 then
            cc.exports.clipboardContent = clipBoardCmd
        end

        if DeviceUtils:getInstance().copyToClipboard then
            DeviceUtils:getInstance():copyToClipboard('')
        end
        return
    end

    local cmd = ""
    if DeviceUtils:getInstance().getClipboardContent then
        cmd = DeviceUtils:getInstance():getClipboardContent()
        if cmd and string.len(cmd) > 0 then
            cc.exports.clipboardContent = cmd
        end
        if DeviceUtils:getInstance().copyToClipboard then
            DeviceUtils:getInstance():copyToClipboard('')
        end
    end

    if not cmd or string.len(cmd) <= 0 then
        return
    end

    local cmdTbl = string.split(cmd, '=')
    if #cmdTbl < 2 or cmdTbl[1] ~= 'GameContent' then
        return
    end

    local buffer
    if string.sub(cmdTbl[2], 1, 3) == '%7B' then
        -- 判断是否是url编码
        buffer = string.urldecode(cmdTbl[2])
    else
        buffer = cmdTbl[2]
    end
    local content = string.len(buffer) > 0 and json.decode(buffer)

    self:receiveInvite(content)
end

function Team2V2Model:receiveInvite(content)
    if not self:isTeam2V2InviteContent(content) then
        return
    end

    if my.isInGame() then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "正在游戏中，无法加入队伍~", removeTime = 2}})
        return false
    end

    if self._teamInfo and self._teamInfo.leaderUserID ~= 0 then
        -- 已有队伍，先退出队伍，再加入
        self:setNeedJoinNewTeam(true, content.UserID)
        self:reqQuitTeam()
    else
        self:reqJoinTeam(content.UserID)
    end
end


-- 登陆用户改变
function Team2V2Model:loginUserChange()
    if self._lastLoginUserID and self._lastLoginUserID ~= user.nUserID then
        self._config                    = nil       -- 组队2V2配置
    end

    self._lastLoginUserID   = user.nUserID      -- 最后登陆用户ID
end

-- 新的一天重新请求
function Team2V2Model:updateDay()
    
end

-- 是否开启组队2V2
function Team2V2Model:isOpen()
    if not cc.exports.isTeam2V2RoomSupported() then
        return false
    end

    if not self._config then
        return false
    end

    if self._config.Enable ~= 1 then
        return false
    end

    return true
end

-- 是否显示组队2V2红点
function Team2V2Model:isNeedReddot()
    return false
end

-- 注册回调
function Team2V2Model:initAssistResponse()
    self._assistResponseMap = {
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUERY_CONFIG] = handler(self, self.onQueryTeam2V2ModelConfig),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_CREATE_TEAM] = handler(self, self.onCreateTeam),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_CANCEL_TEAM] = handler(self, self.onCancelTeam),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUERY_TEAM] = handler(self, self.onQueryTeam),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_JOIN_TEAM] = handler(self, self.onJoinTeam),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUIT_TEAM] = handler(self, self.onQuitTeam),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_KICK_TEAM] = handler(self, self.onKickTeam),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_DO_READY] = handler(self, self.onDoReady),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_CANCEL_READY] = handler(self, self.onCancelReady),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_CHANGE_ROOM] = handler(self, self.onChangeRoom),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_SYNCHRON_INFO] = handler(self, self.onSynchronInfo),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_START_MATCH] = handler(self, self.onStartMatch),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_MATCH_FAIL] = handler(self, self.onMatchFail),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_SYNCHRON_REAL_TEAM] = handler(self, self.onSynchronRealTeam),
        [Team2V2ModelDef.GR_TEAM_2V2_MODEL_OVER_TIME_CANCEL_TEAM] = handler(self, self.onOverTimeCancelTeam),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

--请求组队2V2活动配置
function Team2V2Model:reqTeam2V2ModelConfig()
    print("Team2V2Model:reqTeam2V2ModelConfig")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID = user.nUserID,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqTeam2V2ModelConfig', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUERY_CONFIG, pdata, false)
end

--响应组队2V2配置获取
function Team2V2Model:onQueryTeam2V2ModelConfig(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported() then return end

    local pdata = json.decode(data)

    dump(pdata, "Team2V2Model:onQueryTeam2V2ModelConfig")

    self._config = pdata

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUERY_CONFIG_RSP})
end

--请求创建队伍
function Team2V2Model:reqCreateTeam()
    print("Team2V2Model:reqCreateTeam")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local nickName = NickNameInterface.getNickName()
    local userNameStr = nickName or user.szUtf8Username
    local userSex = 0
    if user:getSexName() == "girl" then
        userSex = 1
    end

    local data = {
        userID              = user.nUserID,
        userName            = userNameStr,
        userGender          = userSex,      -- 0:girl 1:boy
        teamPlayerNum       = Team2V2ModelDef.TEAM_PLAYER_NUM_TWO,
        leaderUserSliver    = user.nDeposit or 0,
        leaderUserState     = Team2V2ModelDef.TEAM_PLAYER_READY_OK,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqCreateTeam', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_CREATE_TEAM, pdata, false)
end

--响应创建队伍
function Team2V2Model:onCreateTeam(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespCreateTeam', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onCreateTeam")

    -- todo   
    self._teamInfo = clone(pdata.teamInfo)
    self:setNeedJoinNewTeam(false, nil)
    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_CREATE_TEAM_RSP, value = pdata})
end

--请求取消队伍
function Team2V2Model:reqCancelTeam()
    --预留
end

--响应取消队伍
function Team2V2Model:onCancelTeam(data)
    --预留
end

--请求查询队伍
function Team2V2Model:reqQueryTeam()
    print("Team2V2Model:reqQueryTeam")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID              = user.nUserID,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqQueryTeam', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUERY_TEAM, pdata, false)
end

--响应查询队伍
function Team2V2Model:onQueryTeam(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespQueryTeam', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onQueryTeam")

    -- todo   
    if pdata.teamInfo and pdata.teamInfo.leaderUserID then
        self._teamInfo = pdata.teamInfo
    else
        self:initTeamInfo()
    end

    PluginProcessModel:setPluginReadyStatus('Team2V2Model', false)
    if pdata.queryResult == Team2V2ModelDef.QUERY_TEAM_RESULT.FIND_TEAM then
        PluginProcessModel:stopPluginProcess()
    else
        PluginProcessModel:startPluginProcess()
    end

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUERY_TEAM_RSP, value = pdata})
end

--请求加入队伍
function Team2V2Model:reqJoinTeam(homeUserID)
    print("Team2V2Model:reqJoinTeam")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local nickName = NickNameInterface.getNickName()
    local userNameStr = nickName or user.szUtf8Username
    local userSex = 0
    if user:getSexName() == "girl" then
        userSex = 1
    end

    local data = {
        userID              = user.nUserID,
        userName            = userNameStr,
        userGender          = userSex,      -- 0:girl 1:boy
        userSliver          = user.nDeposit or 0,
        userState           = Team2V2ModelDef.TEAM_PLAYER_NOT_READY,
        leaderUserID        = homeUserID,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqJoinTeam', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_JOIN_TEAM, pdata, false)
end

--响应加入队伍
function Team2V2Model:onJoinTeam(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespJoinTeam', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onJoinTeam")

    -- todo   
    self._teamInfo = pdata.teamInfo
    self:setNeedJoinNewTeam(false, nil)
    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_JOIN_TEAM_RSP, value = pdata})
end

--请求退出队伍
function Team2V2Model:reqQuitTeam()
    print("Team2V2Model:reqQuitTeam")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID              = user.nUserID,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqQuitTeam', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUIT_TEAM, pdata, false)
end

--响应退出队伍
function Team2V2Model:onQuitTeam(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespQuitTeam', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onQuitTeam")

    -- todo   
    local params = clone(pdata)
    params.oldTeamInfo = clone(self._teamInfo)

    if UserModel.nUserID ~= pdata.userID then
        self._teamInfo = pdata.teamInfo
    else
        self:initTeamInfo()
    end

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUIT_TEAM_RSP, value = params})
end

--请求踢出队伍
function Team2V2Model:reqKickTeam(kickUserID)
    print("Team2V2Model:reqKickTeam")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID              = UserModel.nUserID,
        kickuserID          = self._teamInfo.mateUserID,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqKickTeam', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_KICK_TEAM, pdata, false)
end

--响应踢出队伍
function Team2V2Model:onKickTeam(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespKickTeam', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onKickTeam")

    -- todo   
    self._teamInfo = pdata.teamInfo

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_KICK_TEAM_RSP, value = pdata})
end

--队友准备
function Team2V2Model:reqDoReady()
    print("Team2V2Model:reqDoReady")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID              = user.nUserID,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqDoReady', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_DO_READY, pdata, false)
end

--响应队友准备
function Team2V2Model:onDoReady(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespDoReady', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onDoReady")

    -- todo
    self._teamInfo = pdata.teamInfo

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_DO_READY_RSP, value = pdata})
end

--队长/队友取消准备
function Team2V2Model:reqCancelReady(userID)
    print("Team2V2Model:reqCancelReady")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID              = userID ~= nil and userID or user.nUserID,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqCancelReady', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_CANCEL_READY, pdata, false)
end

--响应队长/队友取消准备
function Team2V2Model:onCancelReady(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespCancelReady', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onCancelReady")

    -- todo   
    self._teamInfo = pdata.teamInfo
    
    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_CANCEL_READY_RSP, value = pdata})
end

--队长切换房间(废弃)
function Team2V2Model:reqChangeRoom()
    --预留
end

--响应队长切换房间(废弃)
function Team2V2Model:onChangeRoom(data)
    --预留
end

--队友同步信息(携银变化)
function Team2V2Model:reqSynchronInfo()
    print("Team2V2Model:reqSynchronInfo")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID              = user.nUserID,
        sliver              = user.nDeposit,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqSynchronInfo', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_SYNCHRON_INFO, pdata, false)
end

--响应队友同步信息(携银变化)
function Team2V2Model:onSynchronInfo(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespSynchronInfo', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onSynchronInfo")

    -- todo   
    self._teamInfo = pdata.teamInfo

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_SYNCHRON_INFO_RSP, value = pdata})
end

--队长开始匹配
function Team2V2Model:reqStartMatch()
    print("Team2V2Model:reqStartMatch")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID              = user.nUserID,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqStartMatch', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_START_MATCH, pdata, false)
end

--响应队长开始匹配
function Team2V2Model:onStartMatch(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespStartMatch', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onStartMatch")

    -- todo   
    if pdata.teamInfo and pdata.teamInfo.leaderUserID then
        self._teamInfo = pdata.teamInfo
    else
        self:initTeamInfo()
    end

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_START_MATCH_RSP, value = pdata})
end

--队长匹配失败（同步队友）
function Team2V2Model:reqMatchFail(failReason, roomID)
    print("Team2V2Model:reqMatchFail")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userID = user.nUserID,
        friendUserID = self._teamInfo.mateUserID,
        failReason = failReason,
        roomID = roomID
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqMatchFail', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_MATCH_FAIL, pdata, false)
end

--响应队长匹配失败（同步队友）
function Team2V2Model:onMatchFail(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespMatchFail', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onMatchFail")

    -- todo   
    if pdata.teamInfo and pdata.teamInfo.leaderUserID then
        self._teamInfo = pdata.teamInfo
    else
        self:initTeamInfo()
    end

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_MATCH_FAIL_RSP, value = pdata})
end

--队长同步真实队伍信息
function Team2V2Model:reqSynchronRealTeam(realTeamIf)
    print("Team2V2Model:reqSynchronRealTeam")
    if not cc.exports.isTeam2V2RoomSupported() then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local rTeamInfo = {
        leaderUserID		= realTeamIf.leaderUserID;
	    mateUserID			= realTeamIf.mateUserID;
	    roomID				= realTeamIf.roomID;
	    tableNO				= realTeamIf.tableNO;
	    enterGameFlag		= realTeamIf.enterGameFlag;
	    roomLevel			= realTeamIf.roomLevel;
	    leastRank			= realTeamIf.leastRank;
    }

    local data = {
        userID              = user.nUserID,
        realTeamInfo        = rTeamInfo,
    }
    local pdata = protobuf.encode('pbTeam2V2Model.ReqSynchronRealTeam', data)
    AssistModel:sendData(Team2V2ModelDef.GR_TEAM_2V2_MODEL_SYNCHRON_REAL_TEAM, pdata, false)
end

--响应队长同步真实队伍信息
function Team2V2Model:onSynchronRealTeam(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTeam2V2RoomSupported()  then return end

    local pdata = protobuf.decode('pbTeam2V2Model.RespSynchronRealTeam', data)
    protobuf.extract(pdata)
    dump(pdata, "Team2V2Model:onSynchronRealTeam")

    -- todo   
    if pdata.teamInfo and pdata.teamInfo.leaderUserID then
        self._teamInfo = pdata.teamInfo
    else
        self:initTeamInfo()
    end

    self:dispatchEvent({name = Team2V2ModelDef.GR_TEAM_2V2_MODEL_SYNCHRON_REAL_TEAM_RSP, value = pdata})
end

--组队超时解散队伍（队长选择房间后多长时间后队友未加入真实队伍则解散队伍）
function Team2V2Model:reqOverTimeCancelTeam()
    -- 预留
end

--响应组队超时解散队伍（队长选择房间后多长时间后队友未加入真实队伍则解散队伍）
function Team2V2Model:onOverTimeCancelTeam(data)
    -- 预留
end

-- 获取配置
function Team2V2Model:getConfig()
    return self._config
end

function Team2V2Model:getRoomList()
    return self._config and self._config.RoomList or {}
end

function Team2V2Model:getTeamInfo()
    return self._teamInfo
end

function Team2V2Model:isTeam2V2InviteContent(content)
    if not cc.exports.isTeam2V2RoomSupported() then
        return false
    end

    if not content or not next(content) then
        return false
    end

    if not content.Team2V2Invite then
        return false
    end

    if not content.UserID or content.UserID <= 0 then
        return false
    end

    if content.UserID == UserModel.nUserID then
        return false
    end
    
    if not content.InviteTimeStamp or os.time() - content.InviteTimeStamp > getTeam2V2InviteExpire() then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "组队邀请已过期~", removeTime = 2}})
        return false
    end
    
    if content.UserID == self._teamInfo.leaderUserID then
        return false
    end

    if content.UserID == self._teamInfo.mateUserID then
        return false
    end

    return true
end

function Team2V2Model:makeShareUrl(url)
    local GameContent = {
        Team2V2Invite = true,
        GameCode = my.getAbbrName(),
        UserID = UserModel.nUserID,
        UserName = NickNameInterface.getNickName(),
        GameRule = '掼蛋组队连打',
        InviteTimeStamp = os.time()
    }
    local GameContentString = json.encode(GameContent)

    local pkgName = ''
    if DeviceUtils:getInstance().getPackageName then
        pkgName = DeviceUtils:getInstance():getPackageName()
    end

    local params = {
        Pkg = pkgName,
        Hardid = require("src.app.GameHall.models.DeviceModel"):getInstance().szHardID,
        Channelid = BusinessUtils:getInstance():getTcyChannel(),
        GameContent = string.urlencode(GameContentString)
    }

    DeviceUtils:getInstance():copyToClipboard(string.format('GameContent=%s', string.urlencode(GameContentString)))

    if not string.find(url, '?') then
        url = url .. '?'
    end

    local paramIndex = 1
    for k, v in pairs(params) do
        url = url .. k .. '=' .. v
        if paramIndex < table.nums(params) then
            url = url .. '&'
        end
        paramIndex = paramIndex + 1
    end

    return url
end

-- 分享邀请链接
function Team2V2Model:inviteMate()
    if self._shareWaitTimer then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "操作频繁，请稍后再试~", removeTime = 2}})
        return
    end

    self._shareWaitTimer = my.createSchedule(function()
        if self._shareWaitTimer then
            my.removeSchedule(self._shareWaitTimer)
            self._shareWaitTimer = nil
        end
    end, 2)

    if not DeviceUtils:getInstance():isAppInstalled("com.tencent.mm") then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "微信未安装！", removeTime = 1}})
        return
    end

    local shareObj = clone(cc.exports.getTeam2V2ShareObj())
    if shareObj.url then
        shareObj.url = self:makeShareUrl(shareObj.url)
    end

    if shareObj.type then
        shareObj.type = tostring(C2DXContentType[shareObj.type])
    end

    if shareObj.image then
        shareObj.imagePath = shareObj.image
    end

    local sharePlugin = plugin.AgentManager:getInstance():getSharePlugin()

    if not sharePlugin then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "不支持此功能！", removeTime = 3}})
        return
    end

    sharePlugin:setCallback(function(code, msg)
        if self._shareWaitTimer then
            my.removeSchedule(self._shareWaitTimer)
            self._shareWaitTimer = nil
        end
    end)

    sharePlugin:configDeveloperInfo({})
    sharePlugin:share(C2DXPlatType[shareObj.shareTo], true, shareObj)
end

function Team2V2Model:getRuleStringByRoomInfo(roomInfo)
    if not roomInfo.nLeastRank or roomInfo.nLeastRank <= 0 or roomInfo.nLeastRank > 13 then
        return '未知规则'
    end
    return RankString[roomInfo.nLeastRank]
end

function Team2V2Model:isSelfLeader()
    return self._teamInfo.leaderUserID == UserModel.nUserID
end

function Team2V2Model:isSelfMate()
    return self._teamInfo.mateUserID == UserModel.nUserID
end

function Team2V2Model:getTeamMateCount()
    if self._teamInfo.leaderUserID ~= 0 and self._teamInfo.mateUserID ~= 0 then
        return 2
    elseif self._teamInfo.leaderUserID ~= 0 and self._teamInfo.mateUserID == 0 then
        return 1
    end
    return 0
end

function Team2V2Model:isAllReady()
    if self._teamInfo.mateUserID ~= 0 then
        return self._teamInfo.mateUserState == Team2V2ModelDef.TEAM_PLAYER_READY_OK
    end
    return true
end

function Team2V2Model:needJoinNewTeam()
    return self._needJoinNewTeam, self._needJoinTeamLeader
end

function Team2V2Model:setNeedJoinNewTeam(needJoinNewTeam, teamLeader)
    self._needJoinNewTeam = needJoinNewTeam
    self._needJoinTeamLeader = teamLeader -- teamLeader为nil时创建队伍
end

function Team2V2Model:onCreateTeam2V2RoomOK(roomContext)

    local roomInfo = roomContext['roomInfo']
    local tableInfo = roomContext['tableInfo']

    local realTeamInfo = {
        leaderUserID = self._teamInfo.leaderUserID,
        mateUserID = self._teamInfo.mateUserID,
        roomID = roomInfo.nRoomID,
        tableNO = tableInfo.nTableNO,
        enterGameFlag = 3,
        roomLevel = roomInfo.nRoomLevel,
        leastRank = roomInfo.nLeastRank,
    }

    self:reqSynchronRealTeam(realTeamInfo)
end

function Team2V2Model:backFromGame()
    if self._teamInfo.mateUserID ~= 0 then
        Team2V2Model:reqCancelReady(self._teamInfo.mateUserID)
    end
    self:reqSynchronInfo()
end

return Team2V2Model