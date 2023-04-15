
local ConfigModelBase = import('src.app.GameHall.config.ConfigModelBase')
local AdditionConfigModel = class('AdditionConfigModel', ConfigModelBase)

AdditionConfigModel.EVENT_CONFIG_UPDATED = "config_updated"
my.addInstance(AdditionConfigModel)

local CONFIG_PATH       = 'res/hall/hallstrings/'
local CONFIG_NAME       = 'AdditionConfig.json'
local CONFIG_TYPE       = 2
local CONFIG_ID         = 'AdditionConfig'
local CONFIG_NAME_BAK   = 'AdditionConfig_%s.json'

local KEY_FUNCTIONS     = 'functions'
local KEY_SUPPORT       = 'support'
local KEY_ID            = 'ID'
local KEY_VERSION       = 'version'

AdditionConfigModel.ROOM_MATCH_TYPE_OLD    = 1
AdditionConfigModel.ROOM_MATCH_TYPE_NEW    = 2
AdditionConfigModel.ROOM_MATCH_TYPE_RANDOM = 3

AdditionConfigModel.FUNCTION_KEYS =
{
    KEY_DEPOSIT         = 'deposit',
    KEY_SCORE           = 'score',
    KEY_ACTIVITIES      = 'activities',
    KEY_SHARE           = 'share',
    KEY_GIFT_EXCHANGE   = 'giftexchange',
    KEY_SHARE_FOR_GIFT  = 'shareForGift',
    KEY_CHECKIN         = 'checkin',
    KEY_RELIEF          = 'relief',
    KEY_RELIEFSHOPITEMID= 'shopItemID',
    KEY_RELIEFLARGEPRICE= 'largerPrice',
    KEY_RELIEFSMALLPRICE= 'smallPrice',
    KEY_RELIEFLARGE     = 'largeExtraSilver',
    KEY_RELIEFSMALL     = 'smallExtraSilver',
    KEY_RELIEFSMALLHEJI = 'smallExtraSilverHeJi',
    KEY_RELIEFSLIVER    = 'reliefSilver',
    KEY_EXITGAME        = 'exitgame',
    KEY_SAFEBOX         = 'safebox',
    KEY_BACKBOX         = 'backbox',
    KEY_SHOP            = 'shop',
    KEY_EXCHANGE        = 'exchange',
    KEY_TONGBAO         = 'tongbao',
    KEY_VIP             = 'vip',
    KEY_FIRSTRECHARGE   = 'firstrecharge',
    KEY_LIMITTIMESPECIAL= 'limitTimeSpecial',
    KEY_SHOPTIP         = 'shoptip',
    KEY_BINDPHONE       = 'bindphone',
    KEY_MODIFYPHONE     = 'modifyphone',
    KEY_MODIFYNAME      = 'modifyname',
    KEY_MODIFYSEX       = 'modifysex',
    KEY_MODIFYPASSWORD  = 'modifypassword',
    KEY_ISSOCIAL        = 'issocial',
    KEY_ISYULEROOM      = 'isyueleroom',
    KEY_MOREGAME        = 'moregame',
    KEY_REALNAME        = 'realname',
    KEY_ANTIADDICTION   = 'antiaddiction',
    KEY_SWITCHACCOUNT   = 'switchaccount',
    KEY_SHOWLOGINWINDOWWHENFAILED = 'showloginwindowwhenfailed',
    KEY_QQSHOW          = 'qqshow',
    KEY_UPLOADHEADICON  = 'uploadheadicon',
    KEY_ROLLITEM        = 'rollitem',
    KEY_RANKING         = 'ranking',
    KEY_TASK            = 'task',
    KEY_USERITEMS       = 'useritems',
    KEY_HEALTHDESCRIPTION = 'healthdescription',
    KEY_COPYRIGHT       = 'copyright',
    KEY_SDKBALL         = 'sdkball',
    KEY_FRIEND          = 'friend',
    KEY_VERSIONCHECK    = 'versioncheck',
    KEY_ROOMCARD        = "roomcard",
    KEY_ROOMCARD_SHARELINK = "sharelink",
    KEY_ROOMCARD_CHARGE = "charge",
    KEY_NOVOICEGUIDE    = "novoiceguide",
    KEY_MODIFYNICKNAME  = "modifynickname",
    KEY_SOCIALROOM      = "socialroom",
    KEY_QQSTRING        = 'qqstring',
    KEY_WECHATFIRST     = "wechatfirst",
    KEY_LOGNETSTATUS    = "lognetstatus",
    KEY_GAMELOGUSERSTACk    = "gameloguserstack",    
    KEY_RANKMATCH       = "rankmatch",
    KEY_COUPON          = "coupon",
    KEY_PAYFORAA        = "aa",
    KEY_PAYFORBIGWIN    = "bigwin",
    KEY_IOSLOGSDK       = "ios_logsdk",
    KEY_ROOMCARD_CHARGENAME= "wechat_name",
    KEY_XXY_CHARGE      = "xxycharge",
    KEY_XXY_BINDCODE    = "bindcode",
    KEY_XXY_DOMAINRELEASE = "domain_release",
    KEY_XXY_DOMAINDEBUG = "domain_debug",
    KEY_AUTO_UPDATE_DBG_LOG = "auto_update_dbg_log",
    KEY_GAME_RECONNECT_COUNT_DBG_LOG = "game_reconnect_count",
    KEY_HALL_RECONNECT_TIME_DBG_LOG  = "hall_reconnect_time",
    KEY_INVITE_GIFT                  = "invitegift",
    KEY_GOOD_FRIEND_GIFT_INVITE_GIFT = "goodFriendGiftInviteGift",
    KEY_SETTING_3DMJ                 = "setting_3dmj",
    KEY_HEADERIMGLOG                 = "header_img_log",
    KEY_CLUB                         = "club",
    KEY_CLUB_ANNOUNCEMENT            = 'announcement',
    KEY_SWITCH_2DGAME_DIALOG         = "switch_2dgame_dialog",
    KEY_GOOD_LUCK_PROP               = "good_luck_prop",
    KEY_GOOD_LUCK_FREE_SHOW_GUIDE    = "good_luck_free_show_guide",
    KEY_CONSULT_ADJUST_CHAIRS        = "consult_adjust_chairs",
    KEY_ACCOUNT_SAFE         = "account_safe",
    KEY_NEWACTIVITY                  = "newactivity",
    KEY_ROOMCARD_DONATE              = "donate",
    KEY_RULE_TABS                    = "rulechoose_support_tabs",
    KEY_SUPPORT_TABS                 = "support_tabs",
    KEY_DWC                          = "dwc",
    KEY_FUSEMODEL                    = "mix_album",
    KEY_PANELSET                     = "panel_set",
    KEY_MOREGAMECONFIG               = "moregameconfig", 
    KEY_MOREGAMESET                  = "moregame_set",
    KEY_MOREGAMERECOMMAND            = 'recommand',
    KEY_MOREGAMEPANELTYPE            = 'panelType',
    KEY_MOREGAMEHALLENTRY            = 'hallentrypicurl',
    KEY_NOVICE_PACKS                 = "novicepacks",


    --自定义功能
    KEY_LIMITTIMEGIFT = "limitTimeGift",
    KEY_ACTIVITYCENTER = "activityCenter",
    KEY_MONTHCARD = "monthCard",
    KEY_WEEKCARD = "weekCard",
    KEY_WEEKMONTHSUPERCARD = "weekMonthSuperCard",
    KEY_NEWPLAYERGIFT = "newPlayerGift",
    KEY_TOPRANK = "topRank",
    KEY_RECHARGEACTIVITY = "rechargeActivity",
    KEY_PPL                 = "PPL",
    KEY_PPL_DEPOSITLIMIT    = "depositlimit",
    KEY_GOLDEGG = "goldegg",
    KEY_GOLDSILVER = "goldSilver",
    KEY_GOLDSILVER_COPY = "goldSilverCopy",
    KEY_OUTLAYGAME = "outlayGame",
    KEY_BOUTLIMIT = "boutLimit",
    KEY_LEGENDCOME = "legendCome",

    KEY_CUSTOMERSERVICE = "customerService",
    KEY_EXCHANGE_REALITEM = "realItem",
    KEY_EXCHANGE_PHONEFEE = "phoneFee",
    KEY_WINNINGSTREAK = "WinningStreak",
    KEY_WINNINGSTREAK_NEED_BOUT = "needbout",
    KEY_DEPOSITLIMIT            = "depositlimit",

    KEY_TELEPHONELABEL          = "telephonelabel",
    KEY_EXCHANGE_NUM            = "exchangenum",
    KEY_REDPACKET100            = "redpacket100",
    KEY_GOLDSILVER_TIPLEVEL     = "tiplevel",
    KEY_GOLDSILVER_TIPDAY       = "tipday",
    KEY_GOLDSILVER_TIPLEVEL_COPY= "tiplevelCopy",
    KEY_GOLDSILVER_TIPDAY_COPY  = "tipdayCopy",
    KEY_GOLDSILVERCOPY_START_DATE = "goldSilverCopyStartDate",
    KEY_GOLDSILVERCOPY_END_DATE  = "goldSilverCopyEndDate",
    KEY_NOBILITYPRIVILEGE       = "nobilityprivilege",
    KEY_NOBILITYPRIVILEGEGIFT       = "nobilityprivilegegift",
    KEY_LUCKYCAT                = "luckycat",
    KEY_ADVER                   = "adver",
    KEY_ADVERROOM               = "room",
    KEY_ADVERBOUT               = "bout",
    KEY_ADVERINTERSCENE         = "InterStitialScene",
    KEY_ADVERINTERLIMIT         = "InterStitialLimit",
    KEY_ADVERINTERPRO           = "InterStitialPro",
    KEY_ADVERINTERBOUT          = "InterStitiaBout",
    KEY_ADVERINTERTIME          = "InterStitiaStandTime",
    KEY_AUTOSUPPLY              = "autosupply",
    KEY_AUTOJUMPROOM            = "autoJumpRoom",
    KEY_NORMALROOM              = "normalroom",
    KEY_NOWASHROOM              = "nowashroom",
    KEY_DSRMD                   = "dashiroomdeposit",
    KEY_NWDSRMD                 = "nowashdashiroomdeposit",
    KEY_NORMALROOMSAFE          = "normalroomsafe",
    KEY_NOWASHROOMSAFE          = "nowashroomsafe",
    KEY_AUTOSUPPLY_SAVE         = "autosave",
    KEY_AUTOSUPPLYROOM          = "room",
    KEY_AUTOSUPPLYRATIO         = "ratio",
    KEY_AUTOSUPPLYDEPOSITLIMIT  = "depositlimit",
    KEY_QUICKSTART              = "quickstart",
    KEY_QUICKSTART_MATCHTYPE    = "matchtype",
    KEY_QUICKSTART_MATCHRANDOM  = "matchrandom",
    KEY_QUICKSTART_MATCHSET     = "roomdeposit_matchset",
	
	KEY_EXCHANGE_MAX            = "exchangemax",
    KEY_EXCHANGE_DEFAULT_COUNT  = "defaultcount",
    KEY_EXCHANGE_LIMIT_125      = "limit125",
    KEY_EXCHANGE_LIMIT_ZS       = "limitzs",

    KEY_EXCHANGE_LOTTERY        = "exchangelottery",
    KEY_BANKRUPTCY              = "bankruptcy",
    KEY_DAILY_RECHARGE          = "dailyrecharge",

    KEY_USE_MARK_WITHOUT        = "useMarkWithout",
    KEY_USE_MARK_JD             = "useMarkJd",
    KEY_HSOX_PAY                = "HSoxPay",
    KEY_TIMING_GAME             = "timingGame",
    KEY_TIMING_GAME_HALL_TIPS   = "hallTips",
    KEY_TIMING_GAME_ENTRY_TYPE  = "entryType",
    KEY_TIMING_GAME_FIEIDS      = "firstItemExchangeIDs",
    KEY_TIMING_GAME_BC_TIP      = "broadCastTip",
    KEY_TIMING_GAME_BC_RTIMES   = "broadCastRepeatTimes",
    KEY_TIMING_GAME_TICKET_ES   = "ticketEntranceSwitch",
    KEY_TIMING_GAME_TICKET_TASK_ES   = "ticketTaskEntranceSwitch",
    KEY_TIMING_GAME_GET_TICKET_WAY = "getTicketWay",
    KEY_TIMING_CHAO_GE_ROOM_BG  = "chaoGeRoomBg",
    KEY_TIMING_LONG_QI_ROOM_BG  = "longQiRoomBg",
    KEY_LUCKY_PACK              = "luckyPack",
    KEY_SPRINGFESTIVAL          = "SpringFestival",
    KEY_RECHARGE_POOL           = "rechargepool",   --超级大奖池
    KEY_PROMOTE_NUM_TIP         = "promoteNumTip",
    KEY_SPRING_FESTIVAL_VIEW    = "springFestivalView",
    KEY_SPRING_FESTIVAL_VIEW_START_DATE = "startDate",
    KEY_SPRING_FESTIVAL_VIEW_END_DATE = "endDate",
    KEY_AUTO_POP_COUNT          = "autoPopCount",
    KEY_AUTO_POP_NEWPLAYER      = "newPlayer",
    KEY_AUTO_POP_NOMARLPLAYER   = "nomarlPlayer",
    KEY_AUTO_DOUBLE_EXCHANGE    = "DoubleExchange",
    KEY_AUTO_DE_STARTDATE       = "DoubleExchangeStartDate",
    KEY_AUTO_DE_ENDDATE         = "DoubleExchangeEndDate",
    KEY_GUIDE_COMMENTS          = "GuideComments",
    KEY_GUIDE_COMMENTS_MIN_BOUT = "guideCommentsMinBout",
    KEY_GUIDE_COMMENTS_WS_BOUT  = "winningStreakBout",
    KEY_GUIDE_TIP               = "guideTip",
    KEY_GUIDE_VIVOVIPACTIVITY   = "VivoVipActivity",
    KEY_LOGIN_LOTTERY           = "loginlottery",
    KEY_HIDE_JUNIOR_ROOM        = "HideJuniorRoom",
    KEY_MERGE_HIDE_ROOM_ID      = "mergeHideRoomID",
    KEY_HIDE_ROOM_ID            = "HideRoomID",
    KEY_USER_COUNT_LIMIT        = "UserCountLimit",
    KEY_HALL_ANCHOR_INFO        = "HallAnchorInfo", 
    KEY_HALL_WEIXIN_TITLE       = "weixintitle",
    KEY_HALL_WEIXIN_NAME        = "weixinname",
    KEY_HALL_ANCHOR_POSTER      = "HallAnchorPoster",
    KEY_HALL_ANCHOR_POSTER_NUM  = "AnchorPosterNum",
    KEY_HALL_ANCHOR_POSTER_NAME = "AnchorPosterName",
    KEY_HALL_ANCHOR_POSTER_TIME = "AnchorPosterTime",
    KEY_HALL_ANCHOR_POSTER_URL  = "AnchorPosterUrl",
    KEY_HALL_ANCHOR_ID          = "AnchorID",
    KEY_HALL_ANCHOR_WECHAT_ID   = "WechatID",
    KEY_HALL_ANCHOR_ROOM                = "HallAnchorRoom",
    KEY_HALL_WARNNING_TIP               = "WarnningTip",
    KEY_HALL_ANCHOR_PLAYER_NUM          = "AnchorPlayerNum",
    KEY_HALL_ANCHOR_PLAYER_USE_TABLE_NO = "AnchorPlayerUseTableNO",
    KEY_HALL_ANCHOR_PLAYER_USE_ID       = "AnchorPlayerUseID",
    KEY_HALL_ANCHOR_PLAYER_TIME         = "AnchorPlayerTime",
    KEY_HALL_OPEN_TIME          = "OpenTime",
    KEY_HALL_GAME_OPEN_TIME     = "GameOpenTime",
    KEY_CPS_APP                 = "CpsApp",
    KEY_GAME_MARK               = "GameMark",
    KEY_GRATITUDE_REPAY         = "GratitudeRepay",
    KEY_JI_SU_ROOM              = "JiSuRoom",
    KEY_TEAM_2V2_ROOM           = "Team2V2Room",
    KEY_TEAM_2V2_SHARE          = "team2V2Share",

}

