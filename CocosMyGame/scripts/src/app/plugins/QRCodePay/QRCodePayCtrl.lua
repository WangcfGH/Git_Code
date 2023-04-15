local QRCodePayCtrl = class('QRCodePayCtrl',cc.load('BaseCtrl'))
local QRCodePayModel = import('src.app.plugins.QRCodePay.QRCodePayModel'):getInstance()
local viewCreater = import('src.app.plugins.QRCodePay.QRCodePayView')

my.addInstance(QRCodePayCtrl)

local md5Key        = 'MW0N39VPLWAIB2D5'
local js2LuaScheme  = 'lua'

local function encodeURI(s)
    s = string.gsub(s, '([^%w%.%- ])', function(c) return string.format('%%%02X', string.byte(c)) end)
    return string.gsub(s, ' ', '+')
end
    
local function decodeURI(s)
    return string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
end

local function parseJsCallbackUrl(url)
    local headStr = js2LuaScheme .. '://'
    local startIndex = string.find(url, headStr)

    if 1 == startIndex and string.len(url) > string.len(headStr) then
        local bodyStr = string.sub(url, string.len(headStr) + 1, string.len(url))

        local endIndex = string.find(bodyStr, '?')
        if nil == endIndex then
            return bodyStr
        elseif 1 == endIndex then
            return nil
        elseif string.len(bodyStr) == endIndex then
            return string.sub(bodyStr, 1, string.len(bodyStr) - 1)
        else
            local interface = string.sub(bodyStr, 1, endIndex - 1)
            local paramList = string.sub(bodyStr, endIndex + 1, string.len(bodyStr))
            
            local specialIndex = string.find(paramList, '=')
            if nil == specialIndex then
                return interface
            elseif 1 == specialIndex then
                return interface
            else
                local param = {}

                while specialIndex do
                    local key = string.sub(paramList, 1, specialIndex - 1)
                    local value = string.sub(paramList, specialIndex + 1, string.len(paramList))

                    endIndex = string.find(value, '&')
                    if nil == endIndex then
                        param[key] = decodeURI(value)
                        break
                    else
                        paramList = string.sub(value, endIndex + 1, string.len(value))
                        value = string.sub(value, 1, endIndex - 1)
                        param[key] = decodeURI(value)
                        specialIndex = string.find(paramList, '=')
                    end
                end
                return interface, param
            end
        end
    else
        return nil
    end
end

function QRCodePayCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self._payInfo = params.payInfo
    self:bindDestroyButton(viewNode.btnClose)
    local bindList = {'btnAliPay', 'btnWeChatPay', 'btnBackToPayInfo'}
    self:bindUserEventHandler(viewNode, bindList)
    my.runPopupAction(viewNode.panelAnimation:getRealNode())
    self:initEventListeners()
    self:initWebView()
    self:showPayInfo()
end

function QRCodePayCtrl:initEventListeners()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    self:listenTo(netProcess, netProcess.EventEnum.SoketError, handler(self, self.removeSelfInstance))
    self:listenTo(netProcess, netProcess.EventEnum.NetWorkError, handler(self, self.removeSelfInstance))
    self:listenTo(netProcess, netProcess.EventEnum.KickedOff, handler(self, self.removeSelfInstance))
    self:listenTo(QRCodePayModel, QRCodePayModel.EVENT_PAY_RESULT, handler(self, self.removeSelfInstance))
end

function QRCodePayCtrl:onExit()
    self:removeEventListeners()
    QRCodePayModel:onExitQRCodePay()
end

function QRCodePayCtrl:removeSelfInstance()
    self._viewNode.webView:removeFromParentAndCleanup()
    QRCodePayCtrl.super.removeSelfInstance(self)
end

function QRCodePayCtrl:removeEventListeners()
    self:removeEventHosts()
end

function QRCodePayCtrl:initWebView()

    local function jsCallback(webView, url)
        local funcName, param = parseJsCallbackUrl(url)
        print('jsCallbackUrl', url, funcName)
        if param then dump(param) end
        if funcName == 'clientPayResult' then
            local code = param['code']
            local msg = param['msg']
            QRCodePayModel:onPayResult(code, msg)
            self:removeSelfInstance()
        end
    end

    self._viewNode.webView:setJavascriptInterfaceScheme(js2LuaScheme)
    if self._viewNode.webView.setOnJSCallback then
        self._viewNode.webView:setOnJSCallback(jsCallback)
    else
        print("webView setOnJSCallback not exist!")
    end

    self._viewNode.webView:setOnShouldStartLoading(function(wv, url)
        return true
    end)

    self._viewNode.webView:setOnDidFinishLoading(function(wv, url)
        self._isWebLoadFinish = true
        return true
    end)

    self._viewNode.webView:setOnDidFailLoading(function(wv, url)
        self._isWebLoadFailed = true
        return true
    end)
end

