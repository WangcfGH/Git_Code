--local ReportCtrl  = class('ReportCtrl', cc.load('BaseCtrl'))
local ReportCtrl = class("ReportCtrl",  cc.load('BaseCtrl'))
local viewCreater  = import("src.app.plugins.Report.ReportView")
local ReportModel = require('src.app.plugins.Report.ReportModel'):getInstance()



--==============================--
--desc:ReportCtrl:onCreate
--time:2021-10-18 04:45:54
--@params:按钮绑定举报事件，显示面板
--playerInfo是SKGamePlayer中传进的人员信息
--@return 
--============================
function ReportCtrl:onCreate( ... )

    --绑定x的关闭按钮
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    --self:bindDestroyButton(viewNode.btnConfirm)
    local bindList={
        'btnCronfim',
    }
    --self:bindUserEventHandler(viewNode,bindList)

    self.playerInfo = {}
    self.xhr = {}
    --读取配置信息
    self:reqGamePlayConfig()
    --显示界面图片
    self:showPanel(viewNode)
    --读取服务端配置，显示各类文本信息
    self:requarePlayerInfo(viewNode)
    --绑定发送按钮的功能
    self:initialBtnClick(viewNode)
end

function ReportCtrl:reqGamePlayConfig()
    local PlayerInfo = ReportModel.ReportNameList

    --初始化读取的数据 人名 id 携银（结算是结算银两）
    if(PlayerInfo[1]) then
        self.player1_name = PlayerInfo[1].name
        self.player1_uid = PlayerInfo[1].userID
        self.player1_SilverNum = PlayerInfo[1].deposit
    end

    if(PlayerInfo[2]) then
        self.player2_name = PlayerInfo[2].name
        self.player2_uid = PlayerInfo[2].userID
        self.player2_SilverNum = PlayerInfo[2].deposit
    end

    if(PlayerInfo[3]) then
        self.player3_name = PlayerInfo[3].name
        self.player3_uid = PlayerInfo[3].userID
        self.player3_SilverNum = PlayerInfo[3].deposit
    end

    if(PlayerInfo[4]) then
        self.player4_name = PlayerInfo[4].name
        self.player4_uid = PlayerInfo[4].userID
        self.player4_SilverNum = PlayerInfo[4].deposit
    end
  

end

--绑定发送按钮
function ReportCtrl:initialBtnClick(viewNode)
    --举报按钮
    viewNode.Btn_Commit:addClickEventListener(handler(self, self.SendReportInfo))
    --关闭按钮
    viewNode.Btn_Close:addClickEventListener(handler(self, self.onClose))
end

--显示面板信息
function ReportCtrl:showPanel(viewNode)

    if(ReportModel:GetReportResultSwoitch() ~= true) then
        viewNode.Img_DepositIcon_1:setVisible(false)
        viewNode.Img_DepositIcon_2:setVisible(false)
        viewNode.Img_DepositIcon_3:setVisible(false)
    end
    
    viewNode.Txt_Field_Inform:setVisible(true)
    viewNode.Btn_Close:setVisible(true)
    
    --把所有的单选框开局都设置为false,但举报原因就自动选1
    viewNode.CheckBox_1_1:setSelected(false)
    viewNode.CheckBox_1_2:setSelected(false)
    viewNode.CheckBox_1_3:setSelected(false)
    viewNode.CheckBox_2_1:setSelected(true)
    viewNode.CheckBox_2_2:setSelected(false)

    --结算界面时，人名和携银要先隐藏
    viewNode.Txt_SilverNum_1:setVisible(false)
    viewNode.Txt_SilverNum_2:setVisible(false)
    viewNode.Txt_SilverNum_3:setVisible(false)
    viewNode.Txt_1_1:setVisible(false)
    viewNode.Txt_1_2:setVisible(false)
    viewNode.Txt_1_3:setVisible(false)


    --根据谁的面板上，初始化的举报功能，就先把谁选了
    local newObject = ReportModel.newObject 
    if(newObject ~= 0) then
        if newObject == 2 then

            viewNode.CheckBox_1_1:setSelected(true)
        elseif newObject == 3 then
            viewNode.CheckBox_1_2:setSelected(true)
        elseif newObject == 4 then
            viewNode.CheckBox_1_3:setSelected(true)
        end 
    end 

    --单选框选择1时，单选框2置否，反之亦然
    viewNode.CheckBox_2_1:addClickEventListener(function()
        if self._viewNode.CheckBox_2_1:isSelected() then
            viewNode.CheckBox_2_2:setSelected(true)
        else
            viewNode.CheckBox_2_2:setSelected(false)
        end
    end)

    viewNode.CheckBox_2_2:addClickEventListener(function()
        if self._viewNode.CheckBox_2_2:isSelected() then
            viewNode.CheckBox_2_1:setSelected(true)
        else
            viewNode.CheckBox_2_1:setSelected(false)
        end
    end)
