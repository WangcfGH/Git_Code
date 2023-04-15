local NationalDayActivityReq = {
    RANK_REQ={
        lengthMap = {
            -- [1] = nUserID( int ) : maxsize = 4,
            -- [2] = nRankType( int )   : maxsize = 4,
                                                    -- szUserName   : maxsize = 32  =   1 * 32 * 1,
            [3] = 32,
            maxlen = 3
        },
        nameMap = {
            'nUserID',      -- [1] ( int )
            'nRankType',        -- [2] ( int )
            'szUserName',       -- [3] ( char )
        },
        formatKey = '<i2A',
        deformatKey = '<i2A32',
        maxsize = 40
    },
}

return NationalDayActivityReq