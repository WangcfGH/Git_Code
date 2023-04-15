--[[
    登录数据埋点模块
    成功获取到微信数据后，向assist server发送登录的数据。
]]
local DataRecordModel   = class('DataRecordModel', import('src.app.GameHall.models.BaseModel'))
local DataRecordRequest = import('src.app.GameHall.models.hallext.DataRecord.DataRecordRequest')

local AssistModel       = mymodel('assist.AssistModel'):getInstance()
local UserModel         = mymodel('UserModel'):getInstance()
local PlayerModel       = mymodel('hallext.PlayerModel'):getInstance()

cc.exports.FuncUsedTypeDef = {
    FUNC_TYPE_BEGIN = 0,
    FUNC_TYPE_LOTTERY = 1,
    FUNC_TYPE_SWITCH_CHAIR = 2,
    FUNC_TYPE_SURRENDER = 3,
    FUNC_TYPE_MAX = 4
}

my.addInstance(DataRecordModel)
my.setmethods(DataRecordModel, cc.load('coms').PropertyBinder)

function DataRecordModel:onCreate()
    self:_init()
end

function DataRecordModel:_init()
    self:listenTo(PlayerModel, PlayerModel.PLAYER_WECHAT_UPDATED, handler(self, self._onWechatInfoUpdate))
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    netProcess:addEventListener(netProcess.EventEnum.NetProcessFinished, handler(self, self._onNetProcessFinished), self.__cname)
end

function DataRecordModel:_onWechatInfoUpdate(data)
    self._wechatInfoGet = true
    self:uploadClientData()
end

function DataRecordModel:_onNetProcessFinished()
    self._netProcessFinished = true
    self:uploadClientData()
end

function DataRecordModel:uploadClientData()
--    if nil == UserModel:isWechatBinded() then return end
    if (not self._wechatInfoGet) or (not self._netProcessFinished) then return end

    local wechatInfo = UserModel:getWechatInfo()

    --之所以使用rawget 是为了获取当前表内的内容而不触发元表函数（UserModel元表会去发送对应的请求）
    local nDonateBalance= rawget(UserModel, "nDonateBalance") or 0
    local nFreeHappyCoin= rawget(UserModel, "nTotalBalance") or 0
	local szWeChatName  = wechatInfo and wechatInfo.nickname or ''
	local szPhoneNO     = cc.exports.UserPlugin:isBindMobile() and cc.exports.UserPlugin:getMobile() or ''
    local data          = {
        nUserID         = UserModel.nUserID,
		szWeChatName    = MCCharset:getInstance():utf82GbString(szWeChatName, string.len(szWeChatName)),
		szPhoneNO       = MCCharset:getInstance():utf82GbString(szPhoneNO, string.len(szPhoneNO)),
		szDeviceName    = DeviceUtils:getInstance():getPhoneBrand(),
		szClientVer     = my.getGameVersion(),
        nFirstLogon     = rawget(UserModel, "dwFlags"),
        nHappyCoin      = rawget(UserModel, "nTotalBalance"),
        nFreeHappyCoin  = nFreeHappyCoin - nDonateBalance,
        nScoreNum       = rawget(UserModel, "nScore"),
        nDepositNum     = rawget(UserModel, "nDeposit"),
        nSafeboxNum     = rawget(UserModel, "nSafeboxDeposit"),
	    nNetType        = DeviceUtils:getInstance():getNetworkType(),
        nChannelNO      = tonumber(BusinessUtils:getInstance():getRecommenderId()),
        szHardID        = PUBLIC_INTERFACE.GetDeviceModel().szHardID,
        szExtend        = mymodel('hallext.LbsModel'):getInstance():getLbsAreaString() 
        -- 运营需求：登录上报详细地理信息，需要结合埋点模板一并修改，直接合并代码会导致服务端数据长度校验不通过
    }
    AssistModel:sendRequest(DataRecordRequest.MessageMap.GR_DATARECORD_NEW_APP_UPLOAD, DataRecordRequest.APPUPLOAD_DATA, data)
end

function DataRecordModel:uploadFuncUsedLog(funcID)
    local data          = {
        nUserID         = UserModel.nUserID,
        nFuncID         = funcID
    }
    AssistModel:sendRequest(DataRecordRequest.MessageMap.GR_DATARECORD_LOG_FUNC_USED, DataRecordRequest.FUNCUSED_LOG, data)
end

return DataRecordModel