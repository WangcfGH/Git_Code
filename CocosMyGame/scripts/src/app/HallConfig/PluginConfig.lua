
local PluginConfig={
    --once pluginCalled, no plugin will be called within 'PluginBlock' seconds
    --unless plugin has property ["DisableBlock"] = true
    PluginBlock = 0.3,

    PluginTrailBlackList = {
        "CheckinCtrl",
    },
    --如果想要拒绝某插件被推送入队列，将插件名称填充到blackList即可

    PluginsConfig =
    {
        --[[ config demo

        ["GameSet"] =     --Plugin name, it must be solo in cc.exports.PluginsConfig
        {
        ["Enable"]= true, --ture: display the touch button,
        --false not display the touch button

        -- @note: unused
        ["TouchCtrlName"]="GameSet_Btn", --the touch button name which is registered in
        MainScene.csb

        ["EnterPluginActionType"]=PushScene,
        --'PushScene': display plugin in the way of replace mainscene
        and create new scene
        --false:display plugin in the way of create a new layer in
        mainscene

        ["PluginMainViewFullPath"]="src.app.Plugins.GameSet.views.GameSetLayer",
        --the abslute path of the "main view" of plugin, and the
        life of "main view" should be as long as plugin life


        },

        ["EnterSceneTime"]=1,    --the span of replacing scene

        ["EnterSceneType"]=FADE, --the style of replacing old scene with new scene
        --values are as follows:
        CROSSFADE
        FADE
        FADEBL
        FADEDOWN
        FADETR
        FADEUP
        FLIPANGULAR
        FLIPX
        FLIPY
        JUMPZOOM
        MOVEINB
        MOVEINL
        MOVEINR
        MOVEINT
        PAGETURN
        ROTOZOOM
        SHRINKGROW
        SLIDEINB
        SLIDEINL
        SLIDEINR
        SLIDEINT
        SPLITCOLS
        SPLITROWS
        TURNOFFTILES
        ZOOMFLIPANGULAR
        ZOOMFLIPX
        ZOOMFLIPY

        ]]

        ["MainScene"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='PushScene',
            ["PluginMainViewFullPath"]="src.app.plugins.mainpanel.MainCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["CreateWithPhysics"] = true,
            ["ShowBroadcast"]=true,
            ["DisableBlock"] = true,
            ["retain"] = true
        },

        --[[["PersonalInfoCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='LayOnWidget',
            ["PluginMainViewFullPath"]="src.app.plugins.personalinfo.PersonalInfoCtrl",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        ["HelpCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='PushScene',
            ["PluginMainViewFullPath"]="src.app.plugins.help.HelpCtrl",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["WebView"]=true,
        },]]--


        --商城
        ["ShopCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='LayOnWidget',
            ["PluginMainViewFullPath"]="src.app.plugins.shop.ShopCtrl",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
		
		--商城HSox
         ["ShopHSoxCtrl"] =
         {
             ["Enable"]= true,
             ["EnterPluginActionType"]='BlockLayer',
             ["PluginMainViewFullPath"]="src.app.plugins.shophsox.ShopHSoxCtrl",
             ["EnterSceneType"]="CROSSFADE",
             ["EnterSceneTime"]=0.5,
             ["LoginRely"]=true,
         },

         --活动充值HSox
         ["ActivityRechargeHSoxCtrl"] =
         {
             ["Enable"]= true,
             ["EnterPluginActionType"]='BlockLayer',
             ["PluginMainViewFullPath"]="src.app.plugins.activityRechargeHSox.ActivityRechargeHSoxCtrl",
             ["EnterSceneType"]="CROSSFADE",
             ["EnterSceneTime"]=0.5,
             ["LoginRely"]=true,
             ["DisableBlock"]=true,
         },
		 
        ["ShopToolsSelectPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.shop.ShopToolsSelectCtrl",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0.5,
            ["LoginRely"]=false,
        },

        --[[["ExchangeCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='PushScene',
            ["PluginMainViewFullPath"]="src.app.plugins.exchange.ExchangeCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["WebView"]=true,
        },]]--

        --[[["SettingsPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.settingsplugin.SettingsCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
        },]]--
        ["OnUserKickedOutPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.kickedout.KickedOutCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["DisableBlock"]=true
        },
        ["UserKickedOutPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.kickedout.KickedOutCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["HallRely"]=false,
            ["DisableBlock"]=true
        },
        ["TipPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='LayOnWidget',
            ["PluginMainViewFullPath"]="src.app.plugins.tip.TipCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["DisableBlock"]=true,
            ["retain"] = true
        },
        ["ToastPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='LayOnWidget',
            ["PluginMainViewFullPath"]="src.app.plugins.tip.TipCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["HallRely"]=false,
            ["DisableBlock"]=true,
            ["retain"] = true
        },

        ["CheckinCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.checkin.CheckinCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["HallRely"]=true,
        },
        ["ChooseDialog"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.choosedialog.ChooseTipCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["HallRely"]=false,
        },
        ["SureTipPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.suretip.SureTipCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["HallRely"]=false,
            ["DisableBlock"]=true
        },
        ["SureDialog"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.suretip.SureTipCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["HallRely"]=false,
            ["DisableBlock"]=true
        },
        ["NoticeDialog"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.noticetip.NoticeTipCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["HallRely"]=false,
            ["DisableBlock"]=true
        },
        ["ReliefCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.relief.ReliefCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        ["ShareCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.sharectrl.ShareCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },              
        
        ["FirstRecharge"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.firstrecharge.FirstRechargeCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },

        ["LimitTimeSpecial"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.LimitTimeSpecial.LimitTimeSpecialCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },

        --defult game plugin, it must be filled in
        --[[["Game"] =
        {
            ["Enable"]= true,    --must be true
            ["PluginMainViewFullPath"]="src.app.Game.mMyGame.MyGameScene",
            ["EnterPluginActionType"]='PushScene',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["ShowBroadcast"]=true,
            ["LoginRely"]=true,
            ["needWaiting"]=true
        },]]--
        ["QuickStartCtrl"] =
	    {
			["Enable"] = true,    --must be true
			["PluginMainViewFullPath"] = "src.app.Game.mMyGame.MyGameScene",
			["EnterPluginActionType"] = 'PushScene',
			["EnterSceneType"] = "",
			["EnterSceneTime"] = 0,
			["LoginRely"] = true,
            ["ShowBroadcast"] = true, --跑马灯
            --["needWaiting"] = true
        },
        -- 急速掼蛋入口
        ["JiSuQuickStartCtrl"] =
	    {
			["Enable"] = true,    --must be true
			["PluginMainViewFullPath"] = "src.app.Game.mMyJiSuGame.MyJiSuGameScene",
			["EnterPluginActionType"] = 'PushScene',
			["EnterSceneType"] = "",
			["EnterSceneTime"] = 0,
			["LoginRely"] = true,
            ["ShowBroadcast"] = true, --跑马灯
            --["needWaiting"] = true
	    },
        ["OfflineGamePlugin"] =
		{
			["Enable"]= true,
			["PluginMainViewFullPath"]="src.app.Game.mNetless.NetlessScene",
			["EnterPluginActionType"]='PushScene',
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=false,
            ["ShowBroadcast"]=true, --跑马灯
		},
        --different logic for replaygame
        ['LoadingPlugin'] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.loading.LoadingCtrl",
            ["EnterPluginActionType"]='LayOnWidget',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["DisableBlock"] = true,
            ["HallRely"] = true,
            ["retain"] = true
        },
        --经典房也可能会有新手引导，现在逻辑中需要考虑两种新手引导，所以先加一个插件，并且指向**新手引导插件
        ["ClassicGuide"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.yqwguide.RoomCardGuideCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["DisableBlock"]=true
        },
        ['RecordCtrl'] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.record.RecordCtrl",
            ["EnterPluginActionType"]='pushScene',
            ["LoginRely"]=true,
        },
        ['RecordLoading'] = 
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.record.RecordLoadingCtrl",
            ["LoginRely"]=false,
            ["DisableBlock"]=true
        },        
        ['OthersRecordCtrl'] = 
        {
            ['Enable']= true,
            ["EnterPluginActionType"]='LayOnWidget',
            ["PluginMainViewFullPath"]="src.app.plugins.record.OthersRecordCtrl",
            ["LoginRely"]=false,
        },                
        ["BroadcastCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='LayOnWidget',
            ["PluginMainViewFullPath"]="src.app.plugins.broadcast.BroadcastCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["HallRely"]=false,
            ["DisableBlock"]=true,
        },
               
        ["EmailPlugin"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.email.EmailListCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["EmailDetailPlugin"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.email.EmailDetailCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["MobileInputPlugin"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.inputplugin.MobileInputCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["RealItemInputPlugin"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.inputplugin.RealItemInputCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["RecordCurveCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.record.RecordCurveCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["NetworkCheckCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.networkcheck.NetworkCheckCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["DisableBlock"]=false
        },
        ["InviteGiftShareCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.InviteGiftShareCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        }, 
        ["NewUserInviteGiftCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.newusergift.NewUserInviteGiftCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        }, 
        ["OldUserInitGiftCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.oldusergift.OldUserInitGiftCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        }, 
        ["RollNumberCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.oldusergift.RollNumberCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        }, 
        ["InviteGiftCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.InviteGiftCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["NewUserInviteTipCtr"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.newusergift.NewUserInviteTipCtr",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
        },
        ["InviteGiftAwardCtrl"] =
        {
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.oldusergift.InviteGiftAwardCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
        },
        ["InviteGiftSureTipPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.suretip.SureTipCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["HallRely"]=false,
            ["DisableBlock"]=true
        },
        ["MoreGameDownload"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.moregamedownload.MoreGameCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },

        --竞技场插件
        ["SignUpToArenaCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.arena.SignUp.SignUpCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},
		["GiveUpToArenaCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.arena.GiveUp.GiveUpCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},
		["ArenaChangeRoomCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ArenaModel.ArenaChangeRoomCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=true,
		},
		["ArenaRewardInfoCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ArenaModel.ArenaRewardInfoCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},
		["ArenaRankTotalModel"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ArenaRankTotal.ArenaRankTotalCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},
		["ArenaRankSignUpOK"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ArenaRankSignUpOK.ArenaRankSignUpOKCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},
		["ArenaRankTakeReward"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ArenaRankTakeReward.ArenaRankTakeRewardCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},
		["ArenaPlayerCourseCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ArenaModel.ArenaPlayerCourseCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},
		["ArenaContinueBuyCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ArenaModel.ArenaContinueBuyCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},

        ["GameRulePlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.gamerule.GameRuleCtrl",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0.5,
            ["LoginRely"]=false,
        },

        ["GameRuleScoreJiSuPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.gamerulejisu.GameRuleJiSuCtrl",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0.5,
            ["LoginRely"]=false,
        },

        ["JiSuGameRulePlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.Game.mMyJiSuGame.MyJiSuGameRule",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0.5,
            ["LoginRely"]=false,
        },

        --兑换
        ["ExchangeCenterPlugin"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ExchangeCenter.ExchangeCenterCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=true,
		},
        ["ExchangeRecordCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ExchangeCenter.ExchangeRecordCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
		},
		["ExchangeDescription"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ExchangeDescription.ExchangeDescriptionCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=true,
		},
		["ExchangeItemNeedInput"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ExchangeItemTip.ExchangeItemNeedInputCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=true,
		},
		["ExchangeItemNormal"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ExchangeItemTip.ExchangeItemNormalCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=true,
		},
		["ExchangeItemResult"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.ExchangeItemTip.ExchangeItemResultCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=true,
		},

        --抽奖
        ["LoginLotteryCtrl"] =
		{
		    ["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.loginlottery.LoginLotteryCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
        },

        ["LoginLotteryRuleCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.loginlottery.LoginLotteryRuleCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },

        ["ExchangeLotteryRuleCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.ExchangeLottery.ExchangeLotteryRuleCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
            ["DisableBlock"]=false
        },

		["PassCheckRule"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.passcheck.PassCheckRuleCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
		},

        --巅峰榜
        ["NationalDayActivityPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.NationalDayActivity.NationalDayActivityCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0.5,
            ["LoginRely"]=true,
        },
        ["NationalDayActivityRulePlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.NationalDayActivity.NationalDayActivityRuleCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0.5,
            ["LoginRely"]=false,
        },
        ["RankRewardCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.RankReward.RankRewardCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=true,
		},

        --电玩城
        ["SmallGamePlugin"] =
    	{
        	["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.smallgame.SmallGameCtrl",
		    ["EnterSceneType"]="",
        	["EnterSceneTime"]=0,
        	["LoginRely"]=true,
        	["HallRely"]=false,
       	},

        --任务
        ["MyTaskPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='PushScene',
            ["PluginMainViewFullPath"]="src.app.plugins.MyTaskPlugin.TaskCtrl",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0.5,
            ["LoginRely"]=true,
			["CreateWithPhysics"] = true,
        },
        ["AdvertisementCtrl"] =
		{
		    ["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.MiniGame.AdvertisementCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},

        --帮助
        ["HelpCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='PushScene',
			["PluginMainViewFullPath"]="src.app.plugins.help.HelpCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
		},
        ["HelpCtrlInChartered"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.help.HelpCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
		},
        ["HelpCtrlExpand"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='PushScene',
			["PluginMainViewFullPath"]="src.app.plugins.help.HelpCtrlExpand",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=false,
	    },

        --个人信息
        ["PersonalInfoCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='PushScene',
			["PluginMainViewFullPath"]="src.app.plugins.personalinfo.PersonalInfoCtrl",
			["EnterSceneType"]="CROSSFADE",
			["EnterSceneTime"]=0.5,
			["LoginRely"]=true,
		},

        --设置
        ["SettingsPlugin"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.settingsplugin.SettingsCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
		},

        --保险箱
        ["SafeboxCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.safebox.SafeboxCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
			["HallRely"]=false,
		},
		["SafeboxPswPlaneCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.safeboxpasswordplane.SafeboxPasswordPlaneCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ['ZOrder'] = 1999  --MainCtrl:_tryAutoTakeRelief() 中提高了界面层级，导致密码框也要提高
		},

        --退出
        ["ExitTipPlugin"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.exittip.ExitTipCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=false,
		},
        ["ExitProtectPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.exitprotect.ExitProtectCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
        },

        --每日活动（好友房会触发）
        ["DailyActivitysCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.dailyactivity.DailyActivitysCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
		},

        ["MonthCard"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.monthcard.MonthCardCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },

        ["WeekCard"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.WeekCard.WeekCardCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        
        ["WeekMonthSuperCardCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        
        ["NewPlayerGiftCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.newPlayerGift.NewPlayerGiftCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        
        --充值有礼
        ["RechargeActivityCtrl"] =
    	{
        	["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.RechargeActivity.RechargeActivityCtrl",
		    ["EnterSceneType"]="",
        	["EnterSceneTime"]=0,
        	["LoginRely"]=true,
        	["HallRely"]=false,
       	},

        --限时礼包
        ["LimitTimeGift"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='BlockLayer',
			["PluginMainViewFullPath"]="src.app.plugins.limitTimeGift.limitTimeGiftCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
        },

        ["BankruptcyCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.Bankruptcy.BankruptcyCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        
        --活动中心
        ["ActivityCenterCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.activitycenter.ActivityCenterCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["LoginoffEvent"]=true,
        },

        --发奖界面
        ["RewardTipCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.RewardTip.RewardTipCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        --发奖界面(目前仅用于每日抽奖)
        ["RewardTipCtrlEx"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.RewardTipEx.RewardTipCtrlEx",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },

        --新手赠银
        ["NewUserRewardPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.NewUserReward.NewUserRewardCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },

        --联运游戏
        ["OutlayGame"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.outlaygame.OutlayGameCtrl",
            ["EnterSceneType"]="CROSSFADE",
            ["EnterSceneTime"]=0.5,
            ["LoginRely"]=true,
        },
        
        -- 百元红包弹窗
        ["RedPack100Plugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.RedPack100.RedPack100Ctrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=true,
        },
        ["RedPack100ExplainPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.RedPack100.RedPack100ExplainCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        ["RedPack100SimplePlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.RedPack100.RedPack100SimpleCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        -- 百元红包礼券模式弹窗
        ["Vocher_RedPack100Plugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.RedPack100Vocher.Vocher_RedPack100Ctrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=true,
        },
        ["Vocher_RedPack100SimplePlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.RedPack100Vocher.Vocher_RedPack100SimpleCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=true,
        },
        ["Vocher_RedPack100ExplainPlugin"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.RedPack100Vocher.Vocher_RedPack100ExplainCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        ["GoldSilverCtrl"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='LayOnWidget',
			["PluginMainViewFullPath"]="src.app.plugins.goldsilver.GoldSilverCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
        },
        ["GoldSilverBuyLayer"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='LayOnWidget',
			["PluginMainViewFullPath"]="src.app.plugins.goldsilver.GoldSilverBuyLayerCtrl",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
        },
        ["GoldSilverCtrlCopy"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='LayOnWidget',
			["PluginMainViewFullPath"]="src.app.plugins.goldsilverCopy.GoldSilverCtrlCopy",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
        },
        ["GoldSilverBuyLayerCopy"] =
		{
			["Enable"]= true,
			["EnterPluginActionType"]='LayOnWidget',
			["PluginMainViewFullPath"]="src.app.plugins.goldsilverCopy.GoldSilverBuyLayerCtrlCopy",
			["EnterSceneType"]="",
			["EnterSceneTime"]=0,
			["LoginRely"]=true,
        },
        ["WinningStreakCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.WinningStreak.WinningStreakCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["WinningStreakRuleCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.WinningStreak.WinningStreakRuleCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["WinningStreakRewardCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.WinningStreak.WinningStreakRewardCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["NobilityPrivilegeCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.NobilityPrivilege.NobilityPrivilegeCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["NobilityPrivilegeGiftCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["MemberTransferCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.MemberTransfer.MemberTransferCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
         ["LuckyCatCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.LuckyCat.LuckyCatCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["LuckyCatRuleCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.LuckyCat.LuckyCatRuleCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["AutoSupplyCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.AutoSupply.AutoSupplyCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["xyxz"] = 
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='PushScene',
            ["PluginMainViewFullPath"]="src.app.plugins.xyxz.XYXZCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=true
        },
        ["GiftExchange"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.giftexchange.GiftExchangeCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["TimingGameLayer"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.TimingGame.TimingGameLayer.TimingGameLayerCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["TimingGameGetTicket"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.TimingGame.TimingGameGetTicket.TimingGameGetTicketCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["TimingGameRule"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.TimingGame.TimingGameRule.TimingGameRuleCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["TimingGameRewardDesc"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.TimingGame.TimingGameRewardDesc.TimingGameRewardDescCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["TimingGameRank"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.TimingGame.TimingGameRank.TimingGameRankCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["TimingGameApplySucceed"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.TimingGame.TimingGameApplySucceed.TimingGameApplySucceedCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["TimingGameTicketTask"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.TimingGame.TimingGameTicketTask.TimingGameTicketTaskCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["RechargePool"] = {
            ["Enable"] = true,
            ["PluginMainViewFullPath"] = "src.app.plugins.rechargepool.RechargePoolCtrl",
            ["EnterPluginActionType"] = 'BlockLayer',
            ["EnterSceneType"] = "",
            ["EnterSceneTime"] = 0,
            ["LoginRely"] = true,
            ["DisableBlock"] = false
        },
        --感恩回馈活动
        ["GratitudeRepayCtrl"] = {
            ["Enable"] = true,
            ["PluginMainViewFullPath"] = "src.app.plugins.GratitudeRepay.GratitudeRepayCtrl",
            ["EnterPluginActionType"] = 'BlockLayer',
            ["EnterSceneType"] = "",
            ["EnterSceneTime"] = 0,
            ["LoginRely"] = true,
            ["DisableBlock"] = false
        },
        --感恩回馈活动概率显示
        ["GratitudeRepayRuleCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.GratitudeRepay.GratitudeRepayRuleCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["WatchVideoTakeReward"] = {
            ["Enable"] = true,
            ["PluginMainViewFullPath"] = "src.app.plugins.watchvideotakereward.WatchVideoTakeRewardCtrl",
            ["EnterPluginActionType"] = 'BlockLayer',
            ["EnterSceneType"] = "",
            ["EnterSceneTime"] = 0,
            ["LoginRely"] = true,
            ["DisableBlock"] = false
        },
        ["RechargeFlopCard"] = {
            ["Enable"] = true,
            ["PluginMainViewFullPath"] = "src.app.plugins.RechargeFlopCard.RechargeFlopCardCtrl",
            ["EnterPluginActionType"] = 'BlockLayer',
            ["EnterSceneType"] = "",
            ["EnterSceneTime"] = 0,
            ["LoginRely"] = true,
            ["DisableBlock"] = false
        },
        ["ContinueRechargeCtrl"] = 
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.continuerecharge.ContinueRechargeCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        ["LuckyPackCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.LuckyPack.LuckyPackCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },

        ["MoreGameCtrl"] =
        {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.outlaygame.MoreGameCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        ["OutlayGameCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.outlaygame.OutlayGameCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["VivoPrivilegeStartUpCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.VivoPrivilegeStartUp.VivoPrivilegeStartUpCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["AnchorPosterCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.AnchorPoster.AnchorPosterCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["AnchorTableCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.AnchorTable.AnchorTableCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["AnchorRulePasswordCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.AnchorTable.AnchorRulePasswordCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["AnchorLuckyBagCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.AnchorLuckyBag.AnchorLuckyBagCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["LuckyBagRewardListCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.AnchorLuckyBag.LuckyBagRewardListCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ["CheckTiktokAccountCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.AnchorLuckyBag.CheckTiktokAccountCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },
        ['ChargeAgreement'] = {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.shop.ChargeAgreementCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
        },
        
        ['ValuablePurchase'] = {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.ValuablePurchase.ValuablePurchaseCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },

        ["SecondLayerTeam2V2RuleCtrl"] =
        {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.mainpanel.room.SecondLayerTeam2V2Rule.SecondLayerTeam2V2RuleCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },

        ["QRCodePayCtrl"] = {
            ["Enable"]= true,
            ["PluginMainViewFullPath"]="src.app.plugins.QRCodePay.QRCodePayCtrl",
            ["EnterPluginActionType"]='BlockLayer',
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
            ["DisableBlock"]=false
        },

        ["ExchangeHuafeiCtrl"] =
        {
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.ExchangeHuafeiCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
        },

        ["ActiveHelpPanelCtrl"] =
        {
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.invitegift.oldusergift.ActiveHelpPanelCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
        },

        ["ReportCtrl"] =
        {
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.Report.ReportCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=false,
        },
        
        ['PeakRankCtrl'] = {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.PeakRank.PeakRankCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
        ['PeakRankRuleCtrl'] = {
            ["Enable"]= true,
            ["EnterPluginActionType"]='BlockLayer',
            ["PluginMainViewFullPath"]="src.app.plugins.PeakRank.PeakRankRuleCtrl",
            ["EnterSceneType"]="",
            ["EnterSceneTime"]=0,
            ["LoginRely"]=true,
        },
    }
}

return PluginConfig
