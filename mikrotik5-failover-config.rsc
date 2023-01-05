/ip firewall filter
add action=drop chain=output comment=FAILOVER-gw1-drop-per-WAN2 dst-address=1.1.1.1 out-interface=ether2-WAN2 protocol=icmp
add action=drop chain=output comment=FAILOVER-gw1-drop-per-WAN2 dst-address=8.8.8.8 out-interface=ether2-WAN2 protocol=icmp
add action=drop chain=output comment=FAILOVER-gw2-drop-per-WAN1 dst-address=8.8.4.4 out-interface=ether1-WAN1 protocol=icmp
add action=drop chain=output comment=FAILOVER-gw2-drop-per-WAN1 dst-address=64.6.64.6 out-interface=ether1-WAN1 protocol=icmp
add action=accept chain=forward comment=GRN-new-dsnat connection-nat-state=dstnat connection-state=new in-interface=ether2-WAN2
/ip firewall mangle
add action=mark-connection chain=WAN1 new-connection-mark=WAN1 passthrough=yes
add action=mark-connection chain=WAN2 new-connection-mark=WAN2 passthrough=yes
add action=mark-connection chain=input in-interface=ether1-WAN1 new-connection-mark=WAN1 passthrough=no
add action=mark-connection chain=prerouting in-interface=ether1-WAN1 new-connection-mark=WAN1 passthrough=no
add action=mark-connection chain=input in-interface=ether2-WAN2 new-connection-mark=WAN2 passthrough=no
add action=mark-connection chain=prerouting in-interface=ether2-WAN2 new-connection-mark=WAN2 passthrough=no
add action=mark-routing chain=output connection-mark=WAN1 new-routing-mark=WAN1 passthrough=no
add action=mark-routing chain=output connection-mark=WAN2 new-routing-mark=WAN2 passthrough=no
add action=mark-routing chain=prerouting connection-mark=WAN1 new-routing-mark=WAN1 passthrough=no
add action=mark-routing chain=prerouting connection-mark=WAN2 new-routing-mark=WAN2 passthrough=no
add action=mark-routing chain=prerouting connection-mark=no-mark new-routing-mark=WAN1 passthrough=no
/ip route
add comment=Routing-mark-del-FAILOVER-WAN1 distance=1 gateway=10.1.1.1 routing-mark=WAN1
add comment=Routing-mark-del-FAILOVER-WAN1 distance=2 gateway=10.2.2.2 routing-mark=WAN1
add comment=Routing-mark-del-FAILOVER-WAN2 distance=1 gateway=10.2.2.2 routing-mark=WAN2
add comment=Routing-mark-del-FAILOVER-WAN2 distance=2 gateway=10.1.1.1 routing-mark=WAN2
add comment=Default-route-del-WAN1 distance=1 gateway=2.2.2.2
add comment=Default-route-del-WAN2 distance=10 gateway=9.9.9.9
add comment=IP-check-del-FAILOVER-WAN1 distance=1 dst-address=8.8.8.8/32 gateway=2.2.2.2 scope=10
add check-gateway=ping comment=Virtual-HOP-del-FAILOVER-WAN1 distance=1 dst-address=10.1.1.1/32 gateway=1.1.1.1 scope=10
add check-gateway=ping comment=Virtual-HOP-del-FAILOVER-WAN1 distance=1 dst-address=10.1.1.1/32 gateway=8.8.8.8 scope=10
add check-gateway=ping comment=Virtual-HOP-del-FAILOVER-WAN2 distance=1 dst-address=10.2.2.2/32 gateway=8.8.4.4 scope=10
add check-gateway=ping comment=Virtual-HOP-del-FAILOVER-WAN2 distance=1 dst-address=10.2.2.2/32 gateway=64.6.64.6 scope=10
add comment=IP-check-del-FAILOVER-WAN2 distance=1 dst-address=64.6.64.6/32 gateway=9.9.9.9 scope=10
add comment=IP-check-del-FAILOVER-WAN2 distance=1 dst-address=8.8.4.4/32 gateway=9.9.9.9 scope=10
add comment=IP-check-del-FAILOVER-WAN1 distance=1 dst-address=8.8.8.8/32 gateway=2.2.2.2 scope=10
/tool netwatch
add comment=FAILOVER-WAN1 down-script="/tool e-mail send to=23andreu@gmail.com subject=FIREWALL-ElMoix-WAN1-DOWN /log error \"WAN1-DOWN\";" host=8.8.8.8 interval=30s up-script="/tool e-mail send to=23andreu@gmail.com subject=FIREWALL-ElMoix-WAN1-UP /log error \"WAN1-UP\";"
add comment=FAILOVER-WAN2 down-script="/tool e-mail send to=23andreu@gmail.com subject=FIREWALL-ElMoix-WAN2-DOWN /log error \"WAN2-DOWN\";" host=8.8.4.4 interval=30s up-script="/tool e-mail send to=23andreu@gmail.com subject=FIREWALL-ElMoix-WAN2-UP /log error \"WAN2-UP\";"