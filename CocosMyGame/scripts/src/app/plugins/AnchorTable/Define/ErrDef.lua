--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
if nil == cc or nil == cc.exports then
    return
end

cc.exports.ErrDef = {
    Common={
        UR_OBJECT_NOT_EXIST     = 1001,                   -- 对象不存在
        UR_OBJECT_EXIST         = 1001,                   -- 对象已存在
        UR_PASSWORD_WRONG       = 1020,                   -- 密码错误
        UR_OPERATE_FAILED       = 10100,                  -- 操作失败
        GR_NO_CHAIRS            = 60010,                  -- 没有位置了
        GR_FORBID_LOOKON        = 60082,                  -- 禁止旁观
        GR_MINWINRATE_FORBIDDEN = 60213,                 -- 胜率不达标
        GR_MINSCORE_FORBIDDEN   = 60025,                  -- 积分不达标
        GR_MINDEPOSIT_FORBIDDEN = 60026,                  -- 银子不达标
    },
    TcyFriend={
        ERR_IN_BLACKLIST     = 2010117,                   -- 对方是你的黑名单成员
        ERR_MARK_TOOLONG     = 2010116,                   -- 备注信息过长
        ERR_HUANXIN_SEND     = 2010115,                   -- 发送环信消息失败
        ERR_INVITE_STATE     = 2010114,                   -- 邀请操作状态不正确
        ERR_FRIEND_FULL      = 2010113,                   -- 对方好友数量已满
        ERR_AREADY_DEAL      = 2010112,                   -- 您已经处理过这个请求
        ERR_ADD_USER         = 2010111,                   -- 添加用户错误
        ERR_USER_UNEXIST     = 2010110,                   -- 该用户不存在
        ERR_AREADY_FRIEND    = 2010109,                   -- 接受好友申请时，对方已经是你好友了
        ERR_OPE_CACHE        = 2010108,                   -- 操作缓存错误
        ERR_FRIEND_NOT_FOUND = 2010107,                   -- 删除好友时，该好友不存在
        ERR_FRIEND_EXCEPTION = 2010106,                   -- 接受好友申请时，捕获异常
        ERR_CALL_HUANXIN     = 2010105,                   -- 调用环信接口错误
        ERR_OPE_DATABASE     = 2010104,                   -- 操作数据库错误
        ERR_REQUEST_EXPIRED  = 2010103,                   -- 接受好友申请时，对方根本没有发送过好友申请或发送的好友申请太久远已失效
        ERR_SELF_FRIEND_FULL = 2010102,                   -- 您的好友数量已满
        ERR_ADD_SELF         = 2010101,                   -- 您不能添加自己
        ERR_AUTH_INVALID     = 10010,                     -- 认证数据不合法
        ERR_TOKEN_EXPIRED    = 10009,                     -- 授权令牌已过期
        ERR_TOKEN_INVALID    = 10008,                     -- 无效的授权令牌
        ERR_TOKEN_ILLEGAL    = 10007,                     -- 不合法的授权令牌
        ERR_USERID_ILLEGAL   = 10006,                     -- 不合法的用户ID
        ERR_APPID_ILLEGAL    = 10005,                     -- 不合法的应用ID
        ERR_INVALID_REQUEST  = 10004,                     -- 无效的请求参数
        ERR_NOT_ENOUGH_AUTH  = 10003,                     -- 没有足够权限
        ERR_IP_LIMIT         = 10002,                     -- IP被限制
        ERR_SERVICE_PAUSE    = 10001,                     -- 服务暂停
        ERR_SERVICE_EXCEPT   = 10000,                     -- 服务异常
    }
}

return cc.exports.ErrDef
--endregion
