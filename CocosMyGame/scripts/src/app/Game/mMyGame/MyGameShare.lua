local SKGameShare           = import("src.app.Game.mSKGame.SKGameShare")
local MyGameShare           = class("MyGameShare", SKGameShare)

local constStrings=cc.load('json').loader.loadFile('../mSKGame/ShareStrings.json')
local ShareCtrl=import('src.app.plugins.sharectrl.ShareCtrl')

local screen2
local curScene
local menu
local forb
local whi
local whi2

local function playBtnEffct()
    audio.playSound("res/Game/GameSound/PublicSound/Snd_pu.mp3",false)
end

local function closeShare()
    playBtnEffct()
    menu:removeFromParentAndCleanup()
    forb:setVisible(false)
    --screenShot:setVisible(false)
end

local function weixinShare()
    playBtnEffct()
    ShareCtrl:loadShareConfig()
    ShareCtrl:shareToWechatInGame()
end

local function momentsShare()
    playBtnEffct()
    ShareCtrl:loadShareConfig()
    ShareCtrl:shareToMomentsInGame()
end

function MyGameShare:screenShot()
    local size = cc.Director:getInstance():getWinSize()
    curScene = cc.Director:getInstance():getRunningScene()
    local screen = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
    
    screen:beginWithClear(1,1,1,1)
    curScene:visit()
    screen:endToLua()
    
    whi = cc.Sprite:create('res/Game/GamePic/hall_share/whiteBg.png')
    forb = cc.CSLoader:createNode('res/GameCocosStudio/csb/Forbidden.csb')
    local screenShot = cc.Sprite:createWithTexture(screen:getSprite():getTexture())
    screenShot:setAnchorPoint(0,0.5)
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

    local whiteBackSize = whi:getContentSize()
    local icoSize = ico:getContentSize()
    local whiteGap = 3
    
    local screenShotSize = screenShot:getContentSize()

    local icoScaleY = ico:getScaleY()

    local screenShotScaleY = (whiteBackSize.height - icoSize.height * icoScaleY - whiteGap * 3) / screenShotSize.height
    screenShot:setScaleY(screenShotScaleY)
    screenShot:setPosition(whiteGap, (whiteBackSize.height - icoSize.height * ico:getScaleY() - whiteGap) / 2 + icoSize.height * ico:getScaleY() + whiteGap)

    curScene:addChild(forb)
    forb:addChild(whi)
    whi:setPosition(size.width/2,size.height/2+20)
--    if size.height > 720 then
--        screenShot:setPosition(size.width/2 - 240,size.height/2 - 93)
--    else
--        screenShot:setPosition(size.width/2 - 240,size.height/2 - 55)
--    end
    forb.ctrl = self
    forb:setVisible(false)
    
end

function MyGameShare:show()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/Common.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameCocosStudio/plist/OprationBtn.plist")
    local menuClose = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrameName('Hall_Btn_Close_L.png'),
        cc.Sprite:createWithSpriteFrameName('Hall_Btn_Close_L.png'),cc.Sprite:createWithSpriteFrameName('Hall_Btn_Close_L.png'))
    local menuWeixin = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrameName('Game_Btn_ShareWeChat.png'),
        cc.Sprite:createWithSpriteFrameName('Game_Btn_ShareWeChat.png'),cc.Sprite:createWithSpriteFrameName('Game_Btn_ShareWeChat.png'))
    local menuMoments = cc.MenuItemSprite:create(cc.Sprite:createWithSpriteFrameName('Game_Btn_ShareFriends.png'),
        cc.Sprite:createWithSpriteFrameName('Game_Btn_ShareFriends.png'),cc.Sprite:createWithSpriteFrameName('Game_Btn_ShareFriends.png'))
    menuClose:registerScriptTapHandler(closeShare)
    menuWeixin:registerScriptTapHandler(weixinShare)
    menuMoments:registerScriptTapHandler(momentsShare)

    menuWeixin:setScale(0.8)
    menuMoments:setScale(0.8)

    local size = cc.Director:getInstance():getWinSize()
    menu = cc.Menu:create(menuClose,menuWeixin,menuMoments)
    if menu then
        menu:setPosition(0,0)
        curScene:addChild(menu)
