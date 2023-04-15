local InviteGiftShareView       = import('src.app.plugins.invitegift.InviteGiftShareView')
local QRCodeCtrl                = require("src.app.BaseModule.QRCode.QRCodeCtrl")
local OldUserInviteGiftModel    = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
local UserModel                 = mymodel('UserModel'):getInstance()

local InviteGiftShareCtrl = class("InviteGiftShareCtrl", myctrl('BaseShareCtrl'))

local IMG_PATH = "QRCodeBG.jpg"
InviteGiftShareCtrl.RUN_ENTERACTION = true

function InviteGiftShareCtrl:onCreate(params)
    local viewNode=self:setViewIndexer(InviteGiftShareView:createViewIndexer())

    self:initEvent()
    self:initClickEvent()

    self._callback = params.callback
end

function InviteGiftShareCtrl:onEnter()
    InviteGiftShareCtrl.super.onEnter(self)
    self:freshView()

    self._viewNode.imgQRCodeBg = self._viewNode:getChildByName("Img_QRCodeBG")
    self._viewNode.panelQRCode = self._viewNode.imgQRCodeBg:getChildByName('Panel_QRCode')
    self._viewNode.panelMask = self._viewNode:getChildByName("Panel_Mask")

    self._viewNode.imgQRCodeBg:hide()
    self._viewNode.panelMask:hide()
end

function InviteGiftShareCtrl:onExit()
    InviteGiftShareCtrl.super.onExit(self)
    if type(self._callback) == "function" then
        self._callback()
    end
end

function InviteGiftShareCtrl:initEvent()
    
end

function InviteGiftShareCtrl:initClickEvent()
    local viewNode = self._viewNode
    if not viewNode then return end

    -- viewNode.checkBoxWord:addClickEventListener(handler(self, self.onSwitchChange))
    -- viewNode.checkBoxImg:addClickEventListener(handler(self, self.onSwitchChange))
    self:addClickEvent(viewNode.checkBoxWord, handler(self, self.onSwitchChange))
    self:addClickEvent(viewNode.checkBoxImg, handler(self, self.onSwitchChange))
    self:addClickEvent(viewNode.closeBt, handler(self, self.onCloseBtnClick), true)
    self:addClickEvent(viewNode.shareToWechat, handler(self, self.onShareToWechatBtnClick))
    self:addClickEvent(viewNode.shareToWechat2, handler(self, self.onShareToWechatBtnClick))
end

function InviteGiftShareCtrl:freshView()
    local viewNode = self._viewNode
    if not viewNode then return end

    if device.platform == "ios" then
        viewNode:switchShareType(InviteGiftShareView.SwitchType.WORD)
        viewNode.panelShareType:hide()
        viewNode.imgTitle:show()
    else
        viewNode.imgTitle:hide()
        if OldUserInviteGiftModel:getDefaultShareType() == 1 then
            viewNode:switchShareType(InviteGiftShareView.SwitchType.IMAGE)
            viewNode.checkBoxImg:setSelected(true)
        else
            viewNode:switchShareType(InviteGiftShareView.SwitchType.WORD)
            viewNode.checkBoxWord:setSelected(true)
        end
    end

    if not viewNode.progress then
        local progress = self:createProgress()
        viewNode.ImgProgressBg:addChild(progress)
        local size = viewNode.ImgProgressBg:getContentSize()
        progress:setPosition(cc.p(size.width / 2, size.height / 2))
        viewNode.progress = progress
    end

    -- 根据当前数据显示相应的阶段
    if (not OldUserInviteGiftModel:isBinding()) or (OldUserInviteGiftModel:isBinding() and OldUserInviteGiftModel:isBindUserAllRewarded()) or OldUserInviteGiftModel:isRewardMax() then
        self:setStage(1)
    elseif OldUserInviteGiftModel:isBinding() and OldUserInviteGiftModel:isEnableReward() then
        self:setStage(3)
    elseif OldUserInviteGiftModel:isBinding() and (not OldUserInviteGiftModel:isEnableReward()) then
        self:setStage(2)
    end
end

function InviteGiftShareCtrl:setStage(stage)
    local viewNode = self._viewNode

    -- 节点
    for i = 1, 3 do
        viewNode['checkBoxPoint' .. i]:setSelected(false)
        viewNode['checkBoxPoint' .. i]:setEnabled(false)
        viewNode['checkBoxPoint' .. i]:setScale(1)
        viewNode['checkBoxPoint' .. i]:stopAllActions()
    end
    for i = 1, stage do
        viewNode['checkBoxPoint' .. i]:setSelected(true)
    end
    viewNode['checkBoxPoint' .. stage]:setScale(0.8)
    local actScale1 = cc.ScaleTo:create(0.6, 1.15)
    local act1 = cc.EaseInOut:create(actScale1, 2)
    local actScale2 = cc.ScaleTo:create(0.6, 0.85)
    local act2 = cc.EaseInOut:create(actScale2, 2)
    local sequence = cc.Sequence:create(act1, act2)
    local animation = cc.RepeatForever:create(sequence)
    viewNode['checkBoxPoint' .. stage]:runAction(animation)

    -- 进度条
    viewNode.progress:stopAllActions()
    if stage ~= 3 then
        local origin = 0
        if stage == 1 then origin = 10 else origin = 60 end
        viewNode.progress:setPercentage(origin)
        
        local act1 = cc.ProgressTo:create(0.6, origin + 15)
        local act1_1 = cc.EaseInOut:create(act1, 2)
        local act2 = cc.ProgressTo:create(0.6, origin)
        local act2_1 = cc.EaseInOut:create(act2, 2)
        local sequence = cc.Sequence:create(act1_1, act2_1)
        local animation = cc.RepeatForever:create(sequence)
        viewNode.progress:runAction(animation)
    else
        viewNode.progress:setPercentage(100)
    end
    
