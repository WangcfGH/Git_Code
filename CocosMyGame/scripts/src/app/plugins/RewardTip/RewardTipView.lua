local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    "res/hallcocosstudio/RewardCtrl/Layer_RewardCtrl.csb",
    {
        panelShade = 'Panel_Shade',
        panelMain = 'Panel_Main',
        {
            _option={prefix = 'Panel_Main.'},
            Img_Huan = 'Img_Huan',
            Img_Title = 'Img_Title',
            List_Item = 'List_Item',
            Panel_Btns = 'Panel_Btns',
            {
                _option={prefix = 'Panel_Btns.'},
                Btn_ToSeize = 'Btn_ToSeize',
                Btn_Sure = 'Btn_Sure',
                Btn_ToPlay = 'Btn_ToPlay',
                Btn_ToApply = 'Btn_ToApply',
                Btn_ToExchange = 'Btn_ToExchange',
                {
                    _option={prefix = 'Btn_ToExchange.'},
                    Panel_Bubble = 'Panel_Bubble',
                    Text_Tip = 'Text_Tip'
                },
            }
        }
    }
}

function viewCreator:createViewNode(filename)
	if(filename and filename:len()>0)then
        self._viewNode=cc.CSLoader:createMyNode(filename)	--:addTo(self)
        local action    =cc.CSLoader:createTimeline(filename)
        self._viewNode:runAction(action)
        action:play("animation0", false)
	else
		self._viewNode=ccui.Widget:new()
	end
	if(DEBUG)then
		self._viewNode._hostname=self.__cname
	end

	return self._viewNode
end

function viewCreator:onCreateView(viewNode)
    if viewNode.Img_Huan then
        viewNode.Img_Huan:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 60)))
    end
    if viewNode.Panel_Btns then
        viewNode.Panel_Btns:setVisible(false)
    end
    if viewNode.Btn_ToSeize then
        viewNode.Btn_ToSeize:setVisible(false)
    end
    if viewNode.Btn_ToPlay then
        viewNode.Btn_ToPlay:setVisible(false)
    end
    if viewNode.Btn_ToApply then
        viewNode.Btn_ToApply:setVisible(false)
    end
    if viewNode.Btn_ToExchange then
        viewNode.Btn_ToExchange:setVisible(false)
    end
    if viewNode.Panel_Bubble then
        viewNode.Panel_Bubble:setVisible(false)
    end
    if viewNode.Text_Tip then
        viewNode.Text_Tip:setVisible(false)
    end
end

return viewCreator