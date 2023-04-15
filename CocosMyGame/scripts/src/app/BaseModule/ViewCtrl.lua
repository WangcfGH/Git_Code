local ViewCtrl = class("ViewCtrl")

ViewCtrl.DEFAULTRUN_SCENE = ""

function ViewCtrl:ctor( ... )
    self:onCreate( ... )
end

function ViewCtrl:onCreate()
end

function ViewCtrl:run(viewPath)
    local targetPath = self:_isStringValid(viewPath) and viewPath 
                    or self:_isStringValid(self.DEFAULTRUN_SCENE) and self.DEFAULTRUN_SCENE
    assert(targetPath, 'invalid viewPath for run')

    local view = self:createView(targetPath)
    self:showAsScene(view)
end

function ViewCtrl:showAsScene(scene, transition, time, more)
    assert(type(scene) == 'userdata', 'invalid scene for showAsScene')

    display.runScene(scene, transition, time, more)
    self:_checkMobileMemory()
end

function ViewCtrl:showOnScene(view, scene)
    assert(type(view) == 'userdata', 'invalid viewPath for showAsScene')

    local targetScene = type(scene) == 'userdata' and scene or display.getRunningScene()
    if not targetScene then printError("no running scene to show") end
    targetScene:addChild(view)
end

function ViewCtrl:createView(viewPath)
    assert(viewPath, 'invalid viewPath for createView')
    local viewTarget = require(viewPath)
    local view = viewTarget and viewTarget.create and viewTarget:create()
    return view
end

function ViewCtrl:_isStringValid(str)
    return type(str) == 'string' and string.len(str) > 0
end

function ViewCtrl:_clearCache()
    cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeAllTextures()
end

function ViewCtrl:_checkMobileMemory(args)
    printLog('ViewCtrl', '_checkMobileMemory')
    local memoryInfo = DeviceUtils:getInstance():getRuntimeMemoryInfo()
    dump(memoryInfo)
    if memoryInfo.lowMemory then
        print('low memory, texture cache will be cleared')
        self:_clearCache()
    else
        print('do not clearCache since memory enough')
    end

end

return ViewCtrl