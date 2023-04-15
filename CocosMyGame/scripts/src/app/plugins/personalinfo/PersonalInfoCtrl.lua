local viewCreater       = import('src.app.plugins.personalinfo.PersonalInfoView')
local player            = mymodel('hallext.PlayerModel'):getInstance()
local gamemodel         = mymodel('GameModel'):getInstance()
local levelconfig       = require('src.app.plugins.personalinfo.LevelConfig')
local levelstrings      = cc.load('json').loader.loadFile('LevelStrings')
local userPlugin        = plugin.AgentManager:getInstance():getUserPlugin()
local imageCtrl = require('src.app.BaseModule.ImageCtrl')
local PersonalInfoCtrl  = class('PersonalInfoCtrl', cc.load('SceneCtrl'))
local UserModel = mymodel('UserModel'):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()

PersonalInfoCtrl.DATA_PAGE  = 1
PersonalInfoCtrl.GOODS_PAGE = 2

PersonalInfoCtrl.EVENT_UPLOADIMAGE_SUCCEEDED = 'uploadImage succeeded'

local event = cc.load('event')
event:create():bind(PersonalInfoCtrl)

local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local UserLevelModel = import("src.app.plugins.personalinfo.UserLevelModel"):getInstance()

local RoomConfig = cc.exports.GetRoomConfig()

function PersonalInfoCtrl:onCreate( ... )
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())

    self:bindUserEventHandler({titlesRd=viewNode.titlesRd})
    self:bindProperty(player,'PlayerData',self,'PlayerData')
    self:bindDestroyButton(viewNode.backBt)
    --[[self:setOnExitCallback(function()
		require("src.app.plugins.roomspanel.RoomsCtrl"):playTipAni()
	end)]]--
    self._curPage=self.DATA_PAGE
    self:listenTo(player, player.PLAYER_DATA_UPDATED, handler(self, self.setMobile))
    self:listenTo(player, player.PLAYER_PORTRAIT_UPDATED,handler(self, self.onPortraitUpdated))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getInfoDataFromSvr"], handler(self, self.refreshTimingView))

    if cc.exports.isSocialSupported() then
        viewNode.Image_cover:onTouch(function(e)
            print('Image_cover')
            if e.name == "began" then 
                print("began")
                local myFade220 = cc.FadeTo:create(0,220)
                viewNode.Image_juesedikuang:runAction(myFade220)
            elseif e.name == "cancelled" then 
                local myFade255 = cc.FadeTo:create(0,255)
                viewNode.Image_juesedikuang:runAction(myFade255)
            elseif e.name == 'ended' then 
                local myFade255 = cc.FadeTo:create(0,255)
                viewNode.Image_juesedikuang:runAction(myFade255)
                print('Image_cover touched    1')
                local uploaderPlugin = plugin.AgentManager:getInstance():getUploaderPlugin()
                local gameId = my.getGameID()
                local userId = UserModel.nUserID
                --local uploaderPluginCallback = require('src.app.GameHall.models.PluginEventHandler.UploaderPluginCallback')
                uploaderPlugin:startUpload(gameId, userId, userPlugin:getAccessToken(), DEBUG>0, handler(self,self.onUploadImageFinished))
            end
        end)
		if cc.exports.isUploadHeadIconSupported() then
			viewNode.Image_cover:setVisible(true)
		else
			viewNode.Image_cover:setVisible(false)
		end
    else
        viewNode.Image_cover:setVisible(false)
    end

    self:setMobile()
    
    viewNode.userNewLevelTxt:setString( RoomConfig["PERSONAL_DATA_DEFAULT"])
    viewNode.userExchangeTxt:setString( RoomConfig["PERSONAL_DATA_DEFAULT"])
    viewNode.userGameLevelBg:setVisible(false)
    self:onUpdateSelfLevel()

    --监听等级的
    self:listenTo(UserLevelModel, UserLevelModel.UPDATE_SELF_LEVEL_DATA, handler(self,self.onUpdateSelfLevel))
    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.TICKET_LEFT_NUM_UPDATED, handler(self, self.updatePlayerExchangeInfo))

    player:getPortraitInfo()
end

function PersonalInfoCtrl:onPortraitUpdated()
    self:loadPortrait()
