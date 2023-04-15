
local UserLevelReq = {
    USER_LEVEL_DATA={
        lengthMap = {
            maxlen = 6
        },
        nameMap = {
            'nUserID',
            'nLevel',
            'nLevelExp',
            'nNextExp',
            'nUpgradeDeposit',
            'nUpgradeExchange'
        },
        formatKey = '<iiiiii',
        deformatKey = '<iiiiii',
        maxsize = 24
    },
}

return UserLevelReq