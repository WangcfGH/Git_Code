local viewCreator 	=cc.load('ViewAdapter'):create()
local NewPlayerGiftModel    = import("src.app.plugins.newPlayerGift.NewPlayerGiftModel"):getInstance()

viewCreator.viewConfig={
    'res/hallcocosstudio/newplayergift/layer_newplayergift.csb',
    {
        panelShade = "Panel_Shade",
        panelMain = "Panel_Main",
        {
		          _option={prefix='Panel_Main.'},
            panelTotalDays = 'Panel_TotalDays',
            {
                _option={prefix='Panel_TotalDays.'},
                fnt1 = 'Fnt_1',
                fnt2 = 'Fnt_2',
                fntTotalDay = 'Fnt_Num',
                fnt3 = 'Fnt_3',
            },
            fntGiftIndex = 'Fnt_Days',
            btnTake ='Btn_Take',
            btnRewarded = 'Btn_Rewarded',
            imgReward = 'Img_Reward',
            {
                 _option={prefix='Img_Reward.'},
                imgSilver = 'Img_Silver',
                imgTicket = 'Img_Ticket',
            },
            img251 = 'Image_251',
            textGiftCount = 'Text_GiftCount',
            btnClose = 'Btn_Close',
            nodeGiftPop = 'Node_GiftPop',
            {
                _option={prefix='Node_GiftPop.'},
                panelShadePop = "Panel_Shade",
                panelPop = 'Panel_Main',
                {
                    _option={prefix='Panel_Main.'},
                    popLightAni = 'Node_LightAni',
                    panelBackPop = 'Img_Back',
                    {_option={prefix='Img_Back.'},imgTitlePop = 'Img_Title'},
                    popStartAni = 'Node_StarAni',
                    imgRewardPop = 'Img_Reward',
                    {
                        _option={prefix='Img_Reward.'},
                        imgSilverPop = 'Img_Silver',
                        imgTicketPop = 'Img_Ticket',
                    },
                    textRewardPop = 'Text_Reward',
                    btnClosePop = 'Btn_Close',
                }
            },
            img250 = 'Img_250',
            img252 = 'Img_252'
        }
    },
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Panel_Main",
        ["isPlayAni"] = true
    }
}



----添加弹出动画
--function viewCreator:createViewNode(filename)
--	if(filename and filename:len()>0)then
--		  self._viewNode  =cc.CSLoader:createMyNode(filename)	--:addTo(self)

--    --播放弹窗动画
--    local action    =cc.CSLoader:createTimeline(filename)
--    self._viewNode:runAction(action)
--    action:play("animation0", false)
--	else
--		self._viewNode=ccui.Widget:new()
--	end
--	if(DEBUG)then
--		self._viewNode._hostname=self.__cname
--	end

--	return self._viewNode
--end

function viewCreator:onCreateView(viewNode)
    local lightAniFile = "res/hallcocosstudio/email/emailAni/Node_Huan.csb"
    local starAniFile = "res/hallcocosstudio/email/emailAni/Node_Star.csb"
    if viewNode.popLightAni then
        local lightAni = cc.CSLoader:createTimeline(lightAniFile)
        viewNode.popLightAni:runAction(lightAni)
        lightAni:play("animation0", true)
    end
    if viewNode.popStartAni then
        local starAni = cc.CSLoader:createTimeline(starAniFile)
        viewNode.popStartAni:runAction(starAni)
        starAni:play("animation0", true)
    end
end

return viewCreator