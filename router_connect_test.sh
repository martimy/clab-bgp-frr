#!/bin/sh

# Test host-leaf connectivity
docker exec clab-bgp_frr-leaf1 ping 192.168.11.2 -c 1
docker exec clab-bgp_frr-leaf1 ping 192.168.12.2 -c 1
docker exec clab-bgp_frr-leaf2 ping 192.168.21.2 -c 1
docker exec clab-bgp_frr-leaf2 ping 192.168.22.2 -c 1
docker exec clab-bgp_frr-leaf3 ping 192.168.31.2 -c 1
docker exec clab-bgp_frr-leaf3 ping 192.168.32.2 -c 1

