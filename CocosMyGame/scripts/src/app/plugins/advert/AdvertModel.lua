local AdvertModel       = class("AdvertModel", require('src.app.GameHall.models.BaseModel'))
local AdvertDefine      = import('src.app.plugins.advert.AdvertDefine')
local AssistModel       = mymodel('assist.AssistModel'):getInstance()
local treepack          = cc.load('treepack')
local user              = mymodel('UserModel'):getInstance()
local player            = mymodel('hallext.PlayerModel'):getInstance()
local UserModel         = mymodel('UserModel'):getInstance()
local DeviceModel       = mymodel("DeviceModel"):getInstance()
local PropertyBinder    = cc.load('coms').PropertyBinder

my.addInstance(AdvertModel)
my.setmethods(AdvertModel, PropertyBinder)

protobuf.register_file('src/app/plugins/advert/pbAdvert.pb')

local AdSdkRetType = {
  ADSDK_RET_LOADAD_SUCCESS      = 1,    -- 广告加载成功
  ADSDK_RET_LOADAD_FAIL         = 2,    -- 广告加载失败
  ADSDK_RET_SHOWAD_SUCCESS      = 3,    -- 广告展示成功
  ADSDK_RET_AD_CLICKED          = 4,    -- 广告被有效点击，跳转详细页面
  ADSDK_RET_AD_CLOSED           = 5,    -- 广告被用户点击关闭
  ADSDK_RET_AD_VIDEOPLAY        = 6,    -- 视频广告开始播放
  ADSDK_RET_AD_VIDEOCOMPLETE    = 7,    -- 视频广告播放完成
  ADSDK_RET_AD_VIDEOPLAYERROR   = 8,    -- 视频广告播放出错?
  ADSDK_RET_AD_VIDEOSTOP        = 9,    -- 视频广告停止播放
  ADSDK_RET_AD_DIMISS           = 10,   -- 广告DISMISS
  ADSDK_RET_AD_NOT_SUPPORT      = 11,   -- 不支持当前广告
}

local AdSdkAdType = {
    TYPE_BANNER         = 1,    -- banner广告
    TYPE_INTERSTITIAL   = 2,    -- 插屏广告
    TYPE_RWD            = 3,    -- 视频广告
}

local NetworkName = {
    [0] = "无网络",
    [1] = "2G",
    [2] = "3G",
    [3] = "wifi",
    [4] = "4G",
    [5] = "未知类型",
}

AdvertModel.AdSdkRetType = AdSdkRetType

function AdvertModel:onCreate()
    self:initAssistResponse()
    --self:TestReportLog()
end

