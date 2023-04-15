
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
end

function viewCreator:onCreateView(viewNode)

    viewNode.inputInp:setPlaceHolderColor(cc.c4b(127,127,127,160))

    local radioList={
        viewNode.feedbackRd,
        viewNode.faqRd,
        viewNode.ruleRd,
        viewNode.aboutRd,
    }
    viewNode.feedbackPanel:setVisible(true)
    viewNode.keFuwebPanel:setVisible(false)
    viewNode.webPanel:setVisible(false)  
    if cc.exports.isCustomerServiceSupported() == false then
        viewNode.feedbackRd:setVisible(false)
        viewNode.feedbackPanel:setVisible(false)
    end

    local noneview=TabView.noneview
    local pageList = {viewNode.feedbackPanel,viewNode.webPanel,viewNode.webPanel,viewNode.webPanel}

    local defaultPageIndex = 1
    if cc.exports.isCustomerServiceSupported() == false then
        defaultPageIndex = 2
    end
    local titles=TabView:create({
        nodelist=radioList,
        image='Image_',
        pageList = pageList,
        default=defaultPageIndex,
    })

    viewNode.radioList=radioList
    viewNode.noneview=noneview
    viewNode.titles=titles

    addWebViewToViewNode(viewNode)

    viewNode.HELP_TAB_FEEDBACK=titleIndexList.FEEDBACK
    function viewNode:showPageByIndex(index)
        local webView=self.webView

        if(not webView)then
            return
        end

        if(index==self.HELP_TAB_FEEDBACK)then
            webView:setVisible(false)
            return
        else
            webView:setVisible(true)
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

    local editBox=ccui.EditBox:create(viewNode.inputInp:getContentSize(),'res/hallcocosstudio/imagesbox5_shuru_pic.png')
    editBox:setPosition(viewNode.inputInp:getPosition())
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

	
end

return viewCreator
