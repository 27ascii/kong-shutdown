# kong-shutdown behavior

# Summary:
Kong 3.x doesn't gracefully shut down when running cleanup jobs that require DNS lookups.  It fails with a timeout in the DNS lookup.

# Problem Description:
Some plugins require to properly handle a graceful shutdown and e.g. flushing final logs to an http endpoint (similar to http-log plugin). While in the 2.x releases the graceful shutdown properly handled and the http callout could be made
3.x doesn't allow this. The issue could be limited to the the DNS lookup. If the target host is already in the DNS cache the http call is made, otherwise it fails. 

This repository contains a minimized example to reproduce the issue. 

To reproduce start kong using: `docker-compose up kong` and then trigger a reload `docker-compose exec kong kong reload`

Watch the kong logs. After about 60s the kong worker that is shutdown fails with a DNS error.

```
 ⠿ Container kong  Created                                                                                                                                                                                                                            0.0s
Attaching to kong
kong  | 2022/12/02 15:47:34 [warn] 1#0: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /usr/local/kong/nginx.conf:6
kong  | nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /usr/local/kong/nginx.conf:6
kong  | 2022/12/02 15:47:35 [warn] 1109#0: *1 [kong] handler.lua:7 [shutdown-events] ++++++ init worker, context: init_worker_by_lua*
kong  | 2022/12/02 15:47:59 [warn] 1#0: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /usr/local/kong/nginx.conf:6
kong  | 2022/12/02 15:47:59 [warn] 1157#0: *149 [kong] handler.lua:7 [shutdown-events] ++++++ init worker, context: init_worker_by_lua*
kong  | 2022/12/02 15:48:00 [error] 1109#0: *3 [lua] worker.lua:248: communicate(): event worker failed: failed to receive the first 2 bytes: closed, context: ngx.timer
kong  | 2022/12/02 15:48:00 [warn] 1109#0: *3 [kong] handler.lua:7 ++++++ attempting to resolve httpbin.org, context: ngx.timer
kong  | 2022/12/02 15:48:00 [error] 1157#0: *151 [lua] worker.lua:248: communicate(): event worker failed: failed to receive the first 2 bytes: closed, context: ngx.timer
kong  | 2022/12/02 15:49:00 [warn] 1109#0: *3 [kong] handler.lua:7 ++++++ error resolving hostname: dns lookup pool exceeded retries (1): timeout, context: ngx.timer
```


