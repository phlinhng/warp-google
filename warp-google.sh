#!/bin/bash

# change to your own value
gateway="10.0.10.1"
interface="eth0"
mainip="10.0.10.164"

# https://support.google.com/a/answer/10026322?hl=en
# https://www.wireguard.com/netns/

# override the default route
echo "ip rule add from $mainip table main" > /root/wg-down.sh
echo "ip route add 0.0.0.0/1 dev wgcf" >> /root/wg-up.sh
echo "ip route add 128.0.0.0/1 dev wgcf" >> /root/wg-up.sh

# restore The default route
echo "ip rule del from $mainip table main" > /root/wg-down.sh
echo "ip route del 0.0.0.0/1 dev wgcf" >> /root/wg-down.sh
echo "ip route del 128.0.0.0/1 dev wgcf" >> /root/wg-down.sh

# get google's ipv4 range
curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv4Prefix | select( . != null )" -r > /tmp/goog_ip4s

# add ip rules to wireguard script
for googip4 in `cat /tmp/goog_ip4s`; do echo "ip route add $googip4 via $gateway dev $interface" >> /root/wg-up.sh; done
for googip4 in `cat /tmp/goog_ip4s`; do echo "ip route del $googip4 via $gateway dev $interface" >> /root/wg-down.sh; done

# get cloudflare's ipv4 range
#curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ip4s
#for cfip4 in `cat /tmp/cf_ip4s`; do echo "ip route add $cfip4 via $gateway dev $interface" >> /root/wg-up.sh; done
#for cfip4 in `cat /tmp/cf_ip4s`; do echo "ip route del $cfip4 via $gateway dev $interface" >> /root/wg-down.sh; done

# disable ipv6 dns records
#echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf

# get google's ipv6 range
#curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv6Prefix | select( . != null )" -r >> /tmp/goog_ip6s
#for googip6 in `cat /tmp/goog_ip6s`; do echo "AllowedIPs = $googip6" >> /etc/wireguard/wgcf.conf; done

# get cloudflare's ipv6 range
#curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ip6s
#for cfip6 in `cat /tmp/cf_ip6s`; do echo "AllowedIPs = $cfip6" >> /etc/wireguard/wgcf.conf; done

exit
