local MyRoomManager = class("MyRoomManager")

local MyRoomManagerException = import("src.app.plugins.mainpanel.room.MyRoomManagerException")
local FirstLayer = import("src.app.plugins.mainpanel.room.FirstLayer")
local SubTeamRoomManager = import("src.app.plugins.mainpanel.room.SubTeamRoomManager")
local SubTeam2V2RoomManager = import("src.app.plugins.mainpanel.room.SubTeam2V2RoomManager")
local SubArenaRoomManager = import("src.app.plugins.mainpanel.room.SubArenaRoomManager")

local PlayerModel = mymodel("hallext.PlayerModel"):getInstance()
local UserModel = mymodel('UserModel'):getInstance()
local ReliefActivity = mymodel('hallext.ReliefActivity'):getInstance()
local SettingsModel = mymodel("hallext.SettingsModel"):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
local WeakenScoreRoomModel = require('src.app.plugins.weakenscoreroom.WeakenScoreRoomModel'):getInstance()
local AdditionConfigModel = import('src.app.GameHall.config.AdditionConfigModel'):getInstance()
local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()

local Team2V2Model          = import('src.app.plugins.Team2V2Model.Team2V2Model'):getInstance()
local Team2V2ModelDef       = require('src.app.plugins.Team2V2Model.Team2V2ModelDef')

local coms = cc.load("coms")
local PropertyBinder = coms.PropertyBinder
local WidgetEventBinder = coms.WidgetEventBinder

my.setmethods(MyRoomManager, PropertyBinder)
my.setmethods(MyRoomManager, WidgetEventBinder)

MyRoomManager.areaViewConfig = {
    ["noshuffle"] = {   --不洗牌
        ["skeletonAni"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_noshuffle/buxipai.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_noshuffle/buxipai.atlas",
		    ["aniNames"] = {"buxipai"}
        },
        ["skeletonAniSpringFestival"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_noshuffle_springfestival/buxipai.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_noshuffle_springfestival/buxipai.atlas",
		    ["aniNames"] = {"buxipai"}
        },
        ["secondLayer"] = {
            ["name"] = "normal",
            ["csbPath"] = "res/hallcocosstudio/room/room_secondlayer.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerNormal"
        },
        ["roomBtn"] = {
            ["csbPath"] = "res/hallcocosstudio/room/roomnode_template.csb",
        }
    },

    ["classic"] = { --经典
        ["skeletonAni"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_classic/jingdian.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_classic/jingdian.atlas",
		    ["aniNames"] = {"jingdian"}
        },
        ["skeletonAniSpringFestival"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_classic_springfestival/jingdian.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_classic_springfestival/jingdian.atlas",
		    ["aniNames"] = {"jingdian"}
        },
        ["secondLayer"] = {
            ["name"] = "normal",
            ["csbPath"] = "res/hallcocosstudio/room/room_secondlayer.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerNormal"
        },
        ["roomBtn"] = {
            ["csbPath"] = "res/hallcocosstudio/room/roomnode_template.csb",
        }
    },

    ["arena"] = {   --竞技
        ["skeletonAni"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_arena/jingjichang.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_arena/jingjichang.atlas",
		    ["aniNames"] = {"jingjichang"}
        },
        ["skeletonAniSpringFestival"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_arena_springfestival/dingshisai_j.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_arena_springfestival/dingshisai_j.atlas",
		    ["aniNames"] = {"dingshisai_j"}
        },
        ["secondLayer"] = {
            ["name"] = "arena",
            ["csbPath"] = "res/hallcocosstudio/arena/second_layer_arena.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerArena"
        },
        ["roomBtn"] = {
            ["csbPath"] = "",
        }
    },
    
    ["joy"] = {     --娱乐
        ["skeletonAni"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_joy/yule.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_joy/yule.atlas",
		    ["aniNames"] = {"yule"}
        },
        ["skeletonAniSpringFestival"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_joy_springfestival/yuele.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_joy_springfestival/yuele.atlas",
		    ["aniNames"] = {"yuele"}
        },
        ["secondLayer"] = {
            ["name"] = "joy",
            ["csbPath"] = "res/hallcocosstudio/room/room_secondlayer_joy.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerJoy"
        }
    },    

    ["jisu"] = {    --急速血战
        ["skeletonAni"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_jisu/yule.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_jisu/yule.atlas",
		    ["aniNames"] = {"yule"}
        },
        ["skeletonAniSpringFestival"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_jisu_springfestival/xuezhanguandan.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_jisu_springfestival/xuezhanguandan.atlas",
		    ["aniNames"] = {"xuezhanguandan"}
        },
        ["secondLayer"] = {
            ["name"] = "normal",
            ["csbPath"] = "res/hallcocosstudio/room/room_secondlayer.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerNormal"
        },
        ["roomBtn"] = {
            ["csbPath"] = "res/hallcocosstudio/room/roomnode_template.csb",
        }
    },

    ["timingMiddle"] = {    --定时赛
        ["skeletonAni"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_timing/jingjichang.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_timing/jingjichang.atlas",
		    ["aniNames"] = {"jingjichang"}
        },
        ["skeletonAniSpringFestival"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_timing_springfestival/huafeisai.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_timing_springfestival/huafeisai.atlas",
		    ["aniNames"] = {"huafeisai_dz"}
        },
        ["skeletonAniTimingType"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_timing_dingshi/dingshisai_j.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_timing_dingshi/dingshisai_j.atlas",
		    ["aniNames"] = {"dingshisai_j"}
        },
        ["skeletonAniSpringFestivalTimingType"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_timing_springfestival_dingshi/dingshisai.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_timing_springfestival_dingshi/dingshisai.atlas",
		    ["aniNames"] = {"dingshisai_dz"}
        },
        ["secondLayer"] = {
            ["name"] = "timingMiddle",
            ["csbPath"] = "res/hallcocosstudio/room/room_secondlayer_timing_middle.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerTimingMiddle"
        }
    },

    ["anchorMatch"] = {     --主播娱乐
        ["skeletonAni"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_anchormatch/bisai_b.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_anchormatch/bisai_b.atlas",
		    ["aniNames"] = {"bisai_b"}
        },
        ["skeletonAniSpringFestival"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_anchormatch_springfestival/bisai_ji.json",
		    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_anchormatch_springfestival/bisai_ji.atlas",
		    ["aniNames"] = {"bisai_ji_dz"}
        },
        ["secondLayer"] = {
            ["name"] = "anchorMatch",
            ["csbPath"] = "res/hallcocosstudio/room/room_secondlayer_anchor_match.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerAnchorMatch"
        }
    },

    ["timing"] = {      --定时赛报名       
        ["secondLayer"] = {
            ["name"] = "timing",
            ["csbPath"] = "res/hallcocosstudio/TimingGame/TimingGameLayer.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerTiming"
        }
    },

    ["team"] = {
        ["secondLayer"] = {
            ["name"] = "team",
            ["csbPath"] = "res/hallcocosstudio/gamefriend/room_secondlayer_team.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerTeam"
        },
        ["roomBtn"] = {
            ["csbPath"] = "res/hallcocosstudio/gamefriend/roommodel2.csb",
        }
    },

    ["team2V2"] = {     --组队2V2房
        ["skeletonAni"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_team2v2/zudui.json",
            ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_team2v2/zudui.atlas",
            ["aniNames"] = {"zudui4"}
        },
        ["skeletonAniSpringFestival"] = {
            ["jsonPath"] = "res/hallcocosstudio/images/skeleton/area_team2v2/zudui.json",
            ["atlasPath"] = "res/hallcocosstudio/images/skeleton/area_team2v2/zudui.atlas",
            ["aniNames"] = {"zudui4"}
        },
        ["secondLayer"] = {
            ["name"] = "team2V2",
            ["csbPath"] = "res/hallcocosstudio/room/room_secondlayer_team2v2.csb",
            ["classPath"] = "src.app.plugins.mainpanel.room.SecondLayerTeam2V2"
        }
    },

    ["areaEntries"] = {"noshuffle", "classic", "arena", "joy", "jisu", "timingMiddle", "anchorMatch", "timing", "team", "team2V2"}
}

MyRoomManager.roomModelConfig = {
    ["normal"] = "src.app.GameHall.room.model.NormalRoomModel",
    ["team"] = "src.app.GameHall.room.model.TeamRoomModel",
    ["anchorMatch"] = "src.app.GameHall.room.model.XuanZhuoRoomModel",
    ["team2V2"] = "src.app.GameHall.room.model.Team2V2RoomModel",
}

