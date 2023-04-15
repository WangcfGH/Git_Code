
local UpdateDefine = {

    CHECKSTATE = {
        STATE_NEW               = 1,
        STATE_OLD_INCOMPATIBLE  = 2,
        STATE_OLD_COMPATIBLE    = 3,
        STATE_VERSION_ERROR     = 4
    },

    TYPE_OS = {
        OS_ANDROID = 1,
        OS_IOS = 2
    },

    UPDATEDIALOG_TAG = 100,
    
    _1K_ = 1024,
}

table.merge(cc.exports, UpdateDefine)