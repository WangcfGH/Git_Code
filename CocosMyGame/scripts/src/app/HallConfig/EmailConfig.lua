local EmailConfig = {
    showRewardTogether = true,
    itemConfig = {
        localPath = "res/hall/hallpic/commonitems/commonitem5.png",
        [ItemType.JF] = {
            title = "积分",                                                                     --物品类型通用标题（服务端接口只会带类型不会带详细数据，所以标题，描述需要本地配置）
            description = "积分",                                                               --物品类型通用描述
            localPath = "res/hall/hallpic/commonitems/commonitem4.png",                                                                     --物品类型的通用图片
            extendJson = "{\"gameid\":%d}"
--            [itemID] = {                                                                      --物品类型下特定物品的属性
--                title = ""                                                                    --物品类型下特定物品的特定标题
--                description = "",                                                             --物品类型下特定物品的特定描述
--                localPath = "",                                                               --特定物品的本地图片（服务端也可以配置物品url）
--            }
        },
        [ItemType.SILVER] = {
            title = "银子",
            description = "银子",
            localPath = "res/hall/hallpic/commonitems/commonitem3.png",
            rewardTo = "directgame",                                                            --领取到的地方（directgame，deposit，back分别是游戏，保险箱，后备箱）
            extendJson = {
                directgame  = "{\"to\":\"directgame\",\"gameid\":%d}",                          --领取到游戏
                deposit     = "{\"to\":\"deposit\"}",                                           --领取到保险箱
                back        = "{\"to\":\"back\",\"gameid\":%d}",                                --领取到后备箱
            }
        },
        [ItemType.MOBILEBILL] = {
            title       = "话费",
            description = "话费",
            localPath   = "res/hall/hallpic/commonitems/commonitem8.png",
            extendJson  = "{\"mobile\":%s}",
            enableOnlineImg = true
        },
        [ItemType.REALITEM] = {
            title       = "实物",
            description = "实物",
            localPath   = "res/hall/hallpic/commonitems/commonitem6.png",
            extendJson  = "{\"mobile\":%s,\"address\":\"%s\",\"recipients\":\"%s\",\"remark\":\"%s\"}",
            enableOnlineImg = true
        },
        [ItemType.MATCHTICKETS] = {
            title       = "比赛券",
            description = "比赛券",
            localPath   = "res/hall/hallpic/commonitems/commonitem7.png",
            extendJson  = "{\"gameid\":%d}"
        },
        [ItemType.HAPPYCOIN] = {
            title       = "***",
            description = "***",
            localPath   = "res/hall/hallpic/commonitems/commonitem2.png",
            extendJson  = "{\"gameid\":%d}" 
        },
        [ItemType.EXCHANGETICKETS] = {
            title       = "礼券",
            description = "礼券",
            localPath   = "res/hall/hallpic/commonitems/commonitem1.png",
            extendJson  = ""                                                                    --礼券不用传透传字段
        },
        [ItemType.VIRTUALITEM] = {
            --虚拟物品类是指游戏特定的道具，比如记牌器等，透传字段最终会穿给游戏服务
            title       = "虚拟物品",
            description = "虚拟物品",
            localPath   = "res/hall/hallpic/commonitems/commonitem6.png",
            extendJson  = "",
--            [123]       = {
--                extendJson = "记牌器一天"                                                      --透传字段最终会透传给游戏服务器，最好根据每种不同的物品定义透传字段
--            }
        },
        [ItemType.HAPPYCOINTIKET] = {
            --虚拟物品类是指游戏特定的道具，比如记牌器等，透传字段最终会穿给游戏服务
            title       = "***券",
            description = "***券",
            localPath   = "res/hall/hallpic/commonitems/commonitem9.png",
            extendJson  = "",
--            [123]       = {
--                extendJson = "记牌器一天"                                                      --透传字段最终会透传给游戏服务器，最好根据每种不同的物品定义透传字段
--            }
        },
        ["MultiItem"] = {
            title       = "大礼包",
            description = "大礼包",
            localPath   = "res/hall/hallpic/commonitems/commonitem6.png",
            extendJson  = ""
        }
        --如果您需要领取道具，请在这里对对应的道具，填写对应的extendJson
        -- [ItemType.USERITEM[1]] = {
        --         title       = "道具1",
        --         description = "道具1",
        --         localPath   = "res/hall/hallpic/commonitems/commonitem6.png",
        --         extendJson  = "",
        --         enableOnlineImg = true
        -- }
    },
    description = {
        awardExist = "包含%d个附件",
        defaultTag = "邮件",
        deadlineTip = "(%Y-%m-%d)到期",
        noMoreMail = "没有更多邮件了",
        commonName = "奖品",
        unableToReward = "对不起，无法为您领取：%s",
        ensureDeleteAllEmail = "确认要删除所有已读的邮件吗(包含物品的邮件不会删除)",
        ensureDeleteEmail = "确认要删除邮件吗",
--        ensureDeleteAwardEmail = "邮件中包含奖励：“%s”尚未领取，请问确定要删除吗？\n请注意，邮件删除后无法恢复!",
        ensureDeleteAwardEmail = "您有奖励尚未领取，真的要删除邮件吗？\n请注意，邮件删除后无法恢复",
        noReward = "没有可领取的物品。",
    }
}

setmetatable(EmailConfig.itemConfig, {
    __index = function(_, name)
        if table.indexof(ItemType.USERITEM, name) then
            return {
                title       = "道具",
                description = "道具",
                localPath   = "res/hall/hallpic/commonitems/commonitem6.png",
                extendJson  = "",
                enableOnlineImg = true
            }
        end
    end
})

return EmailConfig