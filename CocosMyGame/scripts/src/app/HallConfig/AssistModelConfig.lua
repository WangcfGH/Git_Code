local AssistModelConfig = {
    RETRY_TIMES = 3,        -- connect retry
    KEEPALIVE = true,       -- send assist pulse or not
    WAITTIME = 5,           -- second
    PULSETIME = 30,         -- send pulse packet per x second
    ASSISTSERVER_TYPE = 3,  -- assist server type
    TIMEOUT = 15,           -- waitting time for response if need
}

if (DEBUG == 0 ) then
    AssistModelConfig.ASSISTSERVER_TYPE = 0
end

return AssistModelConfig