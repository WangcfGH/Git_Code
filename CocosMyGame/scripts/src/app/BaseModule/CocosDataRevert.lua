
local function _clone(t)
	if(t==nil)then
		return nil
	end
	local t2={}
	for k,v in pairs(t) do
		t2[k]=t[k]
	end
	return t2
end

--local curModuleName
--local function initcurModuleName()
--	local n
--	n,curModuleName= debug.getlocal(3, 1)
--end
--initcurModuleName()

--local mainModuleName
--local function initMainModuleName()
--	--	local n
--	--	n,mainModuleName= debug.getlocal(4, 1)
--	mainModuleName='src/main.lua'
--end

local function doBackUp()
--	initMainModuleName()

	local org_G=_clone(_G)
	if(cc.exports)then
		cc.exports.org_G=org_G
	else
		_G.org_G=org_G
	end

	local loaded=_clone(package.loaded)
	package.org_loaded=loaded

	local org_loaded_packages=_clone(cc.loaded_packages)
	cc.org_loaded_packages=org_loaded_packages
end

local function doRecover()
	-- !! consider if clean up gl node or not
	local package=package
	local org_loaded=package.org_loaded
	local loaded=package.loaded
	for k,v in pairs(loaded) do
		loaded[k]=org_loaded[k]
	end
	package.org_loaded=nil

--	loaded[mainModuleName]=nil
--	loaded[curModuleName]=nil

	local org_loaded_packages=cc.org_loaded_packages or {}
	local loaded_packages=cc.loaded_packages
	for k,v in pairs(loaded_packages) do
		loaded_packages[k]=org_loaded_packages[k]
	end
	package.org_loaded_packages=nil

	local org_G=_G.org_G or cc.exports.org_G
	for k,v in pairs(_G) do
		_G[k]=org_G[k]
	end
	local function enable_global()
		setmetatable(_G, nil)
	end
	enable_global()

	--	_G=org_G

	collectgarbage()
end

return {
	doBackUp=doBackUp,
	doRecover=doRecover,
}