function MyRoomManager:ctor(mainCtrl)
    self._mainCtrl = mainCtrl
    self.roomManagerException = MyRoomManagerException:create(self)
    self.firstLayer = nil
    self.subTeamRoomManager = SubTeamRoomManager:create(self)           --将好友房的大部分逻辑集中到SubTeamRoomManager，防止MyRoomManager过大
    self.subTeam2V2RoomManager = SubTeam2V2RoomManager:create(self)     --将好友房的大部分逻辑集中到SubTeamRoomManager，防止MyRoomManager过大
    self.subArenaRoomManager = SubArenaRoomManager:create(self)

    self._roomStrings = HallContext.context["roomStrings"]

    self._roomContext = {
        ["secondLayer"] = nil,
        ["secondLayerNode"] = nil,

        ["isEnteringRoom"] = false,
        ["lastEnterRoom_BeginTime"] = -1,
        ["enterRoomCallback"] = nil
    }
    self._roomContextOut = HallContext.context["roomContext"] --导出的上下文，提供外部访问

    cc.exports.XXXXXXX = self._roomContextOut

    self:addTeam2V2EventListeners()
end

function MyRoomManager:addTeam2V2EventListeners()
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUERY_CONFIG_RSP, handler(self, self.onQueryConfigRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_CREATE_TEAM_RSP, handler(self, self.onCreateTeamRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUIT_TEAM_RSP, handler(self, self.onQuitTeamRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_CANCEL_TEAM_RSP, handler(self, self.onCancelTeamRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_QUERY_TEAM_RSP, handler(self, self.onQueryTeamRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_JOIN_TEAM_RSP, handler(self, self.onJoinTeamRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_KICK_TEAM_RSP, handler(self, self.onKickTeamRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_DO_READY_RSP, handler(self, self.onReadyOKRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_CANCEL_READY_RSP, handler(self, self.onCancelReadyRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_CHANGE_ROOM_RSP, handler(self, self.onChangeRoomRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_SYNCHRON_INFO_RSP, handler(self, self.onSyncInfoRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_START_MATCH_RSP, handler(self, self.onStartMatchRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_MATCH_FAIL_RSP, handler(self, self.onMatchFailRsp))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_SYNCHRON_REAL_TEAM_RSP, handler(self, self.onSyncRealTeam))
    self:listenTo(Team2V2Model, Team2V2ModelDef.GR_TEAM_2V2_MODEL_OVER_TIME_CANCEL_TEAM_RSP, handler(self, self.onOverTimeCancelTeam))
end

function MyRoomManager:getSecondLayerTeam2V2()
    local secondLayer = self:getSecondLayer()
    if secondLayer and secondLayer.layerName == 'team2V2' then
        return secondLayer
    end
    return nil
end

function MyRoomManager:enterSecondLayerTeam2V2()
    local secondLayer = self:getSecondLayer()

    while secondLayer and secondLayer.layerName ~= 'team2V2' do
        self:closeSecondeLayer(true)
        secondLayer = self:getSecondLayer()
    end

    if not secondLayer then
        my.closeLayerPlugins()
        self:_createAndShowSecondLayer('team2V2', nil)
    end
end

function MyRoomManager:closeSecondLayerTeam2V2()
    local secondLayer = self:getSecondLayer()
    if secondLayer and secondLayer.layerName == 'team2V2' then
        self:closeSecondeLayer(true)
    end
end

function MyRoomManager:onQueryConfigRsp(data)
    local secondLayer = self:getSecondLayerTeam2V2()
    if secondLayer then
        secondLayer:onQueryConfigRsp(data)
    end
end

function MyRoomManager:onCreateTeamRsp(data)
    if not data or not data.value then
        return
    end

    local secondLayer = self:getSecondLayerTeam2V2()
    if secondLayer then
        secondLayer:refreshTeamInfo()
        secondLayer:refreshAllRoomBtnInfo()
    else
        self:enterSecondLayerTeam2V2()
        my.stopLoading()
    end
end

function MyRoomManager:onCancelTeamRsp(data)
    
end

function MyRoomManager:onQueryTeamRsp(data)
    if not data or not data.value then
        return
    end

    local result = data.value.queryResult
    if data.value.queryResult ~= Team2V2ModelDef.QUERY_TEAM_RESULT.FIND_TEAM  then
        return
    end

    self:enterSecondLayerTeam2V2()
end

function MyRoomManager:onQuitTeamRsp(data)
    if not data or not data.value then
        return
    end

    local result = data.value.quitResult
    if result == Team2V2ModelDef.QUIT_TEAM_RESULT.QUIT_TEAM_NULL 
    or result == Team2V2ModelDef.QUIT_TEAM_RESULT.NOT_IN_TEAM then
        self:closeSecondLayerTeam2V2()
        return
    end

    local quitUserID = data.value.userID
    local oldTeamInfo = data.value.oldTeamInfo

    if quitUserID == UserModel.nUserID then
        -- 自己退出
        local needJoinNew, joinLeader = Team2V2Model:needJoinNewTeam()
        if needJoinNew then
            Team2V2Model:setNeedJoinNewTeam(false, nil)
            if joinLeader then
                Team2V2Model:reqJoinTeam(joinLeader)
            else
                Team2V2Model:reqCreateTeam()
            end
        else
            self:closeSecondLayerTeam2V2()
        end
    else
        local secondLayer = self:getSecondLayerTeam2V2()
        if secondLayer then
            if quitUserID == oldTeamInfo.leaderUserID then
                -- 队长退出
                my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '当前队伍已解散！', removeTime = 2}})
            elseif quitUserID == oldTeamInfo.mateUserID then
                -- 队友退出
                my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = oldTeamInfo.mateUserName..'退出队伍！', removeTime = 2}})
            end
    
            secondLayer:refreshTeamInfo()
            secondLayer:refreshAllRoomBtnInfo()
        end
    end
end

function MyRoomManager:onJoinTeamRsp(data)
    if not data or not data.value then
        return
    end

    local result = data.value.joinResult
    
    if result == Team2V2ModelDef.JOIN_TEAM_RESULT.TEAM_IS_NULL
    or result == Team2V2ModelDef.JOIN_TEAM_RESULT.LEADER_IN_OTHER_TEAM 
    or result == Team2V2ModelDef.JOIN_TEAM_RESULT.TEAM_INFO_IS_NULLthen then
 
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '队伍已解散！', removeTime = 2}})
        if not my.isInGame() then
            -- 队伍已解散，且不在游戏中，这自己创建队伍
            Team2V2Model:reqCreateTeam()
        end
    elseif result == Team2V2ModelDef.JOIN_TEAM_RESULT.TEAM_IS_ABNORMAL then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '队伍为空！', removeTime = 2}})
    elseif result == Team2V2ModelDef.JOIN_TEAM_RESULT.TEAM_IS_FULL then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '队伍已满！', removeTime = 2}})
        if not my.isInGame() then
            -- 队伍已满，且不在游戏中，这自己创建队伍
            Team2V2Model:reqCreateTeam()
        end
    elseif result == Team2V2ModelDef.JOIN_TEAM_RESULT.JOIN_NEW_TEAM 
        or result == Team2V2ModelDef.JOIN_TEAM_RESULT.IN_OTHER_TEAM
        or result == Team2V2ModelDef.JOIN_TEAM_RESULT.BACK_TO_TEAM then

        local joinUserID = data.value.userID
        local teamInfo = data.value.teamInfo

        if result == Team2V2ModelDef.JOIN_TEAM_RESULT.JOIN_NEW_TEAM  then
            if UserModel.nUserID == joinUserID then
                my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '加入队伍成功！', removeTime = 2}})
            else
                my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = teamInfo.mateUserName .. '加入队伍！', removeTime = 2}})
            end
        end
        
        self:enterSecondLayerTeam2V2()

        local secondLayer = self:getSecondLayerTeam2V2()
        if secondLayer then
            secondLayer:onJoinTeamRsp(data)
        end
    end
end

function MyRoomManager:onKickTeamRsp(data)
    if not data or not data.value then
        return
    end

    local result = data.value.kickResult
    if result == Team2V2ModelDef.KICK_TEAM_RESULT.KICK_TEAM_NOT_EXIST
        or result == Team2V2ModelDef.KICK_TEAM_RESULT.KICK_TEAM_NULL then
        self:closeSecondLayerTeam2V2()
    elseif result == Team2V2ModelDef.KICK_TEAM_RESULT.KICK_PLAYER_NO_LEADER then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '只有队长才能踢人哦！', removeTime = 2}})
    elseif result == Team2V2ModelDef.KICK_TEAM_RESULT.TEAM_NO_KICKED then
        local secondLayer = self:getSecondLayerTeam2V2()
        if secondLayer then
            secondLayer:refreshTeamInfo()
            secondLayer:refreshAllRoomBtnInfo()
        end
    elseif result == Team2V2ModelDef.KICK_TEAM_RESULT.KICK_TEAM_OK then
        if data.value.kickuserID == UserModel.nUserID then
            my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '已被队长踢出！', removeTime = 2}})
            Team2V2Model:reqCreateTeam()
        else
            local secondLayer = self:getSecondLayerTeam2V2()
            if secondLayer then
                secondLayer:refreshTeamInfo()
                secondLayer:refreshAllRoomBtnInfo()
            end
        end
    end
