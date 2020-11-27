#!/bin/sh

/usr/sbin/sshd -D
nginx -g 'daemon off;'
