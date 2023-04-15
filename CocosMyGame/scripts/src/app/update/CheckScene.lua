local CheckScene = class('CheckScene', require('src.app.update.UpdateBaseScene'))

local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()

CheckScene.CSBDIR = 'res/hallcocosstudio/update/'
CheckScene.VIEW = 'start.csb'
CheckScene.bCreateViewNodeDelay = true

CheckScene.ANIMATIONAME = 'ani_start'
CheckScene.LOOP = false

function CheckScene:playCheckAnimation()
    if UpdateUtils.checkString(self.ANIMATIONAME) then
        self._viewNode:stopAllActions()

        local ani = cc.CSLoader:createTimeline(self.CSBDIR .. self.VIEW)
        self._viewNode:runAction(ani)
        ani:play(self.ANIMATIONAME, self.LOOP)
    end
end

function CheckScene:bindViewNode()
    local panel = self._viewNode:getChildByName('Panel_Detail')
    if panel then
        self._textTip = panel:getChildByName('Text_Detail')
        self._imageTip = panel:getChildByName('Img_DetailBG')
    end
    self._panelCopyRight = self._viewNode:getChildByName('Panel_AttentionWords')
    local panel = self._viewNode:getChildByName('Panel_Version')
    if panel then
        self._imageVerBG = panel:getChildByName('Img_BG')
        self._textVersion = panel:getChildByName('Text_Version')
    end
end

function CheckScene:onEnterTransitionFinish()
    CheckScene.super.onEnterTransitionFinish(self)
    self:playCheckAnimation()
end

function CheckScene:getVersionString(path)
    if not path or 'string' ~= type(path) then return "null" end
    if not cc.FileUtils:getInstance():isFileExist(path) then return "null" end

    local fileJson = MCFileUtils:getInstance():getStringFromFile(path)
    local version = cc.load('json').json.decode(fileJson)
    if version and version.version then
        return version.version
    else
        return "null"
    end
end

function CheckScene:showGameVersion()
    if not self._textVersion then return end
    if not self._imageVerBG then return end
    
    local filePath = "src/app/HallConfig/HallVersion.json"  -- 大厅版本号
    local strVersion = "Hall:"..self:getVersionString(filePath)

    filePath = "res/config/game/version/base.json"  -- Base层版本号
    strVersion = strVersion.." Base:"..self:getVersionString(filePath)

    filePath = "res/config/game/version/game.json"  -- Game层版本号
    strVersion = strVersion.." Game:"..self:getVersionString(filePath)

    self._textVersion:setString(strVersion)
    self._textVersion:setVisible(false)--20191029,大厅版本号隐藏
    self._imageVerBG:setVisible(false)

    local width = self._textVersion:getContentSize().width
    local height = self._imageVerBG:getContentSize().height
    self._imageVerBG:setContentSize(cc.size(width + 20, height))
end

function CheckScene:setSpringFestivalView( )
    local imageLoadingBg = self._viewNode:getChildByName('Img_BG')
    if imageLoadingBg then
        -- 春节换背景
        if SpringFestivalModel:isInSpringFestival() then
            SpringFestivalModel:setShowSpringFestivalView(true)
            imageLoadingBg:loadTexture('res/hall/hallpic/Game/png/Start/Hall_StartBG_SpringFestival.jpg')

            -- 按比例先缩放下长宽再设置大小
            local visibleSize = cc.Director:getInstance():getVisibleSize()
            local bgSize = cc.size(1600, 1000)
            if visibleSize.height / visibleSize.width > bgSize.height / bgSize.width then
                bgSize.width = visibleSize.height * bgSize.width / bgSize.height
                bgSize.height = visibleSize.height
            else
                bgSize.height = visibleSize.width * bgSize.height / bgSize.width
                bgSize.width = visibleSize.width
            end
            imageLoadingBg:setContentSize(bgSize)

            local sprite = cc.Scale9Sprite:create('res/hall/hallpic/Game/png/Start/Loading_TextBG.png')
            local panelMain = self._viewNode:getChildByName('Panel_Main')
            panelMain:setVisible(true)
            panelMain:addChild(sprite, 0)
            sprite:setAnchorPoint(cc.p(0.5, 0))
            sprite:setPosition(cc.p(visibleSize.width / 2, 0))
            sprite:setPreferredSize(cc.size(visibleSize.width, sprite:getContentSize().height))
        end
    end
end

return CheckScene