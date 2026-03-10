---
title: PowerShell配置文件：美化并快速启动
pinned: false
description: 让PowerShell获得更好看的界面效果，更称心如意的快捷键
tags: [pwsh, 配置, 美化]
category: 技术
author: 雪纷飞
draft: false
published: 2026-03-07
image: "./pwsh-logo.png"
---

# 预览

先来展示效果吧！

![最终的效果][效果]

# 特性

- **启动速度快**：从加载配置文件开始，到成功展示Prompt，总用时300ms。
- **简洁但美观大方**：Prompt并不花里胡哨——正相反，只展示有用的信息（用户与主机名、虚拟环境、当前目录、Git情况、退出码）。
- **追加换行**：命令执行完毕后自动追加换行。
- **无污染命名空间**：脚本的所有变量都不会污染到全局名称空间。

# 开始吧

这个配置文件基本是分块的。

## 开头

```ps1
if (-not $Host.UI -or $Host.Name -notmatch 'ConsoleHost') { return }
```

<!-- 引用 -->

[效果]: ./效果.png "效果"