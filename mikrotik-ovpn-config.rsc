# Crear CA y autofirmar
/certificate add name=CA country="ES" state="GI" locality="SarriaDeDalt"
organization="TotmaticGirona" unit="Oficina" common-name="CA"
key-size=4096 days-valid=3650 key-usage=crl-sign,key-cert-sign
/certificate sign CA ca-crl-host=127.0.0.1 name="CA"

# Crear certificado del servidor OpenVPN y firmarlo con el CA
/certificate add name=SERVIDOR country="ES" state="GI"
locality="SarriaDeDalt" organization="TotmaticGirona" unit="Oficina"
common-name="SERVIDOR" key-size=4096 days-valid=3650
key-usage=digital-signature,key-encipherment,tls-server
/certificate sign SERVIDOR ca="CA" name="SERVIDOR"

# Crear plantilla de certificado para usuarios
/certificate add name=PLANTILLA-USUARIOS country="ES" state="GI"
locality="SarriaDeDalt" organization="TotmaticGirona" unit="Oficina"
common-name="USUARIOS" key-size=4096 days-valid=3650 key-usage=tls-client
/certificate sign PLANTILLA-USUARIOS ca="CA" name="PLANTILLA-USUARIOS"

# Exportar el certificado de CA
/certificate export-certificate CA export-passphrase=""

#############################################################################
# Crear tantos clientes cómo sean necesarios ejecutando estos comandos.
/certificate add name=USUARI01 copy-from="PLANTILLA-USUARIOS"
common-name="USUARI01"
/certificate sign USUARI01 ca="CA" name="USUARI01"

# Exportar los certificados con contraseña JvWje6Ut
/certificate export-certificate USUARI01 export-passphrase=JvWje6Ut
#############################################################################

# Crear el pool y el servidor DHCP de la VPN
/ip pool add name=OVPN-POOL ranges=10.10.1.100-10.10.1.254
/ip dhcp-server network add address=10.10.1.0/24 comment=VPN
dns-server=192.60.30.100 gateway=192.60.30.100 netmask=24


/ppp profile add dns-server=192.60.30.100 local-address=OVPN-POOL
name=OVPN-PERFIL  remote-address=OVPN-POOL use-compression=no
use-encryption=required
/interface ovpn-server server set certificate=SERVIDOR
cipher=blowfish128,aes128,aes192,aes256 default-profile=OVPN-PERFIL
enabled=yes  require-client-certificate=yes

/ppp secret add name=USUARI01 password=k0k4k0l4 profile=OVPN-PERFIL
service=ovpn

/ip firewall filter add action=accept chain=input comment="ACEPTAR VPN"
dst-port=1194 protocol=tcp

/ip firewall nat add chain=srcnat action=masquerade
src-address=10.10.1.0/24 log=no log-prefix="" comment="OPENVPN -> LAN"


/certificate add name=USUARI01 copy-from="PLANTILLA-USUARIOS"
common-name="USUARI01"
/certificate sign USUARI01 ca="CA" name="USUARI01"
