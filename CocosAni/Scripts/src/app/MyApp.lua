
local MyApp = class("MyApp")

function MyApp:ctor()
    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end

    if CC_DEFAULT_ANIMATIONINTERVAL then
        if CC_DEFAULT_ANIMATIONINTERVAL <= 1 / 25 and CC_DEFAULT_ANIMATIONINTERVAL > 1 / 60 then
            cc.Director:getInstance():setAnimationInterval(CC_DEFAULT_ANIMATIONINTERVAL)
        end
    end
    math.randomseed(os.time())
    self:onCreate()
end

function MyApp:onCreate()
    self:initMainScene()
    self:initBtns()
end

function MyApp:initMainScene()
    self._nodeRoot = cc.CSLoader:createNode("res/csb/node_mainscene.csb")
    if self._nodeRoot then
        self._nodeRoot:retain()
        self._panelMain = self._nodeRoot:getChildByName("Panel_Main")
    end
end

function MyApp:getNodeMainScene()
    return self._nodeRoot
end

function MyApp:run()
    local scene = display.newScene("MainScene")
    scene:addChild(self:getNodeMainScene())
    display.runScene(scene)
end

function MyApp:initBtns()
    local btnSpriteAni = self._panelMain:getChildByName("Btn_SpriteAni")
    if btnSpriteAni then
        btnSpriteAni:addClickEventListener(handler(self, self.runSpriteAni))
    end

    local btnCsbAni = self._panelMain:getChildByName("Btn_CsbAni")
    if btnCsbAni then
        btnCsbAni:addClickEventListener(handler(self, self.runCsbAni))
    end

    local btnSkeletonAni = self._panelMain:getChildByName("Btn_SkeletonAni")
    if btnSkeletonAni then
        btnSkeletonAni:addClickEventListener(handler(self, self.runSkeletonAni))
    end

    local btnParticleAni = self._panelMain:getChildByName("Btn_ParticleAni")
    if btnParticleAni then
        btnParticleAni:addClickEventListener(handler(self, self.runParticleAni))
    end
end

-- 精灵帧动画
function MyApp:runSpriteAni()
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    -- 将plist配置文件和材质导入
    spriteFrameCache:addSpriteFrames("res/images/plist/bomb.plist", "res/images/plist/bomb.png")
    -- 新建一个动画
    local animation = cc.Animation:create()
    -- 添加精灵帧
    for i = 1, 18 do
        -- 根据在plist中的图片的名称获取
        local frameName = string.format("images/plist/bomb/bb%04d.png", i)
        local spriteFrame = spriteFrameCache:getSpriteFrame(frameName)
        animation:addSpriteFrame(spriteFrame)
    end

    -- 设置每帧延时
    animation:setDelayPerUnit(1 / 18)
    -- 设置动画播放完成后是否回到起始帧
    animation:setRestoreOriginalFrame(true)
    -- 设置动画循环次数
    animation:setLoops(3)

    local actions = {}

    -- 根据当前动画配置生成Action
    local action = cc.Animate:create(animation)
    table.insert(actions, action)

    -- 创建一个用于播放动画的精灵
    local sprite = cc.Sprite:create()
    self._panelMain:addChild(sprite)
    sprite:setPosition(display.center)
    action = cc.RemoveSelf:create()
    table.insert(actions, action)

    local action = cc.Sequence:create(actions)
    -- 精灵播放刚才生成的动画
    sprite:runAction(action)
end

-- Cocos Studio创建的csb动画
function MyApp:runCsbAni()
    local path = "res/csb/node_bombani.csb"
    -- 创建节点
    local node = cc.CSLoader:createNode(path)
    -- 创建动画
    local action = cc.CSLoader:createTimeline(path)
    if node and action then
        self._panelMain:addChild(node)
        node:setPosition(display.center)
        node:runAction(action)
        action:play("animation", false)
        print("start play csb action")
        local function frameCallback(frame)
            -- 帧事件名字
            local frameEvent = frame:getEvent()
            print(frameEvent)

            if frameEvent == "play_over" then
                node:stopAllActions()
                node:removeFromParent()
            end
        end
        -- 设置帧事件回调
        action:setFrameEventCallFunc(frameCallback)
    end
end

-- 骨骼动画
function MyApp:runSkeletonAni()
    local skeletonNode = sp.SkeletonAnimation:create("res/skeleton/baiying.json", "res/skeleton/baiying.atlas", 0.6)
    skeletonNode:setPosition(display.center)
    skeletonNode:setAnimation(0, "chuxian", true)

--    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/skeleton/chongfengqiang.ExportJson")

--    -- armature_data.name  animation_data.name
--    local armature = ccs.Armature:create("chongfengqiang2")
--    self._panelMain:addChild(armature)
--    armature:setPosition(display.center)
--    -- animation_data.mov_data.name
--    armature:getAnimation():play("chongfengqiang1")

