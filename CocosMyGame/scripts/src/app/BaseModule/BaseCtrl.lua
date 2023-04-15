
local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
local WidgetEventBinder=coms.WidgetEventBinder

local BaseCtrl=class('BaseCtrl')
local ViewAdapter=import('src.app.BaseModule.ViewAdapter')

my.addInstance(BaseCtrl)
my.setmethods(BaseCtrl,PropertyBinder)
my.setmethods(BaseCtrl,WidgetEventBinder)

function BaseCtrl:ctor(params)
    self._pluginConfig = {}  --自定义功能

    if(self.onCreate)then
        self:onCreate(params)
    end

    self._params = params
    if(self._viewNode)then
        local viewNode=self._viewNode
        ------------------
        --    viewNode will be binded with ctrl instance
        --    if ctrl instance.removeSelfInstance() is not called,
        --    then viewNode will be still retained and will not be autoreleased,
        --    thus if ctrl instance is alive, then viewNode is still retained
--        viewNode:retain()
--        self._retained=true
        viewNode:enableNodeEvents()

        local listener = cc.EventListenerKeyboard:create()
        self._listener=listener
        listener:registerScriptHandler(handler(self,self.onKeyboardReleased), cc.Handler.EVENT_KEYBOARD_RELEASED)

        self._eventDispatcher = viewNode:getEventDispatcher()
        --        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        local realNode=viewNode:getRealNode()
        self._eventDispatcher:addEventListenerWithSceneGraphPriority(listener, realNode)

        if(realNode.registerScriptHandler)then
            realNode:registerScriptHandler(function(event)
                if event == "enter" then
                    my.autoBlockKeyboardListener(self._listener)
                    self:_enter()
                elseif event == 'exit' then
                    my.removeKeyboardListener(self._listener)
                    self:_exit()
                elseif event == "enterTransitionFinish" then
                    self:onEnterTransitionDidFinish()
                elseif event == 'cleanup' then
                    self:onCleanup()
                end
            end)
        end

    end

end

function BaseCtrl:onEnter()
    self._alive = true
    my.enableBackgroundListener( function()
        self:onBackground()
    end )
    if self.RUN_ENTERACTION then
        self:runEnterAction()
    end
end

function BaseCtrl:onExit()
    self._alive = false
    my.enableLastBackgroundListener()
end

function BaseCtrl:onCleanup()
    if self._params and self._params.retain then return end
    self._viewNode = nil
    self:removeInstance()
    self:removeEventHosts()
end

function BaseCtrl:onEnterTransitionDidFinish()

end

function BaseCtrl:_enter()
    self:onEnter()
end

function BaseCtrl:_exit()
    if(self._onExitCallback)then
        self:_onExitCallback()
    end
    self:onExit()
end

function BaseCtrl:onKeyboardReleased(keyCode, event)
	if keyCode == cc.KeyCode.KEY_BACK then
		print('on key back clicked')
		if(self.onKeyBack)then
			return self:onKeyBack()
		end
	end
end
function BaseCtrl:onBackground()
    self:recordBackgroundEvent()
end
function BaseCtrl:recordBackgroundEvent()
    if self.LOGUI then
        my.logBackgroundEvent(self:getLogEventMap())
    end
end
function BaseCtrl:getLogEventMap()
    return { connectStatus = my.getNetworkTypeString(), ui = self.LOGUI }
end

function BaseCtrl:playEffectOnPress()
    my.playClickBtnSound()
end

function BaseCtrl:onKeyBack()
    printf("basectrl onkeyBack")
    self:playEffectOnPress()
    my.scheduleOnce(function()
--        self._toDestroySelf=true
--        self:respondDestroyEvent()
        if(self:informPluginByName(nil,nil))then
            self:removeSelfInstance()
        end
    end)
end

function BaseCtrl:postClickEvent( widget,... )
    self:playEffectOnPress()
    WidgetEventBinder.postClickEvent(self,widget,...)
    self:respondDestroyEvent()
end

function BaseCtrl:respondDestroyEvent(  )
    if(not self._isDestroyingSelf) then
        self._isDestroyingSelf=true
    end
    if(self._toDestroySelf)then
        if(self:informPluginByName(nil,nil))then
            self:removeSelfInstance()
        end
        self._toDestroySelf=nil
    end
    self._isDestroyingSelf=nil

end

function BaseCtrl:informPluginByName(pluginName,params)
    local informParams={
        sender=self,
        pluginName=pluginName,
        params=params,
    }
    return my.informPluginByName(informParams)
end

function BaseCtrl:getViewNode()
    return self._viewNode
