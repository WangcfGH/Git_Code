local OldUserInitGiftView = cc.load('ViewAdapter'):create()

OldUserInitGiftView.viewConfig = {
    'res/hallcocosstudio/invitegiftactive/olduser/olduserinitgift.csb',
    {
        panelMain = 'PanelMain',
        {
            _option = { prefix = 'Panel_Main.' },
            {
                panelAnimation = 'Panel_Animation',
                {
                    _option = { prefix = 'Panel_Animation.' },
                    nodeBgAniPos = 'Node_BgAniPos',
                    btnHelp = "Btn_help",
                    panelUnopen = 'Panel_Unopen',
                    {
                        _option = { prefix = 'Panel_Unopen.' },
                        btnOpen = 'Btn_Open',
                    },
                    panelOpenRes = 'Panel_OpenResult',
                    {
                        _option = { prefix = 'Panel_OpenResult.' },

                        textOpenHint1 = 'Text_OpenResultHint1',
                        {
                            _option = { prefix = 'Panel_TotalRewardInfo.' },
                            textTotalRewardOpen = 'Text_TotalReward',
                            Image_huafeibg = "Image_huafeibg",
                            {
                                _option = { prefix = 'Image_huafeibg.' },
                                textTotalHuafei = "Text_TotalHuafei",
                            }
                            

                        },
                        Img_Hit1_0 = "Img_Hit1_0",
                        panelBarOpenRes = 'Panel_Bar',
                        {
                            _option = { prefix = 'Panel_Bar.' },
                            nodeBarPosOpenRes = 'Node_BarPosition',
                            textBarHintOpenRes = 'Text_BarHint'
                        },

                        btnExtract = 'Btn_Extract',
                        Fnt_Extract = "Btn_Extract.Fnt_Extract"
                        -- viewNode.btnExtract:setTitleText( self._okBtnName )
                    },
                    panelCountStatus = 'Panel_CountStatus',
                    {
                        _option = { prefix = 'Panel_CountStatus.' },
                        textDescribe = 'Text_CountHint1',
                        {
                            _option = { prefix = 'Panel_TotalRewardInfo.' },
                            textTotalRewardCount = 'Text_TotalReward',
                            Image_huafeibg1 = "Image_huafeibg1",
                            {
                                _option = { prefix = 'Image_huafeibg1.' },
                                textTotalHuafei1 = "Text_TotalHuafei1",
                            }
                        },
                        panelBarCount = 'Panel_Bar',
                        {
                            _option = { prefix = 'Panel_Bar.' },
                            nodeBarPosCount = 'Node_BarPosition',
                            imgBarHint = 'Img_Hit1',
                            textCountHint2 = "Text_CountHint2"
                        },
                        btnBout = 'Btn_Bout',
                        btnAccelerate = 'Btn_Accelerate',
                        Img_frendhelp_bg = "Img_frendhelp_bg",
                        Text_frendhelp = "Img_frendhelp_bg.Text_frendhelp",
                        Img_Tip = "Img_Tip",
                        Text_share_tip = "Img_Tip.Text_share_tip"

                    },
                    panelRewardStatus = 'Panel_RewardStatus',
                    {
                        _option = { prefix = 'Panel_RewardStatus.' },

                        panelBarReward = 'Panel_Bar',
                        {
                            _option = { prefix = 'Panel_Bar.' },
                            nodeBarPosReward = 'Node_BarPosition',
                            imgBarHintReward = 'Img_Hit1',
                            imgBarHintReward2 = 'Img_Hit2',
                        },
                        btnInviteMore = 'Btn_InviteMore',
                        btnLookUp = 'Btn_LookUp',
                        Img_Dot = "Img_Dot",
                        btnReward = 'Btn_Reward',
                        Fnt_Reward = "Btn_Reward.Fnt_Reward",
                        imgTopHint = 'Img_TopHint',
                        {
                            _option = { prefix = 'Panel_TotalRewardInfo.' },
                            textTotalRewardCount2 = 'Text_TotalReward',
                            Image_huafeibg2 = "Image_huafeibg2",
                            {
                                _option = { prefix = 'Image_huafeibg2.' },
                                textTotalHuafei2 = "Text_TotalHuafei2",
                            }
                        },
                        dailinquImg = "Image_77",
                        Panel_getted = "Panel_getted",
                        Text_getted_tip = "Panel_getted.Text_getted_tip",
                        gettedBtn = "Btn_getted"
                    },
                    panelListContent = 'Panel_ListContent',
                    {
                        _option = { prefix = 'Panel_ListContent.' },
                        panelShade = 'Panel_ShadeList',
                        imgListContent = 'ImageListContent',
                        {
                            _option = { prefix = 'ImageListContent.' },
                            listViewUser = 'List_User'
                        }
                    },
                    panelFlowView = 'Panel_FlowView',
                    {
                        _option = { prefix = 'Panel_FlowView.' },
                        btnInvite = 'Btn_FlowInvite',
                    },
                    btnClose = "Btn_Close",

                    Panel_Hint_1 = 'Panel_Hint_1',
                    {
                        _option = { prefix = 'Panel_Hint_1.' },
                        textHint1Reward = 'Text_Hint1_32',
                        textHint2Reward = 'Text_Hint2_34',
                    },
               
                    
                }
            }
        }
    }
}

return OldUserInitGiftView