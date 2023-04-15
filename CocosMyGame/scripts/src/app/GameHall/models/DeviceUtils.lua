
--------------------------------
-- @module DeviceUtils
-- @parent_module 

--------------------------------
-- Android: get the mac address. if no permission , will get android id
-- @function [parent=#DeviceUtils] getMacAddress 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- Android: kill the process
-- @function [parent=#DeviceUtils] terminateProcess 
-- @param self
-- @return DeviceUtils#DeviceUtils self (return value: DeviceUtils)
        
--------------------------------
-- Android: get the device id. if no permission , will get android id
-- @function [parent=#DeviceUtils] getIMEI 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- Android: 1-2g, 2-3g, 3-wifi, 4-4g, 5-other
-- @function [parent=#DeviceUtils] getNetworkType 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- Android: start installer the<br>
-- IOS: do nothing<br>
-- window: do nothing
-- @function [parent=#DeviceUtils] startApkInstaller 
-- @param self
-- @param #char apkPath
-- @return DeviceUtils#DeviceUtils self (return value: DeviceUtils)
        
--------------------------------
-- Android: getPhoneBrand
-- @function [parent=#DeviceUtils] getPhoneBrand 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- Android: android id
-- @function [parent=#DeviceUtils] getSystemId 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- Android: if apk named packageName installed
-- @function [parent=#DeviceUtils] isAppInstalled 
-- @param self
-- @param #char packageName
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- Android: getSystemVersion
-- @function [parent=#DeviceUtils] getSystemVersion 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- Android: simulator
-- @function [parent=#DeviceUtils] isSimulator 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- Android: if sim card support
-- @function [parent=#DeviceUtils] isSimCardSupported 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- Android: get the sim serical number. if no sim card , return null
-- @function [parent=#DeviceUtils] getSimSerialNumber 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- Android: get the imsi. if no sim card , return null
-- @function [parent=#DeviceUtils] getIMSI 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- Android: get the meta data form androidmainfest.xml
-- @function [parent=#DeviceUtils] getMetaDataValue 
-- @param self
-- @param #char name
-- @param #char defValue
-- @return string#string ret (return value: string)
        
--------------------------------
-- Android: the size of external memory
-- @function [parent=#DeviceUtils] getAvailableExternalMemorySize 
-- @param self
-- @return float#float ret (return value: float)
        
--------------------------------
-- Android: open apk named packageName
-- @function [parent=#DeviceUtils] openApp 
-- @param self
-- @param #char packageName
-- @return DeviceUtils#DeviceUtils self (return value: DeviceUtils)
        
--------------------------------
-- 
-- @function [parent=#DeviceUtils] isNetworkConnected 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- Android: getPhoneModel
-- @function [parent=#DeviceUtils] getPhoneModel 
-- @param self
-- @return string#string ret (return value: string)
        
--------------------------------
-- Android: open the browser to load the url
-- @function [parent=#DeviceUtils] openBrowser 
-- @param self
-- @param #char url
-- @return DeviceUtils#DeviceUtils self (return value: DeviceUtils)
        
--------------------------------
-- Android: if external memory card support
-- @function [parent=#DeviceUtils] isSdCardSupported 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#DeviceUtils] getInstance 
-- @param self
-- @return DeviceUtils#DeviceUtils ret (return value: DeviceUtils)
        
return nil
