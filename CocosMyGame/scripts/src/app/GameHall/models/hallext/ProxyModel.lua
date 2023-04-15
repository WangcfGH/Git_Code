
local BaseModel         = require('src.app.GameHall.models.BaseModel')
local ProxyModel        = class("ProxyModel", BaseModel)

local AssistModel       = mymodel('assist.AssistModel'):getInstance()
local UserModel         = mymodel('UserModel'):getInstance()
local PlayerModel       = mymodel('hallext.PlayerModel'):getInstance()
local AgentSystem       = mymodel('hallext.AgentSystemModel'):getInstance()

my.addInstance(ProxyModel)
--my.setmethods(ProxyModel, cc.load('coms').PropertyBinder)
my.setmethods(ProxyModel, cc.load('coms').WidgetEventBinder)

--[[
#define     GR_YQW_ALLOC_AGENT_ROOM    (GAME_REQ_BASE + 994)       // 游戏申请代开房号
#define     GR_YQW_ALLOC_AGENT_ROOM_OK (GAME_REQ_BASE + 995)       // 游戏申请代开房号回应
#define     GR_YQW_FREE_AGENT_ROOM     (GAME_REQ_BASE + 996)       // 游戏释放代开房号
#define     GR_YQW_FREE_AGENT_ROOM_OK  (GAME_REQ_BASE + 997)       // 游戏释放代开房号回应
#define     GR_QUERY_AGENT_ROOMINFO    (GAME_REQ_INDIVIDUAL + 4000)       // 查询代开信息
#define     GR_QUERY_AGENT_ROOMHISTORY (GAME_REQ_INDIVIDUAL + 4001)       // 查询代开历史
#define     GR_CONFIRM_AGENT_ROOMHISTORY (GAME_REQ_INDIVIDUAL + 4002)     // 确认某条代开历史记录
#define     GR_DELETE_AGENT_ROOMHISTORY (GAME_REQ_INDIVIDUAL + 4003)      // 删除某条代开历史记录
#define     GR_DELETE_ALL_AGENT_ROOMHISTORY (GAME_REQ_INDIVIDUAL + 4004)  // 删除所有已确认的包括不可见的代开历史记录

typedef struct _tagYQW_ALLOC_AGENT_ROOM{
    int nUserID;         // 开房者ID
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nRoomType;       // 微信 or qq
    int nTimeOut;        // 开房超时时间。  多少s 房间未开始自动解散
    int nRuleLen;        // 规则长度,结构体尾部携带
    TCHAR szBOC[MAX_HAPPYCOIN_BUSINESSORDER_LEN]; //订单号   透传数据
    int nReserved[32];
}YQW_ALLOC_AGENT_ROOM, *LPYQW_ALLOC_AGENT_ROOM; //YQW_ALLOC_AGENT_ROOM + rule

typedef struct _tagYQW_ALLOC_AGENT_ROOM_OK{
    int nRoomNum;         // 房号
    int nTime;            // 创建的时间
    TCHAR szBOC[MAX_HAPPYCOIN_BUSINESSORDER_LEN]; //订单号
    int nReserved[32];
}YQW_ALLOC_AGENT_ROOM_OK, *LPYQW_ALLOC_AGENT_ROOM_OK;

typedef struct _tagYQW_FREE_AGENT_ROOM{
	int nUserID;          // 开房者ID
	int nGameID;
	int nRoomNum;         // 房号
	TCHAR szBOC[MAX_HAPPYCOIN_BUSINESSORDER_LEN]; // 房间唯一标识   透传数据
	int nReserved[16];
}YQW_FREE_AGENT_ROOM, *LPYQW_FREE_AGENT_ROOM;

typedef struct _tagYQW_FREE_AGENT_ROOM_OK{
	int nUserID;          // 开房者ID
	int nGameID;
	int nRoomNum;         // 房号
	TCHAR szBOC[MAX_HAPPYCOIN_BUSINESSORDER_LEN]; // 房间唯一标识   透传数据
	int nErrCode;         // 错误码  0 表示成功
	int nReserved[8];
}YQW_FREE_AGENT_ROOM_OK, *LPYQW_FREE_AGENT_ROOM_OK;

typedef struct _tagYQW_QUERY_AGENT_ROOM {
	int nUserID;         // 开房者ID
	int nGameID;
	int nPageSize;       // 分页大小
	int nCurPage;        // 当前页码
	int nMaxSize;        // 最大请求数量，当为0时返回最新的数据
	int nUnConfirmCount; // 在最大请求数量下的未确认的条目总数
	int nUnBeginCount;   // 在最大请求数量下的未开始的条目总数
	int nPlayingCount;   // 在最大请求数量下的游戏中的条目总数
	int nSubID;			 // 子账号ID
    int nReserved[31];
}YQW_QUERY_AGENT_ROOM, *LPYQW_QUERY_AGENT_ROOM;

typedef struct _tagAgentRoomInfo
{
	int nUserID;                                                          // 开房者ID
	int nRoomNum;                                                         // 六位房号
	TCHAR szBOC[MAX_HAPPYCOIN_BUSINESSORDER_LEN];                         // 房间唯一标识
	int nRoomType;                                                        // 房间类型
	int nCreateTime;                                                      // 创建时间
	int nTimeOut;                                                         // 超时时间
	int nPayCount;                                                        // 扣欢乐点数
    // 状态分四种：可用房(0)、未确认(1)、已确认(2)、已删除(3)
	// 可用房                 在已开房间里
	// 未确认、已确认、已删除 在代开记录里
	int nState;                                                           // 状态
	int nBout;                                                            // 当前进行到第几局
	TCHAR szUtf8WechatName[MAX_YQW_CHAIR_COUNT][MAX_YQW_NICKNAME_LEN_EX]; // 昵称
	TCHAR szPortraitUrl[MAX_YQW_CHAIR_COUNT][MAX_YQW_PORTRAIT_LEN_EX];    // 头像
	int nRuleLen;                                                         // 本桌规则长度
	int nPayUserID;														  // 支付***的ID
	int nSubState;														  // 作为子账号的状态
    int nReserved[30];
}AGENTROOMINFO, *LPAGENTROOMINFO;
Response:
YQW_QUERY_AGENT_ROOM + nCount + nCount个(AGENTROOMINFO+ruleJson)

typedef struct _tagAgentRoomIdentify
{
	int nUserID;                                                          // 开房者ID
	int nGameID;
	int nRoomNum;                                                         // 六位房号
	TCHAR szBOC[MAX_HAPPYCOIN_BUSINESSORDER_LEN];                         // 房间唯一标识
	int nSubID;															  // 子账号ID
    int nReserved[31];
}AGENTROOMIDENTIFY, *LPAGENTROOMIDENTIFY;
Response:
ErrCode(int) + szBOC(TCHAR[MAX_HAPPYCOIN_BUSINESSORDER_LEN])
int 0 表示成功 1 表示失败
--]]

