local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/activitycenter/phonefeegift.csb',
    {
        _option={prefix='Panel_Main.'},
        panelCountDown  = 'Panel_count_down',
        {
            _option={prefix='Panel_count_down.'},
            textLeftSec='Txt_LeaveSec',
        },
        panelEggProcess  = 'Panel_egg_process',
        {
            _option={prefix='Panel_egg_process.'},
            loadingBar='LoadingBar',
            fntProcess='Fnt_process',
        },
        panelEggLeft  = 'Panel_egg_left',
        {
            _option={prefix='Panel_egg_left.'},
            imgEggBrokenleft='Img_egg_broken',
            {
                _option={prefix='Img_egg_broken.'},
                imgHetu1='Img_hetu1',
            },
            imgEggNomalLeft='Img_egg_nomal',
            nodeZadanLeft='Node_zadan_left',
        },
        panelEggMid  = 'Panel_egg_mid',
        {
            _option={prefix='Panel_egg_mid.'},
            imgEggBrokenMid='Img_egg_broken',
            {
                _option={prefix='Img_egg_broken.'},
                imgHetu2='Img_hetu2',
            },
            imgEggNomalMid='Img_egg_nomal',
            {
                _option={prefix='Img_egg_nomal.'},
                imgBubbleMid='Img_bubble',
                {
                    _option={prefix='Img_bubble.'},
                    textDuiju='Txt_duiju',
                },
            },
            nodeZadanMid='Node_zadan_mid',
        },
        panelEggRight  = 'Panel_egg_right',
        {
            _option={prefix='Panel_egg_right.'},
            imgEggBrokenRight='Img_egg_broken',
            {
                _option={prefix='Img_egg_broken.'},
                imgHetu3='Img_hetu3',
            },
            imgEggNomalRight='Img_egg_nomal',
            {
                _option={prefix='Img_egg_nomal.'},
                imgBubbleRight='Img_bubble',
                {
                    _option={prefix='Img_bubble.'},
                    textLogin='Txt_login',
                },
            },
            nodeZadanRight='Node_zadan_right',
        },    
        btnGoFight='Button_fight',
        {
            _option={prefix='Button_fight.'},  
            imgGoFight='Sprite_go_fight',
        },
        btnReward='Button_reward',
        {
            _option={prefix='Button_reward.'},  
            imgLingQu='Sprite_lingqu',
        },
        nodeReward='Node_reward_huafei',
        panelAniShade='Panel_Ani_Shade',
        rewardHueFei='Img_reward_huafei',
        {
            _option={prefix='Img_reward_huafei.'},  
            brokenBubble4 = 'broken_bubble4',
            {
                _option={prefix='broken_bubble4.'},  
                txt_tiphuafe='Txt_duiju_4',
            },
            imgHuafei='Img_huafei_2yuan',
            {
                _option={prefix='Img_huafei_2yuan.'},  
                fntHuafei='Fnt_huafei',
            },
        },
    }
}

function viewCreator:onCreateView(viewNode)

end

return viewCreator