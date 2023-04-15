
local function getInviteGiftApiUrl()
    if (BusinessUtils:getInstance():isGameDebugMode()) then
        return "http://invitegiftapi.ct108.org:1505/"
    end
    return "http://invitegiftapi.ct108.net/"
end

local function getInviteGiftShareUrl()
    return (getInviteGiftApiUrl() .. "index.html")
end

local config={
        queryInviteGift={
            baseUrl=getInviteGiftApiUrl(),
            addition='/api/Invite/GetGifts',
            exchangeMap={
                activityid='InviteGiftActId',
            },
            privateData={
                input_charset='UTF-8',
            },
        }
}

myhttp.registConfigList(config)

return {
    baseUrl = getInviteGiftApiUrl(),
    shareUrl = getInviteGiftShareUrl(),
}