#!/bin/sh

# Test host-leaf connectivity
docker exec clab-fdc-leaf01 ping clab-fdc-spine01 -c 1
docker exec clab-fdc-leaf01 ping clab-fdc-spine02 -c 1
docker exec clab-fdc-leaf02 ping clab-fdc-spine01 -c 1
docker exec clab-fdc-leaf02 ping clab-fdc-spine02 -c 1
docker exec clab-fdc-leaf03 ping clab-fdc-spine01 -c 1
docker exec clab-fdc-leaf03 ping clab-fdc-spine02 -c 1

