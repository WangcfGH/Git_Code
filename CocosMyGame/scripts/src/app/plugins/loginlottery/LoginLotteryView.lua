
local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/loginlottery/layer_loginlottery.csb',
    {
        lotteryMainPanel='Panel_LotteryMain',
	    {
		    _option=
		    {
			    prefix='Panel_LotteryMain.'
            },
            {
                _option=
                {
                    prefix='Image_Back.'
                },
                loginDays='Fnt_Day',
            },
            {
                _option=
                {
                    prefix='Panel_Lottery.'
                },
                lottery='Sprite_Lottery',
                {
                    _option=
                    {
                        prefix='Sprite_Lottery.'
                    },
                    lotteryParts='Image_Parts',
                    {
                        _option=
                        {
                            prefix='Image_Parts.'
                        },
                        part1='Fnt_Part1',
                        part2='Fnt_Part2',
                        part3='Fnt_Part3',
                        part4='Fnt_Part4',
                        part5='Fnt_Part5',
                    },
                },
                drawBt='Btn_Go',
                {
                    _option=
                    {
                        prefix='Btn_Go.'
                    },
                    drawText='Text_Count',
                    imgWatchVideo = 'Img_WatchVideo'
                },
                aniGobt='Panel_GoAni',
                nodeResultLight = "Img_Light"
            },
            {
                _option=
                {
                    prefix='Panel_Reward.'
                },
                -- {            
                --     _option=
                --     {
                --         prefix='Img_Login.'
                --     },
                --     loginDays='Fnt_Days',
                -- },
                reward1Bt='Btn_Reward1',
                {
                    _option=
                    {
                        prefix='Btn_Reward1.'
                    },
                    reward1Icon='Img_Icon',
                    reward1Days='Text_Days',
                    reward1Count='Text_Count',
                },
                reward2Bt='Btn_Reward2',
                {
                    _option=
                    {
                        prefix='Btn_Reward2.'
                    },
                    reward2Icon='Img_Icon',
                    reward2Days='Text_Days',
                    reward2Count='Text_Count',
                },
                reward3Bt='Btn_Reward3',
                {
                    _option=
                    {
                        prefix='Btn_Reward3.'
                    },
                    reward3Icon='Img_Icon',
                    reward3Days='Text_Days',
                    reward3Count='Text_Count',
                },
                reward4Bt='Btn_Reward4',
                {
                    _option=
                    {
                        prefix='Btn_Reward4.'
                    },
                    reward4Icon='Img_Icon',
                    reward4Days='Text_Days',
                    reward4Count='Text_Count',
                },
                loginTip='Text_Tip',
            },
            closeBt='Btn_Close',
            helpBt='Btn_Help',
            nodePop='Node_Popup',
		    {
                _option=
		        {
			        prefix='Node_Popup.'
		        },
                {
                    _option=
		            {
			            prefix='Panel_Main.'
		            },
                    popLightAni='Node_LightAni',
                    popStartAni='Node_StarAni',
                    {
                        _option=
		                {
			                prefix='Img_Reward.'
		                },
                        popSilverIcon='Img_SilverIcon',
                        popVoucherIcon='Img_VoucherIcon',
                    },
                    popText='Text_Reward',
                    popDouble='Img_Double',
                    popTipImg='Img_Tip',
                    popTipText='Text_Tip',
                    popClose='Btn_Close',
                },
		    }
	    }
    },
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Panel_LotteryMain",
        ["isPlayAni"] = true
    }
}

function viewCreator:onCreateView(viewNode)
    local lightAniFile = "res/hallcocosstudio/email/emailAni/Node_Huan.csb"
    local starAniFile = "res/hallcocosstudio/email/emailAni/Node_Star.csb"
    if viewNode.popLightAni then
        local lightAni = cc.CSLoader:createTimeline(lightAniFile)
        viewNode.popLightAni:runAction(lightAni)
        lightAni:play("animation0", true)
    end
    if viewNode.popStartAni then
        local starAni = cc.CSLoader:createTimeline(starAniFile)
        viewNode.popStartAni:runAction(starAni)
        starAni:play("animation0", true)
    end
end

return viewCreator
