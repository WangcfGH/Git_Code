local GoldSilverDefCopy = 
{
    GoldSilverInfoReceivedCopy = "GoldSilverInfoReceivedCopy",
    SynGoldSilverScoreCopy = "SynGoldSilverScoreCopy",
    SynGoldSilverBuyStateCopy = "SynGoldSilverBuyStateCopy",
    GoldSilverTakeRewardRetCopy = "GoldSilverTakeRewardRetCopy",

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

    GR_GOLDSILVER_SYN_INICONFIG	    = 410360, --同步金银杯ini配置
    GR_GOLDSILVER_SYN_REWARDCONFIG	= 410361, --同步金银杯奖励配置
    GR_GOLDSILVER_INFO_REQ	        = 410362, --金银杯信息请求
    GR_GOLDSILVER_INFO_RESP	        = 410363, --金银杯信息回应
    GR_GOLDSILVER_TAKEREWARD_REQ	= 410364, --金银杯领奖请求
    GR_GOLDSILVER_TAKEREWARD_RESP	= 410365, --金银杯领奖回应
    GR_GOLDSILVER_SYN_SCORE	        = 410367,
    GR_GOLDSILVER_PAY_REQ           = 410368,
    GR_GOLDSILVER_SYN_BUYSTATE      = 410369,


    GOLDSILVER_APPTYPE_AN_TCY = 1,
	GOLDSILVER_APPTYPE_AN_SINGLE = 2,
	GOLDSILVER_APPTYPE_AN_SET = 3,
	GOLDSILVER_APPTYPE_IOS_TCY = 4,
    GOLDSILVER_APPTYPE_IOS_SINGLE = 5,
    
    PriceConfig_AN = {
        [1] = {
            silver = {
                price = 12,
                exchangeid = 17651,
                value = 108000 --原价
            },
            gold = {
                price = 30,
                exchangeid = 17672,
                value = 330000 --原价
            }
        },
        [2] = {
            silver = {
                price = 30,
                exchangeid = 17652,
                value = 330000 --原价
            },
            gold = {
                price = 108,
                exchangeid = 17673,
                value = 1242000 --原价
            }
        },
        [3] = {
            silver = {
                price = 108,
                exchangeid = 17653,
                value = 1242000 --原价
            },
            gold = {
                price = 328,
                exchangeid = 17674,
                value = 3772000 --原价
            }
        },
        [4] = {
            silver = {
                price = 328,
                exchangeid = 17654,
                value = 3772000 --原价
            },
            gold = {
                price = 648,
                exchangeid = 17655,
                value = 7516800 --原价
            }
        }
    },
    PriceConfig_IOS = {
        [1] = {
            silver = {
                price = 12,
                exchangeid = 17656,
                value = 108000 --原价
            },
            gold = {
                price = 30,
                exchangeid = 17675,
                value = 330000 --原价
            }
        },
        [2] = {
            silver = {
                price = 30,
                exchangeid = 17657,
                value = 330000 --原价
            },
            gold = {
                price = 108,
                exchangeid = 17676,
                value = 1242000 --原价
            }
        },
        [3] = {
            silver = {
                price = 108,
                exchangeid = 17658,
                value = 1242000 --原价
            },
            gold = {
                price = 328,
                exchangeid = 17677,
                value = 3772000 --原价
            }
        },
        [4] = {
            silver = {
                price = 328,
                exchangeid = 17659,
                value = 3772000 --原价
            },
            gold = {
                price = 648,
                exchangeid = 17660,
                value = 7516800 --原价
            }
        }
    },
    PriceConfig_SET = {
        [1] = {
            silver = {
                price = 12,
                exchangeid = 17661,
                value = 48000 --原价
            },
            gold = {
                price = 30,
                exchangeid = 17678,
                value = 120000 --原价
            }
        },
        [2] = {
            silver = {
                price = 30,
                exchangeid = 17662,
                value = 120000 --原价
            },
            gold = {
                price = 108,
                exchangeid = 17679,
                value = 540000 --原价
            }
        },
        [3] = {
            silver = {
                price = 108,
                exchangeid = 17663,
                value = 540000 --原价
            },
            gold = {
                price = 328,
                exchangeid = 17680,
                value = 1640000 --原价
            }
        },
        [4] = {
            silver = {
                price = 328,
                exchangeid = 17664,
                value = 1640000 --原价
            },
            gold = {
                price = 648,
                exchangeid = 17665,
                value = 3240000 --原价
            }
        }
    }
} 

return GoldSilverDefCopy