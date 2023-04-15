
-- extensions
require "src.cocos.extension.ExtensionConstants"
-- network
require "src.cocos.network.NetworkConstants"


local function run()
    cc.exports.gDbgConfig = require("src.debugtool.config")
    require("src.debugtool.globalfunc")
    require("src.debugtool.printlog")

    require("src.debugtool.dbginterface")
    if DEBUG > 0 then
        DbgInterface:run()
    end
end

local status, msg = xpcall(run, function(s)
    print(debug.traceback(s,2))
    return s
end)