--        if size.height > 720 then
--            menuClose:setPosition(size.width - 260,size.height - 110)
--        else
--            menuClose:setPosition(size.width - 260,size.height - 90)
--        end
        local whix, whiy = whi:getPosition()
        menuClose:setPosition(size.width - 260,  whiy + whi:getContentSize().height / 2)
        
       
        menuWeixin:setAnchorPoint(0,0)
        menuWeixin:setPosition(450,30)
       
        menuMoments:setAnchorPoint(0,0)
        menuMoments:setPosition(650,30)
    end
       
    forb:setVisible(true)
    
end

function MyGameShare:KaChaAni()
    local size = cc.Director:getInstance():getWinSize()
    local s1 = cc.RenderTexture:create(size.width,size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
    s1:beginWithClear(0,0,0,1)
    s1:endToLua()
    
    local sprite1 = cc.Sprite:createWithTexture(s1:getSprite():getTexture())
    local sprite2 = cc.Sprite:createWithTexture(s1:getSprite():getTexture())
    
    s1:cleanup()
    sprite1:setScaleY(0.1)
    sprite2:setScaleY(0.1)
    sprite2:setPosition(0,size.height)
    sprite1:setAnchorPoint(0,0)
    sprite2:setAnchorPoint(0,1)
    
    curScene:addChild(sprite1)
    curScene:addChild(sprite2)
    
    sprite1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.12,1,0.5),
        cc.ScaleTo:create(0.12,1,0),cc.RemoveSelf:create()))
    sprite2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.12,1,0.5),
        cc.ScaleTo:create(0.12,1,0),cc.RemoveSelf:create()))--,cc.CallFunc:create(show)))
end

function MyGameShare:saveToFile()
    local defaultPath = cc.FileUtils:getInstance():getGameWritablePath()
    print(defaultPath)
    self:prepare()
    local bRet = screen2:saveToFile('screen_shot.jpg', cc.IMAGE_FORMAT_JPEG)
    if not bRet then
        print('save file failed')
    end
    screen2:cleanup()
    screen2:release()
end

function MyGameShare:prepare()
    local size = cc.Director:getInstance():getWinSize()
    curScene = cc.Director:getInstance():getRunningScene()
    local screen = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)

    screen:beginWithClear(1,1,1,1)
    curScene:visit()
    screen:endToLua()

    whi2 = cc.Sprite:create('res/Game/GamePic/hall_share/whiteBg.png')
    local screenShot = cc.Sprite:createWithTexture(screen:getSprite():getTexture())
    screenShot:setScale(0.62)
    screenShot:setRotationSkewX(180)
    whi2:addChild(screenShot)

    local ico = cc.Sprite:create('res/Game/GamePic/hall_share/lagt_launcher.png')
    ico:setScale(0.5)
    ico:setAnchorPoint(0,0)
    ico:setPosition(3,3)
    whi2:addChild(ico)

    local label = cc.Label:create()
    label:setString(constStrings['GAME_SHARE_WORDS'])
    label:setScale(1.5)
    label:setColor(display.COLOR_BLACK)
    label:setAnchorPoint(0,0.5)
    label:setPosition(100,40)
    whi2:addChild(label)
    whi2:setAnchorPoint(0,0)
    whi2:setPosition(0,0)
    --screenShot:setPosition(400,305)
    if size.height > 720 then
        screenShot:setPosition(size.width/2 - 240,size.height/2 - 93)
    else
        screenShot:setPosition(size.width/2 - 240,size.height/2 - 55)
    end
  
    screen2 = cc.RenderTexture:create(whi:getContentSize().width, whi:getContentSize().height)
    screen2:retain()
    screen2:beginWithClear(1,1,1,1)
    whi2:visit()
    screen2:endToLua()
end

return MyGameShare