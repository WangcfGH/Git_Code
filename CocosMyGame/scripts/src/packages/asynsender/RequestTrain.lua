
local function _sendRequestTrain(requestTrain, client, dmap, index)
    local item = requestTrain[index]
    if not item then return end

    dmap = item[3] or checktable(dmap)
    client:setCallback(
    	function(...)
	        print('[RequestTrain.lua]on data receive ' .. tostring(item[1]))
	        item[2](...)
	        return _sendRequestTrain(requestTrain, client, dmap, index)
    	end)
    print('[RequestTrain.lua]send request ' .. tostring(item[1]))
    client:sendRequest(item[1], dmap, item[4], item[5], item[6], item[7], item[8])
    index = index + 1
end

local function sendRequestTrain(requestTrain, client, dmap)
    assert(client, '[RequestTrain.lua]sendRequestTrain()#client')
    _sendRequestTrain(requestTrain, client, dmap, 1)
end

return sendRequestTrain
