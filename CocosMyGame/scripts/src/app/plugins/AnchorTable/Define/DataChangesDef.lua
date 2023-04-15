if nil == cc or nil == cc.exports then
    return
end

-- 供关心用户数据变化的插件订阅
cc.exports.DataChangesDef = {
    EVENT_PLAYER_NEW                    = "room_data_changes_new_player_enter_or_leave",    -- 有玩家进出
    EVENT_PLAYER_CHAIRNO                = "room_data_changes_player_chairno_change",        -- 玩家椅子号变化
    EVENT_PLAYER_TABLENO                = "room_data_changes_player_tableno_change",        -- 玩家桌号变化
    EVENT_PLAYER_NETSPEED               = "room_data_changes_player_netspeed_update",       -- 玩家网速更新
    EVENT_PLAYER_STATUS                 = "room_data_changes_player_status_change",         -- 玩家状态变化
    EVENT_TABLE_FIRST_SEATED            = "room_data_changes_table_first_seated",           -- 桌子第一次被坐
    EVENT_TABLE_MINSCORE                = "room_data_changes_table_minscore_change",        -- 桌子设置最小积分
    EVENT_TABLE_MINDEPOSIT              = "room_data_changes_table_mindeposit_change",      -- 桌子设置最小银子
    EVENT_TABLE_MINWINBOUT              = "room_data_changes_table_minwinbout_change",      -- 桌子设置最小胜率
    EVENT_TABLE_PASSWORD                = "room_data_changes_table_password_change",        -- 桌子设置密码
    EVENT_TABLE_STATUS                  = "room_data_changes_table_status_change",          -- 桌子状态发生变化
    EVENT_TABLE_CHANGECHAIR1            = "room_data_changes_table_player_change1",         -- 桌子上壹号位玩家变化
    EVENT_TABLE_CHANGECHAIR2            = "room_data_changes_table_player_change2",         -- 桌子上贰号位玩家变化
    EVENT_TABLE_CHANGECHAIR3            = "room_data_changes_table_player_change3",         -- 桌子上叁号位玩家变化
    EVENT_TABLE_CHANGECHAIR4            = "room_data_changes_table_player_change4",         -- 桌子上肆号位玩家变化
    EVENT_TABLE_CHANGECHAIR5            = "room_data_changes_table_player_change5",         -- 桌子上伍号位玩家变化
    EVENT_TABLE_CHANGECHAIR6            = "room_data_changes_table_player_change6",         -- 桌子上陆号位玩家变化
    EVENT_TABLE_CHANGECHAIR7            = "room_data_changes_table_player_change7",         -- 桌子上柒号位玩家变化
    EVENT_TABLE_CHANGECHAIR8            = "room_data_changes_table_player_change8",         -- 桌子上捌号位玩家变化
    EVENT_TABLE_PLAYER_COUNT            = "room_data_changes_table_player_count_change",    -- 桌子上的玩家数发生变化
    EVENT_TABLE_LOOKER_ENTER1           = "room_data_changes_table_looker_enter1",          -- 桌子上壹号位旁观进入
    EVENT_TABLE_LOOKER_ENTER2           = "room_data_changes_table_looker_enter2",          -- 桌子上贰号位旁观进入
    EVENT_TABLE_LOOKER_ENTER3           = "room_data_changes_table_looker_enter3",          -- 桌子上叁号位旁观进入
    EVENT_TABLE_LOOKER_ENTER4           = "room_data_changes_table_looker_enter4",          -- 桌子上肆号位旁观进入
    EVENT_TABLE_LOOKER_ENTER5           = "room_data_changes_table_looker_enter5",          -- 桌子上伍号位旁观进入
    EVENT_TABLE_LOOKER_ENTER6           = "room_data_changes_table_looker_enter6",          -- 桌子上陆号位旁观进入
    EVENT_TABLE_LOOKER_ENTER7           = "room_data_changes_table_looker_enter7",          -- 桌子上柒号位旁观进入
    EVENT_TABLE_LOOKER_ENTER8           = "room_data_changes_table_looker_enter8",          -- 桌子上捌号位旁观进入
    EVENT_TABLE_LOOKER_ABORT1           = "room_data_changes_table_looker_abort1",          -- 桌子上壹号位旁观离开
    EVENT_TABLE_LOOKER_ABORT2           = "room_data_changes_table_looker_abort2",          -- 桌子上贰号位旁观离开
    EVENT_TABLE_LOOKER_ABORT3           = "room_data_changes_table_looker_abort3",          -- 桌子上叁号位旁观离开
    EVENT_TABLE_LOOKER_ABORT4           = "room_data_changes_table_looker_abort4",          -- 桌子上肆号位旁观离开
    EVENT_TABLE_LOOKER_ABORT5           = "room_data_changes_table_looker_abort5",          -- 桌子上伍号位旁观离开
    EVENT_TABLE_LOOKER_ABORT6           = "room_data_changes_table_looker_abort6",          -- 桌子上陆号位旁观离开
    EVENT_TABLE_LOOKER_ABORT7           = "room_data_changes_table_looker_abort7",          -- 桌子上柒号位旁观离开
    EVENT_TABLE_LOOKER_ABORT8           = "room_data_changes_table_looker_abort8",          -- 桌子上捌号位旁观离开
    EVENT_TABLE_VISITOR_COUNT           = "room_data_changes_table_visitor_count_change",   -- 桌子上的旁观数发生变化
    EVENT_ROOM_INFO_REFRESH             = "room_data_changes_room_info_refresh",            -- 房间信息刷新
    EVENT_TCYFRIEND_LIST_FRESH          = "room_data_changes_tcyfriend_list_fresh",         -- 好友列表全部刷新
    EVENT_TCYFRIEND_LIST_UPDATE         = "room_data_changes_tcyfriend_list_update",        -- 好友列表某项变化
    EVENT_TCYFRIEND_LIST_INSERT         = "room_data_changes_tcyfriend_list_insert",        -- 好友列表插入新项
    EVENT_TCYFRIEND_LIST_DEL            = "room_data_changes_tcyfriend_list_del",           -- 好友列表删除项
    EVENT_TCYFRIEND_APPLY_FRESH         = "room_data_changes_tcyfriend_apply_fresh",        -- 好友申请列表全部刷新
    EVENT_TCYFRIEND_APPLY_UPDATE        = "room_data_changes_tcyfriend_apply_update",       -- 好友申请列表某项变化
    EVENT_TCYFRIEND_APPLY_INSERT        = "room_data_changes_tcyfriend_apply_insert",       -- 好友申请列表插入新项
    EVENT_TCYFRIEND_APPLY_DEL           = "room_data_changes_tcyfriend_apply_del",          -- 好友申请列表有一条记录被删
    EVENT_TCYFRIEND_INVITEGAME          = "room_data_changes_tcyfriend_invite_game",        -- 好友邀请游戏
    -- ... 其他变化待补充

    -- joint bout 
    EVENT_JOINTBOUT_QUERY               = "room_data_changes_joint_bout_query_response",    -- 共同局数查询返回
    EVENT_JOINTBOUT_PROMOTE             = "room_data_changes_joint_bout_promote_response",  -- 共同局数推荐返回
    -- joint bout 

    EVENT_PLAYER_PORTRAIT               = "room_data_changes_player_portrait_change",       -- 玩家的自定义头像变化
};



return cc.exports.DataChangesDef