--    local function animationEvent(armatureBack, movementType, movementID)
--        local id = movementID -- action name 在这是chongfengqiang1
--        if movementType == ccs.MovementEventType.loopComplete then
--            armatureBack:stopAllActions()
--            armatureBack:removeFromParent()
--        end
--    end
--    armature:getAnimation():setMovementEventCallFunc(animationEvent)
end

-- 粒子动画
function MyApp:runParticleAni()
    if self._bInRunParticle then
        local particle = self._panelMain:getChildByName("Particle")
        if particle then
            particle:removeFromParent()
        end
        local particleBg = self._panelMain:getChildByName("ParticleBg")
        if particleBg then
            particleBg:removeFromParent()
        end
        self._bInRunParticle = false
        return
    end

    local particleBg = cc.Sprite:create("res/images/jpg/bg_particle.jpg")
    particleBg:setPosition(display.center)
    particleBg:setName("ParticleBg")
    self._panelMain:addChild(particleBg)

    -- 这个plist中自带有纹理
    local particle = cc.ParticleSystemQuad:create("res/particle/particle_2.plist")
    -- 加载纹理
    -- particle:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png"))
    particle:setPosition(display.center)
    particle:setName("Particle")
    self._panelMain:addChild(particle)
    self._bInRunParticle = true

    -- 一下为cocos自带的一些粒子动画类
    -- -- 流星
    -- local meteor = cc.ParticleMeteor:createWithTotalParticles(130)
    -- -- meteor:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png"))
    -- meteor:setPosition(display.center)
    -- meteor:setLife(5.0)
    -- self._panelMain:addChild(meteor)

    -- -- 雨
    -- local rain = cc.ParticleRain:createWithTotalParticles(130)
    -- -- rain:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- rain:setPosition(display.center)
    -- rain:setLocalZOrder(9999)
    -- rain:setLife(5.0)
    -- self._panelMain:addChild(rain)
      
    -- -- 雪
    -- local snow = cc.ParticleSnow:createWithTotalParticles(130)
    -- -- snow:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- snow:setPosition(display.center)
    -- snow:setLocalZOrder(9999)
    -- snow:setLife(5.0)
    -- self._panelMain:addChild(snow)

    -- -- 爆炸
    -- local explosion = cc.ParticleExplosion:createWithTotalParticles(130)
    -- -- explosion:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- explosion:setPosition(display.center)
    -- explosion:setLocalZOrder(9999)
    -- explosion:setLife(5.0)
    -- self._panelMain:addChild(explosion)
    
    -- -- 烟雾
    -- local smoke = cc.ParticleSmoke:createWithTotalParticles(130)
    -- -- smoke:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- smoke:setPosition(display.center)
    -- smoke:setLocalZOrder(9999)
    -- smoke:setLife(5.0)
    -- self._panelMain:addChild(smoke)

    -- -- 旋涡
    -- local spiral = cc.ParticleSpiral:createWithTotalParticles(130)
    -- -- spiral:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- spiral:setPosition(display.center)
    -- spiral:setLocalZOrder(9999)
    -- spiral:setLife(5.0)
    -- self._panelMain:addChild(spiral)

    -- -- 太阳
    -- local sun = cc.ParticleSun:createWithTotalParticles(130)
    -- -- sun:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- sun:setPosition(display.center)
    -- sun:setLocalZOrder(9999)
    -- sun:setLife(1.0)
    -- self._panelMain:addChild(sun)

    -- -- 火焰
    -- local fire = cc.ParticleFire:createWithTotalParticles(130)
    -- -- fire:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- fire:setPosition(display.center)
    -- fire:setLocalZOrder(9999)
    -- fire:setLife(1.0)
    -- self._panelMain:addChild(fire)

    -- -- 烟火
    -- local fireworks = cc.ParticleFireworks:createWithTotalParticles(50)
    -- -- fireworks:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- fireworks:setPosition(display.center)
    -- fireworks:setLocalZOrder(9999)
    -- fireworks:setLife(1.0)
    -- self._panelMain:addChild(fireworks)

    -- -- 银河系
    -- local galaxy = cc.ParticleGalaxy:createWithTotalParticles(130)
    -- -- galaxy:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- galaxy:setPosition(display.center)
    -- galaxy:setLocalZOrder(9999)
    -- galaxy:setLife(1.0)
    -- self._panelMain:addChild(galaxy)

    -- -- 花
    -- local flower = cc.ParticleFlower:createWithTotalParticles(130)
    -- -- flower:setTexture(cc.Director:getInstance():getTextureCache():addImage("particle_texture.png")) 
    -- flower:setPosition(display.center)
    -- flower:setLocalZOrder(9999)
    -- flower:setLife(1.0)
    -- self._panelMain:addChild(flower)
end

return MyApp
