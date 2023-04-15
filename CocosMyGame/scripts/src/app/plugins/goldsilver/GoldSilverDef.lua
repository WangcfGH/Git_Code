local GoldSilverDef = 
{
    GoldSilverInfoReceived = "GoldSilverInfoReceived",
    SynGoldSilverScore = "SynGoldSilverScore",
    SynGoldSilverBuyState = "SynGoldSilverBuyState",
    GoldSilverTakeRewardRet = "GoldSilverTakeRewardRet",

    REWARD_TYPE_SILVER = 0,
    REWARD_TYPE_TICKET = 1,

    TAKETYPE_FREE = 0,
    TAKETYPE_SILVER = 1,
    TAKETYPE_GOLD = 2,
    TAKETYPE_ALL = 3,

    PAY_TYPE_SILVER = 0,
    PAY_TYPE_GOLD = 1,

	GOLDSILVER_SUCCESS = 0,
	GOLDSILVER_FAILED = 1,
	GOLDSILVER_NOTOPEN = 2,
	GOLDSILVER_PROHIBIT = 3,
	GOLDSILVER_DEVICELIMIT = 4,
	GOLDSILVER_DB_ERROR = 5,
    GOLDSILVER_SCORE_NOTENOUGH = 6,
    GOLDSILVER_SOAP_ERROR = 7,

    GR_GOLDSILVER_SYN_INICONFIG	    = 410350, --同步金银杯ini配置
    GR_GOLDSILVER_SYN_REWARDCONFIG	= 410351, --同步金银杯奖励配置
    GR_GOLDSILVER_INFO_REQ	        = 410352, --金银杯信息请求
    GR_GOLDSILVER_INFO_RESP	        = 410353, --金银杯信息回应
    GR_GOLDSILVER_TAKEREWARD_REQ	= 410354, --金银杯领奖请求
    GR_GOLDSILVER_TAKEREWARD_RESP	= 410355, --金银杯领奖回应
    GR_GOLDSILVER_SYN_SCORE	        = 410357,
    GR_GOLDSILVER_PAY_REQ           = 410358,
    GR_GOLDSILVER_SYN_BUYSTATE      = 410359,


    GOLDSILVER_APPTYPE_AN_TCY = 1,
	GOLDSILVER_APPTYPE_AN_SINGLE = 2,
	GOLDSILVER_APPTYPE_AN_SET = 3,
	GOLDSILVER_APPTYPE_IOS_TCY = 4,
    GOLDSILVER_APPTYPE_IOS_SINGLE = 5,
    
    PriceConfig_AN = {
        [1] = {
            silver = {
                price = 6,
                exchangeid = 11362,
                value = 45000 --原价
            },
            gold = {
                price = 30,
                exchangeid = 11863,
                value = 330000 --原价
            }
        },
        [2] = {
            silver = {
                price = 30,
                exchangeid = 11820,
                value = 330000 --原价
            },
            gold = {
                price = 98,
                exchangeid = 11864,
                value = 1130000 --原价
            }
        },
        [3] = {
            silver = {
                price = 98,
                exchangeid = 11821,
                value = 1130000 --原价
            },
            gold = {
                price = 198,
                exchangeid = 11865,
                value = 2300000 --原价
            }
        },
        [4] = {
            silver = {
                price = 198,
                exchangeid = 11822,
                value = 2300000 --原价
            },
            gold = {
                price = 328,
                exchangeid = 11823,
                value = 3750000 --原价
            }
        }
    },
    PriceConfig_IOS = {
        [1] = {
            silver = {
                price = 6,
                exchangeid = 11366,
                value = 45000 --原价
            },
            gold = {
                price = 30,
                exchangeid = 11860,
                value = 330000 --原价
            }
        },
        [2] = {
            silver = {
                price = 30,
                exchangeid = 11816,
                value = 330000 --原价
            },
            gold = {
                price = 108,
                exchangeid = 11861,
                value = 1242000 --原价
            }
        },
        [3] = {
            silver = {
                price = 108,
                exchangeid = 11817,
                value = 1242000 --原价
            },
            gold = {
                price = 198,
                exchangeid = 11862,
                value = 2277000 --原价
            }
        },
        [4] = {
            silver = {
                price = 198,
                exchangeid = 11818,
                value = 2277000 --原价
            },
            gold = {
                price = 488,
                exchangeid = 11967,
                value = 5612000 --原价
            }
        }
    },
    PriceConfig_SET = {
        [1] = {
            silver = {
                price = 6,
                exchangeid = 11362,
                value = 21000 --原价
            },
            gold = {
                price = 30,
                exchangeid = 11866,
                value = 120000 --原价
            }
        },
        [2] = {
            silver = {
                price = 30,
                exchangeid = 11824,
                value = 120000 --原价
            },
            gold = {
                price = 98,
                exchangeid = 11867,
                value = 490000 --原价
            }
        },
        [3] = {
            silver = {
                price = 98,
                exchangeid = 11825,
                value = 490000 --原价
            },
            gold = {
                price = 198,
                exchangeid = 11868,
                value = 990000 --原价
            }
        },
        [4] = {
            silver = {
                price = 198,
                exchangeid = 11826,
                value = 990000 --原价
            },
            gold = {
                price = 328,
                exchangeid = 11827,
                value = 1640000 --原价
            }
        }
    }
} 

return GoldSilverDef