--[[
1、查询子账号接口：
#define GR_AGENT_QUERY_BIND (GAME_REQ_INDIVIDUAL + 4007) // 查询所有子账号

发送：
typedef struct _tagAgentBindIdentify
{
    int nGameID;
    int nUserID;
}AGENTBINDIDENTIFY, *LPAGENTBINDIDENTIFY;

返回：
AGENTBINDIDENTIFY + nCount + nCount*AGENTBINDUNIT

typedef struct _tagAgentBindUnit
{
    int nSubID;        // 子账号ID
    int nBindUnixTime; // 子账号绑定时间
}AGENTBINDUNIT, *LPAGENTBINDUNIT;

2、绑定接口
#define GR_AGENT_BIND_ACCOUNT (GAME_REQ_INDIVIDUAL + 4005) // 代理绑定子账号

发送：
typedef struct _tagAgentBind
{
    int nGameID;
    int nUserID;
    int nSubID;
}AGENTBIND, *LPAGENTBIND;

返回：
typedef struct _tagAgentBindResult
{
	int nGameID;
	int nUserID;
	int nSubID;
	int nBindUnixTime;
	int nErrCode;
}AGENTBINDRESULT, *LPAGENTBINDRESULT;

nErrCode取值：
#define YQW_AGENT_BIND_ERR_OK                0 // 绑定成功
#define YQW_AGENT_BIND_ERR_SOURCE_IS_SUB     1 // 源账号已经是子账号
#define YQW_AGENT_BIND_ERR_DEST_HAS_BIND     2 // 目标账号已被其他人绑定
#define YQW_AGENT_BIND_ERR_DEST_HAS_SUB      3 // 目标账号有子账号
#define YQW_AGENT_BIND_ERR_SOURCE_EQUAL_DEST 4 // 源账号 = 目标账号
#define YQW_AGENT_BIND_ERR_HAS_COUNTLIMIT    5 // 源账号的子账号已达上限
#define YQW_AGENT_BIND_ERR_PARM_ID           6 // 参数错误，账号ID错误

3、解绑接口
#define GR_AGENT_UNBIND_ACCOUNT (GAME_REQ_INDIVIDUAL + 4006) // 代理解绑绑定子账号

发送：
AGENTBIND

返回：
AGENTBIND + nErrCode

nErrCode取值：
0 成功 1 失败

4、查询父账号接口
#define		GR_AGENT_QUERY_PARENT			(GAME_REQ_INDIVIDUAL + 4008)	   // 查询父账号

发送：
typedef struct _tagAgentBindIdentify
{
    int nGameID;
    int nUserID;
}AGENTBINDIDENTIFY, *LPAGENTBINDIDENTIFY;

返回：
typedef struct _tagAgentBindParent
{
	int nGameID;
	int nUserID;
	int nParentID;		// 父账号ID
}AGENTBINDPARENT, *LPAGENTBINDPARENT;
--]]

