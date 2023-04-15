local ResHelper = {}
local CC_SHOW_REALCOLOR = true

function ResHelper:createArmature(INarmatureName, INarmaturePath)
    local armatureManager = ccs.ArmatureDataManager:getInstance()
    local isDataExist = armatureManager:getAnimationData(INarmatureName)

    if not isDataExist then
        if not INarmaturePath then
            printError("... what a you long sha lei ...")
            return
        end

        -- add armature
        printf(".................... holly shit ....................")
        -- need path
        local armatureName = INarmaturePath .. INarmatureName .. ".ExportJson"
        armatureManager:addArmatureFileInfo(armatureName)
    end

    local armature = ccs.Armature:create(INarmatureName)
    return armature
end


--[[--
-- 同步加载纹理
display.addSpriteFrames("Sprites.plist", "Sprites.png")

-- 异步加载纹理
local cb = function(plist, image)
    -- do something
end
display.addSpriteFrames("Sprites.plist", "Sprites.png", cb)
-- end ]]--
function ResHelper:loadSpriteFrames(INplistFilename, INimage, INcallBack)
    local sharedTextureCache = cc.Director:getInstance():getTextureCache()
    local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()

    local async = type(INcallBack) == "function"
    local asyncHandler = nil
    if async then
        asyncHandler = function(INtexture)
            local texture = sharedTextureCache:getTextureForKey(INimage)
            -- texture:setAntiAliasTexParmeters()
            assert(texture, string.format("The texture %s, %s is unavailable.", INplistFilename, INimage))
            -- addSpriteFrames 在C++中是重载函数，所以会有误报错误，不必理会
            sharedSpriteFrameCache:addSpriteFrames(INplistFilename, texture)
            INcallBack(INplistFilename, INimage)
        end
    end

    if display.TEXTURES_PIXEL_FORMAT[INimage] then
        cc.Texture2D:setDefaultAlphaPixelFormat(display.TEXTURES_PIXEL_FORMAT[INimage])
        if async then
            sharedTextureCache:addImageAsync(INimage, asyncHandler)
        else
            sharedSpriteFrameCache:addSpriteFrames(INplistFilename, INimage)
        end
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
    else
        if async then
            sharedTextureCache:addImageAsync(INimage, asyncHandler)
        else
            sharedSpriteFrameCache:addSpriteFrames(INplistFilename, INimage)
        end
    end
end

function ResHelper:load32ColorPlist(INfileName)
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
    local plistname = INfileName .. ".plist"
    local pngname = INfileName .. ".png"
    ResHelper:loadSpriteFrames(plistname, pngname)
    if not CC_SHOW_REALCOLOR then
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
    end
end

function ResHelper:loadImage(INimageName)
    if not CC_SHOW_REALCOLOR then
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_BGR_A8888)
        cc.Director:getInstance():getTextureCache():addImage(INimageName)
        cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
    else
        cc.Director:getInstance():getTextureCache():addImage(INimageName)
    end
end

function ResHelper:removeImage(INimageFileName)
    -- 释放单图资源
    display.removeImage(INimageFileName)
    display.removeSpriteFrame(INimageFileName)
end

function ResHelper:removePlistImage(INplistName)
    local plistName = INplistName .. ".plist"
    local imagename = INplistName .. ".png"
    display.removeSpriteFrames(plistName, imagename)
end

function ResHelper:loadArmature(INarmatureName, INcallBack)
    local armatureInstance = ccs.ArmatureDataManager:getInstance()
    local armatureName = INarmatureName .. ".ExportJson"

    if INcallBack then
        armatureInstance:addArmatureFileInfoAsync(armatureName, INcallBack)
    else
        armatureInstance:addArmatureFileInfo(armatureName)
    end
end

function ResHelper:removeArmature(INarmatureName)
    local armatureName = INarmatureName .. ".ExportJson"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(armatureName)
    local plistCount = 1
    for k,v in pairs(HConfigArmature) do
        local key = v["resPath"] .. v["name"]
        if key == INarmatureName then
            plistCount = v["plistCount"]
            break
        end
    end

    for i=1, plistCount do
        self:removePlistImage(INarmatureName .. (i-1))
    end
end

return ResHelper