end

--通过model获取概率面板的配置消息,修改ui的text信息
function ReportCtrl:requarePlayerInfo(viewNode)

    if ReportModel:GetReportResultSwoitch() ~= true then
        viewNode.Txt_1_1:setPosition(55,33)
        viewNode.Txt_1_2:setPosition(55,33)
        viewNode.Txt_1_3:setPosition(55,33)
    end

    viewNode.Txt_SilverNum_1:setMoney(self.player2_SilverNum)
    viewNode.Txt_SilverNum_1:setVisible(true)
    
    --角色的名字 和 银子数量不为空时显示,为空时，按钮不能点击
    if(self.player2_name and self.player2_SilverNum ) then
        self:setUserName(self.player2_name,viewNode.Txt_1_1)
        viewNode.Txt_SilverNum_1:setMoney(self.player2_SilverNum)
        viewNode.Txt_SilverNum_1:setVisible(true)
    else
        viewNode.CheckBox_1_1:setTouchEnabled(false)
    end

    if(self.player3_name and self.player3_SilverNum ) then
        self:setUserName(self.player3_name,viewNode.Txt_1_2)
        viewNode.Txt_SilverNum_2:setMoney(self.player3_SilverNum)
        viewNode.Txt_SilverNum_2:setVisible(true)
    else
        viewNode.CheckBox_1_2:setTouchEnabled(false)
    end

    if(self.player4_name and self.player4_SilverNum) then
        self:setUserName(self.player4_name,viewNode.Txt_1_3)
        viewNode.Txt_SilverNum_3:setMoney(self.player4_SilverNum)
        viewNode.Txt_SilverNum_3:setVisible(true)
    else
        viewNode.CheckBox_1_3:setTouchEnabled(false)
    end

    if ReportModel:GetReportResultSwoitch() ~= true then
        viewNode.Txt_SilverNum_1:setVisible(false)
        viewNode.Txt_SilverNum_2:setVisible(false)
        viewNode.Txt_SilverNum_3:setVisible(false)
    else
        ReportModel:SetReportResultSwoitch(false)
    end
    
end

