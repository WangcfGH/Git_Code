
local function CreatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i - 1
    end 
    return enumtbl 
end 

local Plugin_type = {
    "kPluginAds",
    "kPluginAnalytics",
    "kPluginIAP",
    "kPluginShare",
    "kPluginUser",
    "kPluginSocial",
    "kPluginPush",
    "kPluginUploader",
    "kPluginImageLoader",
    "kPluginTcyFriend",
    "kPluginLBS",
    "kPluginSocialGameChat"
}
cc.exports.Plugin_type = CreatEnumTable(Plugin_type, 1)

-- for ads
local AdsResultCode = {
    "kAdsReceived",           	--/**< enum the callback: the ad is received is at center. */
    "kAdsShown",                  --/**< enum the callback: the advertisement dismissed. */
    "kAdsDismissed",             --/**< enum the callback: the advertisement dismissed. */
    "kPointsSpendSucceed",       --/**< enum the callback: the points spend succeed. */
    "kPointsSpendFailed",        --/**< enum the callback: the points spend failed. */
    "kNetworkError",              --/**< enum the callback of Network error at center. */
    "kUnknownError",              --/**< enum the callback of Unknown error. */
    "kOfferWallOnPointsChanged",   --/**< enum the callback of Changing the point of offerwall. */
};	--ads result code
cc.exports.AdsResultCode = CreatEnumTable(AdsResultCode, 0)

local AdsPos = {
    "kPosCenter",			--/**< enum the toolbar is at center. */
    "kPosTop",				--/**< enum the toolbar is at top. */
    "kPosTopLeft",			--/**< enum the toolbar is at topleft. */
    "kPosTopRight",			--/**< enum the toolbar is at topright. */
    "kPosBottom",				--/**< enum the toolbar is at bottom. */
    "kPosBottomLeft",			--/**< enum the toolbar is at bottomleft. */
    "kPosBottomRight" 		--/**< enum the toolbar is at bottomright. */
};	--ads pos
cc.exports.AdsPos = CreatEnumTable(AdsPos, 0)

local AdsType = {
	"AD_TYPE_BANNER",		--/**< enum value is banner ads . */
	"AD_TYPE_FULLSCREEN",	--/**< enum value is fullscreen ads . */
	"AD_TYPE_MOREAPP",		--/**< enum value is moreapp ads . */
	"AD_TYPE_OFFERWALL"	--/**< enum value is offerwall ads . */
};	--ads type
cc.exports.AdsType = CreatEnumTable(AdsType, 0)

local AdSdkAdType = {
	"ADSDK_TYPE_BANNER",		--/**< enum value is adsdk banner ads . */
	"ADSDK_TYPE_INSERTSCREEN",	--/**< enum value is adsdk insertscreen ads . */
};	--adsdk ad type
cc.exports.AdSdkAdType = CreatEnumTable(AdSdkAdType, 1)

local AdSdkRetType = {
	"ADSDK_RET_LOADAD_SUCCESS",		--/**< enum the callback: load ad success */
	"ADSDK_RET_LOADAD_FAIL",		--/**< enum the callback: load ad fail */
	"ADSDK_RET_SHOWAD_SUCCESS",		--/**< enum the callback: show ad success */
	"ADSDK_RET_AD_CLICKED",			--/**< enum the callback: ad is clicked and will jump to detail page */
	"ADSDK_RET_AD_CLOSED",			--/**< enum the callback: user closed ad */
};	--adsdk ret type
cc.exports.AdSdkRetType = CreatEnumTable(AdSdkRetType, 1)

--for pay result code
local PayResultCode = {
    "kPaySuccess",		--/**< enum value is callback of succeeding in paying . */
    "kPayFail",			--/**< enum value is callback of failing to pay . */
    "kPayCancel",		--/**< enum value is callback of canceling to pay . */
    "kPayTimeOut",	--/**< enum value is callback of network error . */
    "kPayProductionInforIncomplete",	--/**< enum value is callback of incompleting info . */
    "kRechargeDirectlySuccess",
    "kRechargeDirectlyFailed",
    "kRechargeDirectlyDuration",
    "kRechargeDirectlyException",
    "kRechargeDirectlyCanceled",
};
cc.exports.PayResultCode = CreatEnumTable(PayResultCode, 0)

