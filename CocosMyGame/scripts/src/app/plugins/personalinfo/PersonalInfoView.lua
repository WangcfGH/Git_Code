
local PlayerInfoView        = import('src.app.plugins.personalinfo.PlayerInfoView')
local PlayerGoodsView       = import('src.app.plugins.personalinfo.PlayerGoodsView')
local PersonalInfoString    = cc.load('json').loader.loadFile('PersonalInfoString.json')
--local ExtraConfig           = cc.exports.GetExtraConfigInfo()
local userPlugin            = plugin.AgentManager:getInstance():getUserPlugin()

local TabView               = cc.load('myccui').TabView
local viewCreator           = cc.load('ViewAdapter'):create()
local private               = {}
local PropertyMode          = {
    deposit                 = 1,
    score                   = 2,
    compatible              = 3
}  
local ViewPage              = {
    pInfo_date              = 1,
    pInfo_goods             = 2,
    shop_goods              = 1,
    shop_vip                = 2
} 

viewCreator.viewConfig      = {
    'res/hallcocosstudio/personalinfo/personalinfo.csb',
	{
        image_Bg    = 'Img_Box2',
        {
            _option = {prefix='Operate_Panel.'},
            titlesHost  ='Panel_TopBar',
			{
				_option                     = {prefix = 'Panel_TopBar.'},
				backBt                      = 'Btn_Back',
				infoBt                      = 'Check_Tab1',
				goodsBt                     = 'Check_Tab2',
				checkimagin1                = "Img_TabPersonInfo",
				checkimagin2                = "Img_TabItems",

				userGameDepositTable2        = 'Img_InfoDeposit2',
				{
					_option                     = {prefix='Img_InfoDeposit2.'},
					userGameDepositTxt2          = 'Value_Deposit',
				},
				userScoreTable              = 'Img_InfoScore',
				{
					_option                     = {prefix='Img_InfoScore.'},
					userScoreTxt                = 'Value_Score',
					userScoreChargeBt           = 'Btn_QuickCharge',
				},
			},
			panelHead = 'Panel_PlayerHead',
			{
				_option                     = {prefix = 'Panel_PlayerHead.'},
				girlPic                     = 'Img_Girl',
				Image_cover                 = 'Img_ChangePhoto',
				Image_juesedikuang          = 'Img_PlayerHeadBG',
				
				Flag_icon_auditfailed       = 'Panel_VerifyError',
				Flag_icon_duringaudit       = 'Img_TagVerifying',
				userIdTxt                   = 'Text_ID',
				userGameLevelBg             = 'Img_GameLevel',
				userGameLevelColor          = 'Img_GameLevel.Img_LevelColor',
				userGameLevelNum            = 'Img_GameLevel.Text_LevelNum',
			},
			button_xiugaimima           = 'Btn_EditPassword',
			infoBox     = 'Panel_PlayerInfo',
			{
				_option                     = {prefix='Panel_PlayerInfo.'},
				image_touchCover            = 'Img_touchCover',
				usernameTable               = 'Img_InfoName',
				{
					_option                     = {prefix='Img_InfoName.'},
					usernameTxt                 = 'Vaule_Name',
					usernameSetBt               = 'Btn_Edit',
				},
				userSafeboxDepositTable     = 'Img_InfoSavebox',
				{
					_option                     = {prefix='Img_InfoSavebox.'},
					userSafeboxDepositTxt       = 'Value_Savebox',
					userSafeboxDepositChargeBt  = 'Btn_QuickCharge',
				},
				userGameDepositTable        = 'Img_InfoDeposit',
				{
					_option                     = {prefix='Img_InfoDeposit.'},
					userGameDepositTxt          = 'Value_Deposit',
					userGameDepositChargeBt     = 'Btn_QuickCharge',
				},
				
				userSexTable                = 'Img_InfoGender.',
				{
					_option                     = {prefix='Img_InfoGender.'},
					userSexTxt                  = 'Value_Gender',
					userSexSetBt                = 'Btn_Edit',
				},
				userPhoneTable              = 'Img_InfoBinding',
				{
					_option                     = {prefix='Img_InfoBinding.'},
					userPhoneUnbindedTxt        = 'Text_Attention',
					userPhoneNumberTxt          = 'Value_PhoneNum',
					userPhoneBangdingBt         = 'Btn_Binding',
					userPhoneXiugaiBt           = 'Btn_Edit',
				},
				userWinRateTable            = 'Img_InfoWinrate',
				userWinRateTxt              = 'Img_InfoWinrate.Value_Winrate',
				userLevelTable              = 'Img_InfoLevel',
				userLevelTxt                = 'Img_InfoDeposit.Value_Level',
                userExchangeTable           = 'Img_InfoExchange',
				userExchangeTxt             = 'Img_InfoExchange.Value_Exchange',
				userNewLevelTxt             = 'Img_InfoLevel.Value_GameLevel',
				gameRuleBtn                 = 'Img_InfoLevel.Btn_Rule',
			},

			goodsScroll = 'Scroll_Goods',
			{
				_option                     = {prefix='Scroll_Goods.'},
				{
					_option                     = {prefix='Panel_Item1.'},
					buyVipBt                    = 'Btn_Charge',
					outlineTxt                  = 'Img_ItemDetailBG.Text_ItemDetail',
				},
				productInfoVipNode          = 'Panel_Item1',
				{
					_option                     = {prefix='Panel_Item2.Panel_1.'},
					exchangeBt                  = 'Btn_Charge',
					exchangeNumTxt              = 'Img_ItemDetailBG.Text_ItemDetail',
				},
                exchangeInfoNode                = 'Panel_Item2',
                {
					_option                     = {prefix='Panel_Item3.Panel_1.'},
					timingLimitBt                  = 'Btn_Charge',
					timingLimitTipTxt              = 'Text_Tip',
					timingLimitNumTxt              = 'Img_ItemDetailBG.Text_ItemDetail',
				},
                timingTicketLimitNode           = 'Panel_Item3',
                {
					_option                     = {prefix='Panel_Item4.Panel_1.'},
					timingTicketBt                  = 'Btn_Charge',
					timingTicketNumTxt              = 'Img_ItemDetailBG.Text_ItemDetail',
				},
				timingTicketNode                = 'Panel_Item4',

				productListEmptyLb          = 'Text_Attention',
				enterShopCenterBt           = 'Btn_Shop',
			}
        }
    }
}

