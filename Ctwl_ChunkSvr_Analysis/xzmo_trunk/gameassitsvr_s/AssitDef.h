#pragma once

#define		PRODUCT_LICENSE	 		_T("license.dat")
#define		PRODUCT_NAME			_T(GAME_CLIENT"AssitSvr")
#define		PRODUCT_VERSION			_T("1.00")
#define     STR_SERVICE_NAME		_T(GAME_CLIENT"AssitSvr")
#define     STR_DISPLAY_NAME		_T("ͬ����"GAME_APPNAME"��������")
#define     STR_DISPLAY_NAME_ENU	_T("TCY"GAME_CLIENT "Assit Service") 

#define     ASSITSVR_CLSNAME_EX     _T("TCY_ASSITSVR_CLSNAME")
#define     ASSITSVR_WNDNAME_EX     _T("TCY_ASSITSVR_WNDNAME")


/************************************************************************/
/*                                                                       
/************************************************************************/
enum{
	LOGON_NOUSERINFO=-1,      //û�д��û�
	LOGON_NOTOKEN=-2,	      //û�д�token
	LOGON_USERID_MISMATCH=-3, //userid��ƥ��
	LOGON_HARDID_MISMATCH=-4, //hardid��ƥ��
};		