function AdvertModel:initAssistResponse()
    self._assistResponseMap = {
        
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

-- 是否需要显示banner广告 
function AdvertModel:isNeedShowBanner()
    if not cc.exports.isAdverSupported() then
        return false
    end

    local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local bOpen, bUnlock, nLevel = NobilityPrivilegeModel:isAdverFree()
    if bOpen and bUnlock then
        return false
    end

    return true
end

-- 显示banner广告
function AdvertModel:showBannerAdvert()
    print("enter showBannerAdvert ")
    local AdPlugin = plugin.AgentManager:getInstance():getAdsPlugin()
    if not AdPlugin then return end

    local nAdvertType = AdSdkAdType.TYPE_BANNER

    AdPlugin:setCallback(function(code, msg, err)
        print('showBannerAdvert AdsCallback--------------')
        print("code="..tostring(code).."msg="..tostring(msg).."err="..tostring(err))
        if code == AdSdkRetType.ADSDK_RET_LOADAD_SUCCESS then   -- 广告加载成功
            print('showChannelAd')
            --self:gc_ReportInterstitialAdvertLog(0, code)
        elseif code == AdSdkRetType.ADSDK_RET_SHOWAD_SUCCESS then -- 广告展示成功
            print('banner showed')
            --self:gc_ReportInterstitialAdvertLog(0, code)
        elseif code == AdSdkRetType.ADSDK_RET_AD_CLOSED then -- 广告被用户点击关闭
            print('banner closed')
            --self:gc_ReportInterstitialAdvertLog(0, code)
        elseif code == AdSdkRetType.ADSDK_RET_AD_CLICKED then -- 广告被用户点击
            print('banner click')
            --self:gc_ReportInterstitialAdvertLog(0, code)
        elseif code == AdSdkRetType.ADSDK_RET_LOADAD_FAIL then -- 广告加载失败
            print('banner load fail')
            --self:gc_ReportInterstitialAdvertLog(0, code)
        elseif code == AdSdkRetType.ADSDK_RET_AD_DIMISS then -- 广告DIMISS
            print('banner ADSDK_RET_AD_DIMISS')
            --self:gc_ReportInterstitialAdvertLog(0, code)
        elseif code == AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then -- 不支持当前广告
            print('banner ADSDK_RET_AD_NOT_SUPPORT')
            --self:gc_ReportInterstitialAdvertLog(0, code)
        end
    end)
    if AdPlugin.loadChannelAd then
        print('loadChannelAd')
        AdPlugin:loadChannelAd(nAdvertType, {})
    end
    if AdPlugin.showChannelAd then
        print('showChannelAd')
        AdPlugin:showChannelAd(nAdvertType, {})
    end
end

-- 隐藏banner广告
function AdvertModel:hideBannerAdvert()
    print('AdvertModel:hideBannerAdvert')
    local AdPlugin = plugin.AgentManager:getInstance():getAdsPlugin()
    if not AdPlugin then return end
    if AdPlugin.destroyChannelAd then
        AdPlugin:destroyChannelAd(AdSdkAdType.TYPE_BANNER, {})
    end
end

-- 显示插屏广告
function AdvertModel:showInterstitialAdvert(scene)
    print("enter showInterstitialAdvert ")
    local AdPlugin = plugin.AgentManager:getInstance():getAdsPlugin()
    if not AdPlugin then return end

    local nAdvertType = AdSdkAdType.TYPE_INTERSTITIAL

    AdPlugin:setCallback(function(code, msg, err)
        print('showInterstitialAdvert AdsCallback--------------')
        print("code="..tostring(code).."msg="..tostring(msg).."err="..tostring(err))
        if code == AdSdkRetType.ADSDK_RET_LOADAD_SUCCESS then       -- 广告加载成功
            if AdPlugin.showChannelAd then
                print('showChannelAd')
                AdPlugin:showChannelAd(nAdvertType, {})
            end
            self:gc_ReportInterstitialAdvertLog(scene, code)
        elseif code == AdSdkRetType.ADSDK_RET_SHOWAD_SUCCESS then   -- 广告展示成功
            print('interstitial showed')
            self:gc_ReportInterstitialAdvertLog(scene, code)
        elseif code == AdSdkRetType.ADSDK_RET_AD_CLOSED then        -- 广告被用户点击关闭
            print('interstitial closed')
            self:gc_ReportInterstitialAdvertLog(scene, code)
        elseif code == AdSdkRetType.ADSDK_RET_AD_CLICKED then       -- 广告被用户点击
            print('interstitial click')
            self:gc_ReportInterstitialAdvertLog(scene, code)
        elseif code == AdSdkRetType.ADSDK_RET_LOADAD_FAIL then      -- 广告加载失败
            print('interstitial load fail')
            self:gc_ReportInterstitialAdvertLog(scene, code)
        elseif code == AdSdkRetType.ADSDK_RET_AD_DIMISS then        -- 广告DIMISS
            print('interstitial ADSDK_RET_AD_DIMISS')
            self:gc_ReportInterstitialAdvertLog(scene, code)
        elseif code == AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then   -- 不支持当前广告
            print('interstitial ADSDK_RET_AD_NOT_SUPPORT')
            self:gc_ReportInterstitialAdvertLog(scene, code)
        end
    end)
    if AdPlugin.loadChannelAd then
        print('loadChannelAd')
        AdPlugin:loadChannelAd(nAdvertType, {})
    end
    if AdPlugin.showChannelAd then
        print('showChannelAd')
        AdPlugin:showChannelAd(nAdvertType, {})
    end
end

-- 是否需要显示插屏广告
function AdvertModel:isNeedShowInterstitial(scene)
    -- 校验广告是否开启
    if not cc.exports.isAdverSupported() then
        return false
    end

    -- 校验该场景插屏广告是否开启
    if not self:getInterVdSupport(scene) then
        return false
    end

    -- 校验该场景插屏广告次数是否到达上限
    if self:getInterVdLimit(scene) >= 0 then
        local useCount = CacheModel:getCacheByKey("InterVdLimitCount" .. tostring(user.nUserID) .. tostring(scene))
        local lastDate = CacheModel:getCacheByKey("InterVdLimitDate" .. tostring(user.nUserID) .. tostring(scene))
        local curDate = os.date('%Y%m%d',os.time())
        if curDate == lastDate then
            if toint(useCount) >= toint(self:getInterVdLimit(scene)) then
                return false
            end
        else
            CacheModel:saveInfoToUserCache("InterVdLimitCount" .. tostring(user.nUserID) .. tostring(scene), 0)
            CacheModel:saveInfoToUserCache("InterVdLimitDate" .. tostring(user.nUserID) .. tostring(scene), curDate)
        end
    end

    -- 校验该场景插屏广告是否有概率限制
    if self:getInterVdPro(scene) >= 0 then
        math.randomseed(os.time())
        local pro = math.random(0, 100)
        if pro > self:getInterVdPro(scene) then
            return false
        end
    end

    -- 校验该场景插屏广告是否有局数限制
    if self:getAdverInterBout(scene) >= 0 then
        if user.nBout and user.nBout <= self:getAdverInterBout(scene) then
            return false
        end
    end

    -- 校验是否达到贵族免广告
    local NobilityPrivilegeModel    = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local bOpen, bUnlock, nLevel    = NobilityPrivilegeModel:isAdverFree()
    if bOpen and bUnlock then
        return false
    end

    return true
end

-- 增加插屏广告不同场景观看次数
function AdvertModel:addInterVdShowCount(scene, count)
    local useCount = CacheModel:getCacheByKey("InterVdLimitCount" .. tostring(user.nUserID) .. tostring(scene))
    local lastDate = CacheModel:getCacheByKey("InterVdLimitDate" .. tostring(user.nUserID) .. tostring(scene))
    local curDate = os.date('%Y%m%d',os.time())
    if curDate == lastDate then
        if useCount and toint(useCount) > 0 then
            local countLast = toint(count) + toint(useCount)
            CacheModel:saveInfoToUserCache("InterVdLimitCount" .. tostring(user.nUserID) .. tostring(scene), countLast)
        else
            CacheModel:saveInfoToUserCache("InterVdLimitCount" .. tostring(user.nUserID) .. tostring(scene), count)
        end
    else
        CacheModel:saveInfoToUserCache("InterVdLimitCount" .. tostring(user.nUserID) .. tostring(scene), count)
    end

    CacheModel:saveInfoToUserCache("InterVdLimitDate" .. tostring(user.nUserID) .. tostring(scene), curDate)
end

-- 获取插屏广告不同场景开关
function AdvertModel:getInterVdSupport(scene)
    local supportScenes = cc.exports.getAdverInterScene()
    if supportScenes and supportScenes[tostring(scene)] then
        return supportScenes[tostring(scene)] > 0 or false
    else
        return false
    end
end

-- 获取插屏广告不同场景次数限制
function AdvertModel:getInterVdLimit(scene)
    local limits = cc.exports.getAdverInterLimit()
    if limits and limits[tostring(scene)] then
        return limits[tostring(scene)]
    else
        return -1
    end
end

-- 获取插屏广告不同场景触发概率
function AdvertModel:getInterVdPro(scene)
    local Probabilitys = cc.exports.getAdverInterPro()
    if Probabilitys and Probabilitys[tostring(scene)] then
        return Probabilitys[tostring(scene)]
    else
        return -1
    end
end

-- 获取插屏广告不同场景局数要求
function AdvertModel:getAdverInterBout(scene)
    local bouts = cc.exports.getAdverInterBout()
    if bouts and bouts[tostring(scene)] then
        return bouts[tostring(scene)]
    else
        return -1
    end
end

-- 获取插屏广告不同场景停留时长
function AdvertModel:getInterVdStandingTime(scene)
    local standTimes = cc.exports.getAdverInterStandTime()
    if standTimes and standTimes[tostring(scene)] then
        return standTimes[tostring(scene)]
    else
        return 0
    end
end

function AdvertModel:ReportInterstitialAdvertLog(scene, code)
    local curDate = os.date("%Y-%m-%d", os.time())
    local curTime = os.date("%H:%M:%S", os.time())
    local userID = user.nUserID
    local recommenderID = BusinessUtils:getInstance():getRecommenderId()
    local roomID = 0
    if scene == AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE 
    or scene == AdvertDefine.INTERSTITIAL_AUTO_PLAY_SCORE 
    or scene == AdvertDefine.INTERSTITIAL_AUTO_PLAY_PRIMARY_DEPOSIT then
        local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
        if roomInfo and roomInfo.nRoomID and type(roomInfo.nRoomID) == "number" then
            roomID = roomInfo.nRoomID
        end
        
    end
    local adID = scene
    local adName = "INTERSTITIAL_STAND_HALL"
    if scene == AdvertDefine.INTERSTITIAL_STAND_HALL then
        adName = "INTERSTITIAL_STAND_HALL"
    elseif scene == AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE then        
        adName = "INTERSTITIAL_THROW_OVER_SCORE"
    elseif scene == AdvertDefine.INTERSTITIAL_GAME_TO_HALL_SCORE then
        adName = "INTERSTITIAL_GAME_TO_HALL_SCORE"
    elseif scene == AdvertDefine.INTERSTITIAL_GAME_TO_HALL_PRIMARY_DEPOSIT then
        adName = "INTERSTITIAL_GAME_TO_HALL_PRIMARY_DEPOSIT"
    elseif scene == AdvertDefine.INTERSTITIAL_AUTO_PLAY_SCORE then
        adName = "INTERSTITIAL_AUTO_PLAY_SCORE"
    elseif scene == AdvertDefine.INTERSTITIAL_AUTO_PLAY_PRIMARY_DEPOSIT then
        adName = "INTERSTITIAL_AUTO_PLAY_PRIMARY_DEPOSIT"
    end

    local adSource = my.getSelfSdkName()
    local adType = AdSdkAdType.TYPE_INTERSTITIAL
    local opeType = "ADSDK_RET_SHOWAD_SUCCESS"
    if code == AdSdkRetType.ADSDK_RET_SHOWAD_SUCCESS then       -- 广告展示成功
        opeType = "ADSDK_RET_SHOWAD_SUCCESS"
    elseif code == AdSdkRetType.ADSDK_RET_AD_CLOSED then        -- 广告被用户点击关闭
        opeType = "ADSDK_RET_AD_CLOSED"
    elseif code == AdSdkRetType.ADSDK_RET_AD_CLICKED then       -- 广告被用户点击
        opeType = "ADSDK_RET_AD_CLICKED"
    elseif code == AdSdkRetType.ADSDK_RET_LOADAD_FAIL then      -- 广告加载失败
        opeType = "ADSDK_RET_LOADAD_FAIL"
    elseif code == AdSdkRetType.ADSDK_RET_AD_DIMISS then        -- 广告DIMISS
        opeType = "ADSDK_RET_AD_DIMISS"
    elseif code == AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then   -- 不支持当前广告
        opeType = "ADSDK_RET_AD_NOT_SUPPORT"
    end

    local eventName = "InterAdLog"
    local eventMap = {}
    eventMap.Date = curDate
    eventMap.Time = curTime
    eventMap.Userid = userID
    eventMap.Channel = recommenderID
    eventMap.Roomid = roomID
    eventMap.AdID = adID
    eventMap.AdName = adName
    eventMap.AdSource = adSource
    eventMap.AdType = adType
    eventMap.OpeType = opeType
    my.dataLink(cc.exports.DataLinkCodeDef.INTER_AD_LOG, eventMap)
end

function AdvertModel:gc_ReportInterstitialAdvertLog(scene, code)
    local curDate = os.date("%Y-%m-%d", os.time())
    local curTime = os.date("%H:%M:%S", os.time())
    local playerID = user.nUserID
    local recommenderID = BusinessUtils:getInstance():getRecommenderId()
    local curRoomID = 0
    if scene == AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE 
    or scene == AdvertDefine.INTERSTITIAL_AUTO_PLAY_SCORE 
    or scene == AdvertDefine.INTERSTITIAL_AUTO_PLAY_PRIMARY_DEPOSIT 
    or scene == 0 then
        local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
        if roomInfo and roomInfo.nRoomID and type(roomInfo.nRoomID) == "number" then
            curRoomID = roomInfo.nRoomID
        end
        
    end
    local adID = scene
    local adName = "INTERSTITIAL_STAND_HALL"
    if scene == AdvertDefine.INTERSTITIAL_STAND_HALL then
        adName = "INTERSTITIAL_STAND_HALL"
    elseif scene == AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE then        
        adName = "INTERSTITIAL_THROW_OVER_SCORE"
    elseif scene == AdvertDefine.INTERSTITIAL_GAME_TO_HALL_SCORE then
        adName = "INTERSTITIAL_GAME_TO_HALL_SCORE"
    elseif scene == AdvertDefine.INTERSTITIAL_GAME_TO_HALL_PRIMARY_DEPOSIT then
        adName = "INTERSTITIAL_GAME_TO_HALL_PRIMARY_DEPOSIT"
    elseif scene == AdvertDefine.INTERSTITIAL_AUTO_PLAY_SCORE then
        adName = "INTERSTITIAL_AUTO_PLAY_SCORE"
    elseif scene == AdvertDefine.INTERSTITIAL_AUTO_PLAY_PRIMARY_DEPOSIT then
        adName = "INTERSTITIAL_AUTO_PLAY_PRIMARY_DEPOSIT"
    else
        adName = "BANNER_ADVERT"
    end    

    local adSource = my.getSelfSdkName()
    local advertType = AdSdkAdType.TYPE_INTERSTITIAL
    if scene == 0 then
        advertType = AdSdkAdType.TYPE_BANNER
    end
    local operateType = "ADSDK_RET_SHOWAD_SUCCESS"

    if code == AdSdkRetType.ADSDK_RET_LOADAD_SUCCESS then       -- 广告加载成功
        operateType = "ADSDK_RET_LOADAD_SUCCESS"
    elseif code == AdSdkRetType.ADSDK_RET_LOADAD_FAIL then      -- 广告加载失败
        operateType = "ADSDK_RET_LOADAD_FAIL"
    elseif code == AdSdkRetType.ADSDK_RET_SHOWAD_SUCCESS then   -- 广告展示成功
        operateType = "ADSDK_RET_SHOWAD_SUCCESS"
    elseif code == AdSdkRetType.ADSDK_RET_AD_CLICKED then       -- 广告被用户点击
        operateType = "ADSDK_RET_AD_CLICKED"
    elseif code == AdSdkRetType.ADSDK_RET_AD_CLOSED then        -- 广告被用户点击关闭
        operateType = "ADSDK_RET_AD_CLOSED"
    elseif code == AdSdkRetType.ADSDK_RET_AD_VIDEOPLAY then     -- 视频广告开始播放
        operateType = "ADSDK_RET_AD_VIDEOPLAY"
    elseif code == AdSdkRetType.ADSDK_RET_AD_VIDEOCOMPLETE then -- 视频广告播放完成
        operateType = "ADSDK_RET_AD_VIDEOCOMPLETE"
    elseif code == AdSdkRetType.ADSDK_RET_AD_VIDEOPLAYERROR then-- 视频广告播放出错
        operateType = "ADSDK_RET_AD_VIDEOPLAYERROR"
    elseif code == AdSdkRetType.ADSDK_RET_AD_VIDEOSTOP then     -- 视频广告停止播放
        operateType = "ADSDK_RET_AD_VIDEOSTOP"
    elseif code == AdSdkRetType.ADSDK_RET_AD_DIMISS then        -- 广告DIMISS
        operateType = "ADSDK_RET_AD_DIMISS"
    elseif code == AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then   -- 不支持当前广告
        operateType = "ADSDK_RET_AD_NOT_SUPPORT"
    end

    local data = {
        userID = playerID,
        channel = recommenderID,
        roomID = curRoomID,
        sceneID = adID,
        sceneName = adName,
        sdkName = adSource,
        adType = advertType,
        opeType = operateType,
        strDate = curDate,
        strTime = curTime
    }
    local pdata = protobuf.encode('pbAdvert.AdvertLog', data)
    AssistModel:sendData(AdvertDefine.GR_ADVERT_LOG_MSG, pdata, false)
end

function AdvertModel:TestReportLog()
    my.createSchedule(function()
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_LOADAD_SUCCESS)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_LOADAD_FAIL)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_SHOWAD_SUCCESS)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_AD_CLICKED)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_AD_CLOSED)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_AD_VIDEOPLAY)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_AD_VIDEOCOMPLETE)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_AD_VIDEOPLAYERROR)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_AD_VIDEOSTOP)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_AD_DIMISS)
        self:gc_ReportInterstitialAdvertLog(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT)
    end, 1)
