#!/bin/bash

clean_files() {
	shopt -s dotglob
	rm -rf /tmp/*
	shopt -u dotglob
}

clean_files

xvfb-run -s '-screen 0 1750x1050x24' sh -c 'env > /tmp/xvfb.config && sleep infinity' &
while [ ! -f /tmp/xvfb.config ]; do
	sleep 1
done

export DISPLAY="$( grep 'DISPLAY=' /tmp/xvfb.config | cut -c 9- )"
export XAUTHORITY="$( grep 'XAUTHORITY=' /tmp/xvfb.config | cut -c 12- )"

x11vnc -auth "${XAUTHORITY}" -display "${DISPLAY}" -usepw -forever > /tmp/x11vnc.log 2>&1 &

nginx -g "daemon off;" &

(
	sleep 5

	echo '-------- Test Chrome Availability --------'
	curl -s http://localhost:9222/json/version

	echo '-------- Test Nginx Availability --------'
	curl -s http://localhost:9223/json/version

	echo '-------- Test Node Availability --------'
	curl -s http://localhost:9229/json/version
	echo

	echo '-------- Test Availability Finish --------'
	echo 'vncserver starts at 0.0.0.0:5900 with username "123" and password "12345678"'
	echo

) &

exec node --inspect=0.0.0.0:9229 ./index.js
