---
title: "WinForward"
slug: winforward
published: 2026-10-30
draft: false
order: 100
description: "WinForward是一个高性能的、基于.NET的Windows专用的透明代理软件。"
image: ""
status: "developing"
tags:
  - 网络
  - 驱动
link:
  - label: Github
    icon: "fa7-brands:github"
    value: "https://github.com/Snowy117/WinForward"
---

## 为什么需要我

现有的Windows透明代理软件或多或少存在问题：

|软件|问题|
|:-:|:-:|
|Proxifier|不支持UDP|
|ProxiBridge|性能差、稳定性低，UDP错误率高|
|ProxiFyre|性能中等、DNS特殊处理|
|WinTUN类|需要篡改路由表|
|系统代理类|部分软件不尊重系统代理|

此外，没有软件支持代理转发类的流量（即，将当前Windows机器作为路由器）到给定的SOCKS服务器。

WinForward致力于解决上述问题。支持x86-64与arm64。

## 我有什么功能

下面是一个典型的WinForward配置：

```json
{
  "WinForward": {
    "Socks5Servers": [
      { "Name": "main", "Host": "proxy.example.com", "Port": 1080,
        "Username": "user", "Password": "secret" }
    ],
    "LocalTargets": [
      // 对于某些UDP流量，直接进行原样转发，不经SOCKS5
      { "Name": "dns-in", "Host": "127.0.0.1", "Port": 53 }
    ],
    "Host": {
      "FallbackAction": "pass",
      "Rules": [
        // 没有任何隐藏规则，所有流量亲自操刀
        { "Protocol": ["udp"], "RemotePort": ["67", "68"], 
          "Action": "pass" },
        { "RemoteCidr": ["fe80::/10"], "Action": "pass" },
        {
          "Process": ["browser.exe"],
          "Protocol": ["tcp", "udp"],
          "AddressFamily": ["ipv4", "ipv6"],
          "RemoteCidr": ["0.0.0.0/0", "::/0"],
          "RemotePort": ["80", "443", "10000-20000"],
          "Action": "proxy",
          "Target": "main"
        },
        { "RemoteCidr": [ "198.18.0.0/15", "2001:2::/64" ],
          "Action": "proxy", "Target": "main" },
        {
          "Process": [
            // 精准匹配进程
            "C:\\Program Files\\sing-box\\runtime\\sing-box.exe",
            "C:\\Program Files\\Tencent\\Weixin\\Weixin.exe",
            // 匹配具名进程
            "WeChatAppEx.exe",
            "WinForward.exe",
            // 按文件夹递归匹配
            "D:\\Games\\Delta Force"
          ],
          "Action": "pass"
        },
        { "RemoteCidr": [ 
            "127.0.0.0/8", "::1/128",
            "192.168.100.0/24", "192.168.77.0/24", "fd00:1234:5678:1::/64"
          ],
          "Action": "pass"
        },
        { "protocol": ["udp"], "remotePort": ["53"], 
          "Action": "proxy", "Target": "dns-in" },
        { "Action": "proxy", "Target": "main" },
      ]
    },
    "Forwarded": {
      "FallbackAction": "pass",
      "Rules": [
        // 转发NAT流量
        {
          "AdapterName": ["vEthernet (MyVM)"],
          "RemoteCidr": [ "192.168.100.0/24", "192.168.77.0/24",
                          "fd00:1234:5678:1::/64" ],
          "Action": "pass"
        },
        { "Protocol": ["udp"], "RemotePort": ["53"], 
          "Action": "proxy", "Target": "dns-in" },
        { "AdapterName": ["vEthernet (MyVM)"], 
          "Action": "proxy", "Target": "main" }
      ]
    },
    "ProxyUnavailableAction": "block",
    "ProcessingFailureAction": "block",
    "TcpFlowCapacity": 4096
  }
}
```

从上到下依次匹配所有规则，将命中首个规则的流量根据`Action`的设定进行操作（`pass`, `block`, or `proxy`）。

## 我是怎么做到的

### 后端一：WinpkFilter

借助WinpkFilter，捕获所有包并在用户态进行逐包分流，将分流包发回内核态。性能足够。

### 后端二：WinForward.Kernel（开发中）

自研WFP驱动，于内核态完成几乎所有工作，实现极致性能。
