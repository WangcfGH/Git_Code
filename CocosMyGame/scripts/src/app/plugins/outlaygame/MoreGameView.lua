local viewCreator     =cc.load('ViewAdapter'):create()
 
viewCreator.viewConfig={
	'res/hallcocosstudio/room/moregame.csb',
	{
        mainPannel = 'Panel_Main',
        {
            _option={prefix='Panel_Main.'},
            operatePanle = 'Operate_Panel',
            {
                _option = { prefix = 'Operate_Panel.'},
                panelAnimation = 'Panel_Animation',
                {                                  
                    _option={prefix = 'Panel_Animation.'},
                    backBtn = 'Btn_Back',
                    listRoom = 'List_Room'
                }    
            }
        }
        
    }
}

return viewCreator