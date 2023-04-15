local viewCreater           = import('src.app.plugins.outlaygame.MoreGameView')
local MoreGameCtrl          = class('MoreGameCtrl', cc.load('BaseCtrl')) 
local constStrings          = cc.load('json').loader.loadFile('MainSceneStrings.json')     
--local RoomManager           = import("src.app.GameHall.room.ctrl.RoomManager"):getInstance()

MoreGameCtrl.MORE_RESOUCE_PATH = "res/hallcocosstudio/room/gameunit.csb" 

function MoreGameCtrl:onCreate(params)                    
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer()) 
	self:bindUserEventHandler(viewNode, {'backBtn'})
    self._btnGame = {}
    --cc.exports.zeroBezelNodeAutoAdapt(viewNode.operatePanle);
    --local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    --netProcess:addEventListener(netProcess.EventEnum.SoketError,         handler(self, self._onSocketError))
end

function MoreGameCtrl:onEnter()
    MoreGameCtrl.super.onEnter(self)
    self:_checkDownload()
    self._gameBtCanClick = true
    self:initGamePanel() 
end

function MoreGameCtrl:_onSocketError()  
    my.dataLink(cc.exports.DataLinkCodeDef.HALL_MORE_GAME_VIEW_CLOSE)
    self:goBack()
end

function MoreGameCtrl:goBack()
    MoreGameCtrl.super.removeSelfInstance(self)
    -- my.informPluginByName({pluginName = 'MainScene'})
end

function MoreGameCtrl:onExit()      
    MoreGame:removeDownloadListenerByTag("moregame") 
    --RoomManager:fuseLayerCheckDownload()
    self:onGameButtonClickTimer()
end

function MoreGameCtrl:onKeyBack()  
    self:goBack()
    MoreGameCtrl.super.onKeyBack(self)
end

function MoreGameCtrl:backBtnClicked()
    my.dataLink(cc.exports.DataLinkCodeDef.HALL_MORE_GAME_VIEW_CLOSE)
    self:goBack()
end

function MoreGameCtrl:initGamePanel()                        
    local moreGameSetting = cc.exports.getMoreGameSetting()
    if not moreGameSetting then return end   

    local panelType = cc.exports.getMoreGamePanelType()
    if type(panelType) ~= "number" or panelType < 1 or panelType > 2 then
        panelType = 1
    end
    self._viewNode.listRoom:removeAllItems()
    local btnGameWidth = 0
    local btnGameHeight = 0
    for i = 1, #moreGameSetting, panelType do
        if not self._btnGame[moreGameSetting[i].gameCode] then
            local rootNode  = cc.CSLoader:createNode(self.MORE_RESOUCE_PATH)
            local largeRoomBtn = rootNode:getChildByName("Btn_Room_L")
            local panelSmallRoom = rootNode:getChildByName("Panel_Room_S")
            local upSmallRoomBtn = panelSmallRoom:getChildByName("Btn_Room_S_Up")
            local downSmallRoomBtn = panelSmallRoom:getChildByName("Btn_Room_S_Down")
            largeRoomBtn:setVisible(false)
            panelSmallRoom:setVisible(true)
            upSmallRoomBtn:setVisible(false)
            downSmallRoomBtn:setVisible(false)
            if 2 == panelType then
                self:initBtnGame(moreGameSetting[i],panelType,upSmallRoomBtn)
                --奇数时只设置upSmallRoomBtn
                if i+1 <= #moreGameSetting then
                    self:initBtnGame(moreGameSetting[i+1],panelType,downSmallRoomBtn)
                end
                panelSmallRoom:removeFromParent()
                self._viewNode.listRoom:pushBackCustomItem(panelSmallRoom)
                btnGameWidth = panelSmallRoom:getContentSize().width
                btnGameHeight = panelSmallRoom:getContentSize().height
            else
                self:initBtnGame(moreGameSetting[i],panelType,largeRoomBtn)
                largeRoomBtn:removeFromParent()
                self._viewNode.listRoom:pushBackCustomItem(largeRoomBtn)
                btnGameWidth = largeRoomBtn:getContentSize().width
                btnGameHeight = largeRoomBtn:getContentSize().height
            end
        end
    end

    --listview居中处理
    if panelType ~= 0 then
        local size = self._viewNode.listRoom:getContentSize()
        self._viewNode.listRoom:setContentSize(cc.size(size.width,btnGameHeight))
        size = self._viewNode.listRoom:getContentSize()
        
        local margin = 30
        local width = (math.floor(#moreGameSetting/panelType)+#moreGameSetting%panelType)*(margin+btnGameWidth) - margin
        if width < size.width then
            self._viewNode.listRoom:setContentSize(cc.size(width,btnGameHeight))
            self._viewNode.listRoom:setBounceEnabled(false)
            self._viewNode.listRoom:setInertiaScrollEnabled(false) 
            self._viewNode.listRoom:setItemsMargin(margin)
        end
    end
end

function MoreGameCtrl:initBtnGame(moreGameInfo,panelType,btnGame)  
    if not btnGame or not moreGameInfo then return end
    local panelRes      = moreGameInfo.url  
    local panelResUrl   = moreGameInfo["picurl"..panelType] 
    --获取url
    local gameWebUrl = my.packageGameUrl(panelRes)
    local progressBG = btnGame:getChildByName("Img_ProgressBG") 
    progressBG:setVisible(false)
    btnGame:setVisible(false)
    if self._btnGame[moreGameInfo.gameCode] then return end

    if moreGameInfo.gameCode then
        self._btnGame[moreGameInfo.gameCode] = btnGame
    end
    
    local imageOnline = btnGame:getChildByName("Img_GamePic")
    imageOnline:setVisible(false)
    if string.len(panelResUrl) > 0 then
        local thirdPartyImageCtrl = require('src.app.BaseModule.YQWImageCtrl')
        thirdPartyImageCtrl:getUserhuodongImage(panelResUrl, function(code, path)
            print("loadOnlineImage url is ", panelResUrl)
            print("loadOnlineImage path is ",  path)
            if not imageOnline or tolua.isnull(imageOnline) then return end
            if code ==cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess then
                imageOnline:loadTexture(path)
                imageOnline:setVisible(true)
                print('~~~~~kImageLoadOnlineSuccess~~~~~')
            else
                imageOnline:setVisible(false)
                print('~~~~~kImageLoadOnlineFailed~~~~~')
            end
        end)
    else
        imageOnline:setVisible(true)
    end
    btnGame:setVisible(true)

    local textNum = btnGame:getChildByName("Text_User")
    if textNum then
        textNum:setVisible(false)
    end
    
    if moreGameInfo.customType then
        btnGame:addClickEventListener(function()        
            my.playClickBtnSound()
            if moreGameInfo.customType == "appGame" then 
                self:onGameButtonClicked(moreGameInfo)   
            elseif moreGameInfo.customType == "MoreGameGame" then
                --do something                                        
            elseif moreGameInfo.customType == "webUrl" then
                DeviceUtils:getInstance():openBrowser(gameWebUrl) 
            elseif moreGameInfo.customType == "webView" then
                my.dataLink(cc.exports.DataLinkCodeDef.MORE_GAME_BTN_CLICK, {gamecode = moreGameInfo.gameCode})
                my.informPluginByName({pluginName='OutlayGameCtrl',params={url=gameWebUrl}})
            end 
        end)
    end
end

function MoreGameCtrl:_checkDownload()
    if MoreGame:isDownloading() then
        self:startDownloadGame()
    end
end

--防止多次快速点击
function MoreGameCtrl:initGameButtonClickTimer()
    local function onGameButtonClickTimer(dt)
        self:onGameButtonClickTimer()
    end
    self._gameBtnClickTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onGameButtonClickTimer, 2, false)
end

function MoreGameCtrl:onGameButtonClickTimer()
     if self._gameBtnClickTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._gameBtnClickTimerID)
        self._gameBtnClickTimerID = nil
    end         
    self._gameBtCanClick   = true
