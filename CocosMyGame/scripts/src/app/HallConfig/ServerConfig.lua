
local hallIp
local hallPort

local roomIp
local roomPort


-- common proxy begin
local commonmpIp
local commonmpPort
-- common proxy end


if BusinessUtils:getInstance():isGameDebugMode() then
    --hallIp='122.224.230.90'                              --外网 或者 内网测试机                          
    hallIp="192.168.1.222"                             --内网
    hallPort='31626'
else
	local utils = HslUtils:create( BusinessUtils:getInstance():getAbbr() )
	hallIp = utils:getHallSvrIp()
	if(type(hallIp)~='string' or hallIp:len()==0)then
		print(hallIp)
		print('hall ip empty')
	end
	hallPort = utils:getHallSvrPort()
	if( hallPort == 0 ) then
		hallPort = 31626
	end
	
	roomIp=''
	roomPort=''
end

local ServerConfig={
    hall={hallIp,hallPort},
    room={roomIp,roomPort},
	-- common proxy begin
	commonmp = {commonmpIp, commonmpPort},
	-- common proxy end
}

return ServerConfig
