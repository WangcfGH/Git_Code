local AdvertisementCtrl=class('AdvertisementCtrl', cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.MiniGame.AdvertisementView')
local GuideDownLoadModel = require('src.app.plugins.GuideDownLoad.GuideDownLoadModel')

my.addInstance(AdvertisementCtrl)

local function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end
    n = n or 0;
    n = math.floor(n)
    if n < 0 then
        n = 0;
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end

function AdvertisementCtrl:onCreate(params)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)

    local bindList={
		'downloadBt',
	}
	self:bindUserEventHandler(viewNode,bindList)

    for i = 1, 4 do
        local btn = viewNode['iconDown'..i]
        if btn then
            local function iconDownClick()
                if cc.exports._gameJsonConfig.TCYGameConfig and cc.exports._gameJsonConfig.TCYGameConfig.IconDownloadURL then
                    self:onStartDownloadUrl(cc.exports._gameJsonConfig.TCYGameConfig.IconDownloadURL[i])
                end
            end
            btn:addClickEventListener(iconDownClick)
        end
    end
    self._currentUrl = nil

    self.gotoType = params.gototype

    viewNode.tcyLoadingPanel:setVisible(false)
    viewNode.downloadText:setVisible(false)
    --self._loadingHeight = viewNode.tcyLoadingLayer:getContentSize().height
    --viewNode.tcyLoadingLayer:setPositionY(self._loadingHeight/2)
    --viewNode.tcyLoadingPanel:setPositionY(viewNode.tcyIcon:getPositionY()-viewNode.tcyIcon:getContentSize().height / 2)
    --self._oldLoadingY =  viewNode.tcyLoadingPanel:getPositionY()

    self:listenTo(GuideDownLoadModel,GuideDownLoadModel.DOWNLOAD_PROCESS,handler(self,self.onGuidDownloadProcess))
    self:listenTo(GuideDownLoadModel,GuideDownLoadModel.DOWNLOAD_SUCCESS,handler(self,self.onGuidDownloadSuccess))
end

function AdvertisementCtrl:downloadBtClicked( ... )
    if cc.exports._gameJsonConfig.TCYGameConfig then
        self:onStartDownloadUrl(cc.exports._gameJsonConfig.TCYGameConfig.DownloadURL)
    end
end

function AdvertisementCtrl:onChooseDialogOk(url)
    if self._currentUrl == nil then
        GuideDownLoadModel:getInstance():startDownLoad(url)
        self._currentUrl = url
    end
end

function AdvertisementCtrl:onChooseDialogCancel()
    
end

function AdvertisementCtrl:onStartDownloadUrl(url)
    if self._currentUrl ~= nil then
        return
    end
    local con = DeviceUtils:getInstance():isNetworkConnected()
    if(con == false)then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName='TipPlugin',params={tipString=config["NET_NOT_CONNECTED"],removeTime=1}})
        return false
    end

    if self.gotoType == 1 then
        my.dataLink(cc.exports.DataLinkCodeDef.MAIN_DOWNLOAD_BEGIN)
    elseif self.gotoType == 2 then
        my.dataLink(cc.exports.DataLinkCodeDef.MAIN_DOWNLOAD_BEGIN)
    end

    local viewNode = self._viewNode
    viewNode.tcyLoadingPanel:setVisible(true)
    viewNode.downloadText:setVisible(true)
    viewNode.downloadText:setText("0%")
    viewNode.tcyLoadingBar:setPercent(0)

    viewNode.downloadBt:setVisible(true)
    viewNode.downloadBt:setTouchEnabled(false)
    viewNode.downloadBt:setBright(false)

    --判断下是否是wifi环境
    if DeviceUtils:getInstance():getNetworkType() ~= 3 then
        local function chooseDialogOk()
            self:onChooseDialogOk(url)
        end
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName='ChooseDialog',params={
		    tipContent=config["ADVERTISEMENT_CONTENT"],
            onCancel=handler(self,self.onChooseDialogCancel),
            onClose=handler(self,self.onChooseDialogCancel),
            okBtTitle=config["ADVERTISEMENT_CONTINUE"],
            onOk=chooseDialogOk,
	    }})
        return
    end

    if self._currentUrl == nil and cc.exports._gameJsonConfig.TCYGameConfig then
        GuideDownLoadModel:getInstance():startDownLoad(url)
        self._currentUrl = url
    end
end

function AdvertisementCtrl:onGuidDownloadProcess(param)
    local viewNode = self._viewNode
    local data = param.data
    local total = data.total
    local downloaded = data.downloaded
    
    viewNode.downloadBt:setVisible(false)
    viewNode.downloadBt:setTouchEnabled(false)
    viewNode.downloadBt:setBright(false)

    viewNode.tcyLoadingPanel:setVisible(true)
    viewNode.downloadText:setVisible(true)

    viewNode.tcyLoadingBar:setPercent(downloaded/total *100)

    --local yy = self._oldLoadingY  - (self._loadingHeight *  downloaded/total)
    --viewNode.tcyLoadingPanel:setPositionY(self._loadingHeight/2  + (self._loadingHeight *  downloaded/total))
    --viewNode.tcyLoadingPanel:setPositionY(self._oldLoadingY  - (self._loadingHeight *  downloaded/total))
    viewNode.downloadText:setText(tostring(GetPreciseDecimal(downloaded/total*100, 2)).."%")
end

function AdvertisementCtrl:onGuidDownloadSuccess(param)
    local viewNode = self._viewNode
    viewNode.downloadBt:setVisible(false)
    viewNode.downloadBt:setTouchEnabled(false)
    viewNode.downloadBt:setBright(false)
    
    viewNode.tcyLoadingPanel:setVisible(true)
    viewNode.downloadText:setVisible(true)
    viewNode.downloadText:setText("100%")
    viewNode.tcyLoadingBar:setPercent(100)
    
    if self.gotoType == 1 then
        my.dataLink(cc.exports.DataLinkCodeDef.MAIN_DOWNLOAD_SUCCESS)
    elseif self.gotoType == 2 then
        my.dataLink(cc.exports.DataLinkCodeDef.TASK_DOWNLOAD_SUCCESS)
    end
end

return AdvertisementCtrl
