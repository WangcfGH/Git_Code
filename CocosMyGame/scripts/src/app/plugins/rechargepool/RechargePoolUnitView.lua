
local RechargePoolUnitView = {
    DayUnitCsbPath = 'res/hallcocosstudio/rechargepool/RechargePool_DayUnit.csb',
    DayUnitViewConfig = {
        panelMain = 'Panel_Main',
        {
            _option = { prefix = 'Panel_Main.' },

            textDay = 'Text_Day',
            textValue = 'Text_Value',
            btnTake = 'Btn_Take',
            btnShop = 'Btn_Shop',
            imgLocked = 'Img_Tomorrow',
            imgStateFuture = 'Img_Future',
            imgStateNow = 'Img_Now',
            imgStateNoReward = 'Img_NoDeposit',
        }
    },

    RankUnitCsbPath = 'res/hallcocosstudio/rechargepool/RechargePool_RankUnit.csb',
    RankUnitViewConfig = {
        panelMain = 'Panel_Main',
        {
            _option = { prefix = 'Panel_Main.' },

            imgHightLight = 'Img_HighLight',
            textRank = 'Text_Rank',
            textUser = 'Text_User',
            textValue = 'Text_Value',
            textReward = 'Text_Reward',
        }
    }
}

return RechargePoolUnitView

