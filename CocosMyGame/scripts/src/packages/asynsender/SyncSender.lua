
local function send(requestId, dmap, mcName, needResponse)

	local params={}
	coroutine.yield(params, requestId, dmap, mcName, needResponse)
	return unpack(params[0])
end

local function call(plugin, func, ...)
    local params={}
    local co = coroutine.running()
    local function pluginCallback(...)
        local code,requestId,dmap, mcName, needResponse
        code,params,requestId,dmap, mcName, needResponse = coroutine.resume(co,...)
        print('coroutine code is '..tostring(code))
        if(code==true and coroutine.status(co)~='dead')then
            if requestId then -- send is comming
                assert(requestId)
                mclient:send(requestId,dmap, mcName, needResponse)
            else
                if dmap[1][dmap[2]] then
                    dmap[1][dmap[2]](dmap[1],unpack(dmap[3]),dmap[4])
                else
                    print('unexist ' .. tostring(dmap[2]) .. ' in plugin ' .. dmap[1])
                end
            end
        end
    end
    return coroutine.yield(params,nil,{plugin,func,{...},pluginCallback})
end



local function coroutineSend(co,mclient,params)

	local code, requestId, dmap, mcName, needResponse
	code, params, requestId, dmap, mcName, needResponse=coroutine.resume(co)
	print('coroutine code is '..tostring(code))
	if(code==true and coroutine.status(co)~='dead')then
            if requestId then -- send is comming
		assert(requestId)
		mclient:send(requestId, dmap, mcName, needResponse)
            else
                if dmap[1][dmap[2]] then
                    dmap[1][dmap[2]](dmap[1],unpack(dmap[3]),dmap[4])
                else
                    print('unexist ' .. tostring(dmap[2]) .. ' in plugin ' .. dmap[1])
                end
            end
        end

	return params
end

local function simpleRun(f)
    local co=coroutine.create(function()
        local status, msg = my.mxpcall(f
            , __G__TRACKBACK__)
        if not status then
            print(msg)
        end
    end)
    printInfo(co)

    coroutineSend(co,client)
end

local function run(client,f,...)
	assert(client,'')
	local co=coroutine.create(function()
		local status, msg = my.mxpcall(f
			, __G__TRACKBACK__)
		if not status then
			print(msg)
		end
	end)
	printInfo(co)

	local mclient=client
	local params
	mclient:setCallback(function ( ... )
		if(type(params)~='table')then
			printInfo(params,'')
		end
		params=checktable(params)
		params[0]={...}
		local status, msg = my.mxpcall(function()
			params=coroutineSend(co,client,params)
		end
		, __G__TRACKBACK__)
		if not status then
			print(msg)
		end
	end)

	params=coroutineSend(co,client,params)
end

return {send=send,simpleRun=simpleRun,call=call,run=run}

-------------------------
--	for example
--	syncsender.run(mclient,function()
--		local respondType,data,msgType,dataMap=syncsender.send(mc.GET_AREAS)
--		respondType,data,msgType,dataMap=syncsender.send(mc.GET_ROOMS)
--		respondType,data,msgType,dataMap=syncsender.send(mc.GET_ROOMUSERS,{nRoomCount=1,nRoomIDs={3751}})
--		dump(dataMap)
--	end)
