--保存大厅管理范围（大厅自己以及各子模块）的上下文信息，比如房间选择信息等
local HallContext = class("HallContext")
my.addInstance(HallContext)

HallContext.EVENT_MAP = {
    ["netProcessWatcher_netProcessFinished"] = "netProcessWatcher_netProcessFinished",
    ["roomManager_enterRoomOk"] = "roomManager_enterRoomOk",

    ["hall_gotoGameByQuickStart"] = "hall_gotoGameByQuickStart",
    ["hall_backToMainSceneFromNonSceneFullScreenCtrl"] = "hall_backToMainSceneFromNonSceneFullScreenCtrl",

    ["gameScene_goBackToMainScene"] = "gameScene_goBackToMainScene",
    ["gameScene_gotoGameByRoomId"] = "gameScene_gotoGameByRoomId",
    ["gameScene_gotoScoreGame"] = "gameScene_gotoScoreGame"
}

function HallContext:ctor()
    cc.load('event'):create():bind(self)

    self.context = {
        ["isLogoff"] = false,

        ["roomStrings"] = cc.load('json').loader.loadFile('RoomStrings.json'),
        ["roomContext"] = {
            ["areaEntry"] = nil,

            ["roomModel"] = nil,

            ["roomInfo"] = nil,
            ["tableInfo"] = nil,
            ["enterRoomOk"] = nil,
            ["isEnteredGameScene"] = false --是否已经进入游戏场景
        },
        ["teamRoomContext"] = {
            ["enterTeamInfo"] = {
                ["hostName"] = nil,
                ["hostID"] = nil,
                ["roomID"] = nil,
                ["tableNO"] = nil,
                ["enterType"] = nil,
                ["readyToFollowOnBackFromGame"] = false
            }
        },
        ["arenaRoomContext"] = {
            ["isArenaPlayer"] = false
        }
    }
end

--登陆、或切换账号，需要重置部分上下文
function HallContext:onLogon()
    self.context["isLogoff"] = false

    self.context["arenaRoomContext"]["isArenaPlayer"] = false

    --仅重置Count
    local reliefData = cc.exports.gameReliefData
    if reliefData and reliefData.state then
        reliefData.state.Count = 0
    end
end

function HallContext:onLogoff()
    self.context["isLogoff"] = true
end

function HallContext:isLogoff()
    if self.context["isLogoff"] == true then
        return true
    end
    return false
end

return HallContext