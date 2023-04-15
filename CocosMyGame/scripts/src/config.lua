
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- defualt animation interval, you can set the data between 1 / 60 and 1 / 25, as required
CC_DEFAULT_ANIMATIONINTERVAL = 1 / 60.0

-- global one touch pos
CC_GLOBAL_TOUCH_ONE_BY_ONE = true

-- for module display
CC_DESIGN_RESOLUTION = {
	width = 1280,
	height = 720,
	autoscale = "FIXED_WIDTH",
	--"FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
			return {autoscale = "FIXED_WIDTH"}
        elseif ratio >= 1.98 then --��Ϊp20�Ƚ����أ��ֱ���2240x1080��δȫ��ʱʵ�ʷֱ���2159/1080��������1.999074����Ȼ���ʺ�FIXED_WIDTH��������1.98�ж�
            -- Comprehensive screen 1080*2160
            return {autoscale = "FIXED_HEIGHT"}
        end
    end
}

CC_LUA_CODE_PATH = "src/app/"

CC_LUA_FILE_LIST = "src/app/Filelist.lua"
