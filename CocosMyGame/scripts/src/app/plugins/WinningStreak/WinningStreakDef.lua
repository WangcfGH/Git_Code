local WinningStreakDef = 
{
    WINNING_STREAK_TOTAL_COUNT = 7,
    WINNING_STREAK_ID = 105,

    WINNING_STREAK_BRONZE   = 1,
    WINNING_STREAK_SILVER   = 2,
    WINNING_STREAK_GOLD     = 3,
    WINNING_STREAK_DIAMOND  = 4,


    WINNING_STREAK_UNSTARTED   = 0,	-- 挑战未开始
	WINNING_STREAK_STARTING    = 1,	-- 挑战正在进行中
	WINNING_STREAK_UNTAKE      = 2,	-- 已完成未领取
	WINNING_STREAK_TAKED       = 3,	-- 已完成已领取
	WINNING_STREAK_OUTDATE     = 4,	-- 已过期

    GR_GET_WINNING_STREAK_INFO    = 401801,
    GR_BUY_WINNING_STREAK_CHANCE  = 401802,
    GR_TAKE_WINNING_STREAK_AWARD  = 401803,
    GR_BUY_WINNING_STREAK_SUCCESS = 401804,
    GR_BUY_CHALLENGE_CHANCE_FAIL  = 401805,
    GR_AUTO_TAKE_WINNING_STREAK_AWARD = 401807,
    GR_CHALLENGE_BUTTON_CLICK_LOG = 401808,

    WINNING_STREAK_APPTYPE_AN     = 1,
	WINNING_STREAK_APPTYPE_IOS    = 2,
	WINNING_STREAK_APPTYPE_SET    = 3,

    WINNING_STREAK_HALL     = 1,
	WINNING_STREAK_GAME    = 2,

    WINNING_STREAK_BTN_TAB      = 1,
    WINNING_STREAK_BTN_BRONZE   = 2,
    WINNING_STREAK_BTN_SILVER   = 3,
    WINNING_STREAK_BTN_GOLD     = 4,
    WINNING_STREAK_BTN_DIAMOND  = 5,
    WINNING_STREAK_BTN_OPEN     = 6,
    WINNING_STREAK_BTN_AWARD    = 7,
    WINNING_STREAK_BTN_RULE     = 8,
    
	WinningStreakInfoRet        = "WinningStreakInfoRet",
	WinningStreakAwardRet       = "WinningStreakAwardRet",
	WinningStreakUpdateRedDot   = "WinningStreakUpdateRedDot",
    WinningStreakChargeCancel   = "WinningStreakCharegeCancel",

    Broadcast = "<c=255>【连胜挑战】<>挑战对局连胜，赢<c=65280>百万银两<>奖励，快来参加吧！详情可查看<c=65535>【活动】<>界面",

    PriceConfig_AN = {
        [1] = {
            hall = {
                price = 3000,
                exchangeid = 12154
            },
            game = {
                price = 3000,
                exchangeid = 12155
            },
            double = {
                price = 6,
                exchangeid = 12127
            }
        },
        [2] = {
            hall = {
                price = 10000,
                exchangeid = 12156
            },
            game = {
                price = 10000,
                exchangeid = 12157
            },
            double = {
                price = 6,
                exchangeid = 12130
            }
        },
        [3] = {
            hall = {
                price = 6,
                exchangeid = 12121
            }
        },
        [4] = {
            hall = {
                price = 30,
                exchangeid = 12124
            },
        }
    },
    PriceConfig_IOS = {
        [1] = {
            hall = {
                price = 3000,
                exchangeid = 12154
            },
            game = {
                price = 3000,
                exchangeid = 12155
            },
            double = {
                price = 6,
                exchangeid = 12128
            }
        },
        [2] = {
            hall = {
                price = 10000,
                exchangeid = 12156
            },
            game = {
                price = 10000,
                exchangeid = 12157
            },
            double = {
                price = 6,
                exchangeid = 12131
            }
        },
        [3] = {
            hall = {
                price = 6,
                exchangeid = 12122
            }
        },
        [4] = {
            hall = {
                price = 30,
                exchangeid = 12125
            }
        }
    },
    PriceConfig_SET = {
        [1] = {
            hall = {
                price = 3000,
                exchangeid = 12154
            },
            game = {
                price = 3000,
                exchangeid = 12155
            },
            double = {
                price = 12,
                exchangeid = 12129
            }
        },
        [2] = {
            hall = {
                price = 10000,
                exchangeid = 12156
            },
            game = {
                price = 10000,
                exchangeid = 12157
            },
            double = {
                price = 12,
                exchangeid = 12132
            }
        },
        [3] = {
            hall = {
                price = 6,
                exchangeid = 12123
            }
        },
        [4] = {
            hall = {
                price = 30,
                exchangeid = 12126
            }
        }
    },
}

return WinningStreakDef