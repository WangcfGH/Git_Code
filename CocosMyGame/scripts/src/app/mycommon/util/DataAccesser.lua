local DataAccesser       = class("DataAccesser")
local SimpleEncrypter    = import("src.app.mycommon.util.SimpleEncrypter")

DataAccesser.DEFAULT_ENCRYPT_SEQUENCE = "zslhKXEO1k02/f9bQpBY3xoCTaFu=WUZAdnSRv8ID5mcJ4iyweG67LMPjtrgHNV+q"

function DataAccesser:ctor(encryptSequence)
    self._encrypter = SimpleEncrypter:create(encryptSequence)
    if encryptSequence == nil then
        self._encrypter:setEncryptSequence(DataAccesser.DEFAULT_ENCRYPT_SEQUENCE)
    end

    self._encryptMapAttParts = {["name"] = true, ["value"] = true} --加密和解密Map时，需要加密和解密的属性部分
    self._encryptMapAttValueTypes = {["string"] = true, ["number"] = true, ["boolean"] = true} --加密Map时，需要加密的数据类型
end

function DataAccesser:setEncrypter(encryptSequence)
    self._encrypter:setEncryptSequence(encryptSequence)
end

--设置加密和解密Map时，需要加密和解密的属性部分
function DataAccesser:setEncryptMapAttParts(attParts)
    if attParts == nil then return end

    self._encryptMapAttParts = attParts
end

--设置加密Map时，需要加密的数据类型；解密时如果设置了EncryptMapAttParts["value"]=true，则会对string类型解密；否则不会解密value
function DataAccesser:setEncryptMapAttValueTypes(attValueTypes)
    if attValueTypes == nil then return end

    self._encryptMapAttValueTypes = attValueTypes
end

--加密(支持string、number、boolean、table)
function DataAccesser:encrypt(object)
    if object == nil then return nil end
    if self._encrypter == nil then return object end

    local objType = type(object)
    local objEncrypted = object
    if objType == "string" or objType == "number" or objType == "boolean" then
       objEncrypted = self._encrypter:encrypt(object)
    elseif objType == "table" then
        objEncrypted = self:_encryptMap(object)
    end
    return objEncrypted
end

--解密(支持string、table)
function DataAccesser:decipher(object)
    if object == nil then return nil end
    if self._encrypter == nil then return object end

    local objType = type(object)
    local objDeciphered = object
    if objType == "string" then
       objDeciphered = self._encrypter:decipher(object)
    elseif objType == "table" then
        objDeciphered = self:_decipherMap(object)
    end
    return objDeciphered
end

--本类测试示例
function DataAccesser:testDecipherData()
    local dataOrigin = {
        ["name"] = "exchange_ticket",
        ["typeList"] = {"type1", "type2"},
        ["testMap"] = {
            ["name"] = "silver",
            ["count"] = 1000,
            ["typeList"] = {"type3", "type4"}
        },
        1999,
        {
            ["name"] = "cardmaster",
            ["desc"] = "记牌器"
        },
        ["testBool"] = true
    }
    self:setEncryptMapAttParts({["name"] = false, ["value"] = true})
    self:setEncryptMapAttValueTypes({["string"] = true, ["number"] = true, ["boolean"] = true})
    local dataEncrypted = self:encrypt(dataOrigin)
    local dataDeciphered = self:decipher(dataEncrypted)
end

--解密map(默认name和value均加密)；对于number和boolean类型，需要在解密后手动转换
function DataAccesser:_decipherMap(dataMapEncrypted)
    if dataMapEncrypted == nil then return nil end
    if type(dataMapEncrypted) ~= "table" then return dataMapEncrypted end
    if self._encrypter == nil then return dataMapEncrypted end

    local dataMapOrigin = {}
    local nameType, valueType, attName, attValue
    for k, v in pairs(dataMapEncrypted) do
        attName = k
        attValue = v
        nameType = type(attName)
        valueType = type(attValue)
        if nameType == "string" then
            if self._encryptMapAttParts["name"] == true then
                attName = self._encrypter:decipher(attName)
            end
        end
        if valueType == "string" then
            if self._encryptMapAttParts["value"] == true then
                attValue = self._encrypter:decipher(attValue)
            end
        elseif valueType == "table" then
            attValue = self:_decipherMap(attValue)
        end
        dataMapOrigin[attName] = attValue
    end
    return dataMapOrigin
end

--加密map(默认name和value均加密)；对于number和boolean类型，会自动转换为string再加密
function DataAccesser:_encryptMap(dataMapOrigin)
    if dataMapOrigin == nil then return nil end
    if type(dataMapOrigin) ~= "table" then return dataMapOrigin end
    if self._encrypter == nil then return dataMapOrigin end

    local dataMapEncrypted = {}
    local nameType, valueType, attName, attValue
    for k, v in pairs(dataMapOrigin) do
        attName = k
        attValue = v
        nameType = type(attName)
        valueType = type(attValue)
        if nameType == "string" then
            if self._encryptMapAttParts["name"] == true then
                attName = self._encrypter:encrypt(attName)
            end
        end
        if self._encryptMapAttParts["value"] == true then
            if valueType == "string" or valueType == "number" or valueType == "boolean" then
                if self._encryptMapAttValueTypes[valueType] == true then
                    attValue = self._encrypter:encrypt(attValue)
                end
            end
        end
        if valueType == "table" then
            attValue = self:_encryptMap(attValue)
        end
        dataMapEncrypted[attName] = attValue
    end
    return dataMapEncrypted
end

--加密或解密文件；direction = {"encrypt", "decipher"}
function DataAccesser:translateFile(rawFilePath, saveFilePath, direction)
    if rawFilePath == nil or saveFilePath == nil then return end
    if direction ~= "encrypt" and direction ~= "decipher" then return end
    if self._encrypter == nil then return end

    --翻译并存储
    local saveFile = io.open(saveFilePath, "w")
    local rawFile = io.open(rawFilePath, "r")
    local lineTranslated = nil
    if direction == "encrypt" then
        for line in rawFile:lines() do
            lineTranslated = self:encrypt(line)
            saveFile:write(lineTranslated.."\n")
        end
    else
        for line in rawFile:lines() do
            lineTranslated = self:decipher(line)
            saveFile:write(lineTranslated.."\n")
        end
    end
    rawFile:close()
    saveFile:close()
end

return DataAccesser
