local InviteGiftCtrl    = class('InviteGiftCtrl', myctrl('BaseShareCtrl'))

local InviteGiftModel   = require('src.app.plugins.invitegift.InviteGiftModel'):getInstance()
local user              = mymodel('UserModel'):getInstance()
local activitysConfig   = require('src.app.HallConfig.ActivitysConfig')
local inviteGiftConfig  = require('src.app.plugins.invitegift.InviteGiftConfig')

InviteGiftCtrl.LOGUI = 'InviteGift'

InviteGiftCtrl.RUN_ENTERACTION = true

InviteGiftCtrl.SHARE_SOURCE_TYPE = 
{
    WEIXIN_WECHAT = 0,  --微信好友
    WEIXIN_FRIEND_Corner = 1  --微信朋友圈
}

-- 1:银子;2:兑换券;3:积分;4:话费;5:***;6:***券;7:其他;
InviteGiftCtrl.HAPPY_COIN_TYPE = 5
InviteGiftCtrl.AWARD_TYPE_TO_IMAGE = 
{
    [1] = "res/hall/hallpic/commonitems/commonitem3.png",
    [2] = "res/hall/hallpic/commonitems/commonitem1.png",
    [3] = "res/hall/hallpic/commonitems/commonitem4.png",
    [4] = "res/hall/hallpic/commonitems/commonitem8.png",
    [5] = "res/hall/hallpic/commonitems/commonitem2.png",
    [6] = "res/hall/hallpic/commonitems/commonitem9.png",
    [7] = "res/hall/hallpic/commonitems/commonitem6.png",
}

function InviteGiftCtrl:getViewCreater()
    return require('src.app.plugins.invitegift.InviteGiftView')
end