end

function MyRoomManager:onReadyOKRsp(data)
    if not data or not data.value then
        return
    end

    local result = data.value.readyResult
    if result == Team2V2ModelDef.DO_READY_RESULT.READY_TEAM_NOT_EXIST
        or result == Team2V2ModelDef.DO_READY_RESULT.READY_TEAM_NULL then
        self:closeSecondLayerTeam2V2()
    elseif result == Team2V2ModelDef.DO_READY_RESULT.READY_TEAM_OK
        or result == Team2V2ModelDef.DO_READY_RESULT.READY_OK_AGAIN then

        local secondLayer = self:getSecondLayerTeam2V2()
        if secondLayer then
            secondLayer:onReadyOKRsp(data)
        end
    end
end

function MyRoomManager:onCancelReadyRsp(data)
    if not data or not data.value then
        return
    end

    local result = data.value.cancelResult
    if result == Team2V2ModelDef.DO_CANCEL_READY_RESULT.CANCEL_READY_TEAM_NOT_EXIST
    or result == Team2V2ModelDef.DO_CANCEL_READY_RESULT.CANCEL_READY_TEAM_NULL then
        self:closeSecondLayerTeam2V2()
    elseif result == Team2V2ModelDef.DO_CANCEL_READY_RESULT.CANCEL_READY_TEAM_OK
        or result == Team2V2ModelDef.DO_CANCEL_READY_RESULT.CANCEL_READY_AGAIN then

        local secondLayer = self:getSecondLayerTeam2V2()
        if secondLayer then
            secondLayer:onCancelReadyRsp(data)
        end
    end
end

function MyRoomManager:onChangeRoomRsp(data)
    
end

function MyRoomManager:onSyncInfoRsp(data)
    if not data or not data.value then
        return
    end

    local result = data.value.synchronResult
    if result == Team2V2ModelDef.SYNCHRON_INFO_RESULT.SYNCHRON_TEAM_NOT_EXIST
    or result == Team2V2ModelDef.SYNCHRON_INFO_RESULT.SYNCHRON_TEAM_NULL then
        self:closeSecondLayerTeam2V2()
    elseif result == Team2V2ModelDef.SYNCHRON_INFO_RESULT.SYNCHRON_INFO_OK then

        local secondLayer = self:getSecondLayerTeam2V2()
        if secondLayer then
            secondLayer:onSyncInfoRsp(data)
        end
    end
end

function MyRoomManager:onStartMatchRsp(data)
    
end

function MyRoomManager:onMatchFailRsp(data)
    if not data or not data.value then
        return
    end

    local result = data.value.matchFailResult
    if result == Team2V2ModelDef.MATCH_FAIL_RESULT.MATCH_FAIL_NEED_SYNCHRON then
        local secondLayer = self:getSecondLayerTeam2V2()
        if secondLayer then
            secondLayer:onMatchFailRsp(data)
        end
    else
        self:closeSecondLayerTeam2V2()
    end
end

function MyRoomManager:onSyncRealTeam(data)
    if not data or not data.value then
        return
    end

    local result = data.value.synchronResult
    if result == Team2V2ModelDef.SYNCHRON_INFO_RESULT.SYNCHRON_TEAM_NOT_EXIST
    or result == Team2V2ModelDef.SYNCHRON_INFO_RESULT.SYNCHRON_TEAM_NULL then
        self:closeSecondLayerTeam2V2()
    elseif result == Team2V2ModelDef.SYNCHRON_INFO_RESULT.SYNCHRON_INFO_OK then
        local secondLayer = self:getSecondLayerTeam2V2()
        if secondLayer then
            if UserModel.nUserID == data.value.teamInfo.mateUserID then
                self.subTeam2V2RoomManager:onLeaderStartMatch()
            end
        end
    end
end

function MyRoomManager:onOverTimeCancelTeam(data)
    
end


function MyRoomManager:initView(viewNode)
    self.firstLayer = FirstLayer:create(self)
    self.firstLayer:initView(viewNode)
end

function MyRoomManager:refreshView()
    if self.firstLayer then
        self.firstLayer:refreshView()
    end
    --[[if self._roomContext["secondLayer"] then
        self._roomContext["secondLayer"]:refreshView()
    end]]--
end

function MyRoomManager:refreshViewOnDepositChange()
    if self.firstLayer then
        self.firstLayer:refreshViewOnDepositChange()
    end
    if self._roomContext["secondLayer"] then
        self._roomContext["secondLayer"]:refreshViewOnDepositChange()
    end
end

function MyRoomManager:refreshViewOnTimingGameRecvInfo()
    if self.firstLayer and self.firstLayer.refreshConfigDesc then
        self.firstLayer:refreshConfigDesc()
    end
    if self._roomContext["secondLayer"] and self._roomContext["secondLayer"].refreshTickets then
        self._roomContext["secondLayer"]:refreshTickets()
    end
end

function MyRoomManager:refreshViewOnTimingGameRecvConfig()
    if self.firstLayer and self.firstLayer.refreshConfigDesc then
        self.firstLayer:refreshConfigDesc()
    end
    if self._roomContext["secondLayer"] and self._roomContext["secondLayer"].refreshConfigDesc then
        self._roomContext["secondLayer"]:refreshConfigDesc()
    end
end

--normalSecondLayer指不洗牌和经典两种模式
function MyRoomManager:getNormalSecondLayer()
    local secondLayer = self._roomContext["secondLayer"]
    if secondLayer then
        if secondLayer.layerName == "classic" or secondLayer.layerName == "noshuffle" or secondLayer.layerName == "jisu" then
            return secondLayer
        end
    end

    return nil
end

function MyRoomManager:getSecondLayer()
    return self._roomContext["secondLayer"]
end

function MyRoomManager:onNetProcessFinished()
    --self.subTeamRoomManager:checkLauchParams()
    --self:checkRoomList()
end

function MyRoomManager:onGetDXXWInfo(eventData)
    if eventData == nil then return end
    local roomID = eventData.value["roomId"]
    local tableID = eventData.value["tableNo"]

    if my.isInGame() then return end

    my.informPluginByName({pluginName = "SureDialog", params = {
        tipContent = self._roomStrings['GAMEON_DXXW_PLZ'],
        tipTitle = nil,
        okBtTitle = nil,
        onOk = function()
            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.HALL_BACK_TO_GAME)

            --aaaa此处需要确认，断线续玩是进入普通场、竞技场、还是好友房
            local roomInfo = RoomListModel.roomsInfo[roomID]
            if roomInfo == nil then
                printf("onGetDXXWInfo, target roominfo is nil, roomID %s, tableNo %s", tostring(roomID), tostring(tableID))
                return
            end
            self._roomContextOut["areaEntry"] = "classic"
            if roomInfo["isNoShuffleRoom"] == true or roomInfo["isGuideRoom"] == true then
                self._roomContextOut["areaEntry"] = "noshuffle"
            end
            if roomInfo["isJiSuRoom"] == true then
                self._roomContextOut["areaEntry"] = "jisu"
            end
            if roomInfo["isTimingRoom"] == true then
                self._roomContextOut["areaEntry"] = "timing"
            end
            if roomInfo["isAnchorMatch"] == true then
                self._roomContextOut["areaEntry"] = "anchorMatch"
            end
            if roomInfo["isTeam2V2"] == true then
                self._roomContextOut["areaEntry"] = "team2V2"
            end
            self:tryEnterRoom(roomID, true, nil)
        end,
        closeBtVisible = false,
        forbidKeyBack = true
    }})
end