local RechargeDirectlyType = {
	"kRechargeDirectlyAlipay",
	"kRechargeDirectlyWxPay"
};
cc.exports.RechargeDirectlyType = CreatEnumTable(RechargeDirectlyType, 0)

-- for push action result code
local PushActionResultCode = {
	"kPushReceiveMessage"	--/**value is callback of Receiving Message . */
};
cc.exports.PushActionResultCode = CreatEnumTable(PushActionResultCode, 0)

-- for upload action result code
local UploadActionResultCode = {
	"kUploadSuccess",	--/**value is callback of succeeding in upload . */
	"kUploadFailed"  	--/**value is callback of failing in upload . */
};
cc.exports.UploadActionResultCode = CreatEnumTable(UploadActionResultCode, 1)

-- for imageload action result code
local ImageLoadActionResultCode = {
	"kImageLoadOnlineSuccess",	--/**value is callback of succeeding in imageload . */
	"kImageLoadOnlineFailed",	    --/**value is callback of failing in imageload . */
	"kImageLoadOnlineCancel",	    --/**value is callback of canceling in imageload . */
	"kImageLoadGetLocalSuccess",
	"kImageLoadGetLocalFailed"
};
cc.exports.ImageLoadActionResultCode = CreatEnumTable(ImageLoadActionResultCode, 0)

-- for tcyfriend action result code
local TcyFriendActionResultCode = {
	"kFriendGetSelfPortraitSuccess",	--/**value is callback of succeeding in tcyfriend . */
	"kFriendGetSelfPortraitFailed",	    --/**value is callback of failing in tcyfriend . */
	"kFriendGetSelfPortraitDuration",	    --/**value is callback of canceling in tcyfriend . */
	"kFriendGetSelfPortraitException",
	"kFriendGetPortraitByIDsSuccess",	--/**value is callback of succeeding in tcyfriend . */
	"kFriendGetPortraitByIDsFailed",	    --/**value is callback of failing in tcyfriend . */
	"kFriendGetPortraitByIDsDuration",	    --/**value is callback of canceling in tcyfriend . */
	"kFriendGetPortraitByIDsException",
    "kFriendSNSLoginSucceed",
    "kFriendSNSLoginFailed",
    "kFriendSNSLoginLoadConversationsSucceed",
    "kFriendSNSConnected",
    "kFriendSNSDisconnected",
    "kFriendSNSNewMessage",
    "kFriendSNSDeletebyFriend",
    "kFriendSNSAddFriendSucceed",
    "kFriendSNSFriendAppyReceived",
    "kFriendLBSLocationSucceed",
    "kFriendGetFriendListSucceed",
    "kFriendGetInviteListSucceed",
    "kFriendGetMyPortraitInfoSucceed",
    "kFriendGetFriendStateSucceed"
};
cc.exports.TcyFriendActionResultCode = CreatEnumTable(TcyFriendActionResultCode, 0)

-- for lbs action result code
local LBSActionResultCode = {
	"kLBSGetLBSInfoSuccess",	--/**value is callback of succeeding in lbs . */
	"kLBSGetLBSInfoFailed"  	--/**value is callback of failing in lbs . */
};
cc.exports.LBSActionResultCode = CreatEnumTable(LBSActionResultCode, 0)

-- for lbs action result code
local SocialGameChatActionResultCode = {
	"kSocialGameChatJoinChatroomSuccess",
	"kSocialGameChatJoinChatroomFailed"
};
cc.exports.SocialGameChatActionResultCode = CreatEnumTable(SocialGameChatActionResultCode, 0)

-- for share result code
local ShareResultCode = {
    "kShareSuccess",	--/**< enum value is callback of failing to sharing . */
    "kShareFail",		--/**< enum value is callback of failing to share . */
    "kShareCancel",		--/**< enum value is callback of canceling to share . */
    "kShareNetworkError"	--/**< enum value is callback of network error . */
};
cc.exports.ShareResultCode = CreatEnumTable(ShareResultCode, 0)

