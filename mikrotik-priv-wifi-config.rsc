/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk,wpa2-eap \
    supplicant-identity=MikroTik wpa2-pre-shared-key=ElMoix
add authentication-types=wpa-psk,wpa2-psk mode=dynamic-keys name=ElMoix \
    supplicant-identity="" wpa-pre-shared-key=ElMoix \
    wpa2-pre-shared-key=ElMoix
add authentication-types=wpa-psk,wpa2-psk mode=dynamic-keys name=ElMoixPub \
    supplicant-identity="" wpa-pre-shared-key=ElMoix \
    wpa2-pre-shared-key=ElMoix
/interface wireless
set [ find default-name=wlan2 ] band=5ghz-a/n/ac channel-width=\
    20/40/80mhz-Ceee country=spain disabled=no frequency=auto mode=ap-bridge \
    name=ElMoix security-profile=Security_Priv ssid=ElMoix
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=20/40mhz-Ce \
    country=spain default-forwarding=no disabled=no frequency=auto mode=\
    ap-bridge name=ElMoixPub security-profile=Security_Pub ssid=\
    ElMoixPub
/ip pool
add comment="Public Wifi" name=dhcp-guests ranges=\
    10.8.0.10-10.8.0.220
/ip dhcp-server
add address-pool=dhcp-guests disabled=no interface=ElMoixPub name=\
    publicwifi
/interface bridge port
add bridge=bridge-lan interface=ElMoix
add bridge=bridge-lan interface=ElMoix2GHz
/ip address
add address=10.8.0.1/24 comment=publicwifi interface=ElMoixPub network=\
    10.8.0.0
/ip dhcp-server network
add address=10.8.0.0/24 dns-server=8.8.8.8,1.1.1.1 gateway=10.8.0.1 \
    netmask=24
/ip firewall address-list
add address=10.8.0.10-10.8.0.220 list=publicwifi
/ip firewall filter
add action=drop chain=input comment="Public Wifi - Block Ports" dst-address=\
    10.8.0.1 dst-port=80,22,8291 protocol=tcp src-address-list=publicwifi
add action=drop chain=input comment="Public Wifi - Block LAN" dst-address=\
    192.168.1.0/24 src-address-list=publicwifi