function InviteGiftCtrl:onCreate( params )
    local viewNode=self:setViewIndexer(self:getViewCreater():createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
    self:bindUserEventHandler(viewNode, { 'shareToWechat', 'shareToFriendsCorner'})

    self:listenTo(InviteGiftModel, InviteGiftModel.EVENT_INVITE_GIFT_INFO, handler(self, self.updateGiftView))

    self:initShareConfig()
end

function InviteGiftCtrl:initShareConfig()
    self._shareObj = self:getShareConfig()
end

function InviteGiftCtrl:onEnter()
    InviteGiftCtrl.super.onEnter(self)
    InviteGiftModel:queryInviteGift()
end

function InviteGiftCtrl:onKeyBack()
    InviteGiftCtrl.super.onKeyBack(self)
end

function InviteGiftCtrl:updateGiftView( data )
    local giftInfo = data.value
    if not data or not data.value or giftInfo.StatusCode ~= 0 or not giftInfo.Data then
        my.informPluginByName( { pluginName = 'ToastPlugin', params = { tipString = "数据获取失败", removeTime = 3 } })
        return
    end
    local viewNode = self._viewNode

    self:fillGiftList(viewNode.yourGiftList, giftInfo.Data.InviteGifts, 3)
    self:fillGiftList(viewNode.friendGiftList, giftInfo.Data.InvitedGifts, 2)
end

function InviteGiftCtrl:fillGiftList( view, data, maxCount )
    local rewardCount = #data
    local itemWidth = 124
    local itemInterval = 0
    local sizeWidth = rewardCount * itemWidth + (rewardCount - 1) * itemInterval
    if rewardCount <= maxCount then
        view:setContentSize(sizeWidth, view:getContentSize().height)
    else
        view:setContentSize(maxCount * itemWidth + (rewardCount - 1) * itemInterval + 20, view:getContentSize().height)
    end
    view:setInnerContainerSize(cc.size(sizeWidth, view:getContentSize().height))
    for i, v in ipairs( data ) do
        local rewardItem = cc.CSLoader:createNode("res/hallcocosstudio/invite/invite_itemunit.csb")
        local rewardItemMain = rewardItem:getChildByName("Panel_Main")
        rewardItem:removeChild(rewardItemMain, true)

        if InviteGiftCtrl.AWARD_TYPE_TO_IMAGE[v.ItemTypeId] then
            rewardItemMain:getChildByName("Img_Items"):loadTexture(InviteGiftCtrl.AWARD_TYPE_TO_IMAGE[v.ItemTypeId])
        else
            rewardItemMain:getChildByName("Img_Items"):loadTexture(InviteGiftCtrl.AWARD_TYPE_TO_IMAGE[7])
        end
        local RewardNum = v.Number
        if v.RewardType == InviteGiftCtrl.HAPPY_COIN_TYPE then
            RewardNum = RewardNum / 10
        end
        local nameText = rewardItemMain:getChildByName("Text_Name")
        my.fitStringInWidget(v.Name, nameText, 90)
        if RewardNum > 99 then
            RewardNum = 99
        end
        nameText:setString(nameText:getString() .. "×" .. RewardNum)
        
        rewardItemMain:setPositionX((i - 1)* (itemWidth + itemInterval))
        view:addChild(rewardItemMain)
    end
end

function InviteGiftCtrl:shareToWechatClicked()
    local shareObj = self:_makeShareObj('ToWechat_InviteGift', InviteGiftCtrl.SHARE_SOURCE_TYPE.WEIXIN_WECHAT)
    if not shareObj.url then
        return
    end
    dump(shareObj)
    self:share(shareObj, C2DXPlatType.C2DXPlatTypeWeixiSession)
    self:removeSelfInstance()
end

function InviteGiftCtrl:shareToFriendsCornerClicked()
    local shareObj = self:_makeShareObj('ToWeiXinFriendCorner_InviteGift', InviteGiftCtrl.SHARE_SOURCE_TYPE.WEIXIN_FRIEND_Corner)
    if not shareObj.url then
        return
    end
    self:share(shareObj, C2DXPlatType.C2DXPlatTypeWeixiTimeline)
    self:removeSelfInstance()
end

function InviteGiftCtrl:_makeShareObj(configName, sourceType)
    local shareObj = clone(self._shareObj[configName])

    self:_fillLinkShareObj(shareObj, sourceType)

    return shareObj
end

function InviteGiftCtrl:_fillLinkShareObj(shareObj, sourceType)
    shareObj.url        = self:_makeShareUrl(sourceType)
    shareObj.type       = tostring(C2DXContentType.C2DXContentTypeNews)
    local imageName     = shareObj.image
    shareObj.image      = self:loadShareImg(imageName)
    shareObj.imagePath  = self:loadShareImg(imageName)
end

function InviteGiftCtrl:_makeShareUrl(sourceType)
    local wechatInfo = user:getWechatInfo() or {}
    --[[if not wechatInfo or not wechatInfo.headurl or not wechatInfo.nickname then
        my.informPluginByName( { pluginName = 'ToastPlugin', params = { tipString = "请先登录微信", removeTime = 3 } })
        return
    end]]
    local json = cc.load("json").json

    local keyString=string.format('%s&%d&%d&%s',my.getAbbrName(), sourceType, user.nUserID, InviteGiftModel.SIGN_KEY)
    local md5String=my.md5(keyString)

    local urlParams = {
        abbr = my.getAbbrName(),
        t = YQWShareType.YQWShareType_InviteGift,
        type = sourceType,
        userid = user.nUserID,
        gtime = user.nExperience,
        happy = user.nTotalBalance,
        actid = activitysConfig.InviteGiftActId,
        stime = math.floor(socket.gettime() * 1000),
        sign = md5String,
        --name = wechatInfo.nickname or "",
        img = wechatInfo.headurl  or "",
        wxkey = UserPlugin:getThirdAppId("weixin")
        --appid = "",
    }
    --参数为nil
    --[[if table.nums(urlParams) ~= 8 then
        return
    end]]
    dump(urlParams)
    local urlData = json.encode(urlParams)

    --local data = MCCrypto:encodeBase64(urlData, urlData:len())
    --data = string.urlencode(data)
    --local data = string.urlencode(urlData)
    --data = MCCrypto:encodeBase64(data, data:len())
    --local url = inviteGiftConfig.shareUrl .. "?data=" .. data

    local url = BusinessUtils:getInstance():encodeShareUrl(urlData, inviteGiftConfig.shareUrl)

    local name = wechatInfo.nickname or ""
    if name ~= "" then
        local nameUrl = BusinessUtils:getInstance():encodeShareUrl(name, inviteGiftConfig.shareUrl)
        print(nameUrl)
        local beginPos, endPos = string.find(nameUrl, "?data=")
        local signBeginPos, signEndPos = string.find(nameUrl, "&signkey")
        if endPos and signBeginPos then
            name = string.sub(nameUrl, endPos + 1, signBeginPos - 1)
        end
    end
    
    url = url .. "&invitewxname=" .. name
    print(url)
    return url
end

return InviteGiftCtrl