function MyRoomManager:onClickAreaBtn(areaEntry, callback)
    print("MyRoomManager:onClickAreaBtn")
    my.playClickBtnSound()
    if areaEntry == "joy" then
        --娱乐场不检查登陆状态，因为要提供单机场入口
    else
        if not CenterCtrl:checkNetStatus() then return end
    end
    if not UIHelper:checkOpeCycle("MyRoomManager_onClickAreaBtn") then
        return
    end
    UIHelper:refreshOpeBegin("MyRoomManager_onClickAreaBtn")

    if RoomListModel:checkAreaEntryAvail(areaEntry) == false then
        print("checkAreaEntryAvail false, areaEntry "..tostring(areaEntry))
        local boutNum = cc.exports.getNewUserGuideBoutCount()
        local strTip = string.format(self._roomStrings["NEW_PLAYER_LOCK_TIPS"], boutNum )
        self:_showTip(strTip)
        return
    end

    local NewUserGuideModel = mymodel('NewUserGuideModel'):getInstance()
    if NewUserGuideModel:isNeedGuide() then
        self._roomContextOut["areaEntry"] = 'noshuffle'

        local guideRoom = RoomListModel:getNewUserGuideRoom()
        if guideRoom then
            self:tryEnterRoom(guideRoom.nRoomID, false, nil)
            return
        end
    end

    if areaEntry == 'team2V2' then
        my.startLoading()
        Team2V2Model:reqCreateTeam()
    elseif areaEntry == "arena" then
        --竞技场的点击频率限制加大一些
        if not UIHelper:checkOpeCycle("MyRoomManager_onClickAreaBtn_Arena", 1.1) then
            return
        end
        UIHelper:refreshOpeBegin("MyRoomManager_onClickAreaBtn_Arena")
        self.subArenaRoomManager:getArenaData(callback) --成功拿到竞技场数据（配置和用户比赛数据），才显示竞技场界面
    else
        self:_createAndShowSecondLayer(areaEntry, callback)
    end

    if areaEntry == "classic" or areaEntry == "noshuffle" then
        --self:_checkAndUpdateDoubleExchangeConfig()
    end
end

--1小时没更新，则重新请求一次
function MyRoomManager:_checkAndUpdateDoubleExchangeConfig()
    local doubleExchangeConfig = CommonData:getAppData("DoubleExchangeConfig")
    if doubleExchangeConfig == nil then return end
    if doubleExchangeConfig["lastUpdateTime"] == nil then return end

    local timeElapsed = os.time() - doubleExchangeConfig["lastUpdateTime"]
    if timeElapsed > 3600 then
        local AssistCommon = require('src.app.GameHall.models.assist.common.AssistCommon'):getInstance()
        --AssistCommon:JR_RequestModuleConfigDefinedByServer({"DoubleExchange"})
    end
end

function MyRoomManager:_createAndShowSecondLayer(areaEntry, callback)
    print("MyRoomManager:_createAndShowSecondLayer")
    -- if self._roomContext["secondLayer"] ~= nil then
    --     print("secondLayer already exist!!!")
    --     return
    -- end
    if self._roomContext["areaEntry"] == areaEntry then
        print("secondLayer areaEntry same!!!")
        return
    end

    local isCreated, layerNode = self:_createRoomSecondLayer(self._mainCtrl._viewNode, areaEntry)
    if layerNode == nil then return end

    if type(callback) == "function" then callback() end

    if SpringFestivalModel:showSpringFestivalView() then
        layerNode:getChildByName("Img_BG"):setVisible(false)
        layerNode:getChildByName("Img_BG_1"):setVisible(true)
    else
        layerNode:getChildByName("Img_BG"):setVisible(true)
        layerNode:getChildByName("Img_BG_1"):setVisible(false)
    end

    local secondLayer = import(MyRoomManager.areaViewConfig[areaEntry]["secondLayer"]["classPath"]):create(layerNode, self)
    self._roomContext["secondLayer"] = secondLayer
    self._roomContextOut["areaEntry"] = areaEntry
    self._roomContext["secondLayerNode"] = layerNode

    if isCreated == true then secondLayer:initView() end
    secondLayer:refreshView()

    if secondLayer.runEnterAni then
        secondLayer:runEnterAni()
    end

    if self._MyLogonSuccessStatus == false then -- 断线重连回来的一次需要立马刷新人数
        RoomListModel:_updataRoomPlayerNum()
        self._MyLogonSuccessStatus = true
    end
end

function MyRoomManager:closeSecondeLayer(isLeaveRoom)
    local isSecondLayerExistAndClosed = false
    if self._roomContext["secondLayer"] then
        self._roomContext["secondLayer"]:dealOnClose()
        isSecondLayerExistAndClosed = true
    end
    if self._roomContext["secondLayerNode"] then 
        self._roomContext["secondLayerNode"]:removeFromParent()
        isSecondLayerExistAndClosed = true
    end
    self._roomContext["secondLayerNode"] = nil
    self._roomContext["secondLayer"] = nil

    --关闭二级界面，退回一级界面的时候，将areaEntry置空
    self._roomContextOut["areaEntry"] = nil

    if isLeaveRoom == true then
        print("MyRoomManager:closeSecondeLayer and doLeaveCurrentRoom")
        self:doLeaveCurrentRoom()
    end

    if self._roomContextOut["middleAreaEntry"]
    and self._roomContextOut["middleAreaEntry"] ~= "timing" then
        print("show middleAraEntry ", self._roomContextOut["middleAreaEntry"])
        self:_createAndShowSecondLayer(self._roomContextOut["middleAreaEntry"])
        self._roomContextOut["middleAreaEntry"] = nil
    end

    if isSecondLayerExistAndClosed then
        self._mainCtrl._view:runEnterAni(self._mainCtrl._viewNode)
    end
end

function MyRoomManager:clearSecondeLayerData()
    self._roomContextOut["middleAreaEntry"] = "timingMiddle"
end

function MyRoomManager:clearSecondeLayerDataAnchor()
    self._roomContextOut["middleAreaEntry"] = "anchorMatch"
end

function MyRoomManager:_createRoomSecondLayer(viewNode, areaEntry)
    if viewNode == nil then return end

    local layerConfig = MyRoomManager.areaViewConfig[areaEntry]["secondLayer"]
    if layerConfig == nil then return end

    local existedNode = nil
    local layerNodeName = "roomSecondLayer_"..layerConfig["name"]
    local areaEntries = MyRoomManager.areaViewConfig["areaEntries"]
    for i = 1, #areaEntries do
        local nodeName = "roomSecondLayer_"..areaEntries[i]
        local nodeLayer = viewNode:getChildByName(nodeName)
        if nodeName ~= layerNodeName then
            if nodeLayer ~= nil then
                nodeLayer:removeFromParent()
            end
        else
            existedNode = nodeLayer
        end
    end

    if existedNode == nil then
        local layerNode = cc.CSLoader:createNode(layerConfig["csbPath"])
        layerNode:setName(layerNodeName)
        viewNode:addChild(layerNode)
        layerNode:setContentSize(display.size)
        my.presetAllButton(layerNode)
        ccui.Helper:doLayout(layerNode)

        return true, layerNode
    end

    return false, existedNode
end

function MyRoomManager:tryEnterRoom(roomId, isDXXW, callbackOnEnterRoomSuccess)

    if not isDXXW then
        local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        if not NobilityPrivilegeModel:isRoomEnableEnterByNPLevel(roomId) then
            local roomNPLevel = NobilityPrivilegeModel:getRoomNPLevelLimit(roomId)
            local tipString = "当前房间需要贵族" .. tostring(roomNPLevel) .. "才能进入"
            my.informPluginByName({ pluginName = 'ChooseDialog', params = {tipContent = tipString }})
            return
        end
    end

    if cc.exports.isHideJuniorRoomSupported() and toint(cc.exports.getMergeHideJuniorRoomID()) == toint(roomId) then
        if isDXXW == true then
            roomId = roomId
        else
            local hideJuniorRoomID = cc.exports.getHideJuniorRoomID()
            local mergeHideJuniorRoomID = roomId
            local userCountLimit = cc.exports.getUserCountLimit()
            local hideJuniorRoomCount = RoomListModel.roomsInfo[hideJuniorRoomID]["nUsers"]
            local hideMergeJuniorRoomCount = RoomListModel.roomsInfo[mergeHideJuniorRoomID]["nUsers"]
            --获取到的数据都要为number
            if (hideMergeJuniorRoomCount and hideJuniorRoomCount and type(hideJuniorRoomCount) == "number" and type(hideMergeJuniorRoomCount) == "number") then
                hideMergeJuniorRoomCount = hideMergeJuniorRoomCount - hideJuniorRoomCount
                if hideMergeJuniorRoomCount > userCountLimit then
                    if hideJuniorRoomCount < userCountLimit then
                        roomId = hideJuniorRoomID
                    else
                        if hideJuniorRoomCount < hideMergeJuniorRoomCount then
                            roomId = hideJuniorRoomID
                        end
                    end
                end
            end
        end
    end
    UIHelper:beginRuntime("EnterGameScene", "MyRoomManager:tryEnterRoom")
    print("MyRoomManager:tryEnterRoom, roomId "..tostring(roomId))
    local roomInfo = RoomListModel.roomsInfo[roomId]
    if roomInfo == nil then
        print("tryEnterNormalRoom, but roomInfo is nil!!!")
        return false
    end
    if self:_isDoingEnterRoom() == true then
        print("one enteringroom already existed!!!")
        return false
    end

    self:doLeaveCurrentRoom() --先重置已存在的连接

    local curAreaEntry = self._roomContextOut["areaEntry"]
    self._roomContext["enterRoomCallback"] = callbackOnEnterRoomSuccess
    self._roomContext["isEnteringRoom"] = true
    self._roomContext["lastEnterRoom_BeginTime"] = os.time()
    if curAreaEntry == "team2V2" and roomInfo["isTeam2V2"] == true then
        my.startProcessing()
        self.subTeam2V2RoomManager:tryEnterTeam2V2Room(roomInfo, isDXXW)
    elseif curAreaEntry == "team" and roomInfo["isTeamRoom"] == true then
        my.startProcessing()
        self.subTeamRoomManager:tryEnterTeamRoom(roomInfo, isDXXW)
    elseif self:_getRoomMNGType(roomId) == RoomListModel.dwManages.ROOM_MNG_SELECTTABLE then
        --my.startLoading()
        self:_tryEnterAnchorRoom(roomInfo, isDXXW)
    else
        my.startLoading()
        self:_tryEnterNormalRoom(roomInfo, isDXXW)
    end
