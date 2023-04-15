local UpdateUtils = {}

local scheduler=cc.Director:getInstance():getScheduler()
function UpdateUtils.scheduleOnce(f,delay)
	local id
	id=scheduler:scheduleScriptFunc(function()
		scheduler:unscheduleScriptEntry(id)
		f()
	end,delay or 0,false)
    return id
end

function UpdateUtils.unschedule(id)
    if id then
        scheduler:unscheduleScriptEntry(id)
    end
end

function UpdateUtils.checkString(string)
    return type(string) == 'string' and string.len(string) > 0
end

function UpdateUtils.checkAppExist(appName)
    if UpdateUtils.checkString(appName) then
        return DeviceUtils:getInstance():isAppInstalled(appName)
    end

    return false
end

function UpdateUtils.cutStrIntoParagraphs(str)
    local utf8String = cc.load('strings').Utf8String
    local paragraphs = {}
    local startPos, endPos, temp = 1, nil, nil
    repeat
        temp, endPos = utf8String.find(str, '\r\n')
        if not endPos then
            table.insert(paragraphs, str)
            return paragraphs
        end
        local paragraph = utf8String.sub(str, startPos, temp-1)
        table.insert(paragraphs, paragraph)
        startPos = endPos + 1
        str = utf8String.sub(str, startPos)
        if str:len() <= 0 then 
            return paragraphs
        end
    until false;
end

cc.exports.UpdateUtils = UpdateUtils

return UpdateUtils