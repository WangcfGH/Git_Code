local HttpUtils = cc.exports.HttpUtils
if HttpUtils then
    return HttpUtils
end

HttpUtils = {__cname = 'HttpUtils'}

function HttpUtils.httpPost(url, params, callback, api, headers)
    local xhr = cc.XMLHttpRequestExt:new()
    xhr.responseType = 0
    xhr:setRequestHeader('Content-Type', 'application/json')
    if type(headers) == "table" then
        for key, value in pairs(headers) do
            xhr:setRequestHeader(key, value)
        end
    end
    url = HttpUtils.mosaicUrl(url, api or '', {})
    xhr:open('POST', url)
    xhr:registerScriptHandler( function()
        printLog('HttpUtils', 'response: %s', xhr.response)
        callback(xhr)
    end )
    local sendStr = HttpUtils.makeJsonStr(params)
    xhr:send(sendStr)
    printLog('HttpUtils', 'http post url: %s, params: %s', url, sendStr)
end

function HttpUtils.httpGet(url, params, callback, api, headers)
    local xhr = cc.XMLHttpRequestExt:new()
    xhr.responseType = 0
    url = HttpUtils.mosaicUrl(url, api or '', params)
    xhr:open('GET', url)
    if type(headers) == "table" then
        for key, value in pairs(headers) do
            xhr:setRequestHeader(key, value)
        end
    end
    xhr:registerScriptHandler( function()
        printLog('HttpUtils', 'response: %s', xhr.response)
        callback(xhr)
    end )
    xhr:send()
    printLog('HttpUtils', 'http get url: %s', url)
end

function HttpUtils.makeJsonStr(params)
    local str = '{'
    for k, v in pairs(params) do
        if type(v) == 'table' then
            if next(v) then
                v = HttpUtils.makeJsonStr(v)
            else
                v = '""'
            end
        else
            v = string.format('"%s"', tostring(v))
        end

        str = str .. string.format('"%s":%s,', k, v)
    end
    str = string.sub(str, 1, string.len(str) -1) .. '}'

    return str
end

function HttpUtils.mosaicUrl(baseUrl, api, params)
    local url = baseUrl .. api
    local paramIndex = 1

    if type(params) == 'table' then
        for k, v in pairs(params) do
            url = url .. k .. '=' .. v
            if paramIndex < table.nums(params) then
                url = url .. '&'
            end
            paramIndex = paramIndex + 1
        end
    else
        url = url .. params
    end

    return url
end

cc.exports.HttpUtils = HttpUtils
return HttpUtils