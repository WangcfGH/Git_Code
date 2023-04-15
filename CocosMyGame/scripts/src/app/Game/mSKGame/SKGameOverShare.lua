local OverShare = class('OverShare')
local constStrings=cc.load('json').loader.loadFile('ShareStrings.json')
local ShareCtrl=import('src.app.plugins.sharectrl.ShareCtrl')

OverShare._screen = nil

function OverShare:share()
    self:screenShot()
    self:saveToFile()
    my.scheduleOnce(function() 
        if self._screen then      
            self._screen:cleanup()
            self._screen:release()
            self:momentsShare()
        end
    end,1.0)
    
end

function OverShare:momentsShare()
    ShareCtrl:loadShareConfig()
    ShareCtrl:shareToMomentsInGame()
end

function OverShare:shareToFriend()
    self:screenShot()
    self:saveToFile()
    my.scheduleOnce(function() 
        if self._screen then      
            self._screen:cleanup()
            self._screen:release()
            self:FriendShare()
        end
    end,1.0)
    
end

function OverShare:FriendShare()
    ShareCtrl:loadShareConfig()
    ShareCtrl:shareToWechatInGame()
end

function OverShare:screenShot()
    local size = cc.Director:getInstance():getWinSize()
    local screen = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)

    local curScene = cc.Director:getInstance():getRunningScene()

    screen:beginWithClear(1,1,1,1)
    curScene:visit()
    screen:endToLua()

    local whi = cc.Sprite:create('res/Game/GamePic/hall_share/whiteBg.png')
    local screenShot = cc.Sprite:createWithTexture(screen:getSprite():getTexture())
    screenShot:setScale(0.62)
    screenShot:setRotationSkewX(180)
    whi:addChild(screenShot)

    local ico = cc.Sprite:create('res/Game/GamePic/hall_share/lagt_launcher.png')
    ico:setScale(0.5)
    ico:setAnchorPoint(0,0)
    ico:setPosition(3,3)
    whi:addChild(ico)

    local label = cc.Label:create()
    label:setString(constStrings['GAME_SHARE_WORDS'])
    label:setScale(1.5)
    label:setColor(display.COLOR_BLACK)
    label:setAnchorPoint(0,0.5)
    label:setPosition(100,40)
    whi:addChild(label)
    whi:setAnchorPoint(0,0)
    whi:setPosition(0,0)
    screenShot:setPosition(400,305)
    
    self._screen = cc.RenderTexture:create(whi:getContentSize().width, whi:getContentSize().height)
    self._screen:retain()

    self._screen:beginWithClear(1,1,1,1)
    whi:visit()
    self._screen:endToLua()
end

function OverShare:saveToFile()

    local defaultPath = cc.FileUtils:getInstance():getGameWritablePath()
    print(defaultPath)

    local bRet = self._screen:saveToFile('screen_shot.jpg', cc.IMAGE_FORMAT_JPEG)
    if not bRet then
        print('save file failed')
    end

--    self._screen:cleanup()
--    self._screen:release()

end

return OverShare