# warp-google
既然只想用 Warp 上 Google，为什么不只让 Warp 上 Google 呢？

## 0. 前置要求
1. `apt install jq`
2. WireGuard & wgcf 

## 1. 修改配置文件
只列出需要改的部分
```sh
[Interface]
...
PostUp = ip rule add from 主网口IP table main
PostDown = ip rule del from 主网口IP table main
...
[Peer]
...
删除 AllowedIPs = 0.0.0.0/0 和 AllowedIPs = ::/0
```
这就是你的配置文件模版了，接下来我们只要下载 Google 的 IP 段加到配置文件中即可。 PostUp 和 PostDown 是为了让你的入站 IP 不被 WireGuard 接管，一定要加。
## 2. 获取 Google IP 段
```sh
curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv4Prefix | select( . != null )" -r >> /tmp/goog_ips
#curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv6Prefix | select( . != null )" -r >> /tmp/goog_ips
```
### 将获取的 Google IP 段加入配置文件中
```
for googip in `cat /tmp/goog_ips`; do echo "AllowedIPs = $googip" >> /etc/wireguard/wgcf.conf; done
```
## 3. 启动 WireGuard
就是这么简单。
## 4. (可选) 禁用 IPv6 DNS 结果
为了避免 DNS 有时默名其妙返回 AAAA 纪录造成连接失败，建议禁止系统使用 IPv6 结果
```
echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
```
## 5. 补充
如果你除了上谷歌还想看 Neflix，有几种做法
1. 比照本文方法，将 Netflix 的 IPv4 段加入 AllowedIP
2. 比照本文方法，将 Netflix 的 IPv6 段加入 AllowedIP，并通过 V2Ray / Xray 的 routing 指定 `geosite:netfllix` 使用 IPv6
3. 把 `AllowedIPs = ::/0` 加回来，让 WireGuard 接管 谷歌的 IPv4 和 全球的 IPv6，并通过 V2Ray / Xray 的 routing 指定 `geosite:netflix` 使用 IPv6。
4. （不建议）把 `AllowedIPs = ::/0` 加回来，让 WireGuard 接管 谷歌的 IPv4 和 全球的 IPv6，并设置 DNS 优先使用 IPv6 结果。由于有些网站的 IPv6 部署情形不佳，有时即使拿到 AAAA 也连不上目标，不建议冒然使用全局 IPv6 优先的策略。

## 6. (可选) 其他 IP 段
### Cloudflare
```sh
curl -s https://www.cloudflare.com/ips-v4 >> /tmp/cf_ips
#curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips
for cfip in `cat /tmp/cf_ips`; do echo "AllowedIPs = $cfip" >> /etc/wireguard/wgcf.conf; done
```
### Telegram*
### Netflix*
### *: 非官方列表，可能存在误差
