local PeakRankDef = {
    GR_PEAK_RANK_MSG_BEGIN                  = 405600,
    GR_PEAK_RANK_QUERY_CONFIG               = 405601,   -- 获取巅峰榜配置数据
    GR_PEAK_RANK_QUERY_ITEMS_INFO           = 405602,   -- 获取巅峰榜单数据
    GR_PEAK_RANK_QUERY_TOTAL_VALUE          = 405603,   -- 获取巅峰榜单总奖励数据
    GR_PEAK_RANK_SEND_EMAIL_AWARD           = 405604,   -- 巅峰榜发放奖励
    GR_PEAK_RANK_SEND_EMAIL_AWARD_FAILED    = 405605,   -- 巅峰榜发放奖励失败
    GR_PEAK_RANK_END                        = 405650,   -- 幸运礼包消息结束标识


    RANK_TIME_TYPE = {
        DATE_RANK        = 1,   -- 日榜
        ROUND_RANK        = 2,  -- 期榜
    },

    PLAY_MODEL_TYPE = {
        CLASSIC_PLAY    = 1,    -- 经典玩法
        NO_WASH_PLAY    = 2,    -- 不洗牌玩法
    },

    STATISTICS_TYPE = {
        GAIN            = 1,    -- 盈利
        VICTORY         = 2,    -- 胜局
        GAME_MATCH      = 3,    -- 对局
        WINNING_STREAK  = 4,    -- 连胜
        PRAISE          = 5,    -- 点赞
    },

    LIST_TYPE = {
        CLASSIC_TOTAL   = 1,    -- 经典总榜
        CLASSIC_DATE    = 2,    -- 经典日榜
        NOWASH_TOTAL    = 3,    -- 不洗牌总榜
        NOWASH_DATE     = 4,    -- 不洗牌日榜
        NORMAL_TOTAL    = 5,    -- 总榜
        NORMAL_DATE     = 6,    -- 日榜
    },

    AWARD_GET_TYPE = {
        PERCENTAGE_TYPE = 1,    -- 百分比
        FIXED_TYPE      = 2,    -- 固定值
    },

    -- 客户端展示使用
    PeakRankRankType = {
        GainTotal       = 1,    -- 盈利榜
        GainOnece       = 2,    -- 胜银榜
        PlayBout        = 3,    -- 对局榜
        WinningStreak   = 4,    -- 连胜榜
        ThumbsUp        = 5,    -- 点赞榜
    },

    -- 客户端展示使用
    PeakRankDayType = {
        Total           = 1,    -- 总榜
        Today           = 2,    -- 今日榜
        YesterDay       = 3,    -- 昨日榜
    },

    -- 客户端展示使用
    PeakRankAreaType = {
        None            = 0,    -- 不区分
        NoShuffle       = 1,    -- 不洗牌
        Classic         = 2,    -- 经典
    },
}

return PeakRankDef