end

function BaseCtrl:addViewTo(parent)
    self._ctrlParent=parent
    local viewParent=(parent.getViewNode and parent:getViewNode()) or parent
    self._viewParent=viewParent
    local viewNode=self._viewNode:getRealNode()
    viewParent:addChild(viewNode)
    return self
end

function BaseCtrl:getViewParent()
    return self._ctrlParent
end

function BaseCtrl:setVisible(visible)
    self._viewNode:setVisible(visible)
end

function BaseCtrl:bindButtonToPlugin(button,pluginName,params)

    assert(button,'button is nil, unable to bind')

    self:bindWidgetToClickEventHandler(button,'callPluginEventList',function()
        my.scheduleOnce(function()
            self:informPluginByName(pluginName,params)
        end)
    end)

end

function BaseCtrl:bindSomeButtonsToPlugin( params )
    local container,bindList,pluginList=(params.container or self._viewNode),params.bindList,params.pluginList or params.moduleList
    local defaultParams = params.defaultParams
    local params = {}
    for _,v in pairs(bindList)do
        if(type(v)=='table')then
            params=v
            v=v.bindname
        else
            params=nil
        end
        local buttonName=v..'Bt'
        local ctrlName=v..'Ctrl'
        if(params==nil)then
            params=defaultParams or {name=ctrlName}
            if(params.name==nil or params.name=='nil')then
                params.name=ctrlName
            end
        end
        self:bindButtonToPlugin(container[buttonName],pluginList[ctrlName],params)
    end
end

-- may unused for now
function BaseCtrl:_getCtrlButtonBindList()
    if(self._ctrlButtonBindList==nil)then
        self._ctrlButtonBindList={}
        setmetatable(self._ctrlButtonBindList,{__mode='k'})
    end
    return self._ctrlButtonBindList
end

-- may unused for now
function BaseCtrl:bindButtonToCtrl(button,ctrl,params)
    params=checktable(params)

    local localctrlname=params.name
    local callback=params.callback

    button:addClickEventListener(function()
        printInfo('%s clicked',localctrlname or '')
        local newctrl=myctrl(ctrl):getInstance(params.params)

        local parent=self

        if(localctrlname)then
            parent[localctrlname]=newctrl
        end

        local ctrlButtonBindList=parent:_getCtrlButtonBindList()
        if(ctrlButtonBindList[newctrl])then
            printInfo('child %s existed',localctrlname or '')
            return
        end
        ctrlButtonBindList[newctrl]=true
        newctrl:addViewTo(parent)

        if(callback)then
            callback()
        end
    end)

    self:_bindWidgetClickEventProxy(button)

end

-- may unused for now
function BaseCtrl:bindSomeButtonsToCtrl(params)
    local container,bindList,moduleList=(params.container or self._viewNode),params.bindList,params.moduleList
    local defaultParams = params.defaultParams
    local params = {}
    for _,v in pairs(bindList)do
        if(type(v)=='table')then
            params=v
            v=v.bindname
        else
            params=nil
        end

        local buttonname=v..'Bt'
        local ctrlname=v..'Ctrl'
        if(params==nil)then
            params=defaultParams or {name=ctrlname}
            if(params.name==nil or params.name=='nil')then
                params.name=ctrlname
            end
        end
        self:bindButtonToCtrl(container[buttonname],moduleList[ctrlname],params)
    end
end

function BaseCtrl:setViewIndexer(viewIndexer)
    self._viewNode=viewIndexer
    return self._viewNode
end

function BaseCtrl:bindUserEventHandler(container,itemNameList,keyEffected)

    if(itemNameList==nil)then
        if(container.getExchangeMap)then
            itemNameList=container:getExchangeMap()
            keyEffected=true
        else
            itemNameList=container
        end
    end

    for k,v in pairs(itemNameList)do
        local item
        if(keyEffected)then
            item=container[k]
            v=k
        elseif(type(v)=='string')then
            item=container[v]
        else
            item=v
            v=k
        end

        if(item)then
            local selfOnClicked=self[v..'Clicked']
            local selfOnTouched=self[v..'Touched']
            local selfOnUpdated=self[v..'Updated']

            if((item.onClick and selfOnClicked)
                or ((item.addClickEventListener) and selfOnClicked))then
                self:bindWidgetToClickEventHandler(item,'userClickEventList',handler(self,selfOnClicked))
            end
            if(item.onTouch and selfOnTouched)then
                item:onTouch(handler(self,selfOnTouched))
            end
            if(item.onEvent and selfOnUpdated)then
                item:onEvent(handler(self,selfOnUpdated))
            elseif(item.addEventListener and selfOnUpdated)then
                item:addEventListener(handler(self,selfOnUpdated))
            end

        else
            printInfo('item %s is nil',v)
        end
    end