end

-- 移动端选桌：begin
-- 当前房间是否是选桌房间
function MyRoomManager:isCurrentXuanZhuoRoom()
    if self._roomContextOut["roomModel"] and self._roomContextOut["roomModel"].isCurrentXuanZhuoRoom then
        return self._roomContextOut["roomModel"]:isCurrentXuanZhuoRoom()
    end

    return false
end

-- roomID是否是选桌房间
function MyRoomManager:isXuanZhuoRoom(roomID)
    if roomID then
        local nodeMNGType = self:_getRoomMNGType(roomID)
        return (nodeMNGType == RoomListModel.dwManages.ROOM_MNG_SELECTTABLE)
    else
        return false
    end
end

-- 获取房间的选桌属性
function MyRoomManager:_getRoomMNGType(roomID)
    printLog("RoomManager", "_isSecletTableRoom")
    local roomInfo = RoomListModel.roomsInfo[roomID]
    if not roomInfo then
        return false
    end
    return bit.band(roomInfo.dwManages, RoomListModel.dwManages.ROOM_MNG_SELECTTABLE)
end
-- 移动端选桌：begin

function MyRoomManager:_isDoingEnterRoom()
    if self._roomContext["isEnteringRoom"] == true then
        local timeElapsed = os.time() - self._roomContext["lastEnterRoom_BeginTime"]
        if timeElapsed > 0 and timeElapsed < 5 then
            return false
        else
            return true
        end
    end
    return false
end

function MyRoomManager:_createRoomModel(roomInfo, roomModelName)
    local modelClassPath = MyRoomManager.roomModelConfig[roomModelName]
    self._roomContextOut["roomModel"] = import(modelClassPath):create(roomInfo, roomModelName)
    if self._roomContextOut["roomModel"] and self._roomContextOut["roomModel"].setMyRoomManager then
        self._roomContextOut["roomModel"]:setMyRoomManager(self)
    end

    self:addRoomEventListeners()
    self.subTeamRoomManager:addRoomEventListeners()
    -- self.subTeam2V2RoomManager:addRoomEventListeners()
end

function MyRoomManager:addRoomEventListeners()
    local roomModel = self._roomContextOut["roomModel"]
    if roomModel then
        self._mainCtrl:listenTo(roomModel, roomModel.EVENT_MAP["baseRoomModel_roomSocketError"], handler(self, self.onSocketError))
    end
end

function MyRoomManager:_tryEnterNormalRoom(roomInfo, isDXXW)
    UIHelper:recordRuntime("EnterGameScene", "MyRoomManager:_tryEnterNormalRoom")
    self:_createRoomModel(roomInfo, "normal")
	self._roomContextOut["roomModel"]:enterRoom(function(isEntered, respondType, enterRoom_dataMap, newTable_dataMap)
		if isEntered == "succeeded" then
            UIHelper:recordRuntime("EnterGameScene", "MyRoomManager enterRoom success")
            self._roomContextOut["roomInfo"] = roomInfo
            self._roomContextOut["enterRoomOk"] = enterRoom_dataMap[1]
            self._roomContextOut["tableInfo"] = newTable_dataMap

            if not self._roomContextOut["areaEntry"] then
                if roomInfo["isNoShuffleRoom"] == true or roomInfo["isGuideRoom"] == true then
                    self._roomContextOut["areaEntry"] = "noshuffle"
                elseif roomInfo["isJiSuRoom"] == true then
                    self._roomContextOut["areaEntry"] = "jisu"
                elseif roomInfo["isClassicRoom"] == true then
                    self._roomContextOut["areaEntry"] = "classic"
                elseif roomInfo["isScoreRoom"] == true then
                    self._roomContextOut["areaEntry"] = "joy"
                elseif roomInfo["isOfflineRoom"] == true then
                    self._roomContextOut["areaEntry"] = "joy"
                elseif roomInfo["isTimingRoom"] == true then
                    self._roomContextOut["areaEntry"] = "timing"
                elseif roomInfo["isAnchorMatch"] == true then
                    self._roomContextOut["areaEntry"] = "anchorMatch"
                elseif roomInfo["isTeam2V2"] == true then
                    self._roomContextOut["areaEntry"] = "team2V2"
                end
            end
            --老游戏模板需要这个
            table.merge(UserModel, enterRoom_dataMap[2])
            UserModel["nRoomID"] = roomInfo["nRoomID"]
            UserModel["szHardID"]= require("src.app.GameHall.models.DeviceModel"):getInstance().szHardID

			self:_onEnterRoomSucceeded()
			self:_tryEnterGame()

            local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
            NewInviteGiftModel:reqConfig()

            local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
            OldUserInviteGiftModel:sendInviteGiftData()
        elseif isEntered == "failed" then
            if cc.exports.jumpHighRoom == true then
                my.informPluginByName({params={message='remove'}})
            end
            
			my.stopLoading()
            self.roomManagerException:onEnterRoomFailed(respondType, enterRoom_dataMap, roomInfo["nRoomID"])
		end

        self._roomContext["isEnteringRoom"] = false
	end, isDXXW, self:isStartGameAs("arena", roomInfo))
end

-- 移动端选桌：begin
function MyRoomManager:_tryEnterAnchorRoom(roomInfo, isDXXW)
    UIHelper:recordRuntime("EnterGameScene", "MyRoomManager:_tryEnterAnchorRoom")
    self:_createRoomModel(roomInfo, "anchorMatch")
	self._roomContextOut["roomModel"]:enterRoom(function(isEntered, respondType, enterRoom_dataMap, newTable_dataMap)
		if isEntered == "succeeded" then
            UIHelper:recordRuntime("EnterGameScene", "MyRoomManager enterRoom success")
            self._roomContextOut["roomInfo"] = roomInfo
            self._roomContextOut["enterRoomOk"] = enterRoom_dataMap[1]
            self._roomContextOut["tableInfo"] = newTable_dataMap

            if not self._roomContextOut["areaEntry"] then
                if roomInfo["isNoShuffleRoom"] == true then
                    self._roomContextOut["areaEntry"] = "noshuffle"
                elseif roomInfo["isJiSuRoom"] == true then
                    self._roomContextOut["areaEntry"] = "jisu"
                elseif roomInfo["isClassicRoom"] == true then
                    self._roomContextOut["areaEntry"] = "classic"
                elseif roomInfo["isScoreRoom"] == true then
                    self._roomContextOut["areaEntry"] = "joy"
                elseif roomInfo["isOfflineRoom"] == true then
                    self._roomContextOut["areaEntry"] = "joy"
                elseif roomInfo["isTimingRoom"] == true then
                    self._roomContextOut["areaEntry"] = "timing"
                elseif roomInfo["isAnchorMatch"] == true then
                    self._roomContextOut["areaEntry"] = "anchorMatch"
                elseif roomInfo["isTeam2V2"] == true then
                    self._roomContextOut["areaEntry"] = "team2V2"
                end
            end
            --老游戏模板需要这个
            table.merge(UserModel, enterRoom_dataMap[2])
            UserModel["nRoomID"] = roomInfo["nRoomID"]
            UserModel["szHardID"]= require("src.app.GameHall.models.DeviceModel"):getInstance().szHardID

			self:_onEnterRoomSucceeded()
            if newTable_dataMap then -- 玩家已经上桌了
                self:xz_enterGame()
            end
            self:xz_showTables(enterRoom_dataMap[1],enterRoom_dataMap[2],enterRoom_dataMap[3])
        elseif isEntered == "failed" then
			my.stopLoading()
            self.roomManagerException:onEnterRoomFailed(respondType, enterRoom_dataMap, roomInfo["nRoomID"])
		end

        self._roomContext["isEnteringRoom"] = false
	end, isDXXW, self:isStartGameAs("arena", roomInfo))
