
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/Task/Task.csb',
    {
        {
            _option={prefix='Operate_Panel.'},
            closeBt='Button_1',
        },
        --[[{
            _option={prefix='Panel_animation.'},
            ScoreText="text_score_animation"
        },]]--
        ScrollView='Operate_Panel.ScrollView_1'
    }
}

return viewCreator

