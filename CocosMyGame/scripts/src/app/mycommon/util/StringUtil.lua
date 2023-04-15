local StringUtil = class("StringUtil")

--rawStr中目标字符串的最后位置
function StringUtil:lastIndexOf(rawStr, strToFind)
    if rawStr == nil or strToFind == nil then return -1 end
    if type(rawStr) ~= "string" or type(strToFind) ~= "string" then return -1 end

    local curIndex, targetEndIndex = string.find(rawStr, strToFind)
    local prevIndex = nil
    while curIndex ~= nil do
        prevIndex = curIndex
        curIndex, targetEndIndex = string.find(rawStr, strToFind, targetEndIndex + 1)
    end
    return prevIndex
end

--分解文件路径，返回文件目录、文件名(不含后缀名)、文件后缀
function StringUtil:parseFileParts(filePath)
    if filePath == nil then return end
    if type(filePath) ~= "string" then return end
    
    local separatorIndex = nil
    separatorIndex = self:lastIndexOf(filePath, "/")
    if separatorIndex == nil then separatorIndex = self:lastIndexOf(filePath, "\\") end

    local dir = string.sub(filePath, 0, separatorIndex - 1)
    local fileFullName = string.sub(filePath, separatorIndex + 1, string.len(filePath))
    local fileName = fileFullName
    local dotIndex = string.find(fileFullName, "%.")
    local fileExt = nil
    if dotIndex ~= nil then
        fileExt = string.sub(fileFullName, dotIndex + 1, string.len(fileFullName))
        fileName = string.sub(fileFullName, 0, dotIndex - 1)
    end
    return dir, fileName, fileExt
end

--追加路径
function StringUtil:appendFilePath(rawPath, pathToAppend)
    if rawPath == nil or pathToAppend == nil then return end
    if type(rawPath) ~= "string" or type(pathToAppend) ~= "string" then return end

    local separator = "/"
    local separatorIndex = string.find(rawPath, separator)
    if separatorIndex == nil then
        separator = "\\"
    end
    rawPath = rawPath..separator..pathToAppend
    return rawPath
end

-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
function StringUtil:_chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- 计算utf8字符串字符数, 各种字符都按一个字符计算
-- 例如utf8len("1你好") => 3
function StringUtil:utf8len(rawStr)
    if rawStr == nil or type(rawStr) ~= "string" then return 0 end

    local len = 0
    local currentIndex = 1
    while currentIndex <= #rawStr do
        local char = string.byte(rawStr, currentIndex)
        currentIndex = currentIndex + self:_chsize(char)
        len = len +1
    end
    return len
end

-- 截取utf8 字符串
-- rawStr: 要截取的字符串
-- startCharIndex: 开始字符下标,从1开始
-- numChars: 要截取的字符长度
function StringUtil:utf8sub(rawStr, startCharIndex, numChars)
    if rawStr == nil or type(rawStr) ~= "string" then return "" end
    if startCharIndex == nil or startCharIndex <= 0 then startCharIndex = 1 end
    local totalCharCount = string.utf8len(rawStr)
    if numChars == nil or (numChars + startCharIndex - 1) > totalCharCount then numChars = totalCharCount - startCharIndex + 1 end
    if startCharIndex > totalCharCount then return rawStr end

    --找到byte索引
    local startIndex = 1
    while startCharIndex > 1 do
        local char = string.byte(rawStr, startIndex)
        startIndex = startIndex + self:_chsize(char)
        startCharIndex = startCharIndex - 1
    end

    --从byte索引开始，截取numChars的byte长度的字符串
    local currentIndex = startIndex
    while numChars > 0 and currentIndex <= #rawStr do
        local char = string.byte(rawStr, currentIndex)
        currentIndex = currentIndex + self:_chsize(char)
        numChars = numChars -1
    end
    return rawStr:sub(startIndex, currentIndex - 1)
end

--计算字符串的字符长度，英文、数字等Ascii码字符长度为1，其它中文、韩文等字符长度为2
function StringUtil:charLen(rawStr)
    if rawStr == nil or type(rawStr) ~= "string" then return 0 end

    local charLen = 0
    local currentIndex = 1
    local char = nil
    local chSize = 0
    while currentIndex <= #rawStr do
        char = string.byte(rawStr, currentIndex)
        chSize = self:_chsize(char)
        currentIndex = currentIndex + chSize
        if chSize == 1 then
            charLen = charLen + 1
        elseif chSize > 1 then
            charLen = charLen + 2
        end
    end
    return charLen
end

--根据字符长度查找不超过maxCharLen的分割位置
function StringUtil:findSubPosByCharLen(rawStr, maxCharLen)
    if rawStr == nil or type(rawStr) ~= "string" then return 0 end
    local totalCharCount = self:utf8len(rawStr)
    if maxCharLen == nil or type(maxCharLen) ~= "number" then return totalCharCount end

    local subPos = totalCharCount
    local charLen = 0
    local utf8CharCount = 0
    local currentIndex = 1
    local char = nil
    local chSize = 0
    while currentIndex <= #rawStr do
        char = string.byte(rawStr, currentIndex)
        chSize = self:_chsize(char)
        currentIndex = currentIndex + chSize
        utf8CharCount = utf8CharCount + 1
        if chSize == 1 then
            charLen = charLen + 1
        elseif chSize > 1 then
            charLen = charLen + 2
        end
        if charLen == maxCharLen then
            subPos = utf8CharCount
            break
        elseif charLen > maxCharLen then
            subPos = utf8CharCount - 1
            break
        end
    end
    return subPos
end

--将格式为"xx.xx.xxxxxxxx"的版本号转换为整数，比如"9.5.20160707"可转换为95160707
function StringUtil:convertVersionStrToNumber(versionStr)
    if versionStr == nil or type(versionStr) ~= "string" then return 0 end

    local firstDotIndex = string.find(versionStr, "%.")
    local majorNumStr = string.sub(versionStr, 1, firstDotIndex - 1)
    local leftStr = string.sub(versionStr, firstDotIndex + 1)
    local secondDotIndex = string.find(leftStr, "%.")
    local minorNumStr = string.sub(leftStr, 1, secondDotIndex - 1)
    local datetimeStr = string.sub(leftStr, secondDotIndex + 1)

    return tonumber(majorNumStr..minorNumStr..string.sub(datetimeStr, 3))
end

--超过upUnitValue时，转换为带该单位的简洁数字，并保留decimalDigit位小数
function StringUtil:getConsiseNumber(numValue, unitName, upUnitValue, upUnitName, decimalDigit)
    if type(numValue) ~= "number" or unitName == nil then return end 
    if type(upUnitValue) ~= "number" or upUnitValue == 0 or upUnitName == nil then return end
    if type(decimalDigit) ~= "number" then return end

    if numValue >= upUnitValue then
        return string.format("%0."..decimalDigit.."f", numValue / upUnitValue)..upUnitName
    else
        return numValue..unitName
    end
end

--将保留n位小数的数值整数化，即去除为零的小数部分；如果小数部分不为0，则不做任何处理
function StringUtil:trimZeroDecimal(decimalNum)
    if decimalNum == nil or type(decimalNum) ~= "number" then return nil end

    if math.ceil(decimalNum) == decimalNum then
        return math.ceil(decimalNum)
    end
    return decimalNum
end

return StringUtil
