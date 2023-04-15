local DownloadModel = class('DownloadModel',import('src.app.GameHall.models.BaseModel'))

DownloadModel.DOWNEVENT_ERROR = 'error'
DownloadModel.DOWNEVENT_PROGRESS = 'progress'
DownloadModel.DOWNEVENT_SUCCESS = 'success'

function DownloadModel:onCreate()
    self._downImplement = DownloadUtils:getInstance()
    self:_initCallback()
end

function DownloadModel:_initCallback()
    local downloadUtils = self._downImplement
    downloadUtils:setErrorCallback(function(...)
        self:_downloadCallback(self.DOWNEVENT_ERROR, ...)
        self._downloading = false
    end)

    downloadUtils:setProgressCallback(function(...)
        self:_downloadCallback(self.DOWNEVENT_PROGRESS, ...)
    end)

    downloadUtils:setSuccessCallback(function(...)
        self:_downloadCallback(self.DOWNEVENT_SUCCESS, ...)
        self._downloading = true
    end)
end

function DownloadModel:_downloadCallback(event, ...)
    if type(self._callback) == 'function' then
        self._callback(event, ...)
    end
end

function DownloadModel:download(url, callback, path)
    self._callback = callback

    if self._downloading then
        self._downloading = false
    end
    self._downloading = true

    local customid
    if type(path) == 'string' then
        customid = self._downImplement:updateAssets(url, path)
    else
        customid = self._downImplement:download(url)
    end

    self._customid = customid
    return customid
end

function DownloadModel:stopDownload()
    if self._customid then
        self._downImplement:stop(self._customid)
    end
end

function DownloadModel:resume()
    if self._customid then
        self._downImplement:resume(self._customid)
    end
end

function DownloadModel:pause()
    if self._customid then
        self._downImplement:resume(self._customid)
    end
end

function DownloadModel:getDownloadInfo(url)
    return self._downImplement:getDownloadInfo(url)
end

return DownloadModel