--for share platfrom type 
local C2DXPlatType ={
            "C2DXPlatTypeSinaWeibo",
            "C2DXPlatTypeTencentWeibo",
            "C2DXPlatTypeSohuWeibo",
            "C2DXPlatType163Weibo",
            "C2DXPlatTypeDouBan",
            "C2DXPlatTypeQZone",
            "C2DXPlatTypeRenren",
            "C2DXPlatTypeKaixin",
            "C2DXPlatTypePengyou",
            "C2DXPlatTypeFacebook",
            "C2DXPlatTypeTwitter",
            "C2DXPlatTypeEvernote",
            "C2DXPlatTypeFoursquare",
            "C2DXPlatTypeGooglePlus",
            "C2DXPlatTypeInstagram",
            "C2DXPlatTypeLinkedIn",
            "C2DXPlatTypeTumblr",
            "C2DXPlatTypeMail",
            "C2DXPlatTypeSMS",
            "C2DXPlatTypeAirPrint",
            "C2DXPlatTypeCopy",
            "C2DXPlatTypeWeixiSession",
            "C2DXPlatTypeWeixiTimeline",
            "C2DXPlatTypeQQ",
            "C2DXPlatTypeInstapaper",
            "C2DXPlatTypePocket",
            "C2DXPlatTypeYouDaoNote",
            "C2DXPlatTypeSohuKan",
            "C2DXPlatTypePinterest",
            "C2DXPlatTypeFlickr",
            "C2DXPlatTypeDropbox",
            "C2DXPlatTypeVKontakte",
            "C2DXPlatTypeWeixiFav",
            "C2DXPlatTypeYiXinSession",
            "C2DXPlatTypeYiXinTimeline",
            "C2DXPlatTypeYiXinFav",
            "C2DXPlatTypeAny"

};
cc.exports.C2DXPlatType = CreatEnumTable(C2DXPlatType, 1)

-- for share sdk content type
local  C2DXContentType =
{
    "C2DXContentTypeText",
    "C2DXContentTypeImage",
    "C2DXContentTypeNews",
    "C2DXContentTypeMusic",
    "C2DXContentTypeVideo",
    "C2DXContentTypeApp",
    "C2DXContentTypeNonGif",
    "C2DXContentTypeGif",
    "C2DXContentTypeFile"
};
cc.exports.C2DXContentType = CreatEnumTable(C2DXContentType, 0)

--for social ret code
local SocialRetCode = {
	-- code for leaderboard feature
	"kScoreSubmitSucceed",		--/**< enum value is callback of succeeding in submiting. */
    "kScoreSubmitfail",			--/**< enum value is callback of failing to submit . */
    -- code for achievement feature
    "kAchUnlockSucceed",		--/**< enum value is callback of succeeding in unlocking. */
    "kAchUnlockFail",			--/**< enum value is callback of failing to  unlock. */
    "kSocialSignInSucceed",		--/**< enum value is callback of succeeding to login. */
    "kSocialSignInFail",		--/**< enum value is callback of failing to  login. */
    "kSocialSignOutSucceed",	--/**< enum value is callback of succeeding to login. */
    "kSocialSignOutFail"		--/**< enum value is callback of failing to  login. */
};
cc.exports.SocialRetCode = CreatEnumTable(SocialRetCode, 1)

-- for user action result code
local UserActionResultCode = {
    "kLoginSuccess",	    --/**< enum value is callback of succeeding in login.*/
    "kLoginTimeOut",	--/**< enum value is callback of network error*/
    "kLoginCancel",		--/**< enum value is callback of no need login.*/
    "kLoginFail",		--/**< enum value is callback of failing to login. */
    "kLogout", 	--/**< enum value is callback of succeeding in logout. */
    "kModifyNameSuccess", 	--/**< enum value is callback after enter platform. */
    "kModifyNameFail",  	--/**< enum value is callback after exit antiAddiction. */
    "kModifySexSuccess", 		--/**< enum value is callback after exit pause page. */
    "kModifySexFail",  		--/**< enum value is callback after exit exit page. */
    "kExitSuccess",	--/**< enum value is callback after querying antiAddiction. */
    "kExitNothing",	--/**< enum value is callback after registering realname. */
    "kExitCancel",	--/**< enum alue is callback of succeeding in switching account. */
    "kAntiQueryFail",	--/**< enum value is callback of failing to switch account. */
    "kAntiQueryResutlBaby",			--/**< enum value is callback of open the shop. */
    "kAntiQueryResutlAdult",         --/**< enum value is callback of open the shop. */
    "kAntiQueryResutlUnexist",         --/**< enum value is callback of open the shop. */
    "kRealNameCompleted",
    "kModifyPasswordSuccess",
    "kModifyPasswordFail",
    "kRegisterSuccess",
    "kRegisterFail",
    "kClickCustomerService",
    "kBindMobileSucess",
    "kBindMobileFailed",
    "kUnBindMobileSucess",
    "kUnBindMobileFailed",
    "kOpenMobileLoginSuccess",
    "kOpenMobileLoginFailed",
	"kModifyMobileLoginSuccess",
	"kModifyMobileLoginFailed",
	"kVerifyHadBindMobileSuccess",
	"kVerifyHadBingMobileFailed",
	"kUpdateBirthdaySuccess",
	"kUpdateBirthdayFailed",
    "kCompleteAccountInfoSucceed",
    "kCompleteAccountInfoFailed",
    "kCompleteAccountInfoCanceled",
    "kModifyNicknameSucceed",
    "kModifyNicknameFailed",
    "kSilentLoginSucceed",
    "kSilentLoginFailed",
};
cc.exports.UserActionResultCode = CreatEnumTable(UserActionResultCode, 2)

