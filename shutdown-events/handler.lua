local ShutdownEvents = { PRIORITY=666, VERSION="1.0.0" }

local dns = require "kong.tools.dns"
local http = require "resty.http"
local HOST = "httpbin.org"

local function log(...)
    kong.log.warn("++++++ ", ... )
end

local function shutdown_event(premature) 
    if premature and ngx.worker.exiting() then
        
        log("attempting to resolve ", HOST)
        kong.dns =  dns({dns_no_sync= true})
        local httpc = http.new()
        local res, err = httpc:request_uri("http://httpbin.org/anything")

        if err then
            log("error resolving hostname: ", err)
            return
        end
        
        log("Status: " ..  res.status)
        log("shutdown completed")
    end
end

function ShutdownEvents:init_worker()
    if ngx.config.subsystem == "stream" then 
        return
    end
    
    log("init worker")
    ngx.timer.every(60, shutdown_event)
end

return ShutdownEvents


