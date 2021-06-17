#!/bin/bash

# https://support.google.com/a/answer/10026322?hl=en
# https://www.wireguard.com/netns/

# get google's ipv4 range
curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv4Prefix | select( . != null )" -r > /tmp/goog_ips
# get google's ipv6 range
#curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv6Prefix | select( . != null )" -r >> /tmp/goog_ips

# add google's ip range to wireguard config
for googip in `cat /tmp/goog_ips`; do echo "AllowedIPs = $googip" >> /etc/wireguard/wgcf.conf; done

# disable ipv6 dns records
#echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf

# get cloudflare's ipv4 range
#curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
# get cloudflare's ipv6 range
#curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips
# add cloudflare's ip range to wireguard config
#for cfip in `cat /tmp/cf_ips`; do echo "AllowedIPs = $cfip" >> /etc/wireguard/wgcf.conf; done

exit