local ProxyReq = {
    YQW_ALLOC_AGENT_ROOM = {
        lengthMap = {
            [3] = 16,
            [7] = 44,
            [8] = { maxlen = 32 },
            maxlen = 8
        },
        nameMap = {
            'nUserID',		    -- [1] ( int )
            'nGameID',	        -- [2] ( int )
            'szGameCode',	    -- [3] ( char )
            'nRoomType',	    -- [4] ( int )
            'nTimeOut',	        -- [5] ( int )
            'nRuleLen',         -- [6] ( int )
            'szBOC',            -- [7] ( char )
            'nReserved',        -- [8] ( int )
        },
        formatKey = '<i2Ai3Ai32',
        deformatKey = '<i2A16i3A44i32',
        maxsize = 208
    },
    YQW_ALLOC_AGENT_ROOM_OK = {
        lengthMap = {
            [3] = 44,
            [4] = { maxlen = 32 },
            maxlen = 4
        },
        nameMap = {
            'nRoomNum',		    -- [1] ( int ) 
            'nTime',            -- [2] ( int )
            'szBOC',            -- [3] ( char )
	        'nReserved',        -- [4] ( int )
        },
        formatKey = '<i2Ai32',
        deformatKey = '<i2A44i32',
        maxsize = 180
    },
    YQW_FREE_AGENT_ROOM = {
        lengthMap = {
			[4] = 44,
			[5] = { maxlen = 16 },
			maxlen = 5
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nRoomNum',		-- [3] ( int )
			'szBOC',		-- [4] ( char )
			'nReserved',	-- [5] ( int )
		},
		formatKey = '<i3Ai16',
		deformatKey = '<i3A44i16',
		maxsize = 120
    },
    YQW_FREE_AGENT_ROOM_OK = {
        lengthMap = {
			[4] = 44,
			[6] = { maxlen = 8 },
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nRoomNum',		-- [3] ( int )
			'szBOC',		-- [4] ( char )
			'nErrCode',		-- [5] ( int )
			'nReserved',	-- [6] ( int )
		},
		formatKey = '<i3Ai9',
		deformatKey = '<i3A44i9',
		maxsize = 92
    },
    YQW_QUERY_AGENT_ROOM = {
        lengthMap = {
            [10] = { maxlen = 31 },
            maxlen = 10
        },
        nameMap = {
            'nUserID',          -- [1] ( int )
            'nGameID',          -- [2] ( int )
            'nPageSize',        -- [3] ( int )
            'nCurPage',         -- [4] ( int )
            'nMaxSize',         -- [5] ( int )
            'nUnConfirmCount',  -- [6] ( int )
            'nUnBeginCount',    -- [7] ( int )
            'nPlayingCount',    -- [8] ( int )
            'nSubID',           -- [9] ( int )
            'nReserved',        -- [10] ( int )
        },
        formatKey = '<i40',
        deformatKey = '<i40',
        maxsize = 160
    },
    YQW_AGENT_ROOM_INFO = {
		lengthMap = {
	
			[3] = 44,		
			[10] = { maxlen = 128, maxwidth = 8, complexType = 'string_group' },								
			[11] = { maxlen = 260, maxwidth = 8, complexType = 'string_group' },
			[15] = { maxlen = 30 },
			maxlen = 15
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nRoomNum',		-- [2] ( int )
			'szBOC',		-- [3] ( char )
			'nRoomType',		-- [4] ( int )
			'nCreateTime',		-- [5] ( int )
			'nTimeOut',		-- [6] ( int )
			'nPayCount',		-- [7] ( int )
			'nState',		-- [8] ( int )
			'nBout',		-- [9] ( int )
			'szUtf8WechatName',		-- [10] ( char )
			'szPortraitUrl',		-- [11] ( char )
			'nRuleLen',		-- [12] ( int )
			'nPayUserID',		-- [13] ( int )
			'nSubState',		-- [14] ( int )
			'nReserved',		-- [15] ( int )
		},
		formatKey = '<i2Ai6A16i33',
		deformatKey = '<i2A44i6A128A128A128A128A128A128A128A128A260A260A260A260A260A260A260A260i33',
		maxsize = 3312
	},
    YQW_AGENT_ROOM_IDENTIFY = {
        lengthMap = {
			[4] = 44,
			[6] = { maxlen = 31 },
			maxlen = 6
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nGameID',		-- [2] ( int )
			'nRoomNum',		-- [3] ( int )
			'szBOC',		-- [4] ( char )
            'nSubID',       -- [5] ( int )
			'nReserved',	-- [6] ( int )
		},
		formatKey = '<i3Ai32',
		deformatKey = '<i3A44i32',
		maxsize = 184
    },
    YQW_AGENT_ROOM_IDENTIFY_OK = {
        lengthMap = {
			[2] = 44,
			maxlen = 2
		},
		nameMap = {
			'nErrCode',		-- [1] ( int )
			'szBOC',		-- [2] ( char )
		},
		formatKey = '<iA',
		deformatKey = '<iA44',
		maxsize = 48
    },
    YQW_DELETE_ALL_AGENT_ROOM_OK = {
        lengthMap = {
			maxlen = 4
		},
		nameMap = {
			'nErrCode',		-- [1] ( int )
            'nUserID',      -- [2] ( int )
			'nGameID',		-- [3] ( int )
            'nSubID',       -- [4] ( int )
		},
		formatKey = '<i4',
		deformatKey = '<i4',
		maxsize = 16
    },
    YQW_AGENT_BIND = {
        lengthMap = {
			maxlen = 3
		},
		nameMap = {
            'nGameID',      -- [1] ( int )
 			'nUserID',		-- [2] ( int )
			'nSubID',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
    },
    YQW_AGENT_BIND_OK = {
        lengthMap = {
			maxlen = 5
		},
		nameMap = {
            'nGameID',      -- [1] ( int )
 			'nUserID',		-- [2] ( int )
			'nSubID',		-- [3] ( int )
            'nBindUnixTime',-- [4] ( int )
			'nErrCode',		-- [5] ( int )
		},
		formatKey = '<i5',
		deformatKey = '<i5',
		maxsize = 20
    },
    YQW_AGENT_UNBIND_OK = {
        lengthMap = {
			maxlen = 4
		},
		nameMap = {
            'nGameID',      -- [1] ( int )
 			'nUserID',		-- [2] ( int )
			'nSubID',		-- [3] ( int )
			'nErrCode',		-- [4] ( int )
		},
		formatKey = '<i4',
		deformatKey = '<i4',
		maxsize = 16
    },
    YQW_QUERY_AGENT_BIND = {
        lengthMap = {
			maxlen = 2
		},
		nameMap = {
            'nGameID',      -- [1] ( int )
			'nUserID',		-- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
    },
    YQW_QUERY_AGENT_BIND_OK = {
        lengthMap = {
			maxlen = 3
		},
		nameMap = {
            'nGameID',      -- [1] ( int )
			'nUserID',		-- [2] ( int )
			'nCount',		-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
    },
    YQW_AGENT_BIND_UNIT = {
        lengthMap = {
			maxlen = 2
		},
		nameMap = {
            'nSubID',           -- [1] ( int )
			'nBindUnixTime',    -- [2] ( int )
		},
		formatKey = '<i2',
		deformatKey = '<i2',
		maxsize = 8
    },
    YQW_QUERY_AGENT_PARENT_OK = {
        lengthMap = {
			maxlen = 3
		},
		nameMap = {
            'nGameID',      -- [1] ( int )
			'nUserID',		-- [2] ( int )
			'nParentID',	-- [3] ( int )
		},
		formatKey = '<i3',
		deformatKey = '<i3',
		maxsize = 12
    },
}

local ProxyDef = {
    GR_YQW_ALLOC_AGENT_ROOM         = 50994, -- 游戏申请代开房号
    GR_YQW_ALLOC_AGENT_ROOM_OK      = 50995, -- 游戏申请代开房号回应
    GR_YQW_FREE_AGENT_ROOM          = 50996, -- 游戏释放代开房号
    GR_YQW_FREE_AGENT_ROOM_OK       = 50997, -- 游戏释放代开房号回应

    GR_QUERY_AGENT_ROOMINFO         = 404000,   -- 查询代开信息
    GR_QUERY_AGENT_ROOMHISTORY      = 404001,   -- 查询代开历史
    GR_CONFIRM_AGENT_ROOMHISTORY    = 404002,   -- 确认某条代开历史记录
    GR_DELETE_AGENT_ROOMHISTORY     = 404003,   -- 删除某条代开历史记录
    GR_DELETE_ALL_AGENT_ROOMHISTORY = 404004,   -- 删除所有已确认的包括不可见的代开历史记录
    
    GR_AGENT_BIND_ACCOUNT           = 404005,   -- 代理绑定子账号
    GR_AGENT_UNBIND_ACCOUNT         = 404006,   -- 代理解绑绑定子账号
    GR_AGENT_QUERY_BIND             = 404007,   -- 查询所有子账号
    GR_AGENT_QUERY_PARENT           = 404008,   -- 查询父账号
}

ProxyModel.EVENT_YQW_ALLOC_AGENT_ROOM       = "EVENT_YQW_ALLOC_AGENT_ROOM"
ProxyModel.EVENT_YQW_FREE_AGENT_ROOM        = "EVENT_YQW_FREE_AGENT_ROOM"
ProxyModel.EVENT_QUERY_AGENT_ROOM_INFO      = "EVENT_QUERY_AGENT_ROOM_INFO"
ProxyModel.EVENT_QUERY_AGENT_ROOM_HISTORY   = "EVENT_QUERY_AGENT_ROOM_HISTORY"
ProxyModel.EVENT_CONFIRM_AGENT_ROOM_HISTORY = "EVENT_CONFIRM_AGENT_ROOM_HISTORY"
ProxyModel.EVENT_DELETE_AGENT_ROOM_HISTORY  = "EVENT_DELETE_AGENT_ROOM_HISTORY"
ProxyModel.EVENT_DELETE_AGENT_ROOM_HISTORYS = "EVENT_DELETE_AGENT_ROOM_HISTORYS"
ProxyModel.EVENT_QUERY_AGENT_BIND           = "EVENT_QUERY_AGENT_BIND"
ProxyModel.EVENT_AGENT_BIND_ACCOUNT         = "EVENT_AGENT_BIND_ACCOUNT"
ProxyModel.EVENT_AGENT_UNBIND_ACCOUNT       = "EVENT_AGENT_UNBIND_ACCOUNT"
ProxyModel.EVENT_QUERY_AGENT_PARENT         = "EVENT_QUERY_AGENT_PARENT"

ProxyModel.YQW_AGENTROOM_STATE_USABLE       = 0     -- 可用的
ProxyModel.YQW_AGENTROOM_STATE_UNCONFIRM    = 1     -- 未确认
ProxyModel.YQW_AGENTROOM_STATE_CONFIRMED    = 2     -- 已确认
ProxyModel.YQW_AGENTROOM_STATE_DELETED      = 3     -- 已删除

-- Bind ErrorCode
ProxyModel.YQW_AGENT_BIND_ERR_OK                = 0 -- 绑定成功
ProxyModel.YQW_AGENT_BIND_ERR_SOURCE_IS_SUB     = 1 -- 源账号已经是子账号
ProxyModel.YQW_AGENT_BIND_ERR_DEST_HAS_BIND     = 2 -- 目标账号已被其他人绑定
ProxyModel.YQW_AGENT_BIND_ERR_DEST_HAS_SUB      = 3 -- 目标账号有子账号
ProxyModel.YQW_AGENT_BIND_ERR_SOURCE_EQUAL_DEST = 4 -- 源账号 = 目标账号
ProxyModel.YQW_AGENT_BIND_ERR_HAS_COUNTLIMIT    = 5 -- 源账号的子账号已达上限
ProxyModel.YQW_AGENT_BIND_ERR_PARM_ID           = 6 -- 参数错误，账号ID错误

function ProxyModel:onCreate()
    self._switchAction      = {}
    self._bindParentID      = 0

    self:initMembers()

    if self._init then self:_init() end
end

function ProxyModel:initMembers()
    self._typeRoomCount     = {}
    self._currentRooms      = {}
    self._historyRooms      = {}

    self._bindAccounts      = {}
    self._remarkNames       = {}
end

function ProxyModel:setBindParentID(userID)
    if not userID or 0 > userID then return end
    self._bindParentID = userID
    if cc.exports.isProxySupported() then
        AgentSystem:queryIsSubAgent(self._bindParentID)
    end
end

function ProxyModel:getBindParentID()
    return self._bindParentID
end

function ProxyModel:getCurrentRooms(userID)
    if not userID then return {} end
    return self._currentRooms[userID]
end

function ProxyModel:setCurrentRooms(userID, rooms)
    if not userID then return end
    self._currentRooms[userID] = rooms
end

function ProxyModel:getCurrentByBOC(userID, szBOC)
    local rooms = self:getCurrentRooms(userID)
    return self:getRoomInfoByBOC(rooms, szBOC)
end

function ProxyModel:insertCurrentRooms(userID, room)
    if not userID or not room then return end
    if not self._currentRooms[userID] then
        self._currentRooms[userID] = {}
    end
    table.insert(self._currentRooms[userID], 1, room)
end

function ProxyModel:removeCurrentRooms(userID, index)
    if not userID or not index then return end
    if not self._currentRooms[userID] then return end
    table.remove(self._currentRooms[userID], index)
end

function ProxyModel:getHistoryRooms(userID)
    if not userID then return {} end
    return self._historyRooms[userID]
end

function ProxyModel:setHistoryRooms(userID, rooms)
    if not userID then return end
    self._historyRooms[userID] = rooms
end

function ProxyModel:getHistoryByBOC(szBOC)
    for _i, _v in pairs(self._historyRooms) do
        local rooms = self:getHistoryRooms(_i)
        local info, index = self:getRoomInfoByBOC(rooms, szBOC)
        if info and index then return info, index end
    end
end

function ProxyModel:insertHistoryRooms(userID, room)
    if not userID or not room then return end
    if not self._historyRooms[userID] then
        self._historyRooms[userID] = {}
    end
    table.insert(self._historyRooms[userID], 1, room)
end

function ProxyModel:removeHistoryRooms(userID, index)
    if not userID or not index then return end
    if not self._historyRooms[userID] then return end
    table.remove(self._historyRooms[userID], index)
end

function ProxyModel:getTypeRoomCount(userID)
    if not self._typeRoomCount[userID] then
        self._typeRoomCount[userID] = {}
    end
    return self._typeRoomCount[userID]
end

function ProxyModel:removeTypeRoomCount(userID)
    if not userID or 0 >= userID then return end
    self._typeRoomCount[userID] = nil
end

function ProxyModel:setUnConfirmCount(userID, count)
    if not userID or 0 >= userID then return end
    if not count or 0 > count then return end
    self:getTypeRoomCount(userID).nUnconfirm = count
end

function ProxyModel:getUnConfirmCount(userID)
    if not userID or 0 >= userID then return 0 end
    return self:getTypeRoomCount(userID).nUnconfirm or 0
end

function ProxyModel:setUnBeginCount(userID, count)
    if not userID or 0 >= userID then return end
    if not count or 0 > count then return end
    self:getTypeRoomCount(userID).nUnbegin = count
end

function ProxyModel:getUnBeginCount(userID)
    if not userID or 0 >= userID then return 0 end
    return self:getTypeRoomCount(userID).nUnbegin or 0
end

function ProxyModel:setPlayingCount(userID, count)
    if not userID or 0 >= userID then return end
    if not count or 0 > count then return end
    self:getTypeRoomCount(userID).nPlaying = count
end

function ProxyModel:getPlayingCount(userID)
    if not userID or 0 >= userID then return 0 end
    return self:getTypeRoomCount(userID).nPlaying or 0
end

function ProxyModel:getBindAccounts()
    return self._bindAccounts
end

function ProxyModel:setBindAccounts(accounts)
    self._bindAccounts = accounts
end

function ProxyModel:insertBindAccounts(unit)
    if not unit.nSubID then return end
    if self:getAccountIndex(unit.nSubID) then return end
    table.insert(self._bindAccounts, 1, unit)
end

function ProxyModel:removeBindAccounts(subID)
    if not subID then return end
    local index = self:getAccountIndex(subID)
    if index then
        table.remove(self._bindAccounts, index)
    end
end

function ProxyModel:getRemarkNames()
    return self._remarkNames
end

function ProxyModel:setRemarkNames(names)
    if not names then return end
    self._remarkNames = names
end

function ProxyModel:addRemarkNames(subID, szName)
    if not subID or not szName then return end
    self._remarkNames[tostring(subID)] = szName
    self:saveRemarkNames()
end

function ProxyModel:removeRemarkNames(subID)
    if not subID then return end
    self._remarkNames[tostring(subID)] = nil
    self:saveRemarkNames()
end

function ProxyModel:isHasRemarkName(szName)
    if not szName or '' == szName then return end
    local remarkNames = self:getRemarkNames()
    for _i, _v in pairs(remarkNames) do
        if _v == szName then return true end
    end
end

function ProxyModel:getRoomInfoByBOC(rooms, szBOC)
    if not rooms or 'table' ~= type(rooms) then return end
    if not szBOC or '' == szBOC then return end
    for _i, _v in pairs(rooms) do
        if _v.szBOC == szBOC then
            return _v, _i
        end
    end
end

function ProxyModel:sortHistoryRooms(userID)
    if not userID then return end
    if not self._historyRooms[userID] then return end

    local szState = (UserModel.nUserID == userID) and 'nState' or 'nSubState'
    local comps = function(a, b)
        if a[szState] ~= b[szState] then
            return a[szState] < b[szState]
        elseif a.nCreateTime ~= b.nCreateTime then
            return a.nCreateTime > b.nCreateTime
        else
            return a.szBOC < b.szBOC
        end
    end
    table.sort(self._historyRooms[userID], comps)
end

function ProxyModel:setHistoryRoomState(userID, index, state)
    if not userID or not state then return end
    if not index or 0 >= index then return end
    if not self._historyRooms[userID] then return end

    if self._historyRooms[userID][index] then
        if UserModel.nUserID == userID then
            self._historyRooms[userID][index].nState = state
        else
            self._historyRooms[userID][index].nSubState = state
        end
    end
end

function ProxyModel:getAccountIndex(subID)
    if not subID then return end
    
    local bindAccounts = self:getBindAccounts()
    for _i, _v in pairs(bindAccounts) do
        if _v.nSubID == subID then return _i end
    end
end

function ProxyModel:sortBindAccounts()
    local comps = function(a, b)
        if a.nBindUnixTime ~= b.nBindUnixTime then
            return a.nBindUnixTime > b.nBindUnixTime
        else
            return a.nSubID > b.nSubID
        end
    end
    table.sort(self._bindAccounts, comps)
end

function ProxyModel:_init()
    -- response
    self._switchAction = {
        [ProxyDef.GR_YQW_ALLOC_AGENT_ROOM_OK]       = function(data)
            self:onAllocAgentRoomOK(data)
        end,
        [ProxyDef.GR_YQW_FREE_AGENT_ROOM_OK]        = function(data)
            self:onFreeAgentRoomOK(data)
        end,
        [ProxyDef.GR_QUERY_AGENT_ROOMINFO]          = function(data)
            self:onQueryAgentRoomInfoOK(data)
        end,
        [ProxyDef.GR_QUERY_AGENT_ROOMHISTORY]       = function(data)
            self:onQueryAgentRoomHistoryOK(data)
        end,
        [ProxyDef.GR_CONFIRM_AGENT_ROOMHISTORY]     = function(data)
            self:onConfirmAgentRoomHistoryOK(data)
        end,
        [ProxyDef.GR_DELETE_AGENT_ROOMHISTORY]      = function(data)
            self:onDeleteAgentRoomHistoryOK(data)
        end,
        [ProxyDef.GR_DELETE_ALL_AGENT_ROOMHISTORY]  = function(data)
            self:onDeleteAllAgentRoomHistoryOK(data)
        end,
        [ProxyDef.GR_AGENT_BIND_ACCOUNT]            = function(data)
            self:onAgentBindAccountOK(data)
        end,
        [ProxyDef.GR_AGENT_UNBIND_ACCOUNT]          = function(data)
            self:onAgentUnbindAccountOK(data)
        end,
        [ProxyDef.GR_AGENT_QUERY_BIND]              = function(data)
            self:onQueryAgentBindOK(data)
        end,
        [ProxyDef.GR_AGENT_QUERY_PARENT]            = function(data)
            self:onQueryAgentParentOK(data)
        end,
    }
    -- regist
    AssistModel:registCtrl(self, self.dealwithResponse)
end

function ProxyModel:getCacheFileName()
    local nUserID = UserModel.nUserID
    if not nUserID then return end
    return string.format("%d_RemarkNames.xml", UserModel.nUserID)
end

function ProxyModel:readRemarkNames()
    local nUserID = UserModel.nUserID
    if not nUserID then self._remarkNames = {} return end

    local fileName = self:getCacheFileName()
    if fileName and my.isCacheExist(fileName) then
        self:setRemarkNames(my.readCache(fileName))
    else
        self:setRemarkNames({})
    end
end

function ProxyModel:saveRemarkNames()
    local fileName = self:getCacheFileName()
    if fileName then
	    my.saveCache(fileName, self:getRemarkNames())
    end
end

function ProxyModel:onDestory()
    AssistModel:unRegistCtrl(self)
end

function ProxyModel:isResponseID(response)
    return nil ~= self._switchAction[response]
end

-- data response
function ProxyModel:dealwithResponse(dataMap)
    local response, data = unpack(dataMap.value)

    if response == cc.exports.UrSocket.UR_SOCKET_ERROR 
        or response == cc.exports.UrSocket.UR_SOCKET_GRACEFULLY_ERROR then
        printLog('ProxyModel', 'connect assistsvr error !!!')
    else
        self:onNotifyReceived(response, data)
    end
end

function ProxyModel:onNotifyReceived(response, data)
    if self._switchAction[response] then
        self._switchAction[response](data)
    else
        ProxyModel.super.onNotifyReceived(self, response, data)
    end
end

function ProxyModel:onAllocAgentRoomOK(data)
    if not data then return end

    local struct = ProxyReq["YQW_AGENT_ROOM_INFO"]
    local resp = cc.load('treepack').unpack(data, struct)
    if 0 < resp.nRoomNum then
        local ruleJson = string.sub(data, struct.maxsize + 1)
        if string.len(ruleJson) <= 0 then return end
        resp.tbGameRule = cc.load("json").json.decode(ruleJson)
        self:insertCurrentRooms(resp.nUserID, resp)
        self:setUnBeginCount(resp.nUserID, self:getUnBeginCount(resp.nUserID) + 1)
    else
        local errorData = string.sub(data, struct.maxsize + 1)
        local _, nErrCode = string.unpack(errorData, '<i')
        resp.nErrCode = nErrCode
    end
    self:dispatchEvent({name = self.EVENT_YQW_ALLOC_AGENT_ROOM, value = resp})
end

function ProxyModel:onFreeAgentRoomOK(data)
    if not data then return end

    local resp = cc.load('treepack').unpack(data, ProxyReq["YQW_FREE_AGENT_ROOM_OK"])
    if 0 == resp.nErrCode then -- 解散成功，房间移到历史中，***变为0
        local info, index = self:getCurrentByBOC(resp.nUserID, resp.szBOC)
        if info and index then
            self:removeCurrentRooms(resp.nUserID, index)
            self:setUnBeginCount(resp.nUserID, self:getUnBeginCount(resp.nUserID) - 1)
            info.nState = self.YQW_AGENTROOM_STATE_UNCONFIRM
            info.nSubState = self.YQW_AGENTROOM_STATE_UNCONFIRM
            self:insertHistoryRooms(resp.nUserID, info)
            self:setUnConfirmCount(resp.nUserID, self:getUnConfirmCount(resp.nUserID) + 1)
        end
        self:sortHistoryRooms(resp.nUserID)
        PlayerModel:update({'HappyCoin'}) -- 更新下***，可能会有返回
    end
    self:dispatchEvent({name = self.EVENT_YQW_FREE_AGENT_ROOM, value = resp})
end

function ProxyModel:parseAgentRoomInfo(data)
    if not data then return end

    local json = cc.load("json").json
    local struct = ProxyReq["YQW_QUERY_AGENT_ROOM"]
    local head, rooms = cc.load('treepack').unpack(data, struct), {}
    local info = string.sub(data, struct.maxsize + 1)
    local _, count = string.unpack(info, '<i')
    local struct, ruleLen = ProxyReq["YQW_AGENT_ROOM_INFO"], 4
    for i = 1, count do
        local maxsize = (1 == i) and 0 or struct.maxsize
        info = string.sub(info, maxsize + ruleLen + 1)
        local agentInfo = cc.load('treepack').unpack(info, struct)
        -- 处理规则，json转为table
        ruleLen = agentInfo.nRuleLen
        local startPos = struct.maxsize
        local ruleJson = string.sub(info, startPos + 1, startPos + ruleLen)
        if ruleJson and string.len(ruleJson) > 0 then
            agentInfo.tbGameRule = json.decode(ruleJson)
        
            table.insert( rooms, agentInfo )
        end
    end
    return head, rooms 
end

function ProxyModel:onQueryAgentRoomInfoOK(data)
    local head, rooms = self:parseAgentRoomInfo(data)
    if not head or not rooms then return end
    
    local resp = {nCount = #rooms, nUserID = (0 < head.nSubID) and head.nSubID or head.nUserID}
    self:setCurrentRooms(resp.nUserID, rooms)
    self:setUnBeginCount(resp.nUserID, head.nUnBeginCount)
    self:setPlayingCount(resp.nUserID, head.nPlayingCount)

    self:dispatchEvent({name = self.EVENT_QUERY_AGENT_ROOM_INFO, value = resp})
end

function ProxyModel:onQueryAgentRoomHistoryOK(data)
    local head, rooms = self:parseAgentRoomInfo(data)
    if not head or not rooms then return end

    local resp = {nCount = #rooms, nUserID = (0 < head.nSubID) and head.nSubID or head.nUserID}
    self:setHistoryRooms(resp.nUserID, rooms)
    self:sortHistoryRooms(resp.nUserID)
    self:setUnConfirmCount(resp.nUserID, head.nUnConfirmCount)

    self:dispatchEvent({name = self.EVENT_QUERY_AGENT_ROOM_HISTORY, value = resp})
end

function ProxyModel:onConfirmAgentRoomHistoryOK(data)
    if not data then return end

    local resp = cc.load('treepack').unpack(data, ProxyReq["YQW_AGENT_ROOM_IDENTIFY_OK"])
    if 0 == resp.nErrCode then
        local info, index = self:getHistoryByBOC(resp.szBOC)
        if info and index then
            self:setUnConfirmCount(info.nUserID, self:getUnConfirmCount(info.nUserID) - 1)
            self:setHistoryRoomState(info.nUserID, index, self.YQW_AGENTROOM_STATE_CONFIRMED)
        end
        self:sortHistoryRooms(info.nUserID)
        resp.nUserID = info.nUserID
    end
    self:dispatchEvent({name = self.EVENT_CONFIRM_AGENT_ROOM_HISTORY, value = resp})
end

function ProxyModel:onDeleteAgentRoomHistoryOK(data)
    if not data then return end

    local resp = cc.load('treepack').unpack(data, ProxyReq["YQW_AGENT_ROOM_IDENTIFY_OK"])
    if 0 == resp.nErrCode then
        local info, index = self:getHistoryByBOC(resp.szBOC)
        self:removeHistoryRooms(info.nUserID, index)
        resp.nUserID = info.nUserID
    end
    self:dispatchEvent({name = self.EVENT_DELETE_AGENT_ROOM_HISTORY, value = resp})
end

function ProxyModel:onDeleteAllAgentRoomHistoryOK(data)
    if not data then return end

    local resp = cc.load('treepack').unpack(data, ProxyReq["YQW_DELETE_ALL_AGENT_ROOM_OK"])
    if 0 == resp.nErrCode then
        local nUserID = (0 < resp.nSubID) and resp.nSubID or resp.nUserID
        local nowRooms, leftRooms = self:getHistoryRooms(nUserID) or {}, {}
        for _i, _v in pairs(nowRooms) do
            local nState = (UserModel.nUserID == nUserID) and _v.nState or _v.nSubState
            if ProxyModel.YQW_AGENTROOM_STATE_UNCONFIRM == nState then
                table.insert(leftRooms, _v)
            end
        end
        self:setHistoryRooms(nUserID, leftRooms)
        resp.nUserID = nUserID
    end
    self:dispatchEvent({name = self.EVENT_DELETE_AGENT_ROOM_HISTORYS, value = resp})
end

function ProxyModel:onAgentBindAccountOK(data)
    if not data then return end
    
    local resp = cc.load('treepack').unpack(data, ProxyReq["YQW_AGENT_BIND_OK"])
    if self.YQW_AGENT_BIND_ERR_OK == resp.nErrCode then
        self:insertBindAccounts({nSubID = resp.nSubID, nBindUnixTime = resp.nBindUnixTime})
        self:sortBindAccounts()
    else
        self:removeRemarkNames(resp.nSubID)
    end
    self:dispatchEvent({name = self.EVENT_AGENT_BIND_ACCOUNT, value = resp})
end

function ProxyModel:onAgentUnbindAccountOK(data)
    if not data then return end

    local resp = cc.load('treepack').unpack(data, ProxyReq["YQW_AGENT_UNBIND_OK"])
    if self.YQW_AGENT_BIND_ERR_OK == resp.nErrCode then
        self:removeBindAccounts(resp.nSubID)
        self:removeRemarkNames(resp.nSubID)
        self:removeTypeRoomCount(resp.nSubID)
    end
    self:dispatchEvent({name = self.EVENT_AGENT_UNBIND_ACCOUNT, value = resp})
end

function ProxyModel:onQueryAgentBindOK(data)
    if not data then return end

    local stHead    = ProxyReq["YQW_QUERY_AGENT_BIND_OK"]
    local resp      = cc.load('treepack').unpack(data, stHead)
    local stUnit    = ProxyReq["YQW_AGENT_BIND_UNIT"]
    local tbAccounts, maxsize = {}, stHead.maxsize
    for i = 1, resp.nCount do
        data = string.sub(data, maxsize + 1)
        local unit = cc.load('treepack').unpack(data, stUnit)
        table.insert(tbAccounts, unit)
        maxsize = stUnit.maxsize
    end
    self:setBindAccounts(tbAccounts)
    self:sortBindAccounts()
    self:dispatchEvent({name = self.EVENT_QUERY_AGENT_BIND, value = resp})
end

function ProxyModel:onQueryAgentParentOK(data)
    if not data then return end

    local resp = cc.load('treepack').unpack(data, ProxyReq["YQW_QUERY_AGENT_PARENT_OK"])
    self:setBindParentID(resp.nParentID)
    self:dispatchEvent({name = self.EVENT_QUERY_AGENT_PARENT, value = resp})
end

-- request interface
-- 创建接口
function ProxyModel:onAllocAgentRoom(roomID, ruleJson, yqwRoomType, cost)
    roomID = checknumber(roomID)
    if 0 >= roomID then printError("ProxyModel:onAllocAgentRoom, roomID is wrong !!!") return end
    if not ruleJson then printError("ProxyModel:onAllocAgentRoom, ruleJson is wrong !!!") return end

    local struct        = ProxyReq.YQW_ALLOC_AGENT_ROOM
    local data          = {
        nUserID         = UserModel.nUserID,
        nGameID         = tonumber(my.getGameID()),
        szGameCode      = tostring(my.getAbbrName()),
        nRoomType       = yqwRoomType or 0,
        nTimeOut        = cc.exports.getProxyTimeOutValue(),
        nRuleLen        = string.len(ruleJson),
    }

    local headData = cc.load('treepack').alignpack(data, struct)
    AssistModel:sendData(ProxyDef.GR_YQW_ALLOC_AGENT_ROOM, headData..tostring(ruleJson))
end
-- 查询当前接口
function ProxyModel:onQueryAgentRoomInfo(subid, pagesize)
    pagesize = checknumber(pagesize or 20)
    if 0 > pagesize then printError("ProxyModel:onQueryAgentRoomInfo, pagesize is wrong !!!") return end

    local data          = {            
        nUserID         = UserModel.nUserID,
        nGameID         = tonumber(my.getGameID()),
        nPageSize       = pagesize,
        nCurPage        = 0,
        nMaxSize        = 0,
        nSubID          = subid or 0,
    }
    AssistModel:sendRequest(ProxyDef.GR_QUERY_AGENT_ROOMINFO, ProxyReq.YQW_QUERY_AGENT_ROOM, data)
end
-- 查询历史接口
function ProxyModel:onQueryAgentRoomHistory(subid, pagesize)
    pagesize = checknumber(pagesize or 20)
    if 0 > pagesize then printError("ProxyModel:onQueryAgentRoomHistory, pagesize is wrong !!!") return end

    local data          = {            
        nUserID         = UserModel.nUserID,
        nGameID         = tonumber(my.getGameID()),
        nPageSize       = pagesize,
        nCurPage        = 0,
        nMaxSize        = 0,
        nSubID          = subid or 0,
    }
    AssistModel:sendRequest(ProxyDef.GR_QUERY_AGENT_ROOMHISTORY, ProxyReq.YQW_QUERY_AGENT_ROOM, data)
end
-- 解散接口
function ProxyModel:onFreeAgentRoom(roomNum, szBOC)
    roomNum = checknumber(roomNum)
    if 0 >= roomNum then printError("ProxyModel:onFreeAgentRoom, roomNum is wrong !!!") return end
    if not szBOC or '' == szBOC then printError("ProxyModel:onFreeAgentRoom, szBOC is wrong !!!") return end

    local data          = {
        nUserID         = UserModel.nUserID,
        nGameID         = tonumber(my.getGameID()),
        nRoomNum        = roomNum,
        szBOC           = szBOC,
    }
    AssistModel:sendRequest(ProxyDef.GR_YQW_FREE_AGENT_ROOM, ProxyReq.YQW_FREE_AGENT_ROOM, data)
end
-- 确认接口
function ProxyModel:onConfirmAgentRoomHistory(userid, roomNum, szBOC)
    roomNum = checknumber(roomNum)
    if 0 >= roomNum then printError("ProxyModel:onConfirmAgentRoomHistory, roomNum is wrong !!!") return end
    userid = checknumber(userid)
    if 0 >= userid then printError("ProxyModel:onConfirmAgentRoomHistory, userid is wrong !!!") return end
    if not szBOC or '' == szBOC then printError("ProxyModel:onConfirmAgentRoomHistory, szBOC is wrong !!!") return end
    
    local nSubID = (UserModel.nUserID == userid) and 0 or userid
    local data          = {
        nUserID         = UserModel.nUserID,
        nGameID         = tonumber(my.getGameID()),
        nRoomNum        = roomNum,
        szBOC           = szBOC,
        nSubID          = nSubID,
    }
    AssistModel:sendRequest(ProxyDef.GR_CONFIRM_AGENT_ROOMHISTORY, ProxyReq.YQW_AGENT_ROOM_IDENTIFY, data)
end
-- 删除接口
function ProxyModel:onDeleteAgentRoomHistory(userid, roomNum, szBOC, subid)
    roomNum = checknumber(roomNum)
    if 0 >= roomNum then printError("ProxyModel:onDeleteAgentRoomHistory, roomNum is wrong !!!") return end
    userid = checknumber(userid)
    if 0 >= userid then printError("ProxyModel:onDeleteAgentRoomHistory, userid is wrong !!!") return end
    if not szBOC or '' == szBOC then printError("ProxyModel:onDeleteAgentRoomHistory, szBOC is wrong !!!") return end
    
    local nSubID = (UserModel.nUserID == userid) and 0 or userid
    local data          = {
        nUserID         = UserModel.nUserID,
        nGameID         = tonumber(my.getGameID()),
        nRoomNum        = roomNum,
        szBOC           = szBOC,
        nSubID          = nSubID,
    }
    AssistModel:sendRequest(ProxyDef.GR_DELETE_AGENT_ROOMHISTORY, ProxyReq.YQW_AGENT_ROOM_IDENTIFY, data)
end
-- 全部删除接口
function ProxyModel:onDeleteAllAgentRoomHistory(userid)    
    userid = checknumber(userid)
    if 0 >= userid then printError("ProxyModel:onDeleteAllAgentRoomHistory, userid is wrong !!!") return end

    local nSubID = (UserModel.nUserID == userid) and 0 or userid
    local data          = {
        nUserID         = UserModel.nUserID,
        nGameID         = tonumber(my.getGameID()),
        nSubID          = nSubID,
    }
    AssistModel:sendRequest(ProxyDef.GR_DELETE_ALL_AGENT_ROOMHISTORY, ProxyReq.YQW_AGENT_ROOM_IDENTIFY, data)
end
-- 添加子账号接口
function ProxyModel:onAgentBindAccount(userID)    
    userID = checknumber(userID)
    if 0 >= userID then printError("ProxyModel:onAgentBindAccount, userID is wrong !!!") return end

    local data          = {
        nGameID         = tonumber(my.getGameID()),
        nUserID         = UserModel.nUserID,
        nSubID          = userID,
    }
    AssistModel:sendRequest(ProxyDef.GR_AGENT_BIND_ACCOUNT, ProxyReq.YQW_AGENT_BIND, data)
end
-- 删除子账号接口
function ProxyModel:onAgentUnbindAccount(userID)    
    userID = checknumber(userID)
    if 0 >= userID then printError("ProxyModel:onAgentBindAccount, userID is wrong !!!") return end

    local data          = {
        nGameID         = tonumber(my.getGameID()),
        nUserID         = UserModel.nUserID,
        nSubID          = userID,
    }
    AssistModel:sendRequest(ProxyDef.GR_AGENT_UNBIND_ACCOUNT, ProxyReq.YQW_AGENT_BIND, data)
end
-- 查询子账号接口
function ProxyModel:onQueryAgentBind()    
    local data          = {
        nGameID         = tonumber(my.getGameID()),
        nUserID         = UserModel.nUserID,
    }
    AssistModel:sendRequest(ProxyDef.GR_AGENT_QUERY_BIND, ProxyReq.YQW_QUERY_AGENT_BIND, data)
end
-- 查询父账号接口
function ProxyModel:onQueryAgentParent()    
    local data          = {
        nGameID         = tonumber(my.getGameID()),
        nUserID         = UserModel.nUserID,
    }
    AssistModel:sendRequest(ProxyDef.GR_AGENT_QUERY_PARENT, ProxyReq.YQW_QUERY_AGENT_BIND, data)
end

return ProxyModel