#pragma once

//////////////////////////////////////////////////////////////////////////
// req id from 200000 to 250000

// request (from game clients)
#define     GR_GAME_PULSE          	 (GAME_REQ_BASE_EX + 1020)      // 玩家客户端脉搏信号

//////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
//RoomSvr Common
#define     WM_RTG_RECONNECTSVR_EX          (WM_USER+999)
#define     WM_RTG_GETFINISHED_EX           (WM_USER+1000)
#define     WM_RTG_CLEARTABLE_EX            (WM_USER+1001)
#define     WM_RTG_HARDCODE_EX              (WM_USER+1002)
#define     WM_RTG_TOKENID_EX               (WM_USER+1003)
#define		WM_RTG_ROOMTABLECHAIR_EX		(WM_USER+1004)
#define     WM_RTG_EXPERIENCE_EX			(WM_USER+1005)
#define     WM_RTG_LEAVEROOM_EX             (WM_USER+1006)
#define		WM_RTG_ROOMSVRHWND_EX			(WM_USER+1009)
#define     WM_RTG_ROOMOPTIONS_EX           (WM_USER+1010)  
#define     WM_RTG_ROOMCONFIGS_EX           (WM_USER+1011)
#define     WM_RTG_ROOMMANAGES_EX           (WM_USER+1012)  
#define     WM_RTG_GAMEOPTIONS_EX           (WM_USER+1013)  
#define     WM_RTG_GAMEPARAM_EX             (WM_USER+1014)  
#define     WM_RTG_GAMEDATA_EX              (WM_USER+1015)  
#define     WM_RTG_MINPLAYSCORE_EX          (WM_USER+1025)  
#define     WM_RTG_MAXPLAYSCORE_EX          (WM_USER+1026)  
#define     WM_RTG_MINDEPOSIT_EX			(WM_USER+1027)  
#define     WM_RTG_MAXDEPOSIT_EX			(WM_USER+1028) 
#define     WM_RTG_STARTVALID_EX            (WM_USER+1030)  
#define     WM_RTG_STARTINVALID_EX          (WM_USER+1031)
#define     WM_RTG_STARTSOLOTABLE_EX		(WM_USER+1040)  
#define     WM_RTG_KICKOFFPLAYER_EX			(WM_USER+1050)
#define		WM_RTG_NEWTABLECHAIR_EX			(WM_USER+1201)
#define     WM_RTG_USERCLOTHING_EX			(WM_USER+1202)
#define		WM_RTG_BECOMEMEMBER_EX			(WM_USER+1203)

#define		WM_GTR_ENTERGAMEOK_EX			(WM_USER+2000)
#define		WM_GTR_VERIFYSTART_EX           (WM_USER+2001)
#define     WM_GTR_LEAVEGAMEOK_EX			(WM_USER+2002)
#define		WM_GTR_GAMESTARTUP_EX			(WM_USER+2003)
#define		WM_GTR_GAMEBOUTEND_EX			(WM_USER+2004)
#define     WM_GTR_ASKNEWTABLE_EX 		    (WM_USER+2005)
#define		WM_GTR_USERBOUTEND_EX			(WM_USER+2006)
#define		WM_GTR_CHANGETABLE_EX			(WM_USER+2007)
#define		WM_GTR_WELFAREDEPOSIT_EX		(WM_USER+2008)
#define     WM_GTR_CLOSESOLOTABLE           (WM_USER+2010)
#define		WM_GTR_ADD_SOCRE_EX				(WM_USER+2030)
#define		WM_GTR_MINUS_SOCRE_EX			(WM_USER+2031)
#define     WM_GTR_GAMESVRPULSE_EX          (WM_USER+2100)  
// RoomSvr End
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// Common 
#define		MAX_FILTERWORD_LEN		32			// 过滤词最大长度
#define		MAX_LEVELNAME_LEN_EX	16			// 级别名称长度
#define		MAX_HARDID_LEN_EX		32			// 硬件标识ID最大长度
#define		MAX_SERVERIP_LEN_EX		32			// 服务器IP最长长度(含NULL)
#define		CLIENT_TYPE_GAME_EX		4			// 游戏服务器