-- for toolBar place
local ToolBarPlace = {
    "kToolBarTopLeft",		--/**< enum the toolbar is at topleft. */
    "kToolBarTopRight",		--/**< enum the toolbar is at topright. */
    "kToolBarMidLeft",		--/**< enum the toolbar is at midleft. */
    "kToolBarMidRight",		--/**< enum the toolbar is at midright. */
    "kToolBarBottomLeft", 	--/**< enum the toolbar is at bottomleft. */
    "kToolBarBottomRight" 	--/**< enum the toolbar is at bottomright. */
};
cc.exports.ToolBarPlace = CreatEnumTable(ToolBarPlace, 1)

-------------for analytics---------------
-- for analytics
local AccountType = {
    "ANONYMOUS",
    "REGISTED",
    "SINA_WEIBO",
    "TENCENT_WEIBO",
    "QQ",
    "QQ_WEIBO",
    "ND91"
}; 
cc.exports.AccountType = CreatEnumTable(AccountType, 0)

local AccountOperate = {
    "LOGIN",
    "LOGOUT",
    "REGISTER"
};
cc.exports.AccountOperate = CreatEnumTable(AccountOperate, 0)

local AccountGender = {
    "MALE",
    "FEMALE",
    "UNKNOWN"
}
cc.exports.AccountGender = CreatEnumTable(AccountGender, 0)

local TaskType = {
    "GUIDE_LINE",
    "MAIN_LINE",
    "BRANCH_LINE",
    "DAILY",
    "ACTIVITY",
    "OTHER"
};
cc.exports.TaskType = CreatEnumTable(TaskType, 0)
-------------for analytics---------------
-------------for msgtype--------------
cc.exports.MsgType= {MSG_REQUEST=1,MSG_RESPONSE=2}
-------------for msgtype--------------
--
--
---------------for ursocket--------------
cc.exports.UrSocket= {UR_SOCKET_CLOSE=1,UR_SOCKET_ERROR=2,UR_SOCKET_CONNECT=3,UR_SOCKET_GRACEFULLY_ERROR=4}
-------------for ursocket--------------

---------------for launchmode--------------
cc.exports.LaunchMode= {ALONE=1,PLATFORM=2}
cc.exports.LaunchSubMode= {DEFAULT=0,PLATFORMSET=1,PLATFORMSET2=2}
-------------for launchmode--------------

local InviteFriendType = {
    "kInviteFriendSuccess",
    "kInviteFriendFailed"
};
cc.exports.InviteFriendType = CreatEnumTable(InviteFriendType, 0)

local AgreeToBeInvitedType = {
    "kAgreeToBeInvitedSuccess",
    "kAgreeToBeInvitedFailed"
};
cc.exports.AgreeToBeInvitedType = CreatEnumTable(AgreeToBeInvitedType, 0)

local ReceiveInvitationType = {
    "kReceiveInvitationdHall",
    "kReceiveInvitationdSDK"
};
cc.exports.ReceiveInvitationType = CreatEnumTable(ReceiveInvitationType, 0)

local RoomType = {
    "kRoomTypeNormal",
    "kRoomTypeFriend"
};
cc.exports.RoomType = CreatEnumTable(RoomType, 0)

