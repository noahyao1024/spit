# Run a simple Web Server like spitting.

# Quick start

```
#Run a server on port 1080, and proxy some API to upstream server.
./run.sh start 1080 north 192.168.5.1:8080

# Run in daemon mode.
./run.sh daemon 1080 north 192.168.5.1:8080

# Stop daemon mode.
./run.sh stop
```