end

function MoreGameCtrl:onGameButtonClicked(moreGameInfo) 
    if not self._params.centerCtrl:checkNetStatus() then
        return
    end
    if not self._gameBtCanClick then 
        my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = "操作频繁，请稍后再试"} })
        return 
    end

    self._gameBtCanClick = false
    self:initGameButtonClickTimer()

    if MoreGame:isDownloading() then
        local callback
        local tipString = ''  
        local downloadGameCode = MoreGame:getCurrentDownloadGameCode()
        local downloadGameID   = MoreGame:getCurrentDownloadGameID() 

        if moreGameInfo.gameCode == downloadGameCode then 
            tipString = constStrings["GAME_DOWNLOAD_PAUSE_SURE"]       
            callback = function()                                        
                MoreGame:pauseDownload(downloadGameCode, downloadGameID)
            end
        else                                                        
            tipString = constStrings["GAME_DOWNLOAD_PAUSE_CURRENT"]  
            callback = function()                                      
                MoreGame:pauseDownload(downloadGameCode, downloadGameID)  
                self:startDownloadMoreGame(moreGameInfo)   
            end
        end
        self:informPluginByName("ChooseDialog", {onOk = callback, tipContent = tipString })

    else                                  
        self:startDownloadMoreGame(moreGameInfo)
    end
end

function MoreGameCtrl:startDownloadMoreGame(moreGameInfo) 
    if MoreGame:isDownloadFinished(moreGameInfo.gameCode) then
        MoreGame:startGame(moreGameInfo.gameCode, moreGameInfo.gameID)
    else                                 
        MoreGame:startDownload(moreGameInfo.gameCode, moreGameInfo.gameID, handler(self, self.onMoreGameDownload), false, "moregame")
    end
end

function MoreGameCtrl:startDownloadGame()
    local downloadGameCode = MoreGame:getCurrentDownloadGameCode()
    local downloadGameID   = MoreGame:getCurrentDownloadGameID() 
    if downloadGameCode and downloadGameID then
        MoreGame:startDownload(downloadGameCode, downloadGameID, handler(self, self.onMoreGameDownload), false, "moregame")
    end
end

function MoreGameCtrl:onMoreGameDownload(content)
    my.onMoreGameDownload(content, handler(self, self.setDownLoadPercent))
end

function MoreGameCtrl:setDownLoadPercent(percent, gameCode) 
    if not self._viewNode or not self._btnGame[gameCode] then return end
        
    local progressBG = self._btnGame[gameCode]:getChildByName("Img_ProgressBG")   
    local progressBar = progressBG:getChildByName("Progress_Download")
    local function setPercentVisible(bVisible)
        progressBG:setVisible(bVisible)
    end
    if percent and percent > 0 then
        setPercentVisible(true)
        progressBar:setPercent(percent)
    else        
        progressBG:setVisible(false)
    end
end

return MoreGameCtrl