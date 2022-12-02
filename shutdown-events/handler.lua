local ShutdownEvents = { PRIORITY=666, VERSION="1.0.0" }

local dns_client = require("kong.tools.dns")(kong.configuration)
local HOST = "httpbin.org"

local function log(...)
    kong.log.warn("++++++ ", ... )
end

local function shutdown_event(premature) 
    if premature and ngx.worker.exiting() then
        log("attempting to resolve ", HOST)
        local records, err, try_list = dns_client.resolve(HOST)
        if err then
            log("error resolving hostname: ", err)
            return
        end
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


