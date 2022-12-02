# kong-shutdown behavior

Kong 3.x doesn't process cleanup jobs when gracefully shutting down that require DNS lookup.  It fails with a timeout for the DNS lookup.

Some plugins require to properly handle a graceful shutdown and e.g. flushing final logs to an http endpoint (similar to http-log plugin). While in the 2.x releases the graceful shutdown properly handled and the http callout could be made
3.x doesn't allow this. The issue could be limited to the the DNS lookup. If the target host is already in the DNS cache the http call is made, otherwise it fails. 

This repository contains a minimized example to reproduce the issue. 

To reproduce start kong using: `docker-compose up -d kong` and then trigger a reload `docker-compose exec kong kong reload`

Watch the kong logs. After 60s the kong worker that is shutdown fails with a DNS error.