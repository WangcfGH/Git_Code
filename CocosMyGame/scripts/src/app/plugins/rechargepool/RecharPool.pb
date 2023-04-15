
»

RecharPool.protoRechargePool"E
ReqActivityInfo
userid (Ruserid
nickname (Rnickname"â
RspActivityInfo2
status (2.RechargePool.ServerStatusRstatus2
config (2.RechargePool.StaticConfigRconfig8
predayinfos (2.RechargePool.UserInfoRpredayinfos
today (Rtoday
	poolprize (R	poolprize 
daylefttime (Rdaylefttime"7
ReqRankInfo
userid (Ruserid
day (Rday"Ø
RspRankInfo
ok (Rok
day (Rday,
users (2.RechargePool.UserInfoRusers2
selfdata (2.RechargePool.UserInfoRselfdata
	poolprize (R	poolprize"6

ReqDoAward
userid (Ruserid
day (Rday"H
RspAward
ok (Rok
userid (Ruserid
count (Rcount"8
NotifyUpdate
userid (Ruserid
day (Rday"∂
UserInfo
nUserID (RnUserID

szUserName (	R
szUserName
day (Rday
nRank (RnRank
nValue (RnValue
nReward (RnReward
bAward (RbAward";
RankAwardRate
rankno (Rrankno
rate (Rrate"Å
StaticConfig
startday (Rstartday
openday (Ropenday
closeday (Rcloseday
ranknum (Rranknum
name (	Rname
ruledes (	Rruledes
addbase (Raddbase=
rewardrange (2.RechargePool.RankAwardRateRrewardrange*2
ServerStatus
OPEN
	WAITCLOSE	
CLOSE