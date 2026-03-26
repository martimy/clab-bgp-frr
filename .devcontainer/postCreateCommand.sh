#!/bin/bash
echo "Pre-pulling lab images (this happens only once)..."
docker pull frrouting/frr:v10.2.1
docker pull wbitt/network-multitool:alpine-extra
docker pull nicolaka/netshoot
echo "Images ready! Deploy the lab with: sudo clab deploy -t bgp-frr.clab.yml"