end

function PersonalInfoCtrl:loadPortrait()
    print('PersonalInfoCtrl:loadPortrait')
    if not isSocialSupported() then return end
    local viewNode = self._viewNode

    local portraitStatus = UserModel:getPortraitStatus()
    viewNode.Flag_icon_duringaudit:setVisible(portraitStatus == PortraitStatus.AUDITTING)
    viewNode.Flag_icon_auditfailed:setVisible(portraitStatus == PortraitStatus.DENIED)
    print("portraitStatus "..tostring(portraitStatus))

    local portraitPath = UserModel:getPortraitPath()
    print("portraitPath "..tostring(portraitPath))
    if type(portraitPath) == "string" and portraitPath ~= "" then
        viewNode.Image_juesedikuang:loadTexture(portraitPath)
        viewNode.Image_juesedikuang:setVisible(true)
        viewNode.Image_juesedikuang:setContentSize(viewNode.girlPic:getContentSize())
        viewNode.girlPic:setVisible(false)
    else
        viewNode.Image_juesedikuang:setVisible(false)
        viewNode.girlPic:setVisible(true)
    end
end

function PersonalInfoCtrl:setMobile()
    print('PersonalInfoCtrl setMobile')
    local viewNode = self._viewNode
    if userPlugin:isBindMobile() then 
        print('PersonalInfoCtrl setMobile isBindMobile')
	    viewNode.userPhoneUnbindedTxt:setVisible(false)
	    viewNode.userPhoneBangdingBt:setVisible(false)
	    viewNode.userPhoneNumberTxt:setString(userPlugin:getMobile())
	    viewNode.userPhoneNumberTxt:setVisible(true)
	    viewNode.userPhoneXiugaiBt:setVisible(true)
    else
        print('PersonalInfoCtrl setMobile isnotBindMobile')
	    viewNode.userPhoneNumberTxt:setVisible(false)
	    viewNode.userPhoneXiugaiBt:setVisible(false)
	    viewNode.userPhoneUnbindedTxt:setVisible(true)
	    viewNode.userPhoneBangdingBt:setVisible(true)
    end  
    
    if not cc.exports.isBindphoneSupported() then
        viewNode.userPhoneTable:setVisible(false)        
    else
        viewNode.userPhoneTable:setVisible(true)
    end

    if not cc.exports.isModifyphoneSupported() then
        if viewNode.userPhoneBangdingBt then
            viewNode.userPhoneBangdingBt:setVisible(false)
        end

        if viewNode.userPhoneXiugaiBt then
            viewNode.userPhoneXiugaiBt:setVisible(false)
        end
    else
        if viewNode.userPhoneBangdingBt then
            viewNode.userPhoneBangdingBt:setVisible(true)
        end

        if viewNode.userPhoneXiugaiBt then
            viewNode.userPhoneXiugaiBt:setVisible(true)
        end
    end
end

function PersonalInfoCtrl:onEnter()
    my.scheduleOnce(function()
        player:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

        UserLevelModel:sendGetUserLevelReqForMySelf()
    end,1)
    self:updatePlayerExchangeInfo()
end

--[[function PersonalInfoCtrl:onExit()
end]]--

function PersonalInfoCtrl:titlesRdClicked(e)
    print(e.index)
    self._curPage=e.index
end

