
local treepack=import('.TreePack')

local totest=true

local function test(treepack)
	if(totest)then
		local tree_pack,tree_unpack=treepack.pack,treepack.unpack
		

		local UNITE_TYPE={
		lengthMap = {
			-- [1] = nCardIDs( int )	: maxsize = 4,
			maxlen = 1
		},
		nameMap = {
			'nCardIDs',		-- [0]
		},
		formatKey = '<i',
		deformatKey = '<i',
		maxsize = 4
	}
		local GAME_PUBLIC_INFO={
		lengthMap = {
					-- WaitCardUnite	: maxsize = 4	=	4 * 1 * 1,
			[1] = {maxlen = 1, maxwidth = 1, refered = UNITE_TYPE, complexType = 'link_refer'},
			-- [2] = nWaitChair( int )	: maxsize = 4,
					-- wfk	: maxsize = 32	=	1 * 32 * 1,
			[3] = 32,
					-- wfk2	: maxsize = 32	=	1 * 32 * 1,
			[4] = 32,
					-- wfk3	: maxsize = 32	=	1 * 32 * 1,
			[5] = 32,
			maxlen = 5
		},
		nameMap = {
			'WaitCardUnite',		-- [0]
			'nWaitChair',		-- [1]
			'wfk',		-- [2]
			'wfk2',		-- [3]
			'wfk3',		-- [4]
		},
		formatKey = '<i2A3',
		deformatKey = '<i2A32A32A32',
		maxsize = 104
	}

		local dataMap={}
		dataMap['nWaitChair']=455
		dataMap['WaitCardUnite']={{{nCardIDs=12}}}
		dataMap['wfk']='lkwjelfk'
		dataMap['wfk2']=''
		dataMap['wfk3']='lkwjelf3k'
		local data=tree_pack(dataMap,GAME_PUBLIC_INFO)

		local target = tree_unpack(data,GAME_PUBLIC_INFO)
		dump(target)

	end

end

test(_treepack)
