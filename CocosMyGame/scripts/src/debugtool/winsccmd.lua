local Test = class("Test")

--拓展 press_XXXX  CocosdConstants.lua cc.KeyCodeKey中的key 除了F6
function Test:showMsg(msg, time)
    time = time or 2
    my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = msg, removeTime = time}})
end

-- 更新银两
function Test:press_KEY_1()
    self:showMsg("hhahahh")
end

function Test:press_KEY_2()
    local ExchangeCenterReq = import('src.app.plugins.ExchangeCenter.ExchangeCenterReq')
    local AssistModel = mymodel('assist.AssistModel'):getInstance()
    local exCenterBroadCast = ExchangeCenterReq["EXCHANGE_CENTER_BROAD_CAST"]
    local treepack          = cc.load('treepack')
    local data      = {
        nUserID     = 610516,
        nType       = 1,
        nCount      = 100,
		szUserName   = "gb2Name",
        szPrizName   = "gb2PrizeName" -- 实物名称
    }
    local pData = treepack.alignpack(data, exCenterBroadCast)

    AssistModel:sendData(409011, pData)
end

function Test:press_KEY_3()
    
end

return Test