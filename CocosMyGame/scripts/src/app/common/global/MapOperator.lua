--存取数据
local MapOperator = class("MapOperator", import(".UniqueObject"))

function MapOperator:ctor()
    self:_testCase1()
end

function MapOperator:_testCase1()
    local dataTest = {
        ["data1"] = {["hisname"] = "jim"},
        ["2"] = 3,
        ["data2"] = {"simpher"}
    }
    local abc = self:getData(dataTest, "data1")
    local abd = self:getData(dataTest, "data1.hisname")
    local abe = self:getData(dataTest, "data2.[1]")
end

--字符串key原样返回；[1]返回整型数字
function MapOperator:_parseSubKey(subKey)
    local firstChar = string.sub(subKey, 1, 1)
    local lastChar = string.sub(subKey, -1, -1)
    if firstChar == "[" and lastChar == "]" then
        return tonumber(string.sub(subKey, 2, string.len(subKey) - 1))
    else
        return subKey
    end
end

function MapOperator:getData(dataMap, dataKey, defaultDataValue)
    if dataMap == nil or type(dataMap) ~= "table" then return defaultDataValue end
    if dataKey == nil or type(dataKey) ~= "string" then return defaultDataValue end

    local nextData = dataMap
    local subKeys = string.split(dataKey, ".")
    for i = 1, #subKeys do
        nextData = nextData[self:_parseSubKey(subKeys[i])]
        if nextData == nil then return defaultDataValue end
    end

    if nextData == nil then
        return defaultDataValue
    end
    return nextData
end

function MapOperator:setData(dataMap, dataKey, dataValue)
    if dataMap == nil or type(dataMap) ~= "table" then return nil end
    if dataKey == nil or type(dataKey) ~= "string" then return nil end

    local nextData = dataMap
    local subKeys = string.split(dataKey, ".")
    for i = 1, #subKeys - 1 do
        nextData = nextData[self:_parseSubKey(subKeys[i])]
        if nextData == nil then return nil end
    end

    local targetKey = subKeys[#subKeys]
    nextData[targetKey] = dataValue
    return true
end

function MapOperator:addNumericData(dataMap, dataKey, addValue)
    if addValue == nil or type(addValue) ~= "number" then return false end

    local curValue = self:getData(dataMap, dataKey)
    if type(curValue) == "number" then
        self:setData(dataMap, dataKey, curValue + addValue)
        return true
    end
    return false
end

function MapOperator:getSubElement(rootElement, elementKey)
    if rootElement == nil or type(rootElement.getChildByName) ~= "function" then return nil end
    if elementKey == nil or type(elementKey) ~= "string" then return nil end

    local nextElement = rootElement
    local subKeys = string.split(elementKey, ".")
    for i = 1, #subKeys do
        nextElement = nextElement:getChildByName(self:_parseSubKey(subKeys[i]))
        if nextElement == nil then return nil end
    end
    return nextElement
end

--从Map或List中查找满足targetCondition的第一个Item
function MapOperator:findItem(items, targetCondition)
    if items == nil or type(items) ~= "table" then return nil end
    if targetCondition == nil or type(targetCondition) ~= "table" then return nil end

    local isSatisfied = false
    for _, item in pairs(items) do
        isSatisfied = true
        for conditionKey, conditionVal in pairs(targetCondition) do
            if item[conditionKey] ~= conditionVal then
                isSatisfied = false
                break
            end
        end
        if isSatisfied == true then
            return item
        end
    end
    return nil
end

--递归拷贝数据Map
function MapOperator:copyData(dataOrigin)
    local dataCopied = nil
    local dataOriginType = type(dataOrigin)
    if dataOriginType ~= "table" then
        dataCopied = dataOrigin
        return dataCopied
    else
        dataCopied = {}
        local valueType = nil
        for k, v in pairs(dataOrigin) do
            valueType = type(v)
            if valueType == "table" then
                dataCopied[k] = self:copyData(v)
            else
                dataCopied[k] = v
            end
        end
    end
    return dataCopied
end

function MapOperator:checkTable(dataMap)
    if dataMap ~= nil and next(dataMap) ~= nil then
        return true
    end
    return false
end

return MapOperator