#define		RF_VERIFY_SCORE			0x00000001			// 从数据库校验积分结果
#define		RF_LOG_TO_DB			0x00000002			// 数据库记录游戏结果
#define		RF_VERIFY_DEPOSIT		0x00000004			// 从数据库校验银子结果
#define		RF_IGNORE_DIFFSUM		0x00000008			// 校验银子结果时忽略差值总和校验(水草,对局奖)-不支持此项FLAG

#define		RF_PRESAVE_DEPOSIT		0x00000100			// 预收一个用户
#define		RF_ENDSAVE_DEPOSIT		0x00000200			// 保存最终结果

// req id from 20000 to 30000 (compact for commreq.h of version 6.0)
#define		COMMON_REQ_BASE_EX		20000

#define     GR_RECONNECT_SVR		(COMMON_REQ_BASE_EX + 12) 

#define		GAME_REQ_BASE_EX		200000
#define		MOBILE_REQ_BASE_EX		300000		  //移动端请求起点
#define		GAME_REQ_INDIVIDUAL		400000

//游戏表扩展预定义请求，范围260000 ~ 270000 (该类型游戏的数据表按需扩展)
#define		EXT_GAME_REQ_BASE		(GAME_REQ_BASE_EX+60000)

#define		ROOM_REQ_BASE			50000         //使用与RoomSvr一样的区间
#define     IR_REQ_BASE             90000		  //与insidereq.h一致

#define		SOAP_FLAG_DEFAULTEX	    0x00000001

// Common End
//////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// CheckSvr Common
// request (to check server)
#define		GR_GET_PLAYERLEVELS_EX			(GAME_REQ_BASE_EX + 10)		// 获取级别信息
#define		GR_SEND_PULSE_EX				(GAME_REQ_BASE_EX + 20)		// 发送脉搏信号
#define		GR_REFRESH_RESULT_EX			(GAME_REQ_BASE_EX + 30)		// 更新游戏结果
#define		GR_LOOK_SAFE_DEPOSIT			(GAME_REQ_BASE_EX + 40)		// 查看保险箱银子
#define		GR_TAKE_SAFE_DEPOSIT			(GAME_REQ_BASE_EX + 41)		// 取保险箱银子(到游戏)
#define		GR_SAVE_SAFE_DEPOSIT			(GAME_REQ_BASE_EX + 42)		// 存到保险箱
#define		GR_TAKE_SAFE_RNDKEY    			(GAME_REQ_BASE_EX + 43)		// 获取随机码
#define		GR_LOOK_BACKDEPOSIT_INGAME		(GAME_REQ_BASE_EX + 44)		// 查看后备箱银子
#define		GR_TAKE_BACKDEPOSIT_INGAME		(GAME_REQ_BASE_EX + 45)		// 取后备箱银子(到游戏)
#define		GR_SAVE_BACKDEPOSIT_INGAME		(GAME_REQ_BASE_EX + 46)		// 存到后备箱
#define     GR_TAKE_DEPOSIT_BONUS			(GAME_REQ_BASE_EX + 50)     // 领银子奖励(到游戏)
#define		GR_ENTER_GAME_EX				(GAME_REQ_BASE_EX + 110)	// 用户进入游戏
#define		GR_VALIDATE_GAMESVR_EX			(GAME_REQ_BASE_EX + 200)	// 连接帐户服务
#define     GR_SEND_GAMERUNLOG_EX  			(GAME_REQ_BASE_EX + 210)	// 发送服务器运行日志

#define		GR_GET_FILTERWORD_EX			(ROOM_REQ_BASE + 22)		// 获取过滤关键字