--敏感型功能，在启动未获取到最新后台信息情况下，不使用本地缓存配置
AdditionConfigModel.SENSITIVE_MODULES = {
    ["dwc"] = true
}

function AdditionConfigModel:init()
    AdditionConfigModel.super.init(self)

    self:doBackUp()
end

function AdditionConfigModel:isSensitiveModule(moduleName)
    if moduleName == nil then return false end

    if AdditionConfigModel.SENSITIVE_MODULES[moduleName] == true then
        return true
    end
    return false
end

function AdditionConfigModel:getConfigPath()
    return CONFIG_PATH
end

function AdditionConfigModel:getConfigName()
    return CONFIG_NAME
end

function AdditionConfigModel:getConfigType()
    return CONFIG_TYPE
end

function AdditionConfigModel:getConfigID()
    return CONFIG_ID
end

function AdditionConfigModel:getFunctionSupport(...)
    local keys, moduleNames = self:getConfigKeysTable(...)

    local support = 0
    if not keys then
        return support
    end

    --敏感功能，在未获取到后台回应前，不使用本地缓存，而是默认关闭
    if self:isReceivedResponseFromServer() == false and moduleNames ~= nil then
        for _, moduleName in pairs(moduleNames) do
            if self:isSensitiveModule(moduleName) == true then
                support = 0
                return support
            end
        end
    end

    for _, v in pairs(keys) do
        if v[KEY_SUPPORT]  then
            support = v[KEY_SUPPORT]

            --使用SdkName配置再刷一遍
            local isSupportBySdkName = self:_getConfigValBySdkName(v, KEY_SUPPORT)
            if isSupportBySdkName then
                support = isSupportBySdkName
            end

            --使用ByTcyChannel配置再刷一遍
            local isSupportByTcyChannel = self:_getConfigValByTcyChannel(v, KEY_SUPPORT)
            if isSupportByTcyChannel then
                support = isSupportByTcyChannel
            end
        end

        if support <= 0 then
            break
        end
    end

    return support
