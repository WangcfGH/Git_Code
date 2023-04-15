local AudioChat = {}
cc.exports.AudioChat = AudioChat
cc.exports.IsBackGround = false

local _friendPlugin     = plugin.AgentManager:getInstance():getTcyFriendPlugin()
if not  _friendPlugin then
    printError("_friendPlugin is nil")
    return
end
local _bRecording       = false
local _operateCode      = 0
local _abortCodes       = {}
local _abortTags        = {}
local _audioCallbacks   = {}
local _audioMusicVolume = 0
local _audioSoundsVolume= 0

--模拟器上模拟语音, 
local voiceRes          = "res/sound/game/chat/male/mandarin/1.mp3"   --语音路径
local duration          = 0                                             --语音时长
local durationDiff      = 1                                             --每次语音时长增量

function AudioChat:saveVolumes()
    _audioMusicVolume   = audio.getMusicVolume()
    _audioSoundsVolume  = audio.getSoundsVolume()
    print("---------AudioChat:saveVolumes", _audioMusicVolume, _audioSoundsVolume)
end

AudioChat:saveVolumes()

local function _pauseMusicAndSounds()
    audio.pauseMusic()
    audio.pauseAllSounds()
--    audio.setMusicVolume(0)
    audio.setSoundsVolume(0)
end

local function _resumeMusicAndSounds()
    audio.resumeMusic()
    audio.resumeAllSounds()
--    audio.setMusicVolume(_audioMusicVolume)
    audio.setSoundsVolume(_audioSoundsVolume)
--    print("---------AudioChat:_resumeMusicAndSounds", _audioMusicVolume, _audioSoundsVolume)
end

local function _startRecord()
    --开始录音时, 暂停音乐
    _pauseMusicAndSounds()

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        return 0
    else
        return _friendPlugin:speak()
    end
--    return value
--    SpeakStatus = {
--        kError = -1, -- unkonw error
--        kSuccess = 0,-- operate successs
--        kNoAuth = 1, -- no auth for microphone
--    }
end

local function _stopRecordAndGetFilePath()
    --录音结束后, 恢复音乐
    -- info {path, duration}
    local info = _friendPlugin:speakDone(true)
    _resumeMusicAndSounds()
    _bRecording = false
    return info
end

local function _stopRecordAndAbort()
    local result = _friendPlugin:speakDone(false)
    _resumeMusicAndSounds()

    return result
end

local function _uploadAudioFile(filePath, callback)
    return _friendPlugin:uploadFile(filePath, 'voice', function( event, info )
        --event: 'onProgress'
        --info {target, complete, total}
        --event: 'onSuccess'
        --info {target, url}
        --event: 'onError'
        --info {target, msg}
        callback(event, info)
    end)
end

--[Comment]
--instead of return local path, _getFileByUrl will only download file.
local function _getFileByUrl(url, callback)
    return _friendPlugin:downloadFile(url, function ( event, info )
        -- event: 'onProgress'
        -- info {target, complete, total}
        -- event: 'onSuccess'
        -- info {target, path}
        -- event: 'onError'
        -- info {target, msg}
        callback(event, info)
    end)
end

local function _playAudioFile(path)
    print("_playAudioFile", path)
    return _friendPlugin:playVoice(path)
end

local function _stopAudio()
    return _friendPlugin:stopPlayVoice()
end

local function _setAudioCallback(callback)
    -- armFile:string --file path
    -- event:['Start', 'Stop']
    return _friendPlugin:onVoicePlay(function( amrFile, event )
        callback( amrFile, event )
    end)
end

local function _generateOperateCode()
    local operateCode = _operateCode
    _operateCode = _operateCode + 1
    return operateCode
end

local function _enableTag(tag)
    table.removebyvalue(_abortTags, tag)
end

local function _isOperateAborted(operateCode, tag)
    return table.keyof(_abortCodes, operateCode) or table.keyof(_abortTags, tag)
end

local function _onVoicePlay( amrFile, event )
    print("--------_onVoicePlay, path:="..amrFile)
    print("event="..event)

    if event == "onStart" then
        --开始播放语音时, 暂停音乐
        _pauseMusicAndSounds()
    elseif event == "onStop" and (not cc.exports.IsBackGround)then
        --播放语音结束时, 恢复音乐
        _resumeMusicAndSounds()
    end

    for tag, handler in pairs(_audioCallbacks) do
        if type(handler) == "function" then
            handler(event)
        end
    end
end
_setAudioCallback(_onVoicePlay)

function AudioChat:isRecording()
    return _bRecording
end

function AudioChat:startRecord()
    print("AudioChat:startRecord...")

    if _bRecording then
        printError("attempt to startRecord, since recording")
        return false
    end

    _bRecording = true
    return _startRecord()
end

function AudioChat:stopRecordAndGetPathURL(callback, tag)
    print("AudioChat:stopRecordAndGetPathURL...")

    if not _bRecording then
        printError("attempt to stopRecord, since not recording")
        return false
    end

    local operateCode = _generateOperateCode()
    _enableTag(tag)

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        return
    end


    local info = _stopRecordAndGetFilePath()
    if info and info.path then
        _uploadAudioFile(info.path, function( event, info )
            if not _isOperateAborted(operateCode, tag) then
                if type(callback) == "function" then
                    callback( event, info )
                end
            else
                print("upload audio file ignored, operateCode=", operateCode)
            end
        end)
    end
    return operateCode, info
end

function AudioChat:stopRecordAndAbort()
    print("AudioChat:stopRecordAndAbort...")

    if not _bRecording then
        printError("attempt to stopRecord, since not recording")
        return false
    end

    _bRecording = false

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        return
    end

    return _stopRecordAndAbort()
end

function AudioChat:getAudioFileByUrl(url, callback, tag)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        callback("onSuccess", {path = voiceRes} )
        return 
    end
    local operateCode = _generateOperateCode()
    _enableTag(tag)

    print("getAudioFileByUrl, url=="..url)

    _getFileByUrl(url, function(...)
        if not _isOperateAborted(operateCode, tag) then
            callback(...)
        else
            print("getAudioFileByUrl over, tag is aborted", tag)
        end
    end)
    return operateCode
end

function AudioChat:playAudioByPath(path, voiceLength)
    print("AudioChat:playAudioByPath:  "..path)

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        if gameController then
            gameController:playLanguageSound(path)
        end

        my.scheduleOnce(function()
            _onVoicePlay("", "onStop")
        end, voiceLength)
    end

    return _playAudioFile(path)
end

function AudioChat:playAudioByUrl(url, tag)
    return self:getAudioFileByUrl(url, function (event, Info)
        if event == "onSuccess" then
            _playAudioFile(Info.path)
        end
    end, tag)
end

function AudioChat:abortAsynOperation(operateCode)
    table.insert(_abortCodes, operateCode)
end

function AudioChat:abortAsynOperationByTag(tag)
    table.insert( _abortTags, tag )
end

function AudioChat:stopAudio()
    return _stopAudio()
end

function AudioChat:setCallback(callback, tag)
    if type(callback) == "function" then
        if tag then
            _audioCallbacks[tag] = callback
        else
            table.insert(_audioCallbacks, calback)
        end
    else
        printError("setcallback require callable function")
    end
end

function AudioChat:removeCallback(tag)
    _audioCallbacks[tag] = nil
end

function AudioChat:setVoiceVolume(volume)--录音语音音量, 0-1
    print("AudioChat:setVoiceVolume, volume=", volume)
    if _friendPlugin.setVoiceVolume then
        _friendPlugin:setVoiceVolume(volume)
    end
end

return AudioChat