end

-- 生成进度条
function InviteGiftShareCtrl:createProgress()
    cc.SpriteFrameCache:getInstance():addSpriteFrames('res/hallcocosstudio/images/plist/InviteShare.plist')
    local sprite = display.newSprite()
    sprite:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("hallcocosstudio/images/plist/InviteShare/wechat_progress_main.png"))
    local progress = cc.ProgressTimer:create(sprite)
    progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    progress:setMidpoint(cc.p(0, 1))
    progress:setBarChangeRate(cc.p(1, 0))
    progress:setPercentage(0)
    return progress
end

-- 生成最终的分享图片
function InviteGiftShareCtrl:generateShareImg(str, path)
    self._viewNode.imgQRCodeBg:show()
    self._viewNode.panelMask:show()
    QRCodeCtrl:drawQRCode(self._viewNode.panelQRCode, str)
    -- 将图片输出到本地
    cc.exports.outputNodeTexture(self._viewNode.imgQRCodeBg, path, cc.IMAGE_FORMAT_JPEG, cc.p(1.67, 1.67))
    my.scheduleOnce(function ()
        self._viewNode.panelQRCode:removeAllChildren()
        self._viewNode.imgQRCodeBg:hide()
        self._viewNode.panelMask:hide()
    end, 0)
end

-- 生成分享的口令
function InviteGiftShareCtrl:generateShareWord()
    local userIdStr = tostring(UserModel.nUserID)
    local resStr = ""
    local len = #userIdStr
    local times = math.ceil(len / 3)
    local pos = 1
    for i = 1, times do
        local str = string.sub(userIdStr, pos, pos + 2)
        local encodeRes = MCCrypto:encodeBase64(str, #str)
        resStr = resStr .. encodeRes .. '/'
        pos = pos + 3
    end

    local config = OldUserInviteGiftModel:getConfig()
    
    return resStr .. config.activityID
end

-- 生成分享url
function InviteGiftShareCtrl:generateShareUrl(cmd, isCmdDomain)
    local config = OldUserInviteGiftModel:getConfig()
    local baseurl = ""
    if isCmdDomain then
        baseurl = config.oldUser.urlCmd
    else
        baseurl = config.oldUser.urlCode
    end
    
    local url = baseurl .. "?c=" .. cmd
    return url
end

-- 获取二维码的分享参数列表
function InviteGiftShareCtrl:getQrCodeShareContent()
    local strCmd = self:generateShareWord()
    local url = self:generateShareUrl(strCmd, false)

    self:generateShareImg(url, IMG_PATH)

    local tbl = {
        content = "",
        title = "",
        image = IMG_PATH,
        description = "",
        type = tostring(cc.exports.C2DXContentType["C2DXContentTypeImage"])
    }

    local fileutils = cc.FileUtils:getInstance()
    local writablePath = fileutils:getGameWritablePath()

    if tbl["image"] then
        tbl["image"] = writablePath .. tbl["image"]
        tbl["imagePath"] = tbl["image"]
    end

    return tbl
end

-- 获取口令的分享参数列表
function InviteGiftShareCtrl:getWordShareContent()
    local strCmd = self:generateShareWord()
    local url = self:generateShareUrl(strCmd, true)

    local tbl = {
        content = "复制此消息，打开「同城游掼蛋」，领10元！戳" .. url .." 下载",
        title = " ",
        description = " ",
        url = url,
        type = tostring(cc.exports.C2DXContentType["C2DXContentTypeText"])
    }

    return tbl
end

-- 分享成功回调
function InviteGiftShareCtrl:onShareSuccess()
    -- 刷新进度条
    if (not OldUserInviteGiftModel:isBinding()) or (OldUserInviteGiftModel:isBinding() and OldUserInviteGiftModel:isBindUserAllRewarded()) or OldUserInviteGiftModel:isRewardMax() then
        self:setStage(1)
    elseif OldUserInviteGiftModel:isBinding() and OldUserInviteGiftModel:isEnableReward() then
        self:setStage(3)
    elseif OldUserInviteGiftModel:isBinding() and (not OldUserInviteGiftModel:isEnableReward()) then
        self:setStage(2)
    end
end

function InviteGiftShareCtrl:onSwitchChange(sender)
    local viewNode = self._viewNode
    if not viewNode then return end

    local name = sender:getName()
    if name == 'CheckBox_ImgShare' then
        viewNode:switchShareType(InviteGiftShareView.SwitchType.IMAGE)
    else
        viewNode:switchShareType(InviteGiftShareView.SwitchType.WORD)
    end
end

function InviteGiftShareCtrl:onShareToWechatBtnClick()
    local viewNode = self._viewNode
    if not viewNode then return end

    local sharedType = viewNode:getShareType()

    if sharedType == InviteGiftShareView.SwitchType.WORD then
        -- 口令分享
        my.dataLink(cc.exports.DataLinkCodeDef.SHARECMD)
        local shareContent = self:getWordShareContent()
        self:share(shareContent, C2DXPlatType.C2DXPlatTypeWeixiSession)
    elseif sharedType == InviteGiftShareView.SwitchType.IMAGE then
        -- 图片（二维码分享）
        my.dataLink(cc.exports.DataLinkCodeDef.SHAREIMG)
        local shareContent = self:getQrCodeShareContent()
        my.scheduleOnce(function ()
            self:share(shareContent, C2DXPlatType.C2DXPlatTypeWeixiSession)
        end, 0.3)
    end
end

function InviteGiftShareCtrl:onCloseBtnClick()
    self:onKeyBack()
end

return InviteGiftShareCtrl