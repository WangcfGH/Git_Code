
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/rechargepool/RechargePool.csb',
    {
        panelShade = 'Panel_Shade',
        {
            _option = { prefix = 'Panel_Main.Panel_Animation.' },
            textPoolName = 'Text_Name',
            textDateRange = 'Text_DateRange',
            textTips = 'Text_tips',
            {
                _option = { prefix = 'Panel_Pool.' },
                panelPoolValue = 'Panel_jiangchi',
                textLeftTime = 'Text_Time',
            },
            
            btnClose = 'Btn_close',
            btnRule = 'Btn_Rule',
            panelRule = 'Panel_Rule',
            textRule = 'Panel_Rule.Text_Content',

            scrollDayList = 'ScrollView_DayList',
            btnShop = 'Btn_Shop',
            {
                _option = { prefix = 'Img_Tip.' },
                {
                    _option = { prefix = 'Text_tip.' },
                    textNum = 'Text_num'
                }
            },
            btnToday = 'Btn_Today',
            btnLast = 'Btn_Last',
            btnDayReward = 'Btn_JiangLi',

            panelRank = 'Panel_Rank',
            {
                _option = { prefix = 'Panel_Rank.' },
                scrollRank = 'ScrollView_Rank',
                {
                    _option = { prefix = 'Panel_Rank.Image_myself.' },
                    textMyRank = 'Text_Rank',
                    textMyName = 'Text_User',
                    textMyValue = 'Text_Value',
                    textMyReward = 'Text_Reward',
                    imgMyNoRank = 'Img_Nochongzhi',
                },
            }
        }
    }
}

return viewCreator