function viewCreator:onCreateView(viewNode)
    private.init(viewNode)
    private.organizeView(viewNode)
	private.registWidgts(viewNode)

    viewNode.exchangeBt:setVisible(cc.exports.isExchangeSupported())
    viewNode.userGameDepositChargeBt:setVisible(cc.exports.isShopSupported())
    viewNode.userLevelTxt:setVisible(false)--20191113,隐藏银两称号
    --viewNode.enterShopCenterBt:setVisible(cc.exports.isShopSupported())
end

function private.init(viewNode)
    --刘海屏额外单独处理下ScrollView的子节点自适应位置、缩放
    local scrollView = viewNode.goodsScroll
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, scrollView:getContentSize().height))
    ccui.Helper:doLayout(scrollView:getRealNode())

    local playerInfoView = PlayerInfoView:create(viewNode)
	local goodsListView  = PlayerGoodsView:create(viewNode)

	local titlesRd=TabView:create({
		host=viewNode.titlesHost,
		name='Check_Tab',--name='CheckBox_',
		image='Img_Box',--image='Image_',
		pageList={playerInfoView,goodsListView,},
		default = 1,
	})

	viewNode.playerInfoView = playerInfoView
	viewNode.goodsListView  = goodsListView
	viewNode.titlesRd       = titlesRd
    function viewNode:setSex(isGirl)
        --viewNode.girlPic:setVisible(true)
		if isGirl then 
			viewNode.userSexTxt:setString(PersonalInfoString["female"])
		else
			viewNode.userSexTxt:setString(PersonalInfoString["male"])
		end
        if viewNode.Image_juesedikuang:isVisible() == true then
        else
            viewNode.girlPic:loadTexture(cc.exports.getPersonResPath(isGirl), 0)
        end
	end
    
    viewNode.Image_juesedikuang:setVisible(false)
    viewNode.buyVipBt:setVisible(false)
end

