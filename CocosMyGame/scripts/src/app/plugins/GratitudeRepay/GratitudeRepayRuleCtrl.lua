local GratitudeRepayRuleCtrl  = class('GratitudeRepayRuleCtrl', cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.GratitudeRepay.GratitudeRepayRuleView")
local GratitudeRepayModel = require('src.app.plugins.GratitudeRepay.GratitudeRepayModel'):getInstance()

my.addInstance(GratitudeRepayRuleCtrl)

--==============================--
--desc:GratitudeRepayRuleCtrl:onCreate
--time:2021-10-18 04:45:54
--@params:按钮绑定结束事件，显示面板
--@return 
--============================
function GratitudeRepayRuleCtrl:onCreate(params)
    --绑定x的关闭按钮
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnConfirm)
    local bindList={
        'btnCronfim',
	}
    self:bindUserEventHandler(viewNode,bindList)
    --显示界面图片
    self:showPanel(viewNode)
    --读取服务端配置，显示各类文本文件
    self:requareRuleConfig(viewNode)
end

function GratitudeRepayRuleCtrl:showPanel(viewNode)
    viewNode.ImgTop:setVisible(true)
    viewNode.ImgTitle:setVisible(true)
    viewNode.ImgTitleUnder:setVisible(true)
    viewNode.btnConfirm:setVisible(true)
    viewNode.Imgform:setVisible(true)
end


--通过model获取概率面板的配置消息,修改ui的text信息
function GratitudeRepayRuleCtrl:requareRuleConfig(viewNode)
    --获取nodel的config信息,用来获取抽奖概率
    local config = GratitudeRepayModel:getConfig()

    --获取单次抽奖的金额,不同抽奖金额的概率不同
    local todayItemInfo = GratitudeRepayModel:todayItemInfo()
    local n = 1; --抽奖金额1为18一档，2为108一档
    --如果抽奖金额为108时
    if(todayItemInfo.OnePrice == config.LotteryConfig[1].AllLevelItems[2].OnePrice) then
    n = 2
    end

    local level = config.LotteryConfig[1].AllLevelItems[n].GiveItems
    --获取总的数字为10000的第6条结尾数，虽然感觉直接写10000就行
    local num = level[6].FProbabilityEnd
    local p1,p2,p3,p4,p5,p6 --抽取的概率
    
    
    --把配置消息以1到101 或者101 到400这样的结构，转换成1%或3%这样的结构
    p1 = (level[1].FProbabilityEnd - level[1].FProbabilityStart +1)/(num/100)
    p2 = (level[2].FProbabilityEnd - level[2].FProbabilityStart +1)/(num/100)
    p3 = (level[3].FProbabilityEnd - level[3].FProbabilityStart +1)/(num/100)
    p4 = (level[4].FProbabilityEnd - level[4].FProbabilityStart +1)/(num/100)
    p5 = (level[5].FProbabilityEnd - level[5].FProbabilityStart +1)/(num/100)
    p6 = (level[6].FProbabilityEnd - level[6].FProbabilityStart +1)/(num/100)
    --显示从配置消息中获取多少两
    local num1 = level[1].SliverNum
    local num2 = level[2].SliverNum
    local num3 = level[3].SliverNum
    local num4 = level[4].SliverNum
    local num5 = level[5].SliverNum
    local num6 = level[6].SliverNum
    --显示多少两
    viewNode.txt1_1:setString(string.format( "%d两",num1))
    viewNode.txt1_2:setString(string.format( "%d两",num2))
    viewNode.txt1_3:setString(string.format( "%d两",num3))
    viewNode.txt1_4:setString(string.format( "%d两",num4))
    viewNode.txt1_5:setString(string.format( "%d两",num5))
    viewNode.txt1_6:setString(string.format( "%d两",num6))
    --显示多少概率（百分号作为字符打印）
    viewNode.txt2_1:setString(string.format( "%d%s",p1,"%"))
    viewNode.txt2_2:setString(string.format( "%d%s",p2,"%"))
    viewNode.txt2_3:setString(string.format( "%d%s",p3,"%"))
    viewNode.txt2_4:setString(string.format( "%d%s",p4,"%"))
    viewNode.txt2_5:setString(string.format( "%d%s",p5,"%"))
    viewNode.txt2_6:setString(string.format( "%d%s",p6,"%"))

end




function GratitudeRepayRuleCtrl:onEnter( ... )

end

function GratitudeRepayRuleCtrl:onExit()

end


return GratitudeRepayRuleCtrl