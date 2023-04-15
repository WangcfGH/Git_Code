local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/activitycenter/activitycenter.csb',
	{
        Panel_Main = 'Panel_Main',
        _option={prefix='Panel_Main.Panel_Animation.'},
		bottomPanel = "Panel_Bottom",
        panelDialog = 'Image_Bottom',
        {
		    _option = {prefix='Image_Bottom.'},
		    closeBtn = 'Button_Close',

            panelTitleBtn='Panel_Title_Btn',
            {
		        _option = {prefix='Panel_Title_Btn.'},
                jchdBtn = 'Button_jchd',
                jchdRedDot = 'Img_jchdRedDot',
                {
                    _option = {prefix='Img_jchdRedDot.'},
                    jchdRedDotNum = 'Text_RedNum',
                },
                yxggBtn = 'Button_yxgg',
                yxggRedDot = 'Img_yxggRedDot',
            },              
        },
        dikuang = 'Image_DiKuang',   
        --noActivityPanel = 'Panel_NoActivity',
        activityPanel = 'Panel_Activity',
        {
            _option = {prefix='Panel_Activity.'},
            activityButtonsPanel = 'ScrollView_Buttons',
            activitiesPanel = 'Panel_Activities',
            Img_NoActivitys='Img_NothingBG',
        },
        noticePanel = 'Panel_Notice',
        {
            _option = {prefix='Panel_Notice.'},
            noticeButtonsPanel = 'ScrollView_Buttons',
            noticesPanel = 'Panel_Notices',
            Img_NoNotice='Img_NoNoticeBG',
        },  
        biankuangPanel = 'Panel_3',
        {
            _option = {prefix='Panel_3.'},
            nodeTitle = 'Node_Title',
            imageJchd = 'Image_Jchd',
            imageYxgg = 'Image_Yxgg'
        },    			
        imgWait = 'Image_Wait',
    },
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Panel_Main",
        ["isPlay"] = true
    }
}

return viewCreator

