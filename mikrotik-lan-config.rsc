/interface bridge
add name=bridge-lan
/interface list
add name=LAN
add name=WAN
# ADDRESS POOL
/ip pool
add name=dhcp ranges=192.168.1.100-192.168.1.200
/ip dhcp-server
add address-pool=dhcp disabled=no interface=bridge-lan name=dhcp1
# WHICH PORTS TO USE IN THE BRIDGE
/interface bridge port
add bridge=bridge-lan interface=ether2
add bridge=bridge-lan interface=ether3
add bridge=bridge-lan interface=ether4
add bridge=bridge-lan interface=ether5
/interface list member
add interface=bridge-lan list=LAN
add interface=ether1 list=WAN
# CREATING LAN NETWORK
/ip address
add address=192.168.1.1/24 comment=XLAN interface=bridge-lan network=192.168.1.0
/ip dhcp-server network
add address=192.168.1.0/24 dns-server=8.8.8.8,1.1.1.1 gateway=192.168.1.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1
/ip dns static
add address=192.168.1.1 name=router.lan
/ip firewall filter
add action=accept chain=input comment=Accept-ping protocol=icmp
add action=accept chain=input comment=Accept-winbox dst-port=8291 protocol=tcp
add action=accept chain=input comment=Accept-web dst-port=80 protocol=tcp
add action=accept chain=input comment=Accept-ssh dst-port=22 protocol=tcp
add action=drop chain=input comment=DROP-other
/ip route rule
add dst-address=192.168.1.0/24 table=main
# ACCESS ROUTER
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www address=X.X.X.X/32,192.168.1.0/24
set ssh address=X.X.X.X/32,192.168.1.0/24
set api disabled=yes
set winbox address=X.X.X.X/32,192.168.1.0/24
set api-ssl disabled=yes
/system clock
set time-zone-name=Europe/Madrid
/system ntp client
set enabled=yes primary-ntp=0.es.pool.ntp.org
/system identity
set name=ElMoix