end

function BaseCtrl:bindUserEventHandlerEx(params)
    local container=params.container

    local exclude=params.exclude
    local include=params.include
    local itemNameList
    local keyEffected
    if(type(exclude)=='table' and #exclude>0)then
        itemNameList=clone(include)

        if(itemNameList==nil and container.getExchangeMap)then
            itemNameList=clone(container:getExchangeMap())
            keyEffected=true
        end

        for k,_ in pairs(exclude) do
            itemNameList[k]=nil
        end
    else
        itemNameList=include
    end

    self:bindUserEventHandler(container,itemNameList,keyEffected)
end

function BaseCtrl:bindDestroyButton(button)
    if(button.addClickEventListener)then
        if(button.onClick==nil and self._onClickCallback==nil)then
            function button:onClick(callback)
                self._onClickCallback=callback
            end
            button:addClickEventListener(function(...)
                if(button._onClickCallback)then
                    button:_onClickCallback(...)
                end
            end)
        end

        self:bindWidgetToClickEventHandler(button,'destroyEventList',function (  )
            self._toDestroySelf=true
        end)
    end

end

function BaseCtrl:bindSomeDestroyButtons(host,names)
    assert(host~=nil,'')
    for _,v in pairs(names) do
        self:bindDestroyButton(host[v] or v)
    end
end

function BaseCtrl:provideOnClickEvent(eventList,widgetNameList)
    local eventCallback
    for k,v in ipairs(widgetNameList) do
        eventCallback=self[v]
        self[k..'Clicked']=eventList[k..'Clicked']
    end

end

function BaseCtrl:setOnExitCallback(callback)
    self._onExitCallback=callback
end


----------------------
--    user removeSelfInstance instead of removeSelf
function BaseCtrl:removeSelf()
    if self._viewNode then
        self._viewNode:removeSelf()
        if self._params and self._params.retain then
            self._viewNode = nil
        end
    end
end

----------------------
--    user removeSelfInstance instead of removeSelf
function BaseCtrl:removeSelfInstance()
    self:removeInstance()
    self:removeSelf()
--    if(self._retained==true)then
--        self._viewNode:release()
--        self._retained=false
--    end

end

--注意：由于getInstance()的调用者必须是类（而不是类的实例），所以BaseCtrl的createViewNode()方法的调用者也同样必须是类
function BaseCtrl:createViewNode(...)
    return self:getInstance(...):getViewNode():getRealNode()
end

function BaseCtrl:onGetCenterCtrlNotify(params)
    printLog('BaseCtrl', 'onGetCenterCtrlNotify')
    dump(params)
end

function BaseCtrl:runEnterAction()
    local panelMain = self._viewNode:getRealNode():getChildByName("Panel_Main")
    local panelAni  = panelMain and panelMain:getChildByName("Panel_Animation")
    if panelAni then
        panelAni:setScale(0.6)
        panelAni:setOpacity(255)
        local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
        local scaleTo2 = cc.ScaleTo:create(0.09, 1)
        local callback = cc.CallFunc:create(function ()
            self:onEnterActionFinished()
        end)
        local ani = cc.Sequence:create(scaleTo1, scaleTo2, callback, nil)
        panelAni:runAction(ani)
    else
        self._viewNode:runTimelineAction("animation_appear", false)
    end
end

function BaseCtrl:onEnterActionFinished()
    print(self.__cname, ":onEnterActionFinished")
end

function BaseCtrl:runExitAction()
    self._viewNode:runTimelineAction("animation_disappear", false)
end




 --自定义功能
function BaseCtrl:setView(view)
    self._view = view
end

function BaseCtrl:addListenerOfAutoCloseOnLogoff()
    local player = mymodel('hallext.PlayerModel'):getInstance()
    self:listenTo(player, player.PLAYER_LOGIN_OFF, function()
        print("autoCloseOnLogoff triggered")
        self:closeSelf()
    end)
end

function BaseCtrl:closeSelf()
    self:removeSelfInstance()
end

function BaseCtrl:addClickEvent(btnNode, func, forbidSound)
    btnNode:addClickEventListener(function (sender)
        if not forbidSound then
            self:playEffectOnPress()
        end
        if type(func) == "function" then
            func(sender)
        end
    end)
end

cc.register('BaseCtrl',BaseCtrl)

return BaseCtrl
