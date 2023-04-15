local DataUtil       = class("DataUtil")

function DataUtil:ctor()
end

--拷贝数据表
--对string、number、boolean、table类型深拷贝；对userdata、function、thread只拷贝引用
--对value深拷贝；对name只拷贝引用
function DataUtil:copyData(dataOrigin)
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

--从itemList列表中查询具有属性名称为attName且取值为attValue的项
function DataUtil:getItemByKeyAttribute(itemList, attName, attValue)
    if itemList == nil or attName == nil or attValue ==  nil then return end

    for i = 1, #itemList do
        if itemList[i][attName] == attValue then
            return itemList[i]
        end
    end
    return nil
end

--判断是否是今天的时间，即今日的00:00:00-23:59:59
function DataUtil:isTodayTime(timeInstance)
    if timeInstance == nil or timeInstance < 0 then return false end

    local curTimeMap = os.date("*t")
    local timeInstanceMap = os.date("*t", timeInstance)
    if curTimeMap.year == timeInstanceMap.year and curTimeMap.month == timeInstanceMap.month 
        and curTimeMap.day == timeInstanceMap.day then
        return true
    end
    return false
end

return DataUtil
