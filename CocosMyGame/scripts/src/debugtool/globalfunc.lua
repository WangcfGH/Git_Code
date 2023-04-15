
local function strval2Str(szVal)
    szVal   = string.gsub(szVal, "\\", "\\\\")
    szVal   = string.gsub(szVal, '"', '\\"')
    szVal   = string.gsub(szVal, "\n", "\\n")
    szVal   = string.gsub(szVal, "\r", "\\r")
    return '"'..szVal..'"'
end

local function val2Str(var, szBlank)
    local szType    = type(var)
    if (szType == "nil") then
        return "nil"
    elseif (szType == "number") then
        return tostring(var)
    elseif (szType == "string") then
        return strval2Str(var)
    elseif (szType == "function") then
        local szCode    = string.dump(var)
        local arByte    = {string.byte(szCode, i, #szCode)}
        szCode  = ""
        for i = 1, #arByte do
            szCode  = szCode..'\\'..arByte[i]
        end
        return 'loadstring("' .. szCode .. '")'
    elseif (szType == "table") then
        if not szBlank then
            szBlank = ""
        end
        local szTbBlank = szBlank .. "  "
        local szCode    = ""
        for k, v in pairs(var) do
            local szPair    = szTbBlank.."[" .. val2Str(k) .. "]   = " .. val2Str(v, szTbBlank) .. ",\n"
            szCode  = szCode .. szPair
        end
        if (szCode == "") then
            return "{}"
        else
            return "\n"..szBlank.."{\n"..szCode..szBlank.."}"
        end
    else    --if (szType == "userdata") then
        return '"' .. tostring(var) .. '"'
    end
end

local function myxpcall(func)
    local status, msg = xpcall(func, function(s)
        print(debug.traceback(s,2))
        return s
    end)
end

-- 重载文件
local function reload(path)
    myxpcall(function()
        package.loaded[path] = nil
        import(path)
        --print(string.format("reload[%s] success!", path))
    end)
end


---------------------- 全局函数申明 ----------------------
cc.exports.tostr        = val2Str           -- value to string
cc.exports.myxpcall     = myxpcall
cc.exports.reloadfile   = reload


---------------------- 执行脚本文件 ----------------------
if device.platform == "windows" then
    -- F6按键监听
    local function onKeyReleased(keyCode, event)
        --print(string.format("Key %d was released!",keyCode))
        if keyCode == cc.KeyCode.KEY_F6 then
            --print("----------------------winsccmd-------------------------")
            reloadfile("src.debugtool.winsccmd")
        else
            reloadfile("src.debugtool.winsccmd")
            local test = require("src.debugtool.winsccmd")
            local key = table.keyof(cc.KeyCode, keyCode)
            if type(test["press_" .. key]) == "function" then
                local instance = test:create()
                --instance:onCreate()
                instance["press_" .. key](instance)
                -- test["press_" .. key](test)
                --instance:onDestroy()
            end
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end