function QRCodePayCtrl:refreshPayInfo()
    local productName = self._payInfo['Product_Name']
    local productPrice = self._payInfo['Product_Price']
    self._viewNode.valueProductName:setString(productName)
    self._viewNode.valueProductPrice:setString('￥' .. productPrice)
end

function QRCodePayCtrl:btnAliPayClicked()
    my.startLoading()
    self._viewNode.textPayTip:setString('打开支付宝扫一扫即可支付')
    self:payForProductByAlipay()
end

function QRCodePayCtrl:btnWeChatPayClicked()
    my.startLoading()
    self._viewNode.textPayTip:setString('打开微信扫一扫即可支付')
    self:payForProductByWechat()
end

function QRCodePayCtrl:btnBackToPayInfoClicked()
    self:showPayInfo()
end

function QRCodePayCtrl:showPayInfo()
    self:refreshPayInfo()
    self._viewNode.webView:setVisible(false)
    self._viewNode.panelPayInfo:setVisible(true)
    self._viewNode.panelQRCode:setVisible(false)
end

function QRCodePayCtrl:onQRCodeError()
    my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "支付请求失败，请稍后再试！", removeTime = 1}})
end

function QRCodePayCtrl:showQRCode(qrCodeUrl)
    if self and self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) then
        my.stopLoading()
        self._viewNode.webView:loadURL(qrCodeUrl)
        self._viewNode.webView:setVisible(true)
        self._viewNode.panelPayInfo:setVisible(false)
        self._viewNode.panelQRCode:setVisible(true)
    end
end

function QRCodePayCtrl:payForProductByWechat()
    self._payInfo["way_op"] = "way_web_weixin_code"
    self:payForProduct()
end

function QRCodePayCtrl:payForProductByAlipay()
    self._payInfo["way_op"] = "way_web_alipay_web"
    self:payForProduct()
end

function QRCodePayCtrl:payForProduct()
    local userId = mymodel("UserModel"):getInstance().nUserID

    if userId <= 0 then return end

    local userRequest = {}
    userRequest["input_charset"] = "UTF-8"
    userRequest["op"] = "tcy_wap_create_tctb"
    userRequest["partner_app_id"] = ""
    userRequest["return_url"] = ""
    userRequest["way_version_no"] = ""
    userRequest["nonce_str"] = self:getNonceStr()
    userRequest["source_platform_id"] = "30"
    userRequest["os_type"] = 1
    userRequest["process_version_no"] = "2.0"
    userRequest["way_op"] = self._payInfo["way_op"]
    userRequest["game_code"] = my.getAbbrName()
    userRequest["game_version_no"] = my.getGameVersion()
    userRequest["user_access_token"] = UserPlugin:getAccessToken()
    userRequest["pay_download_group"] = mymodel("GameModel"):getInstance().nAgentGroupID
    userRequest["app_client_id"] = cc.exports.GetShopConfig().QRPayClientId or '100512'
    userRequest["game_app_id"] = "18800" .. tostring(my.getGameID())
    userRequest["game_app_code"] = my.getAbbrName()
    userRequest["game_app_version_no"] = my.getGameVersion()
    userRequest["app_code"] = my.getAbbrName()
    userRequest["app_version_no"] = my.getGameVersion()


    userRequest["client_channel_id"] = cc.exports.getQRCodePayChannelID() or "160008"
    userRequest["publish_channel"] = my.getTcyChannelId()


    local qrCodeWidth = self._viewNode.webView:getContentSize().width - 20
    local ratio = display.sizeInPixels.width / display.size.width
    local dpi = cc.Device:getDPI()
    userRequest["qr_code_size"] = math.floor(160 * qrCodeWidth * ratio / dpi)
    userRequest["load_env"] = "lua"

    self:buildOrderInfo(userRequest, self._payInfo, "Exchange_Id", "exchange_id")
    self:buildOrderInfo(userRequest, self._payInfo, "WifiID", "mac_address")
    self:buildOrderInfo(userRequest, self._payInfo, "Imei", "imei")
    self:buildOrderInfo(userRequest, self._payInfo, "SystemId", "system_id")
    self:buildOrderInfo(userRequest, self._payInfo, "Role_Id", "user_id")
    self:buildOrderInfo(userRequest, self._payInfo, "Product_Price", "price")
    self:buildOrderInfo(userRequest, self._payInfo, "Product_Price", "real_price")
    self:buildOrderInfo(userRequest, self._payInfo, "Product_Id", "buy_props_id")
    self:buildOrderInfo(userRequest, self._payInfo, "Role_Name", "user_name")
    -- self:buildOrderInfo(userRequest, self._payInfo, "Channel_Id", "client_channel_id")
    self:buildOrderInfo(userRequest, self._payInfo, "Way_Version_No", "way_version_no")
    self:buildOrderInfo(userRequest, self._payInfo, "Way_Op", "way_op")
    self:buildOrderInfo(userRequest, self._payInfo, "ext_args", "ext_args")
    self:buildOrderInfo(userRequest, self._payInfo, "through_data", "through_data")
    -- self:buildOrderInfo(userRequest, self._payInfo, "Publish_Channel", "publish_channel")
    self:buildOrderInfo(userRequest, self._payInfo, "Game_Id", "game_id")
    self:buildOrderInfo(userRequest, self._payInfo, "GameCode", "game_code")
    self:buildOrderInfo(userRequest, self._payInfo, "GameVersion", "game_version_no")

    local sortKey = self:sortParams(userRequest)
    local getOrderSign = self:getSignParmStr(sortKey, userRequest)
    userRequest["sign"] = getOrderSign

    local url = self:getPayUrl(userRequest)
    print('QRCodePayCtrl url = ', url)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = 0

    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            xhr:setRequestHeader("GsClientData", gsClient);
        end
    end

    xhr:open("GET", url)
    local function onPayOrder()
        local json = cc.load("json").json
        local jsontext = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        print('QRCodePayCtrl onPayOrder response = ', jsontext)
        if xhr.status == 200 then
            jsontext = self:unicode_to_utf8(jsontext)
            local appJsonObj = json.decode(jsontext)
            if appJsonObj["return_code"] == 1 then
                if appJsonObj["data"]["result_code"] == 1 then
                    local returnUrl = appJsonObj["data"]["ext_info"]["res_client_forward_url"]
                    self:showQRCode(returnUrl)
                else
                    self:onQRCodeError()
                end
            else
                self:onQRCodeError()
            end
        else
            self:onQRCodeError()
        end
    end

    xhr:registerScriptHandler(onPayOrder)
    xhr:send()