end

-- add by zjh 进入房间成功，显示桌子和玩家列表界面
function MyRoomManager:xz_showTables(enterRoomOk,players,tables)
    local anchorTableModel = require("src.app.plugins.AnchorTable.AnchorTableModel"):getInstance()
    anchorTableModel:setData({roomInfo=RoomListModel:getAnchorRoomInfo(), players=players, tables=tables})
end

function MyRoomManager:xz_enterGame()
    self:_tryEnterGame()    

    my.scheduleOnce(function()
        local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
        NewInviteGiftModel:reqConfig()

        local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
        OldUserInviteGiftModel:sendInviteGiftData()
    end, 1.0)
end
-- 移动端选桌：end

function MyRoomManager:isStartGameAs(areaEntry, roomInfo)
    if self._roomContextOut["areaEntry"] ~= areaEntry then
        return false
    end

    if areaEntry == "arena" then
        if roomInfo and roomInfo["isArenaRoom"] == true then
            return true
        end
    elseif areaEntry == "team" then
        if roomInfo and roomInfo["isTeamRoom"] == true then
            return true
        end
    elseif areaEntry == "team2V2" then
        if roomInfo and roomInfo["isTeam2V2"] == true then
            return true
        end
    elseif areaEntry == "noshuffle" then
        if roomInfo and roomInfo["isNoShuffleRoom"] == true then
            return true
        end
    elseif areaEntry == "jisu" then
        if roomInfo and roomInfo["isJiSuRoom"] == true then
            return true
        end
    elseif areaEntry == "classic" then
        if roomInfo and roomInfo["isClassicRoom"] == true then
            return true
        end
    elseif areaEntry == "joy" then
        if roomInfo and roomInfo["isScoreRoom"] == true then
            return true
        elseif roomInfo and roomInfo["isOfflineRoom"] == true then
            return true
        end
    end

    return false
end

function MyRoomManager:_tryEnterGame()
    UIHelper:recordRuntime("EnterGameScene", "MyRoomManager:_tryEnterGame")
    cc.exports.TimerManager:scheduleOnceUnique("Timer_DoEnterGame", function()
        cc.exports.isInHall = false
        --cc.exports.isShowLoadingPanel = true
        self._roomContextOut["isEnteredGameScene"] = true
        UIHelper:recordRuntime("EnterGameScene", "MyRoomManager informPluginByName QuickStartCtrl")
        if cc.exports.jumpHighRoom == true then
            if cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
                cc.exports.GamePublicInterface._gameController._baseGameScene:OnJumpedRoom()
                my.stopLoading()
            else
                my.stopLoading()
                my.informPluginByName({params={message='remove'}})
            end

            cc.exports.jumpHighRoom = false
        else
            if self._roomContextOut['roomInfo'] and self._roomContextOut['roomInfo']['isTeam2V2']  then
                self._roomContextOut["areaEntry"] = 'team2V2'
            end
            if self._roomContextOut["areaEntry"] == "jisu" then
                my.informPluginByName({sender = self, pluginName = 'JiSuQuickStartCtrl'})
            else
                my.informPluginByName({sender = self, pluginName = 'QuickStartCtrl'})
            end
            my.stopLoading()
        end
    end, 0)

    if cc.exports._isEnterRoomForGameScene then
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["roomManager_enterRoomOk"]})
    end

    RoomListModel:stopPlayerNumUpdateScheduler()
end

function MyRoomManager:onSocketError()
    print("MyRoomManager:onSocketError")
    my.stopLoading()

    self:closeSecondeLayer(true)
    GamePublicInterface:OnInGameRoomSocketError()
    if cc.exports.jumpHighRoom == true then
        cc.exports.jumpHighRoom = false

        local okCallback = function()
            my.informPluginByName({params={message='remove'}})
        end

        local msg = GamePublicInterface:getGameString("G_DISCONNECTION_NOPLAYING")
        local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
        my.informPluginByName({pluginName = "SureDialog", params = {
            tipContent = utf8Msg,
            tipTitle = nil,
            okBtTitle = nil,
            onOk = function()                
                if  cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
                    cc.exports.GamePublicInterface._gameController:gotoHallScene()
                end
            end,
            closeBtVisible = false,
            forbidKeyBack = true
        }})
    else
        self:_showTip(self._roomStrings["SOCKET_ERROR"])
    end
end

function MyRoomManager:doLeaveCurrentRoom()
    print("MyRoomManager:doLeaveCurrentRoom")

    if self._roomContextOut["roomModel"] then
        self._roomContextOut["roomModel"]:leaveRoom()
    end
    self._roomContextOut["roomModel"] = nil

    --优化：roomInfo被大量外部模块引用，为了避免重置后引用模块仍然使用出现nil错误，故不予重置，一律以覆盖方式更新
    --self._roomContextOut["roomInfo"] = nil
    self._roomContextOut["tableInfo"] = nil
    self._roomContextOut["enterRoomOk"] = nil
    
    self._roomContext["isEnteringRoom"] = false
    self._roomContext["lastEnterRoom_BeginTime"] = -1
    self._roomContext["enterRoomCallback"] = nil
end

function MyRoomManager:onRoomPlayerNumUpdated()
    print("MyRoomManager:onRoomPlayerNumUpdated")

    local secondLayer = self._roomContext["secondLayer"]
    if secondLayer and secondLayer.onRoomPlayerNumUpdated  then
        secondLayer:onRoomPlayerNumUpdated()
    end
end

function MyRoomManager:onAllRoomsInfoGot()
    print("MyRoomManager:onAllRoomsInfoGot")

    if self.firstLayer then
        self.firstLayer:refreshPanelQuickStart()
    end
end

function MyRoomManager:onBackFromGame()
    printLog("MyRoomManager", "onBackFromGame1")

    self._roomContextOut["isEnteredGameScene"] = false

    --如果没有打开的房间二级界面，则执行一次leaveRoom
    if self._roomContext["secondLayer"] == nil then
        print("MyRoomManager:onBackFromGame and secondLayer is nil and doLeaveCurrentRoom")
        self:doLeaveCurrentRoom()
    else
        if self.subTeam2V2RoomManager:getSecondLayerTeam2V2() then
            self:doLeaveCurrentRoom()
            Team2V2Model:backFromGame()
        elseif self.subTeamRoomManager:getSecondLayerTeam() then
            --只有好友房是“进入房间”和“进入桌子”分离的；其它都需要调用leaveRoom
        else
            print("MyRoomManager:onBackFromGame and secondLayer not team and doLeaveCurrentRoom")
            self:doLeaveCurrentRoom()
        end

        local secondLayer = self._roomContext["secondLayer"]
        self._roomContextOut["areaEntry"] = secondLayer._areaEntryByLayer --根据secondLayer重新设定一遍areaEntry
        secondLayer:refreshView() -- 积分场退出后，用于刷新积分场房间按钮状态
    end

    if self.subTeam2V2RoomManager:dealOnBackFromGame() == true then
        print("subTeam2V2RoomManager:dealOnBackFromGame return true")
        my.scheduleOnce(function()
            if my.isInGame() then return end
            local netProcess = import('src.app.BaseModule.NetProcess'):getInstance()
            if netProcess:isNetStatusFinished() then
                PlayerModel:checkPlayerGameStatus()
            end
        end, 1.5)
    elseif self.subTeamRoomManager:dealOnBackFromGame() == true then
        print("subTeamRoomManager:dealOnBackFromGame return true")
    else
        self.subArenaRoomManager:dealOnBackFromGame()
        printLog("MyRoomManager", "onBackFromGame5")

        my.scheduleOnce(function()
            if my.isInGame() then return end
            local netProcess = import('src.app.BaseModule.NetProcess'):getInstance()
            if netProcess:isNetStatusFinished() then
                PlayerModel:checkPlayerGameStatus()
            end
        end, 1)
    end

    local netProcess = import('src.app.BaseModule.NetProcess'):getInstance()
    if netProcess:isNetStatusFinished() then
        local centerCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
        centerCtrl:silentCheckUpdate()
        RoomListModel:autoUpdateRoomList()
    end
    RoomListModel:startPlayerNumUpdateScheduler()
end

function MyRoomManager:_onEnterRoomSucceeded( ... )
    if self._roomContext["enterRoomCallback"] then
        self._roomContext["enterRoomCallback"]( ... )
        self._roomContext["enterRoomCallback"] = nil
    end
