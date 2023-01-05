# PASSWORD
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa-psk,wpa2-psk eap-methods="" \
    management-protection=allowed mode=dynamic-keys name=Wifi_Sec_Prof \
    supplicant-identity="" wpa-pre-shared-key=ElMoix wpa2-pre-shared-key=ElMoix
# WIFI 2,4 AND 5 & SSID
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=20/40mhz-Ce \
    country=spain disabled=no distance=indoors frequency=auto mode=ap-bridge \
    name=AP_BRIDGE_2.4GHZ security-profile=Wifi_Sec_Prof ssid=\
    ElMoix
set [ find default-name=wlan2 ] antenna-gain=3 band=5ghz-a/n/ac \
    channel-width=20/40/80mhz-Ceee country=spain disabled=no distance=indoors \
    frequency=auto mode=ap-bridge name=AP_BRIDGE_5GHZ security-profile=\
    Wifi_Sec_Prof ssid=ElMoix5GHZ