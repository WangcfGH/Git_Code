
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)
    --[[
    local exitButton = cc.MenuItemImage:create("ExitButton.png", "ExitButton.png")
        :onClicked(function()
            os.exit();
        end)
    cc.Menu:create(exitButton)
        :move(display.cx, display.cy - 285)
        :addTo(self)
    --]]
    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)

end

return MainScene