end

function AdditionConfigModel:_getConfigValByTcyChannel(configItem, keyName)
    local keyNameByTcyChannel = keyName.."ByTcyChannel"
    local tcyChannelId = my.getTcyChannelId()
    if configItem[keyNameByTcyChannel] and tcyChannelId then
        return configItem[keyNameByTcyChannel][tcyChannelId]
    end

    return nil
end

function AdditionConfigModel:_getConfigValBySdkName(configItem, keyName)
    local keyNameBySdkName = keyName.."BySdkName"
    local sdkName = my.getSelfSdkName()

    if sdkName == "tcyapp" then
        if device.platform == 'ios' and configItem[keyNameBySdkName] and configItem[keyNameBySdkName]["tcyappios"] then
            return configItem[keyNameBySdkName]["tcyappios"]
        elseif device.platform == 'android' and configItem[keyNameBySdkName] and configItem[keyNameBySdkName]["tcyappand"] then
            return configItem[keyNameBySdkName]["tcyappand"]
        end
    end

    if configItem[keyNameBySdkName] and sdkName then
        return configItem[keyNameBySdkName][sdkName]
    end

    return nil
end

function AdditionConfigModel:getConfigKey(...)
    local configData = self:getConfigData()
    if configData == nil then
        return nil
    end

    local key = configData[KEY_FUNCTIONS]
    local params = {...}
    for k, v in ipairs(params) do
        if key and key[v] then
            local configItem = key
            local configKey = v

            key = key[v]

            --使用SdkName配置再刷一遍
            local configValBySdkName = self:_getConfigValBySdkName(configItem, configKey)
            if configValBySdkName then
                key = configValBySdkName
            end

            --使用ByTcyChannel配置再刷一遍
            local configValByTcyChannel = self:_getConfigValByTcyChannel(configItem, configKey)
            if configValByTcyChannel then
                key = configValByTcyChannel
            end
        else
            key = nil
            break
        end
    end

    return key