function PersonalInfoCtrl:setPlayerData(data)

    local viewNode=self._viewNode
    --viewNode.userIdTxt:setString('ID:'..tostring(data.nUserID))
    viewNode.userIdTxt:setString(RoomConfig["PERSONAL_PLAY_ID"]..tostring(data.nUserID))
    
    viewNode.usernameTxt:setString(data.szUtf8UsernameRaw)
    if not userPlugin:isFunctionSupported("modifyUserName") then 
        print('modifyUserName not supported')
    	viewNode.usernameSetBt:setVisible(false)
        viewNode.usernameTable:setEnabled(false)
    end
    viewNode.userGameDepositTxt:setString(data.nDeposit)
    viewNode.userGameDepositTxt2:setString(data.nDeposit)
    viewNode.userScoreTxt:setString(data.nScore)
    viewNode.userSafeboxDepositTxt:setString(data.nSafeboxDeposit)
    if cc.exports.isBackBoxSupported() then
       viewNode.userSafeboxDepositTxt:setString(data.nBackDeposit)
    end

    local level

    if cc.exports.isDepositSupported() then
        level=levelconfig.getLevelStringId(data.nDeposit)
    else
        if cc.exports.isScoreSupported() then
            level=levelconfig.getLevelStringId(data.nScore)
        end
    end

    local levelString=levelstrings[level]

    if(data.nBout)then
        viewNode.userLevelTxt:setString("("..levelString..")")
        local str
        str=string.format(cc.exports.GetRoomConfig()["achievement"],data.nWin,data.nLoss,data.nStandOff)
        viewNode.userWinRateTxt:setString(str..'('..tostring(data.nBout~=0 and math.modf(100*data.nWin/data.nBout) or 0)..'%)')
    end

    viewNode.productInfoVipNode:setVisible(true)
    viewNode.exchangeInfoNode:setVisible(true)

    if(self._curPage==self.GOODS_PAGE)then
        viewNode.goodsScroll:setVisible(true)
    else
        viewNode.goodsScroll:setVisible(false)
    end
    
    if(self.outlineStringFormat==nil)then
        self.outlineStringFormat=viewNode.outlineTxt:getString()
    end
    if(self.exchangeNumStringFormat==nil)then
        self.exchangeNumStringFormat=viewNode.exchangeNumTxt:getString()
    end
    if(data.isMember)then
        if(data.memberInfo)then
            local endline=data.memberInfo.endline
            viewNode.outlineTxt:setString(
                string.format(self.outlineStringFormat,endline.nYearEnd,endline.nMonthEnd,endline.nDayEnd)
            )
        end
    else
        viewNode.outlineTxt:setString(RoomConfig["PLAYER_INFO_NO_VIP_TXT"])
    end

    viewNode.exchangeNumTxt:setString( string.format(self.exchangeNumStringFormat,ExchangeCenterModel._ticketLeftNum))
    local NobilityPrivilegeGiftModel      = import("src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftModel"):getInstance()
    if not NobilityPrivilegeGiftModel:isNeedPop() then
        viewNode.productInfoVipNode:setVisible(false)
        local pos = cc.p(viewNode.productInfoVipNode:getPosition())
        viewNode.exchangeInfoNode:setPosition(pos)
        local size = viewNode.exchangeInfoNode:getContentSize()
        pos.y = pos.y - size.height
        viewNode.timingTicketLimitNode:setPosition(pos)
        pos.y = pos.y - size.height
        viewNode.timingTicketNode:setPosition(pos)
    end

    self:refreshTimingView()

    viewNode:setSex(UserModel:getSexName() == "girl")

    self:loadPortrait()
end

function PersonalInfoCtrl:refreshTimingView()
    local viewNode=self._viewNode

    --初始化定时赛相关的物品
    local infoData = TimingGameModel:getInfoData() 
    if infoData then
        local limitCount = TimingGameModel:getTaskTicketCount()
        local date = tonumber(os.date("%Y%m%d", TimingGameModel:getCurrentTime()))
        local sec = TimingGameModel:getCurrentTime() + 3600 * 24
        local dataTbl = os.date("*t", sec)
        if limitCount > 0 then
            viewNode.timingLimitTipTxt:setString(string.format("(%d年%02d月%02d日0点过期)",
             dataTbl.year, dataTbl.month, dataTbl.day))
            viewNode.timingLimitNumTxt:setString(string.format("数量:%d", limitCount))
        end
        if limitCount <= 0 then
            viewNode.timingTicketLimitNode:setVisible(false)
            viewNode.timingTicketNode:setPosition(viewNode.timingTicketLimitNode:getPosition())
        end
        local buyCount = infoData.buyTicketNum
        viewNode.timingTicketNumTxt:setString(string.format("数量:%d", buyCount))
    else
        viewNode.timingTicketLimitNode:setVisible(false)
        viewNode.timingTicketNode:setVisible(false)
    end
end

function PersonalInfoCtrl:userManagerBtClicked(e)
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    if(userPlugin:isFunctionSupported('enterPlatform'))then
        userPlugin:enterPlatform()
    end
end

