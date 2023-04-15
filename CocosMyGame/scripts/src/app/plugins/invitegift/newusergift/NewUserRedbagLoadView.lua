

local viewCreator=cc.load('ViewAdapter'):create()
viewCreator.viewConfig={
    'res/hallcocosstudio/invitegiftactive/newuser/node_redbag.csb',
	{
        Panel_main = "Panel_main",
        {
            _option={prefix='Panel_main.'},
		    Node_main_icon='Node_main_icon',
            {
                _option         = {prefix = 'Node_main_icon.Panel_1.'},
                Button_open1         = 'Button_open',
                Text_money         = "Text_money",
    
            },
            
        },
        Panel_game = "Panel_game",
        {
            _option={prefix='Panel_game.'},
		    Node_game_icon='Node_game_icon',
            {
                _option         = {prefix = 'Node_game_icon.Panel_1.'},
                Button_open         = 'Button_open',
                Text_Money         = "Text_Money",
                Text_AddMoney = "Text_AddMoney",
                Text_Money1 = "Text_Money1"

    
            },
            Node_RedbagFei='Node_RedbagFei',
            {
                _option         = {prefix = 'Node_RedbagFei.Panel_5.'},
                Text_addMoney1         = 'Text_addMoney1',
            },
            Node_bar = "Node_bar",
           
        },
	}
}

return viewCreator