local BatteryState = {
    "kBatteryStateUnknown",
    "kBatteryStateCharging",
    "kBatteryStateDisCharging",
    "kBatteryStateNotCharging",
    "kBatteryStateFull"
};
cc.exports.BatteryState = CreatEnumTable(BatteryState, 1)

local WifiState = {
    "kWifiStateDisabling",
    "kWifiStateDisabled",
    "kWifiStateEnabling",
    "kWifiStateEnabled",
    "kWifiStateUnkonwn"
};
cc.exports.WifiState = CreatEnumTable(WifiState, 0)

local LaunchType = {
    "kLaunchTypeDefault",
    "kLaunchTypeEnter"
};
cc.exports.LaunchType = CreatEnumTable(LaunchType, 0)

local LaunchSubType = {
    "kLaunchSubTypeDefault",
    "kLaunchSubTypeInvited",
    "kLaunchSubTypeFollow",
    "kLaunchSubTypeShared",
    "kLaunchSubTypeYQW",
    "kLaunchSubTypeReplay",
    "kLaunchSubTypeQuitAndEnter"
};
cc.exports.LaunchSubType = CreatEnumTable(LaunchSubType, 0)

local LaunchSource = {
    "kLaunchSourceDefault",
    "kLaunchSourceTcyApp",
    "kLaunchSourceMlink"
};
cc.exports.LaunchSource = CreatEnumTable(LaunchSource, 0)

local LaunchDestination = {
    "kLaunchDestinationDefault",
    "kLaunchDestinationGame",
    "kLaunchDestinationGameTable",
    "kLaunchDestinationCreateTable"
};
cc.exports.LaunchDestination = CreatEnumTable(LaunchDestination, 0)

local NetworkType = {
    "kNetworkTypeDisconnection",
    "kNetworkType2G",
    "kNetworkType3G",
    "kNetworkTypeWifi",
    "kNetworkType4G",
    "kNetworkTypeUnknown",
};
cc.exports.NetworkType = CreatEnumTable(NetworkType, 0)

local MlinkNotification = {
    "kMlinkNotificationUnknown",
    "kMlinkNotificationShared"
};
cc.exports.MlinkNotification = CreatEnumTable(MlinkNotification, 0)

local TcyNotification = {
    "kTcyNotificationUnknown",
    "kTcyNotificationShared",
	"kTcyNotificationDownloadGame"
};
cc.exports.TcyNotification = CreatEnumTable(TcyNotification, 0)

local GameNotification = {
    "kGameNotificationUnknown",			    -- 未知
    "kGameNotificationEnterYQWRoom",		-- 通知平台成功进入一起玩房间
    "kGameNotificationQuitYQWRoom",		    -- 通知平台退出一起玩房间
	"kGameNotificationDownloadGame",		-- 通知平台下载另外一款游戏
	"kGameNotificationStopDownloadGame",	-- 通知平台停止下载另外一款游戏
	"kGameNotificationQuitAndEnter",		-- 通知平台退出游戏并进入另外一款游戏
};
cc.exports.GameNotification = CreatEnumTable(GameNotification, 0)

-- event string definition
local Event = {
    play = {'onStart', 'onStop'},
    transfer = {'onSuccess', 'onError', 'onProgress'},
}
-- third account type
local ThirdAccountType = {'Weixin', 'QQ'}

local ThirdAccountStatus = {
    kError = -1,
    kBinded = 0,
    kUnbinded = 1,
}
cc.exports.ThirdAccountStatus = ThirdAccountStatus

local AsyncQueryStatus = {
    kSuccess = 0,   -- operate successs
    kFailed = 1,    -- operate failed
    kDuration = 2,  -- during operating
    kException = 3, -- operate exception
}
cc.exports.AsyncQueryStatus = AsyncQueryStatus

local SpeakStatus = {
    kError = -1, -- unkonw error
    kSuccess = 0,-- operate successs
    kNoAuth = 1, -- no auth for microphone
}

local InterfaceOrientation = {
    "kPortrait",
    "kUpsideDown",
    "kLeftOnTop",
    "kRightOnTop",
    "kLandscape",
}
cc.exports.InterfaceOrientation = CreatEnumTable(InterfaceOrientation, 0)