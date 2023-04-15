--字符串构造器，通过不断地连接下一个子部分构成一个新的字符串
--如果子部分为string,number,boolean则直接连接；如果为nil,table,function,userdata,thread则连接其类型字符串
local StringBuilder = class("StringBuilder")

function StringBuilder:ctor()
    self._curString = ""
end

function StringBuilder:reset()
    self._curString = ""
end

--开始连接
function StringBuilder:begin(nextPart)
    self:reset()
    self:add(nextPart)
    return self
end

--继续连接
function StringBuilder:add(nextPart)
    if type(nextPart) == "string" or type(nextPart) == "number" then
        self._curString = self._curString..nextPart
    elseif type(nextPart) == "boolean" then
        if nextPart then
            self._curString = self._curString.."true"
        else
            self._curString = self._curString.."false"
        end
    else
        self._curString = self._curString..type(nextPart)
    end
    return self
end

function StringBuilder:getString()
    return self._curString
end

function StringBuilder:tasteMe()
    local sb = require("src.app.common.util.StringBuilder")
    local str1 = "aaa"
    local str2 = nil
    local str3 = false
    local str4 = {"bbb"}
    local str5 = 1.982
    local str6 = function() print("ddd") end
    local str7 = nil
    print(sb:begin(str1):begin(str2):add(str3):add(str4):add(str5):add(str6):add(str7):getString())
end

return StringBuilder
