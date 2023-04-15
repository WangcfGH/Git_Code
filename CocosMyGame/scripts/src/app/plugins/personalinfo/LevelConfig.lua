
-- >=,

local configs={
	LevelConfig={
		26214400,
		13107200,
		6553600,
		3276800,
		1638400,
		819200,
		409600,
		204800,
		102400,
		51200,
		25600,
		12800,
		6400,
		3200,
        1600,
		800,
		400,
		200,
		100,
		0,
	},

}

local function getLevelStringId(score)

	--local PluginConfig=require('src.app.HallConfig.PluginConfig') or {}
	--local ExtraConfig=PluginConfig.ExtraConfig or {}
	local preString = 'G_LEVEL_'

	score=score or 0

	local config=configs["LevelConfig"]
	for k,v in ipairs(config) do
		if(score>=v)then
			return preString..tostring(#config-k+1)
		end
	end
	return preString..tostring(1)
end

return {getLevelStringId=getLevelStringId}