end

function AdditionConfigModel:getConfigKeysTable(...)
    local configData = self:getConfigData()
    if configData == nil then
        return nil
    end

    local keys = {}
    local moduleNames = {}
    local data = configData[KEY_FUNCTIONS]
    for k, v in ipairs({...}) do
        moduleNames[#moduleNames + 1] = v 
        if data and data[v] then
            data = data[v]
            keys[#keys + 1] = data
        else
            keys = nil
            break
        end
    end
    return keys, moduleNames
end

-- just for offline test
--[[
function AdditionConfigModel:reqLatestConfig()
    if self:getConfigVersion() < 2 then
        local config = cc.FileUtils:getInstance():getStringFromFile('C:\\Users\\MSI\\Desktop\\Win32\\AdditionConfig.json')
        if self:isStringValid(config) then
            self:updateConfig(
                BusinessUtils:getInstance():getUpdateDirectory() .. my.getAbbrName() .. '\\' .. self:getConfigPath(),
                self:getConfigName(),
                config,
                10.5)
        end
    end
end
--]]

function AdditionConfigModel:updateConfigData(content)
    print("AdditionConfigModel:updateConfigData")
    local data = self:parseConfigData(content)
    local curData = self:getConfigData()
    dump(data)
    dump(curData)

    if data and data[KEY_FUNCTIONS] and curData and curData[KEY_FUNCTIONS] then
        curData[KEY_FUNCTIONS] = data[KEY_FUNCTIONS]
    end
end

function AdditionConfigModel:onGetConfigCallback(...)
    AdditionConfigModel.super.onGetConfigCallback(self, ...)
    self:dispatchEvent({name = AdditionConfigModel.EVENT_CONFIG_UPDATED})
end

function AdditionConfigModel:mergeTable(dest, src)
    local _merge
    _merge = function(dest, src)
        for k, v in pairs(src) do
            if type(dest[k]) == "table" and type(v) == "table" then
                if k == "functions" then
                    self:_mergeModuleConfigItems(dest[k], v)
                else
                    _merge(dest[k], v)
                end
            else
                dest[k] = v
            end
        end
    end
    _merge(dest, src)
end

--对具体模块的配置项，不合并而是直接覆盖；因为直接覆盖的需求度更高
function AdditionConfigModel:_mergeModuleConfigItems(destItems, srcItems)
    for key, item in pairs(srcItems) do
        destItems[key] = srcItems[key]
    end
end

function AdditionConfigModel:getContentFromPackage()
    local stringInPackage = MCFileUtils:getInstance():getStringFromFileInPackage(self:getConfigPath() .. self:getConfigName())
    if not self:isStringValid(stringInPackage) then
        stringInPackage = cc.FileUtils:getInstance():getStringFromFile(self:getConfigPath() .. self:getBakFileName())
    end

    local packageContent = safeDecoding(stringInPackage)
    return packageContent
end

-- function AdditionConfigModel:updateConfig(path, filename, content, configversion)
--     if not self:isStringValid(path) or
--         not self:isStringValid(filename) or
--         not self:isStringValid(content) or
--         not self:isNumberValid(configversion) or
--         math.ceil(configversion) <= self:getConfigVersion() then return end

--     local jsonContent = safeDecoding(content)
--     if jsonContent and jsonContent[KEY_ID] == self:getConfigID() then
--         jsonContent[KEY_VERSION] = math.ceil(configversion)
--         local mergedContent = self:getContentFromPackage() or {}
--         self:mergeTable(mergedContent, jsonContent)
--         content = json.encode(mergedContent)

--         if self:isStringValid(content) then
--             self:writeConfig(path, filename, content)
--             self:updateConfigVersion(content)
--             self:updateConfigData(content)
--         end
--     end
-- end

function AdditionConfigModel:updateConfig(path, filename, content, configversion)
    if not self:isStringValid(path) or
        not self:isStringValid(filename) or
        not self:isStringValid(content) or
        not self:isNumberValid(configversion) or
        math.ceil(configversion) <= self:getConfigVersion() then return end
    local jsonContent = safeDecoding(content)
    if jsonContent and jsonContent[KEY_ID] == self:getConfigID() then
        jsonContent[KEY_VERSION] = math.ceil(configversion)
        local mergedContent = self:getContentFromPackage() or {}
        self:mergeTable(mergedContent, jsonContent)
        content = json.encode(mergedContent)
        if self:isStringValid(content) then
            self:writeConfig(path, filename, content)
            self:updateConfigVersion(content)
            self:updateConfigData(content)
            CacheModel:saveInfoToCache("ChangeToNewAddtion", 1) -- 添加该缓存标志位写入, 表示已经用该新配置界面接口获取过配置
        end
    end
end

function AdditionConfigModel:doBackUp()
    local path = BusinessUtils:getInstance():getUpdateDirectory() .. my.getAbbrName() .. '/' .. self:getConfigPath()
    if not cc.FileUtils:getInstance():isFileExist(path..self:getBakFileName()) then
        self:writeConfig(path, self:getBakFileName(), self.__configContent)
    end
end

function AdditionConfigModel:getBakFileName()
    return string.format(CONFIG_NAME_BAK, my.getGameVersion())
end

--获取随机房间系数
function AdditionConfigModel:getRoomDepositParamByRoomID(roomID)
    if not roomID then return 1 end

    local quickStartConfig = cc.exports.getQuickStartMatchSet()
    if not quickStartConfig then 
        return 1 
    end

    local param = quickStartConfig[tostring(roomID)]
    if not param then
        param = 1
    end

    return param
end

function AdditionConfigModel:getRoomDepositParam(roomID)
    local matchType = cc.exports.getQuickStartMatchType()

    local depositCoefficient = 1
    if AdditionConfigModel.ROOM_MATCH_TYPE_OLD == matchType then  --老算法

    elseif AdditionConfigModel.ROOM_MATCH_TYPE_NEW == matchType then --新算法
        depositCoefficient = self:getRoomDepositParamByRoomID(roomID)
    elseif AdditionConfigModel.ROOM_MATCH_TYPE_RANDOM == matchType then --随机算法
        local cacheMatchType = CacheModel:getCacheByKey("QuickStartMatchType")
        if AdditionConfigModel.ROOM_MATCH_TYPE_NEW == cacheMatchType then --新算法
            depositCoefficient = self:getRoomDepositParamByRoomID(roomID)
        end
    end

    if not depositCoefficient then
        return 1
    end

    return depositCoefficient
end

local UsageType = {
    TCY    = 1,--单包
    TCYAPP = 2,--同城游
    PLATFORMSET = 3,    --合集包
}

function AdditionConfigModel:getUsageType()
    if  MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() > 0 then
        return UsageType.PLATFORMSET
    end
    if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        return UsageType.TCYAPP
    else
        return UsageType.TCY
    end
end

return AdditionConfigModel
