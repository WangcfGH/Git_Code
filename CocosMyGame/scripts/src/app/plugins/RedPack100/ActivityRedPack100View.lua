local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/activitycenter/activityredpack100.csb',
    {
        _option={prefix='Panel_Main.'},
        {
            panelCountDown  = 'Panel_count_down',
            {
                _option={prefix='Panel_count_down.'},
                textLeftSec='Txt_LeaveSec',
            },
            panelMoneyProcess = 'Panel_money_process',
            {
                _option={prefix='Panel_money_process.'},
                lodingBarValue = 'LoadingBar',
                imgDiffMoney = 'Img_diff_money',
                {
                    _option={prefix='Img_diff_money.'},
                    txtDiffValue = 'Txt_diff',
                    txtMinus = 'Txt_minus',
                },
            },
            btnHelp = 'Btn_Help',
            txtLeiji = 'Text_LeijiTixian',
            imgTipsBg = 'Img_Tips_BG',
            listViewUsersReward = 'ListView_UserReward',
            {
                _option={prefix='ListView_UserReward.'},
                panelContent1="Panel_1",
                {
                    _option={prefix='Panel_1.'},
                    spriteFlag1='Sprite_fuhao',
                    txt1='Text_1',
                    txtUserName1 = 'Text_UserName',   
                },
                panelContent2="Panel_2",
                {
                    _option={prefix='Panel_2.'},
                    spriteFlag2='Sprite_fuhao',
                    txt2='Text_1',
                    txtUserName2 = 'Text_UserName',   
                },
                panelContent3="Panel_3",
                {
                    _option={prefix='Panel_3.'},
                    spriteFlag3='Sprite_fuhao',
                    txt3='Text_1',
                    txtUserName3 = 'Text_UserName',   
                },
                panelContent4="Panel_4",
                {
                    _option={prefix='Panel_4.'},
                    spriteFlag4='Sprite_fuhao',
                    txt4='Text_1',
                    txtUserName4 = 'Text_UserName',   
                },
            },
            panelBtns = "Panel_Btns",
            {
                _option={prefix='Panel_Btns.'},
                btnJump = 'Btn_Jump',
                {
                    _option={prefix='Btn_Jump.'},
                    spriteJump = 'Sprite_GoTask',
                    txtBMFont = "TxtBMFont",
                },
                btnBreak = "Btn_Break",
                {
                    _option={prefix='Btn_Break.'},
                    spriteBreak = 'Sprite_GoBreak',
                    nodeBreak = 'NodeBreakAni',
                },
                btnReward = 'Btn_Reward',
                {
                    _option={prefix='Btn_Reward.'},
                    spriteReward = 'Sprite_GoReward',
                    nodeTiqu = 'Tiqu_Ani',
                },
                btnLogin = "Btn_Login",
                {
                    _option={prefix='Btn_Login.'},
                    spriteLoginTip = 'Sprite_LoginTip',
                    txtBMFontTip = "TxtBMFontTip",
                },
            },
            imgTipFight = "Img_Tip",
            {
                _option={prefix='Img_Tip.'},  
                txtTipFight = "Txt_Tip",          
            },
            panelAniShade = 'Panel_Ani_Shade',
            nodeQuxian = 'NodeQuXian',
            panelRMB = 'Panel_RMB',
            {
                _option={prefix='Panel_RMB.'},  
                imgRMB = 'Img_RMB',
                imgRMBTruth = 'Img_RMBtruth',
                {
                    _option={prefix='Img_RMBtruth.'},  
                    imgTixian = 'Img_Tixian',
                },
                imgVocher='Img_Vocher',
                {
                    _option={prefix='Img_Vocher.'}, 
                    imgExchangeBg='Img_ExchangeBg',
                    {
                        _option={prefix='Img_ExchangeBg.'}, 
                        txtWaitExchange='Txt_Wait',
                    },
                },
            }
        }
    }
}


function viewCreator:onCreateView(viewNode)
    if not viewNode then return end
    viewNode.imgVocher:setVisible(false)    --隐藏兑换券模式下的图片


end

return viewCreator