local NationalDayActivityModel = class('NationalDayActivityModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(NationalDayActivityModel)

local NationalDayActivityReq = import('src.app.plugins.NationalDayActivity.NationalDayActivityReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local NationalDayActivityDef = {
    GR_SEND_RANK_REQ            = 410017, -- 请求国庆活动排行信息

    GR_SEND_RANK_RESP           = 410018, -- 回复国庆活动排行信息
}

NationalDayActivityModel.REFRESH_ACT_RANK = "REFRESH_ACT_RANK"     --刷新活动排名
NationalDayActivityModel.EVENT_MAP = {
    ["topRank_pluginAvailChanged"] = "topRank_pluginAvailChanged"
}

function NationalDayActivityModel:onCreate()
    self._assistResponseMap = {
        [NationalDayActivityDef.GR_SEND_RANK_RESP] = handler(self, self.onDealRankInfo)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function NationalDayActivityModel:onReqRankInfo(rankType)
    local playerInfo = PublicInterface.GetPlayerInfo()
    local utf8Name = playerInfo.szUtf8Username
    local gb2Name = MCCharset:getInstance():utf82GbString(utf8Name, string.len(utf8Name))
    local data = {
        nUserID     = playerInfo.nUserID,
        nRankType   = rankType,
        szUserName  = gb2Name
    }
    local rankReqData = NationalDayActivityReq["RANK_REQ"]
    local pData = treepack.alignpack(data, rankReqData)
    AssistModel:sendData(NationalDayActivityDef.GR_SEND_RANK_REQ, pData)
end

function NationalDayActivityModel:onDealRankInfo(data)
    local json = cc.load("json").json
    local rankInfo = json.decode(data)
    local rankInfoData = clone(rankInfo)
    
    local rankType = tonumber(rankInfoData.type)
    if cc.exports._gameJsonConfig.NationalDaysActivityRank == nil then 
        cc.exports._gameJsonConfig.NationalDaysActivityRank = {}
    end
    cc.exports._gameJsonConfig.NationalDaysActivityRank[rankType+1] = rankInfoData
    my.scheduleOnce(function()
        self:dispatchEvent({name = self.REFRESH_ACT_RANK, value = rankType})
    end,0.5)
end

--缓存判断是否显示红点
--[[function NationalDayActivityModel:isNeedReddot()
    local dataMap
    local filename = "NationalDayActivity.xml"
    if false == my.isCacheExist(filename) then
        return true
    end

    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)

    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())

    local date = tmYear.."_"..tmMon.."_"..tmMday
    if date ~= dataMap.queryDate then
        return true
    end

    return false
end

function NationalDayActivityModel:saveNationalDayCacheData()
    local tmYear = os.date('%Y',os.time())
    local tmMon = os.date('%m',os.time())
    local tmMday = os.date('%d',os.time())
    local data = {}
    data.queryDate = tmYear.."_"..tmMon.."_"..tmMday
    local cacheFile = "NationalDayActivity"..".xml"
    my.saveCache(cacheFile,data)
end]]--

return NationalDayActivityModel