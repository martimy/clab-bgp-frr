# Spine-Leaf Data Centre Topology using FRRouting

This lab example consists of five [FRR](https://frrouting.org/) routers connected in a spine-leaf topology (two spine and three leaf). Each leaf router is connected to two hosts.


![Lab Topology](img/topology.png)


## Requirements and credits

To use this lab, you need to install [containerlab](https://containerlab.srlinux.dev/). You also need to have basic familiarity with [Docker](https://www.docker.com/).

This lab uses the following Docker images:

- [frrouting/frr v10.2.1](https://quay.io/repository/frrouting/frr)
- [wbitt/network-multitool](https://hub.docker.com/r/wbitt/network-multitool)
- [nicolaka/netshoot](https://hub.docker.com/r/nicolaka/netshoot)


## Starting and ending the lab

Use the following command to start the lab:

```
sudo clab deploy -t bgp-frr.clab.yml
```

For convenience, use the following script to test connectivity between leaf routers and hosts:

```
./router_connect_test.sh
```

and to test connectivity between hosts:

```
./host_connect_test.sh
```

To end the lab:

```
sudo clab destroy -t bgp-frr.clab.yml --cleanup
```

## Try this

1. Confirm that BGP sessions are established among all peers.  

   ```
   docker exec clab-fdc-spine01 vtysh -c "show bgp summary"
   ```

2. Show the routes learned from BGP in the routing table. Notices there are two paths to each host.

   ```
   docker exec clab-fdc-leaf01 vtysh -c "show ip route bgp"
   ```

3. Ping from any one host to another to verify connectivity.

    ```
    docker exec clab-fdc-host11 ping 192.168.31.2
    ```

4. Use MTR/traceroute tools to observe the traffic path. Use MTR between several host pairs to confirm that paths are split between the two spine routers.

    ```
    docker exec -it clab-fdc-host11 mtr 192.168.31.2
    ```

5. There are two paths between any pair of servers. To observe how the network reacts in case of a link failure:
    a) use MTR to observe the traffic route between two servers, then
    b) disable one of the links in the route and observe the traffic resume over another route.

    ```
    docker exec -it clab-fdc-spine01 vtysh
    ```

6. To force traffic to avoid one spine router (e.g. before shutting it down for repairs), prepend the path advertised by the router using a route-map. Add the following lines to the configuration:

    ```
    route-map SERVICE permit 10
     set as-path prepend 65000 65000
    router bgp 65000
     neighbor LEAF route-map SERVICE out
    ```

    Repeat (2) to confirm there only one route to each destination.

7. Use iperf3 to send TCP traffic between hosts (requires *wbitt/network-multitool:alpine-extra*):
   a) Run iperf3 as a server in one host

   ```
   docker exec -d clab-fdc-host11 iperf3 -s
   ```

   b) Run iperf as a client from another host

   ```
   docker exec -it clab-fdc-host31 iperf3 -c 192.168.11.2
   ```

## Selected output


```bash
docker exec clab-fdc-spine01 vtysh -c "show bgp summary"
```

```
IPv4 Unicast Summary:
BGP router identifier 10.10.10.11, local AS number 65000 VRF default vrf-id 0
BGP table version 30
RIB entries 11, using 1408 bytes of memory
Peers 3, using 50 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
eth1            4      65001        32        35       30    0    0 00:00:03            2        6 N/A
eth2            4      65002        32        36       30    0    0 00:00:03            2        6 N/A
eth3            4      65003        32        36       30    0    0 00:00:03            2        6 N/A

Total number of neighbors 3
```


```bash
docker exec clab-fdc-leaf01 vtysh -c "show ip route bgp"
```

```
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

B>* 192.168.21.0/24 [20/0] via fe80::a8c1:abff:fe1e:3ec1, eth1, weight 1, 00:00:36
  *                        via fe80::a8c1:abff:fe24:a1b5, eth2, weight 1, 00:00:36
B>* 192.168.22.0/24 [20/0] via fe80::a8c1:abff:fe1e:3ec1, eth1, weight 1, 00:00:36
  *                        via fe80::a8c1:abff:fe24:a1b5, eth2, weight 1, 00:00:36
B>* 192.168.31.0/24 [20/0] via fe80::a8c1:abff:fe1e:3ec1, eth1, weight 1, 00:00:36
  *                        via fe80::a8c1:abff:fe24:a1b5, eth2, weight 1, 00:00:36
B>* 192.168.32.0/24 [20/0] via fe80::a8c1:abff:fe1e:3ec1, eth1, weight 1, 00:00:36
  *                        via fe80::a8c1:abff:fe24:a1b5, eth2, weight 1, 00:00:36
```


```bash
docker exec clab-fdc-host11 ping 192.168.31.2
```

```
PING 192.168.31.2 (192.168.31.2) 56(84) bytes of data.
64 bytes from 192.168.31.2: icmp_seq=1 ttl=61 time=0.275 ms
64 bytes from 192.168.31.2: icmp_seq=2 ttl=61 time=0.105 ms
64 bytes from 192.168.31.2: icmp_seq=3 ttl=61 time=0.424 ms
64 bytes from 192.168.31.2: icmp_seq=4 ttl=61 time=0.112 ms
64 bytes from 192.168.31.2: icmp_seq=5 ttl=61 time=0.105 ms
```

```bash
docker exec -it clab-fdc-host11 mtr 192.168.31.2
```

```
                             My traceroute  [v0.95]
host11 (192.168.11.2) -> 192.168.31.2 (192.168.31.2)    2026-03-12T01:20:14+0000
Keys:  Help   Display mode   Restart statistics   Order of fields   quit
                                        Packets               Pings
 Host                                 Loss%   Snt   Last   Avg  Best  Wrst StDev
 1. 192.168.11.1                       0.0%    20    0.1   0.2   0.1   0.7   0.2
 2. spine01                            0.0%    19    0.1   0.1   0.1   0.5   0.1
 3. 10.10.10.23                        0.0%    19    0.1   0.1   0.1   0.4   0.1
 4. 192.168.31.2                       0.0%    19    0.1   0.1   0.1   0.2   0.0
```

```bash
docker exec clab-fdc-leaf01 vtysh -c "show ip route bgp"
```

```
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

B>* 192.168.21.0/24 [20/0] via fe80::a8c1:abff:fe1e:3ec1, eth1, weight 1, 00:01:58
  *                        via fe80::a8c1:abff:fe24:a1b5, eth2, weight 1, 00:01:58
B>* 192.168.22.0/24 [20/0] via fe80::a8c1:abff:fe1e:3ec1, eth1, weight 1, 00:01:58
  *                        via fe80::a8c1:abff:fe24:a1b5, eth2, weight 1, 00:01:58
B>* 192.168.31.0/24 [20/0] via fe80::a8c1:abff:fe1e:3ec1, eth1, weight 1, 00:01:58
  *                        via fe80::a8c1:abff:fe24:a1b5, eth2, weight 1, 00:01:58
B>* 192.168.32.0/24 [20/0] via fe80::a8c1:abff:fe1e:3ec1, eth1, weight 1, 00:01:58
  *                        via fe80::a8c1:abff:fe24:a1b5, eth2, weight 1, 00:01:58
```

```bash
docker exec -d clab-fdc-host11 iperf3 -s
```

```bash
docker exec -it clab-bgp_frr-host32 iperf3 -c 192.168.11.2
```

```
Connecting to host 192.168.11.2, port 5201
[  5] local 192.168.32.2 port 49164 connected to 192.168.11.2 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   229 MBytes  1.92 Gbits/sec    0    258 KBytes
[  5]   1.00-2.01   sec   231 MBytes  1.93 Gbits/sec    0    286 KBytes
[  5]   2.01-3.00   sec   214 MBytes  1.80 Gbits/sec    6    332 KBytes
[  5]   3.00-4.00   sec   216 MBytes  1.81 Gbits/sec    0    434 KBytes
[  5]   4.00-5.00   sec   220 MBytes  1.85 Gbits/sec    6    434 KBytes
[  5]   5.00-6.00   sec   221 MBytes  1.85 Gbits/sec   27    434 KBytes
[  5]   6.00-7.00   sec   222 MBytes  1.87 Gbits/sec   13    434 KBytes
[  5]   7.00-8.01   sec   222 MBytes  1.86 Gbits/sec    0    434 KBytes
[  5]   8.01-9.00   sec   238 MBytes  2.00 Gbits/sec   13    434 KBytes
[  5]   9.00-10.01  sec   225 MBytes  1.88 Gbits/sec    0    434 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.01  sec  2.19 GBytes  1.88 Gbits/sec   65             sender
[  5]   0.00-10.01  sec  2.19 GBytes  1.88 Gbits/sec                  receiver

iperf Done.
```

## Author

Created by Maen Artimy - [Personal Blog](http://adhocnode.com)
