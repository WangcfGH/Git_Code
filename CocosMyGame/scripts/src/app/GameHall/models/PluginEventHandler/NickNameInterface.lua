local NickNameInterface = cc.exports.NickNameInterface
if NickNameInterface then
    return
else
    NickNameInterface = {}
    cc.exports.NickNameInterface = NickNameInterface
end

local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()

function NickNameInterface.getNickName()
    if type(userPlugin.getNickName) == 'function' then
        return userPlugin:getNickName()
    else
        print('NickNameInterface.getNickName: engine is not support this function.')
    end
end

function NickNameInterface.modifyNickName()
    if type(userPlugin.modifyNickName) == 'function' then
        userPlugin:modifyNickName()
    else
        print('NickNameInterface.getNickName: engine is not support this function.')
    end
end

function NickNameInterface.getUserDetailInfo(resultCallback)
    if not isModifyNickNameSupported() then
        print('modify nick name is not supported')

        if type(resultCallback) == 'function' then
            resultCallback()
        end

        return
    end

    if userPlugin.getUserDetailInfo then
        print('NickNameInterface.getUserDetailInfo')
        userPlugin:getUserDetailInfo(function(code, msg, detail)
            dump(detail)
            if code == 0 then -- OK
                NickNameInterface.isSupportModifyNickName = detail.supportNickModify
            else
                printf('NickNameInterface.getUserDetailInfo failed. code: %d, msg: %s', code, msg)
            end

            if type(resultCallback) == 'function' then
                resultCallback()
            end

        end)
    else
        print('NickNameInterface.getUserDetailInfo: engine is not support this function.')    
    end
end

function NickNameInterface.resetUserDetailInfo()
    NickNameInterface.isSupportModifyNickName = nil
end

return NickNameInterface