function private.registWidgts(viewNode)
        
    local touchEventMap = {
        tablesWithGoldCircle                    = {
            ["userSexTable"]             = handler(userPlugin, userPlugin.modifyUserSex), 
            ["usernameTable"]            = handler(userPlugin, userPlugin.modifyUserName),
            ["userScoreTable"]           = handler("silver", private.enterShop),
            ["userGameDepositTable"]     = handler("silver", private.enterShop),
            ["userSafeboxDepositTable"]  = handler("silver", private.enterShop),
        },
        buttons                                 = {
            ["button_xiugaimima"]                   = {
                ["enterPlatform"]                   = handler(userPlugin, userPlugin.enterPlatform),
                ["modifyPassword"]                  = handler(userPlugin, userPlugin.modifyPassword)
            },
            ["userPhoneBangdingBt"]      = handler(userPlugin, userPlugin.bindunbingPhone),
            ["userPhoneXiugaiBt"]        = handler(userPlugin, userPlugin.bindunbingPhone),
            ["buyVipBt"]                 = handler("vip", private.enterShop),
            ["enterShopCenterBt"]        = handler("vip", private.enterShop),

            ["userSexSetBt"]        = handler(userPlugin, userPlugin.modifyUserSex), 
            ["userGameDepositChargeBt"]     = handler("silver", private.enterShop),
            ["usernameSetBt"]            = handler(userPlugin, userPlugin.modifyUserName),
            
            ["gameRuleBtn"]            = handler({pluginName='GameRulePlugin'},my.informPluginByName),
            ["exchangeBt"]            = handler({pluginName='ExchangeCenterPlugin'},my.informPluginByName),
            ["timingLimitBt"]            = handler({pluginName='TimingGameLayer'},my.informPluginByName),
            ["timingTicketBt"]            = handler({pluginName='TimingGameLayer'},my.informPluginByName),
            --[viewNode.backBt]                   = handler({params={message='remove'}},my.infromPluginByName),
        }
    }
    for widgtName, func in pairs(touchEventMap.tablesWithGoldCircle) do 
        viewNode[widgtName]:onTouch(function(e)       
            if     e.name == 'began'        then 
                viewNode.image_touchCover:setVisible(true)
                viewNode.image_touchCover:setPositionY(viewNode[widgtName]:getPositionY())
                private.playSound()
            elseif e.name == 'cancelled'    then 
                viewNode.image_touchCover:setVisible(false)   
            elseif e.name == 'ended'        then
                private.blockWidgts(viewNode[widgtName]) 
                viewNode.image_touchCover:setVisible(false)
                func()
            end 
        end)
    end
    for widgtName, func in pairs(touchEventMap.buttons) do 
        local alterFuc        = nil
        local artificialScale = false
        if widgtName == "button_xiugaimima" then
            if viewNode.button_xiugaimima:getTitleText() == GetRoomConfig()["PERSONALCENTER_QUDAO"] then
                alterFuc = func["enterPlatform"]
            else
                alterFuc = func["modifyPassword"]
            end
        elseif widgtName == "enterShopCenterBt" then 
            artificialScale = true
        end
        viewNode[widgtName]:onTouch(function(e)
            if e.name == "began" then
                --e.target:setScale(1.2) 
                e.target:setColor(cc.c3b(166,166,166))
                private.playSound()
            elseif e.name == "ended" or e.name=='cancelled' then
                --e.target:setScale(1.0) 
                e.target:setColor(cc.c3b(255,255,255))
                if e.name == "ended" then
                    private.blockWidgts(viewNode[widgtName])
                    local toWork = alterFuc or func
                    toWork()
                end
            end
        end)
    end

end

function private.organizeView(viewNode)

    local lockWidgts, removedTables = private.getConfigRequirement()
    local lockWidgts_transtype = private.getTransTypeRequirement()

    local function myMerge(mainTable, subTable)
        for i,v in ipairs(subTable) do 
            table.insert(mainTable, v)
        end
    end 
    local function myMergePlus(mainTable, subTable)
        if mainTable  and subTable then
            myMerge(mainTable.inVisible,   subTable.inVisible)
            myMerge(mainTable.unTouchable, subTable.unTouchable)
        end
    end
    local inVisible = {
        "productListEmptyLb",       "enterShopCenterBt", 
        "goodsScroll",             "image_touchCover",
        "Flag_icon_auditfailed",    "Flag_icon_duringaudit"
    }
    myMerge(lockWidgts.inVisible, inVisible)
    myMergePlus(lockWidgts, lockWidgts_transtype)

    private.lockWidgts(viewNode, lockWidgts)
    
    local totalTable = {
        'usernameTable', 'userSexTable', 'userPhoneTable',
        'userGameDepositTable', 'userSafeboxDepositTable', 
        'userExchangeTable', 'userLevelTable', 'userWinRateTable'
    }
    private.freshWidgetPos(viewNode, totalTable)

    local config = cc.exports.GetShopConfig()
    if(not cc.exports.isVIPSupported())then
        local x = viewNode.infoBt:getPositionX()
        local y = viewNode.infoBt:getPositionY()
        local newPos = cc.p(x+200,y)
        viewNode.infoBt:setPosition(newPos)
        viewNode.checkimagin1:setPosition(newPos)
        viewNode.goodsBt:setVisible(false)
        viewNode.checkimagin2:setVisible(false)
    end
	if not userPlugin:isFunctionSupported("modifyUserName") then 
        print('modifyUserName not supported')
    	viewNode.usernameSetBt:setVisible(false)
        viewNode.usernameTable:setEnabled(false)
    end

