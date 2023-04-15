local ArenaModel = class("ArenaModel", require('src.app.GameHall.models.BaseModel'))
my.addInstance(ArenaModel)

local ArenaRequests = import("src.app.plugins.arena.ArenaRequests")
local ArenaDataSet = require("src.app.plugins.arena.ArenaDataSet"):getInstance()
local arenaRankData = require("src.app.plugins.ArenaRank.ArenaRankData"):getInstance()
local arenaRankTakeRewardModel = require("src.app.plugins.ArenaRankTakeReward.ArenaRankTakeRewardModel"):getInstance()

local ArenaReq = import('src.app.plugins.arena.ArenaReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local UserModel = mymodel('UserModel'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local mySignUpStatus = require("src.app.plugins.SignUp.SignUpStatus"):getInstance()
local mySignUpPayStatus = require("src.app.plugins.SignUp.SignUpPayStatus"):getInstance()
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()

ArenaModel.EVENT_MAP = {
    ["arenaModel_userArenaInfoUpdatedByGiveUp"] = "arenaModel_userArenaInfoUpdatedByGiveUp",
    ["ARENA_USER_RANKUP"] = "ARENA_USER_RANKUP"
}

local ArenaDef = {
    ASSIT_SIGN_UP_ARENA_RANK = 401601,
    ASSIT_GET_ARENA_RANK_STATE = 401603,
    --ASSIT_GET_ARENA_RANK_REWARD_LIST = 401606,
    ASSIT_TAKE_ARENA_RANK_REWARD = 401607,
    ASSIT_UPDATE_ARENA_ROUND = 401608,
    --ASSIT_NOTICY_ARENA_SIGNUP = 401609,
    --ASSIT_NOTICY_ARENA_GIVEUP = 401610,
    -- 竞技场获取本周排行榜数据 新2018年10月30日
    ASSIT_GET_ARENA_WEEK_RANK_LIST = 401611,    -- 竞技场新榜获取排名列表
    ASSIT_MOVE_MY_ARENA_RANK_DATA = 401612,     -- 用于新客户端积分搬迁到新数据库

    --竞技场新排行榜
    ASSIT_GET_ARENA_RANK_REWARD_LIST = 410020, -- 查询奖励列表
    ASSIT_GET_ARENA_RANK_MATCH_CONFIG = 410021, -- 查询竞技场房间积分加成
}

function ArenaModel:onCreate()
    self._requester = ArenaRequests:create()
    
    self.maxSignUpCount = 20
    self.arenaFreeMatchesInfo = {} --免费比赛
    self.arenaSilverMatchesInfo = {} --银子付费比赛
    self.arenaRoomsInfo = {} --比赛对应的房间号；注意：免费和付费比赛对应的房间号是一致的

    self.userArenaData = {} --用户比赛状态信息
    self.userMatchInfo = {} --用户当前所在比赛

    self._assistResponseMap = {
        [ArenaDef.ASSIT_SIGN_UP_ARENA_RANK] = handler(self, self.onSignUpArenaRank),
        [ArenaDef.ASSIT_GET_ARENA_RANK_STATE] = handler(self, self.onGetArenaRankState),
        [ArenaDef.ASSIT_GET_ARENA_RANK_REWARD_LIST] = handler(self, self.onGetArenaRankRewardList),
        [ArenaDef.ASSIT_GET_ARENA_RANK_MATCH_CONFIG] = handler(self, self.onGetArenaRankMatchConfig),
        [ArenaDef.ASSIT_TAKE_ARENA_RANK_REWARD] = handler(self, self.onTakeArenaRankReward),
        [ArenaDef.ASSIT_UPDATE_ARENA_ROUND] = handler(self, self.onDiffArenaRank),
        [ArenaDef.ASSIT_GET_ARENA_WEEK_RANK_LIST] = handler(self, self.onGetArenaRankState),
        [ArenaDef.ASSIT_MOVE_MY_ARENA_RANK_DATA] = handler(self, self.onGetArenaMoveScoreResp)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

--得到竞技场配置后，把每一个matchItem映射到具体的房间上
function ArenaModel:_calcArenaRoomsInfoByArenaConfig()
    self.arenaRoomsInfo = {}

    local allArenaRoomInfos = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsArena)
    for i = 1, #self.arenaFreeMatchesInfo do
        local matchItem = self.arenaFreeMatchesInfo[i]
        for j = 1, #allArenaRoomInfos do
            local roomInfo = allArenaRoomInfos[j]
            if roomInfo["nMinDeposit"] >= matchItem["nMinDeposit"] then
                self.arenaRoomsInfo[i] = roomInfo
                break
            end
        end
    end
end

function ArenaModel:getArenaConfig(callback)
    print("ArenaModel:getArenaConfig")
    self._requester:MR_GET_ARENA_CONFIG(function(respondType, data, msgType, dataMap)
        if respondType == mc.UR_OPERATE_SUCCEED  then
            local function comps(a,b)
                return a.nMinDeposit < b.nMinDeposit
            end

            if dataMap[1].nMatchNum>0 then
                table.sort(dataMap[2],comps)
                self.maxSignUpCount = dataMap[2][1].nMaxSignUpDaily
            end

            --注意获取到新数据，需要重置旧数据
            self.arenaFreeMatchesInfo = {} 
            self.arenaSilverMatchesInfo = {}

            for i = #dataMap[2], 1, -1 do
                if dataMap[2][i].nSignUpPayType ~= 1 then --1 免费 2 银子 3 比赛券 4 银子和比赛
                    if dataMap[2][i].nSignUpPayType == 2 then  --暂时只处理银子的报名比赛
                        table.insert(self.arenaSilverMatchesInfo, clone(dataMap[2][i]))
                    end
                else
                    table.insert(self.arenaFreeMatchesInfo, clone(dataMap[2][i]))
                end
            end
            table.sort(self.arenaFreeMatchesInfo, comps)
            table.sort(self.arenaSilverMatchesInfo, comps)
            dump(self.arenaFreeMatchesInfo)
            dump(self.arenaSilverMatchesInfo)
        else
            print("get ArenaList Failed!")
        end
        
        --免费比赛场次数量和基本属性，应该和银子付费场次一致
        local isConfigLegal = true
        if #self.arenaFreeMatchesInfo ~= #self.arenaSilverMatchesInfo then
            isConfigLegal = false
        else
            for i = 1, #self.arenaFreeMatchesInfo do
                if self.arenaFreeMatchesInfo[i]["nMinDeposit"] ~= self.arenaSilverMatchesInfo[i]["nMinDeposit"] then
                    isConfigLegal = false
                    break
                end
            end
        end
        if isConfigLegal == true then
            self:_calcArenaRoomsInfoByArenaConfig()
            callback(dataMap, respondType)
        else
            print("area room config illegal, free matches not same with silver matches!!!")
        end
     end)
end

function ArenaModel:getUserArenaInfo(callbackOnSuccess)
    self._requester:MR_GET_MY_ARENA_DETAIL(function(respondType, data, msgType, dataMap)
        if respondType ~= mc.UR_OPERATE_SUCCEED then
            print("sorry, getUserArenaInfo Failed!")
            return
        else
            self.userArenaData = dataMap
            ArenaDataSet:setData("ArenaUserInfo", self.userArenaData) --存入公共类，供外部使用
            if type(callbackOnSuccess) == "function" then
                callbackOnSuccess(dataMap)
            end  
        end 
    end)
end

--注意这个函数还会更新缓存变量
function ArenaModel:getMatchInfoByMatchIDFromLocal(matchID)
    for _, info in pairs(self.arenaFreeMatchesInfo) do 
		if info.nMatchID == matchID then

			self.userMatchInfo = info
			ArenaDataSet:setData("ArenaMatchInfo", self.userMatchInfo) --存入公共类，供外部使用

			return info
		end
	end
	for _, info in pairs(self.arenaSilverMatchesInfo) do 
		if info.nMatchID == matchID then

			self.userMatchInfo = info
			ArenaDataSet:setData("ArenaMatchInfo", self.userMatchInfo) --存入公共类，供外部使用

			return info
		end
	end
end

--注意这个函数还会更新缓存变量
function ArenaModel:getSilverMatchInfoByMatchIDFromLocal(matchID)
	for _, info in pairs(self.arenaSilverMatchesInfo) do 
		if info.nMatchID == matchID then

			self.userMatchInfo = info
			ArenaDataSet:setData("ArenaMatchInfo", self.userMatchInfo) --存入公共类，供外部使用

			return info
		end
	end
end

--注意这个函数还会更新缓存变量
function ArenaModel:getMatchInfoByMatchIDFromReq(matchID, callback)
    self:getArenaConfig(function(dataMap, respondType)
		if respondType ~= mc.UR_OPERATE_SUCCEED  then
			print("sorry, getArenaList Failed")
			return
		else
			for _, info in pairs(dataMap[2]) do 
				if info.nMatchID == matchID then
					self.userMatchInfo = info
					ArenaDataSet:setData("ArenaMatchInfo", self.userMatchInfo) --存入公共类，供外部使用
					callback(info)
					return
				end
			end
		end 
	end)
end

--注意matchGradeIndex对应的是房间的gradeIndex，而不是matchInfoList中的序号matchIndex；
--同时返回matchGradeIndex和matchIndex
function ArenaModel:getMatchGradeIndex(matchId)
    if matchId == nil or matchId <= 0 then
        return nil, nil
    end

    local matchIndex = nil
    for i = 1, #self.arenaFreeMatchesInfo do
        local matchInfo = self.arenaFreeMatchesInfo[i]
        if matchInfo["nMatchID"] == matchId then
            matchIndex = i
        end
    end

    if matchIndex == nil then
        for i = 1, #self.arenaSilverMatchesInfo do
            local matchInfo = self.arenaSilverMatchesInfo[i]
            if matchInfo["nMatchID"] == matchId then
                matchIndex = i
            end
        end
    end

    if matchIndex then
        local roomInfo = self.arenaRoomsInfo[matchIndex]
        return math.max(math.min(roomInfo["gradeIndex"], 6), 1), matchIndex
    end

    return nil, matchIndex
end

function ArenaModel:signUpArenaMatch(matchID, signUpPayType, callback)
    self._requester:MR_ARENA_REQ_SIGNUP(matchID, signUpPayType, callback)
end

function ArenaModel:GetSignUpCountToday()
    local signUpCountTemp = mySignUpStatus:getSignUpCacheFile().signUpCount
    local signUpDate = mySignUpStatus:getSignUpCacheFile().timeName
    local isSignUped = mySignUpStatus:getSignUpCacheFile().isSignUped
    if mySignUpStatus:getTodayDate() == signUpDate and signUpCountTemp >= self.maxSignUpCount then
        return -1
    end

    if mySignUpStatus:getTodayDate() ~= signUpDate  then
        signUpCountTemp = 0
    end

    local signUpCountInfo = {signUpCount = signUpCountTemp , timeName = mySignUpStatus:getTodayDate(), isSignUped = isSignUped}
    mySignUpStatus:setMySignUpDatas(signUpCountInfo)

    local count = self.maxSignUpCount-signUpCountTemp  
    return count
end

function ArenaModel:GetSignUpPayCountToday()
    local signUpCountTemp = mySignUpPayStatus:getSignUpCacheFile().signUpCount
    local signUpDate = mySignUpPayStatus:getSignUpCacheFile().timeName
    local isSignUped = mySignUpPayStatus:getSignUpCacheFile().isSignUped
    if mySignUpPayStatus:getTodayDate() == signUpDate and signUpCountTemp >= self.maxSignUpCount then
        return -1
    end

    if mySignUpPayStatus:getTodayDate() ~= signUpDate  then
        signUpCountTemp = 0
    end

    local signUpCountInfo = {signUpCount = signUpCountTemp , timeName = mySignUpPayStatus:getTodayDate(), isSignUped = isSignUped}
    mySignUpPayStatus:setMySignUpDatas(signUpCountInfo)

    local count = self.maxSignUpCount-signUpCountTemp  
    return count
end

function ArenaModel:getMyRank(callback)
    self._requester:MR_ARENA_REQ_MY_RANK(function(respondType, data, msgType, dataMap)
        if respondType ~= mc.UR_OPERATE_SUCCEED then
          print("sorry, getMyRank Failed!")
          return 
        end
        callback(dataMap)      
     end)
end

function ArenaModel:getRank(targetRank, range, callback)
    self._requester:MR_ARENA_REQ_RANK(targetRank, range, function(respondType, data, msgType, dataMap)
        if respondType ~= mc.UR_OPERATE_SUCCEED then 
            print("sorry, getRank Failed!")
            return
        end
        callback(dataMap[2])      
     end)
end

function ArenaModel:getCurrentArenaDetail(callback)
    self:getUserArenaInfo(function(dataMap)
        if type(callback) == "function" then
            callback(dataMap, 'userArena')
        end     
        self:getMatchInfoByMatchIDFromReq(dataMap.nMatchID, function(theMatchInfo)
            if type(callback) == "function" then
                callback(theMatchInfo, 'arenaInfo')
            end 
        end)     
    end)
end

function ArenaModel:giveUp(myArenaData)
    self._requester:MR_ARENA_REQ_GIVEUP(myArenaData.nMatchID, function(respondType, data, msgType, dataMap)
        if respondType ~= mc.UR_OPERATE_SUCCEED then
            print("sorry,GiveUp Failed!")
            my.stopProcessing()
            return
        elseif dataMap and dataMap.nError < 0 then
            my.informPluginByName({pluginName = 'TipPlugin',params={tipString = dataMap.szDes, removeTime = 1}})
            my.stopProcessing()
        else --放弃成功，需要重新获得我的信息
            self:getUserArenaInfo(function(dataMap)
                my.stopProcessing()
                self:dispatchEvent({name = ArenaModel.EVENT_MAP["arenaModel_userArenaInfoUpdatedByGiveUp"]})
            end)
        end
     end)
end

function ArenaModel:setMyArenaData(data)
    self.userArenaData = data
    ArenaDataSet:setData("ArenaUserInfo", self.userArenaData) --存入公共类，供外部使用
end



--AssistSvr通信
function ArenaModel:sendSignUpArenaRank()
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local SIGN_UP_ARENA_RANK = ArenaReq["SIGN_UP_ARENA_RANK"]
    local data     = {
        nUserID = playerInfo.nUserID,
        szUserName = playerInfo.szUsername,
        nSex = playerInfo.nNickSex
    }
    local pData = treepack.alignpack(data, SIGN_UP_ARENA_RANK)
    AssistModel:sendData(ArenaDef.ASSIT_SIGN_UP_ARENA_RANK, pData)
end

function ArenaModel:sendGetArenaRankState()
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local GET_ARENA_RANK_STATE = ArenaReq["GET_INFO_WITH_USERID"]
    local data     = {
        nUserID = playerInfo.nUserID
    }
    local pData = treepack.alignpack(data, GET_ARENA_RANK_STATE)
    
    --  ASSIT_GET_ARENA_RANK_STATE 是竞技场老排行榜使用
    --self._client:sendData(ArenaDef.ASSIT_GET_ARENA_RANK_STATE, pData)
    -- 2018年10月31日 ASSIT_GET_ARENA_WEEK_RANK_LIST 竞技场新本周排行榜使用。不需要报名，对局即入榜。领奖发邮件领取
    AssistModel:sendData(ArenaDef.ASSIT_GET_ARENA_WEEK_RANK_LIST, pData)
end

-- 新接口，用于从老的sql数据库搬迁 该玩家积分到 新的redis数据库。客户端缓存控制是否发该消息搬迁
function ArenaModel:sendMoveMyArenaRankData()

    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local MOVE_MY_ARENA_RANK_DATA = ArenaReq["REQ_MOVE_ARENA_USER_SCORE"]
    local data     = {
        nUserID = playerInfo.nUserID,
        szUserName = playerInfo.szUsername,
        nSex = playerInfo.nNickSex
    }
    local pData = treepack.alignpack(data, MOVE_MY_ARENA_RANK_DATA)
    
    AssistModel:sendData(ArenaDef.ASSIT_MOVE_MY_ARENA_RANK_DATA, pData)
end

function ArenaModel:sendGetArenaRankRewardList()
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local GET_ARENA_RANK_REWARD_LIST = ArenaReq["GET_ARENA_RANK_REWARD_LIST"]
    local data     = {
        nUserID = playerInfo.nUserID
    }
    local pData = treepack.alignpack(data, GET_ARENA_RANK_REWARD_LIST)
    AssistModel:sendData(ArenaDef.ASSIT_GET_ARENA_RANK_REWARD_LIST, pData)
end 

function ArenaModel:sendGetArenaRankMatchConfig()
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local GET_ARENA_RANK_MATCH_CONFIG = ArenaReq["GET_ARENA_RANK_REWARD_LIST"]
    local data     = {
        nUserID = playerInfo.nUserID
    }
    local pData = treepack.alignpack(data, GET_ARENA_RANK_MATCH_CONFIG)
    AssistModel:sendData(ArenaDef.ASSIT_GET_ARENA_RANK_MATCH_CONFIG, pData)
end

function ArenaModel:sendTakeArenaRankReward()
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <= 0 then 
        return 
    end

    local TAKE_ARENA_RANK_REWARD = ArenaReq["TAKE_ARENA_RANK_REWARD"]
    local data     = {
        nUserID = playerInfo.nUserID,
        szUserName = playerInfo.szUsername
    }
    local pData = treepack.alignpack(data, TAKE_ARENA_RANK_REWARD)
    AssistModel:sendData(ArenaDef.ASSIT_TAKE_ARENA_RANK_REWARD, pData)
end

--竞技场排行榜模块
function ArenaModel:deformatArenaRankInfo(data)
    local arenaRankInfoFormatStruct = ArenaReq["ARENA_RANK_INFO"]
    local arenaRankInfo = treepack.unpack(data, arenaRankInfoFormatStruct)
    dump(arenaRankInfo)

    if UserModel.nUserID ~= arenaRankInfo.nUserID then
        return nil
    end    

    arenaRankInfo.stSingleRankInfos = {}
    local singleInfoFormatStruct = ArenaReq["SINGLE_RANK_INFO"]
    for i = 1, arenaRankInfo.nRealCount do        
        local singleData = string.sub(data, arenaRankInfoFormatStruct.maxsize + (i - 1) * singleInfoFormatStruct.maxsize + 1)
        local singleInfo = treepack.unpack(singleData, singleInfoFormatStruct)
        table.insert(arenaRankInfo.stSingleRankInfos, singleInfo)
    end
    --dump(arenaRankInfo.stSingleRankInfos)
    dump(arenaRankInfo)

    return arenaRankInfo
end

function ArenaModel:onSignUpArenaRank(data)
    local arenaRankInfo = self:deformatArenaRankInfo(data)
    if arenaRankInfo then
        arenaRankData:onSignUpOK(arenaRankInfo)
    end        
end

function ArenaModel:onGetArenaRankState(data)
    local arenaRankInfo = self:deformatArenaRankInfo(data)
    if arenaRankInfo then
        arenaRankData:onGetRankInfoOK(arenaRankInfo)
    end
end

function ArenaModel:onGetArenaRankRewardList(data)
    local rewardListFormatStruct = ArenaReq["ARENA_RANK_REWARD_LIST"]
    local rewardList = treepack.unpack(data, rewardListFormatStruct)
    dump(rewardList)

    if UserModel.nUserID ~= rewardList.nUserID then
        return nil
    end    

    rewardList.stListItem = {} --不同排名区间
    local listItemFormatStruct = ArenaReq["ARENA_RANK_REWARD_LIST_ITEM"]
    for i = 1, rewardList.nRealCount do        
        local listItemData = string.sub(data, rewardListFormatStruct.maxsize + (i - 1) * listItemFormatStruct.realSize + 1)
        local listItem = treepack.unpack(listItemData, listItemFormatStruct)
        listItem.stReward = {} --本排名区间的奖励
        local rewardItemFormatStruct = ArenaReq["ARENA_RANK_REWARD_ITEM"]
        for j = 1, listItem.nRealCount do        
            local rewardData = string.sub(listItemData, listItemFormatStruct.maxsize + (j - 1) * rewardItemFormatStruct.maxsize + 1)
            local reward = treepack.unpack(rewardData, rewardItemFormatStruct)            
            table.insert(listItem.stReward, reward)
        end
        dump(listItem)
        table.insert(rewardList.stListItem, listItem)
    end 
    dump(rewardList)

    arenaRankData:onGetRewardListOK(rewardList)
end

function ArenaModel:onGetArenaRankMatchConfig(data)
    local json = cc.load("json").json
    if string.len(data)>0 then
        local config = cc.load("json").json.decode(data)
        config = checktable(config)
        if config then
            arenaRankData:setMatchConfig(config)
        end
    end
end
function ArenaModel:onTakeArenaRankReward(data)
    local arenaRankRewardFormatStruct = ArenaReq["ARENA_RANK_REWARD"]
    local arenaRankReward = treepack.unpack(data, arenaRankRewardFormatStruct)
    dump(arenaRankReward)

    if UserModel.nUserID ~= arenaRankReward.nUserID then
        return nil
    end    

    arenaRankReward.stReward = {}
    local arenaRankRewardItemFormatStruct = ArenaReq["ARENA_RANK_REWARD_ITEM"]
    for i = 1, arenaRankReward.nRealCount do        
        local rewardItemData = string.sub(data, arenaRankRewardFormatStruct.maxsize + (i - 1) * arenaRankRewardItemFormatStruct.maxsize + 1)
        local rewardItem = treepack.unpack(rewardItemData, arenaRankRewardItemFormatStruct)
        table.insert(arenaRankReward.stReward, rewardItem)
    end
    dump(arenaRankReward.stReward)
    dump(arenaRankReward)
    
    arenaRankTakeRewardModel:onGetDataOK(arenaRankReward)    
end

function ArenaModel:onDiffArenaRank(data)
    local diffArenaRankInfo = ArenaReq["DIFF_ARENA_INFO"]
    local diffArenaRankData = treepack.unpack(data, diffArenaRankInfo)
    dump(diffArenaRankData)

    self:dispatchEvent({name = ArenaModel.EVENT_MAP["ARENA_USER_RANKUP"], value = diffArenaRankData})
end

function ArenaModel:onGetArenaMoveScoreResp(data)
    local moveScoreResp = ArenaReq["MOVE_ARENA_USER_SCORE_RESP"]
    local moveScoreResp = treepack.unpack(data, moveScoreResp)
    dump(moveScoreResp)
    -- 迁移竞技场积分有响应，就可以写缓存。
    -- moveScoreResp.nMoveOK: 0 不予迁移， 1 迁移成功
    if moveScoreResp and moveScoreResp.nMoveOK then
        arenaRankData:setMoveFlagToCache(moveScoreResp.nMoveOK)
        if 1 == moveScoreResp.nMoveOK then
            -- 迁移成功则去获取一遍列表，保证刷新成功
            self:sendGetArenaRankState()
        end
    end
end

return ArenaModel