// response (from check server)
#define		GR_ENTER_GAME_OK_EX				(GAME_REQ_BASE_EX + 500)	// 进入游戏成功（常规）
#define		GR_LOOK_SAFE_DEPOSIT_OK			(GAME_REQ_BASE_EX + 501)	// 查看保险箱银子
#define		GR_TAKE_SAFE_DEPOSIT_OK			(GAME_REQ_BASE_EX + 502)	// 取保险箱银子(到游戏)
#define		GR_SAVE_SAFE_DEPOSIT_OK			(GAME_REQ_BASE_EX + 503)	// 存保险箱银子(从游戏)
#define		GR_TAKE_SAFE_RNDKEY_OK			(GAME_REQ_BASE_EX + 504)	// 取随机码
#define		GR_LOOK_BACKDEPOSIT_INGAME_OK	(GAME_REQ_BASE_EX + 505)	// 查看后备箱银子
#define		GR_TAKE_BACKDEPOSIT_INGAME_OK	(GAME_REQ_BASE_EX + 506)	// 取后备箱银子(到游戏)
#define		GR_SAVE_BACKDEPOSIT_INGAME_OK	(GAME_REQ_BASE_EX + 507)	// 存后备箱银子(从游戏)
#define		GR_LOOK_GAME_DEPOSIT_BONUS_OK	(GAME_REQ_BASE_EX + 508)	// 查看银子奖励
#define		GR_TAKE_GAME_DEPOSIT_BONUS_OK	(GAME_REQ_BASE_EX + 509)	// 取银子奖励(到游戏)
#define		EGR_ENTER_GAME_OK				(EXT_GAME_REQ_BASE + 5000)	// 进入游戏成功

// notification  (from check server)
#define		GR_ENTER_ROOM_NOTIFY			(GAME_REQ_BASE_EX + 600)
#define		GR_RESULT_UNSAVED				(GAME_REQ_BASE_EX + 610)
#define     GR_TAKEBONUS_TOGAME_FAIL		(GAME_REQ_BASE_EX + 611)
#define     GR_ADD_FILER_WORD_EX			(IR_REQ_BASE + 110)		 //添加过滤关键字
#define     GR_DELETE_FILTER_WORD_EX		(IR_REQ_BASE + 209)	     //删除过滤关键字

