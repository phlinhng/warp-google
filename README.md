# warp-google
既然只想用 Warp 上 Google，为什么不只让 Warp 上 Google 呢？

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
curl -sL https://raw.githubusercontent.com/phlinhng/warp-google/main/ip/google-v4.txt >> /tmp/goog_ips
#curl -sL https://raw.githubusercontent.com/phlinhng/warp-google/main/ip/google-v6.txt >> /tmp/goog_ips
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
curl -sL https://www.cloudflare.com/ips-v4 >> /tmp/cf_ips
#curl -sL https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips
for cfip in `cat /tmp/cf_ips`; do echo "AllowedIPs = $cfip" >> /etc/wireguard/wgcf.conf; done
```
### Telegram*
\*: 非官方列表，可能存在误差
```sh
curl -sL https://raw.githubusercontent.com/phlinhng/warp-google/main/ip/as62041-v4.txt >> /tmp/tg_ips
#curl -sL https://raw.githubusercontent.com/phlinhng/warp-google/main/ip/as62041-v6.txt >> /tmp/tg_ips
for tgip in `cat /tmp/tg_ips`; do echo "AllowedIPs = $tgip" >> /etc/wireguard/wgcf.conf; done
```
### Netflix*
\*: 非官方列表，可能存在误差
```sh
curl -sL https://raw.githubusercontent.com/phlinhng/warp-google/main/ip/as55095-v4.txt >> /tmp/nf_ips
#curl -sL https://raw.githubusercontent.com/phlinhng/warp-google/main/ip/as55095-v6.txt >> /tmp/nf_ips
for nfip in `cat /tmp/nf_ips`; do echo "AllowedIPs = $nfip" >> /etc/wireguard/wgcf.conf; done
```
### 所有公网 IPv4
由于 Wireguard 不支持排除特定 IP 段，若需要让所有公网连接走 Warp 并排除所有私网连接，可使用此列表
```sh
curl -sL https://raw.githubusercontent.com/phlinhng/warp-google/main/ip/public-v4.txt >> /tmp/public_ips
for pubip in `cat /tmp/public_ips`; do echo "AllowedIPs = $pubip" >> /etc/wireguard/wgcf.conf; done
```