end

function private.lockWidgts(viewNode, toLock)
    if type(toLock) ~= "table" then
        return 
    end
    table.foreach(toLock.unTouchable, function (i,name)
        viewNode[name]:setTouchEnabled(false)
    end)
    table.foreach(toLock.inVisible,   function (i,name)
        viewNode[name]:setVisible(false)
    end)
end

function private.freshWidgetPos(viewNode, widgets)
    local showCount = 0
    for i, widgetName in ipairs(widgets) do
        if viewNode[widgetName] and viewNode[widgetName]:isVisible() then
            showCount = showCount + 1
        end
    end
    
    local visibleHeight = viewNode.infoBox:getContentSize().height
    local paddingTop = 40
    local paddingBottom = 40
    local interval = (visibleHeight - paddingTop - paddingBottom) / (showCount - 1)
    local index = 0
    for i, widgetName in ipairs(widgets) do
        if viewNode[widgetName] and viewNode[widgetName]:isVisible() then
            viewNode[widgetName]:setPositionY(visibleHeight - interval * index - paddingTop)
            index = index + 1
        end
    end
end

function private.getConfigRequirement()
    local lockWidgts = {
        unTouchable = {
        };
        inVisible = {
        }
    }
    local removedTables = {}

    if not cc.exports.isDepositSupported() then
        table.insert(lockWidgts.inVisible, "userGameDepositTable")
        table.insert(lockWidgts.inVisible, "userSafeboxDepositTable")
        table.insert(removedTables, "userGameDepositTable")
        table.insert(removedTables, "userSafeboxDepositTable")
    elseif not (cc.exports.isSafeBoxSupported() or cc.exports.isBackBoxSupported()) then 
        table.insert(lockWidgts.inVisible, "userSafeboxDepositTable")
        table.insert(removedTables, "userSafeboxDepositTable")
    end

    if not cc.exports.isModifyPasswordSupported() then 
        table.insert(lockWidgts.inVisible, "button_xiugaimima")
    end

    if not cc.exports.isModifySexSupported() then 
        table.insert(lockWidgts.inVisible, "userSexSetBt")
        table.insert(lockWidgts.unTouchable, "userSexTable")
    end

    if not cc.exports.isModifyNameSupported() then 
        table.insert(lockWidgts.inVisible, "usernameSetBt")
        table.insert(lockWidgts.unTouchable, "usernameTable")
    end

    if not cc.exports.isBindphoneSupported() then 
        table.insert(lockWidgts.inVisible, "userPhoneXiugaiBt")
        table.insert(lockWidgts.inVisible, "userPhoneBangdingBt")
        table.insert(removedTables, "userPhoneTable")
    end

    return lockWidgts, removedTables
end

function private.getTransTypeRequirement(viewNode)
    local trans_type = 2 --当前所有的充值项目都是充值到游戏
    local TrasEnum   = {
        box1         = 0,
        box2         = 1,
        game         = 2,
        score        = 3 
    }
    local lockWidgts = {
        [TrasEnum.box1]  = {
            unTouchable  = {"userGameDepositTable"   , "userScoreTable"},
            inVisible    = {"userGameDepositChargeBt", "userScoreChargeBt"}
        },
        [TrasEnum.box2]  = {
            unTouchable  = {"userGameDepositTable"   , "userScoreTable"},
            inVisible    = {"userGameDepositChargeBt", "userScoreChargeBt"}
        },
        [TrasEnum.game]  = {
            unTouchable  = {"userScoreTable"         , "userSafeboxDepositTable"},
            inVisible    = {"userScoreChargeBt"      , "userSafeboxDepositChargeBt"},
        },
        [TrasEnum.score] = {
            unTouchable  = {"userGameDepositTable"   , "userSafeboxDepositTable"},
            inVisible    = {"userGameDepositChargeBt", "userSafeboxDepositChargeBt"},
        },
    }
    return lockWidgts[trans_type]
end

function private.enterShop(defaultPage)
    my.informPluginByName({pluginName = "ShopCtrl", params = {defaultPage = defaultPage}})
end

function private.playSound()
    my.playClickBtnSound()
end

function private.blockWidgts(widgt)
    widgt:setTouchEnabled(false)
    my.scheduleOnce(function()
        widgt:setTouchEnabled(true)
    end,0.3)
end

return viewCreator
