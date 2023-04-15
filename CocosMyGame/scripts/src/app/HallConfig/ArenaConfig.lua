local ArenaConfig = {
    ["ArenaEndByHPZero"] = "您当前血量为0，本轮挑战赛结束！",
    ["ArenaLevelDistanceDistribution"] =  {
        --nValue：等级分值，distance：等级距离，均以比例表示；用于支持非均匀分值的等级均匀分布在进度条上
        {
            ["index"] = 1,
            ["nValue"] = 0.055556,
            ["distance"] = 0.082857
        },
        {
            ["index"] = 2,
            ["nValue"] = 0.111111,
            ["distance"] = 0.205714
        },
        {
            ["index"] = 3,
            ["nValue"] = 0.166667,
            ["distance"] = 0.328571
        },
        {
            ["index"] = 4,
            ["nValue"] = 0.277778,
            ["distance"] = 0.451429
        },
        {
            ["index"] = 5,
            ["nValue"] = 0.444444,
            ["distance"] = 0.604286
        },
        {
            ["index"] = 6,
            ["nValue"] = 0.722222,
            ["distance"] = 0.777143
        },
        {
            ["index"] = 7,
            ["nValue"] = 1,
            ["distance"] = 1
        }
    },
    ["ArenaRewardTypeList"] = {
        {
            ["name"] = "silver",
            ["nType"] = 1,
            ["typeUnit"] = "两",
            ["imageName"] = "GameCocosStudio/plist/Upgrade/Upgrade_Img_rewardSilver.png",
            ["desc"] = "银子"
        },
        {
            ["name"] = "exchange_ticket",
            ["nType"] = 3,
            ["typeUnit"] = "张",
            ["imageName"] = "GameCocosStudio/plist/Upgrade/Upgrade_Img_rewardExchange.png",
            ["desc"] = "礼券"
        },
        {
            ["name"] = "cardmaster",
            ["nType"] = 11,
            ["typeUnit"] = "天",
            ["imageName"] = "img_reward_cardmaster.png",
            ["desc"] = "记牌器"
        }
    },
    ["ArenaBonusTypeList"] = {
        {
            ["name"] = "first_win",
            ["nType"] = 1,
            ["imageName"] = "img_bonus_firstwin.png",
            ["desc"] = "首胜"
        },
        {
            ["name"] = "room_grade",
            ["nType"] = 2,
            ["imageName"] = "img_bonus_room.png",
            ["desc"] = "场次"
        },
        {
            ["name"] = "win_plus",
            ["nType"] = 3,
            ["imageName"] = "img_bonus_room.png",
            ["desc"] = "胜利加成"
        },
        {
            ["name"] = "lose_plus",
            ["nType"] = 4,
            ["imageName"] = "img_bonus_room.png",
            ["desc"] = "失败加成"
        },
        {
            ["name"] = "streaking",
            ["nType"] = 5,
            ["imageName"] = "img_bonus_room.png",
            ["desc"] = "连胜加成"
        }
    }
}

return ArenaConfig
