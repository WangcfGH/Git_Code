
local user=mymodel('UserModel'):getInstance()
local device=mymodel('DeviceModel'):getInstance()

local getActivitysBaseUrl=myhttp.getActivitysBaseUrl
local getTime=myhttp.getTime
local countKeyString=myhttp.countKeyString
local getDeviceId=myhttp.getDeviceId

local function getFeedbackBaseUrl()
    local baseUrl
    if BusinessUtils:getInstance():isGameDebugMode() then
        baseUrl='http://talk.uc108.org:1056/client/mobilegameapi.aspx'
    else
        baseUrl='https://talk.tcy365.com/client/mobilegameapi.aspx'
    end
    return baseUrl
end

local function getFeedbackHardSign()
    local hardsignString=string.format('%s%s%s',device.szImeiID,device.szSystemID,device.szWifiID)
    local hardsign=MCCrypto:md5(
        hardsignString,hardsignString:len()
    )
    return hardsign
end

local function getFeedbackSign()
    local hardString=string.format('%d%s%s',user.nUserID or 0,getFeedbackHardSign(),'tcy_feedback')
    local sign=MCCrypto:md5(
        hardString,hardString:len()
    )
    return sign
end

local config={

        -- feedback
        submitFeedbackMessage={
            method='POST',
            baseUrl=getFeedbackBaseUrl(),
            addition='',
            -- deviceType,msg
            exchangeMap={
                system='szDeviceType',
                msg='msg',
                uid='nUserID',
                gameid='nGameID',
                gamever='gameVer',
                sysver='nSysVersion',
                system='szDeviceType',
                brand='szPhoneBrand',
                model='szPhoneModel',
                channelid='szChannelID',
                gamecode ='abbrName',
            },
            privateData={
                action='submit_message',
                hardsign=getFeedbackHardSign,
                sign=getFeedbackSign,
            },
        },
        obtainFeedbackMsgList={
            method='POST',
            baseUrl=getFeedbackBaseUrl(),
            addition='',
            exchangeMap={
                gameid='nGameID',
                uid='nUserID',
            },
            privateData={
                action='get_list',
                hardsign=getFeedbackHardSign,
                sign=getFeedbackSign,
            },
        },
        obtainFeedbackState={
            method='POST',
            baseUrl=getFeedbackBaseUrl(),
            addition='',
            exchangeMap={
                gameid='nGameID',
                uid='nUserID',
            },
            privateData={
                action='check_new_replay',
                hardsign=getFeedbackHardSign,
                sign=getFeedbackSign,
            },
        },

}

myhttp.registConfigList(config)