end
--[广告插件 end]

function AdvertModel:ShowVideoAd(callback)
    print("enter ShowVideoAd...")
    local AdPlugin = plugin.AgentManager:getInstance():getAdsPlugin()
    if not AdPlugin then 
        return 
    end
    if type(callback) ~= 'function' then
        callback = function (code, msg ) end
    end

    local nAdvertType = AdSdkAdType.TYPE_RWD

    AdPlugin:setCallback(function(code, msg, err)
        print('ShowVideoAd AdsCallback--------------')
        print("code="..tostring(code).."msg="..tostring(msg).."err="..tostring(err))
        if code == AdSdkRetType.ADSDK_RET_LOADAD_SUCCESS then       -- 广告加载成功
            print("[INFO] video load successfully...")
        elseif code == AdSdkRetType.ADSDK_RET_SHOWAD_SUCCESS then   -- 广告展示成功
            print("[INFO] video show successfully...")
        elseif code == AdSdkRetType.ADSDK_RET_AD_CLOSED then        -- 广告被用户点击关闭
            print("[INFO] video closed...")
        elseif code == AdSdkRetType.ADSDK_RET_AD_CLICKED then       -- 广告被用户点击
            print("[INFO] video clicked...")
        elseif code == AdSdkRetType.ADSDK_RET_LOADAD_FAIL then      -- 广告加载失败
            print("[INFO] video load failed...")
        elseif code == AdSdkRetType.ADSDK_RET_AD_DIMISS then        -- 广告DIMISS
            print("[INFO] video dismiss...")
        elseif code == AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then   -- 不支持当前广告
            print("[INFO] video not-support...")
        end
        if type(callback) == 'function' then
            callback(code, msg)
        end
    end)
    local params = {
        appid = "1104905608",
        posID = "7041065725869389"
    }
    if AdPlugin.loadChannelAd then
        print('loadChannelAd')
        AdPlugin:loadChannelAd(nAdvertType, params)
    else
        print("[ERROR] No loadChannelAd function...")
        return
    end
    if AdPlugin.showChannelAd then
        print('showChannelAd')
        AdPlugin:showChannelAd(nAdvertType, params)
    else 
        print("[ERROR] No showChannelAd function...")
        return
    end  
end

return AdvertModel