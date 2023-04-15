#pragma once

#define		PRODUCT_LICENSE	 		_T("license.dat")
#define		PRODUCT_NAME			_T(GAME_CLIENT"AssitSvr")
#define		PRODUCT_VERSION			_T("1.00")
#define     STR_SERVICE_NAME		_T(GAME_CLIENT"AssitSvr")
#define     STR_DISPLAY_NAME		_T("同城游"GAME_APPNAME"辅助服务")
#define     STR_DISPLAY_NAME_ENU	_T("TCY"GAME_CLIENT "Assit Service") 

#define     ASSITSVR_CLSNAME_EX     _T("TCY_ASSITSVR_CLSNAME")
#define     ASSITSVR_WNDNAME_EX     _T("TCY_ASSITSVR_WNDNAME")


/************************************************************************/
/*                                                                       
/************************************************************************/
enum{
	LOGON_NOUSERINFO=-1,      //没有此用户
	LOGON_NOTOKEN=-2,	      //没有此token
	LOGON_USERID_MISMATCH=-3, //userid不匹配
	LOGON_HARDID_MISMATCH=-4, //hardid不匹配
};		