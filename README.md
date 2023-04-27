# Run a simple Web Server like Spitting <img src="https://www.emojirequest.com/images/SpittingEmoji.jpg" width="40" height="40"><img>

Spit is a simple web server that can be used to proxy API requests to an upstream server. Here are some quick start instructions.

# Quick start

- Run a simple HTTP server at `80` port, `static` is the html folder.
  `./run.sh start`, Visit [DEMO](http://localhost/noah.html).

- Run a simple HTTP server with specify port(`8888` here).
  `./run.sh start 8888`

- Run a simple HTTP server with some specify port and proxy backend APIs(begin with `proxyapi`)
  `./run.sh start 8888 proxyapi 192.168.5.1:8080`

- Run in `Daemon` mode.
  `./run.sh daemon 8888 proxyapi 192.168.5.1:8080`

- Stop daemon mode.
  `./run.sh stop`
