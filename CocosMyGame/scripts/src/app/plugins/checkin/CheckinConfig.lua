
local getActivitysBaseUrl=myhttp.getActivitysBaseUrl
local getTime=myhttp.getTime
local countKeyString=myhttp.countKeyString
local getDeviceId=myhttp.getDeviceId

local config={

        -- checkin
        queryPeriodCheckinConfig={
            baseUrl=getActivitysBaseUrl(),
            addition='/checkin/GetCheckInByPeriod',
            exchangeMap={
                UserName='szUtf8Username',
                ActId='CheckinActId',--CheckinActId',
                UserId='nUserID',
                IsTrunk='IsTrunk',
            },
            privateData={
                input_charset='UTF-8',
                time=getTime,
                Key=countKeyString,
                deviceid=getDeviceId,
                ip='192.168.1.111',
            },
        },
        takeCheckin={
            baseUrl=getActivitysBaseUrl(),
            addition='/checkin/addcheckin',
            exchangeMap={
                UserName='szUtf8Username',
                ActId='CheckinActId',
                UserId='nUserID',
                --SilverToGame: 0 save to safebox, 1 save to game
                SilverToGame='SilverToGame',
                IsTrunk='IsTrunk',
            },
            privateData={
                input_charset='UTF-8',
                time=getTime,
                Key=countKeyString,
                deviceid=getDeviceId,
                ip='192.168.1.111',
            },
            --KPI start
            needKPIData = 1,
            --KPI end
        },

}

myhttp.registConfigList(config)
