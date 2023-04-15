local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    "res/hallcocosstudio/RewardCtrl/Layer_RewardCtrlEx.csb",
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
                checkBox = 'CheckBox',
                btnSure = 'Btn_Sure',
                btnWatchVideo = 'Btn_WatchVideo'
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
end

return viewCreator