--发送举报面板上选中的信息
function ReportCtrl:SendReportInfo()
    --确定输入框的内容
    local Report_describe = nil
    if(self._viewNode.Txt_Field_Inform:getString()) then
        Report_describe = self._viewNode.Txt_Field_Inform:getString()
    end

    --发送消息的玩家人数和名称
    local Report_uid = {}
    local Report_num = 0
    --正式网作弊的类型是14，消极游戏是15
    local Report_reason = 14
  
    --按序判断是否举报玩家2，3, 4号
    if self._viewNode.CheckBox_1_1:isSelected() then
        Report_num = Report_num + 1
        Report_uid[Report_num] = self.player2_uid
    end

    if self._viewNode.CheckBox_1_2:isSelected() then
        Report_num = Report_num + 1
        Report_uid[Report_num] = self.player3_uid
    end

    if self._viewNode.CheckBox_1_3:isSelected() then
        Report_num = Report_num + 1
        Report_uid[Report_num] = self.player4_uid
    end

    --如果没有选择举报对象，或者没有举报描述则举报失败
    if(Report_describe == "" ) then
        local tipString = "添加描述可以更快发现ta的违规行为哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        return
    elseif Report_num == 0 then
        local tipString = "请选择你的举报对象"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
        return
    end

    --按序判断举报玩家的理由
    if self._viewNode.CheckBox_2_1:isSelected() then
        if(DEBUG > 0) then
            Report_reason = 1
        else
            Report_reason = 14
        end
    end

    if self._viewNode.CheckBox_2_2:isSelected() then
        if(DEBUG > 0) then
            Report_reason = 2
        else
            Report_reason = 15
        end
    end
    
    --获取客户端ios的票据
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local accessToken = userPlugin:getAccessToken()

    --if(DEBUG > 0) then
        --accessToken = "3SI-2EkO2dx8XAqJLp7XfXanw6639Ww4Et5oqScvA9IO4gHnKJ4ReMYvIrl5stgvuD4SlqgIDwWceK1nzXnJ_Ph1Po4Xgtv1O4JOQk1re7ibNCWbazcT5m6VNFv0fHU7ikSOaooym2BydSrwNv6dMg"
    --end

    --获取渠道号
    local channel = 0
    if BusinessUtils:getInstance():getTcyChannel() then
        channel = tonumber(BusinessUtils:getInstance():getTcyChannel())
        if not channel then
            channel = -1
        end
    end

    --获取房间组别
    local gamemodel   = mymodel('GameModel'):getInstance()
    local currentTime = os.time()*1000

    --获取唯一ID，生成guid
    local GuidID =  my.getRandomUnsignedCharString(32)  

    --dump(Report_reason)
    --举报功能所需的jscon信息
    local params = {
    
        ClientType = 1,
        SubmitMode = 2,

        ChannelId = channel,
        GroupId = gamemodel.nAgentGroupID,
        GameVersion = my.getGameVersion(),
        GameRoomId  = ReportModel.roomid,


        --FromAppId = 0,
        --FromAppCode = 0,
        --FromAppVersion = 0,
        ExpandId = GuidID,
        --ExpandRemark = 0,

        ReportTypeId = Report_reason,
        GameId = tostring(my.getGameID()),
        GameCode = my.getGameShortName(),
        GameUnixTime = currentTime,
        Informer = self.player1_uid,
        AppelleeUserIds = Report_uid ,
        ReportRemark = Report_describe,
        AccessToken = accessToken,
    } 

    --HallSign = accessToken,

    local url = ReportModel.url

    self:httpPost(url, params)
end

function ReportCtrl:onClose()
    self:removeSelfInstance()
end

--收到信息后的回调函数
function ReportCtrl:repOnCallback(xhr)
    if type(xhr.responseText)=='string' and  string.len(xhr.responseText) > 0 then
        local msg = json.decode(xhr.responseText)
        local code = msg.Code
        local message = msg.Message
        --dump(msg.Message)
        local tipString = "您的举报我们已经收到，客服会积极处理"
        if(code == 0) then
            my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
            --成功回复后，关闭函数
            self:removeSelfInstance()
        else
            tipString = message
            my.informPluginByName({pluginName= 'TipPlugin' ,params={tipString=tipString,removeTime=2.0}})
        end
    end
end

--url的发送消息的打包函数
function ReportCtrl:httpPost(url, params)
    local xhr = cc.XMLHttpRequestExt:new()
    xhr.responseType = 0
    xhr:setRequestHeader('Content-Type', 'application/json')
    --KPI start
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            xhr:setRequestHeader("GsClientData", gsClient);
        end
    end
    --KPI end
    xhr:open('POST', url)
    xhr:registerScriptHandler( function()
        printLog(self.__cname, 'status: %s, response: %s', xhr.status, xhr.response)
        self:repOnCallback(xhr)
    end )
    xhr:send(json.encode(params))
    printLog(self.__cname, 'http post url: %s, params: %s', url, params)
end



function ReportCtrl:setUserName(szUserName,control)
    local utf8name = MCCharset:getInstance():gb2Utf8String(szUserName, string.len(szUserName))
    my.fitStringInWidget(utf8name, control, 115)
    control:setVisible(true)
end

function ReportCtrl:onEnter( ... )

end

function ReportCtrl:onExit( ... )
 
end


return ReportCtrl