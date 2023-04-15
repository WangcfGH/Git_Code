local ArenaRankTotalModel = class("ArenaRankTotalModel")
local User = mymodel('UserModel'):getInstance()
local ArenaModel = require("src.app.plugins.arena.ArenaModel"):getInstance()

my.addInstance(ArenaRankTotalModel)

local event = cc.load('event')
event:create():bind(ArenaRankTotalModel)

ArenaRankTotalModel.RANK_BEGIN = 1
ArenaRankTotalModel.RANK_COUNT = 100

ArenaRankTotalModel.REQ_RANK_LIST = "REQ_RANK_LIST"
ArenaRankTotalModel.REQ_MY_RANK_INFO = "REQ_MY_RANK_INFO"

ArenaRankTotalModel.RANK_INFO_UPDATED = "RANK_INFO_UPDATED"

function ArenaRankTotalModel:ctor()
    self:resetData()    
end

function ArenaRankTotalModel:resetData()
    self._rankList = {}
    self._myRankInfo = {
        ["rank"] = 0,
        ["score"] = 0,
        ["isInRange"] = false
    }

    self._reqStatusCache = {
        ["rankList"] = false,
        ["myRankInfo"] = false
    }
end

function ArenaRankTotalModel:reqRankList()
    local function setRankList(...)
        local list = ...   
        dump(list)     
        local boy = 0 -- 0:boy, 1:girl
        for index, rankInfo in ipairs(list) do
            local insertItem = {}
            insertItem.rank = rankInfo.nRank
            insertItem.score = rankInfo.nAchievement
            insertItem.name = rankInfo.szUserName
            --insertItem.name = MCCharset:getInstance():gb2Utf8String(insertItem.name, string.len(insertItem.name))
            insertItem.sex = false
            if rankInfo.nNickSex == boy then
                insertItem.sex = true
            end            
            table.insert(self._rankList, insertItem)
        end      
        
        self:updateReqStatus(ArenaRankTotalModel.REQ_RANK_LIST)
    end

    ArenaModel:getRank(ArenaRankTotalModel.RANK_BEGIN, ArenaRankTotalModel.RANK_COUNT, setRankList)
end

function ArenaRankTotalModel:reqMyRankInfo()
    local function setRank(...)
        local rankInfo = ...  
        dump(rankInfo)
        self._myRankInfo["rank"] = rankInfo.nUserRank

        --由排名获得对应分数
        local function setScore(...)
            local list = ...   
            dump(list)     
            for index, rankInfo in ipairs(list) do
                if rankInfo.nUserID == User.nUserID then
                    self._myRankInfo["score"] = rankInfo.nAchievement
                    --有些刚报名（nAchievement为0）的是不会在list中的
                    if self._myRankInfo["rank"] < ArenaRankTotalModel.RANK_BEGIN + ArenaRankTotalModel.RANK_COUNT then
                        self._myRankInfo["isInRange"] = true
                    end
                    break
                end
            end   
            self:updateReqStatus(ArenaRankTotalModel.REQ_MY_RANK_INFO)         
        end
        if self._myRankInfo["rank"] > 0 then
            ArenaModel:getRank(self._myRankInfo["rank"], 1, setScore)
        end   
    end

    ArenaModel:getMyRank(setRank)
end

function ArenaRankTotalModel:reqRankInfo()
    self:resetData()
    self:reqRankList()
    self:reqMyRankInfo()
end

function ArenaRankTotalModel:isAllReqBack()
    return self._reqStatusCache["myRankInfo"] and self._reqStatusCache["rankList"]
end

function ArenaRankTotalModel:resetAllReqStatus()
    self._reqStatusCache["rankList"]  = false
    self._reqStatusCache["myRankInfo"] = false
end

function ArenaRankTotalModel:updateReqStatus(name)
    if name == ArenaRankTotalModel.REQ_RANK_LIST then
        self._reqStatusCache["rankList"]  = true
    elseif name == ArenaRankTotalModel.REQ_MY_RANK_INFO then
        self._reqStatusCache["myRankInfo"] = true
    end

    if self:isAllReqBack() then 
        self:dispatchEvent({name = ArenaRankTotalModel.RANK_INFO_UPDATED}) 
        self:resetAllReqStatus()
    end
end

function ArenaRankTotalModel:getRankList()
    return self._rankList
end

function ArenaRankTotalModel:getMyRankInfo()
    return self._myRankInfo
end

return ArenaRankTotalModel