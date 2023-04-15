
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

local config=require('src.app.HallConfig.HelpConfig')
local titleIndexList,urlList=config.titleIndexList,config.urlList

viewCreator.viewConfig={
	'res/hallcocosstudio/help/help.csb',
	{
        operatePanel = 'Operate_Panel',
        {
            _option = {prefix = 'Operate_Panel.'},
            feedbackPanel='Panel_Main',
			webPanel = 'Panel_Web',
			keFuwebPanel = 'Panel_KeFu_Web',
			{
				_option={
					prefix='Panel_TopBar.'
				},
				backBt='Btn_Back',
				feedbackRd='Check_Tab1',
				faqRd='Check_Tab2',
				ruleRd='Check_Tab3',
				aboutRd='Check_Tab4',
			},
			{
				_option={
					prefix='Panel_Main.'
				},
				sendMsgBt='Btn_Send',
				inputInp='TextField_EditMsg',
				inputBkImg='Img_EditBoxBG',
				clearBt='Btn_Clear',
				msglistLs='List_Msg',

			},
			{
				_option={
					prefix='Panel_Web.'
				},
				img_box_main='Img_Box_Main',
				img_box_inside='Img_Box_Inside',
				Panel_web_container='Panel_Web_Container',
			},
        }
	}
}


local function getActivityWebUrl()

    local deviceUtils = DeviceUtils:getInstance()   
    local deviceModel=mymodel('DeviceModel'):getInstance()  
    local gamemodel=mymodel('GameModel'):getInstance()
    local user=mymodel('UserModel'):getInstance()
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()

    local szWifiID=deviceModel.szWifiID
    local szImeiID=deviceModel.szImeiID
    local szSystemID=deviceModel.szSystemID

    local did=string.format('%s%s%s',szWifiID,szImeiID,szSystemID)
    local md5=my.md5(did)
    local hagdsign = string.urlencode(md5)
    string.lower(hagdsign)

    --[[local uidSign = string.format('%d%s%s',user.nUserID or 0,hagdsign,"tcy_feedback")
    local uidSignmd5=my.md5(uidSign)
    local sign = string.urlencode(uidSignmd5)
    string.lower(sign)]]
    --[[
    local accToken = userPlugin:getAccessToken()
	local params={
        app=string.urlencode(my.getAppName()),
        abb=string.urlencode(gamemodel.abbrName),
        gamever=string.urlencode(gamemodel.gameVer),
        system=string.urlencode(deviceUtils:getSystemId()),
        sysver=string.urlencode(tostring(deviceUtils:getSystemVersion())),
        model=string.urlencode(deviceUtils:getPhoneModel()),
        brand=string.urlencode(deviceUtils:getPhoneBrand()),
        gameid=string.urlencode(tostring(gamemodel.nGameID)),
        hardsign=hagdsign,
        f=13,
        uid=string.urlencode(tostring(user.nUserID)),
        AccessToken=accToken
	}
	local paramsUrl=my.convertParamsToUrlStyle(params)

	local addition='/conversation/inconversation'
    local urlBase = 'https://mtalk.tcy365.com'
    if BusinessUtils:getInstance():isGameDebugMode() then
        urlBase = 'http://m.talk.uc108.org:1505'
    end
    --]]
    local uidSign = string.format('%d%s%s',user.nUserID or 0,hagdsign,"tcy_feedback")
    local uidSignmd5=my.md5(uidSign)

    local accToken = userPlugin:getAccessToken()
	local params = {
        hardsign = hagdsign,
        uid = string.urlencode(tostring(user.nUserID)),
        gameid = string.urlencode(tostring(gamemodel.nGameID)),
        system = string.urlencode(deviceUtils:getSystemId()),
        sign = string.lower(string.urlencode(uidSignmd5)),
        model = string.urlencode(deviceUtils:getPhoneModel()),
        brand = string.urlencode(deviceUtils:getPhoneBrand()),
        sysver = string.urlencode(tostring(deviceUtils:getSystemVersion())),
        gamever=string.urlencode(gamemodel.gameVer)
	}
	local paramsUrl=my.convertParamsToUrlStyle(params)

	local addition='/client/mobilegame.aspx'    local urlBase = 'https://talk.tcy365.com'    if BusinessUtils:getInstance():isGameDebugMode() then        urlBase = 'http://talk.tcy365.org:1505'    end

	local url=string.format('%s%s%s%s',urlBase ,addition,'?',paramsUrl)
	--	CCLOG("%s",url->getCString());
	--	curl_free(eusername);
	--	curl_easy_cleanup(curl);
	--	return url;
	return url
