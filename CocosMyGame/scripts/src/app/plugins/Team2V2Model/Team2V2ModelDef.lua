local Team2V2ModelDef = 
{
    GR_TEAM_2V2_MODEL_QUERY_CONFIG						= (400000 + 4801),                              	-- {登录成功}查询配置
    GR_TEAM_2V2_MODEL_CREATE_TEAM						= (400000 + 4802),                                  -- {队长进入组队二级大厅}创建队伍
    GR_TEAM_2V2_MODEL_CANCEL_TEAM						= (400000 + 4803),                                  -- {预留}取消队伍
    GR_TEAM_2V2_MODEL_QUERY_TEAM						= (400000 + 4804),                                  -- {登录成功}查询队伍
    GR_TEAM_2V2_MODEL_JOIN_TEAM							= (400000 + 4805),                                  -- {被邀请人进入组队二级大厅}加入队伍
    GR_TEAM_2V2_MODEL_QUIT_TEAM							= (400000 + 4806),                                  -- {组队二级大厅退出}退出队伍
    GR_TEAM_2V2_MODEL_KICK_TEAM							= (400000 + 4807),                                  -- {队长踢人}踢出队伍
    GR_TEAM_2V2_MODEL_DO_READY							= (400000 + 4808),                                  -- {队友准备}队友准备
    GR_TEAM_2V2_MODEL_CANCEL_READY						= (400000 + 4809),                                  -- {队长/队友游戏中断返回大厅}队长/队友取消准备
    GR_TEAM_2V2_MODEL_CHANGE_ROOM						= (400000 + 4810),                                  -- {预留}队长切换房间
    GR_TEAM_2V2_MODEL_SYNCHRON_INFO						= (400000 + 4811),                                  -- {队友准备后银子变化}队友同步信息(携银变化)
    GR_TEAM_2V2_MODEL_START_MATCH						= (400000 + 4812),                                  -- {队长匹配}队长开始匹配
    GR_TEAM_2V2_MODEL_MATCH_FAIL                        = (400000 + 4813),                                  -- {队长匹配前校验队友银两不满足}队长匹配失败（同步队友）
    GR_TEAM_2V2_MODEL_SYNCHRON_REAL_TEAM				= (400000 + 4814),                                  -- {队长进房创完队伍}队长同步真实队伍信息
    GR_TEAM_2V2_MODEL_OVER_TIME_CANCEL_TEAM             = (400000 + 4815),                                  -- {队长等待队友加入队伍N分钟后}组队超时解散队伍（队长选择房间后多长时间后队友未加入真实队伍则解散队伍）

    GR_TEAM_2V2_MODEL_QUERY_CONFIG_RSP 	                = 'GR_TEAM_2V2_MODEL_QUERY_CONFIG_RSP',	            -- 查询组配置
    GR_TEAM_2V2_MODEL_CREATE_TEAM_RSP 	                = 'GR_TEAM_2V2_MODEL_CREATE_TEAM_RSP',	            -- 创建队伍
    GR_TEAM_2V2_MODEL_CANCEL_TEAM_RSP 	                = 'GR_TEAM_2V2_MODEL_CANCEL_TEAM_RSP',	            -- 取消队伍
    GR_TEAM_2V2_MODEL_QUERY_TEAM_RSP 	                = 'GR_TEAM_2V2_MODEL_QUERY_TEAM_RSP',	            -- 查询队伍
    GR_TEAM_2V2_MODEL_JOIN_TEAM_RSP 	                = 'GR_TEAM_2V2_MODEL_JOIN_TEAM_RSP',	            -- 加入队伍
    GR_TEAM_2V2_MODEL_QUIT_TEAM_RSP 	                = 'GR_TEAM_2V2_MODEL_QUIT_TEAM_RSP',	            -- 退出队伍
    GR_TEAM_2V2_MODEL_KICK_TEAM_RSP 	                = 'GR_TEAM_2V2_MODEL_KICK_TEAM_RSP',	            -- 提出队伍
    GR_TEAM_2V2_MODEL_DO_READY_RSP 	                    = 'GR_TEAM_2V2_MODEL_DO_READY_RSP',	                -- 队友准备
    GR_TEAM_2V2_MODEL_CANCEL_READY_RSP 	                = 'GR_TEAM_2V2_MODEL_CANCEL_READY_RSP',	            -- 队长/队友取消准备
    GR_TEAM_2V2_MODEL_CHANGE_ROOM_RSP 	                = 'GR_TEAM_2V2_MODEL_CHANGE_ROOM_RSP',	            -- 队长切换房间
    GR_TEAM_2V2_MODEL_SYNCHRON_INFO_RSP 	            = 'GR_TEAM_2V2_MODEL_SYNCHRON_INFO_RSP',	        -- 队友同步信息(携银变化)
    GR_TEAM_2V2_MODEL_START_MATCH_RSP 	                = 'GR_TEAM_2V2_MODEL_START_MATCH_RSP',	            -- 队长开始匹配
    GR_TEAM_2V2_MODEL_MATCH_FAIL_RSP                    = 'GR_TEAM_2V2_MODEL_MATCH_FAIL_RSP',	            -- 队长匹配失败（同步队友）
    GR_TEAM_2V2_MODEL_SYNCHRON_REAL_TEAM_RSP 	        = 'GR_TEAM_2V2_MODEL_SYNCHRON_REAL_TEAM_RSP',	    -- 队长同步真实队伍信息                    
	GR_TEAM_2V2_MODEL_OVER_TIME_CANCEL_TEAM_RSP         = 'GR_TEAM_2V2_MODEL_OVER_TIME_CANCEL_TEAM_RSP',    -- 组队超时解散队伍（队长选择房间后多长时间后队友未加入真实队伍则解散队伍）

    TEAM_PLAYER_NUM_ONE                                 = 1,                                                -- 1人房
    TEAM_PLAYER_NUM_TWO                                 = 2,                                                -- 2人房

    TEAM_PLAYER_READY_OK                                = 1,                                                -- 已准备
    TEAM_PLAYER_NOT_READY                               = 2,                                                -- 未准备

    -- 枚举类型
    TEAM_ROOM_LEVEL_TYPE = {
        NEW_COMER_ROOM  = 1,    -- 新手房
        JUNIOR_ROOM     = 2,    -- 初级房
        MIDDLE_ROOM     = 3,    -- 中级房
        SENIOR_ROOM     = 4,    -- 高级房
    },

    -- 组队房进游戏类型
    ENTER_GAME_TYPE = {
        EXPLORE         = 0,    -- 探测式
        SYSTEM_FIND     = 1,    -- 系统查找式
        FRIEND_FIND     = 2,    -- 好友查找式
        FOLLOW          = 3,    -- 跟随式
    },

    -- 队长/队友状态(准备/未准备)
    TEAM_PALYER_STATE = {
        READY_OK        = 1,    -- 已准备
        NOT_READY       = 2,    -- 未准备
    },

-- 创建队伍结果
    CREATE_TEAM_RESULT = {
        CREATE_NEW_TEAM = 1,    -- 创建新队伍
        IN_ONE_TEAM     = 2,    -- 在一支队伍中
    },

    -- 查询队伍结果
    QUERY_TEAM_RESULT = {
        FIND_TEAM       = 1,    -- 查找到队伍
        NOT_FIND_TEAM   = 2,    -- 未找到队伍
        QUERY_TEAM_NULL = 3,    -- 队伍为空
    },

    -- 加入队伍结果
    JOIN_TEAM_RESULT = {
        JOIN_NEW_TEAM           = 1,    -- 加入新队伍
        IN_OTHER_TEAM           = 2,    -- 本人在另一支队伍中
        TEAM_IS_NULL            = 3,    -- 待加入的队伍为空
        LEADER_IN_OTHER_TEAM    = 4,    -- 队长在另一支队伍中
        TEAM_INFO_IS_NULL       = 5,    -- 待加入的队伍信息为空
        TEAM_IS_ABNORMAL        = 6,    -- 待加入的队伍异常(队长信息为空等)
        TEAM_IS_FULL            = 7,    -- 待加入的队伍已满	
        BACK_TO_TEAM            = 8,    -- 回到队伍
    },

    -- 退出队伍结果
    QUIT_TEAM_RESULT = {
        QUIT_TEAM_OK    = 1,    -- 成功退出队伍
        NOT_IN_TEAM     = 2,    -- 不在队伍中
        QUIT_TEAM_NULL  = 3,-- 待退出的队伍为空
    },

    -- 踢出队伍结果
    KICK_TEAM_RESULT = {
        KICK_TEAM_OK            = 1,    -- 成功踢出队伍
        KICK_TEAM_NOT_EXIST     = 2,    -- 队伍不存在
        KICK_TEAM_NULL          = 3,    -- 队伍为空	
        KICK_PLAYER_NO_LEADER   = 4,    -- 踢人者不是队长
        TEAM_NO_KICKED          = 5,    -- 队伍没有被踢者
    },

    -- 队友准备结果
    DO_READY_RESULT = {
        READY_TEAM_OK           = 1,    -- 准备成功
        READY_TEAM_NOT_EXIST    = 2,    -- 队伍不存在
        READY_TEAM_NULL         = 3,    -- 队伍为空	
        READY_OK_AGAIN          = 4,    -- 已准备
    },

    -- 队友取消准备结果
    DO_CANCEL_READY_RESULT = {
        CANCEL_READY_TEAM_OK        = 1,    -- 取消准备成功
        CANCEL_READY_TEAM_NOT_EXIST = 2,    -- 队伍不存在
        CANCEL_READY_TEAM_NULL      = 3,    -- 队伍为空	
        CANCEL_READY_AGAIN          = 4,    -- 非准备
    },

    -- 同步信息(携银)成功
    SYNCHRON_INFO_RESULT = {
        SYNCHRON_INFO_OK            = 1,    -- 同步信息成功
        SYNCHRON_TEAM_NOT_EXIST     = 2,    -- 队伍不存在
        SYNCHRON_TEAM_NULL          = 3,    -- 队伍为空	
    },

    -- 队长开始匹配（同步队友）结果
    START_MATCH_RESULT = {
        CAN_START_MATCH         = 1,    -- 可以开始匹配
        MATCH_TEAM_NOT_EXIST    = 2,    -- 队伍不存在
        MATCH_TEAM_NULL         = 3,    -- 队伍为空	
        PLAYER_STATE_NO_READY   = 4,    -- 有人未准备
        IS_NOT_LEADER           = 5,    -- 非队长
    },

    -- 队长匹配失败（同步队友）结果
    MATCH_FAIL_RESULT = {
        MATCH_FAIL_NEED_SYNCHRON    = 1,    -- 队长匹配失败需要同步
        MATCH_FAIL_TEAM_NOT_EXIST   = 2,    -- 队伍不存在
        MATCH_FAIL_TEAM_NULL        = 3,    -- 队伍为空	
    },

    -- 同步真实队伍信息结果
    SYNCHRON_REAL_TEAM_INFO_RESULT = {
        SYNCHRON_REAL_TEAM_INFO_OK      = 1,    -- 同步信息成功
        SYNCHRON_REAL_TEAM_NOT_EXIST    = 2,    -- 队伍不存在
        SYNCHRON_REAL_TEAM_NULL         = 3,    -- 队伍为空	
    },

    -- 开始匹配失败原因(队长同步队友)
    MATCH_FAIL_REASON = {
        MATCH_FAIL_MATE_NOT_READY               = 1,    -- 队友未准备
        MATCH_FAIL_MATE_DEPOSIT_NOT_ENOUGH      = 2,    -- 队友携银不足
        MATCH_FAIL_MATE_DEPOSIT_TOO_HIGH        = 3,    -- 队友携银太多
    },

}

return Team2V2ModelDef