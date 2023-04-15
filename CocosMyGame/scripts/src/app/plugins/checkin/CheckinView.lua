
local checkinView=cc.load('ViewAdapter'):create()

checkinView.viewConfig={
   'res/hallcocosstudio/checkin/checkinpanel.csb',
    {
        _option={prefix="Panel_Main."},
        checkinTabList='Panel_Animation',
        {
            _option={prefix='Panel_Animation.'},
            closeBt='Btn_Close',
            totalCheckedLb='Text_Days',
            todaySumLb='Text_Rewards',
        },
    }
}

return checkinView