// error response
//#define		GR_SERVICE_BUSY_EX			(ROOM_REQ_BASE + 998)		// 服务繁忙
#define		GR_SECUREPWD_EMPTY_EX			(ROOM_REQ_BASE + 10000)		// 保护密码为空
#define		GR_RANDOMKEY_ZERO_EX			(ROOM_REQ_BASE + 10001)		// 随机密码为空
#define		GR_SECUREPWD_EXIST_EX			(ROOM_REQ_BASE + 10002)		// 保护密码不为空
#define		GR_EMAIL_EMPTY_EX				(ROOM_REQ_BASE + 10003)		// email为空
#define		GR_IDCARD_MISMATCH_EX			(ROOM_REQ_BASE + 10004)		// 身份证号不匹配
#define		GR_DEPOSIT_NOTENOUGH_EX			(ROOM_REQ_BASE + 10005)		// 银子不够
#define		GR_EXPERIENCE_NOTENOUGH_EX		(ROOM_REQ_BASE + 10006)		// 经验值不够
#define		GR_STORAGE_NOTENOUGH_EX			(ROOM_REQ_BASE + 10007)		// 库存不够
#define		GR_LEVEL_NOTENOUGH_EX			(ROOM_REQ_BASE + 10008)		// 级别不够
#define		GR_ROOM_FULL_EX					(ROOM_REQ_BASE + 10009)		// 房间满了
#define		GR_NO_CHAIRS_EX					(ROOM_REQ_BASE + 10010)		// 位置满了
#define		GR_MUST_STANDUP_EX				(ROOM_REQ_BASE + 10011)		// 必须先站起来
#define		GR_IP_FORBIDDEN_EX				(ROOM_REQ_BASE + 10012)		// IP不符合要求
#define		GR_CONTINUE_REG_EX				(ROOM_REQ_BASE + 10013)		// 同一台机器不能连续注册
#define		GR_NORIGHTS_TO_ENTER_EX			(ROOM_REQ_BASE + 10014)		// 无权进入该房间
#define		GR_BREAKOFF_FORBIDDEN_EX		(ROOM_REQ_BASE + 10015)		// 断线率不符合要求
#define		GR_NETSPEED_FORBIDDEN_EX		(ROOM_REQ_BASE + 10016)		// 网速不符合要求
#define		GR_NO_THIS_FUNCTION_EX 			(ROOM_REQ_BASE + 10017)		// 该功能暂不支持
#define		GR_PLAYING_GAME_EX      		(ROOM_REQ_BASE + 10018)		// 游戏正在玩
#define		GR_SYSTEM_LOCKED_EX				(ROOM_REQ_BASE + 10019)		// 系统维护中
#define		GR_FORBID_WORD_EX       		(ROOM_REQ_BASE + 10020)		// 禁止的词（无法注册）
#define		GR_SIMPLE_PASSWORD_EX    		(ROOM_REQ_BASE + 10021)		// 密码太简单
#define		GR_FRIEND_FULL_EX      			(ROOM_REQ_BASE + 10022)		// 好友数超出
#define		GR_TOKENID_MISMATCH_EX			(ROOM_REQ_BASE + 10023)		// token不匹配
#define		GR_NOT_NEGASCORE_EX    			(ROOM_REQ_BASE + 10024)		// 不是负分
#define		GR_MINSCORE_FORBIDDEN_EX		(ROOM_REQ_BASE + 10025)		// 积分不符合要求
#define		GR_MINDEPOSIT_FORBIDDEN_EX		(ROOM_REQ_BASE + 10026)		// 银子不符合要求
#define		GR_HARDID_MISMATCH_EX			(ROOM_REQ_BASE + 10027)		// 硬件认证失败		//与之前使用的名字相同，现在加上EX
#define		GR_MUTEXHARD_FORBIDDEN_EX 		(ROOM_REQ_BASE + 10028)		// mutexHard
#define		GR_CONTINUE_PWDWRONG_EX			(ROOM_REQ_BASE + 10029)	    // 同一台机器不能连续密码错误
#define		GR_DEPOSIT_OVERFLOW_EX  		(ROOM_REQ_BASE + 10030)	    // 银子太多了
#define		GR_ERROR_INFOMATION_EX			(ROOM_REQ_BASE + 10031)	    // 返回错误信息
#define		GR_INVALID_WORD_EX				(ROOM_REQ_BASE + 10032)	    // 无效的名字
#define     GR_ROOM_FORBID_IP_EX			(ROOM_REQ_BASE + 10033)	    // 用户所在IP被禁止进入房间
#define     GR_SAME_SECUREPWD_EX			(ROOM_REQ_BASE + 10034)	    // 保护密码跟密码相同
#define     GR_NO_PERMISSION_EX				(ROOM_REQ_BASE + 10035)	    // 没有许可
#define		GR_SCORE_NOTENOUGH_EX			(ROOM_REQ_BASE + 10036)		// 分数不够
#define		GR_SCORE_OVERFLOW_EX   			(ROOM_REQ_BASE + 10037)	    // 分数太多了
#define     GR_PWDLEN_INVALID_EX			(ROOM_REQ_BASE + 10038)     // 密码长度无效
#define     GR_NEED_LOGON_EX				(ROOM_REQ_BASE + 10039)	    // 用户需要登陆先
#define     GR_ROOM_NOT_EXIST_EX			(ROOM_REQ_BASE + 10040)	    // 房间不存在
#define     GR_ROOM_NEED_DXXW_EX			(ROOM_REQ_BASE + 10041)     // 正在另一个房间里玩
#define     GR_NODEPOSIT_GAME_EX			(ROOM_REQ_BASE + 10042)     // 该游戏不能存放银子
#define     GR_NAMELEN_INVALID_EX			(ROOM_REQ_BASE + 10043)     // 用户名长度不合适
#define     GR_OLD_HALLBUILDNO_EX			(ROOM_REQ_BASE + 10044)     // 大厅buildno旧了，无法进入roomsvr
#define     GR_FORBID_NODIANXINIP_EX		(ROOM_REQ_BASE + 10045)	    // 非电信用户无法进入 。
#define     GR_FORBID_ENTERROOM_EX			(ROOM_REQ_BASE + 10046)
#define		GR_FORBID_SAMEHARDID_EX  		(ROOM_REQ_BASE + 10047)		// 禁止同网卡同房
#define		GR_FORBID_SAMEIPINROOM_EX		(ROOM_REQ_BASE + 10048)		// 禁止同IP同房
#define		GR_WAIT_SECONDS_EX				(ROOM_REQ_BASE + 10049)		// 等待几秒钟
#define     GR_ROOM_CLOSED_EX				(ROOM_REQ_BASE + 10050)		// 房间已关闭
#define     GR_ROOM_DIANXIN_EX				(ROOM_REQ_BASE + 10051)		// 电信专属房间 
#define     GR_SCREEN_NOTENOUGH_EX			(ROOM_REQ_BASE + 10052)		// 分辩率不够
#define     GR_WINSYSTEM_NOTENOUGH_EX		(ROOM_REQ_BASE + 10053)		// 操作系统不够
#define     GR_WINSYSTEM_NOTSUPPORT_EX		(ROOM_REQ_BASE + 10054)		// 操作系统不支持
#define		GR_RNDKEY_WRONG_EX				(ROOM_REQ_BASE + 10055)	    // 验证码不正确
#define     GR_FORBID_PROXY_EX				(ROOM_REQ_BASE + 10056)	    // 禁止代理服务 。
#define     GR_OLD_EXEMINORVER_EX			(ROOM_REQ_BASE + 10057)    // roomexe旧了，无法进入roomsvr
#define		GR_RNDKEY_TOOMUCHWRONG_EX		(ROOM_REQ_BASE + 10058)	    // 验证码不正确次数太多
#define		GR_TRUENAME_MISMATCH_EX			(ROOM_REQ_BASE + 10059)		// 真实姓名不匹配
#define     GR_INVALID_IDCARD_EX			(ROOM_REQ_BASE + 10060)		// 身份证号格式不对 
#define     GR_INVALID_TRUENAME_EX			(ROOM_REQ_BASE + 10061)		// 真实姓名格式不对 
#define     GR_HARDID_EMPTY_EX				(ROOM_REQ_BASE + 10062)		// 硬件为空 
#define     GR_IDCARD_EMPTY_EX				(ROOM_REQ_BASE + 10063)		// 身份证为空 
#define     GR_TRUENAME_EMPTY_EX			(ROOM_REQ_BASE + 10064)		// 真实姓名为空
#define     GR_OLD_EXEMAJORVER_EX			(ROOM_REQ_BASE + 10065)    //   
#define     GR_FORBID_PROXYIP_EX			(ROOM_REQ_BASE + 10066)    //   
#define     GR_PLAYSCORE_NOTENOUGH_EX		(ROOM_REQ_BASE + 10067)    //  
#define     GR_PLAYSCORE_OVERFLOW_EX		(ROOM_REQ_BASE + 10068)    //  
#define     GR_OPERATE_MUSTINWEB_EX			(ROOM_REQ_BASE + 10069)    //必须到网上操作  
#define     GR_BOUT_NOTENOUGH_EX			(ROOM_REQ_BASE + 10070)     //    
#define     GR_TIMECOST_NOTENOUGH_EX		(ROOM_REQ_BASE + 10071)     //
#define		GR_FORBID_SCOREDJ_EX   			(ROOM_REQ_BASE + 10072)		//游戏禁止积分道具
#define		GR_NEED_ENTERGAME_EX			(ROOM_REQ_BASE + 10073)	   //需要马上进入游戏
#define		GR_ROOM_NEEDSIGNUP_EX			(ROOM_REQ_BASE + 10074)	   //需要报名才能进入
#define		GR_MATCHSCORE_NOTENOUGH_EX		(ROOM_REQ_BASE + 10075)	   //
#define     GR_ALLOWED_OPERATION_EX			(ROOM_REQ_BASE + 10076)	   //操作被允许
#define     GR_OLD_EXEBUILDNO_EX   			(ROOM_REQ_BASE + 10077)	   //操作被允许
#define     GR_ROOM_NOT_OPENED_EX			(ROOM_REQ_BASE + 10078)		// 房间未开放
#define     GR_LOGON_NEED_RNDKEY_EX			(ROOM_REQ_BASE + 10079)		//登陆需要随机码
#define		GR_SAME_OLDNEWPWD_EX			(ROOM_REQ_BASE + 10080)		//新旧密码不能相同
#define     GR_LOGON_NEED_ACTIVATE_EX		(ROOM_REQ_BASE + 10081)		//帐号需要激活
#define		GR_FORBID_LOOKON_EX				(ROOM_REQ_BASE + 10082)	    //禁止旁观
#define     GR_FORBID_VIRTUAL_EX			(ROOM_REQ_BASE + 10083)    //禁止虚拟机进入房间
#define     GR_NEED_PLAYING_EX				(ROOM_REQ_BASE + 10084)     // 需要正在玩才能继续
#define     GR_NO_MOBILEUSER_EX				(ROOM_REQ_BASE + 10085)     // 不是手机用户
#define		GR_INPUTLIMIT_DAILY_EX			(ROOM_REQ_BASE + 10086)		// 划银每日限制
#define		GR_SERVICE_BUSY_EX				(ROOM_REQ_BASE + 10087)		//服务繁忙
#define		GR_REG_SUCCEEDED_EX				(ROOM_REQ_BASE + 10089)		// 注册成功
#define		GR_LOGON_SUCCEEDED_EX			(ROOM_REQ_BASE + 10090)		// 登录成功
#define		GR_LOGON_KICKOFF_EX      		(ROOM_REQ_BASE + 10091)		// 踢除玩家登录
#define		GR_KEEPDEPOSIT_LIMIT_EX   		(ROOM_REQ_BASE + 10092)		// 游戏银子转出限制
#define		GR_SECUREPWD_EXEMPT_EX			(ROOM_REQ_BASE + 10093)		// 免输入保护密码
#define		GR_INPUTLIMIT_MONTHLY_EX    	(ROOM_REQ_BASE + 10095)		// 划入每月限制
#define		GR_USER_FORBIDDEN_EX			(ROOM_REQ_BASE + 10101)		// 用户已被禁用