--[[function PersonalInfoCtrl:onUploadImageFinished(code, msg, url, path)

    print("uploadImageCallback")
    printf("code = " .. code)
    printf("msg = " .. msg)
    printf("url = " .. url)
    printf("path = " .. path)
    
    local config = cc.exports.GetRoomConfig()
    local mssg = nil
    if code == cc.exports.UploadActionResultCode.kUploadSuccess then 
        print('upLoad image succeed')
        local imageLoaderPlugin = plugin.AgentManager:getInstance():getImageLoaderPlugin()
        local userId = mymodel('UserModel'):getInstance().nUserID
        imageLoaderPlugin:deleteImageData(userId)
        imageLoaderPlugin:setImageData(userId, url, path, '500-500')
		self.loadPortrait()
        player:getPortraitInfo()
		PersonalInfoCtrl:dispatchEvent({name = PersonalInfoCtrl.EVENT_UPLOADIMAGE_SUCCEEDED})
        mssg = config["UPLOAD_SUCCESS"]
    elseif code == cc.exports.UploadActionResultCode.kUploadFailed then 
        print('upLoad image failed')
        mssg = config["UPLOAD_FAILED"]
    else
        print('uknown code')
        mssg = config["UNKOWN_FAILED"]
    end
    my.informPluginByName({pluginName='TipPlugin',params={tipString=mssg,removeTime=2}})
    
end]]--

function PersonalInfoCtrl:onUploadImageFinished(code, msg, url, path)

    print("uploadImageCallback")
    printf("code = " .. code)
    printf("msg = " .. msg)
    printf("url = " .. url)
    printf("path = " .. path)
    
    local config = cc.exports.GetRoomConfig()
    local mssg = nil
    if code == UploadActionResultCode.kUploadSuccess then
        print('upLoad image succeed')
        local imageLoaderPlugin = plugin.AgentManager:getInstance():getImageLoaderPlugin()
        local userId = mymodel('UserModel'):getInstance().nUserID
        imageLoaderPlugin:deleteImageData(userId)
        imageLoaderPlugin:setImageData(userId, url, path, '500-500')
        player:getPortraitInfo()
        PersonalInfoCtrl:dispatchEvent( { name = PersonalInfoCtrl.EVENT_UPLOADIMAGE_SUCCEEDED })
        mssg = config["UPLOAD_SUCCESS"]
    elseif code == UploadActionResultCode.kUploadFailed then
        print('upLoad image failed')
        mssg = config["UPLOAD_FAILED"]
    else
        print('uknown code')
        mssg = config["UNKOWN_FAILED"]
    end
    my.informPluginByName({pluginName='TipPlugin',params={tipString=mssg,removeTime=2}})
    
end

function PersonalInfoCtrl:onUpdateSelfLevel()
    local viewNode = self._viewNode
    if cc.exports._userLevelData.nLevel then
        viewNode.userNewLevelTxt:setString(tostring(cc.exports._userLevelData.nLevel).."("..RoomConfig["LEVEL_TXT"]..tostring(cc.exports._userLevelData.nLevelExp).."/"..tostring(cc.exports._userLevelData.nNextExp)..")")
        
        viewNode.userGameLevelBg:setVisible(true)
        local BGResName, ColorResName, levelString =  cc.exports.LevelResAndTextForData(cc.exports._userLevelData.nLevel)
        viewNode.userGameLevelBg:loadTexture(BGResName)
        viewNode.userGameLevelColor:loadTexture(ColorResName)
        viewNode.userGameLevelNum:setString(levelString)
    end
end

function PersonalInfoCtrl:updatePlayerExchangeInfo()
    --兑换券数量刷新
    if ExchangeCenterModel._ticketLeftNum then
        print(ExchangeCenterModel._ticketLeftNum)
        local viewNode = self._viewNode
        if(self.exchangeNumStringFormat==nil)then
            self.exchangeNumStringFormat=viewNode.exchangeNumTxt:getString()
        end
        viewNode.exchangeNumTxt:setString( string.format(self.exchangeNumStringFormat,ExchangeCenterModel._ticketLeftNum))
        viewNode.userExchangeTxt:setString( ExchangeCenterModel._ticketLeftNum) 
    end
end

return PersonalInfoCtrl
