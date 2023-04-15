local WatchVideoTakeReward=cc.load('ViewAdapter'):create()

WatchVideoTakeReward.viewConfig=
{
	'res/hallcocosstudio/watchvideotakedeposit/wvtd.csb',
    {
        panelMain = "Panel_Main",
        {
            _option = { prefix = "Panel_Main." },
            closeBtn = "Btn_Close",
            watchVideoBtn = "Button_WatchVideo",
            {
                _option = { prefix = 'Button_WatchVideo.' },
                watchVideoProcess = 'Text_Process'
            },
            itemPanal = "Panel_wuping",
            {
                _option = { prefix = 'Panel_wuping.'},
                btn1 = 'Button_1',
                btn2 = 'Button_2',
                btn3 = 'Button_3',
                btn4 = 'Button_4',
                btn5 = 'Button_5',
                btn6 = 'Button_6',
                btn7 = 'Button_7',
                btn8 = 'Button_8',
                btn9 = 'Button_9'
            },
            {
                _option = { prefix = "Panel_cishu." },
                loadingBar = "img_loading",
                countProgressText = "text_jindu",
                {
                    _option = { prefix = 'text_tip.'},
                    countTextTip = 'text_num', -- 寻宝x次必中文字说明
                }
            }
        }
    }   
}

return WatchVideoTakeReward