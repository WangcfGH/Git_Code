--[[

Copyright (c) 2011-2015 chukong-incc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

require "src.cocos.cocos2d.Cocos2d"
require "src.cocos.cocos2d.Cocos2dConstants"
require "src.cocos.cocos2d.functions"

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
    print(msg)
    return msg
end

-- opengl
require "src.cocos.cocos2d.Opengl"
require "src.cocos.cocos2d.OpenglConstants"
-- audio
require "src.cocos.cocosdenshion.AudioEngine"
-- cocosstudio
if nil ~= ccs then
    require "src.cocos.cocostudio.CocoStudio"
end
-- ui
if nil ~= ccui then
    require "src.cocos.ui.GuiConstants"
    require "src.cocos.ui.experimentalUIConstants"
end

-- extensions
require "src.cocos.extension.ExtensionConstants"
-- network
require "src.cocos.network.NetworkConstants"
-- Spine
if nil ~= sp then
    require "src.cocos.spine.SpineConstants"
end

require "src.cocos.cocos2d.deprecated"
require "src.cocos.cocos2d.DrawPrimitives"

-- Lua extensions
require "src.cocos.cocos2d.bitExtend"

-- CCLuaEngine
require "src.cocos.cocos2d.DeprecatedCocos2dClass"
require "src.cocos.cocos2d.DeprecatedCocos2dEnum"
require "src.cocos.cocos2d.DeprecatedCocos2dFunc"
require "src.cocos.cocos2d.DeprecatedOpenglEnum"

-- register_cocostudio_module
if nil ~= ccs then
    require "src.cocos.cocostudio.DeprecatedCocoStudioClass"
    require "src.cocos.cocostudio.DeprecatedCocoStudioFunc"
end


-- register_cocosbuilder_module
require "src.cocos.cocosbuilder.DeprecatedCocosBuilderClass"

-- register_cocosdenshion_module
require "src.cocos.cocosdenshion.DeprecatedCocosDenshionClass"
require "src.cocos.cocosdenshion.DeprecatedCocosDenshionFunc"

-- register_extension_module
require "src.cocos.extension.DeprecatedExtensionClass"
require "src.cocos.extension.DeprecatedExtensionEnum"
require "src.cocos.extension.DeprecatedExtensionFunc"

-- register_network_module
require "src.cocos.network.DeprecatedNetworkClass"
require "src.cocos.network.DeprecatedNetworkEnum"
require "src.cocos.network.DeprecatedNetworkFunc"

-- register_ui_moudle
if nil ~= ccui then
    require "src.cocos.ui.DeprecatedUIEnum"
    require "src.cocos.ui.DeprecatedUIFunc"
end

-- cocosbuilder
require "src.cocos.cocosbuilder.CCBReaderLoad"

if CC_USE_FRAMEWORK then
    require "src.cocos.framework.init"
end