end

function MyRoomManager:onLogoff()
    if my.isInGame() == true then
        --如果当前还在游戏场景内，则先不执行doLeaveCurrentRoom
        print("MyRoomManager:onLogoff but still in gamescene")
    else
        print("MyRoomManager:onLogoff and doLeaveCurrentRoom")
        local secondLayer = self._roomContext["secondLayer"]
        if secondLayer and secondLayer.layerName == "joy" then
            --由于断网情况下，单机场需要暴露出来，所以娱乐场作为入口也需要暴露出来
            secondLayer:refreshView()
        else
            self:closeSecondeLayer(true)
        end
    end

    self.firstLayer:onLogoff()

    if self._MyLogonSuccessStatus and true  ==  self._MyLogonSuccessStatus then
        self._MyLogonSuccessStatus = false
    end

end

function MyRoomManager:onLogon()
    if my.isInGame() == true then
        --如果当前还在游戏场景内，不执行doLeaveCurrentRoom
        print("MyRoomManager:onLogon but still in gamescene")
    else
        print("MyRoomManager:onLogon and doLeaveCurrentRoom")
        self:doLeaveCurrentRoom()
    end
    self.firstLayer:onLogon()

    if self._MyLogonSuccessStatus == nil then
        self._MyLogonSuccessStatus = true
    end
end

--MainCtrl:setPlayerData触发，表示用户信息更新了
function MyRoomManager:onPlayerDataUpdated()
    if self.firstLayer then
        self.firstLayer:refreshAreaEntryLock()
    end
    self:refreshViewOnDepositChange()
end

function MyRoomManager:_showTip(str, ...)
    if not str then return end
    local tipString = string.format(str, ...)
    local pluginName = self._roomContextOut["isEnteredGameScene"] and "ToastPlugin" or "TipPlugin"
    my.informPluginByName({pluginName = pluginName, params = {tipString = tipString, removeTime = 2}})
end

--单机房
function MyRoomManager:tryEnterOfflineRoom()
    self._roomContextOut["roomModel"] = nil
    self._roomContextOut["roomInfo"] = RoomListModel.OFFLINE_ROOMINFO
    self._roomContextOut["tableInfo"] = nil

    my.startLoading()
    my.informPluginByName({pluginName = 'OfflineGamePlugin'})
end

function MyRoomManager:onGotoGameByRoomIdInGameScene(data)
    print("MyRoomManager:onGotoGameByRoomIdInGameScene")
    if not CenterCtrl:checkNetStatus() then return end
    if data == nil or data.value == nil then
        print("no params")
        return
    end

    local params = data.value
    my.scheduleOnce(function()
        --延时的原因：从游戏内返回立即调用“触发进入游戏的流程”，cocos模拟器会崩溃
        self:tryEnterRoom(params["targetRoomId"], false, nil) 
    end, 0)
end

function MyRoomManager:onGotoGameByQuickStartInHall(data)
    print("MyRoomManager:onGotoGameByQuickStart")
    if not CenterCtrl:checkNetStatus() then return end
    if data == nil or data.value == nil then
        print("no params")
        return
    end

    local params = data.value
    if params["autoDecideRoomScope"] == true then
        self:doQuickStartGame(self._roomContextOut["areaEntry"] or "normal")
    else
        self:doQuickStartGame(params["findScope"])
    end
end

function MyRoomManager:onGotoScoreGameInGameScene()
    print("MyRoomManager:onGotoScoreGameInGameScene")
    self._roomContextOut["areaEntry"] = "joy"

    local weakOpen = WeakenScoreRoomModel:onGetWeakOpen()
    local triggerStatus = WeakenScoreRoomModel:onCheckTriggerLimitStatus()
    local silverStatus = WeakenScoreRoomModel:onCheckSliverStatus()

    print("SecondLayerJoy:onGotoScoreGameInGameScene silverStatus", silverStatus)

    local isGO = false
    if not weakOpen then --没开限制活动
        isGO = true
    elseif silverStatus and triggerStatus then --已经触发并且没有领奖
        isGO = true
    end

    if not isGO then --不能进入
        return
    end

    my.scheduleOnce(function()
        --延时的原因：从游戏内返回立即调用“触发进入游戏的流程”，cocos模拟器会崩溃
        self:doGotoScoreGame()
    end, 0)
end

function MyRoomManager:doQuickStartGame(findScope)
    print("MyRoomManager:doQuickStartGame")
    if not CenterCtrl:checkNetStatus() then return end
    if findScope == nil then return end

    if not UIHelper:checkOpeCycle("MyRoomManager_doQuickStartGame") then
        return
    end
    UIHelper:refreshOpeBegin("MyRoomManager_doQuickStartGame")

    local fitRoomInfo
    local NewUserGuideModel = mymodel('NewUserGuideModel'):getInstance()
    if NewUserGuideModel:isNeedGuide() then
        fitRoomInfo = RoomListModel:getNewUserGuideRoom()
    else
        fitRoomInfo = RoomListModel:findFitRoomByDeposit(UserModel.nDeposit, findScope, UserModel.nSafeboxDeposit)
    end

    if fitRoomInfo == nil then
        fitRoomInfo = RoomListModel:findFitRoomByDepositEx(UserModel.nDeposit, findScope, UserModel.nSafeboxDeposit)
        if fitRoomInfo == nil then
            print("fitRoomInfo is nil, findScope "..tostring(findScope))
            return
        end
    end

    if fitRoomInfo["isNoShuffleRoom"] or fitRoomInfo['isGuideRoom'] then
        self._roomContextOut["areaEntry"] = "noshuffle"
    elseif fitRoomInfo["isJiSuRoom"] then
        self._roomContextOut["areaEntry"] = "jisu"
    elseif fitRoomInfo["isClassicRoom"] then
        self._roomContextOut["areaEntry"] = "classic"
    end

    local quickStartType = cc.exports.getQuickStartMatchType()
    local matchType = cc.exports.getQuickStartMatchType()
    if AdditionConfigModel.ROOM_MATCH_TYPE_RANDOM == matchType then --随机算法
        quickStartType = CacheModel:getCacheByKey("QuickStartMatchType")
    end

    local quickStartInfo = {
        ["clickTime"]       = os.date("%Y%m%d%H%M%S", os.time()),
        ["userID"]          = UserModel.nUserID,
        ["platFormType"]    = device.platform,
        ["tcyChannel"]      = tostring(my.getTcyChannelId()),
        ["deposit"]         = UserModel.nDeposit,
        ["safeboxDeposit"]  = UserModel.nSafeboxDeposit,
        ["roomID"]          = fitRoomInfo["nRoomID"],
        ["findScope"]       = findScope,
        ["quickStartType"]  = quickStartType
    }
    
    my.dataLink(cc.exports.DataLinkCodeDef.QUICK_START_GAME_BTN_CLICK, quickStartInfo)

    my.scheduleOnce(function()
        --延时的原因：从游戏内返回立即调用“触发进入游戏的流程”，cocos模拟器会崩溃
        self:tryEnterRoom(fitRoomInfo["nRoomID"], false, nil)
    end, 0) 
end

function MyRoomManager:doGotoScoreGame()
    if RoomListModel.scoreRoomInfo then
        my.scheduleOnce(function()
            --延时的原因：从游戏内返回立即调用“触发进入游戏的流程”，cocos模拟器会崩溃
            self:tryEnterRoom(RoomListModel.scoreRoomInfo["nRoomID"], false, nil)
        end, 0)
    end
end

function MyRoomManager:doGotoTimingGame(info)
    if info and info.value and info.value.nRoomID then
        my.scheduleOnce(function()
            --延时的原因：从游戏内返回立即调用“触发进入游戏的流程”，cocos模拟器会崩溃
            self:tryEnterRoom(info.value.nRoomID, false, nil)
        end, 0)
    end
end

-- 进入主播房
function MyRoomManager:doGotoAnchorRoom()    
    my.scheduleOnce(function()
        --延时的原因：从游戏内返回立即调用“触发进入游戏的流程”，cocos模拟器会崩溃
        local anchorRoomInfo = RoomListModel:getAnchorRoomInfo()
        if anchorRoomInfo then
            self:tryEnterRoom(anchorRoomInfo.nRoomID, false, nil)
        end
    end, 0)
end

--校验积分场进入限制
function MyRoomManager:checkScoreRoomAvail()
    -- [jfcrh]从经典掼蛋移植的函数 by wuym
    return RoomListModel:onGetScoreRoomBtnStatus()

end

