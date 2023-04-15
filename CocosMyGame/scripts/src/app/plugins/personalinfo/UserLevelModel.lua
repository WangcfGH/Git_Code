local UserLevelModel = class('UserLevelModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(UserLevelModel)

local UserLevelReq = import('src.app.plugins.personalinfo.UserLevelReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local PlayerModel = mymodel('hallext.PlayerModel'):getInstance()

local UserLevelDef = {
    GR_GET_USER_LEVEL = 404101,     --获取玩家等级
}

UserLevelModel.UPDATE_SELF_LEVEL_DATA = 'PLAYER_LEVEL_DATA_UPDATED' --更新自己的等级
UserLevelModel.UPDATE_OTHER_LEVEL_DATA = 'OTHER_LEVEL_DATA_UPDATED' --更新其他玩家的等级
UserLevelModel.EVENT_MAP = {
}

function UserLevelModel:onCreate()
    self._assistResponseMap = {
        [UserLevelDef.GR_GET_USER_LEVEL] = handler(self, self.DealUserLevelDataResp),
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function UserLevelModel:sendGetUserLevelReqForMySelf()
	local playerInfo = PublicInterface.GetPlayerInfo()
    self:sendGetUserLevelReq(playerInfo.nUserID, playerInfo.nBout)
end

function UserLevelModel:sendGetUserLevelReq(userID, nBout)
	local USER_LEVEL_DATA = UserLevelReq["USER_LEVEL_DATA"]
    local nPlayerBout = 0
    if nBout then
        nPlayerBout = nBout
    end
	local data = {
		nUserID = userID,
        nLevel = nPlayerBout
	}
	local pData = treepack.alignpack(data, USER_LEVEL_DATA)
	AssistModel:sendData(UserLevelDef.GR_GET_USER_LEVEL, pData)
end

function UserLevelModel:DealUserLevelDataResp(data)
    if data == nil then return end

    local levelData = UserLevelReq["USER_LEVEL_DATA"]
    local msgLevelData = treepack.unpack(data, levelData)

    if msgLevelData == nil then
        return
    end
	local playerInfo = PublicInterface.GetPlayerInfo()
    if playerInfo.nUserID == msgLevelData.nUserID then
        cc.exports._userLevelData = clone(msgLevelData)
        self:dispatchEvent({name = self.UPDATE_SELF_LEVEL_DATA})
    else
        self:dispatchEvent({name = self.UPDATE_OTHER_LEVEL_DATA, value = msgLevelData})
    end
end

return UserLevelModel