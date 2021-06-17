# warp-google
既然只想用 Warp 上 Google，为什么不只让 Warp 上 Google 呢？

## 前置要求
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
+ IPv4 Only（推荐）
```sh
curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv4Prefix | select( . != null )" -r > /tmp/goog_ips
```
+ IPv6 Only
```sh
curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv6Prefix | select( . != null )" -r > /tmp/goog_ips
```
+ IPv4 & IPv6
```sh
curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv4Prefix | select( . != null )" -r > /tmp/goog_ips
curl -s https://www.gstatic.com/ipranges/goog.json | jq ".prefixes | .[] | .ipv6Prefix | select( . != null )" -r >> /tmp/goog_ips
```
## 2. 将获取的 Google IP 段加入配置文件中
```
for googip in `cat /tmp/goog_ips`; do echo "AllowedIPs = $googip" >> /etc/wireguard/wgcf.conf; done
```
## 3. 启动 WireGuard
就是这么简单。
