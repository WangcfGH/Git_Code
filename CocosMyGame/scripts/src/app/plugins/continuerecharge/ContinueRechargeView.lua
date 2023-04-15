local ContinueRechargeView = cc.load('ViewAdapter'):create()

ContinueRechargeView.viewConfig = {
    'res/hallcocosstudio/huafei/huafei.csb',
    {
        panelMain = 'Panel_Main',
        {
            _option = { prefix = 'Panel_Main.' },
            txtHuaFei = 'Fnt_huafei',
            closeBtn = 'Btn_close',
            rechargeModeBtn = 'Btn_chongzhi',
            exchangeModeBtn = 'Btn_duihuan',
            introduceBtn = 'Btn_shuoming',
            tip1Panel = 'Panel_tip1',
            {
                _option = { prefix = 'Panel_tip1.' },
                text1_1 = 'Text_1',
                {
                    _option = { prefix = 'Text_1.' },
                    tipDayRechargeNum = 'Text_3',
                },
                text1_2 = 'Text_2',
                {
                    _option = { prefix = 'Text_2.' },
                    tipHuaiFeiNum = 'Text_10' 
                }
            },

            tip2Panel = 'Panel_tip2',
            {
                _option = { prefix = 'Panel_tip2.' },
                text2_1 = 'Text_1',
                {
                    _option = { prefix = 'Text_1.' },
                    tipExchangeNum = 'fnt_3',
                },
                text2_2 = 'Text_2',
                {
                    _option = { prefix = 'Text_2.' },
                    tipExchangeTotalNum = 'fnt_21'
                },
                tipTime = 'Text_time',
            },
            
            rechargePanel = 'Panel_huafei',
            {
                _option = { prefix = 'Panel_huafei.' },
                img_ItemBG = 'Img_ItemBG',
                {
                    _option = { prefix = 'Img_ItemBG.' },
                    rewardMainNode = 'Image_bg1',
                    rewardSubNode = 'Image_bg2',
                    buyBtn = 'Button_buy',
                    nodeDetail = 'Node_BagDetail'
                },
                Img_ItemBG2 = 'Img_ItemBG2',
                {
                    _option = { prefix = 'Img_ItemBG2.' },
                    ticketText = 'Text_huafei'
                },
            },
            exchangePanel = 'Panel_duihuan',
            {
                _option = { prefix = 'Panel_duihuan.' },
                progressPanel = 'Panel_jindu',
                {
                    _option = { prefix = 'Panel_jindu.' },
                    progress = "LB_jd",
                    lackDayNumText = "Text_time"
                },
                exchangeNode1 = 'Img_ItemBG',
                exchangeNode2 = 'Img_ItemBG2'
            },
            introducePanel = 'Panel_shuoming',
            {
                _option = { prefix = 'Panel_shuoming.' },
                introduceCloseBtn = 'Btn_close'
            }
        }
    }
}

return ContinueRechargeView