function MyRoomManager:onScoreRoomBtn(info)
    local secondLayer = self._roomContext["secondLayer"]
    if secondLayer and secondLayer.onTouchScoreRoomBtn and info.value then
        secondLayer:onTouchScoreRoomBtn(nil, nil, info.value.isInGame)
    elseif not secondLayer then --如果没有拿到二级界面
        self:onGotoScoreGameInGameScene()
    end
end

function MyRoomManager:refreshScoreRoomBtnInfo()
    local secondLayer = self._roomContext["secondLayer"]
    if secondLayer and secondLayer.refreshScoreRoomBtnInfo then
        secondLayer:refreshScoreRoomBtnInfo()
    end
end

function MyRoomManager:onKeyback()
    print("MyRoomManager:onKeyback")
    if self:_isDoingEnterRoom() == true then
        print("isDoingEnterRoom")
        return true
    end

    local guideNode = self._mainCtrl._viewNode:getChildByName("Node_GuideTipOfDepositUnSatisfied_OnEnterRoom")
    if guideNode ~= nil and not tolua.isnull(guideNode) then
        my.playClickBtnSound()
        guideNode:removeFromParentAndCleanup()
        return true
    end

    if self.subTeam2V2RoomManager:onKeyback() == true then
        my.playClickBtnSound()
        return true
    end

    if self.subTeamRoomManager:onKeyback() == true then
        my.playClickBtnSound()
        return true
    end

    local secondLayer = self._roomContext["secondLayer"]
    if secondLayer then
        my.playClickBtnSound()
        self:closeSecondeLayer(true)
        return true
    end

    return false
end

function MyRoomManager:onDepositTooHighWhenEnterRoom(roomID)
    print("MyRoomManager:onDepositTooHighWhenEnterRoom")
    local roomInfo = RoomListModel.roomsInfo[roomID]
    if roomInfo == nil then
        print("current roomInfo is nil")
        return
    end

    local MyGamePromptMoreMoney = import("src.app.Game.mMyGame.MyGamePromptMoreMoney")
    local roomDeposit  = roomInfo.nMinDeposit
    local roomMaxDeposit  = roomInfo.nMaxDeposit

    local myDeposit = UserModel.nDeposit
    local leftDeposit = roomMaxDeposit -- 2019年9月3日 保留下限五倍改成保留房间上限 --roomDeposit*5 
    
    -- r2018年7月9日 因为赠送银变多，外网限制至少携带1万两。
    local playerMinDeposit = cc.exports.GetPlayerMinDeposit()
    if leftDeposit <  playerMinDeposit then
        leftDeposit = playerMinDeposit
    end

    local saveDepositNum = myDeposit - leftDeposit
    if saveDepositNum <= 0 then
        saveDepositNum = myDeposit - roomMaxDeposit
    end

    local safeboxBtnShow = false
    if true == cc.exports.PUBLIC_INTERFACE.IsStartAsFriendRoom(roomInfo) then
        safeboxBtnShow = true
    elseif true == cc.exports.PUBLIC_INTERFACE.IsStartAsArenaPlayer(roomInfo) then
        safeboxBtnShow = true
    end
    local prompt = MyGamePromptMoreMoney:create(self._mainCtrl, saveDepositNum, true, safeboxBtnShow)

    if prompt then
        if true == safeboxBtnShow then
            -- 好友房的时候，禁止跳转高级房 2018年9月17日，策划需求
            prompt:setGotoRoomBtnState(false)
        end

        if  cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
            cc.exports.GamePublicInterface._gameController._baseGameScene:addChild(prompt, 1910)
            prompt:setGotoRoomBtnState(false)
            prompt._closeBtn:addClickEventListener(handler(prompt, prompt.onCloseEx))
            prompt:updateSaveDeposit( self.roomid)
        else
            prompt:setName("Node_GuideTipOfDepositUnSatisfied_OnEnterRoom")
            local curScene = cc.Director:getInstance():getRunningScene()
            curScene:addChild(prompt, 100)
        end
        prompt:setPosition(display.center)
    end
end

function MyRoomManager:onDepositNotEnoughWhenEnterRoom(roomID)
    print("MyRoomManager:onDepositNotEnoughWhenEnterRoom")
    self:checkRelief(UserModel.nDeposit, RoomListModel.roomsInfo[roomID])
end

function MyRoomManager:dealDepositNotEnoughWhenEnterRoomWithoutRelief(roomInfo)
    print("MyRoomManager:dealDepositNotEnoughWhenEnterRoomWithoutRelief")
    if roomInfo == nil then
        print("current roomInfo is nil")
        return
    end

    if cc.exports.PromptTakeSilver then
        return
    end

    local MyGamePromptTakeSilver = import("src.app.Game.mMyGame.MyGamePromptTakeSilver")
    local roomDeposit  = roomInfo.nMinDeposit
    local curRoomId = roomInfo.nRoomID
    local SafeboxDeposit = UserModel:getSafeboxDeposit()
    local myDeposit = UserModel.nDeposit
    local takeDepositNum = SafeboxDeposit

    local depositeLimit = cc.exports.getTakeDepositeLimit(curRoomId, roomDeposit)
    if roomDeposit <= (myDeposit + SafeboxDeposit) then
        if SafeboxDeposit >= depositeLimit then
            takeDepositNum = depositeLimit - myDeposit
        end
        local prompt = MyGamePromptTakeSilver:create(self._mainCtrl, takeDepositNum, true, curRoomId, roomDeposit - myDeposit)
        if prompt then
            cc.exports.PromptTakeSilver = prompt
            if  cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
                cc.exports.GamePublicInterface._gameController._baseGameScene:addChild(prompt, 1910)
                cc.exports.GamePublicInterface._gameController._baseGameScene._mainTakeSilverPrompt = prompt
                prompt._payBtn:addClickEventListener(handler(prompt, prompt.onPayEx))
                prompt._closeBtn:addClickEventListener(handler(prompt, prompt.onCloseEx))
            else
                prompt:setName("Node_GuideTipOfDepositUnSatisfied_OnEnterRoom")
                local curScene = cc.Director:getInstance():getRunningScene()
                curScene:addChild(prompt, 100)
            end
            prompt:setPosition(display.center)
        end
    else
        self._mainCtrl:OnGetItemInfo(curRoomId, roomDeposit - myDeposit)
    end
end

function MyRoomManager:checkRelief(userDeposit, roomInfo)
    print("MyRoomManager:checkRelief")
	local reliefData = UserModel.reliefData
	local config = ReliefActivity.config
	local state = ReliefActivity.state

    local bCanGetWelfare = true
    if state ~= 'SATISFIED' then
        bCanGetWelfare = false
    end

    --贵族使用缓存
    local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local status,reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
    local user = mymodel('UserModel'):getInstance()
    local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief"..user.nUserID..os.date('%Y%m%d',os.time())))
    if not reliefUsedCount then reliefUsedCount = 0 end
    if status and reliefUsedCount and reliefUsedCount >= reliefCount then   --当天升级使用低保超过了缓存，则返回
        bCanGetWelfare = false
    end

    if bCanGetWelfare then
        my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_ROOMMANAGER, promptParentNode = self._mainCtrl, leftTime = reliefData.timesLeft, limit = config.Limit}})
    elseif ReliefActivity:isVideoAdReliefValid() then
        -- 视频低保
        my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_ROOMMANAGER, promptParentNode = self._mainCtrl, VideoAdRelief = true}})
    else
        self:dealDepositNotEnoughWhenEnterRoomWithoutRelief(roomInfo)
    end
end

-- 移动端选桌：begin
--获取座位并自动开始(请求响应)
function MyRoomManager:MR_GET_SEATED_AND_START(tableno, chairno, limit, force, invite, callback)
    if self._roomContextOut["roomModel"] then
        self._roomContextOut["roomModel"]:MR_GET_SEATED_AND_START(tableno, chairno, limit, force, invite, callback)
    end
end

--新建桌子并自动开始(请求响应)
function MyRoomManager:MR_GET_NEWTABLE_EX(limit, empty, callback)
    if self._roomContextOut["roomModel"] then
        self._roomContextOut["roomModel"]:MR_GET_NEWTABLE_EX(limit, empty, callback)
    end
end

--选坐界面唤醒(请求响应)
function MyRoomManager:MR_XZ_RESUME(callback)
    if self._roomContextOut["roomModel"] then
        self._roomContextOut["roomModel"]:MR_XZ_RESUME(callback)
    end
end

--获取房间信息(请求响应)
function MyRoomManager:MR_GET_ROOM_INFO(callback)
    if self._roomContextOut["roomModel"] then
        self._roomContextOut["roomModel"]:MR_GET_ROOM_INFO(callback)
    end
end
-- 移动端选桌：end

function MyRoomManager:onSkipGuide()
    if self.firstLayer then
        self.firstLayer:refreshView()
    end
end

return MyRoomManager