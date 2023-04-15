
--此文件需要是utf-8编码格式
local ActivityCenterConfig = {}

ActivityCenterConfig.ActivityPropType = {
    ["jipaiqi"] = 1,
}

ActivityCenterConfig.ActivityExplain = {
    ["phonefeegift"] = 101, --话费有礼
    ["exchangelottery"] = 102, --惊奇夺宝
    ["redpack100"] = 104,   --百元红包
    ["winningstreak"] = 105, --连胜
    ["dailyrecharge"] = 106, --每日充值
}

ActivityCenterConfig.ActivityCommon = {
    ["title_btn_normal"] = "hallcocosstudio/images/plist/ActivityCenter/btn_left_nomal.png",
    ["title_btn_push"] = "hallcocosstudio/images/plist/ActivityCenter/left_yeqian_select.png",
    ["title_btn_disable"] = "hallcocosstudio/images/plist/ActivityCenter/left_yeqian_select.png",
}

ActivityCenterConfig.ActivityList = {
    [101] = {
        ["title"] = "话费有礼",
        ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
        ["bkimage_sensitive"] = "",
        ["title_text_normal"] = "",
        ["title_text_push"] = "",
        ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_xs.png",
    },

    [102] = {
        ["title"] = "惊喜夺宝",
        ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
        ["bkimage_sensitive"] = "",
        ["title_text_normal"] = "",
        ["title_text_push"] = "",
        ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_newest.png",
    },
    [103] = {
        ["title"] = "对局送礼券",
        ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
        ["bkimage_sensitive"] = "",
        ["title_text_normal"] = "",
        ["title_text_push"] = "",
        ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_hot.png",
    },
    [104] = {
        ["title"] = "百元红包礼",
        ["title2"] = "礼券大放送",
        ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
        ["bkimage_sensitive"] = "",
        ["title_text_normal"] = "",
        ["title_text_push"] = "",
        ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_xs.png",
    },
    [105] = {
        ["title"] = "连胜挑战",
        ["title2"] = "连胜挑战",
        ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
        ["bkimage_sensitive"] = "",
        ["title_text_normal"] = "",
        ["title_text_push"] = "",
        ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_xs.png",
    },
    [106] = {
        ["title"] = "每日充值",
        ["title2"] = "每日充值",
        ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
        ["bkimage_sensitive"] = "",
        ["title_text_normal"] = "",
        ["title_text_push"] = "",
        ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_newest.png",
    },
    [107] = {
        ["title"] = "对局送门票",
        ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
        ["bkimage_sensitive"] = "",
        ["title_text_normal"] = "",
        ["title_text_push"] = "",
        ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_newest.png",
    },
}
if not cc.exports.isWinningStreakSupported() then
    ActivityCenterConfig.ActivityList = {
        [101] = {
            ["title"] = "话费有礼",
            ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
            ["bkimage_sensitive"] = "",
            ["title_text_normal"] = "",
            ["title_text_push"] = "",
            ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_xs.png",
        },

        [102] = {
            ["title"] = "惊喜夺宝",
            ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
            ["bkimage_sensitive"] = "",
            ["title_text_normal"] = "",
            ["title_text_push"] = "",
            ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_newest.png",
        },
        [103] = {
            ["title"] = "对局送礼券",
            ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
            ["bkimage_sensitive"] = "",
            ["title_text_normal"] = "",
            ["title_text_push"] = "",
            ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_hot.png",
        },
        [104] = {
            ["title"] = "百元红包礼",
            ["title2"] = "礼券大放送",
            ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
            ["bkimage_sensitive"] = "",
            ["title_text_normal"] = "",
            ["title_text_push"] = "",
            ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_xs.png",
        },
        [106] = {
            ["title"] = "每日充值",
            ["title2"] = "每日充值",
            ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
            ["bkimage_sensitive"] = "",
            ["title_text_normal"] = "",
            ["title_text_push"] = "",
            ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_newest.png",
        },
        [107] = {
            ["title"] = "对局送门票",
            ["bkimage"] = "hallcocosstudio/images/plist/ActivityCenter/Nothing.png",
            ["bkimage_sensitive"] = "",
            ["title_text_normal"] = "",
            ["title_text_push"] = "",
            ["btn_label"] = "hallcocosstudio/images/plist/ActivityCenter/label_newest.png",
        },
    }
end

ActivityCenterConfig.FntContent = {
    ["话费有礼"] = 1,
    ["惊喜夺宝"] = 1,
    ["对局送礼券"] = 1,
    ["健康公告"] = 1,
    ["防沉迷公告"] = 1,
    ["版本公告"] = 1,
    ["调查问卷"] = 1,
    ["声明"] = 1,
    ["重要通知"] = 1,
    ["百元红包礼"] = 1,
    ["礼券大放送"] = 1,
    ["连胜挑战"] = 1,
    ["每日充值"] = 1,
    ["对局送门票"] = 1,
}
return ActivityCenterConfig