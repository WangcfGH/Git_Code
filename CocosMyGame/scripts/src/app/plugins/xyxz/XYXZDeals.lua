--[[
@描述: 宿主游戏和子游戏的交互协议
@作者：陈添泽
@日期：2020.05.18 
]]
local DealDef = {
    INIT_NETPROCESS = 1,    --用户信息
    INIT_ENTERGAME  = 2,    --进游戏信息
    INIT_SHOPITEMS  = 3,    --商品列表
    INIT_HOSTINFO   = 4,    --初始化宿主信息
    INIT_RELIEF     = 5,    --低保信息
    INIT_SETTINGS   = 6,    --设置
    BACK_GAME       = 7,    --返回游戏会执行的协议
    INIT_SUBGAME    = 8,    --需要打开的子游戏（目前只有碰碰乐，本质上xyxz-938是个小游戏合集）
}

local DealOperator = {}

function DealOperator:INIT_NETPROCESS(data)
    -- local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    if data.needRelogin then
        PUBLIC_INTERFACE.DisconnectHallSvr()
    end
    table.merge(mymodel("UserModel"):getInstance(), data.userInfo)
    UserPlugin:resetCallback()              -- 重置sdk回调
end

function DealOperator:INIT_SETTINGS(data)
    local SettingsModel = mymodel('hallext.SettingsModel'):getInstance()
    SettingsModel:setMusicVolume(data.music)
    SettingsModel:setSoundsVolume(data.sound)
    mymodel('hallext.SettingsModel'):getInstance():InitVoiceEnvironment()
end

local DealMaker = {}

function DealMaker:INIT_NETPROCESS()
    local deal = {
        id = DealDef.INIT_NETPROCESS,
        data = {
            userInfo    = mymodel("UserModel"):getInstance(),
        }
    }
    return deal
end

function DealMaker:INIT_ENTERGAME()
end

function DealMaker:FILTER_SHOPITEMS(shopitems)
    local filterShopItems = {}
    for k, v in pairs(shopitems) do
        if v.producttype == 1 then
            table.insert( filterShopItems,  v )
        end
    end

    return filterShopItems
end

function DealMaker:INIT_SHOPITEMS()
    local ShopModel = mymodel("ShopModel"):getInstance()
    local PayModel  = mymodel("PayModel"):getInstance()
    local deal = {
        id = DealDef.INIT_SHOPITEMS,
        data = {
            shopItems = DealMaker:FILTER_SHOPITEMS(ShopModel:GetShopItemsInfo()),
            uiConfig  = ShopModel:GetShopUIConfig(),
            payInfo   = PayModel:getPayMetaTable(),
            cacheInfo = my.readCache(ShopModel:getCacheDataName()),
            rechargeId = require("src.app.HallConfig.ActivitysConfig").RechargeId
        }
    }
    return deal
end

function DealMaker:INIT_HOSTINFO()
    local deal = {
        id = DealDef.INIT_HOSTINFO,
        data = {
            nGameID = BusinessUtils:getInstance():getGameID(),
            szGameCode = BusinessUtils:getInstance():getAbbr(),
            szGameVer = BusinessUtils:getInstance():getAppVersion()
        }
    }
    return deal
end

function DealMaker:INIT_RELIEF()
    local deal = {
        id  = DealDef.INIT_RELIEF,
        data = {
            reliefActId = require("src.app.HallConfig.ActivitysConfig").ReliefActId,
            reliefCache = mymodel('hallext.ReliefActivity'):readFromCacheData()
        }
    }
    return deal
end

function DealMaker:INIT_SETTINGS()
    local SettingsModel = mymodel('hallext.SettingsModel'):getInstance()
    local deal = {
        id = DealDef.INIT_SETTINGS,
        data = {
            sound       = SettingsModel:getSoundsVolume(),
            music       = SettingsModel:getMusicVolume(),
        }
    }
    return deal
end

function DealMaker:BACK_GAME()
    local function onBack()
        local xyxzDeals = cc.exports.xyxzDeals
        cc.exports.xyxzDeals = {}
        if type(xyxzDeals) == "table" then
            for _, deal in ipairs(xyxzDeals) do
                if deal.id == DealDef.INIT_NETPROCESS then
                    DealOperator:INIT_NETPROCESS(deal.data)
                elseif deal.id == DealDef.INIT_SETTINGS then
                    DealOperator:INIT_SETTINGS(deal.data)
                end
            end
        end
        display.setAutoScale(CC_DESIGN_RESOLUTION)
        cc.Director:getInstance():setAnimationInterval(CC_DEFAULT_ANIMATIONINTERVAL)
        my.unfreezeKeyboardListener()
        my.informPluginByName({params = { message = 'remove' }})
    end

    local deal = {
        id = DealDef.BACK_GAME,
        data = {
            onBack = onBack
        }
    }
    return deal
end

function DealMaker:INIT_SUBGAME()
    local deal = {
        id = DealDef.INIT_SUBGAME,
        data = {
            gamecode = "pple"
        }
    }
    return deal
end

function DealMaker:getDealByID(nDealID)
    local dealName = table.keyof(DealDef, nDealID)
    return self[dealName](self)
end

function DealMaker:getDeals(nDealIDs)
    local deals = {}
    for _, nDealID in ipairs(nDealIDs) do
        table.insert(deals, self:getDealByID(nDealID))
    end
    return deals
end

function DealMaker:getXYXZDeals()
    local nDealIDs = {
        DealDef.INIT_NETPROCESS,
        DealDef.INIT_SHOPITEMS,
        DealDef.INIT_HOSTINFO,
        DealDef.INIT_RELIEF,
        DealDef.INIT_SETTINGS,
        DealDef.BACK_GAME
    }
    return self:getDeals(nDealIDs)
end

return DealMaker