
if nil == cc or nil == cc.exports then
    return
end

require("src.cocos.cocos2d.bitExtend")

cc.exports.SKPublicInterface                = {}
local SKPublicInterface                     = cc.exports.SKPublicInterface

function SKPublicInterface:bits_or(bit1, bit2, ...)
    local bitResult = bit._or(bit1, bit2)
    for i, v in ipairs({...})  do
        bitResult = bit._or(bitResult, v)
    end
    return bitResult;
end

return SKPublicInterface