--	return 'http://www.baidu.com/'

end

local function getAbsoluteUrlByIndex(index)
    local url=urlList[index]
    local absUrl=cc.FileUtils:getInstance():fullPathForFilename(url)
    if(absUrl:find('assets')==1)then
        absUrl='android_asset'..absUrl:sub(7,absUrl:len())
    elseif(absUrl:find('asset')==1)then
        absUrl='android_asset'..absUrl:sub(6,absUrl:len())
    end
    return absUrl
end

local function addWebViewToViewNode(viewNode)
    local webView=viewNode.webView
    if(not webView)then
        local marginTop=75
        webView=ccexp.WebView:create()
        viewNode:addChild(webView)
        local visibleRect=cc.Director:getInstance():getOpenGLView():getVisibleRect()
        local Panel_web = viewNode.webPanel
        local Panel_web_container = viewNode.Panel_web_container
        local Panel_web_container_size = Panel_web_container:getContentSize()
        local Panel_web_container_pos = Panel_web_container:getPosition3D()
        local Panel_web_container_pos_world = Panel_web:convertToWorldSpaceAR(cc.p(Panel_web_container_pos.x,Panel_web_container_pos.y))

        --local centerPos=cc.p(visibleRect.x+visibleRect.width/2,visibleRect.y+visibleRect.height/2-marginTop+50)
        local centerPos = cc.p(Panel_web_container_pos_world.x + Panel_web_container_size.width/2,Panel_web_container_pos_world.y+Panel_web_container_size.height/2)
        webView:setPosition(centerPos)
        webView:setAnchorPoint(cc.p(0.5,0.5))

        --webView:setContentSize(cc.size(visibleRect.width-100,visibleRect.height-marginTop-100))
        webView:setContentSize(cc.size(Panel_web_container_size.width,Panel_web_container_size.height))
        webView:setTransparent(0)
        webView:setOnShouldStartLoading(function(wv,url)
            print('%s',url)
            return true
        end)
        viewNode.webView=webView
    end
    webView:setVisible(false)

    --[[local kefuWebView = viewNode.kefuWebView
    if(not kefuWebView)then
        local marginTop=75
        local kefuWebView=ccexp.WebView:create()
        viewNode:addChild(kefuWebView)
        
        local visibleRect=cc.Director:getInstance():getOpenGLView():getVisibleRect()
        kefuWebView:setContentSize(cc.size(visibleRect.width * 0.95,visibleRect.height * 0.95))
        kefuWebView:setColor(cc.c3b(255,255,255))
        local centerPos=cc.p(visibleRect.x+visibleRect.width/2,visibleRect.y+visibleRect.height/2)
        kefuWebView:setPosition(centerPos)
        kefuWebView:setAnchorPoint(cc.p(0.5,0.5))

        kefuWebView:setTransparent(0)
        kefuWebView:setOnShouldStartLoading(function(wv,url)
            print('kefuWeb,Load,end')
            return true
        end)
        viewNode.kefuWebView=kefuWebView
    end]]
end

