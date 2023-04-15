local Vocher_RedPack100SimpleCtrl = class('Vocher_RedPack100SimpleCtrl', cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.RedPack100Vocher.Vocher_RedPack100SimpleView")
local RedPack100Def = import('src.app.plugins.RedPack100.RedPack100Def')
local RedPack100Model = import("src.app.plugins.RedPack100.RedPack100Model"):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

my.addInstance(Vocher_RedPack100SimpleCtrl)

function Vocher_RedPack100SimpleCtrl:onCreate(params)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if self._RedPackTipConten == nil then
        local FileNameString = "src/app/plugins/RedPack100/RedPack100.json"
        local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
        self._RedPackTipConten = cc.load("json").json.decode(content)
    end

    self:bindDestroyButton(viewNode.btnTixian)
    local bindList={
        'btnTixian',
	}
    self:bindUserEventHandler(viewNode,bindList)
    self._viewNode = viewNode
    self._viewNode.txtTommorow:setVisible(false)
    if params.nGetMoney > 0 then
        -- 设置 拆开后显示数据
        local getVocher = params.nGetMoney
        self._viewNode.txtFontVocher:setString(getVocher)
        local strTip = string.format(self._RedPackTipConten["VOCHER_RP100_CAN_EXCHANGE"], getVocher/100)
        self._viewNode.txtTip1:setString(strTip)
        self._viewNode.txtTip2:setVisible(false)
    end

    self:playRedPackAni(self._viewNode.panelBreak)
end

function Vocher_RedPack100SimpleCtrl:playRedPackAni(aniNode)
    local time = 0.5
    local firstDelay = 0
    local delayAction     = cc.DelayTime:create(firstDelay)    
    local scaleto2 = cc.ScaleTo:create(time, 1.2, 1.2)
    local scaleto3 = cc.ScaleTo:create(time,1, 1)
    local sequenceAction  = cc.Sequence:create(delayAction, scaleto2,scaleto3)
    aniNode:runAction(sequenceAction)
end

-- 提现按钮点击后，关闭后通知活动界面刷新
function Vocher_RedPack100SimpleCtrl:btnTixianClicked()
    my.dataLink(cc.exports.DataLinkCodeDef.VOCHER_PACK100_TI_XIAN_ON_BOUTED)
    if self._viewNode.panelBreak then
        self._viewNode.panelBreak:stopAllActions()
        self._viewNode.panelBreak = nil 
    end

    local breakInfo = RedPack100Model:GetRedPackInfo()
    if not breakInfo then
        return
    end

    local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
    local strNowDate = os.date("%Y%m%d", nowtimestamp)
    local nNowDate = tonumber(strNowDate)
    if nNowDate >= breakInfo.nEndDate then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_BREAK_OUT_DATE"], removeTime = 2}})
        return
    end

    RedPack100Model:NotifyActivityRedPackUpdate()
end


return Vocher_RedPack100SimpleCtrl