end

function QRCodePayCtrl:buildOrderInfo(requestMap, map, mapKey, key)
    if mapKey == "ext_args" or mapKey == "through_data" then
        if mapKey == "ext_args" then
        end
        requestMap[key] = string.urldecode(map[mapKey])
    else
        local value = map[mapKey]
        if value ~= nil then
            requestMap[key] = value
        end
    end
end

function QRCodePayCtrl:getNonceStr()
    local time = os.time() .. ""
    return MCCrypto:md5(time, time:len())
end

function QRCodePayCtrl:sortParams(payInfos)
    local sortTable = {}
    for i, v in pairs(payInfos) do
        if v ~= nil then
            table.insert(sortTable, i)
        end
    end
    table.sort(sortTable)
    return sortTable
end

function QRCodePayCtrl:getSignParmStr(keyMap, payInfos)
    local paramStr = ""
    for i, v in pairs(keyMap) do
        if payInfos[v] ~= nil and payInfos[v] ~= "" then
            paramStr = paramStr .. v .. "=" .. payInfos[v] .. "&"
        end
    end
    paramStr = string.sub(paramStr, 1, string.len(paramStr) - 1)

    paramStr = paramStr .. "59ca3sdfkgkc7178au8nv0xwpzlskiem5292bsbdkje0d2jfkwduasdkfhklasdj"
    paramStr = MCCrypto:md5(paramStr, paramStr:len())
    paramStr = MCCrypto:md5(paramStr, paramStr:len())
    return paramStr
end

function QRCodePayCtrl:getPayUrl(payInfos)
    local url = "https://payproxy.tcy365.net/thirdpay/createtrade.aspx?"
    if BusinessUtils:getInstance():isGameDebugMode() then
        url = "http://payproxy.tcy365.org:1505/thirdpay/createtrade.aspx?"
    end

    for i, v in pairs(payInfos) do
        url = url .. i .. "=" .. string.urlencode(tostring(v)) .. "&"
    end
    return string.sub(url, 1, string.len(url) - 1)
end

function QRCodePayCtrl:unicode_to_utf8(convertStr)
    if type(convertStr) ~= "string" then
        return convertStr
    end
    local resultStr = ""
    local i = 1
    while true do
        local num1 = string.byte(convertStr, i)
        local unicode

        if num1 ~= nil and string.sub(convertStr, i, i + 1) == "\\u" then
            unicode = tonumber("0x" .. string.sub(convertStr, i + 2, i + 5))
            i = i + 6
        elseif num1 ~= nil then
            unicode = num1
            i = i + 1
        else
            break
        end

        if unicode <= 0x007f then
            resultStr = resultStr .. string.char(bit.band(unicode, 0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr = resultStr .. string.char(bit.bor(0xc0, bit.band(bit.rshift(unicode, 6), 0x1f)))
            resultStr = resultStr .. string.char(bit.bor(0x80, bit.band(unicode, 0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr = resultStr .. string.char(bit.bor(0xe0, bit.band(bit.rshift(unicode, 12), 0x0f)))
            resultStr = resultStr .. string.char(bit.bor(0x80, bit.band(bit.rshift(unicode, 6), 0x3f)))
            resultStr = resultStr .. string.char(bit.bor(0x80, bit.band(unicode, 0x3f)))
        end
    end
    resultStr = resultStr .. "\0"
    return resultStr
end

return QRCodePayCtrl