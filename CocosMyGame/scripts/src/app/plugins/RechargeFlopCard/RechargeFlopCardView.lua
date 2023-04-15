local RechargeFlopCardView=cc.load('ViewAdapter'):create()

RechargeFlopCardView.viewConfig=
{
	'res/hallcocosstudio/RechargeFlopCard/RechargeFlopCard.csb',
    {
        panelMain = "Panel_Main",
        {
            _option = { prefix = "Panel_Main.Panel_Animation." },
            closeBtn = "Btn_Close",
            titleAni = "Node_AniTitle",
            takeSilverAni = "Node_TakeSilver",
            txtTitle = "Text_Title.Text_Title_Desc",
            {
                _option = { prefix = "Node_SilverReward." },
                txtBaseSilver = "Text_BaseSilver",
                txtValueMultiply = "Text_ValueMultiply",
                txtTypeMultiply = "Text_TypeMultiply",
                txtFinalMultiply = "Text_FinalMultiply",
                txtTotalSilver = "Text_TotalSilver",
            },
            txtTotalRecharge = "Node_CurReward.Text_TotalRecharge",
            txtCollectedBoxReward = "Node_CurReward.Text_CollectedReward",
            txtToBeCollectedBoxReward = "Text_SuplusTake",
            btnTakeSilver = "Btn_TakeGift",
            btnNormalBox = "Btn_NormalBox",
            btnBigBox = "Btn_BigBox",
            btnSuperBox = "Btn_SuperBox",
            txtRule = "Text_Rule",
            {
                _option = { prefix = "Text_Rule." },
                txtThree = "Text_Three",
                txtThreeTwo = "Text_ThreeTwo",
                txtFour = "Text_Four",
                txtFive = "Text_Five",
                txtTongHua = "Text_TongHua",
                txtFinal = "Text_Final",
            },
            panelCard1 = "Panel_Card1",
            panelCard2 = "Panel_Card2",
            panelCard3 = "Panel_Card3",
            panelCard4 = "Panel_Card4",
            panelCard5 = "Panel_Card5",
            panelFinal = "Panel_Card5.Panel_Final",
            panelClip = "Panel_Card5.Panel_Final.Panel_Clip",
            btnOneKey = "Btn_OneKey",
            btnRecharge = "Btn_Recharge",
            {
                _option = { prefix = "Node_ValueMultiply." },
                txtA = "Text_A",
                txtK = "Text_K",
                txtQ = "Text_Q",
                txtJ = "Text_J",
                txt10 = "Text_10",
            }
        }
    },
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Panel_Main",
        ["isPlayAni"] = true
    }
}

function RechargeFlopCardView:onCreateView(viewNode)
    local aniLightFile = "res/hallcocosstudio/RechargeFlopCard/wssg.csb"
    
    if viewNode.titleAni then
        local lightAni = cc.CSLoader:createTimeline(aniLightFile)
        viewNode.titleAni:runAction(lightAni)
        lightAni:play("animation0", true)
    end
end

return RechargeFlopCardView