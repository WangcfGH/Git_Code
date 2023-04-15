
local Config = {
    synclog         = false,                        -- 是否同步print日志到webserver
    logserver       = "https://logdebug.tcy365.com:2505",                -- webserver地址
    gmenable        = true,                         -- 是否连接指令服务器
    gmserver        = "logdebug.tcy365.com",        -- 指令服务器地址
    gmport          = 7777,
    memenable       = false,                        -- 是否一直显示内存信息
    update_server   = "ws://192.168.42.201:9595",        -- 更新服务器的地址
}

return Config