function viewCreator:onCreateView(viewNode)

    viewNode.inputInp:setPlaceHolderColor(cc.c4b(127,127,127,160))

    local function feedbackTouchEvent()
        my.scheduleOnce(function()
            local webView=viewNode.webView
            if webView then
                webView:setVisible(false)
            end
            --[[测试客服系统]]      
            local kefuWebView=ccexp.WebView:create()
            viewNode:addChild(kefuWebView)
        
            local visibleRect=cc.Director:getInstance():getOpenGLView():getVisibleRect()
            kefuWebView:setContentSize(cc.size(visibleRect.width * 0.95,visibleRect.height * 0.95))
            kefuWebView:setColor(cc.c3b(255,255,255))
            local centerPos=cc.p(visibleRect.x+visibleRect.width/2,visibleRect.y+visibleRect.height/2)
            kefuWebView:setPosition(centerPos)
            kefuWebView:setAnchorPoint(cc.p(0.5,0.5))
            kefuWebView:setTransparent(0)
            kefuWebView:setOnShouldStartLoading(function(wv,url)
                print('kefuWeb,Load,end')
                return true
            end)
            viewNode.kefuWebView=kefuWebView

            --local kefuWebView = viewNode.kefuWebView
            kefuWebView:stopLoading()
            if(kefuWebView:canGoBack())then
             kefuWebView:goBack()
            end
	        local url=getActivityWebUrl()
            print('kefuWeb,Load,start')
	        kefuWebView:loadURL(url)
            kefuWebView:setVisible(true)
            print('%s',url)
            viewNode.keFuwebPanel:setVisible(true)

            viewNode.feedbackRd:setSelected(false)

            local action = cc.CSLoader:createTimeline('res/hallcocosstudio/help/help.csb')
            viewNode:runAction(action)
            action:gotoFrameAndPlay(0, true)
        end)
    end

    viewNode.feedbackRd:setSelected(false)
    viewNode.feedbackRd:addClickEventListener(feedbackTouchEvent)

    local radioList={
        --viewNode.feedbackRd,
        viewNode.faqRd,
        viewNode.ruleRd,
        viewNode.aboutRd,
    }
    
    viewNode.keFuwebPanel:setVisible(false)
    viewNode.webPanel:setVisible(true)
    if cc.exports.isCustomerServiceSupported() == false then
        viewNode.feedbackRd:setVisible(false)
        viewNode.feedbackPanel:setVisible(false)
    end
    local noneview=TabView.noneview
    local titles=TabView:create({
        nodelist=radioList,
        image='Image_',
        --pageList={viewNode.feedbackPanel,viewNode.webPanel,viewNode.webPanel,viewNode.webPanel},
        pageList={
        --viewNode.keFuwebPanel,
        viewNode.webPanel,viewNode.webPanel,viewNode.webPanel},
        default=1,
    })

    viewNode.radioList=radioList
    viewNode.noneview=noneview
    viewNode.titles=titles

    addWebViewToViewNode(viewNode)

    viewNode.HELP_TAB_FEEDBACK=titleIndexList.FEEDBACK
    function viewNode:showPageByIndex(index)
        index = index+1
        local webView=self.webView
        local kefuWebView=self.kefuWebView
        if(not webView)then
            return
        end
        
        webView:setVisible(false)

        if(index==self.HELP_TAB_FEEDBACK)then
            --[[测试客服系统]]            
            kefuWebView:stopLoading()
            if(kefuWebView:canGoBack())then
             kefuWebView:goBack()
            end
	        local url=getActivityWebUrl()
	        kefuWebView:loadURL(url)
            kefuWebView:setVisible(true)
            print('%s',url)
            return
        else
            webView:setVisible(true)
            if kefuWebView then
                kefuWebView:setVisible(false)
            end
        end

        local absUrl=getAbsoluteUrlByIndex(index)
        print(absUrl)

        webView:stopLoading()
        if(webView:canGoBack())then
         webView:goBack()
        end
        print('HelpView.about_to_loadURL')
        --if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode()
        --and device.platform == "android"  then 
        if device.platform == "android" then
            webView:loadURL('file:///'..absUrl)
            printLog("loadURL",absUrl)
        else
            webView:loadFile(urlList[index])
            printLog("loadFile", urlList[index])
        end

    end
    
    --viewNode.kefuWebView:setVisible(false)
    --viewNode.webView:setVisible(true)
    local absUrl=getAbsoluteUrlByIndex(2)
    viewNode.webView:stopLoading()
        if(viewNode.webView:canGoBack())then
         viewNode.webView:goBack()
        end
    --if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode()
    --and device.platform == "android"  then 
    if device.platform == "android" then
        viewNode.webView:loadURL('file:///'..absUrl)
        printLog("loadURL",absUrl)
    else
        viewNode.webView:loadFile(urlList[2])
        printLog("loadFile", urlList[2])
    end
    --[[local editBox=ccui.EditBox:create(viewNode.inputBkImg:getContentSize(),'res/hallcocosstudio/imagesbox5_shuru_pic.png')
    editBox:setPosition(viewNode.inputBkImg:getPosition())
    editBox.getString=editBox.getText
    editBox.setString=editBox.setText
    editBox:setLocalZOrder(viewNode.inputBkImg:getLocalZOrder()+1)
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    editBox:setFontColor(display.COLOR_BLACK)
    viewNode.clearBt:setLocalZOrder(2)
    local parent=(viewNode.inputInp:getParent()~=imageView and viewNode.inputInp:getParent()) or viewNode.inputInp:getParent():getParent()
    parent:addChild(editBox)
    editBox:setPlaceHolder(viewNode.inputInp:getPlaceHolder())
    viewNode.inputInp:setVisible(false)
    viewNode.inputInp = editBox
    ]]
	
end


return viewCreator