#define     RUCID_DATABASEERROR				1
#define     RUCID_INVALIDPARAM				2
#define     RUCID_OBJECTNOTFIND				3
#define     RUCID_SCOREDIFFER				10
#define     RUCID_DEPOSITDIFFER				11
#define     RUCID_FORBIDDENUSER				20

#define		FLAG_SUPPORT_KEEPDEPOSIT_EX		0x00000001	//客户端存银子请求如果带上这个标记，表示客户端支持了GR_KEEPDEPOSIT_LIMIT_EX
#define		FLAG_SUPPORT_MONTHLY_LIMIT_EX	0x00000002	//客户端取银子请求如果带上这个标记，表示客户端支持了GR_INPUTLIMIT_MONTHLY_EX

//CheckSvr End
////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
//AssitSvr 
typedef struct _tagGAME_PULSE
{
	int nUserID;
	DWORD dwAveDelay;							// 1分钟内的平均延迟
	DWORD dwMaxDelay;							// 单次通讯最大延迟
	int nReserved[1];
}GAME_PULSE,*LPGAME_PULSE;

typedef struct _tagRECONNECT_SVR{	
	int   nAdminID;
	TCHAR szHardID[MAX_HARDID_LEN_EX];	 
	TCHAR szReconnectIP[MAX_SERVERIP_LEN_EX];
	int   nReconnectPort;
   	int nReserved[4];
}RECONNECT_SVR, *LPRECONNECT_SVR; 

typedef struct _tagVALIDATE_GAMESVR{
	int nClientID;
	int nClientType;
	int nGameID;
	int nGamePort;
	DWORD dwIPAddr;
	DWORD dwFlags;
	int nReserved[5];
}VALIDATE_GAMESVR, *LPVALIDATE_GAMESVR;

typedef struct _tagErrorInfo{
	int		nUserID;
	int		nRoomID;
	int		nTableNO;
	int		nChairNO;
	TCHAR	szMsg[64];
	int		nReserved[8];
}ERROR_INFO, *LPERROR_INFO;

#define     MAX_SOAPSERVICE_COUNT       32  // soap线程使用参数最大个数
typedef struct _tagSOAP_SERVICE{
    int   nID;
    void* lpVoid;
    TCHAR szSoapWhat[32];
    TCHAR szSoapVersion[32];
    TCHAR szWsdlUrl[256];
    TCHAR szAuthUser[32];
    TCHAR szAuthPassword[32];
    int   nActID;
    int   nReserved[3];
}SOAP_SERVICE, *LPSOAP_SERVICE;

//AssitSvr End
//////////////////////////////////////////////////////////////////////////
