local AgentSystemModel  = class("AgentSystemModel", import('src.app.GameHall.models.hallext.ActivityModel'))
local SyncSender        = cc.load('asynsender').SyncSender
local UserModel         = mymodel('UserModel'):getInstance()

my.addInstance(AgentSystemModel)

AgentSystemModel.PLAYER_ISAGENT_UPDATED = "PLAYER_ISAGENT_UPDATED"

local getAgentSysBaseUrl = myhttp.getAgentSysBaseUrl
--判断当前玩家是否是代理
function AgentSystemModel:queryIsAgent()
    local client = my.jhttp:create()
    SyncSender.run(client, function()
        local sender, dataMap = SyncSender.send('queryIsAgentAccount')
        UserModel:setAgentAccount(dataMap["Data"])
        --test
        -- UserModel:setAgentAccount(true)
        self:dispatchEvent({name = self.PLAYER_ISAGENT_UPDATED})
    end)
end
--判断玩家的父账号是否是代理  userID是从assist查询的父账号的ID
function AgentSystemModel:queryIsSubAgent(userID)
    if not userID then return end
    local client = my.jhttp:create()
    SyncSender.run(client, function()
        local sender, dataMap = SyncSender.send('queryIsAgentAccount', {nUserID = userID})
        UserModel:setSubAgentAccount(dataMap["Data"])
        self:dispatchEvent({name = self.PLAYER_ISAGENT_UPDATED})
    end)
end

function AgentSystemModel:getAgentSystemUrl()
    local nUserID=UserModel.nUserID

	local params={
		uid=nUserID,
        sign = WebSignModel:getWebSign()
	}
	local paramsUrl=my.convertParamsToUrlStyle(params)
    self._curUserID = nUserID

    local addition = '/login/sso'
	local url=string.format('%s%s%s%s',getAgentSysBaseUrl(),addition,'?',paramsUrl)

	return url
end


return AgentSystemModel