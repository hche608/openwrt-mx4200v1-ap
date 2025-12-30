#!/bin/sh
# First boot script: set hostname, LAN IP, and wireless channels based on MAC address.
# Case-insensitive MAC matching. Runs once at first boot.

# Set root password to 'admin' for initial access
echo 'root:admin' | chpasswd

# Read MAC from br-lan (preferred) or fallback to lan1
IFACE="br-lan"
MAC_ADDR="$(cat /sys/class/net/$IFACE/address 2>/dev/null)"
[ -z "$MAC_ADDR" ] && IFACE="lan1" && MAC_ADDR="$(cat /sys/class/net/$IFACE/address 2>/dev/null)"

# Abort if MAC cannot be read
[ -z "$MAC_ADDR" ] && logger -t uci-defaults "Cannot read MAC; skipping init." && exit 0

# Normalize MAC to uppercase
MAC_ADDR_UP="$(echo "$MAC_ADDR" | tr '[:lower:]' '[:upper:]')"

# Default values
HOSTNAME="NodeX"
IPADDR="192.168.192.100"
NETMASK="255.255.255.0"
GATEWAY="192.168.192.252"
DNS="192.168.192.252"
CH_RADIO0="36"   # Default 5GHz channel
CH_RADIO1="1"    # Default 2.4GHz channel
CH_RADIO2="64"   # Default second 5GHz channel

# MAC → hostname/IP/channel mapping
case "$MAC_ADDR_UP" in
  "D8:EC:5E:E1:BD:13") # Node79
    HOSTNAME="Node79"
    IPADDR="192.168.192.79"
    CH_RADIO0="36"
    CH_RADIO1="1"
    CH_RADIO2="64"
    ;;
  "D8:EC:5E:E1:B7:B4") # Node80
    HOSTNAME="Node80"
    IPADDR="192.168.192.80"
    CH_RADIO0="100"
    CH_RADIO1="11"
    CH_RADIO2="128"
    ;;
  "D8:EC:5E:E1:B6:88") # Node81
    HOSTNAME="Node81"
    IPADDR="192.168.192.81"
    CH_RADIO0="64"
    CH_RADIO1="6"
    CH_RADIO2="100"
    ;;
  *)
    # Keep defaults if no match
    ;;
esac

# Apply hostname
uci set system.@system[0].hostname="$HOSTNAME"
uci commit system

# Apply LAN IP settings
uci set network.lan.ipaddr="$IPADDR"
uci set network.lan.netmask="$NETMASK"
uci set network.lan.gateway="$GATEWAY"
uci set network.lan.dns="$DNS"
uci commit network

# Apply wireless channel settings
uci set wireless.radio0.channel="$CH_RADIO0"
uci set wireless.radio1.channel="$CH_RADIO1"
uci set wireless.radio2.channel="$CH_RADIO2"
uci commit wireless

# Optional: disable DHCP for AP mode
# uci set dhcp.lan.ignore='1'
# uci commit dhcp
# /etc/init.d/dnsmasq stop >/dev/null 2>&1 || true
# /etc/init.d/dnsmasq disable >/dev/null 2>&1 || true

# Enable SSH access
/etc/init.d/dropbear enable
/etc/init.d/dropbear start

# Restart network and wifi
/etc/init.d/network restart >/dev/null 2>&1
wifi reload >/dev/null 2>&1

logger -t uci-defaults "Init complete: MAC=$MAC_ADDR_UP hostname=$HOSTNAME IP=$IPADDR Channels=$CH_RADIO0/$CH_RADIO1/$CH_RADIO2"
exit 0

