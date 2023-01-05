/certificate add name=CA country="ES" state="ElMoix" locality="ElMoix"
organization="ElMoix" unit="ElMoix" common-name="CA"
key-size=4096 days-valid=3650 key-usage=crl-sign,key-cert-sign
/certificate sign CA ca-crl-host=127.0.0.1 name="CA"
/certificate add name=SERVER country="ES" state="ElMoix"
locality="ElMoix" organization="ElMoix" unit="ElMoix"
common-name="SERVER" key-size=4096 days-valid=3650
key-usage=digital-signature,key-encipherment,tls-server
/certificate sign SERVER ca="CA" name="SERVER"
/certificate add name=USER-TEMPLATE country="ES" state="ElMoix"
locality="ElMoix" organization="ElMoix" unit="ElMoix"
common-name="USERS" key-size=4096 days-valid=3650 key-usage=tls-client
/certificate sign USER-TEMPLATE ca="CA" name="USER-TEMPLATE"
/certificate export-certificate CA export-passphrase=""
/certificate add name=USER01 copy-from="USER-TEMPLATE"
common-name="USER01"
/certificate sign USER01 ca="CA" name="USER01"
/certificate export-certificate USER01 export-passphrase=password
/ip pool add name=OVPN-POOL ranges=10.10.1.100-10.10.1.200
/ip dhcp-server network add address=10.10.1.0/24 comment=VPN
dns-server=8.8.8.8 gateway=192.168.1.1 netmask=24
/ppp profile add dns-server=8.8.8.8 local-address=OVPN-POOL
name=OVPN-PERFIL  remote-address=OVPN-POOL use-compression=no
use-encryption=required
/interface ovpn-server server set certificate=SERVER
cipher=aes256 default-profile=OVPN-PERFIL
enabled=yes  require-client-certificate=yes
/ppp secret add name=USER01 password=password profile=OVPN-PERFIL
service=ovpn
/ip firewall filter add action=accept chain=input comment="ACCEPT VPN"
dst-port=1194 protocol=tcp
/ip firewall nat add chain=srcnat action=masquerade
src-address=10.10.1.0/24 log=no log-prefix="" comment="OPENVPN -> LAN"
/certificate add name=USER01 copy-from="USER-TEMPLATE"
common-name="USER01"
/certificate sign USER01 ca="CA" name="USER01"
