#!/bin/bash

sudo /etc/init.d/redis-server stop

set -e

REDISBIN=/usr/bin/redis-server
CONFFILE=/kitsune/vagrant/redisconf

$REDISBIN $CONFFILE/redis-persistent.conf
$REDISBIN $CONFFILE/redis-test.conf
$REDISBIN $CONFFILE/redis-volatile.conf