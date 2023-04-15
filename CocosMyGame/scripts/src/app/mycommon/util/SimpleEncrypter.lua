local SimpleEncrypter       = class("SimpleEncrypter")
local Base64                = import("src.app.mycommon.util.Base64")

SimpleEncrypter.CHAR_SEQUENCE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

function SimpleEncrypter:ctor(encryptSequence)
    self._encryptMap = nil
    self._decipherMap = nil

    self:setEncryptSequence(encryptSequence)
end

--传入加密序列
function SimpleEncrypter:setEncryptSequence(encryptSequence)
    if encryptSequence == nil then return false end
    if type(encryptSequence) ~= "string" then return false end
    local seqLen = string.len(encryptSequence)
    if seqLen ~= string.len(SimpleEncrypter.CHAR_SEQUENCE) then return false end

    local rawSeq = SimpleEncrypter.CHAR_SEQUENCE
    local encryptMap = {}
    local decipherMap = {}
    for i = 1, seqLen do
        local char = string.sub(rawSeq, i, i)
        local charMapped = string.sub(encryptSequence, i, i)
        encryptMap[char] = charMapped
        decipherMap[charMapped] = char
    end
    self._encryptMap = encryptMap
    self._decipherMap = decipherMap
end

--加密(支持string、number、boolean)
function SimpleEncrypter:encrypt(object)
    if object == nil then return nil end
    if self._encryptMap == nil then return object end
    if type(object) == "number" then object = object.."" end
    if type(object) == "boolean" then
        if object == true then object = "true" else object = "false" end
    end
    if type(object) ~= "string" then return "" end
    if object == "" then return "" end

    local strBase64 = Base64:to_base64(object)
    local strLen = string.len(strBase64)
    local strEncrypted = ""
    local originChar = nil
    local mappedChar = nil
    for i = 1, strLen do
        originChar = string.sub(strBase64, i, i)
        mappedChar = self._encryptMap[originChar]
        if mappedChar == nil then mappedChar = originChar end --非法字符原样输出
        strEncrypted = strEncrypted..mappedChar
    end
    return strEncrypted
end

--解密(支持string)
function SimpleEncrypter:decipher(strEncrypted)
    if strEncrypted == nil then return nil end
    if self._decipherMap == nil then return strEncrypted end
    if type(strEncrypted) ~= "string" then return "" end
    if strEncrypted == "" then return "" end

    local strLen = string.len(strEncrypted)
    local strDeciphered = ""
    local originChar = nil
    local mappedChar = nil
    for i = 1, strLen do
        originChar = string.sub(strEncrypted, i, i)
        mappedChar = self._decipherMap[originChar]
        if mappedChar == nil then mappedChar = originChar end --非法字符原样输出
        strDeciphered = strDeciphered..mappedChar
    end

    local strOrigin = Base64:from_base64(strDeciphered)
    return strOrigin
end

--生成加密序列
function SimpleEncrypter:generateEncryptSequence()
    local rawSeq = SimpleEncrypter.CHAR_SEQUENCE
    local seqLen = string.len(rawSeq)
    local charArr = {}
    for i = 1, seqLen do
        charArr[i] = string.sub(rawSeq, i, i)
    end

    local index1 = 1
    local index2 = 1
    local tempChar = ""
    for i = 1, 100 do
        index1 = math.random(seqLen)
        index2 = math.random(seqLen)
        tempChar = charArr[index1]
        charArr[index1] = charArr[index2]
        charArr[index2] = tempChar
    end

    local encryptSeq = ""
    for i = 1, seqLen do
        encryptSeq = encryptSeq..charArr[i]
    end
    return encryptSeq
end

return SimpleEncrypter
