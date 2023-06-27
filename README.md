# SCRIPT FOR BACKUPS

File **'mikrotikbck.sh'** it's a bash script used to export the config of mikrotik routers.
With this we have a backup and automatized system to retrieve all the important config.

You have to add your clients to the 'mikrotikClient.txt' file.
If you connect to your router via ssh with another port (that's not the default) you can also add it.

This script use the 'sshpass' tool.
You could also change it and make it with pub/priv keys.
So you don't need to have plaintext passwords in a file. It's up to you.

EXAMPLE:
```
root@backups:~# ./mikrotikbck.sh mikrotikClient.txt 
```

BEFORE DOING NOTHING:
```
The backups are saved onto the /home/mikrotiks/ directory. You must create it before.
Also it saves the logs onto the /var/log/mikrotik/ directory. You must create it before.
```

CRONTAB:
```
00 15 * * 5     /root/mikrotikbck.sh /root/mikrotikClients.txt
```
# MIKROTIK CONFIG FILES

Each file is for a specific configuration for a RouterOS Mikrotik.

In this files there are some fields that have to be configured by you. You have to replace every 'ElMoix' with your custom config.

URL Firmware Mikrotik (RouterOS & SwitchOS) and Winbox for Windows: https://mikrotik.com/download

To install Winbox for Debian:  **sudo snap install winbox**

HOW TO correctly setup OpenVPN with Mikrotik: https://www.gkhan.in/how-to-configure-mikrotik-openvpn-server/

---
## CONFIG FILES
---
### 📌 Mikrotik-lan-config.rsc
```
The default to use.
It specifies the network LAN, DHCP POOL, Port Bridge, which DNS Servers to lookup, 
and a basic firewall rules to specify that you only can access the router via SSH,
HTTP and WINBOX from you network LAN and your public IP.
You have to change 'X.X.X.X/32' to your public IP to enable it.
LAN: 192.168.1.1/24
POOL: 192.168.1.100-192.168.1.200
```
---
### 📌 Mikrotik-ovpn-config.rsc
```
Instantanly create a VPN server with one user.
You have to change 'ElMoix' and 'password' field on your own.
Clue: key-size=4096, days-valid=3650, cipher=aes256

LAN: 10.10.1.1
POOL: 10.10.1.100-10.10.1.200
```
---
### 📌 Mikrotik-portforward-config.rsc
```
Firewall NAT rules.
Example IP: 192.168.1.200
Enabled for SSH (2222), HTTP (8888), HTTPS (8443) and FTP (2121).
You have to change 'X.X.X.X/32' with your public IP to access via SSH.
```
---
### 📌 Mikrotik-pppoe-config.rsc
```
If you have to setup your own connection, you will need this config (via PPPOE)
It's quite similar to 'Mikrotik-lan-config', but in this file we have to change
the user and password for our PPPOE connection and the VLAN to use it.
```
---
### 📌 Mikrotik-wifi-config.rsc
```
To enable WIFI you have to upload this file.
It creates one wifi with 2,4GHz and 5GHz.
You have to change the 'ElMoix' config with your own.
```
---
### 📌 Mikrotik-priv-wifi-config.rsc
```
To create two WIFIs; one is public and the other one is private.
The private one access the network LAN.
The public one has another pool of IP that can't acces to your LAN and your Router.
By the way, they also can go throught internet.
You need to change the fields 'ElMoix' with your own.

Public POOL: 10.8.0.10-10.8.0.220
```
---
### 📌 Mikrotik-failover-config.rsc
```
If you are a provider and you want to do a Failover between two connections via Router Mikrotik.
```
