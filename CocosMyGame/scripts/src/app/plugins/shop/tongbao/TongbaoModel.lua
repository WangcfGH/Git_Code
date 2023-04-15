local TongbaoModel = class('TongbaoModel', require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local UserModel = mymodel('UserModel'):getInstance()
local PlayerModel = mymodel('hallext.PlayerModel'):getInstance()
local json = cc.load("json").json

my.addInstance(TongbaoModel)

local GR_TONGBAO_EXCHANGE = 403601

protobuf.register_file('src/app/plugins/shop/tongbao/pbTongbao.pb')

function TongbaoModel:onCreate()
    self._assistResponseMap = {
        [GR_TONGBAO_EXCHANGE] = handler(self, self.onTongbaoExchangeResp),
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function TongbaoModel:getOsType()
    if device.platform == 'android' then
        return 1
    elseif device.platform == 'ios' then
        return 2
    elseif device.platform == 'windows' then
        return 3
    end
    return 0
end

function TongbaoModel:onTongbaoExchange(exchangeid, price)
    local data = {
        userid = UserModel.nUserID,
        exchangeid = exchangeid,
        price = price,
        ostype = self:getOsType()
    }

    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            data.gsclientdata = gsClient
        end
    end

    local pdata = protobuf.encode('pbTongbao.exchange', data)
    AssistModel:sendData(GR_TONGBAO_EXCHANGE, pdata, false)
end

function TongbaoModel:onTongbaoExchangeResp(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbTongbao.exchangeResult', data)
    protobuf.extract(pdata)

    if pdata then
        local jsonString = pdata.datastring
        local jsonData = json.decode(jsonString)
        if jsonData.Code == 0 then
            local ShopModel = mymodel("ShopModel"):getInstance()
            if jsonData.Data then
                local exchangeid = jsonData.Data.GoodsId
                local shopItem = ShopModel:getShopItemByExchangeId(exchangeid)
                local noteTip = shopItem.notetip
                my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = noteTip, removeTime = 2}})
            end
            PlayerModel:update({"UserGameInfo", "WealthInfo"})
        else
            my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = jsonData.Message, removeTime = 2}})
        end
    end
end

return TongbaoModel