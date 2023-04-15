
local ViewNodeConfig={
    'res/hallcocosstudio/mainpanel/mainpanel.csb',
    {
        imageHallBg = 'Img_BG',
        operatePanle = 'Operate_Panel',
        {
            _option = { prefix = 'Operate_Panel.'},
            settingsBtn = 'Button_Setting',
            exitBtn = "Button_Exit",
            panelQuickStart = 'Panel_QuickStart',

            BtnLuckyCat = 'Button_LuckyCat',
            btnPeakRank = 'Btn_PeakRank',
            nodeRoleAni = "Node_RoleAni",
            nodeBreakEffectAni = "NodeBreakEffectAni",
            nodeBreakOpenAni = "NodeBreakOpenAni",
            nodeBreakCloseAni = "NodeBreakCloseAni",
            panelAreas = 'Panel_Areas',
            panelTop = "Panel_Top",
            {
                 _option = {
                    prefix = 'Panel_Top.'
                },
                userDepositPanel = "Panel_Deposit",
                {
                    _option = {
                        prefix = 'Panel_Deposit.',
                    },
                    userDepositTxt = 'Bmf_Value',
                    depositeChargeBtn = 'Button_Add'
                },
                userScorePanel = "Panel_Score",
                {
                    _option = {
                        prefix = 'Panel_Score.',
                    },
                    userScoreTxt = 'Bmf_Value',
                    scoreChargeBtn = 'Button_Add'
                },
            },

            {
                _option = {
                    prefix = 'Panel_Player.'
                },
                personalInfoBtn = 'Btn_PlayerInfo',
                nobilityPrivilegeBtn = 'Button_NobilityPrivilege',
                PanelNobilityPrivilege = 'Btn_PlayerInfo.Panel_NobilityPrivilege',
                usernameTxt = 'Text_Name',
                memberPic = 'Img_VIP',
                {
                    _option={
                        prefix = 'Btn_PlayerInfo.',
                    },
                    girlHeadPic = 'Img_Girl',
                    boyHeadPic = 'Img_Boy',
                    loginoffPanel = "Panel_Defaulticon",
                    imgIconVerify = 'Img_IconVerify'
                },

                panelPin = 'Panel_Ping',
                {
                    _option = {
                        prefix = 'Panel_Ping.',
                    },
                    imgWifiGreen   = 'Img_Ping_1',
                    imgWifiYellow  = 'Img_Ping_2',
                    imgWifiRed     = 'Img_Ping_3',
                    imgWifiOff     = 'Img_Ping_4',
                    img234GOn      = 'Img_Ping_5',
                    img234GOff     = 'Img_Ping_6',
                    txtPin         = 'Text_Ping',
                },
                panelBattery = 'Panel_Battery',
                {
                    _option = {
                        prefix = 'Panel_Battery.',
                    },
                    batteryBar = 'Progress_Battery',
                },
                {
                    _option = {prefix = 'Panel_LoginMode.',}, 
                    imgIconTcy = "Img_IconTCY",
                    imgIconWechat = "Img_IconWechat",
                }
            },

            --[[dwcNode          = "Node_SkittleAlley",
            {
                _option      = {prefix = 'Node_SkittleAlley.Panel_Main.'},
                dwcBtn       = "Btn_SkittleAlley",
                dwcIconBG    = "Btn_SkittleAlley.Img_ProgressBG",
                downloadBar  = "Btn_SkittleAlley.Loading_DownLoadProgress",
            },]]--

            panelPackSet = "Panel_PackSet",
            panelLeftBar = "Panel_LeftBar",
            panelBottomBar = "Panel_BottomBar",
            {
                _option = { prefix = 'Panel_BottomBar.' },
                redbagPanel = 'Panel_Redbag',
                yqylNode = "Node_yqyl",
                {
                    _option = {prefix = 'Node_yqyl.Panel_2.'},
                    yqylBtn = 'Button_open',
                    yqylDot = "Img_Dot",
        
                },
                redPacketNode = "Node_RedPacket",
                {
                    _option = {prefix = 'Node_RedPacket.'},
                    Image_xyhb_qp = "Image_xyhb_qp",
                    redPacketBtn = 'open_btn',
                    redPacketDot = 'Img_Dot',
                },
            },
            panelMoreBtns = "Panel_MoreBtns",
        },
        Panel_Swallow = "Panel_Swallow"
    }
}

return {
    ViewNodeConfig = ViewNodeConfig
}